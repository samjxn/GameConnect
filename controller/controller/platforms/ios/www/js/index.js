var app = {
    // Application Constructor
    initialize: function() {
        this.bindEvents();
    },

    // Bind Event Listeners
    bindEvents: function() {
        document.addEventListener('deviceready', this.onDeviceReady, false);
    },

    // deviceready Event Handler
    onDeviceReady: function() {
      app.renderHomeView();

      document.getElementById("debug").addEventListener("click", renderDebugView());
      document.addEventListener("backbutton", BackKeyDown, true);

      // Override default HTML alert with native dialog
      if (navigator.notification) {
        window.alert = function (message) {
          navigator.notification.alert(
            message,    // message
            null,       // callback
            "Workshop", // title
            'OK'        // buttonName
          );
        };
      }
    },

    // Update DOM on a Received Event
    receivedEvent: function(id) {
      var parentElement = document.getElementById(id);
      var listeningElement = parentElement.querySelector('.listening');
      var receivedElement = parentElement.querySelector('.received');

      listeningElement.setAttribute('style', 'display:none;');
      receivedElement.setAttribute('style', 'display:block;');

      console.log('Received Event: ' + id);
    },

    // Render the home view
    renderHomeView: function() {
      var html =
        "<div class='app'>" +
          "<h1>Pair With Computer</h1>" +
          "<form id='pairing' onSubmit='return pairRequest()'>" +
            "<input type='text' name='pairing_code' value='Enter the Code on Your Screen'><br>" +
            "<input type='submit' value='Pair' class='blink'>" +
          "</form>" +
          "<button type='button' class='button' id='debug'>Debug Mode</button>" +
        "</div>";
      document.getElementsByTagName("BODY")[0].html(html);
    },

    // Render the debug view
    renderDebugView: function() {
      var html =
        "<div class='app'>" +
          "<h1>Debug</h1><br><br>" +
          "<form id='testing' action='demo_form.asp'>" +
            "<input type='submit' value='Test Event'>" +
          "</form>" +
        "</div>";
      document.getElementsByTagName("BODY")[0].html(html);
    },

    // Handle the back button
    backKeyDown: function() {
     navigator.notification.alert("Welp");
   },

    // Pairing
    pairRequest: function() {
      // send data to server
      // handle function submit
    }

};

app.initialize();
