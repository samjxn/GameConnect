<?php

$appID = "198299850533066";
$appSECRET = "554983e0b8e88fdc2005630386436efa";
if (session_status() == PHP_SESSION_NONE) {
    session_start();
}
if (isset($_GET['nr']) || isset($_GET['noredirect'])) {
    $_SESSION['no-redirect'] = true;
}
//need to log in
require_once 'facebook-sdk/src/Facebook/autoload.php';


$fb = new Facebook\Facebook([
    'app_id' => $appID, // Replace {app-id} with your app id
    'app_secret' => $appSECRET,
    'default_graph_version' => 'v2.2',
        ]);

$helper = $fb->getRedirectLoginHelper();

$permissions = ['public_profile', 'email', 'user_friends']; // Optional permissions

$loginUrl = $helper->getLoginUrl('http://localhost:8080/fb-callback.php', $permissions);

echo '<a href="' . htmlspecialchars($loginUrl) . '"><img src="https://scontent-ord1-1.xx.fbcdn.net/hphotos-xaf1/t39.2178-6/851579_209602122530903_1060396115_n.png" alt="Log in with Facebook!"></img></a>';
