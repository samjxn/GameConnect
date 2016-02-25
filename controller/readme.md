# Getting Set Up
Here are some setup guidelines for building and running the mobile controller using the Cordova Command-Line Interface.

### Step 1: Install node.js and Git
Cordova uses the Node.js package system, so you will need Node.js in order to install Cordova and our Cordova plugins. Follow the instructions on the Node.js website to get that set up. You may need to update your PATH variable in order to use `node` and `npm` on command line.

Cordova also uses Git for some behind-the-scenes download operations, but you should already have Git working.

### Step 2: Install Cordova
Once you have Node.js and Git set up, install the Cordova Command-Line Interface using the `npm` utility in Node.js. Run the following command, and note that you made need to type in your root password.
```
sudo npm install -g cordova
```

### Step 3: Create a New Project
Go to whatever directory you want your mobile apps to be built in, and run the following command to create a new Cordova project.
```
cordova create controller io.cordova.hellocordova controller
```

This might take a minute as it generates a bunch of files. Once that is done, go to the directory. You should see several folders, including `www` and `res` folders. Replace those two folders with the ones from our Git. These contain all of our code for the mobile controller.

Also note that `io.cordova.hellocordova` is just the default reverse domain identifier, so we can change that to whatever identifier we give our project.

### Step 4: Install the Android SDK and iOS SDK
In order to build our application for Android and iOS, you must have each SDK set up and in your PATH variable. Instructions for this should be on each of their respective websites. If you are planning on testing with an emulator, you'll need to download that too. Several are included with Android Studio (for Android) and Xcode (for iOS). Once you have those set up, we need to add each platform to our project. From within the project directory, run the following commands.
```
cordova platform add android
cordova platform add ios
```

You can check which platforms are in your current project with this.
```
cordova platforms ls
```

### Step 5: Install the Device Motion plugin
Run the following command to install the device motion plugin, which is used to access accelerometer data.
```
cordova plugin add cordova-plugin-device-motion
```

### Step 6: Build and Run
Now you are ready to build and run the mobile controller app for Android and iOS. You must have either an emulator or mobile phone connected in order for the app to run.

This will build all platforms.
```
cordova build
```

You can also build specific platforms.
```
cordova build android
cordova build ios
```

To run the app, use the following. Also note that running triggers a new build, so you can skip the above build commands and just use this for testing. The run command will default to any connected device, so if your mobile phone is connected and USB debugging is set up, the application will deploy to your phone. If no phone is set up, it will default to the default emulator.
```
cordova run android
cordova run ios
```

You can also use the following to deploy to an emulator.
```
cordova emulate android
cordova emulate ios
```
More information for building and running can be found on the Cordova website. Another useful tool is Google Chrome's Remote WebView Debugging. If you are testing on your mobile phone and it is connected by USB, you can view the console and other debugging tools by typing `chrome://inspect` into Google Chrome's url bar and selecting the connected device by hitting `inspect`.
