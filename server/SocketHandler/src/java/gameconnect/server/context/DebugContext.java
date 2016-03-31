package gameconnect.server.context;

import gameconnect.server.Client;
import gameconnect.server.ClientGroup;
import gameconnect.server.io.MessageTypes.Message;
import java.util.ArrayList;
import javax.websocket.Session;

/**
 *
 * @author davidboschwitz
 */
public class DebugContext extends Context {

    public DebugContext(ClientGroup group) {
        super(group);

        //put limits on number of types of clients
        int numMobileAllowed = 1;
        int numPCAllowed = 1;
        int numMobile = 0;
        int numPC = 0;
        ArrayList<Client> toRemove = new ArrayList<>();
        for (Client c : group.clients) {
            switch (c.getType()) {
                case PC:
                    if (numPC < numPCAllowed) {
                        numPC++;
                        //do nothing
                    } else {
                        toRemove.add(c);
                    }
                    break;

                case MOBILE:
                    if (numMobile < numMobileAllowed) {
                        numMobile++;
                        //do nothing
                    } else {
                        toRemove.add(c);
                    }
                    break;

                default:
                    toRemove.add(c);
                    break;

            }
        }
        for (Client c : toRemove) {
            group.clients.remove(c);
        }
        toRemove.clear();
    }

    @Override
    public boolean handleMessage(Message messageJson, String msgText, Session session) {
        throw new UnsupportedOperationException("Not supported yet."); 
    }

    @Override
    public void endContext() {
        group.context = null;
        throw new UnsupportedOperationException("Not supported yet.");
        //send new disconnect message
    }

}
