package gameconnect.server;

import gameconnect.server.context.Context;
import gameconnect.server.io.MessageTypes.DisconnectMessage;
import gameconnect.server.io.MessageTypes.Message;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import javax.websocket.Session;
import java.lang.reflect.Type;

/**
 *
 * @author davidboschwitz
 */
public class ClientGroup {

    /**
     * List of all clients within this group
     */
    public List<Client> clients;

    /**
     * The group identifier
     */
    private String groupId;
    
    public String getGroupID(){
        return groupId;
    }

    public Context context = null;

    /**
     * 
     * @param id 
     */
    @Deprecated
    protected ClientGroup(String id) {
        this.groupId = id;
        this.clients = new ArrayList<>();
    }

    /**
     * 
     * @param openingClient
     * @param groupId 
     */
    protected ClientGroup(Client openingClient, String groupId) {
        if (openingClient == null || groupId == null) {
            throw new NullPointerException();
        }

        this.groupId = groupId;
        this.clients = new ArrayList<>();
        clients.add(openingClient);
    }

    /**
     * 
     * @param c 
     */
    protected void giveClient(Client c) {
        if (c == null) {
            throw new NullPointerException();
        }

        if (!this.clients.contains(c)) {
            this.clients.add(c);
        }
    }

    /**
     * 
     * @param msg 
     */
    public void sendToAll(String msg) {
        if (msg == null) {
            throw new NullPointerException();
        }

        for (Client c : this.clients) {
            try {
                c.sendText(msg);
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }
    
    /**
     * 
     * @param m
     * @param t 
     */
    public void sendToAll(Message m, Type t){
        if (m == null || t == null) {
            throw new NullPointerException();
        }
        if(false){
            //implement checking to ensure type t is a valid subclass of Message
        }

        for (Client c : this.clients) {
            try {
                c.sendMessage(m, t);
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }

    /**
     * Send message to everyone in group, except the sender
     *
     * @param msg
     * @param s
     */
    public void sendToAll(String msg, Session s) {
        if (msg == null || s == null) {
            throw new NullPointerException();
        }

        for (Client c : this.clients) {
            if (c.session.equals(s)) {
                continue;
            }
            try {
                c.sendText(msg);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }

    /**
     * Send message to everyone in group, except the sender
     *
     * @param m
     * @param s
     */
    public void sendToAll(Message m, Type t, Session s) {
        if (m == null || s == null || t == null) {
            throw new NullPointerException();
        }

        for (Client c : this.clients) {
            if (c.session.equals(s)) {
                continue;
            }
            try {
                c.sendMessage(m, t);
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }
    
    public void disconnect(Client c) {
        clients.remove(c);
        sendToAll(new DisconnectMessage(groupId), DisconnectMessage.class);
        clients.clear();
    }
    
    public boolean inContext(){
        return context != null;
    }
}
