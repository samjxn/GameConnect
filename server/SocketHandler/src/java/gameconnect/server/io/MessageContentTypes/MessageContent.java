package gameconnect.server.io.MessageContentTypes;

/*  TODO:  This is a stub.  Redo this entirely.
 *         Different messages will require different message contents
 *         Gson doesn't allow for creating objects with generic properties,
 *         so we may need to extend the MessageClass to have different kinds of
 *         message contents.
 */

/**
 * An abstract class to be the super of all message contents.
 * Must be extended
 * @author Sam Jackson
 * @author David Boschwitz
 */
public class MessageContent {
    /**
     * for use by gson library only.
     */
    @Deprecated
    public MessageContent(){}
}
