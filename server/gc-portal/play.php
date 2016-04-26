<?php

?>
<html>
    <head>
        <title>Play Game Connect</title>
        <?php require "include/head.inc"; ?>
        <script async src="packages/react/react.js"></script>
        <script async type="application/dart" src="client.dart"></script>
        <script async src="packages/browser/dart.js"></script>
        <link rel="stylesheet" href="game_connect.css">
        <script>
        function resizeme(){
            if(window.innerWidth < 1000){
                swal("Warning", "It is recommended that you use a browser width greater than 1000px (so you can actually see the entire game.","warning");
            }
        }
        </script>
    </head>
    <body onload="resizeme()" onresize="resizeme()">
        <?php require "include/header.inc"; ?>
         <div id="content-container">App Goes Here.</div>
        <?php require "include/footer.inc"; ?>
    </body>
</html>