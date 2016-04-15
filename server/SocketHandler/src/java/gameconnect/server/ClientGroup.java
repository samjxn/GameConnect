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
     * List of all clients within this group.
     */
    public List<Client> clients;

    /**
     * The group identifier.
     */
    private String groupId;
    
    /**
     * The current context for this group, null if not in a context.
     */
    public Context context = null;
    
    /**
     * True before all clients disconnect.
     */
    public boolean active = true;

    /**
     * 
     * @param id 
     */
    protected ClientGroup(String id) {
        this.groupId = id;
        this.clients = new ArrayList<>();
    }

    /**
     * 
     * @param openingClient
     * @param groupId 
     */
    @Deprecated
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

        if (!clients.contains(c)) {
            clients.add(c);
        }
    }

    /**
     * 
     * @param msg 
     */
    public void sendToAll(String msg) {
        if (msg == null || msg.isEmpty()) {
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
        if(false) {
            //TODO: implement checking to ensure type t is a valid subclass of Message
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
    
    /**
     * Disconnect the entire group starting with @param c
     * @param c the client disconnecting
     */
    public void disconnect(Client c) {
        clients.remove(c);
        sendToAll(new DisconnectMessage(groupId), DisconnectMessage.class);
        clients.clear();
        active = false;
    }
    /**
     * Disconnect without disconnecting the entire group.
     * @param c the client disconnecting
     */
    public void softDisconnect(Client c) {
        clients.remove(c);
        if(clients.isEmpty())
            active = false;
    }
    
    public String getGroupID(){
        return groupId;
    }
    
    public boolean inContext(){
        return context != null;
    }
}
