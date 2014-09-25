<?php
/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

/**
 * Description of UserController
 *
 * @author edinson
 */
class UserController extends ControllerBase {
    public function _Always() {
        if (in_array(ActionName, array('update', 'get', 'cpw'))) {
            if (!isset($_SESSION['usuario'])) {
                HTTP::JSON(401);
            }
        }
    }

    function login() {
        if (Partial::_filled($this->post, array ('correo', 'clave'))) {
            $result = QueryFactory::query("
                SELECT * 
                FROM usuario 
                WHERE correo = :correo
                AND clave = MD5(:clave);", array(
                        ':correo' => $this->post['correo'],
                        ':clave' => $this->post['clave']
            ));

            if (count($result) == 1) {
                $response = Partial::arrayNames($result, array('clave'));
                $_SESSION['usuario'] = $response[0];

                HTTP::JSON(200, $response[0]);
            }
            
            HTTP::JSON(401);
        }
        
        HTTP::JSON(400);
    }

    function logout() {
        session_destroy();

        HTTP::JSON(200);
    }

    function get() {
        HTTP::JSON(Partial::createResponse(HTTP::Value(200), $_SESSION['usuario']));
    }

    function add() {
        $empty = Partial::_empty($this->post, array ('idusuario', 'creation'));
        $filled = Partial::_filled($this->post, 
                array ('nombre', 'correo', 'clave', 'telefono', 'tipo'));
        if ($filled && $empty) {
            $usuario = $this->getModel('usuario');
            
            $params = Partial::prefix($this->post, ':');
            $params[':clave'] = md5($this->post['clave']);

            $usuario->insert($params);

            if ($usuario->lastID() > 0) {
                $headers = "From: " . strip_tags('no-reply@example.com') . "\r\n";
                $headers .= "MIME-Version: 1.0\r\n";
                $headers .= "Content-Type: text/html; charset=UTF-8\r\n";
                
                $mail = "<html>
                            <head>
                                <link href='http://fonts.googleapis.com/css?family=Roboto' rel='stylesheet' type='text/css'>
                                <meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\">
                                <style>
                                    * {
                                        font-family: 'Roboto', sans-serif;
                                        outline: none;
                                    }
                                    td {
                                        width: 900px;
                                    }
                                </style>
                            </head>
                            <body>
                                <table style=\"border: #000 1px solid\">
                                    <tr>
                                        <td>
                                            <img width=\"900\" height=\"231\" src=\"http://example.com/images/header.jpg\" alt=\"header\" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <h2>Bienvenido a Pilotos</h2>

                                            <p>
                                                Estos son los datos de su registro:
                                            </p>

                                            <ul>
                                                <li><b>Nombre:</b> {$this->post['nombre']}</li>
                                                <li><b>usuario:</b> {$this->post['correo']}</li>
                                                <li><b>clave:</b> {$this->post['clave']}</li>
                                            </ul>

                                            <p>
                                                Por favor, asegure muy bien estos datos.
                                            </p>

                                            <p>&nbsp;</p>
                                            <p>&nbsp;</p>
                                            <p>Gracias.</p>
                                            <p>&nbsp;</p>
                                            <p>El equipo Pilotos.</p>
                                        </td>
                                    </tr>
                                </table>
                            </body>
                        </html>";
                mail($this->post['mail'], 'Bienvenido a Pilotos', $mail, $headers);
                HTTP::JSON(200);
            }
            
            HTTP::JSON(424);
        }
        
        HTTP::JSON(400);
    }
    
    function restore () {
        if(!empty ($this->post['correo'])) {
            $user = $this->getModel('usuario');
            $result = $user->select(array (
                ':correo' => $this->post['correo']
            ));
            
            if(count($result) == 1) {
                $pass = substr(md5(time()), 0, 8);
                $user->update($result[0]['idusuario'], array (
                    ':clave' => md5($pass)
                ));
                $headers = "From: " . strip_tags('no-reply@example.com') . "\r\n";
                $headers .= "MIME-Version: 1.0\r\n";
                $headers .= "Content-Type: text/html; charset=UTF-8\r\n";
                
                $mail = "<html>
                            <head>
                                <link href='http://fonts.googleapis.com/css?family=Roboto' rel='stylesheet' type='text/css'>
                                <meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\">
                                <style>
                                    * {
                                        font-family: 'Roboto', sans-serif;
                                        outline: none;
                                    }
                                    td {
                                        width: 900px;
                                    }
                                </style>
                            </head>
                            <body>
                                <table style=\"border: #000 1px solid\">
                                    <tr>
                                        <td>
                                            <img width=\"900\" height=\"231\" src=\"http://example.com/images/header.jpg\" alt=\"header\" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <h2>Restaurar clave - Pilotos</h2>
                                            <p>
                                                Ha tomado la opcion de restaurar clave. La próxima vez
                                                que inicie sesión debe tener presente la siguiente informacion:
                                            </p>

                                            <ul>
                                                <li><b>usuario:</b> {$result[0]['correo']}</li>
                                                <li><b>clave:</b> {$pass}</li>
                                            </ul>

                                            <p>
                                                Por favor, asegure muy bien estos datos.
                                            </p>

                                            <p>&nbsp;</p>
                                            <p>&nbsp;</p>
                                            <p>Gracias.</p>
                                            <p>&nbsp;</p>
                                            <p>El equipo Pilotos.</p>
                                        </td>
                                    </tr>
                                </table>
                            </body>
                        </html>";
                mail($this->post['mail'], 'Restaurar clave - Pilotos', $mail, $headers);
                    
                HTTP::JSON(200);
            }
            HTTP::JSON(424);
        }
        
        HTTP::JSON(400);
    }
    
    function update() {
        $empty = Partial::_empty($this->put, array ('idusuario', 'correo', 'clave', 'creation'));
        $filled = Partial::_filled($this->put, array ());
        if ($filled && $empty) {
            $usuario = $this->getModel('usuario');
            
            $params = Partial::prefix($this->put, ':');

            $usuario->update($_SESSION['usuario']['idusuario'], $params);

            HTTP::JSON(200);
        }
        
        HTTP::JSON(400);
    }

    function cpw() {
        if (Partial::_filled($this->post, array ('old', 'new'))) {
            $res = QueryFactory::query("
                SELECT 1 
                FROM usuario
                WHERE clave = MD5(:old)
                AND correo = :correo", array(
                        ':correo' => $_SESSION['usuario']['correo'],
                        ':old' => $this->post['old']
            ));

            if (count($res) == 1) {
                QueryFactory::executeOnly("
                    UPDATE usuario
                    SET clave = MD5(:new)
                    WHERE idusuario = :idusuario", array(
                    ':idusuario' => $_SESSION['usuario']['idusuario'],
                    ':new' => $this->post['new']
                ));

                HTTP::JSON(200);
            }

            HTTP::JSON(403);
        }

        HTTP::JSON(400);
    }

}