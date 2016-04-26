package gameconnect.server.io.MessageContentTypes;

/**
 *
 * @author Sam Jackson
 * @author David Boschwitz
 */
public class GroupingApprovedMessageContent extends MessageContent {
    
    private boolean groupingApproved;
    private String clientId;
    private String name;
    
    public GroupingApprovedMessageContent(boolean groupingApproved, String clientId, String name){
        this.groupingApproved = groupingApproved;
        this.clientId = clientId;
        this.name = name;
    }
    
    public boolean getGroupingApproved(){
        return this.groupingApproved;
    }
    
    public String getClientId() {
        return this.clientId;
    }
    
    public String getName() {
        return this.name;
    }
    
}
