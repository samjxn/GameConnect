/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package gameconnect.server;

import com.google.gson.*;
//import gameconnect.server.*;
//import gameconnect.server.io.*;
import gameconnect.server.io.MessageTypes.*;
import gameconnect.server.io.MessageContentTypes.*;

/**
 *
 * @author personal
 */
public class test {
    public static void main(String[] args) {
        
        Gson gson = new GsonBuilder().create();
        
        String m1Json = "{\"groupId\":null, \"sourceType\":\"controller\", \"messageType\":\"join-group\", \"content\":{\"groupingCode\":\"2\"}}";
        GroupingCodeMessage m1 = gson.fromJson(m1Json, GroupingCodeMessage.class);
        
        m1Json = gson.toJson(m1, GroupingCodeMessage.class);
        System.out.println(m1Json);
        
        OutgoingMessage m2 = new OutgoingMessage("2", "backend", "grouping-approved", new GroupingApprovedMessageContent(true, "2"));
        
        System.out.println(gson.toJson(m2, OutgoingMessage.class));
        
    }
}
