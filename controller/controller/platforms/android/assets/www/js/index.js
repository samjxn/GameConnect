(function () {

    /* ---------------------------------- Local Variables ---------------------------------- */
    var viewStack = new Array();

    /* --------------------------------- Event Registration -------------------------------- */
    document.addEventListener('deviceready', function () {
      document.addEventListener("backbutton", onBackKeyDown, false);
      renderHomeView();
    }, false);

    /* ---------------------------------- Local Functions ---------------------------------- */

    // Back Key Press Event Handler
    function onBackKeyDown() {
      renderHomeView();
      /*var view;
      if(viewStack.length == 0) {
        // do nothing
      } else {
        view = viewStack.pop();
        if (pop == "debug") {
          renderDebugView();
        } else {
          renderHomeView();
        }
      }*/
    }

    // Pairing Request Event Handler
    function pairRequest() {
      // do stuff
    }


    /* ---------------------------------- Rendering Views ---------------------------------- */

    // Render the Home View
    function renderHomeView() {
      var html =
        "<h1>Pair With Computer</h1>" +
        "<form id='pairing' onSubmit='return pairRequest()'>" +
          "<input type='text' name='pairing_code' value='Enter the Code on Your Screen'><br>" +
          "<input type='submit' value='Pair' class='blink'>" +
        "</form>" +
        "<button type='button' class='button' id='debug'>Debug Mode</button>";
      document.getElementById('application').innerHTML = html;
      document.getElementById("debug").onclick = renderDebugView;
      viewStack.push('home');
      console.log('Rendering Home View');
    }

    // Render the Debug View
    function renderDebugView() {
      var html =
        "<h1>Debug</h1><br><br>" +
        "<form id='testing' action='demo_form.asp'>" +
          "<input type='submit' value='Test Event'>" +
        "</form>";
      document.getElementById('application').innerHTML = html;
      //viewStack.push('debug');
      console.log('Rendering Debug View');
    }

}());
