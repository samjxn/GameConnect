<?php

/* For making sure Dates/Times are correct. Will throw errors if removed */
date_default_timezone_set('US/Central');

session_start();
$link[] = "play.php";
$desc[] = "Play";

$link[] = "about.php";
$desc[] = "About";

$link[] = "download.php";
$desc[] = "Download";

$link[] = "highscores.php";
$desc[] = "Highscores";

$link[] = "service.php";
$desc[] = "Service Panel";
?>
<div id="sidebar">
    <nav class="navbar navbar-default">
        <div class="container-fluid">
            <div class="navbar-header">
                <a class="navbar-brand" href="/index.php" style="padding: 0px 10px 3px 10px;"><img src="/assets/img/navicon.png" height="40" alt="<?php echo $config['name_abbr']; ?>"></a>
                <button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-collapse">
                    <span class="icon-bar"></span>
                    <span class="icon-bar"></span>
                    <span class="icon-bar"></span>
                </button>
            </div>

            <div class="collapse navbar-collapse" id="bs-example-navbar-collapse-1">
                <ul class="nav navbar-nav">
                    <?php
                    for ($i = 0; isset($link[$i]); $i++) {
                        if (basename($_SERVER['PHP_SELF']) == $link[$i]) {
                            ?>
                            <li class="active"><a href="#"><?php echo $desc[$i]; ?></a></li>
                            <?php
                        } else {
                            ?>
                            <li><a href="<?php echo $link[$i]; ?>"><?php echo $desc[$i]; ?></a></li>
                            <?php
                        }
                    }
                    ?>

                </ul>
                <ul class="nav navbar-nav navbar-right">
                    <?php if(isset($_SESSION['fbid'])){ ?>
                    <ul class="nav navbar-nav navbar-right">
                        <li class="<?php echo (basename($_SERVER['PHP_SELF']) == "profile.php" ? "active" : ""); ?>"><a href="profile.php"><span class="glyphicon glyphicon-user" aria-hidden="true"></span>&nbsp;My Profile</a></li>
                    </ul>
                    <?php }else{ ?>
                    <li class="dropdown">
                        <a id="myaccount-dropdown" href="#" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false">
                            <i class="fa fa-sign-in" aria-hidden="true"></i>&nbsp;Sign In
                        </a>
                        <ul class="dropdown-menu">
                            <li><?php include 'include/loginbutton.php'; ?></li>
                        </ul>
                    </li>
                    <?php } ?>
                </ul>
            </div>
        </div>
    </nav>
</div>
<?php
if (isset($page['homepage_header']) && $page['homepage_header'] != null) {
    echo $page['homepage_header'];
}
if (isset($page['title'])) {
    ?>
    <div id="page-header" class="page-header" style="margin-top: 0; background-color: #fcfcfc">
        <div class="container">
            <div class="row">
                <div class="col-xs-12">
                    <h2 style="font-weight:bold;">
                        <?php echo $page['title']; ?>
                    </h2>
                </div>
            </div>
        </div>
    </div>
<?php } ?>
<div id="all-content" class="container mycontent">
    <div id="main-content">
