<?php

require_once($_SESSION['ABSAPP_BASE_DIR']."/app/boot/checksandincludes.php");

function checkMatch($txtPassword, $encryptedPassword) {
	 
    if(crypt($txtPassword, $encryptedPassword) == $encryptedPassword){
       return true;
    }
    else {
       return false;
    }
}



function login($name,$phone){
    
    $servicefunctions_dao = new servicefunctions_dao();
    
    $childid = $servicefunctions_dao->getChildIdByNameAndPhone($name, $phone);
  
    if($childid == null) return false;  // authentication failed
    else return $childid; // authentication success. Return id_child
     
}

function createAccessToken(){
    
    return $access_token = uniqid();
}

function checkIfAccessTokenExistsForChildForDevice($childid,$deviceid){
   
    $servicefunctions_dao=new servicefunctions_dao();

    $rtn = $servicefunctions_dao->checkIfAccessTokenExistsForChildForDevice($childid,$deviceid);
    return $rtn;
}

function updateAccessToken($childid,$deviceid,$access_token, $created_datetime){
   
    $servicefunctions_dao=new servicefunctions_dao();
    $servicefunctions_dao->updateAccessToken($childid,$deviceid,$access_token, $created_datetime);
}

function saveNewAccessTokenForChildForDevice($childid,$deviceid,$access_token,$created_datetime){
   
    $servicefunctions_dao=new servicefunctions_dao();
    $servicefunctions_dao->saveNewAccessTokenForChildForDevice($childid,$deviceid,$access_token,$created_datetime);
}

function checkIfValidAccessToken($access_token){
    
    $servicefunctions_dao=new servicefunctions_dao();
    $rtn = $servicefunctions_dao->checkIfValidAccessToken($access_token); 
    return $rtn;
}

function checkIfNameAndPhoneRegistered($childname,$phone){
    
    $servicefunctions_dao=new servicefunctions_dao();
    $rtn =  $servicefunctions_dao->checkIfNameAndPhoneRegistered($childname,$phone);
    return $rtn;
}

function getChildIdByAccessToken($access_token){
   
    $servicefunctions_dao=new servicefunctions_dao();
    return $childid = $servicefunctions_dao->getChildIdByAccessToken($access_token);   
    
}

function getChildIdByNameAndPhone($name,$phone) {
    
    $servicefunctions_dao=new servicefunctions_dao();
    return $childid = $servicefunctions_dao->getChildIdByNameAndPhone($name,$phone);   
}

function getAccessTokenForChildForDevice($childname,$phone,$deviceid){
    
    $servicefunctions_dao=new servicefunctions_dao();
    return $token = $servicefunctions_dao->getAccessTokenForChildForDevice($childname,$phone,$deviceid);
    
}

function getChildByNameAndPhone($childname, $phone) {
    
    $servicefunctions_dao=new servicefunctions_dao();
    return $servicefunctions_dao->getChildByNameAndPhone($childname,$phone);
    
}

function getChildByChildId($childid) {
    
    $servicefunctions_dao=new servicefunctions_dao();
    return $servicefunctions_dao->getChildByChildId($childid);
    
}

function getChildByAccessToken($accesstoken) {
    
    $servicefunctions_dao=new servicefunctions_dao();
    return $servicefunctions_dao->getChildByAccessToken($accesstoken);
    
}

function registerNewChild($objChild){
    
    $servicefunctions_dao = new servicefunctions_dao();
    
    $rtn = $servicefunctions_dao->insertChild($objChild);
    
    if($rtn) {
        return true;  
    }
    else {
        return false;
    }
}

function updateProfile($objChild) {
    
    $servicefunctions_dao = new servicefunctions_dao();
    
    $rtn = $servicefunctions_dao->updateProfile($objChild);
    
    if($rtn) {
        return true;
    }
    else {
        return false;
    }
}

function saveAvatarPic($base64imagestring,$child_id) {
    
    global $cfg_valid_imagefile_extensions, $cfg_avatarpics_dir;
    
    $createddatetime = time(); // time() returns current UNIX timestamp (current time measured in the number of seconds since the Unix Epoch (January 1 1970 00:00:00 GMT)
    
    $picfilename = 'pic_'.$child_id.'_'.$createddatetime;
    $picfilefullpath = $_SESSION['ABSAPP_BASE_DIR'].'/'.$cfg_avatarpics_dir.'/'.$picfilename;
    
    // convert the JSON base64 encoded string to an image file. Returns. 
    $rtn = file_put_contents($picfilefullpath, base64_decode($base64imagestring));
    
    // file_put_contents returns number of chars written to the file in case of success OR 'false' if failed
    if($rtn !== false) {
        $servicefunctions_dao = new servicefunctions_dao();
        $servicefunctions_dao->updateAvatarpicFilenameByChildId($child_id,$picfilename);
    }
    return $rtn;
           
}

function updateAvatarpicFilenameByChildId($child_id,$picfilename) {
    
    $servicefunctions_dao = new servicefunctions_dao();
    $servicefunctions_dao->updateAvatarpicFilenameByChildId($child_id,$picfilename);
}


function getAvatarpicEncodedStringByChildId($child_id){
    
    global $cfg_avatarpics_dir;
  
    $servicefunctions_dao=new servicefunctions_dao();
    $picfilename = $servicefunctions_dao->getAvatarpicFilenameByChildId($child_id);
 
    if(($picfilename == null) || ($picfilename == ''))
        return '';
    
    $picfilefullpath = $_SESSION['ABSAPP_BASE_DIR'].'/'.$cfg_avatarpics_dir.'/'.$picfilename;
    $imagedata = file_get_contents($picfilefullpath);
    $base64imagestring = base64_encode($imagedata);
    return $base64imagestring;
}

function saveGameplaydetail($objGameplaydetail){
    
    $servicefunctions_dao = new servicefunctions_dao();
    
    $rtn = $servicefunctions_dao->insertGameplaydetail($objGameplaydetail);
    
    if($rtn) {
        return true;
    }
    else {
        return false;
    }
}

function getGameplaydetailByGameplaydetailId($gamedetailid) {

    $servicefunctions_dao = new servicefunctions_dao();
    
    $objGameplaydetail = $servicefunctions_dao->getGameplaydetail($gamedetailid);
    return $objGameplaydetail;
}

function saveGameplay($objGameplay){
    
    $servicefunctions_dao = new servicefunctions_dao();
    
    $rtn = $servicefunctions_dao->insertGameplay($objGameplay);
    
    if($rtn) {
        return true;
    }
    else {
        return false;
    }
}

function getGameplayByGameplayId($gameplayid) {
    
    $servicefunctions_dao = new servicefunctions_dao();
    
    $objGameplay = $servicefunctions_dao->getGameplay($gameplayid);
    return $objGameplay;
}

function saveEkStepEventData($objEkStepEventData){
    
    $ekstepevents_dao = new ekstepevents_dao();
    
    $rtn = $ekstepevents_dao->insertEkStepEventData($objEkStepEventData);
    
    if($rtn) {
        return true;
    }
    else {
        return false;
    }
}

?>