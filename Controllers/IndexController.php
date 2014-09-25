<?php
    class IndexController extends ControllerBase {
        public function index() {
            $params = array ();
            
            $this->view->show('index/index.php', $params);
        }
    }
?>
