package gameconnect.server;

import java.io.IOException;
import java.util.HashMap;
import javax.websocket.OnClose;
import javax.websocket.OnMessage;
import javax.websocket.OnOpen;
import javax.websocket.Session;
import javax.websocket.server.ServerEndpoint;

/**
 *
 * @author davidboschwitz
 */
@ServerEndpoint("/gameconnect")
public class ConnectionHandler {
    protected static HashMap<String, ClientGroup> clientGroups;
    
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
            session.getBasicRemote().sendText("Connection Established");
        } catch (IOException ex) {
            ex.printStackTrace();
        }
    }
 
    /**
     * When a user sends a message to the server, this method will intercept the message
     * and allow us to react to it. For now the message is read as a String.
     */
    @OnMessage
    public void onMessage(String message, Session session){
        println("Message from " + session.getId() + ": " + message);
        //TODO: Parse Message
        
        Client messanger = getClient(session);
        //Do logic to process msg
        String msgtoall = "Probably some sort of JSON";
        messanger.myGroup.sendToAll(msgtoall);
        
//        try {
//            session.getBasicRemote().sendText(message);
//        } catch (IOException ex) {
//            ex.printStackTrace();
//        }
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
}
