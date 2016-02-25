/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package gameconnect.server.io.MessageTypes;

import gameconnect.server.io.MessageContentTypes.GroupingCodeMessageContent;

/**
 *
 * @author Sam Jackson
 */
public class GroupingCodeMessage extends Message {
    
    GroupingCodeMessageContent content;
    
    public GroupingCodeMessage(String groupId, String sourceType, String messageType, GroupingCodeMessageContent content) {
        super(groupId, sourceType, messageType);
        this.content = content;
    }
    
    public GroupingCodeMessageContent getContent(){
        return this.content;
    }
    
}
