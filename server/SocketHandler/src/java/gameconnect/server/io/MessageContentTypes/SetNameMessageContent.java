package gameconnect.server.io.MessageContentTypes;

/**
 *
 * @author davidboschwitz
 */
public class SetNameMessageContent extends MessageContent {

    private String name;

    /**
     * We get names from the join group message now.
     */
    @Deprecated
    public SetNameMessageContent(String name) {
        this.name = name;
    }

    public String getName() {
        return this.name;
    }
}
