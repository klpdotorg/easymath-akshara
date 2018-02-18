<?php

/**
 * Service API:  register
 * File name: register.php
 * Author: Suresh Kodoor
 * 
 * JSON Payload:
 * {
 * "name:"",
 * "phone":"",
 * "age":"",
 * "grade":"",
 * "schooltype:"1/0", 
 * "geo":"lat,long"
 * "language":""
 * "gender":"B/G",
 * "deviceid":""
 * "avatarpic":"picture image as base64 encoded string"
 * }
 *    
 * JSON Response:
 * {
 *  "status":"failed/success",
 *  "description":"reason for failure/access token on success"
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

        $childname  = $data->{'name'};
        $phone      = $data->{'phone'};
        $age        = $data->{'age'};
        $grade      = $data->{'grade'};
        $schooltype = $data->{'schooltype'};
        $geo        = $data->{'geo'};
        $language   = $data->{'language'};
        $gender     = $data->{'gender'};
        $deviceid   = $data->{'deviceid'};
        $avatarpic  = $data->{'avatarpic'}; // The avatar image file as a base64 encoded string
  
        if($childname && $phone && $grade && $language){
        
           $childexists = checkIfNameAndPhoneRegistered($childname, $phone); 
           if($childexists) {
               $responsedata = array(
                   'status' => "failed",
                   'description' => "Given combination of name and phone number ($childname, $phone) is already registered."
               );
               $em = new exceptionMgr(" ");
               $em->logInfo("register: Error: Given combination of name and phone number ($childname, $phone) is already registered.");
           }
           else {
               
               $objchild = new child();
           
               $objchild->setChildName($childname);
               $objchild->setPhone($phone);
               $objchild->setAge($age);
               $objchild->setGradeName($grade);
               $objchild->setSchoolTypeId($schooltype);
               $objchild->setGeo($geo);
               $objchild->setLanguageName($language);
               $objchild->setGender($gender);
               
               $rtn = registerNewChild($objchild);
               
               //For testing saveavatarpic function
               //$contentstr = file_get_contents("testpicture.png");
               //$base64imagestring = base64_encode($contentstr);
               //$avatarpic = $base64imagestring;
               
               if($rtn) {
                   
                  $childid = getChildIdByNameAndPhone($childname,$phone);
                   
                  if(($avatarpic == null) || ($avatarpic == '')) {
                      $avatarmsg = "Recieved empty string for avatar picture though.";
                      $em = new exceptionMgr(" ");
                      $em->logInfo("register: Recieved empty string for avatar picture.");
                  }
                  else {
                      
                      $rtnflg  = saveAvatarPic($avatarpic, $childid);
                      if(!$rtnflg) {
                          $avatarmsg = "Failed to save the avatar picture though.";
                          $em = new exceptionMgr(" ");
                          $em->logInfo("register: Failed to save the avatar picture though."); 
                      }
                      else {
                          $avatarmsg = " ";
                      }
                  }
                  
                  // Return the access_token on registration completion (considered as logged-in)
                  $access_token = createAccessToken();
                  $created_datetime = date('Y-m-d H:i:s') ;
                  saveNewAccessTokenForChildForDevice($childid,$deviceid,$access_token,$created_datetime);
                  
                  $responsedata = array(
                    'status' => "success",
                    'description' => $access_token
                  );
               }
               else {
                   $responsedata = array(
                       'status' => "failed",
                       'description' => "register failed. Please check the input parameters passed."
                   );
                   $em = new exceptionMgr(" ");
                   $em->logInfo("register: Error: registerNewChild() failed. Please check the input parameters passed.");
               }
           }
        }
        else {
        
            $responsedata = array(
                'status' => "failed",
                'description' => "Input parameters missing."
            );
            $em = new exceptionMgr(" ");
            $em->logInfo("register: Error: Input parameters missing."); 
        }
    }
    else {
        $responsedata = array(
            'status' => "failed",
            'description' => "Received no input JSON data."
        );
        $em = new exceptionMgr(" ");
        $em->logInfo("register: Error: Received no input JSON data."); 
    }
    
    header('Content-type: application/json');
    echo json_encode($responsedata);
    
?>    