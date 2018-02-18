<?php

/**
 * Service API:  txabsgameplaydetail
 * Purpose: Sync the 'gameplaydetail' data to the ABS 
 * File name: txabsgameplaydetail.php
 * Author: Suresh Kodoor
 * 
 * JSON Payload:
 * [                       // A JSON array of 'gameplaydetail' JSON objects (this will allow to send multiple 'gameplaydetail' objects in one shot, especially while syncing offline data together)
 * {
 *    "objid":"",          // Identifier for this object/packet (can check the 'response' with this 'objid' to see if this object/packet is valid and successfully received)
 *    "access_token":"",
 *    "id_game_play":"",
 *    "id_question":"",
 *    "pass":"",
 *    "time2answer":"",
 *    "attempts":"",
 *    "date_time_submission":""
 * },
 * .
 * .
 * .
 * {
 *    "objid":"", 
 *    "access_token":"",
 *    "id_game_play":"",
 *    "id_question":"",
 *    "pass":"",
 *    "time2answer":"",
 *    "attempts":"",
 *    "date_time_submission":""
 * }
 * ]
 *    
 * JSON Response:         // A JSON array of Response JSON objects (each response object corresponds to the update status of individual telemetry data object) 
 * [
 * {
 *  "objid":"", 
 *  "status":"failed/success",
 *  "description":"reason for failure/success message"
 * },
 * .
 * .
 * .
 * {
 *  "objid":"", 
 *  "status":"failed/success",
 *  "description":"reason for failure/success message"
 * }
 * 
 * ]
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
    // $jsonstring = $_GET['json'];
    // Using file_get_contents instead to get the content to a string. 
    // Note: json_decode works only with UTF-8 encoded strings. 
    // So, if not UTF-8 encoded, use the function  $jsonstring = utf8_encode($jsonstring) before calling json_decode
    $jsonstring = file_get_contents("php://input");
    
    $jsondata_array = json_decode($jsonstring); 
    
    $responsedata_array = array();
    
    if(count($jsondata_array,1) == 0) {
   
        $responsedata = array(
            'objid' => '',
            'status' => "failed",
            'description' => "Received no input JSON data."
        );
        $em = new exceptionMgr(" ");
        $em->logInfo("txabsgameplaydetail: Error: Received no input JSON data."); 
    }
    else {
        
        foreach($jsondata_array as $data) {
     
            if($data) {
                $objid                 = $data->{'objid'};  
                $access_token          = $data->{'access_token'};
                $id_game_play          = $data->{'id_game_play'};
                $id_question           = $data->{'id_question'};
                $pass                  = $data->{'pass'};
                $time2answer           = $data->{'time2answer'};
                $attempts              = $data->{'attempts'};
                $date_time_submission  = $data->{'date_time_submission'};

     
                if(($access_token == null) || ($access_token == '')) {
            
                    $responsedata = array(
                        'objid' => $objid,
                        'status' => "failed",
                        'description' => "access token is missing."
                    );
                    $em = new exceptionMgr(" ");
                    $em->logInfo("txabsgameplaydetail: Error: access token is missing."); 
                }
                else {
        
                    $tokenvalid = checkIfValidAccessToken($access_token);
           
                    if(!$tokenvalid) {
                        $responsedata = array(
                            'objid' => $objid,
                            'status' => "failed",
                            'description' => "Invalid access token."
                        );
                        $em = new exceptionMgr(" ");
                        $em->logInfo("txabsgameplaydetail: Error: Invalid access token."); 
                    }
                    else {
               
                        $objGameplaydetail = new gameplaydetail();
               
                        $objGameplaydetail->setGamePlayId($id_game_play);
                        $objGameplaydetail->setAccessToken($access_token);
                        $objGameplaydetail->setQuestionId($id_question);
                        $objGameplaydetail->setPass($pass);
                        $objGameplaydetail->setTime2Answer($time2answer);
                        $objGameplaydetail->setAttempts($attempts);
                        $objGameplaydetail->setdateTimeSubmission($date_time_submission);
           
                        $rtn = saveGameplaydetail($objGameplaydetail);
    
                        if($rtn) {
                            $responsedata = array(
                                'objid' => $objid,
                                'status' => "success",
                                'description' => ""
                            );
                        }
                        else {
                            $responsedata = array(
                                'objid' => $objid,
                                'status' => "failed",
                                'description' => "Failed to save Gameplaydetail Data."
                            );
                            $em = new exceptionMgr(" ");
                            $em->logInfo("txabsgameplaydetail: Error: Failed to save Gameplaydetail Data."); 
                        }
                    }
                }
            }
            else {
        
                $responsedata = array(
                    'objid' => $objid,
                    'status' => "failed",
                    'description' => "Data missing for this JSON object."
                );
                $em = new exceptionMgr(" ");
                $em->logInfo("txabsgameplaydetail: Error: Data missing for this JSON object."); 
             }
    
             array_push($responsedata_array,$responsedata);
        }
    }
    
    header('Content-type: application/json');
    echo json_encode($responsedata_array);
    
?>    