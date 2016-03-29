package gameconnect.server.tests;

import gameconnect.server.ConnectionHandler;
import gameconnect.server.io.MessageContentTypes.ChatMessageContent;
import gameconnect.server.io.MessageTypes.ChatMessage;

/**
 * Random tests and stuff
 * @author davidboschwitz
 */
public class GSONTest {
    public static void main(String... args){
        ChatMessage c = new ChatMessage("idk", "idk2", new ChatMessageContent("david", "david says hi"));
        System.out.println(ConnectionHandler.gsonSingleton().toJson(c, ChatMessage.class));
    }
    
}
