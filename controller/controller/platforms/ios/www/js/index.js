(function () {

    /* ---------------------------------- Local Variables ---------------------------------- */
    var temp;


    /* --------------------------------- Event Registration -------------------------------- */
    document.addEventListener('deviceready', function () {
      app.renderHomeView();
    }, false);

    /* ---------------------------------- Local Functions ---------------------------------- */

    // Pairing Request Event Handler
    function pairRequest() {
      // do stuff
    }


    /* ---------------------------------- Rendering Views ---------------------------------- */

    // Render the home view
    function renderHomeView() {
      var html =
        "<h1>Pair With Computer</h1>" +
        "<form id='pairing' onSubmit='return pairRequest()'>" +
          "<input type='text' name='pairing_code' value='Enter the Code on Your Screen'><br>" +
          "<input type='submit' value='Pair' class='blink'>" +
        "</form>" +
        "<button type='button' class='button' id='debug'>Debug Mode</button>";
      document.getElementById('application').innerHTML = html;
      document.getElementById("debug").click(renderDebugView());
      console.log('Rendering Home View');
    }

    // Render the debug view
    function renderDebugView() {
      var html =
        "<h1>Debug</h1><br><br>" +
        "<form id='testing' action='demo_form.asp'>" +
          "<input type='submit' value='Test Event'>" +
        "</form>";
      document.getElementById('application').innerHTML = html;
      console.log('Rendering Debug View');
    }

}());
