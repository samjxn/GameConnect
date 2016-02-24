package gameconnect.server;

import gameconnect.server.MessageType;
import gameconnect.server.SourceType;
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
        
        Message incommingMessage;
        try {
            incommingMessage = gson.fromJson(messageJson, Message.class);
        } catch (Exception e) {
            incommingMessage = new Message(null, null, null, null);
        }
        
        // Messages should always have a messageType and sourceType.
        if(incommingMessage.getSourceType() == null || 
                incommingMessage.getMessageType() == null) {
            return;
        }
        
        OutgoingMessage response = null;
        SendStrategy sender = null;
        
        //TODO:  Replace switch block with a design pattern.
        switch(incommingMessage.getMessageType()){
            case MessageType.OPEN_NEW_GROUP:
                if (incommingMessage.getGroupId() == null &&
                        incommingMessage.getSourceType().equals(SourceType.PC_CLIENT)) {
                
                String pairingCode = Integer.toString(this.openGroups.size());
               
                Tuple<Client, ClientGroup> clientClientGroupTuple = createOpenGroup(session, pairingCode);
                
                Client client = clientClientGroupTuple.item0;
                ClientGroup group = clientClientGroupTuple.item1;
                
                sender = new ToClientSender(client);
                response = new OutgoingMessage(group.groupId, SourceType.BACKEND, MessageType.PAIR_CODE_RESPONSE, 
                        new PairingCodeMessageContent(pairingCode), sender);
                
                } else{
              // Message already had a groupId or Message is not from PC_Client
                }    
                break;
                
            case MessageType.JOIN_GROUP:
                if (incommingMessage.getGroupId() == null && 
                        incommingMessage.getSourceType().equals(SourceType.CONTROLLER) && 
                        incommingMessage.getContent() != null){
                    // get the pairing code from the message
                    PairingCodeMessageContent content = (PairingCodeMessageContent)incommingMessage.getContent();
                    String pairCode = content.getPairingCode();
                    // trim the zeroes

                    ClientGroup group = this.openGroups.get(pairCode);

                    // find the open group in the hash map
                    // put the client into the group.
                    if (group != null){
                        Client controllerClient = new Client(ClientType.MOBILE, session, group);
                        String clientId = ""; // TODO:  Remove when clients have ids
                        
                        group.giveClient(controllerClient);
                        
                        //TODO:  Change message content
                        // respond whether or not that worked.
                        sender = new ToGroupSender(controllerClient);
                        response = new OutgoingMessage(group.groupId, SourceType.BACKEND, 
                                MessageType.JOIN_GROUP, new GroupingApprovedMessageContent(true, clientId), sender);
                    
                    } else {
                        sender = new ToSessionSender(session);
                        response = new OutgoingMessage(null, SourceType.BACKEND, MessageType.ERROR, new ErrorMessageContent("Open Group did not exist"), sender);
                    }
                    
                }
                break;
                
            
        }
        
        try {
            
            if (response == null){
                sender = new ToSessionSender(session);
                response = new OutgoingMessage(null, SourceType.BACKEND, MessageType.ERROR, 
                        new ErrorMessageContent("Message not Recognized."), sender);
                
            }
            
            response.send();
            
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
        System.out.println("[GameConnect]: "+ s);
    }
    
    /**
     * Creates a new Group
     * @param clientSession
     * @return 
     */
    private Tuple<Client, ClientGroup> createOpenGroup(Session clientSession, String pairingCode) {
        
        if (this.openGroups.size() >= this.MAX_OPEN_CONNECTIONS) {
            throw new IllegalStateException("Max open connections reached.");
        }
        
        String groupId = Integer.toString(this.clientGroups.size());
        
        ClientGroup group = new ClientGroup(groupId);
        Client c = new Client(ClientType.PC, clientSession, group);
        group.giveClient(c);
        
        this.openGroups.put(pairingCode, group);
        this.clientGroups.put(group.groupId, group);
        
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
