package gameconnect.server;

/**
 *
 * @author samjackson
 * @author davidboschwitz
 */
public final class MessageType {
    public final static String ERROR = "error";
    public final static String DISCONNECT = "disconnect";
    public final static String SOFT_DISCONNECT = "soft-disconnect";
    public final static String OPEN_NEW_GROUP = "open-new-group";
    public final static String JOIN_GROUP = "join-group";
    public final static String GROUP_CODE_RESPONSE = "group-code-response";
    public final static String CHAT_MESSAGE = "chat-msg";
    public final static String SET_CONTEXT = "set-context";
    public final static String SET_CONTROLLER_COLOR = "set-color";
    public final static String CONTROLLER_SNAPSHOT = "controller-snapshot";
    public final static String SET_NAME = "set-name";
    public final static String QUIT_GAME = "quit-game";
    public final static String SCORE = "score";
}
