package gameconnect.server.io.MessageTypes;

import gameconnect.server.MessageType;
import gameconnect.server.database.Score;
import gameconnect.server.io.MessageContentTypes.ScoreMessageContent;

/**
 *
 * @author davidboschwitz
 */
public class ScoreMessage extends Message {

    ScoreMessageContent content;

    public ScoreMessage(String groupId, String sourceType, ScoreMessageContent content) {
        super(groupId, sourceType, MessageType.SCORE);
        this.content = content;
    }

    @Override
    public ScoreMessageContent getContent() {
        return content;
    }
}
