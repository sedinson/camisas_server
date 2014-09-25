<?php

/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

/**
 * Description of AdminController
 *
 * @author edinson
 */
class AdminController extends ControllerBase {
    //put your code here
    public function _Always() {
        if (!in_array(ActionName, array('login'))) {
            if (!isset($_SESSION['admin'])) {
                HTTP::JSON(401);
            }
        }
    }
    
    public function get () {
        $result = $this->getModel('admin')->select();
        $response = Partial::arrayNames($result, array ('clave'));
        
        HTTP::JSON(Partial::createResponse(HTTP::Value(200), $response));
    }
    
    function login () {
        $_fill = Partial::_filled($this->post, array (
            'usuario', 'clave'
        ));
        
        if($_fill) {
            $params = Partial::prefix($this->post, ':');
            $result = QueryFactory::query("SELECT * FROM admin WHERE usuario=:usuario AND clave=MD5(:clave);", $params);
            
            if(count($result) > 0) {
                $response = Partial::arrayNames($result, array('clave'));
                $_SESSION['admin'] = $response[0];
                
                HTTP::JSON(200);
            }
            
            HTTP::JSON(404);
        }
        
        HTTP::JSON(400);
    }
    
    function active () {
        HTTP::JSON(Partial::createResponse(HTTP::Value(200), $_SESSION['admin']));
    }
    
    function logout () {
        session_destroy();
        
        HTTP::JSON(200);
    }
    
    function add () {
        $_filled = Partial::_filled($this->post, array ('usuario', 'clave', 'nombre'));
        
        if($_filled) {
            $admin = $this->getModel('admin');
            $params = Partial::prefix($this->post, ':');
            $params[':clave'] = md5($params[':clave']);
            
            $admin->insert($params);
            
            if($admin->lastID() > 0) {
                HTTP::JSON(200);
            }
            
            HTTP::JSON(424);
        }
        
        HTTP::JSON(400);
    }
    
    function update() {
        $empty = Partial::_empty($this->put, array ('idadmin', 'clave', 'creation'));
        $filled = Partial::_filled($this->put, array ());
        if ($filled && $empty) {
            $usuario = $this->getModel('admin');
            
            $params = Partial::prefix($this->put, ':');

            $usuario->update($_SESSION['admin']['idadmin'], $params);

            HTTP::JSON(200);
        }
        
        HTTP::JSON(400);
    }
    
    function cpw() {
        if (Partial::_filled($this->post, array ('old', 'new'))) {
            $res = QueryFactory::query("
                SELECT 1 
                FROM admin
                WHERE clave = MD5(:old)
                AND usuario = :usuario", array(
                    ':usuario' => $_SESSION['admin']['usuario'],
                    ':old' => $this->post['old']
            ));

            if (count($res) == 1) {
                QueryFactory::executeOnly("
                    UPDATE admin
                    SET clave = MD5(:new)
                    WHERE idadmin = :idadmin", array(
                    ':idadmin' => $_SESSION['admin']['idadmin'],
                    ':new' => $this->post['new']
                ));

                HTTP::JSON(200);
            }

            HTTP::JSON(403);
        }

        HTTP::JSON(400);
    }
    
    function delete () {
        if(!empty($this->delete['idadmin'])) {
            if($_SESSION['admin']['idadmin'] != $this->delete['idadmin']) {
                $this->getModel('admin')->delete($this->delete['idadmin']);
                
                HTTP::JSON(200);
            }
            
            HTTP::JSON(403);
        }
        
        HTTP::JSON(400);
    }
}
