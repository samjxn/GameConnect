/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package gameconnect.server.io.MessageContentTypes;

/**
 *
 * @author Sam Jackson
 */
public class GroupingApprovedMessageContent extends MessageContent {
    
    private boolean groupingApproved;
    private String clientId;
    
    public GroupingApprovedMessageContent(boolean groupingApproved, String clientId){
        this.groupingApproved = groupingApproved;
        this.clientId = clientId;
    }
    
    public boolean getGroupingApproved(){
        return this.groupingApproved;
    }
    
    public String getClientId() {
        return this.clientId;
    }
    
}
