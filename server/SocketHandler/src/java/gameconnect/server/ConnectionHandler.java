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
import gameconnect.server.io.MessageContentTypes.ErrorMessageContent;
import gameconnect.server.io.MessageContentTypes.GroupingApprovedMessageContent;
import gameconnect.server.io.MessageContentTypes.GroupingCodeMessageContent;
import gameconnect.server.io.MessageTypes.GroupingCodeMessage;
import gameconnect.server.io.MessageTypes.Message;
import gameconnect.server.io.MessageTypes.OutgoingMessage;
import gameconnect.server.io.SendStrategies.SendStrategy;
import gameconnect.server.io.SendStrategies.ToClientSender;
import gameconnect.server.io.SendStrategies.ToGroupSender;
import gameconnect.server.io.SendStrategies.ToSessionSender;

/**
 *
 * @author davidboschwitz
 */
@ServerEndpoint("/gameconnect")
public class ConnectionHandler {
    
    private Gson gson;
    
    /**
     * Maps 5-digit grouping code to groups
     */
    private static HashMap<String, ClientGroup> openGroups = null;
    
    /**
     * Maps group ids to Group objects
     */
    protected static HashMap<String, ClientGroup> clientGroups = null;
    
    private final int MAX_OPEN_CONNECTIONS = 100000;
        
    public ConnectionHandler() {
        this.gson = new GsonBuilder().create();
        
        if (openGroups == null) {
            ConnectionHandler.openGroups = new HashMap<String, ClientGroup>();
        }
        if (clientGroups == null) {
            ConnectionHandler.clientGroups = new HashMap<String, ClientGroup>();
        }
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
        println("Message from " + session.getId() + ": " + messageJson);

        Message incommingMessage;
        try {
            incommingMessage = gson.fromJson(messageJson, Message.class);
        } catch (IllegalArgumentException e) {
            e.printStackTrace();
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
                
                String groupingCode = Integer.toString(this.openGroups.size());
               
                Tuple<Client, ClientGroup> clientClientGroupTuple = createOpenGroup(session, groupingCode);
                
                Client client = clientClientGroupTuple.item0;
                ClientGroup group = clientClientGroupTuple.item1;
                
                sender = new ToClientSender(client);
                response = new OutgoingMessage(group.groupId, SourceType.BACKEND, MessageType.GROUP_CODE_RESPONSE, 
                        new GroupingCodeMessageContent(groupingCode));
                
                } else{
              // Message already had a groupId or Message is not from PC_Client
                }    
                break;
                
            case MessageType.JOIN_GROUP:
                if (incommingMessage.getGroupId() == null && 
                        incommingMessage.getSourceType().equals(SourceType.CONTROLLER) /*&& 
                        incommingMessage.getContent() != null*/){
                    // get the grouping code from the message
                    GroupingCodeMessage incommingGroupCodeMessage = gson.fromJson(messageJson, GroupingCodeMessage.class);
                    
                    GroupingCodeMessageContent content = incommingGroupCodeMessage.getContent();
                    String groupingCode = content.getGroupingCode();
                    // trim the zeroes

                    ClientGroup group = this.openGroups.get(groupingCode);
                    
                    
                    // find the open group in the hash map
                    // put the client into the group.
                    if (group != null){
                        Client controllerClient = new Client(ClientType.MOBILE, session, group);
                        String clientId = ""; // TODO:  Remove when clients have ids
                        
                        group.giveClient(controllerClient);
                        
                        //TODO:  Change message content
                        // respond whether or not that worked.
                        sender = new ToClientSender(controllerClient);
                        response = new OutgoingMessage(group.groupId, SourceType.BACKEND, 
                                MessageType.JOIN_GROUP, new GroupingApprovedMessageContent(true, clientId));
                    
                    } else {
                        sender = new ToSessionSender(session);
                        response = new OutgoingMessage(null, SourceType.BACKEND, MessageType.ERROR, new ErrorMessageContent("Open Group did not exist"));
                    }
                    
                }
                break;
                
            
        }
        
        try {
            
            if (response == null){
                sender = new ToSessionSender(session);
                response = new OutgoingMessage(null, SourceType.BACKEND, MessageType.ERROR, 
                        new ErrorMessageContent("Message not Recognized."));
                
            }
            
            response.send(gson, sender);
            
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
    private Tuple<Client, ClientGroup> createOpenGroup(Session clientSession, String groupingCode) {
        
        if (this.openGroups.size() >= this.MAX_OPEN_CONNECTIONS) {
            throw new IllegalStateException("Max open connections reached.");
        }
        
        String groupId = Integer.toString(this.clientGroups.size());
        
        ClientGroup group = new ClientGroup(groupId);
        Client c = new Client(ClientType.PC, clientSession, group);
        group.giveClient(c);
        
        this.openGroups.put(groupingCode, group);
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
