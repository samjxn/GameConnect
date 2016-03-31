(function () {

    /* ---------------------------------- Local Variables ---------------------------------- */

    var currentView;                  // track what view is rendered
    var previousView;                 // used for back button functionality
    var webSocket;                    // websocket connection
    var groupId;                      // assigned by server
    var clientId;                     // assigned by server
    var timeout;                      // for keeping track of time
    var gamesList;                    // list of games recieved from server

    /* --------------------------------- Device Ready -------------------------------- */
    document.addEventListener('deviceready', init, false);

    function init() {

      // Clear global variables
      currentView = undefined;
      webSocket = undefined;
      groupId = undefined;
      clientId = undefined;
      gamesList = [];
      watchId = undefined;
      initAcc();

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
          case "context-list":
            updateGameList(data);
            renderGameSelectView();
            break;
          case "game-mode":
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
        console.log('WebSocket closed, resetting application in 5 seconds');
        timeout = setTimeout(reset, 5000);     // set timeout 5 seconds;
      };

    }

    /* ---------------------------------- Local Functions ---------------------------------- */

    // Back Key Press Event Handler
    function onBackKeyDown() {
      stopAcc();
      switch(currentView) {
        case "home":
          navigator.app.exitApp();
          break;
        case "debug":
          renderHomeView();
          break;
        case "select":
          navigator.notification.confirm("Are you sure you want to leave this session and return to the pairing screen?", reset, "Confirm", ["Yes", "Cancel"]);
          break;
        case "portrait":
          if(previousView === "debug") {
            renderDebugView();
          } else {
            navigator.notification.confirm("Are you sure you want to end the game?", renderGameSelectView, "End Game", ["Yes", "Cancel"]);
          }
          break;
        case "landscape":
          if(previousView === "debug") {
            renderDebugView();
          } else {
            navigator.notification.confirm("Are you sure you want to end the game?", renderGameSelectView, "End Game", ["Yes", "Cancel"]);
          }
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
      var data = {  "groupId": null,
                    "clientId": null,
                    "ping": null,
                    "sourceType" : "controller",
                    "messageType" : "join-group",
                    "content" :
                    {
                      "groupingCode" : codeString
                    }
      }
      console.log("Sending data to server:");
      console.log('%c' + JSON.stringify(data), 'color: #0080FF');
      timeout = setTimeout(pairTimeout, 30000);     // set timeout 30 seconds

      webSocket.send(JSON.stringify(data));
    }

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
                    "ping": null,
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
      document.getElementById('message').style.color = '#DC0000';
      document.getElementById('message').className = "blink";
      document.getElementById('playButton').disabled = true;
      timeout = setTimeout(selectTimeout, 30000);               // set timeout 30 seconds

      webSocket.send(JSON.stringify(data));
    }

    function selectTimeout() {
      document.getElementById('playButton').disabled = false;
      document.getElementById('message').innerHTML = "Server Timed Out";
      document.getElementById('message').style.color = '#4CAF50';
    }

    // Test event for debug page
    function testEvent() {
      var text = document.getElementById('debugInput').value;
      var data = {  "groupId": groupId,
                    "clientId": clientId,
                    "ping": null,
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

    function buttonPressed(button) {
      var a = false;
      var b = false;
      var d = 0;

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

      var data = {  "groupId": groupId,
                    "clientId": clientId,
                    "ping": null,
                    "sourceType":"controller",
                    "messageType": "controller-snapshot",
                    "content":
                    {
                      "d-pad-input": d,
                      "a-pressed": a,
                      "b-pressed": b
                    }
      }
      webSocket.send(JSON.stringify(data));
      console.log(button + " button pressed");
      console.log('%c' + JSON.stringify(data), 'color: #0080FF');
    }

    /* ---------------------------------- WebSocket Response Handlers ---------------------------------- */

    // After receiving a Join Group messsage from the server
    function joinGroup(data) {
      clearTimeout(timeout);
      if(data.content.groupingApproved === true) {
        console.log("Successfully joined group " + data.groupId);
        groupId = data.groupId;
        clientId = data.content.clientId;
        document.getElementById('message').innerHTML = "Success";
        document.getElementById('pairButton').className = "button";
        document.getElementById('message').style.color = '##4CAF50';

        // temp data for demo
        /*var temp_data = '{  "content":' +
                      '{' +
                        '"games": ["snake", "jetpack hero", "potato hunter", "flappy bird", "airplane", "chess", "checkers", "banana phone"]' +
                      '}' +
        '}';*/

        //gameList(JSON.parse(temp_data));

      } else {
        console.log("Failed to join group");
        document.getElementById('message').innerHTML = "Failed to Join Group";
        document.getElementById('pairButton').className = "button";
        document.getElementById('message').style.color = '#DC0000';
        document.getElementById('pairInput').value = "";
      }
    }

    // Server has sent list of games
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
          toggleAcc();
          break;
        case 3:
          renderLandscapeControllerView();
          break;
        case 4:
          renderLandscapeControllerView();
          toggleAcc();
          break;
        case 5:
          renderDebugView();
            break;
        default:
          console.log("Game mode not recognized");
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
      stopAcc();
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
      updateView(currentView);
      console.log('Home view rendered');
    }

    // Render the Debug View
    function renderDebugView() {
      stopAcc();
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
      document.getElementById('accButton').onclick = toggleAcc;
      document.getElementById('portraitButton').onclick = renderPortraitControllerView;
      document.getElementById('landscapeButton').onclick = renderLandscapeControllerView;

      // Update views and log
      previousView = currentView;
      currentView = "debug";
      updateView(currentView);
      console.log('Debug view rendered');
    }

    // Render the Game Select View
    function renderGameSelectView() {
      stopAcc();

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
      updateView(currentView);
      console.log('Game Select view rendered');
    }

    // Render the Portrait Game Contoller view with Motion Remote (unfinished)
    function renderPortraitControllerView() {
      stopAcc();
      var html =
        "<h1>Motion Remote</h1>";
      document.getElementById('application').innerHTML = html;

      // Update views and log
      previousView = currentView;
      currentView = "portrait";
      updateView(currentView);
      console.log('Portrait game controller view rendered');
    }

    // Render the Landscape Game Controller view with Steering Wheel
    function renderLandscapeControllerView() {
      stopAcc();
      var html =
        "<button type='button' class='controllerButton' id='controllerButtonA'>A</button>" +
        "<button type='button' class='controllerButton' id='controllerButtonB'>B</button>" +
        "<button type='button' class='controllerButton' id='controllerButtonW'>&#8592</button>" +
        "<button type='button' class='controllerButton' id='controllerButtonS'>&#8595</button>" +
        "<button type='button' class='controllerButton' id='controllerButtonN'>&#8593</button>" +
        "<button type='button' class='controllerButton' id='controllerButtonE'>&#8594</button>";
      document.getElementById('application').innerHTML = html;
      document.getElementById('controllerButtonA').onclick = function(){ buttonPressed("a"); };
      document.getElementById('controllerButtonB').onclick = function(){ buttonPressed("b"); };
      document.getElementById('controllerButtonW').onclick = function(){ buttonPressed("4"); };
      document.getElementById('controllerButtonS').onclick = function(){ buttonPressed("3"); };
      document.getElementById('controllerButtonN').onclick = function(){ buttonPressed("1"); };
      document.getElementById('controllerButtonE').onclick = function(){ buttonPressed("2"); };

      // Update views and log
      previousView = currentView;
      currentView = "landscape";
      updateView(currentView);
      console.log('Landscape game controller view rendered');
    }

}());
