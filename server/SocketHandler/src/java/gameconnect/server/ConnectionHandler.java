package gameconnect.server;

import gameconnect.server.io.*;

import java.io.IOException;
import java.util.HashMap;
import javax.websocket.OnClose;
import javax.websocket.OnMessage;
import javax.websocket.OnOpen;
import javax.websocket.Session;
import javax.websocket.server.ServerEndpoint;


import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

/**
 *
 * @author davidboschwitz
 */
@ServerEndpoint("/gameconnect")
public class ConnectionHandler {
    
    private Gson gson;
    static Integer connectionCount = 0;
    static Integer groupCount = 0;
    
    /**
     * Maps 5-digit pairing code to pairing groups
     */
    private static HashMap<String, ClientGroup> openGroups;
    
    /**
     * Maps group ids to Group objects
     */
    protected static HashMap<String, ClientGroup> clientGroups;
    
    private final int MAX_OPEN_CONNECTIONS = 100000;
        
    public ConnectionHandler() {
        this.gson = new GsonBuilder().create();
        ConnectionHandler.openGroups = new HashMap<String, ClientGroup>();
        ConnectionHandler.clientGroups = new HashMap<String, ClientGroup>();
    }
    
    /**
     * @OnOpen allows us to intercept the creation of a new session.
     * The session class allows us to send data to the user.
     * In the method onOpen, we'll let the user know that the handshake was 
     * successful.
     */
    @OnOpen
    public void onOpen(Session session){
        println(session.getId() + " has opened a connection"); 
        try {
            session.getBasicRemote().sendText("Connection Established!");
        } catch (IOException ex) {
            ex.printStackTrace();
        }
    }
 
    /**
     * When a user sends a message to the server, this method will intercept the message
     * and allow us to react to it. For now the message is read as a String.
     */
    @OnMessage
    public void onMessage(String messageJson, Session session){
        
        /**
         * TODO:
         *  - Message has no groupId and is from PC Client:
         *   - Create new group, add the PC client
         *   - Create a pairing code, map the pairing code to the group
         *
         *  - Message has no groupID and is from Controller:
         *   - Find group associated with pairing code, add Controller
         * 
         *  - Message has a groupID:
         *   - Send message to everyone in the group
         *   - Do not echo the message to the sender
         */
        
        
        println("Message from " + session.getId() + ": " + messageJson);
        //TODO: Parse Message
        
        Message message;
        try {
            message = gson.fromJson(messageJson, Message.class);
        } catch (Exception e) {
            message = new Message(null, null, null, null);
        }
        
        try {
            if (message.getGroupId() == null && 
                    message.getSourceType()!= null && message.getSourceType().equals("pc-client")) {

                ClientGroup group = new ClientGroup();
                Client client = new Client(ClientType.PC, session, group);

                group.giveClient(client);
                group.groupId = ConnectionHandler.groupCount.toString();

                String pairingCode = ConnectionHandler.connectionCount.toString();
                ConnectionHandler.openGroups.put(pairingCode, group);



                Message m = new Message(group.groupId, "backend", "pair-code-response", 
                        new PairingCodeRequestResponseContent(pairingCode));

                session.getBasicRemote().sendText(gson.toJson(m, Message.class));
                
                ConnectionHandler.connectionCount++;
                ConnectionHandler.groupCount++;
            } else {
                session.getBasicRemote().sendText("Message not recognized");
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
    public void onClose(Session session){
        println("Session " +session.getId()+" has ended");
    }
    
    protected Client getClient(Session sesh){
        //TODO: Search hashmap clients to find client
        return null;
    }
    
    private static void println(String s){
        System.out.println("[EchoSocket]: "+ s);
    }
    
    private void incrementConnectionCount() {
        if (openGroups.size() >= MAX_OPEN_CONNECTIONS) {
            throw new IllegalStateException("Max number of open connections reached.");
        }
        this.connectionCount = (connectionCount + 1) % MAX_OPEN_CONNECTIONS;
    }
}
