<?php

/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

/**
 * Description of perspectiva
 *
 * @author edinson
 */
class PerspectivaController extends ControllerBase {
    //put your code here
    public function _Always() {
        if(!in_array(ActionName, array ('get'))) {
            if(!isset($_SESSION['admin'])) {
                HTTP::JSON(401);
            }
        }
    }
    
    public function get () {
        $_prenda = Partial::_filled($this->get, array ('idprenda'));
        $_perspectiva = Partial::_filled($this->get, array ('idperspectiva'));
        
        if($_prenda) {
            $result = $this->getModel('perspectiva')->select(array (
                ':idprenda' => $this->get['idprenda']
            ));

            HTTP::JSON(Partial::createResponse(HTTP::Value(200), Partial::arrayNames($result)));
        } 
        
        if ($_perspectiva) {
            $result = $this->getModel('perspectiva')->select(array (
                ':idperspectiva' => $this->get['idperspectiva']
            ));

            HTTP::JSON(Partial::createResponse(HTTP::Value(200), Partial::arrayNames($result)));
        }
        
        HTTP::JSON(400);
    }
    
    public function add () {
        $_filled = Partial::_filled($this->post, array (
                'idprenda', 'nombre', 'plantilla', 'miniatura'
            )
        );
        
        if($_filled) {
            $params = Partial::prefix($this->post, ':');
            $perspectiva = $this->getModel('perspectiva');
            
            $perspectiva->insert($params);
            
            if($perspectiva->lastID() > 0) {
                $this->post['idperspectiva'] = $perspectiva->lastID();
                HTTP::JSON(Partial::createResponse(HTTP::Value(200), $this->post));
            }
            
            HTTP::JSON(424);
        }
        
        HTTP::JSON(400);
    }
    
    public function update () {
        $_filled = Partial::_filled($this->put, array (
            'idperspectiva')
        );
        
        if($_filled) {
            $perspectiva = $this->getModel('perspectiva');
            $params = Partial::prefix($this->put, ':');
            unset($params[':idperspectiva']);
            
            $perspectiva->update($this->put['idperspectiva'], $params);
            
            HTTP::JSON(200);
        }
        
        HTTP::JSON(400);
    }
    
    public function delete () {
        $_filled = Partial::_filled($this->delete, array (
            'idperspectiva')
        );
        
        if($_filled) {
            $perspectiva = $this->getModel('perspectiva');
            
            $perspectiva->delete($this->delete['idperspectiva']);
            
            HTTP::JSON(200);
        }
        
        HTTP::JSON(400);
    }
}
