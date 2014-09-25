<?php
    error_reporting(0);
    if(!ob_start("ob_gzhandler")) ob_start();
    
    //Incluimos el FrontController
    require 'libs/FrontController.php';
    //Lo iniciamos con su método estático main. Hola!
    FrontController::main();
?>