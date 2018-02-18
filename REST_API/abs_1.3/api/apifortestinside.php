<?php

   session_start();
   $jsonstring = file_get_contents("php://input");
   if($jsonstring == null) {
     echo "jsonstring is null";
   }
   else  {
     echo "jsonstring is not null";
     $data = json_decode($jsonstring);
     print_r($data);
   }
?>
