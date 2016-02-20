(function () {

    /* ---------------------------------- Local Variables ---------------------------------- */
    var viewStack = new Array();
    var currentView;
    var webSocket;
    var watchID;

    /* --------------------------------- Device Ready -------------------------------- */
    document.addEventListener('deviceready', function () {
      document.addEventListener("backbutton", onBackKeyDown, false);
      renderHomeView();

      // Ensures only one connection is open at a time
      if(webSocket !== undefined && webSocket.readyState !== WebSocket.CLOSED){
        alert('WebSocket is already opened');
        return;
      }

      // Create a new instance of the websocket
      webSocket = new WebSocket("ws://proj-309-16.cs.iastate.edu:8080/SocketHandler/test/chat");

      // Binds functions to the listeners for the websocket.
      webSocket.onopen = function(event){
        if(event.data === undefined)
          alert('WebSocket is open now');
          return;
      };

      webSocket.onmessage = function(event){
        // parse the message
      };

      webSocket.onclose = function(event){
        // handle this
      };

    }, false);

    /* ---------------------------------- Local Functions ---------------------------------- */

    // Back Key Press Event Handler
    function onBackKeyDown() {
      renderHomeView();
      if (watchID != null) {
        navigator.accelerometer.clearWatch(watchID);
      }
    }

    function checkPairingCode() {
      if(document.getElementById('codeInput').value.length == 0) {
        document.getElementById('pairButton').disabled = true;
        document.getElementById('message').innerHTML = "Start Typing";
        document.getElementById('message').style.color = '#FFFFFF';
      }
      if(document.getElementById('codeInput').value.length == 5) {
        document.getElementById('pairButton').disabled = false;
        document.getElementById('message').innerHTML = "Ready to Pair";
        document.getElementById('message').style.color = '#4CAF50';
      } else {
        document.getElementById('pairButton').disabled = true;
        document.getElementById('message').innerHTML = "Keep Typing...";
        document.getElementById('message').style.color = '#FFFFFF';
      }
    }

    // Pairing Request Event Handler
    function pairRequest() {
      document.getElementById('message').innerHTML = "Pairing";
      document.getElementById('message').style.color = '#DC0000';
      document.getElementById('message').className = "blink";
    }

    function testEvent() {
      alert('firing test event');
      webSocket.send("hello");
    }

    function onSuccess(acceleration) {
    var html =
      "<p> Acc X: " + acceleration.x + "<br>" +
      "<p> Acc Y: " + acceleration.y + "<br>" +
      "<p> Acc Z: " + acceleration.z + "<br>" +
      "<p> Time: " + acceleration.timestamp + "<br>";
      document.getElementById('accelerometer').innerHTML = html;
    }

    function onError() {
      alert('Error checking accelerometer data');
    }

    /* ---------------------------------- Rendering Views ---------------------------------- */

    // Render the Home View
    function renderHomeView() {
      var html =
        "<h1>Pair With Computer</h1>" +
        "<div id='message'>Start Typing</div>" +
        "<input type='number' placeholder='Enter the Code on Your Screen' id='codeInput'><br>" +
        "<button type='button' class='button' id='pairButton' disabled>Pair</button>" +
        "<button type='button' class='button' id='debugButton'>Debug Mode</button>";
      document.getElementById('application').innerHTML = html;
      document.getElementById('debugButton').onclick = renderDebugView;
      document.getElementById('pairButton').onclick = pairRequest;
      document.getElementById('codeInput').oninput = checkPairingCode;
    }

    // Render the Debug View
    function renderDebugView() {
      var html =
        "<h1>Debug</h1><br><br>" +
        "<div id ='accelerometer'></div>" +
        "<button type='button' class='button' id='testButton'>Test Event</button>";
      document.getElementById('application').innerHTML = html;
      document.getElementById('testButton').onclick = testEvent;

      var options = { frequency: 100 };  // Update every .1 seconds
      watchID = navigator.accelerometer.watchAcceleration(onSuccess, onError, options);
    }

    // Render the Game Select View
    function renderGameSelectView() {
      var html =
        "<h1>Select a Game</h1><br><br>";
      document.getElementById('application').innerHTML = html;
    }

    // Render a Game
    function renderGameView() {
      var object = ""; //whatever the backend sends us
      var html = ""; // parse the object for html
      document.getElementById('application').innerHTML = html;
    }

}());
