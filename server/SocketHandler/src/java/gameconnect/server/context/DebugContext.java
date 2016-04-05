package gameconnect.server.context;

import gameconnect.server.Client;
import gameconnect.server.ClientGroup;
import gameconnect.server.MessageType;
import gameconnect.server.io.MessageTypes.Message;
import java.util.ArrayList;
import javax.websocket.Session;

/**
 *
 * @author davidboschwitz
 */
public class DebugContext extends Context {

    public DebugContext(ClientGroup group) {
        super(group);
        group.sendToAll("{ \"sourceType\":\"backend\", \"messageType\": \"game-mode\", \"content\": { \"gameMode\": 3 } }");

//        put limits on number of types of clients
//        don't implement for this right now.
//        int numMobileAllowed = 1;
//        int numPCAllowed = 1;
//        int numMobile = 0;
//        int numPC = 0;
//        ArrayList<Client> toRemove = new ArrayList<>();
//        for (Client c : group.clients) {
//            switch (c.getType()) {
//                case PC:
//                    if (numPC < numPCAllowed) {
//                        numPC++;
//                        //do nothing
//                    } else {
//                        toRemove.add(c);
//                    }
//                    break;
//
//                case MOBILE:
//                    if (numMobile < numMobileAllowed) {
//                        numMobile++;
//                        //do nothing
//                    } else {
//                        toRemove.add(c);
//                    }
//                    break;
//
//                default:
//                    toRemove.add(c);
//                    break;
//
//            }
//        }
//        for (Client c : toRemove) {
//            group.clients.remove(c);
//        }
//        toRemove.clear();
    }

    @Override
    public boolean handleMessage(Message incomingMessage, String msgText, Session session) {
        boolean rtn = false;
        switch (incomingMessage.getMessageType()) {
            case MessageType.CONTROLLER_SNAPSHOT:
                //just send it off as is
                group.sendToAll(msgText, session);
                rtn = true;
                break;
        }
        return rtn;
    }

    @Override
    public void onClose(Session s) {

    }

    @Override
    public void endContext() {
        group.context = null;
        throw new UnsupportedOperationException("Not supported yet.");
        //send new disconnect message
    }

}
