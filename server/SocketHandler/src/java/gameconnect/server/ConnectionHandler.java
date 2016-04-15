package gameconnect.server;

import gameconnect.server.io.MessageTypes.*;
import gameconnect.server.io.SendStrategies.*;
import gameconnect.server.io.MessageContentTypes.*;

import java.io.IOException;
import java.util.HashMap;
import javax.websocket.OnClose;
import javax.websocket.OnMessage;
import javax.websocket.OnOpen;
import javax.websocket.Session;
import javax.websocket.server.ServerEndpoint;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import gameconnect.server.context.ChatContext;
import gameconnect.server.context.DebugAnyContext;
import gameconnect.server.context.DebugContext;
import gameconnect.server.context.SnakeContext;
import gameconnect.server.database.DatabaseSupport;
import gameconnect.server.database.User;
import gameconnect.server.io.MessageTypes.GroupingCodeMessage;
import java.util.Random;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 *
 * @author davidboschwitz
 */
@ServerEndpoint("/gameconnect")
public class ConnectionHandler {

    public static Gson gson;

    public static synchronized Gson gsonSingleton() {
        if (gson == null) {
            gson = new GsonBuilder().create();
        }
        return gson;
    }
    private static Random random;

    public static synchronized Random randomSingleton() {
        if (random == null) {
            random = new Random();
        }
        return random;
    }

    /**
     * Maps 5-digit grouping code to groups
     */
    private static HashMap<String, ClientGroup> openGroups = null;

    /**
     * Maps group ids to Group objects
     */
    protected static HashMap<String, ClientGroup> clientGroups = null;

    /**
     *
     */
    private static HashMap<String, Client> clients = null;

    /**
     *
     */
    private final int MAX_OPEN_CONNECTIONS = 100000;

    /**
     * we can treat this like a main() method
     */
    static {
        if (openGroups == null) {
            openGroups = new HashMap<>();
        }
        if (clientGroups == null) {
            clientGroups = new HashMap<>();
        }
        if (clients == null) {
            clients = new HashMap<>();
        }
        gson = new GsonBuilder().create();
    }

    /**
     * @OnOpen allows us to intercept the creation of a new session. The session
     * class allows us to send data to the user. In the method onOpen, we'll let
     * the user know that the handshake was successful.
     */
    @OnOpen
    public void onOpen(Session session) {
        println(session.getId() + " has opened a connection");
        try {
            session.getBasicRemote().sendText(gsonSingleton().toJson(new ClientIdMessage(session.getId()), ClientIdMessage.class));
        } catch (IOException ex) {
            ex.printStackTrace();
        }
    }

