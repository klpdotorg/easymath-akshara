<?php

// Object corresponding to game_play_tbl

class gameplay {
	
	private $intIdgp;              // idgp
	private $strGamePlayId;        // id_game_play
	private $strGameId;            // id_game
	private $start_time;           // start_time (DATETIME when the game play started (YYYY:MM:DD HH:MM:SS))
	private $childId;              // id_child
	private $childName;            // Not part of the game_play_tbl
	private $phone;                // Not part of the game_play_tbl
	private $strAccessToken;       // access_token. Not part of the gameplay_tbl
	
	function setIdgp($intIdgp){
	    $this->intIdgp = $intIdgp;
	}
	
	function getIdgp(){
	    return $this->intIdgp;
	}
	
	function setGamePlayId($strGamePlayId){
	    $this->strGamePlayId = $strGamePlayId;
	}
	
	function getGamePlayId(){
	    return $this->strGamePlayId;
	}
	
	function setGameId($strGameId){
	    $this->strGameId = $strGameId;
	}
	
	function getGameId(){
	    return $this->strGameId;
	}
	
	function setAccessToken($strAccessToken){
	    $this->strAccessToken = $strAccessToken;
	}
	
	function getAccessToken(){
	    return $this->strAccessToken;
	}
	
	function setStartTime($start_time){
	    $this->start_time = $start_time;
	}
	
	function getStartTime(){
	    return $this->start_time;
	}
	
	function setChildId($childId){
	    $this->childId = $childId;
	}
	
	function getChildId(){
	    return $this->childId;
	}
	
	function setChildName($childName){
	    $this->childName = $childName;
	}
	
	function getChildName(){
	    return $this->childName;
	}
	
	function setPhone($phone){
	    $this->phone = $phone;
	}
	
	function getPhone(){
	    return $this->phone;
	}
	
}

?>