<?php

/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

/**
 * Description of PrendaController
 *
 * @author edinson
 */
class PrendaController extends ControllerBase {
    //put your code here
    public function _Always() {
        if(!in_array(ActionName, array ('get', 'tipo'))) {
            if(!isset($_SESSION['admin'])) {
                HTTP::JSON(401);
            }
        }
    }
    
    public function tipo () {
        $result = $this->getModel('prenda')->select(array (), ' group by tipo');
        
        HTTP::JSON(Partial::createResponse(HTTP::Value(200), Partial::arrayNames($result)));
    }
    
    public function get () {
        $params = Partial::prefix(
            $this->get, ':'
        );
        
        $result = $this->getModel('prenda')->select(
            $params
        );
        
        HTTP::JSON(
            Partial::createResponse(HTTP::Value(200), Partial::arrayNames($result))
        );
    }
    
    public function add () {
        $_filled = Partial::_filled($this->post, array (
            'nombre', 'tipo', 'descripcion', 'miniatura')
        );
        
        if($_filled) {
            $params = Partial::prefix($this->post, ':');
            $prenda = $this->getModel('prenda');
            
            $prenda->insert($params);
            
            if($prenda->lastID() > 0) {
                $this->post['idprenda'] = $prenda->lastID();
                HTTP::JSON(Partial::createResponse(HTTP::Value(200), $this->post));
            }
            
            HTTP::JSON(424);
        }
        
        HTTP::JSON(400);
    }
    
    public function update () {
        $_filled = Partial::_filled($this->put, array (
            'idprenda')
        );
        
        if($_filled) {
            $prenda = $this->getModel('prenda');
            $params = Partial::prefix($this->put, ':');
            unset($params[':idprenda']);
            
            $prenda->update($this->put['idprenda'], $params);
            
            HTTP::JSON(200);
        }
        
        HTTP::JSON(400);
    }
    
    public function delete () {
        $_filled = Partial::_filled($this->delete, array (
            'idprenda')
        );
        
        if($_filled) {
            $prenda = $this->getModel('prenda');
            
            $prenda->delete($this->delete['idprenda']);
            
            HTTP::JSON(200);
        }
        
        HTTP::JSON(400);
    }
}
