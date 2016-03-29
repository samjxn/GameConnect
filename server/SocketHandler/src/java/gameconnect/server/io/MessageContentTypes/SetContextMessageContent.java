package gameconnect.server.io.MessageContentTypes;

/**
 *
 * @author davidboschwitz
 */
public class SetContextMessageContent extends MessageContent {
    
    private String contextName;
    
    public SetContextMessageContent(String contextName){
        this.contextName = contextName;
    }
    
    public String getContextName(){
        return this.contextName;
    }
}
