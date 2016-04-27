(function () {

    /* ---------------------------------- Application Variables ---------------------------------- */

    var currentView;                  // track what view is rendered
    var previousView;                 // used for back button functionality
    var webSocket;                    // websocket connection
    var groupId;                      // assigned by server
    var clientId;                     // assigned by server
    var fbCode;                       // code used to pair with Facebook
    var timeout;                      // for keeping track of time
    var gamesList;                    // list of games recieved from server

    /* ---------------------------------- Accelerometer Variables ---------------------------------- */

    var watchId;                      // used by accelerometer
    var pollingAcc;                   // boolean to track accelerometer
    var accCounter;                   // track how long we've been polling
    var accData;                      // object to track acceleration data changes
    var calibrationFactor;            // calibrate acceleration on startup
    var waitTime;                     // wait time between events

    /* --------------------------------- Device Ready -------------------------------- */
    document.addEventListener('deviceready', init, false);

    // Initialize
    function init() {
      console.log('Device is ready');

      // Clear global variables
      currentView = undefined;
      webSocket = undefined;
      groupId = undefined;
      clientId = undefined;
      gamesList = [];
      watchId = undefined;
      pollingAcc = false;

      // Add event listeners
      document.addEventListener("backbutton", onBackKeyDown, false);

      // Render the home view
      renderHomeView();
      document.getElementById('pairButton').disabled = true;
      document.getElementById('pairInput').disabled = true;
      document.getElementById('message').innerHTML = "No connection";
      document.getElementById('message').style.color = '#DC0000';

      // Connect to websocket
      websocketConnect();
    }

    /* ---------------------------------- WebSocket Connection ---------------------------------- */

    function websocketConnect() {
      // Ensure only one connection is open at a time
      if(webSocket !== undefined && webSocket.readyState !== WebSocket.CLOSED){
        console.log("WebSocket is already opened");
        checkPairingCode();
        return;
      }

      // Create a new instance of the websocket
      webSocket = new WebSocket("ws://proj-309-16.cs.iastate.edu:8080/SocketHandler/gameconnect");
      timeout = setTimeout(connectionFailed, 2000);     // set timeout 2 seconds;
      console.log("Connecting to WebSocket");

      // When the websocket is opened
      webSocket.onopen = function(event) {
        if(event === undefined) {
          return;
        }
        console.log("WebSocket connection opened at ws://proj-309-16.cs.iastate.edu:8080/SocketHandler/gameconnect");
        clearTimeout(timeout);
        checkPairingCode();
      };

      // When a message is read from the websocket
      webSocket.onmessage = function(event) {
        console.log("Message received from server:");
        console.log('%c' + event.data, 'color: #4CAF50');
        var data;
        try {
          data = JSON.parse(event.data);
        } catch (e) {
          return;
        }

        // Determine message type
        switch(data.messageType) {
          case "set-clientid":
            setClientId(data);
            break;
          case "join-group":
            joinGroup(data);
            break;
          case "context-list":
            updateGameList(data);
            renderGameSelectView();
            break;
          case "context-selected":
            console.log("Server recieved game choice");
            break;
          case "settings":
            updateFacebookCode(data);
            renderSettingsView();
          case "controller-snapshot":
            console.log("Server recieved controller input");
            break;
          case "game-mode":
            gameConfig(data);
            break;
          case "set-color":
            setColor(data);
            break;
          case "chat-msg":
            console.log("Recieved a chat message");
            break;
          case "quit-game":
            console.log("A player has left the game");
            break;
          case "error":
            serverError(data);
            break;
          case "disconnect":
            reset();
            break;
          default:
            console.log("Message type not recognized");
        }
      };

      // When the websocket is closed
      webSocket.onclose = function(event) {
        console.log('WebSocket closed, attempting to reconnect');
        connectionFailed();
      }
    }

    /* ---------------------------------- Reset and No Connection ---------------------------------- */

    function connectionFailed() {
      switch(currentView) {
        case "home":
          document.getElementById('pairButton').disabled = true;
          document.getElementById('pairInput').disabled = true;
          document.getElementById('message').innerHTML = "Attempting to reconnect";
          document.getElementById('message').style.color = '#DC0000';
          document.getElementById('message').className = "blink";
          break;
        case "select":
          document.getElementById('playButton').disabled = true;
          document.getElementById('status').innerHTML = "Attempting to reconnect";
          document.getElementById('status').style.color = '#4CAF50';
          document.getElementById('status').className = "blink";
          break;
        default:
          break;
      }

      websocketConnect();
    }

    // Reset controller
    function reset() {
      console.log("Resetting controller");
      stopAcc();
      init();
    }

    /* ---------------------------------- Back Button Functionality ---------------------------------- */

    // Back Key Press Event Handler
    function onBackKeyDown() {
      stopAcc();
      switch(currentView) {
        case "home":
          navigator.app.exitApp();
          break;
        case "select":
          navigator.notification.confirm("Are you sure you want to leave this session and return to the pairing screen?", onLeaveSessionDialog, "End Session", ["Yes", "Cancel"]);
          break;
        case "settings":
          renderGameSelectView();
          break;
        case "portrait":
          if(previousView === "debug") {
            renderDebugView();
          } else {
            navigator.notification.confirm("Are you sure you want to end the game?", onEndGameDialog, "End Game", ["Yes", "Cancel"]);
          }
          break;
        case "landscape":
          if(previousView === "debug") {
            renderDebugView();
          } else {
            navigator.notification.confirm("Are you sure you want to end the game?", onEndGameDialog, "End Game", ["Yes", "Cancel"]);
          }
          break;
        case "debug":
          renderGameSelectView();
          break;
        case "chat":
          navigator.notification.confirm("Are you sure you want to leave this session and return to the pairing screen?", onLeaveSessionDialog, "Leave Session", ["Yes", "Cancel"]);
          break;
        default:
          navigator.app.exitApp();
      }
    }

    // Dialog for leaving a game
    function onEndGameDialog(buttonIndex) {
      if (buttonIndex === 1) {  // confirm
        console.log("Quitting the game");
        var data = {  "groupId": groupId,
                      "clientId": clientId,
                      "sourceType" : "controller",
                      "messageType" : "quit-game"
        }
        console.log("Sending data to server:");
        console.log('%c' + JSON.stringify(data), 'color: #0080FF');
        webSocket.send(JSON.stringify(data));
        renderGameSelectView();
      } else {
        return;
      }
    }

    // Dialog for leaving a pairing session
    function onLeaveSessionDialog(buttonIndex) {
      if (buttonIndex === 1) {  // confirm
        console.log("Leaving this session");
        var data = {  "groupId": groupId,
                      "clientId": clientId,
                      "sourceType" : "controller",
                      "messageType" : "disconnect"
        }
        console.log("Sending data to server:");
        console.log('%c' + JSON.stringify(data), 'color: #0080FF');
        webSocket.send(JSON.stringify(data));
        reset();
      } else {
        return;
      }
    }

    /* ---------------------------------- Pairing Code Handling ---------------------------------- */

    // Check pairing input field any time the value changes
    function checkPairingCode() {
      if(document.getElementById('pairInput').value.length == 0) {
        document.getElementById('pairButton').disabled = true;
        document.getElementById('pairInput').disabled = false;
        document.getElementById('message').innerHTML = "Start Typing";
        document.getElementById('message').style.color = '#FFFFFF';
        document.getElementById('message').className = "";
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
      var nameString = document.getElementById('displayInput').value;
      console.log("Pairing code is " + codeString);
      var data = {  "groupId": null,
                    "clientId": clientId,
                    "sourceType" : "controller",
                    "messageType" : "join-group",
                    "content" :
                    {
                      "groupingCode" : codeString,
                      "name" : nameString.trim(),
                      "uuid" : device.uuid
                    }
      }
      console.log("Sending data to server:");
      console.log('%c' + JSON.stringify(data), 'color: #0080FF');
      timeout = setTimeout(pairTimeout, 30000);     // set timeout 30 seconds

      webSocket.send(JSON.stringify(data));
    }

    // Timeout event for no server response
    function pairTimeout() {
      document.getElementById('pairButton').disabled = true;
      document.getElementById('pairButton').className = "";
      document.getElementById('message').innerHTML = "Pairing Timed Out";
      document.getElementById('message').className = "";
      document.getElementById('message').style.color = '#DC0000';
      document.getElementById('pairInput').disabled = false;
      document.getElementById('pairInput').value = "";
      console.log("Pairing request timed out");
    }

    /* ---------------------------------- Game Selection Handling ---------------------------------- */

    // Get and highlight selected list item
    function selectListItem(event) {
      var selected;

      if(event.target.tagName === 'LI') {
        selected= document.querySelector('li.selected');
        if(selected) selected.className= '';
        event.target.className= 'selected';
      }
    }

    // Send selected game to backend
    function gameSelection() {
      var selection = document.getElementsByClassName("selected")
      if(selection.length != 1) {
        return;
      }
      var game = selection[0].innerHTML;
      console.log("Game selected: " + game);
      var data = {  "groupId": groupId,
                    "clientId": clientId,
                    "sourceType" : "controller",
                    "messageType" : "set-context",
                    "content" :
                    {
                      "contextName" : game
                    }
      }
      console.log("Sending data to server:");
      console.log('%c' + JSON.stringify(data), 'color: #0080FF');

      document.getElementById('status').innerHTML = "Waiting for Server";
      document.getElementById('status').style.color = '#4CAF50';
      document.getElementById('status').className = "blink";
      document.getElementById('playButton').disabled = true;
      timeout = setTimeout(selectTimeout, 30000);               // set timeout 30 seconds

      webSocket.send(JSON.stringify(data));
    }

    // Timeout event for no server response
    function selectTimeout() {
      document.getElementById('playButton').disabled = false;
      document.getElementById('status').innerHTML = "Server Timed Out";
      document.getElementById('status').className = "";
      document.getElementById('status').style.color = '#DC0000';
    }

    /* ---------------------------------- Game Controller Handling ---------------------------------- */

    // Handler for controller buttons and acceleration
    function sendSnapshot(button, x, y, z) {
      var a = false;
      var b = false;
      var d = 0;

      // Determine which button was pressed
      switch(button) {
        case "a":
          a = true;
          break;
        case "b":
          b = true;
          break;
        default:
          d = button;
      }

      // Prepare JSON
      var data = {  "groupId": groupId,
                    "clientId": clientId,
                    "sourceType":"controller",
                    "messageType": "controller-snapshot",
                    "content":
                    {
                      "d-pad-input": d,
                      "a-pressed": a,
                      "b-pressed": b,
                      "acceleration-x": x,
                      "acceleration-y": y,
                      "acceleration-z": z
                    }
      }

      // Send to server
      webSocket.send(JSON.stringify(data));
      console.log('%c' + JSON.stringify(data), 'color: #0080FF');
    }

    /* ---------------------------------- Debug Handling ---------------------------------- */

    // Test event for debug page
    function testEvent() {
      var text = document.getElementById('debugInput').value;
      var data = {  "groupId": groupId,
                    "clientId": clientId,
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

    /* ---------------------------------- Chat Handling ---------------------------------- */

    // Send chat message
    function chatMessage() {
      var text = document.getElementById('chatInput').value;
      if(text.length === 0) {
        return;
      } else {
        var data = {  "groupId": groupId,
                      "clientId": clientId,
                      "sourceType" : "controller",
                      "messageType" : "chat-msg",
                      "content" :
                      {
                        "message" : text.trim()
                      }
        }
        console.log("Sending message to server:");
        console.log('%c' + JSON.stringify(data), 'color: #0080FF');
        webSocket.send(JSON.stringify(data));
        document.getElementById('chatInput').value = "";
      }
    }

    /* ---------------------------------- WebSocket Response Handling ---------------------------------- */

    // Set client id
    function setClientId(data) {
      clientId = data.content.clientId;
      console.log("Connection established, received client id");
    }

    // Server has sent a join group success messsage
    function joinGroup(data) {
      clearTimeout(timeout);
      if(data.content.groupingApproved === true) {
        console.log("Successfully joined group " + data.groupId);
        groupId = data.groupId;
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

    // Server has sent a list of games
    function updateGameList(data) {
      console.log("Recieved list of games");
      gamesList = data.content.games;
    }

    // Server has sent game configuration data
    function gameConfig(data) {
      clearTimeout(timeout);
      console.log("Recieved game configuration details");
      switch(data.content.gameMode) {
        case 1:
          renderPortraitControllerView();
          break;
        case 2:
          renderPortraitControllerView();
          startAcc();
          break;
        case 3:
          renderLandscapeControllerView();
          break;
        case 4:
          renderLandscapeControllerView();
          startAcc();
          break;
        case 5:
          renderDebugView();
            break;
        case 6:
          renderChatView();
            break;
        default:
          console.log("Game mode not recognized");
      }
    }

    // Update Facebook pairing code with data from server
    function updateFacebookCode(data) {
      fbCode = data.content.paircode;
      console.log("Recieved Facebook pair code " + fbCode);
    }

    // Update controller color to match player color in game
    function setColor(data) {
      if ((currentView === "portrait" || currentView === "landscape") && data.content.clientId == clientId) {
        document.getElementById('application').style.backgroundColor = data.content.color;
        console.log("Updating controller color");
      }
      console.log("Recieved set color command but client id did not match");
      console.log("Client id is " + clientId);
    }

    // Server has sent an error message
    function serverError(data) {
      console.log("Server responded with error message");
    }

    /* ---------------------------------- Rendering Views ---------------------------------- */

    // Render the Home View
    function renderHomeView() {
      stopAcc();
      document.getElementById('application').style.backgroundColor = "#000000";
      var html =
        "<h1>Pair With Computer</h1>" +
        "<div id='message'>Start Typing</div>" +
        "<input type='number' placeholder='Enter the Code on Your Screen' id='pairInput'><br>" +
        "<div id = 'displayName'>Display Name</div>" +
        "<input type='text' placeholder='Display Name' id='displayInput' maxlength='15'><br>" +
        "<button type='button' class='button' id='pairButton' disabled>Pair</button>";
      document.getElementById('application').innerHTML = html;
      document.getElementById('pairButton').onclick = pairRequest;
      document.getElementById('pairInput').oninput = checkPairingCode;
      previousView = currentView;
      currentView = "home";
      console.log('Home view rendered');
    }

    // Render the Game Select View
    function renderGameSelectView() {
      stopAcc();
      document.getElementById('application').style.backgroundColor = "#000000";

      // Generate html for list of games
      var gameListHTML = "";
      var i;
      for (i = 0; i < gamesList.length; i++) {
        gameListHTML = gameListHTML + "<li>" + gamesList[i] + "</li>";
      }

      var html =
        "<h1>Select a Game</h1>" +
        "<div id='gameList'> <ul id='games'>" + gameListHTML +
        "</ul> </div> <button type='button' class='button' id='playButton'>Play</button>" +
        "<div id='status'> Ready </div>";
      document.getElementById('application').innerHTML = html;
      document.getElementById('playButton').onclick = gameSelection;
      document.querySelector('ul').addEventListener('click', function(event) { selectListItem(event); }, false);

      // Update views and log
      previousView = currentView;
      currentView = "select";
      console.log('Game Select view rendered');
    }

    // Render the settings view
    function renderSettingsView() {
      document.getElementById('application').style.backgroundColor = "#000000";
      var html =
        "<h1>Settings</h1>" +
        "<div id='fbCode'>" + fbCode + "</div>";
      document.getElementById('application').innerHTML = html;

      // Update views and log
      previousView = currentView;
      currentView = "settings";
      console.log('Settings view rendered');
    }

    // Render the Portrait Game Contoller view with Motion Remote (unfinished)
    function renderPortraitControllerView() {
      document.getElementById('application').style.backgroundColor = "#000000";
      var html =
        "<button type='button' class='controllerButton' id='portraitButtonA'>A</button>" +
        "<button type='button' class='controllerButton' id='portraitButtonB'>B</button>" +
        "<button type='button' class='controllerButton' id='portraitButtonN'>&#8593</button>" +
        "<button type='button' class='controllerButton' id='portraitButtonW'>&#8592</button>" +
        "<button type='button' class='controllerButton' id='portraitButtonE'>&#8594</button>" +
        "<button type='button' class='controllerButton' id='portraitButtonS'>&#8595</button>";
      document.getElementById('application').innerHTML = html;
      document.getElementById('portraitButtonA').onclick = function(){ sendSnapshot("a", 0); };
      document.getElementById('portraitButtonB').onclick = function(){ sendSnapshot("b", 0); };
      document.getElementById('portraitButtonN').onclick = function(){ sendSnapshot("1", 0); };
      document.getElementById('portraitButtonW').onclick = function(){ sendSnapshot("4", 0); };
      document.getElementById('portraitButtonE').onclick = function(){ sendSnapshot("2", 0); };
      document.getElementById('portraitButtonS').onclick = function(){ sendSnapshot("3", 0); };

      // Update views and log
      previousView = currentView;
      currentView = "portrait";
      console.log('Portrait game controller view rendered');
    }

    // Render the Landscape Game Controller view with Steering Wheel
    function renderLandscapeControllerView() {
      document.getElementById('application').style.backgroundColor = "#000000";
      var html =
        "<button type='button' class='controllerButtonLandscape' id='controllerButtonA'>A</button>" +
        "<button type='button' class='controllerButtonLandscape' id='controllerButtonB'>B</button>" +
        "<button type='button' class='controllerButtonLandscape' id='controllerButtonW'>&#8592</button>" +
        "<button type='button' class='controllerButtonLandscape' id='controllerButtonS'>&#8595</button>" +
        "<button type='button' class='controllerButtonLandscape' id='controllerButtonN'>&#8593</button>" +
        "<button type='button' class='controllerButtonLandscape' id='controllerButtonE'>&#8594</button>";
      document.getElementById('application').innerHTML = html;
      document.getElementById('controllerButtonA').onclick = function(){ sendSnapshot("a", 0); };
      document.getElementById('controllerButtonB').onclick = function(){ sendSnapshot("b", 0); };
      document.getElementById('controllerButtonW').onclick = function(){ sendSnapshot("4", 0); };
      document.getElementById('controllerButtonS').onclick = function(){ sendSnapshot("3", 0); };
      document.getElementById('controllerButtonN').onclick = function(){ sendSnapshot("1", 0); };
      document.getElementById('controllerButtonE').onclick = function(){ sendSnapshot("2", 0); };

      // Update views and log
      previousView = currentView;
      currentView = "landscape";
      console.log('Landscape game controller view rendered');
    }

    // Render the Debug View
    function renderDebugView() {
      stopAcc();
      document.getElementById('application').style.backgroundColor = "#000000";
      var html =
        "<h1>Debug</h1>" +
        "<input type='text' placeholder='Write to WebSocket' id='debugInput'><br>" +
        "<button type='button' class='button' id='testButton'>Send</button>" +
        "<div id ='accelerometer'><p> Acc X: --- <br><p> Acc Y: --- <br><p> Acc Z: --- <br></div>" +
        "<button type='button' class='button' id='accButton'>Toggle Accelerometer</button>" +
        "<div id='inline'>" +
        "<button type='button' class='button' id='portraitButton'>1</button>" +
        "<button type='button' class='button' id='landscapeButton'>2</button>" +
        "</div>";
      document.getElementById('application').innerHTML = html;
      document.getElementById('testButton').onclick = testEvent;
      document.getElementById('accButton').onclick = startAcc;
      document.getElementById('portraitButton').onclick = renderPortraitControllerView;
      document.getElementById('landscapeButton').onclick = renderLandscapeControllerView;

      // Update views and log
      previousView = currentView;
      currentView = "debug";
      console.log('Debug view rendered');
    }

    // Render the Chat View
    function renderChatView() {
      document.getElementById('application').style.backgroundColor = "#000000";
      var html =
        "<h1>Chat</h1>" +
        "<div id='chatMessage'> Type your message here </div>" +
        "<textarea id='chatInput'></textarea>" +
        "<button type='button' class='button' id='chatButton'>Send</button>";
      document.getElementById('application').innerHTML = html;
      document.getElementById('chatButton').onclick = chatMessage;

      // Update views and log
      previousView = currentView;
      currentView = "chat";
      console.log('Chat view rendered');
    }

    /* ---------------------------------- Accelerometer Data ---------------------------------- */

    // Toggle acceleration tracking
    function startAcc() {
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

      // Calibrate after one second
      if (accCounter === 5) {
        calibrateAcceleration();
      }

      // Action based on current view
      switch(currentView) {
        case "debug":
          modeDebug();
          break;
        case "portrait":
          modePortraitController();
          break;
        case "landscape":
          modeLandscapeController();
          break;
      }

        // Update acceleration counter
        accCounter = accCounter + 1;
    }

    // Error callback for getting acceleration
    function accError() {
      console.log('Error checking accelerometer data');
    }

    // Calibrate by calculating acerage of first five data points
    function calibrateAcceleration() {
      calibrationFactor.x = (accData.x[0] + accData.x[1] + accData.x[2] + accData.x[3] + accData.x[4]) / 5;
      calibrationFactor.y = (accData.y[0] + accData.y[1] + accData.y[2] + accData.y[3] + accData.y[4]) / 5;
      calibrationFactor.z = (accData.z[0] + accData.z[1] + accData.z[2] + accData.z[3] + accData.z[4]) / 5;
    }

    // If we are in debug mode, update view with acceleration data
    function modeDebug() {
      if (accCounter < 5) {
        var html =
          "<p> Acc X: calibrating... <br>" +
          "<p> Acc Y: calibrating... <br>" +
          "<p> Acc Z: calibrating... <br>";
          document.getElementById('accelerometer').innerHTML = html;
      } else if (accCounter > 5) {
        var html =
          "<p> Acc X: " + accData.x[0] + "<br>" +
          "<p> Acc Y: " + accData.y[0] + "<br>" +
          "<p> Acc Z: " + accData.z[0] + "<br>";
          document.getElementById('accelerometer').innerHTML = html;
      }
    }

    // Motion remote mode
    function modePortraitController() {
      if (accCounter < 5) {                                        // still calibrating
        console.log("Calibrating device, please wait...");
      } else {                                                     // done calibrating
        if (waitTime > 0) {               // prevent events from being double counted
          waitTime = waitTime - 1;
        } else {

          // Find change in X and Y acceleration over last two data points
          var changeX1 = accData.x[0] - accData.x[1];
          var changeX2 = accData.x[0] - accData.x[2];
          var changeY1 = accData.y[0] - accData.y[1];
          var changeY2 = accData.y[0] - accData.y[2];

          // Compare against calibrated zero
          var xDif = accData.x[0] - calibrationFactor.x;
          var yDif = accData.y[0] - calibrationFactor.y;

          // If X difference is greater than four and change is greater than 6, trigger event
          if(xDif > 4 && (changeX1 > 6 || changeX2 > 6)) {
            console.log("Left");
            waitTime = 2;
          } else if(xDif < -4 && (changeX1 < -6 || changeX2 < -6)) {
            console.log("Right");
            waitTime = 2;
          }

          // If Y difference is greater than four and change is greater than 6, trigger event
          if(yDif > 4 && (changeY1 > 6 || changeY2 > 6)) {
            console.log("Up");
            waitTime = 2;
          } else if(yDif < -4 && (changeY1 < -6 || changeY2 < -6)) {
            console.log("Down");
            waitTime = 2;
          }
        }
      }
    }

    // Steering wheel mode
    function modeLandscapeController() {

      // Use average of last three data points to smooth acceleration changes
      var average_x = Math.round(((accData.x[0] + accData.x[1] + accData.x[2]) / 3));
      var average_y = Math.round(((accData.y[0] + accData.y[1] + accData.y[2]) / 3));
      var average_z = Math.round(((accData.z[0] + accData.z[1] + accData.z[2]) / 3));

      // Send to server
      sendSnapshot(0, average_x, average_y, average_z);
    }

}());
