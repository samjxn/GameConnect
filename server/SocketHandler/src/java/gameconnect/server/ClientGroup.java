package gameconnect.server;

import gameconnect.server.context.Context;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import javax.websocket.Session;

/**
 *
 * @author davidboschwitz
 */
public class ClientGroup {

    private static Integer clientGroupCount = 0;


    /**
     * List of all clients within this group
     */
    List<Client> clients;

    /**
     * The group identifier
     */
    String groupId;

    Context context = null;

    ClientGroup() {
        ClientGroup.clientGroupCount++;

        this.groupId = ClientGroup.clientGroupCount.toString();
        this.clients = new ArrayList<>();
    }

    void giveClient(Client c) {
        if (c == null) {
            throw new NullPointerException();
        }

        if (!this.clients.contains(c)) {
            this.clients.add(c);
        }
    }

    public void sendToAll(String msg) {
        if (msg == null) {
            throw new NullPointerException();
        }
        
        for (Client c : this.clients) {
            try {
                c.session.getBasicRemote().sendText(msg);
            } catch (IOException e) {
                e.printStackTrace();
            } catch (IllegalStateException e) {
                // This is a temporary fix for not removing closed sessions.
                // TODO:  REMOVE CLOSED SESSIONS
            }
        }
    }
    /**
     * Send message to everyone in group, except the sender
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
                c.session.getBasicRemote().sendText(msg);
            } catch (IOException e) {
                e.printStackTrace();
            }  catch (IllegalStateException e) {
                // This is a temporary fix for not removing closed sessions.
                // TODO:  REMOVE CLOSED SESSIONS
            }
        }
    }
}
