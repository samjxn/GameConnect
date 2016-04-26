package gameconnect.server.io.MessageContentTypes;

/**
 * A class structuring the message content for a response to a pairing code
 * request
 * 
 * @author Sam Jackson
 */
public class GroupingCodeMessageContent extends MessageContent {
    
    private String groupingCode;
    private String name;
    private String uuid;
    
    public GroupingCodeMessageContent(String groupingCode, String name){
        this.groupingCode = groupingCode;
        this.name = name;
    }
    
    public GroupingCodeMessageContent(String groupingCode){
        this(groupingCode, null);
    }
    
    public String getGroupingCode(){
        return this.groupingCode;
    }
    
    public String getName(){
        return name;
    }
    
    public String getUUID(){
        return uuid;
    }
}
