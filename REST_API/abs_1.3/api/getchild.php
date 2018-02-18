<?php
/**
 * Service API:  getchild
 * File name: getchild.php
 * Author: Suresh Kodoor
 * 
 * JSON Payload:
 * {
 * "name":"",
 * "phone":"",
 * }
 *    
 * JSON Response:
 * {
 * "status":"failed/success",
 * "description":"reason for failure, if status is 'failed'",
 * "name:"",
 * "phone":"",
 * "age":"",
 * "grade":"",
 * "schooltype:"1/0", 
 * "geo":"lat,long"
 * "language":""
 * "gender":"B/G",
 * "avatarpic":"picture image as base64 encoded string"
 * }
 * 
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
    // $jsonstring = $_GET['json']; // Use this _GET and comment out file_get_contents to test directly from browser http://.../getaccesstoken.php?json={"name":"","phone":"","deviceid":""}
    // Using file_get_contents instead to get the content to a string.
    // Note: json_decode works only with UTF-8 encoded strings.
    // So, if not UTF-8 encoded, use the function  $jsonstring = utf8_encode($jsonstring) before calling json_decode
    $jsonstring = file_get_contents("php://input");
    $data = json_decode($jsonstring); 
    
    $childname = $data->{'name'};
    $phone = $data->{'phone'};
    
    if($childname && $phone){
    
       $rtn = checkIfNameAndPhoneRegistered($childname, $phone);
        
       if(!$rtn) {
           $responsedata = array(
               'status' => "failed",
               'description' => "No Child is registered with the given name and phone number ($childname, $phone)."
           );
           $em = new exceptionMgr(" ");
           $em->logInfo("getchild: Error: No Child is registered with the given name and phone number ($childname, $phone).");
       }
       else {
           
           $objChild = getChildByNameAndPhone($childname, $phone);

	       if(!$objChild){
	           
	           $responsedata = array(
	               'status' => "failed",
	               'description' => "Failed to retrieve the Child details for the given name and phone number ($childname, $phone)."
	           );
	           $em = new exceptionMgr(" ");
	           $em->logInfo("getchild: Error: Failed to retrieve the Child details for the given name and phone number ($childname, $phone).");
	       }
	       else {
	           
	           $avatarpic = getAvatarpicEncodedStringByChildId($objChild->getChildId());

	           $responsedata = array(
	               'status' => "success",
	               'description' => "Child details have been successfully retrieved.",
	               'childid' => $objChild->getChildId(),
	               'name' => $objChild->getChildName(),
	               'phone' => $objChild->getPhone(),
	               'age' => $objChild->getAge(),
	               'grade' => $objChild->getGradeName(),
	               'schooltype' => $objChild->getSchoolTypeId(),
	               'geo' => $objChild->getGeo(),
	               'language' => $objChild->getLanguageName(),
	               'gender' => $objChild->getGender(),
	               'avatarpic' => $avatarpic
	           );
	       }
        }
    }
    else {
        
        $responsedata = array(
            'status' => "failed",
            'description' => "Input parameters missing."
        );
        $em = new exceptionMgr(" ");
        $em->logInfo("getchild: Error: Input parameters missing.");
    }
    
    header('Content-type: application/json');
    echo json_encode($responsedata);
    
?>    