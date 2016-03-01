(function () {

    /* ---------------------------------- Local Variables ---------------------------------- */

    var viewStack;                    // stack for back button behavior
    var currentView;                  // track what view is rendered
    var webSocket;                    // websocket connection
    var groupId;                      // assigned by server
    var clientId;                     // assigned by server
    var watchId;                      // used by accelerometer

    /* ---------------------------------- Game Data ---------------------------------- */

    var pollingAcc;                   // boolean to track accelerometer
    var accData;                      // object to track acceleration data changes

    /* --------------------------------- Device Ready -------------------------------- */
    document.addEventListener('deviceready', init, false);

    function init() {

      // Clear global variables
      viewStack = new Array();
      currentView = undefined;
      webSocket = undefined;
      groupId = undefined;
      clientId = undefined;
      watchId = undefined;
      pollingAcc = false;

      // Add event listeners and render the home view
      console.log('Device is ready');
      document.addEventListener("backbutton", onBackKeyDown, false);
      renderHomeView();

      // Ensure only one connection is open at a time
      if(webSocket !== undefined && webSocket.readyState !== WebSocket.CLOSED){
        console.log('WebSocket is already opened');
        return;
      }

      // Create a new instance of the websocket
      webSocket = new WebSocket("ws://proj-309-16.cs.iastate.edu:8080/SocketHandler/gameconnect");

      // When the websocket is opened
      webSocket.onopen = function(event){
        console.log('WebSocket connection opened at ws://proj-309-16.cs.iastate.edu:8080/SocketHandler/gameconnect');
        if(event.data === undefined) {
          return;
        }
      };

      // When a message is read from the websocket
      webSocket.onmessage = function(event) {
        console.log('Message received from server:');
        console.log('%c' + event.data, 'color: #4CAF50');
        var data;
        try {
          data = JSON.parse(event.data);
        } catch (e) {
          return;
        }

        switch(data.messageType) {
          case "join-group":
            joinGroup(data);
            break;
          case "game-list":
            gameList(data);
            break;
          case "game-config":
            gameConfig(data);
            break;
          case "exit":
            reset();
            break;
          default:
            console.log("Message type not recognized");
            console.log(event);
        }
      };

      // When the websocket is closed
      webSocket.onclose = function(event){
        console.log('WebSocket closed, resetting application');
        reset();
      };

    }


    /* ---------------------------------- Local Functions ---------------------------------- */

    // Back Key Press Event Handler
    function onBackKeyDown() {
      renderHomeView();
    }

    // Reset controller
    function reset() {
      stopAcc();
      init();
    }

    // Check pairing input field any time the value changes
    function checkPairingCode() {
      if(document.getElementById('pairInput').value.length == 0) {
        document.getElementById('pairButton').disabled = true;
        document.getElementById('message').innerHTML = "Start Typing";
        document.getElementById('message').style.color = '#FFFFFF';
      } else if(document.getElementById('pairInput').value.length == 5) {
        document.getElementById('pairButton').disabled = false;
        document.getElementById('message').innerHTML = "Ready to Pair";
        document.getElementById('message').style.color = '#4CAF50';
      } else if(document.getElementById('pairInput').value.length > 5) {
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
      document.getElementById('pairInput').disabled = true;

      // Send the pairing code
      var codeString = parseInt(document.getElementById('pairInput').value, 10).toString();
      console.log("Pairing code is " + codeString);
      var data = {"groupId": null,
                    "sourceType" : "controller",
                    "messageType" : "join-group",
                    "content" :
                    {
                      "groupingCode" : codeString
                    }
      }
      console.log("Sending data to server:");
      console.log('%c' + JSON.stringify(data), 'color: #0080FF');
      webSocket.send(JSON.stringify(data));
    }

    // Test event for debug page
    function testEvent() {
      var text = document.getElementById('debugInput').value;
      console.log("Sending message to server:");
      console.log('%c' + text, 'color: #0080FF');
      webSocket.send(text);
      document.getElementById('debugInput').value = "";
    }

    /* ---------------------------------- Accelerometer Data ---------------------------------- */

    // Toggle acceleration tracking
    function toggleAcc() {
      if (pollingAcc === false) {

        // Initialize acceleration data
        accData = {x: [0,0,0,0,0], y: [0,0,0,0,0], z: [0,0,0,0,0]};

        var options = { frequency: 200 };  // Update every .2 seconds
        watchId = navigator.accelerometer.watchAcceleration(accSuccess, accError, options);
        pollingAcc = true;

        console.log("Started tracking accelerometer data");
      }
      else {
        navigator.accelerometer.clearWatch(watchId);
        pollingAcc = false;
        console.log("Stopped tracking accelerometer data");
      }
    }

    // Stop acceleration tracking
    function stopAcc() {
      if (pollingAcc === true) {
        navigator.accelerometer.clearWatch(watchId);
        pollingAcc = false;
        console.log("Stopped tracking accelerometer data");
      }
    }

    // Success callback for getting acceleration
    function accSuccess(acceleration) {

      // Update values
      accData.x.unshift(acceleration.x);      // add to front of array
      accData.y.unshift(acceleration.y);
      accData.z.unshift(acceleration.z);
      accData.x.pop();                        // remove last item of array
      accData.y.pop();
      accData.z.pop();

      if(currentView === "debug") {
        var html =
          "<p> Acc X: " + acceleration.x + "<br>" +
          "<p> Acc Y: " + acceleration.y + "<br>" +
          "<p> Acc Z: " + acceleration.z + "<br>" +
          "<p> Time: " + acceleration.timestamp + "<br>";
          document.getElementById('accelerometer').innerHTML = html;

          // Configuration object
          config = {
            xHigh: false,      // left tilt
            xLow: false,      // right tilt
            yHigh: true,     // up tilt
            yLow: false,      // down tilt
            zHigh: false,
            zLow: false
          };

          reportAccSpike(config);
          //reportAccTilt();

      } else if(currentView === "game") {
        // do something
      }

    }

    // Error callback for getting acceleration
    function accError() {
      console.log('Error checking accelerometer data');
    }

    // Watch for spikes in acceleration
    function reportAccSpike(config) {
      var xDif = accData.x[0] - accData.x[1];
      if(config.xHigh && xDif > 5) {
        console.log("Acc X High Event");
      } else if(config.xLow && xDif < -5) {
        console.log("Acc X Low Event");
      }

      var yDif = accData.y[0] - accData.y[1];
      if(config.yHigh && yDif > 5 && accData.x[0] < 4) {
        console.log("Acc Y High Event");
      } else if(config.yLow && yDif < -5) {
        console.log("Acc Y Low Event");
      }

      var zDif = accData.z[0] - accData.z[1];
      if(config.zHigh && zDif > 5) {
        console.log("Acc Z High Event");
      } else if(config.zLow && zDif < -5) {
        console.log("Acc Z Low Event");
      }
    }

    // Watch for device tilt (steering wheel)
    function reportAccTilt() {
      var average = (accData.y[0] + accData.y[1] + accData.y[2])/3;
      if(average > 1) {
        console.log("Right: (" + Math.round(average) + ")");
      } else if (average < -1){
        console.log("Left: (" + Math.round(Math.abs(average)) + ")");
      } else {
        console.log("Straight");
      }
    }

    /* ---------------------------------- WebSocket Response Handlers ---------------------------------- */

    // After receiving a Join Group messsage from the server
    function joinGroup(data) {
      if(data.content.groupingApproved === true) {
        console.log("Successfully joined group " + data.groupId);
        groupId = data.groupId;
        clientId = data.content.clientId;
        document.getElementById('message').innerHTML = "Success";
        document.getElementById('pairButton').className = "button";
        document.getElementById('message').style.color = '##4CAF50';
      } else {
        console.log("Failed to join group");
        document.getElementById('message').innerHTML = "Failed to Join Group";
        document.getElementById('pairButton').className = "button";
        document.getElementById('message').style.color = '#DC0000';
        document.getElementById('pairInput').value = "";
      }
    }

    function gameList(data) {
      if(data.success === true) {
        console.log("Recieved list of games");
        renderGameSelectView();
      } else {
        // panic
      }
    }

    function gameConfig(data) {
      if(data.success === true) {
        console.log("Recieved game configuration details");
        renderGameView();
      } else {
        // panic
      }
    }

    /* ---------------------------------- Rendering Views ---------------------------------- */

    // Render the Home View
    function renderHomeView() {
      var html =
        "<h1>Pair With Computer</h1>" +
        "<div id='message'>Start Typing</div>" +
        "<input type='number' placeholder='Enter the Code on Your Screen' id='pairInput'><br>" +
        "<button type='button' class='button' id='pairButton' disabled>Pair</button>" +
        "<button type='button' class='button' id='debugButton'>Debug Mode</button>";
      document.getElementById('application').innerHTML = html;
      document.getElementById('debugButton').onclick = renderDebugView;
      document.getElementById('pairButton').onclick = pairRequest;
      document.getElementById('pairInput').oninput = checkPairingCode;
      stopAcc();
      currentView = "home";
      console.log('Home view rendered');
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
      currentView = "debug";
      console.log('Debug view rendered');
    }

    // Render the Game Select View
    function renderGameSelectView() {
      var html =
        "<h1>Select a Game</h1>";
      document.getElementById('application').innerHTML = html;
      currentView = "select";
      console.log('Game Select view rendered');
    }

    // Render a Game
    function renderGameView() {
      var html =
        "<h1>Game</h1>";
      document.getElementById('application').innerHTML = html;
      currentView = "game";
      console.log('Game view rendered');
    }

}());
