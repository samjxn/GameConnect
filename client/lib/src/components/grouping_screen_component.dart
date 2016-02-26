part of game_connect_client.src.game_connect_client_component;

/**
 *
 */

var pairingScreenComponent =
    react.registerComponent(() => new _PairingScreenComponent());

class _PairingScreenComponent extends flux
    .FluxComponent<GameConnectClientActions, GameConnectClientStores> {
  List<flux.Store> redrawOn() => [store.groupingScreenStore];

  String groupCode() => store.groupingScreenStore.groupCode;

  _makeCodeBox(String character, String className, int digit) {
    /**
     * Character: character to be displayed
     * className: class name for the div
     * Digit: which of the five digits is the number (for generating react keys)
     */
    return react.div({
      'className': '$className',
      'key': '$className-$digit'
    }, [
      react.div({
        'className': '$className-char-wrapper',
        'key': '$className-char-wrapper-$digit'
      }, character),
    ]);
  }

  _makeInstructionPanel() {
    var panel = react.div(
        {
          'className':'group-screen-instruction-panel',
          'key':'group-screen-instruction-panel'
        }, react.button({'onClick': (_) {
             actions.setCurrentComponent("levelSelectScreenComponent");
            }
          }, "Simulate grouping approved."));


    return panel;
  }

  render() {
    var code = groupCode();

    var digits = [];
    int digitMade = 0;

    code.split('').forEach((String number){
      digits.add(_makeCodeBox(number, 'number-box', digitMade));
      digits.add(_makeCodeBox('-', 'dash-box', digitMade));
      digitMade++;
    });
    digits.removeLast();

    var panel = _makeInstructionPanel();

    return react.div({
      'className': 'group-screen-content-container',
      'key': 'group-screen-content-container'
    }, [
      react.div({'className': 'code-display-wrapper'}, digits),
      react.div({'className': 'group-screen-instruction-wrapper'}, panel)
    ]);
  }
}
