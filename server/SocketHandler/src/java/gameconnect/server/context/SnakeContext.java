package gameconnect.server.context;

import gameconnect.server.Client;
import gameconnect.server.ClientGroup;
import gameconnect.server.ConnectionHandler;
import static gameconnect.server.ConnectionHandler.gson;
import gameconnect.server.MessageType;
import gameconnect.server.database.DatabaseSupport;
import gameconnect.server.database.Score;
import gameconnect.server.io.MessageTypes.GroupingCodeMessage;
import gameconnect.server.io.MessageTypes.Message;
import gameconnect.server.io.MessageTypes.ScoreMessage;
import javax.websocket.Session;

/**
 *
 * @author davidboschwitz
 */
public class SnakeContext extends Context {

    public SnakeContext(ClientGroup group) {
        super(group);
        group.sendToAll("{ \"sourceType\":\"backend\", \"messageType\": \"game-mode\", \"content\": { \"gameMode\": 3 } }");
        //no limits on number of group members for this context
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
            case MessageType.SCORE:
                ScoreMessage scoreMessage = gson.fromJson(msgText, ScoreMessage.class);
                Score score = new Score();
                score.gameid = getContextID();
                score.uid = ConnectionHandler.getClient(scoreMessage.getContent().clientId).getUser().uid;
                score.score = scoreMessage.getContent().score;
                score.scoreid = -1;
                DatabaseSupport.getSingleton().addScore(score);
                rtn = true;
                break;
        }
        return rtn;
    }
    
    @Override
    public void onClose(Client c){
        group.disconnect(c);
    }

    @Override
    public void endContext() {
        group.context = null;
        //do nothing for now
    }
    
    @Override
    public int getContextID(){
        return 1;
    }

}
