<?php

$page['title'] = "My Profile";
session_start();
if(!isset($_SESSION['fbid'])){
    
    die("unauthenticated");
}
if($_POST['ugh'] == 1){
    require 'include/mysql.inc';
    $query = "UPDATE `db309grp16`.`users` SET `fbid` = '".$_SESSION['fbid']."', `fbpic` = '".$_SESSION['fbpic']."', `name` = '".$_SESSION['full_name']."' WHERE `device_uuid` LIKE '%\"" . $_POST['uuid'] . "\"%';";
    $result = mysql_query($query) or die('Invalid query: ' . mysql_error() . '<br>' . $query);
    mysql_close($mysql_link);
}
?>
<html>
    <head>
        <title>GC-Profile</title>
        <?php require "include/head.inc"; ?>
    </head>
    <body>
        <?php require "include/header.inc"; ?>
        <img class="img-circle img-responsive" src="<?php echo $_SESSION['fbpic']; ?>" alt="">
        Name: <?php echo $_SESSION['full_name']; ?><br>
        FBID: <?php echo $_SESSION['fbid']; ?><br>
        FBPIC: <?php echo $_SESSION['fbpic']; ?><br>
        <form action="profile.php" method="POST">
            <input type="hidden" id="ugh" name="ugh" value="1" />
            Device ID to add:<br>
            <input type="text" id="uuid" name="uuid" placeholder="Device uuid" /><br>
            <input type="submit" value="Submit" />
        </form>
        <br><br>
        <a class="btn btn-danger" href="logout.php">Logout</a>
        <?php require "include/footer.inc"; ?>
    </body>
</html>
