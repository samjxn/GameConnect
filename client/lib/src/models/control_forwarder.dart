part of game_connect_client.src.models;

class ControlForwarder {

  List<IGCGame> listeners;

  ControlForwarder() {
    listeners = [];
  }

  registerListener(listener) {
    listeners.add(listener);
  }

  sendSnapshot(ControllerSnapshot snapshot) {
    listeners.forEach((listener){
       listener.onSnapshotReceived(snapshot);
    });
  }
}
