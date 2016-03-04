(function () {

    /* ---------------------------------- Local Variables ---------------------------------- */
    var viewStack = new Array();      // stack for back button behavior
    var webSocket;                    // websocket connection
    var watchID;                      // used by accelerometer
    var pollingAcc = false;           // boolean to track accelerometer

    /* --------------------------------- Device Ready -------------------------------- */
    document.addEventListener('deviceready', function () {

      // Add event listeners and render the home view
      console.log('Device is ready');
      document.addEventListener("backbutton", onBackKeyDown, false);
      console.log('Rendering home view');
      renderHomeView();

      // Ensure only one connection is open at a time
      if(webSocket !== undefined && webSocket.readyState !== WebSocket.CLOSED){
        console.log('WebSocket is already opened');
        return;
      }

      // Create a new instance of the websocket
      webSocket = new WebSocket("ws://proj-309-16.cs.iastate.edu:8080/SocketHandler/test/chat");

      // When the websocket is opened
      webSocket.onopen = function(event){
        console.log('WebSocket connection opened at ws://proj-309-16.cs.iastate.edu:8080/SocketHandler/test/chat');
        if(event.data === undefined) {
          return;
        }
      };

      // When a message is read from the websocket
      webSocket.onmessage = function(event) {
        console.log('Message received from WebSocket');
        switch(event.code) {
          case 1:
            // do something
            break;
          case 2:
            // do something
            break;
          case 3:
            // do something
            break;
          case 4:
            // do something
            break;
          case 5:
            // do something
            break;
        }
      };

      // When the websocket is closed
      webSocket.onclose = function(event){
        console.log('WebSocket closed, resetting application');
        renderHomeView();
        stopAcc();
      };

    }, false);

    /* ---------------------------------- Local Functions ---------------------------------- */

    // Back Key Press Event Handler
    function onBackKeyDown() {
      renderHomeView();
    }

    // Check pairing input field any time the value changes
    function checkPairingCode() {
      if(document.getElementById('codeInput').value.length == 0) {
        document.getElementById('pairButton').disabled = true;
        document.getElementById('message').innerHTML = "Start Typing";
        document.getElementById('message').style.color = '#FFFFFF';
      } else if(document.getElementById('codeInput').value.length == 5) {
        document.getElementById('pairButton').disabled = false;
        document.getElementById('message').innerHTML = "Ready to Pair";
        document.getElementById('message').style.color = '#4CAF50';
      } else if(document.getElementById('codeInput').value.length > 5) {
        document.getElementById('pairButton').disabled = true;
        document.getElementById('message').innerHTML = "Whoops, too long";
        document.getElementById('message').style.color = '#FFFFFF';
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
      document.getElementById('pairButton').disabled = true;
      document.getElementById('pairButton').className = "blink";
      document.getElementById('codeInput').disabled = true;
      console.log('sending pairing code');
      webSocket.send(document.getElementById('codeInput').value);
    }

    // Test event for debug page - writes input to the websocket
    function testEvent() {
      console.log('sending message to the websocket');
      webSocket.send(document.getElementById('debugInput').value);
      document.getElementById('debugInput').value = "";
    }

    // Toggle acceleration tracking
    function toggleAcc() {
      if (pollingAcc === false) {
        var options = { frequency: 100 };  // Update every .1 seconds
        watchID = navigator.accelerometer.watchAcceleration(accSuccess, accError, options);
        pollingAcc = true;
      }
      else {
        navigator.accelerometer.clearWatch(watchID);
        pollingAcc = false;
      }
    }

    function stopAcc() {
      if (pollingAcc === true) {
        navigator.accelerometer.clearWatch(watchID);
        pollingAcc = false;
      }
    }

    // Configure gameplay controls
    function gameConfig(object) {

    }

    // Success callback for getting acceleration
    function accSuccess(acceleration) {
    var html =
      "<p> Acc X: " + acceleration.x + "<br>" +
      "<p> Acc Y: " + acceleration.y + "<br>" +
      "<p> Acc Z: " + acceleration.z + "<br>" +
      "<p> Time: " + acceleration.timestamp + "<br>";
      document.getElementById('accelerometer').innerHTML = html;
    }

    // Error callback for getting acceleration
    function accError() {
      console.log('error checking accelerometer data');
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
      stopAcc();
      console.log('home view successfully rendered');
    }

    // Render the Debug View
    function renderDebugView() {
      var html =
        "<h1>Debug</h1>" +
        "<input type='text' placeholder='Write to WebSocket' id='debugInput'><br>" +
        "<button type='button' class='button' id='testButton'>Send</button>" +
        "<div id ='accelerometer'><p> Acc X: --- <br><p> Acc Y: --- <br><p> Acc Z: --- <br><p> Time: --- <br></div>" +
        "<button type='button' class='button' id='accButton'>Toggle Accelerometer</button>";
      document.getElementById('application').innerHTML = html;
      document.getElementById('testButton').onclick = testEvent;
      document.getElementById('accButton').onclick = toggleAcc;
      console.log('debug view successfully rendered');
    }

    // Render the Game Select View
    function renderGameSelectView() {
      var html =
        "<h1>Select a Game</h1>";
      document.getElementById('application').innerHTML = html;
    }

    // Render a Game
    function renderGameView() {
      var object = ""; //whatever the backend sends us
      var html = ""; // parse the object for html
      document.getElementById('application').innerHTML = html;
    }

}());
