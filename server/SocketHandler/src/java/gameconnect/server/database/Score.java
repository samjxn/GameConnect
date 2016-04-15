package gameconnect.server.database;

import gameconnect.server.io.MessageContentTypes.MessageContent;
import gameconnect.server.io.MessageTypes.Message;

/**
 *
 * @author davidboschwitz
 */
public class Score {
    
    public int scoreid;
    public long uid;
    public int gameid;
    public int score;
    
    public Score(){}
}
