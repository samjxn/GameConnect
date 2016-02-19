package gameconnect.server.tests;

import java.io.IOException;
import java.util.ArrayList;

import javax.websocket.OnClose;
import javax.websocket.OnMessage;
import javax.websocket.OnOpen;
import javax.websocket.Session;
import javax.websocket.server.ServerEndpoint;

/**
 *
 * @author davidboschwitz
 */
@ServerEndpoint("/test/chat")
public class ChatSocket {

    private static ArrayList<Session> sessions = new ArrayList<>();

    @OnOpen
    public void onOpen(Session session) {
        System.out.println(session.getId() + " has opened a connection");
        try {
            sessions.add(session);
            for (Session s : sessions) {
                s.getBasicRemote().sendText(session.getId() + " Joined the chat.");
            }
        } catch (IOException ex) {
            ex.printStackTrace();
        }
    }

    @OnMessage
    public void onMessage(String message, Session session) {
        System.out.println("Message from " + session.getId() + ": " + message);
        for (Session s : sessions) {
            try {
                s.getBasicRemote().sendText(session.getId() + ": " + message);

            } catch (Exception ex) {
                onClose(s);
                ex.printStackTrace();
            }
        }
    }

    @OnClose
    public void onClose(Session session) {
        System.out.println("Session " + session.getId() + " has ended");
        sessions.remove(session);
    }
}
