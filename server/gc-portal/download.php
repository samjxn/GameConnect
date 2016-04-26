<?php
$page['title'] = "Download Game Connect";
?>
<html>
    <head>
        <title>Download</title>
        <?php require "include/head.inc"; ?>
        <script>
            function appleWarning() {
                swal({   
                    title: "Warning",   
                    text: "Due to Apple\'s regulations and requirements, our iPhone app may not be runnable on your device as it is not approved by the App Store (yet). Sorry!",   
                    type: "warning",   
                    showCancelButton: true,   
                    confirmButtonColor: "#00cc66",   
                    confirmButtonText: "Okay, lets try anyway!",   
                    closeOnConfirm: false }, 
                function(){   
                    window.location = "/download/GC-iPhone.app.zip" });            }
        </script>
    </head>
    <body>
        <?php require "include/header.inc"; ?>
            <div class="row" style="text-align: center; ">
                <div class="col-md-6">
                    <a href="/download/GC-Android.apk"><img src="http://storage.googleapis.com/ix_choosemuse/uploads/2016/02/android-logo.png" alt="apple" style="width:200px; height:200px" /></a>
                </div>
                <div class="col-md-6">
                    <a style="cursor: pointer" onclick="appleWarning();"><img src="https://tctechcrunch2011.files.wordpress.com/2014/06/apple_topic.png?w=400" alt="apple" style="width:200px; height:200px" /></a>
                </div>
            </div>
            <br>
            <div class="row">
                <h3>You only need to download GameConnect on your mobile device that you plan on using as your controller.  Just click on the "Play" tab to open it up on your computer!</h3>
            </div>
        <?php require "include/footer.inc"; ?>
    </body>
</html>