    /**
     * When a user sends a message to the server, this method will intercept the
     * message and allow us to react to it. For now the message is read as a
     * String.
     */
    @OnMessage
    public void onMessage(String messageJson, Session session) {
        long ns_start = System.nanoTime();
        long ms_start = System.currentTimeMillis();
        println("Message from " + session.getId() + ": " + messageJson);

        Message incomingMessage;
        try {
            incomingMessage = gson.fromJson(messageJson, DefaultMessage.class);
        } catch (IllegalArgumentException e) {
            e.printStackTrace();
            //incomingMessage = new Message(null, null, null, null);
            //this is pointless, will just comment out and return early
            return;
        }

        // Messages should always have a messageType and sourceType.
        if (incomingMessage.getSourceType() == null || incomingMessage.getMessageType() == null) {
            return;
        }

        OutgoingMessage response = null;
        SendStrategy sender = null;
        boolean sendGameList = false;
        boolean sent = false;

        //TODO:  Replace switch block with a design pattern.
        Client c = null;
        switch (incomingMessage.getMessageType()) {
            case MessageType.OPEN_NEW_GROUP:
                if (incomingMessage.getGroupId() == null
                        && incomingMessage.getSourceType().equals(SourceType.PC_CLIENT)) {

                    String groupingCode = Integer.toString(openGroups.size());

                    Tuple<Client, ClientGroup> clientClientGroupTuple = createOpenGroup(session, groupingCode);

                    Client client = clientClientGroupTuple.item0;
                    ClientGroup group = clientClientGroupTuple.item1;

                    clients.put(session.getId(), client);
                    sender = new ToClientSender(client);
                    response = new OutgoingMessage(group.getGroupID(), SourceType.BACKEND, MessageType.GROUP_CODE_RESPONSE,
                            new GroupingCodeMessageContent(groupingCode));

                } else {
                    // Message already had a groupId or Message is not from PC_Client
                }
                break;

            case MessageType.JOIN_GROUP:
                if (incomingMessage.getGroupId() == null
                        && incomingMessage.getSourceType().equals(SourceType.CONTROLLER) /*&& 
                        incommingMessage.getContent() != null*/) {
                    // get the grouping code from the message
                    GroupingCodeMessage incommingGroupCodeMessage = gson.fromJson(messageJson, GroupingCodeMessage.class);

                    GroupingCodeMessageContent content = incommingGroupCodeMessage.getContent();
                    String groupingCode = content.getGroupingCode();
                    // trim the zeroes

                    ClientGroup group = openGroups.get(groupingCode);

                    // find the open group in the hash map
                    // put the client into the group.
                    if (group != null) {
                        Client controllerClient;
                        if (getClient(session) == null) {
                            clients.put(session.getId(), controllerClient = new Client(ClientType.MOBILE, session, group));
                        } else {
                            controllerClient = getClient(session);
                        }

                        group.giveClient(controllerClient);
                        controllerClient.clientGrouping = group;

                        controllerClient.setName(content.getName());
                        controllerClient.setUUID(content.getUUID());
                        User u = null;
                        if ((u = DatabaseSupport.getSingleton().getByUUID(content.getUUID())) != null) {
                            //do something?
                        } else {
                            u = User.createUser(content.getName(), content.getUUID());
                        }
                        controllerClient.user = u;

                        //TODO:  Change message content
                        // respond whether or not that worked.
                        sender = new ToGroupSender(controllerClient);
                        response = new OutgoingMessage(group.getGroupID(), SourceType.BACKEND,
                                MessageType.JOIN_GROUP, new GroupingApprovedMessageContent(true, controllerClient.getClientID(), controllerClient.getName()));
                        sendGameList = true;
                    } else {
                        sender = new ToSessionSender(session);
                        response = new OutgoingMessage(null, SourceType.BACKEND, MessageType.ERROR, new ErrorMessageContent("Open Group did not exist"));
                    }

                }
                break;

            case MessageType.SET_NAME:
                SetNameMessage setNameMessage = gson.fromJson(messageJson, SetNameMessage.class);
                c = getClient(session);
                c.setName(setNameMessage.getContent().getName());

                break;

            case MessageType.DISCONNECT:
                c = getClient(session);
                if (c != null) {
                    if (c.getGroup() != null && c.getGroup().context != null) {
                c.getGroup().sendToAll(new SoftDisconnectMessage(c.getClientID(), c.getGroup().getGroupID()), SoftDisconnectMessage.class);
                        c.getGroup().context.onClose(c);
                    } else if (c.getGroup() != null && c.getGroup().context == null) {
                        c.getGroup().sendToAll(new SoftDisconnectMessage(c.getClientID(), c.getGroup().getGroupID()), SoftDisconnectMessage.class);
                        c.getGroup().disconnect(c);
                    }
                    c.disconnected = true;
                }
                sent = true;
                break;

            case MessageType.QUIT_GAME:
                c = getClient(session);
                if (c != null && c.getGroup() != null && c.getGroup().context != null) {
                    c.getGroup().sendToAll(messageJson);
                    c.getGroup().context.endContext();
                    sent = true;
                }
                break;

            case MessageType.SET_CONTEXT:
                SetContextMessage scm = gson.fromJson(messageJson, SetContextMessage.class);
                switch (scm.getContent().getContextName()) {
                    case "snake":
                        c = getClient(session);
                        if (c != null && c.getGroup() != null) {
                            c.getGroup().sendToAll("{ \"groupId\": " + c.getGroup().getGroupID() + ", \"sourceType\":\"backend\", \"messageType\":\"context-selected\", \"content\": { \"contextName\":\"snake\" } }");
                            c.getGroup().context = new SnakeContext(c.getGroup());
                            sent = true;
                        } else {
                            sender = new ToSessionSender(session);
                            response = new OutgoingMessage(null, SourceType.BACKEND, MessageType.ERROR, new ErrorMessageContent("Null pointer error!"));
                        }
                        break;
                    case "chat":
                        c = getClient(session);
                        if (c != null && c.getGroup() != null) {
                            c.getGroup().sendToAll("{ \"groupId\": " + c.getGroup().getGroupID() + ", \"sourceType\":\"backend\", \"messageType\":\"context-selected\", \"content\": { \"contextName\":\"chat\" } }");
                            c.getGroup().context = new ChatContext(c.getGroup());
                            sent = true;
                        } else {
                            sender = new ToSessionSender(session);
                            response = new OutgoingMessage(null, SourceType.BACKEND, MessageType.ERROR, new ErrorMessageContent("Null pointer error!"));
                        }
                        break;
                    case "debug":
                        c = getClient(session);
                        if (c != null && c.getGroup() != null) {
                            c.getGroup().sendToAll("{ \"groupId\": " + c.getGroup().getGroupID() + ", \"sourceType\":\"backend\", \"messageType\":\"context-selected\", \"content\": { \"contextName\":\"debug\" } }");
                            c.getGroup().context = new DebugContext(c.getGroup());
                            sent = true;
                        } else {
                            sender = new ToSessionSender(session);
                            response = new OutgoingMessage(null, SourceType.BACKEND, MessageType.ERROR, new ErrorMessageContent("Null pointer error!"));
                        }
                        break;
                    case "debug-1":
                    case "debug-2":
                    case "debug-3":
                    case "debug-4":
                    case "debug-5":
                    case "debug-6":
                        c = getClient(session);
                        if (c != null && c.getGroup() != null) {
                            c.getGroup().sendToAll("{ \"groupId\": " + c.getGroup().getGroupID() + ", \"sourceType\":\"backend\", \"messageType\":\"context-selected\", \"content\": { \"contextName\":\"debug\" } }");
                            c.getGroup().context = new DebugAnyContext(c.getGroup(), Integer.parseInt(scm.getContent().getContextName().substring(6)));
                            sent = true;
                        } else {
                            sender = new ToSessionSender(session);
                            response = new OutgoingMessage(null, SourceType.BACKEND, MessageType.ERROR, new ErrorMessageContent("Null pointer error!"));
                        }
                        break;
                    case "settings":
                        c = getClient(session);
                        if (c != null) {
                            try {
                                //don't send to all
//                            c.user;

                                c.sendText("{\"groupId\":" + c.getGroup().getGroupID() + ",\"sourceType\":\"backend\",\"messageType\":\"context-selected\",\"content\": { \"contextName\":\"settings\" } }");
                            } catch (IOException ex) {
                                ex.printStackTrace();
                            }

                            sent = true;
                        } else {
                            sender = new ToSessionSender(session);
                            response = new OutgoingMessage(null, SourceType.BACKEND, MessageType.ERROR, new ErrorMessageContent("Null pointer error!"));
                        }
                        break;
                    default:
                        sender = new ToSessionSender(session);
                        response = new OutgoingMessage(null, SourceType.BACKEND, MessageType.ERROR, new ErrorMessageContent("Invalid context name!"));
                        break;
                }

                break;

            default:
                //just let the context try to handle it
                c = getClient(session);
                if (c != null && c.getGroup() != null && c.getGroup().context != null) {
                    sent |= c.getGroup().context.handleMessage(incomingMessage, messageJson, session);
                }
        }

        try {
            if (!sent) {
                if (response == null) {
                    sender = new ToSessionSender(session);
                    response = new OutgoingMessage(null, SourceType.BACKEND, MessageType.ERROR,
                            new ErrorMessageContent("Message not Recognized."));

                }
                response.send(gson, sender);
            }

            if (sendGameList) {
                session.getBasicRemote().sendText("{ \"sourceType\":\"backend\", \"messageType\": \"context-list\", \"content\": { \"games\": [\"debug\", \"snake\", \"chat\", \"settings\"] } }");
            }

        } catch (IOException ex) {
            ex.printStackTrace();
        }
        println("Time Elapsed: " + (System.nanoTime() - ns_start) + "ns | " + (System.currentTimeMillis() - ms_start) + "ms");
    }

