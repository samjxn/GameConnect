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

    /**
     * List of all clients within this group
     */
    List<Client> clients;

    /**
     * The group identifier
     */
    String groupId;

    Context context = null;

    ClientGroup(String id) {
        this.groupId = id;
        this.clients = new ArrayList<>();
    }

    ClientGroup(Client openingClient, String groupId) {
        if (openingClient == null || groupId == null) {
            throw new NullPointerException();
        }

        this.groupId = groupId;
        this.clients = new ArrayList<>();
        clients.add(openingClient);
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
                c.session.getBasicRemote().sendText(msg);
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }
}
