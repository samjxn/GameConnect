# GameConnect Dart (PC) Client

## Up and running

I'm not sure if anyone will need this...
but in the event you need to run this project locally, here's what you do:

### Install dart
If you haven't installed it already, you're definitely going to need the dart sdk.   In the terminal:  
`brew tap dart-lang/dart`  
`$ brew install dart --with-content-shell --with-dartium`

If you need to install brew,  [get it here](http://brew.sh/)
### Get project dependencies
From inside the `G16_ProjectDir/client/` directory, enter the following into the terminal:  `$ pub get`  
It should be obvious from the output whether or not that worked
### Serve it.
To run the project locally, do one of the following:

#### Serve via command line
From inside the `G16_ProjectDir/client/` directory, enter the following into the terminal:  `$ pub serve`  
The output should look like this:
```
Loading source assets... 
Loading sass transformers... 
Serving client web on http://localhost:8080
Build completed successfully
```
If you see this ^, head on over to http://localhost:8080 to see your locally running client

#### Serve via IDE
Import the project to your favorite dart-supporting IDE.  Open up `client/web/index.html` and run that.  
If your IDE functions like IntelliJ, the project should have been served on localhost (under a different port than 8080) and Chromium should have opened to display the client.


