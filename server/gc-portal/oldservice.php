<?php

?>
<html>
    <head>
        <title>GC-SERVICE</title>
        <?php require "include/head.inc"; ?>      
        <script type="text/javascript">
            function rep() {
            var clientID = document.getElementById("clientID").value;
            var groupID = document.getElementById("groupID").value;
            document.getElementById("messageinput").value = (document.getElementById("messageinput").value.replace("/opengroup", "{\n\
    \"groupId\": null,\n\
    \"sourceType\":\"pc-client\",\n\
    \"messageType\": \"open-new-group\",\n\
    \"content\":\n\
        {\n\
        }\n\
}").replace("/quitgame", "{\n\
    \"groupId\": " + groupID + ",\n\
    \"clientId\": \"" + clientID + "\",\n\
    \"sourceType\":\"controller\",\n\
    \"messageType\":\"quit-game\",\n\
    \"content\":\n\
        {\n\
        }\n\
}").replace("/setcontext", "{\n\
    \"groupId\": " + groupID + ",\n\
    \"clientId\": \"" + clientID + "\",\n\
    \"sourceType\":\"controller\",\n\
    \"messageType\":\"set-context\",\n\
    \"content\":\n\
        {\n\
            \"contextName\":\"snake\"\n\
        }\n\
}").replace("/joingroup", "{\n\
    \"clientId\": \"" + clientID + "\",\n\
    \"sourceType\":\"controller\",\n\
    \"messageType\":\"join-group\",\n\
    \"content\":\n\
        {\n\
            \"groupingCode\":\"" + groupID + "\",\n\
            \"name\":\"david\",\n\
            \"uuid\":\"12\"\n\
        }\n\
}").replace("/chatmsg", "{\n\
    \"groupId\": " + groupID + ",\n\
    \"clientId\": \"" + clientID + "\",\n\
    \"sourceType\":\"controller\",\n\
    \"messageType\":\"chat-msg\",\n\
    \"content\":\n\
        {\n\
            \"message\":\"\"\n\
        }\n\
}").replace("/disconnect", "{\n\
    \"groupId\": " + groupID + ",\n\
    \"clientId\": \"" + clientID + "\",\n\
    \"sourceType\":\"controller\",\n\
    \"messageType\":\"disconnect\"\n\
}"));
}

        function repMe(idk){
            document.getElementById("messageinput").value = idk;
            rep();
        }
        
    function loadMe(){
        document.getElementById("messages").style.height = (window.innerHeight - 305) + "px;";
        document.getElementById('messages').setAttribute("style","overflow-y:scroll;height: "+(window.innerHeight - 305) + "px;");
    }
        </script>
    </head>
    <body>
        <?php require "include/header.inc"; ?>
        <div  style="font-family: monospace" onload="loadMe();">
        <div style="font-weight: bold">
            Group: <input id="groupID" type="number" value="0" max="99999" min="0" style="width: 50px" />&nbsp; ClientID: <input id="clientID" type="text" value="0" style="width: 240px;font-family: monospace;" /> <br>
            <a onclick="repMe('/opengroup')">/opengroup</a> <a onclick="repMe('/joingroup')">/joingroup</a> <a onclick="repMe('/setcontext')">/setcontext</a> <a onclick="repMe('/quitgame')">/quitgame</a> <a onclick="repMe('/chatmsg')">/chatmsg</a> <a onclick="repMe('/disconnect')">/disconnect</a><br>
        </div>
        <div>
            <textarea id="messageinput" style="width:400px; height:200px" onchange="rep()"></textarea>
        </div>
        <div style="font-weight: bold">
            <button type="button" onclick="openSocket();" >Open</button>
            <button type="button" onclick="send();" >Send</button>
            <button type="button" onclick="closeSocket();" >Close</button><br>
            <span style="color:green">sent</span> <span>received</span> <span style="color:red">error</span><br>
            ---
        </div>
        <!-- Server responses get written here -->
        <div id="messages" style="overflow-y: scroll;"></div>
        </div>

        <!-- Script to utilise the WebSocket -->
        <script type="text/javascript">

    var webSocket;
    var messages = document.getElementById("messages");
    function openSocket(){
        // Ensures only one connection is open at a time
        if (webSocket !== undefined && webSocket.readyState !== WebSocket.CLOSED){
        writeResponse("<span style=\"color:red\">WebSocket is already opened.</span>");
        return;
        }
        // Create a new instance of the websocket
        webSocket = new WebSocket("ws://proj-309-16.cs.iastate.edu:8080/SocketHandler/gameconnect");
        /**
         * Binds functions to the listeners for the websocket.
         */
        webSocket.onopen = function(event){
            // For reasons I can't determine, onopen gets called twice
            // and the first time event.data is undefined.
            // Leave a comment if you know the answer.
            if (event.data === undefined)
                    return;
            writeResponse("<span style=\"color:red\">Connection opened</span>");

            writeResponse(event.data);
        };
        webSocket.onmessage = function(event){
            writeResponse(event.data);
            var stuff = JSON.parse(event.data);
            if(stuff != null && stuff.content != null && stuff.content.clientId != null){
                document.getElementById("clientID").value = stuff.content.clientId;
            }
            if(stuff != null && stuff.content != null && stuff.content.groupingCode != null){
                document.getElementById("groupID").value = stuff.content.groupingCode;
            }
        };
        webSocket.onclose = function(event){
            writeResponse("<span style=\"color:red\">Connection closed</span>");
        };
    }

    /**
     * Sends the value of the text input to the server
     */
    function send(){
        var text = document.getElementById("messageinput").value;
        webSocket.send(text);
        writeResponse("<span style=\"color:green\">" + text + "</span>");
    }

    function closeSocket(){
        webSocket.close();
    }

    function writeResponse(text){
        //write new line to div
        messages.innerHTML += "<br/>" + text;

        //scroll to bottom of div
        messages.scrollTop = messages.scrollHeight;
    }
        </script>
        <?php require "include/footer.inc"; ?>
    </body>
</html>
