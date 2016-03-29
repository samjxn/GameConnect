package gameconnect.server.io.MessageContentTypes;

/**
 * A class structuring the message content for a response to a pairing code
 * request
 * 
 * @author Sam Jackson
 */
public class GroupingCodeMessageContent extends MessageContent {
    
    private String groupingCode;
    
    public GroupingCodeMessageContent(String groupingCode){
        this.groupingCode = groupingCode;
    }
    
    public String getGroupingCode(){
        return this.groupingCode;
    }
}
