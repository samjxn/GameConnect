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

    public abstract void handleMessage(Message incomingMessage, Session session);

    public abstract void endContext();
}
