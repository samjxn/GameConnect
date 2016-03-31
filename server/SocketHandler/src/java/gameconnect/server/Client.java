package gameconnect.server;

import gameconnect.server.io.MessageTypes.Message;
import javax.websocket.Session;
import java.lang.reflect.Type;

/**
 *
 * @author davidboschwitz
 * @author Sam Jackson
 */
public class Client {

    // TODO:  give client ids
    protected Session session;
    protected final ClientType clientType;
    protected ClientGroup clientGrouping;

    /**
     *
     * @param type
     * @param session
     * @param group
     */
    public Client(ClientType type, Session session, ClientGroup group) {
        this.clientType = type;
        this.session = session;
        this.clientGrouping = group;
    }

    /**
     * Sends plain-text to the client
     * @param msg String to send to the client
     * @throws java.io.IOException 
     */
    public void sendText(String msg) throws java.io.IOException {
        session.getBasicRemote().sendText(msg);
    }

    /**
     * Sends a Message object (w/ JSON) to the client
     * @param m Message object to send
     * @param t Type of message ([MyMessage.class])
     * @throws java.io.IOException 
     */
    public void sendMessage(Message m, Type t) throws java.io.IOException {
        sendText(ConnectionHandler.gsonSingleton().toJson(m, t));
    }

    public ClientGroup getGroup() {
        return clientGrouping;
    }

    public ClientType getType() {
        return clientType;
    }

    public void disconnect() {
        //TODO: this
    }

}
