package gameconnect.server.io.MessageContentTypes;

/**
 *
 * @author davidboschwitz
 */
public class SetNameMessageContent extends MessageContent {
    
    private String name;
    
    public SetNameMessageContent(String name){
        this.name = name;
    }
    
    public String getName(){
        return this.name;
    }
}
