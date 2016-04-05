package gameconnect.server.context;

import gameconnect.server.ClientGroup;
import gameconnect.server.io.MessageTypes.Message;
import javax.websocket.Session;

/**
 * A holder class for all contexts.
 *
 * @author davidboschwitz
 */
public abstract class Context {

    protected ClientGroup group;

    public Context(ClientGroup group) {
        this.group = group;
    }

    /**
     * return true if message is properly handled
     *
     * @param incomingMessage
     * @param msgText
     * @param session
     * @return
     */
    public abstract boolean handleMessage(Message incomingMessage, String msgText, Session session);

    /**
     * Handles disconnecting websockets.
     *
     * @param s session that is disconnecting
     */
    public abstract void onClose(Session s);

    /**
     * Currently unused, clients must disconnect and start a new group to change
     * contexts.
     */
    public abstract void endContext();
}
