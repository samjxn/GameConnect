(function () {

    /* ---------------------------------- Local Variables ---------------------------------- */

    var currentView;                  // track what view is rendered
    var webSocket;                    // websocket connection
    var groupId;                      // assigned by server
    var clientId;                     // assigned by server
    var watchId;                      // used by accelerometer

    /* ---------------------------------- Game Data ---------------------------------- */

    var pollingAcc;                   // boolean to track accelerometer
    var accCounter;                   // track how long we've been polling
    var accData;                      // object to track acceleration data changes
    var calibrationFactor;            // calibrate acceleration on startup

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
          case "error":
            serverError(data);
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
      switch(currentView) {
        case "home":
          navigator.app.exitApp();
          break;
        case "debug":
          renderHomeView();
          break;
        case "select":
          renderHomeView();
          break;
        case "game":
          renderGameSelectView();
          break;
        default:
          navigator.app.exitApp();
      }
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

      // Send the pairing code as JSON object
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
      var data = {"groupId": null,
                    "sourceType" : "controller",
                    "messageType" : "chat-message",
                    "content" :
                    {
                      "messageText" : text
                    }
      }
      console.log("Sending message to server:");
      console.log('%c' + JSON.stringify(data), 'color: #0080FF');
      webSocket.send(JSON.stringify(data));
      document.getElementById('debugInput').value = "";
    }

    /* ---------------------------------- Accelerometer Data ---------------------------------- */

    // Toggle acceleration tracking
    function toggleAcc() {
      if (pollingAcc === false) {

        // Initialize acceleration data
        accCounter = 0;
        calibrationFactor = {x: 0, y: 0, z: 0};
        accData = {x: [0,0,0,0,0], y: [0,0,0,0,0], z: [0,0,0,0,0]};

        // Start acceleration polling
        var options = { frequency: 200 };  // Update every .2 seconds
        watchId = navigator.accelerometer.watchAcceleration(accSuccess, accError, options);
        pollingAcc = true;

        console.log("Started tracking accelerometer data");
      }
      else {
        stopAcc();
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
        if (accCounter === 5) {
          calibrationFactor.x = (accData.x[0] + accData.x[1] + accData.x[2] + accData.x[3] + accData.x[4]) / 5;
          calibrationFactor.y = (accData.y[0] + accData.y[1] + accData.y[2] + accData.y[3] + accData.y[4]) / 5;
          calibrationFactor.z = (accData.z[0] + accData.z[1] + accData.z[2] + accData.z[3] + accData.z[4]) / 5;
          accCounter = 6;
        } else if (accCounter < 5) {
          var html =
            "<p> Acc X: calibrating... <br>" +
            "<p> Acc Y: calibrating... <br>" +
            "<p> Acc Z: calibrating... <br>" +
            "<p> Time: " + acceleration.timestamp + "<br>";
          document.getElementById('accelerometer').innerHTML = html;
          accCounter = accCounter + 1;
        } else {
          var html =
            "<p> Acc X: " + acceleration.x + "<br>" +
            "<p> Acc Y: " + acceleration.y + "<br>" +
            "<p> Acc Z: " + acceleration.z + "<br>" +
            "<p> Time: " + acceleration.timestamp + "<br>";
            document.getElementById('accelerometer').innerHTML = html;
        }

          //modeWiiRemote();
          modeSteeringWheel();

      } else if(currentView === "game") {
        // do something
      }

    }

    // Error callback for getting acceleration
    function accError() {
      console.log('Error checking accelerometer data');
    }

    // Report spikes in acceleration
    function modeWiiRemote() {
      if (accCounter > 5) {
        var changeX = accData.x[0] - accData.x[1];
        var changeY = accData.y[0] - accData.y[1];

        var xDif = accData.x[0] - calibrationFactor.x;
        var yDif = accData.y[0] - calibrationFactor.y;

        var reportX = true;
        var reportY = true;

        if (Math.abs(changeX) > 6 && Math.abs(changeY) > 6) {
          if (Math.abs(changeX) > Math.abs(changeY)) {
            reportX = true;
            reportY = false;
          } else {
            reportX = false;
            reportY = true;
          }
        }

        if(reportX && xDif > 4 && changeX > 6) {
          console.log("Left");
        } else if(xDif < -4 && changeX < -6) {
          console.log("Right");
        }

        if(reportY && yDif > 4 && changeY > 6) {
          console.log("Up");
        } else if(yDif < -4 && changeY < -6) {
          console.log("Down");
        }
      } else {
        console.log("Calibrating device, please wait...");
      }
    }

    // Report device tilt
    function modeSteeringWheel() {
      if (accCounter > 5) {
        var average = ( (accData.y[0] - calibrationFactor.y) +
                        (accData.y[1] - calibrationFactor.y) +
                        (accData.y[2] - calibrationFactor.y) / 3);

        if(average > 1) {
          console.log("Right: (" + Math.round(average) + ")");
        } else if (average < -1){
          console.log("Left: (" + Math.round(Math.abs(average)) + ")");
        } else {
          console.log("Straight");
        }
      } else {
        console.log("Calibrating device, please wait...");
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

    // Server has sent list of games
    function gameList(data) {
      if(data.success === true) {
        console.log("Recieved list of games");
        renderGameSelectView();
      } else {
        // panic
      }
    }

    // Server has sent game configuration data
    function gameConfig(data) {
      if(data.success === true) {
        console.log("Recieved game configuration details");
        renderGameView();
      } else {
        // panic
      }
    }

    // Server has sent us an error message
    function serverError(data) {
      console.log("Server responded with error message");
    }

    // Reset controller
    function reset() {
      stopAcc();
      init();
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
