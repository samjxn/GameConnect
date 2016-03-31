package gameconnect.server;

import gameconnect.server.io.MessageTypes.*;
import gameconnect.server.io.SendStrategies.*;
import gameconnect.server.io.MessageContentTypes.*;
import gameconnect.server.MessageType;
import gameconnect.server.SourceType;

import java.io.IOException;
import java.util.HashMap;
import javax.websocket.OnClose;
import javax.websocket.OnMessage;
import javax.websocket.OnOpen;
import javax.websocket.Session;
import javax.websocket.server.ServerEndpoint;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import gameconnect.server.context.SnakeContext;
import gameconnect.server.io.MessageTypes.GroupingCodeMessage;

/**
 *
 * @author davidboschwitz
 */
@ServerEndpoint("/gameconnect")
public class ConnectionHandler {

    private static Gson gson;

    public static synchronized Gson gsonSingleton() {
        if (gson == null) {
            gson = new GsonBuilder().create();
        }
        return gson;
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
    protected static HashMap<Session, Client> clients = null;

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
            session.getBasicRemote().sendText("Connection Established!");
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
        if (incomingMessage.getSourceType() == null
                || incomingMessage.getMessageType() == null) {
            return;
        }

        OutgoingMessage response = null;
        SendStrategy sender = null;
        boolean sendGameList = false;
        boolean sent = false;

        //TODO:  Replace switch block with a design pattern.
        switch (incomingMessage.getMessageType()) {
            case MessageType.OPEN_NEW_GROUP:
                if (incomingMessage.getGroupId() == null
                        && incomingMessage.getSourceType().equals(SourceType.PC_CLIENT)) {

                    String groupingCode = Integer.toString(openGroups.size());

                    Tuple<Client, ClientGroup> clientClientGroupTuple = createOpenGroup(session, groupingCode);

                    Client client = clientClientGroupTuple.item0;
                    ClientGroup group = clientClientGroupTuple.item1;

                    clients.put(session, client);
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
                            clients.put(session, controllerClient = new Client(ClientType.MOBILE, session, group));
                        } else {
                            controllerClient = getClient(session);
                        }
                        String clientId = ""; // TODO:  Remove when clients have ids

                        group.giveClient(controllerClient);
                        controllerClient.clientGrouping = group;
                        //TODO:  Change message content
                        // respond whether or not that worked.
                        sender = new ToGroupSender(controllerClient);
                        response = new OutgoingMessage(group.getGroupID(), SourceType.BACKEND,
                                MessageType.JOIN_GROUP, new GroupingApprovedMessageContent(true, clientId));
                        sendGameList = true;
                    } else {
                        sender = new ToSessionSender(session);
                        response = new OutgoingMessage(null, SourceType.BACKEND, MessageType.ERROR, new ErrorMessageContent("Open Group did not exist"));
                    }

                }
                break;

            case MessageType.SET_CONTEXT:
                SetContextMessage scm = gson.fromJson(messageJson, SetContextMessage.class);
                switch (scm.getContent().getContextName()) {
                    case "snake":
                        if (getClient(session) != null && getClient(session).getGroup() != null) {
                            getClient(session).getGroup().sendToAll("{ \"groupId\": "+getClient(session).getGroup().getGroupID()+", \"sourceType\":\"backend\", \"messageType\":\"context-selected\", \"content\": { \"contextName\":\"snake\" } }");
                            getClient(session).getGroup().context = new SnakeContext(getClient(session).getGroup());
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
                if (getClient(session) != null && getClient(session).getGroup() != null && getClient(session).getGroup().context != null) {
                    sent |= getClient(session).getGroup().context.handleMessage(incomingMessage, messageJson, session);
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
                session.getBasicRemote().sendText("{ \"sourceType\":\"backend\", \"messageType\": \"context-list\", \"content\": { \"games\": [\"debug\", \"snake\",\"flappy\", \"etc\", \"etc\", \"etc\", \"etc\", \"etc\", \"etc\"] } }");
            }

        } catch (IOException ex) {
            ex.printStackTrace();
        }
    }

    /**
     * The user closes the connection.
     *
     * Note: you can't send messages to the client from this method
     */
    @OnClose
    public void onClose(Session session) {
        println("Session " + session.getId() + " has ended");
    }

    protected Client getClient(Session sesh) {
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
