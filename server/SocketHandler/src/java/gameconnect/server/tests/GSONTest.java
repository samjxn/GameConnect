package gameconnect.server.tests;

import gameconnect.server.ConnectionHandler;
import gameconnect.server.io.MessageContentTypes.ChatMessageContent;
import gameconnect.server.io.MessageTypes.ChatMessage;
import gameconnect.server.io.MessageTypes.DisconnectMessage;
import java.util.ArrayList;

/**
 * Random tests and stuff
 * @author davidboschwitz
 */
public class GSONTest {
    public static void main(String... args){
        ChatMessage c = new ChatMessage("idk", "idk2", new ChatMessageContent("david says hi"));
        System.out.println(ConnectionHandler.gsonSingleton().toJson(c, ChatMessage.class));
        
        DisconnectMessage d = new DisconnectMessage("0");
        System.out.println(ConnectionHandler.gsonSingleton().toJson(d, DisconnectMessage.class));
        
        String testArray = "[\"123412341234\", \"14r1f1f\",\"ugh\"]";
        
        String[] arr = ConnectionHandler.gsonSingleton().fromJson(testArray, String[].class);
        System.out.println(arr.length);
        for(String s : arr){
            System.out.println(s);
        }
        
        long t1 = System.nanoTime();
        String s1 = "";
        int size = 10000;
        for(int i = size; i > 0; i--){
            s1 += " ";
        }
        System.out.println("t1: "+ (System.nanoTime() - t1));
        System.out.println(s1.length());
        long t2 = System.nanoTime();
        String s2 = "";
        for(int i = size; i > 0; i--){
            if(i > 10) {
                s2 += "          ";
                i -= 9;
                continue;
            }
            s2 += " ";
        }
        System.out.println("t2: "+ (System.nanoTime() - t2));
        System.out.println(s2.length());
        
    }
    
}
