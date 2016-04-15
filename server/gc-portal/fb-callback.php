<?php
/* For making sure Dates/Times are correct. Will throw errors if removed */
date_default_timezone_set('US/Central');


$appID = "198299850533066";
$appSECRET = "554983e0b8e88fdc2005630386436efa";
session_start();

if(isset($_SESSION['no-redirect']))
    $_SESSION['debug'] = true;

require_once 'include/facebook-sdk/src/Facebook/autoload.php';

$fb = new Facebook\Facebook([
    'app_id' => $appID, // Replace {app-id} with your app id
    'app_secret' => $appSECRET,
    'default_graph_version' => 'v2.2',
        ]);

$helper = $fb->getRedirectLoginHelper();

try {
    $accessToken = $helper->getAccessToken();
} catch (Facebook\Exceptions\FacebookResponseException $e) {
    // When Graph returns an error
    echo 'Graph returned an error: ' . $e->getMessage() . '<br>Retry <a href="/login.php">here</a>';
    exit;
} catch (Facebook\Exceptions\FacebookSDKException $e) {
    // When validation fails or other local issues
    echo 'Facebook SDK returned an error: ' . $e->getMessage() . '<br>Retry <a href="/login.php">here</a>';
    exit;
}

if (!isset($accessToken)) {
    if ($helper->getError()) {
        header('HTTP/1.0 401 Unauthorized');
        echo "Error: " . $helper->getError() . "\n";
        echo "Error Code: " . $helper->getErrorCode() . "\n";
        echo "Error Reason: " . $helper->getErrorReason() . "\n";
        echo "Error Description: " . $helper->getErrorDescription() . "\n" . '<br>Retry <a href="/login.php">here</a>';
    } else {
        header('HTTP/1.0 400 Bad Request');
        echo 'Bad request' . '<br>Retry <a href="/login.php">here</a>';
    }
    exit;
}

// Logged in
if ($_SESSION['debug']) {
    echo '<h3>Access Token</h3>';
    var_dump($accessToken->getValue());
}

// The OAuth 2.0 client handler helps us manage access tokens
$oAuth2Client = $fb->getOAuth2Client();

// Get the access token metadata from /debug_token
$tokenMetadata = $oAuth2Client->debugToken($accessToken);
if ($_SESSION['debug']) {
    echo '<h3>Metadata</h3>';
    var_dump($tokenMetadata);
}

// Validation (these will throw FacebookSDKException's when they fail)
$tokenMetadata->validateAppId($appID); // Replace {app-id} with your app id
// If you know the user ID this access token belongs to, you can validate it here
//$tokenMetadata->validateUserId('123');
$tokenMetadata->validateExpiration();

if (!$accessToken->isLongLived()) {
    // Exchanges a short-lived access token for a long-lived one
    try {
        $accessToken = $oAuth2Client->getLongLivedAccessToken($accessToken);
    } catch (Facebook\Exceptions\FacebookSDKException $e) {
        echo "<p>Error getting long-lived access token: " . $helper->getMessage() . "</p>\n\n";
        exit;
    }
    if ($_SESSION['debug']) {
        echo '<h3>Long-lived</h3>';
        var_dump($accessToken->getValue());
    }
}

$_SESSION['fb_access_token'] = (string) $accessToken;


try {
    // Returns a `Facebook\FacebookResponse` object
    $response = $fb->get('/me?fields=id,name,email,first_name,last_name,gender,friends', $accessToken);
} catch (Facebook\Exceptions\FacebookResponseException $e) {
    echo 'Graph returned an error: ' . $e->getMessage();
    exit;
} catch (Facebook\Exceptions\FacebookSDKException $e) {
    echo 'Facebook SDK returned an error: ' . $e->getMessage() . '<br>Retry <a href="/login.php">here</a>';
    exit;
}

function gender($gen) {
    if ($gen == "male")
        return "m";
    if ($gen == "female")
        return "f";
    return "o";
}

$user = $response->getGraphUser();
if ($_SESSION['debug']) {
    echo '<br><br>Name: ' . $user['name'];
    echo '<br>ID: ' . $user['id'];
    echo '<br>Email: ' . $user['email'];
    echo '<br><br>';
    var_dump($user['friends']);
}
$_SESSION['full_name'] = $user['name'];
$_SESSION['email'] = $user['email'];
$_SESSION['fbid'] = $user['id'];
$_SESSION['first_name'] = $user['first_name'];
$_SESSION['last_name'] = $user['last_name'];
$_SESSION['gender'] = $user['gender'];
$_SESSION['fbpic'] = "https://graph.facebook.com/".$_SESSION['fbid'] ."/picture?width=200&height=200";

//require 'include/mysql.inc';
//
//$query = sprintf("SELECT * FROM `{$mysql_db}`.`users` WHERE `uid` = '%s'", mysql_real_escape_string($user['id']));
//$result = mysql_query($query) or die('Invalid query (A): ' . mysql_error());
//$data = mysql_fetch_assoc($result);
//
//if ($data['uid'] == $user['id']) {
//    
//$_SESSION['phone'] = $row['phone'];
//    if ($_SESSION['debug'])
//        echo "<br><b><p style=\"color: red\">exists</p></b>";
//}else {
//    $query = sprintf("INSERT INTO `{$mysql_db}`.`users` (`uid`, `first_name`, `last_name`, `email`, `gender`) VALUES ('%s', '%s', '%s', '%s', '%s');", mysql_real_escape_string($user['id']), mysql_real_escape_string($user['first_name']), mysql_real_escape_string($user['last_name']), mysql_real_escape_string($user['email']), gender($user['gender']));
//    $result = mysql_query($query) or die('Invalid query (B): ' . mysql_error());
//}
//$_SESSION['phone'] = $row['phone'];
//
//// User is logged in with a long-lived access token.
//// You can redirect them to a members-only page.
//if(!isset($_SESSION['no-redirect'])){
    header('Location: /profile.php');
//}
