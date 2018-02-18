<?php

/**
 * Service API:  updateprofile
 * File name: updateprofile.php
 * Author: Suresh Kodoor
 * 
 * JSON Payload:
 * {
 * "access_token":"",
 * "phone":"",
 * "age":"",
 * "grade":"",
 * "schooltype:"1/0", 
 * "language":""
 * "avatarpic":"picture image as base64 encoded string"
 * }
 *    
 * JSON Response:
 * {
 *  "status":"failed/success",
 *  "description":"reason for failure"
 * }
 */
    session_start();
    
    $appbasedirorg = dirname(__FILE__);

    $appbasedir = substr($appbasedirorg,0,-4); // remove the directory name api
    $_SESSION['ABSAPP_BASE_DIR'] = $appbasedir;

    $appconfigfile = $appbasedir."/config/appconfig.php";
    $_SESSION['ABSAPP_CONFIG_FILE'] = $appconfigfile;
  
    $dbconfigfile = $appbasedir."/config/dbconfig.php";
    $_SESSION['ABSAPP_DB_CONFIG_FILE'] = $dbconfigfile;
    
    $querystr = $_SERVER['QUERY_STRING']; 
    
    $hosturl = "http://".$_SERVER['HTTP_HOST'];
    $requesturi = $_SERVER['REQUEST_URI']; 
    $lenuri = strripos($requesturi,"/",0);  // find the position of last occurance of '/'
    $appurl = substr($requesturi,0,$lenuri-4); // 4 chars removed as the uri will contain 'api' directory also
  
    $appbaseurl = $hosturl.$appurl."/"; 
    $_SESSION['ABSAPP_BASE_URL'] = $appbaseurl;
    
    require_once($_SESSION['ABSAPP_BASE_DIR']."/servicefunctions/servicefunctions.php");
   
    // get posted data
    // $jsonstring = $_GET['json']; // use this _GET to test directly from the browser http://.../register.php?json={"name:"","phone":"",..}
    // Using file_get_contents instead to get the content to a string. 
    // Note: json_decode works only with UTF-8 encoded strings. 
    // So, if not UTF-8 encoded, use the function  $jsonstring = utf8_encode($jsonstring) before calling json_decode
    $jsonstring = file_get_contents("php://input");

    $data = json_decode($jsonstring); 
    

    if($data) {

        $access_token = $data->{'access_token'};
        $phone        = $data->{'phone'};
        $age          = $data->{'age'};
        $grade        = $data->{'grade'};
        $schooltype   = $data->{'schooltype'};
        $language     = $data->{'language'};
        $avatarpic    = $data->{'avatarpic'}; // The avatar image file as a base64 encoded string
  
        if(($access_token != null) || ($access_token != '')) {
        
           $tokenvalid = checkIfValidAccessToken($access_token);
           if(!$tokenvalid) {
               $responsedata = array(
                   'status' => "failed",
                   'description' => "Invalid access token."
               );
               $em = new exceptionMgr(" ");
               $em->logInfo("updateprofile: Error: Invalid access token: ".$access_token);
           }
           else {
               
               // $childid = getChildIdByAccessToken($access_token);
               $objChild = getChildByAccessToken($access_token); // get the current values so that update needs to be done only for those fields for which valid values are passed
               
               if(!$objChild) {
                   $responsedata = array(
                       'status' => "failed",
                       'description' => "Failed to fetch Child for the given access_token"
                   );
                   $em = new exceptionMgr(" ");
                   $em->logInfo("updateprofile: Error: Failed to fetch Child for the given access_token: ".$access_token);
               }
               else {
                    // $objChild = new child();
                    // $objChild->setChildId($childid);
                    if(($phone != null) || ($phone != ''))
                        $objChild->setPhone($phone);
                    if(($age != null) || ($age != ''))
                        $objChild->setAge($age);
                    if(($grade != null) || ($grade != ''))
                        $objChild->setGradeName($grade);
                    if(($schooltype != null) || ($schooltype != ''))
                        $objChild->setSchoolTypeId($schooltype);
                    if(($language != null) || ($language != ''))
                        $objChild->setLanguageName($language);

                    $rtn = updateProfile($objChild);
               
      
                    if($rtn) {
        
                        if(($avatarpic == null) || ($avatarpic == '')) {
                            $avatarmsg = "Recieved empty string for avatar picture though.";
                            $em = new exceptionMgr(" ");
                            $em->logInfo("updateprofile: Received empty string for avatarpic.");
                        }
                        else {
                      
                            $rtnflg  = saveAvatarPic($avatarpic, $childid);
                            if(!$rtnflg) {
                                $avatarmsg = "Failed to save the avatar picture though.";
                                $em = new exceptionMgr(" ");
                                $em->logInfo("updateprofile: Error. Failed to save the avatar picture.");
                            }
                            else {
                                $avatarmsg = " ";
                            }
                        }
                     }
                  
                     $responsedata = array(
                       'status' => "success",
                       'description' => " ".$avatarmsg
                     );
                 }
           }
        }
        else {
        
            $responsedata = array(
                'status' => "failed",
                'description' => "access_token is missing."
            );
            $em = new exceptionMgr(" ");
            $em->logInfo("updateprofile: Error. access token is missing.");
        }
    }
    else {
        $responsedata = array(
            'status' => "failed",
            'description' => "Received no input JSON data."
        );
        $em = new exceptionMgr(" ");
        $em->logInfo("updateprofile: Error. Received no input JSON data.");
    }
    
    header('Content-type: application/json');
    echo json_encode($responsedata);
    
?>    