/* ---------------------------------- Global Variables ---------------------------------- */

var watchId;                      // used by accelerometer
var pollingAcc;                   // boolean to track accelerometer
var accCounter;                   // track how long we've been polling
var accData;                      // object to track acceleration data changes
var calibrationFactor;            // calibrate acceleration on startup
var currentView;                  // current view screen
var waitTime;                     // wait time between events

/* ---------------------------------- Accelerometer Data ---------------------------------- */

// Set polling to false when initializing
function initAcc() {
  pollingAcc = false;
}

function updateView(view) {
  currentView = view;
}

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

    accCounter = accCounter + 1;

}

// Error callback for getting acceleration
function accError() {
  console.log('Error checking accelerometer data');
}

function calibrateAcceleration() {
  calibrationFactor.x = (accData.x[0] + accData.x[1] + accData.x[2] + accData.x[3] + accData.x[4]) / 5;
  calibrationFactor.y = (accData.y[0] + accData.y[1] + accData.y[2] + accData.y[3] + accData.y[4]) / 5;
  calibrationFactor.z = (accData.z[0] + accData.z[1] + accData.z[2] + accData.z[3] + accData.z[4]) / 5;
}

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
      var changeX1 = accData.x[0] - accData.x[1];
      var changeX2 = accData.x[0] - accData.x[2];
      var changeY1 = accData.y[0] - accData.y[1];
      var changeY2 = accData.y[0] - accData.y[2];

      var xDif = accData.x[0] - calibrationFactor.x;
      var yDif = accData.y[0] - calibrationFactor.y;

      if(xDif > 4 && (changeX1 > 6 || changeX2 > 6)) {
        console.log("Left");
        waitTime = 2;
      } else if(xDif < -4 && (changeX1 < -6 || changeX2 < -6)) {
        console.log("Right");
        waitTime = 2;
      }

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
  if (accCounter < 5) {                                         // still calibrating
    console.log("Calibrating device, please wait...");
  } else {                                                      // done calibrating
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
  }
}
