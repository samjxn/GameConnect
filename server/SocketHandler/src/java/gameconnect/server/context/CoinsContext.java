package gameconnect.server.context;

import gameconnect.server.Client;
import gameconnect.server.ClientGroup;
import gameconnect.server.MessageType;
import gameconnect.server.io.MessageTypes.Message;
import javax.websocket.Session;

/**
 *
 * @author davidboschwitz
 */
public class CoinsContext extends Context {

    public CoinsContext(ClientGroup group) {
        super(group);
        group.sendToAll("{ \"sourceType\":\"backend\", \"messageType\": \"game-mode\", \"content\": { \"gameMode\": 3 } }");
//        group.sendToAll("{ \"sourceType\":\"backend\", \"messageType\": \"set-color\", \"content\": { \"color\": \"red\", \"clientId\":\"" + group.clients.get(1).getClientID() + "\" } }");
//        if (group.clients.size() > 2) {
//            group.sendToAll("{ \"sourceType\":\"backend\", \"messageType\": \"set-color\", \"content\": { \"color\": \"blue\", \"clientId\":\"" + group.clients.get(2).getClientID() + "\" } }");
//        }
//        if (group.clients.size() > 3) {
//            group.sendToAll("{ \"sourceType\":\"backend\", \"messageType\": \"set-color\", \"content\": { \"color\": \"yellow\", \"clientId\":\"" + group.clients.get(3).getClientID() + "\" } }");
//        }
//        if (group.clients.size() > 4) {
//            group.sendToAll("{ \"sourceType\":\"backend\", \"messageType\": \"set-color\", \"content\": { \"color\": \"green\", \"clientId\":\"" + group.clients.get(4).getClientID() + "\" } }");
//        }
    }

    @Override
    public boolean handleMessage(Message inmsg, String msgText, Session session) {
        boolean rtn = false;
        switch (inmsg.getMessageType()) {
            case MessageType.CONTROLLER_SNAPSHOT:
                //inject clientId until we figure out why it doesn't send.
                if (!msgText.contains("\"clientId\":")) {
                    msgText = "{\"clientId\":\"" + session.getId() + "\"," + msgText.substring(1);
                }
                group.sendToAll(msgText, session);
                rtn = true;
                break;
            case MessageType.SET_CONTROLLER_COLOR:
                //just send it off as is
                group.sendToAll(msgText, session);
                rtn = true;
                break;
        }
        return rtn;
    }

    @Override
    public void onClose(Client c) {
        group.disconnect(c);
    }

    @Override
    public void endContext() {
        group.context = null;
        //do nothing for now
    }

    @Override
    public int getScoreContextID() {
        return 3;
    }

}
