<?php

$page['title'] = "My Profile";
session_start();
if(!isset($_SESSION['fbid'])){
    
    die("unauthenticated");
}
if($_POST['update'] == 1){
    require 'include/mysql.inc';
    $query = "UPDATE `db309grp16`.`users` SET `fbid` = '".$_SESSION['fbid']."', `fbpic` = '".$_SESSION['fbpic']."', `name` = '".$_SESSION['full_name']."' WHERE `device_uuid` LIKE '%\"" . $_POST['uuid'] . "\"%';";
    $result = mysql_query($query) or die('Invalid query: ' . mysql_error() . '<br>' . $query);
    mysql_close($mysql_link);
    $onload = "swal('Updated!', 'Your profile has been successfully updated!', 'success');";
} ?>
<html>
    <head>
        <title>GC-Profile</title>
        <?php require "include/head.inc"; ?>
    </head>
    <body onload="<?php echo $onload; ?>">
        <?php require "include/header.inc"; ?>
        <img class="img-circle img-responsive" src="<?php echo $_SESSION['fbpic']; ?>" alt="" style="width:200px;height:200px"><br>
        <b>Name</b>: <?php echo $_SESSION['full_name']; ?><br>
        <b>FBID</b>: <?php echo $_SESSION['fbid']; ?><br>
        <b>FBPIC</b>: <?php echo $_SESSION['fbpic']; ?><br>
        <b>Role</b>:  <?php echo $_SESSION['role']; ?><br><br>
        <form action="profile.php" method="POST">
            <input type="hidden" id="update" name="update" value="1" />
            <b>Pairing Code to add</b>:<br>
            <input type="text" id="uuid" name="uuid" placeholder="Pairing code" /><br>
            <input type="submit" value="Submit" />
        </form>
        <br><br>
        <a class="btn btn-danger" href="logout.php">Logout</a>
        <?php require "include/footer.inc"; ?>
    </body>
</html>