    /**
     * The user closes the connection.
     *
     * Note: you can't send messages to the client from this method
     */
    @OnClose
    public void onClose(Session session) {
        println("Session " + session.getId() + " has ended");
        Client c = getClient(session);
        if (c == null) {
            return;
        }
        if (!c.disconnected) {
            if (c.clientType == ClientType.PC) {
                //nuke the group, since only one pc per group
                c.getGroup().disconnect(c);
            } else if (c.getGroup() != null && c.getGroup().context != null) {
                c.getGroup().sendToAll(new SoftDisconnectMessage(c.getClientID(), c.getGroup().getGroupID()), SoftDisconnectMessage.class);
                c.getGroup().context.onClose(c);
            } else if (c.getGroup() != null && c.getGroup().context == null) {
                c.getGroup().sendToAll(new SoftDisconnectMessage(c.getClientID(), c.getGroup().getGroupID()), SoftDisconnectMessage.class);
                c.getGroup().disconnect(c);
            }
            c.disconnected = true;
        }
        clients.remove(session.getId());
    }

    public static Client getClient(Session sesh) {
        if (sesh != null) {
            return clients.get(sesh.getId());
        }
        return null;
    }
    public static Client getClient(String sesh) {
        if (sesh != null) {
            return clients.get(sesh);
        }
        return null;
    }

    private static void println(String s) {
        System.out.println("[GameConnect]: " + s);
    }

    /**
     * Creates a new Group
     *
     * @param clientSession
     * @return
     */
    private Tuple<Client, ClientGroup> createOpenGroup(Session clientSession, String groupingCode) {

        if (openGroups.size() >= MAX_OPEN_CONNECTIONS) {
            throw new IllegalStateException("Max open connections reached.");
        }

        String groupId = Integer.toString(clientGroups.size());

        ClientGroup group = new ClientGroup(groupId);
        Client c = new Client(ClientType.PC, clientSession, group);
        group.giveClient(c);

        openGroups.put(groupingCode, group);
        clientGroups.put(group.getGroupID(), group);

        return new Tuple<Client, ClientGroup>(c, group);
    }

    private class Tuple<S, T> {

        protected S item0;
        protected T item1;

        protected Tuple(S item0, T item1) {
            this.item0 = item0;
            this.item1 = item1;
        }
    }
}
