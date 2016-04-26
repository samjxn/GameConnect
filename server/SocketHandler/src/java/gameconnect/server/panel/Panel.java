package gameconnect.server.panel;

import java.io.IOException;
import java.util.ArrayList;
import javax.websocket.OnClose;
import javax.websocket.OnMessage;
import javax.websocket.OnOpen;
import javax.websocket.Session;
import javax.websocket.server.ServerEndpoint;

/**
 * @ServerEndpoint gives the relative name for the end point This will be
 * accessed via ws://localhost:8080/EchoChamber/echo Where "localhost" is the
 * address of the host, "EchoChamber" is the name of the package and "echo" is
 * the address to access this class from the server
 */
@ServerEndpoint("/panel")
public class Panel {

    public final static ArrayList<Session> sessions = new ArrayList<>();

    /**
     * @OnOpen allows us to intercept the creation of a new session. The session
     * class allows us to send data to the user. In the method onOpen, we'll let
     * the user know that the handshake was successful.
     */
    @OnOpen
    public void onOpen(Session session) {
        println(session.getId() + " has opened a connection");
        sessions.add(session);
        session.getAsyncRemote().sendText("Log Stream Opened.");
    }

    /**
     * When a user sends a message to the server, this method will intercept the
     * message and allow us to react to it. For now the message is read as a
     * String.
     */
    @OnMessage
    public void onMessage(String message, Session session) {
        //println("Message from " + session.getId() + ": " + message);
        session.getAsyncRemote().sendText("[Panel]: Sending messages to this is not supported.");
    }

    /**
     * The user closes the connection.
     *
     * Note: you can't send messages to the client from this method
     */
    @OnClose
    public void onClose(Session session) {
        println("Session " + session.getId() + " has ended");
        sessions.remove(session);
    }

    public static void log(String msg) {
        for (Session s : sessions) {
            s.getAsyncRemote().sendText(msg);
        }
    }

    private static void println(String s) {
        System.out.println("[Panel]: " + s);
    }
}
