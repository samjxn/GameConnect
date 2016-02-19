part of game_connect_client.src.game_connect_client_component;

/**
 *
 */

var pairingScreenComponent =
    react.registerComponent(() => new _PairingScreenComponent());

class _PairingScreenComponent extends flux
    .FluxComponent<GameConnectClientActions, GameConnectClientStores> {
  List<flux.Store> redrawOn() => [store.pairingScreenStore];

  String pairCode() => store.pairingScreenStore.pairCode?.code;

  _makeNumBox(String number, int digit) {
    /**
     * Number: number to be displayed
     * Digit: which of the five digits is the number (for generating react keys)
     */
    return react.div({
      'className': 'number-box',
      'key': 'number-box-$digit'
    }, [
      react.div({
        'className': 'number-wrapper',
        'key': 'number-wrapper-$digit'
      }, number),
    ]);
  }

  _makeDashBox(int digit) {
    return react.div({
      'className': 'dash-box',
      'key': 'dash-box-$digit'
    }, [
      react.div({
        'className': 'dash-wrapper',
        'key': 'number-wrapper-$digit'
      }, "-"),
    ]);
  }

  render() {
    var code = pairCode() ?? '00000';

    var digits = [];
    int digitMade = 0;

    code.split('').forEach((String number){
      digits.add(_makeNumBox(number, ++digitMade));
      digits.add(_makeDashBox(digitMade));
    });
    digits.removeLast();

    return react.div({
      'className': 'pair-screen-content-container',
      'key': 'pair-screen-content-container'
    }, [
      react.div({'className': 'code-display-wrapper'}, digits),
    ]);
  }
}
