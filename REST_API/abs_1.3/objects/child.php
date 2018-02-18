<?php

class child {
	
	private $intChildId;
	private $strChildName;	
	private $strPhone;
	private $intAge;
	private $intGradeId;
	private $strGradeName;
	private $intSchoolTypeId; // 0 - govt, 1 - pvt
	private $strGeo;
	private $intLanguageId;
	private $strLanguageName;
	private $strPicFileName;
	private $strGender; // 'B' for Boys and 'G' for Girls
	private $strOrganization; 
	
	
	function setChildId($intChildId){
	    $this->intChildId = $intChildId;
	}
	
	function getChildId(){
	    return $this->intChildId;
	}
	
	function setChildName($strChildName) {
	    $this->strChildName = $strChildName ;
	}
	
	function getChildName() {
	    return $this->strChildName;
	}
	
	function setPhone($strPhone) {
	    $this->strPhone = $strPhone;
	}
	
	function getPhone()	{
	    return $this->strPhone;
	}
	
	function setAge($intAge) {
	    $this->intAge = $intAge;
	}
	
	function getAge()	{
	    return $this->intAge;
	}
	
	function setGradeId($intGradeId) {
	    $this->intGradeId = $intGradeId;
	}
	
	function getGradeId()	{
	    return $this->intGradeId;
	}
	
	function setGradeName($strGradeName) {
	    $this->strGradeName = $strGradeName;
	}
	
	function getGradeName()	{
	    return $this->strGradeName;
	}
	
	function setSchoolTypeId($intSchoolTypeId) {
	    $this->intSchoolTypeId = $intSchoolTypeId;
	}
	
	function getSchoolTypeId()	{
	    return $this->intSchoolTypeId;
	}
	
	function setGeo($strGeo) {
	    $this->strGeo = $strGeo;
	}
	
	function getGeo()	{
	    return $this->strGeo;
	}
	
	function setLanguageId($intLanguageId){
	    $this->intLanguageId = $intLanguageId;
	}
	
	function getLanguageId(){
	    return $this->intLanguageId;
	}
	
	function setLanguageName($strLanguageName){
	    $this->strLanguageName = $strLanguageName;
	}
	
	function getLanguageName(){
	    return $this->strLanguageName;
	}
	
	function setPicFileName($strPicFileName){
	    
	    $this->strPicFileName = $strPicFileName;
	}
	
	function getPicFileName(){
	    return $this->strPicFileName;
	}
	
	
	function setGender($strGender){
	    $this->strGender = $strGender;
	}
	
	function getGender(){
	    return $this->strGender;	    
	}	
	
	function setOrg($strOrganization){
	    $this->strOrganization = $strOrganization;
	}
	
	function getOrg(){
	    return $this->strOrganization;
	}	
}

?>