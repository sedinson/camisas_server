-- phpMyAdmin SQL Dump
-- version 3.4.11.1deb1
-- http://www.phpmyadmin.net
--
-- Servidor: localhost
-- Tiempo de generación: 11-01-2014 a las 19:58:33
-- Versión del servidor: 5.5.34
-- Versión de PHP: 5.4.6-1ubuntu1.5

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Base de datos: `corporative`
--
CREATE DATABASE `corporative` DEFAULT CHARACTER SET latin1 COLLATE latin1_swedish_ci;
USE `corporative`;

DELIMITER $$
--
-- Funciones
--
CREATE DEFINER=`root`@`localhost` FUNCTION `GeoDistKM`( lat1 FLOAT, lon1 FLOAT, lat2 FLOAT, lon2 FLOAT ) RETURNS float
BEGIN
DECLARE pi, q1, q2, q3 FLOAT;
DECLARE rads FLOAT DEFAULT 0;
SET pi = PI();
SET lat1 = lat1 * pi / 180;
SET lon1 = lon1 * pi / 180;
SET lat2 = lat2 * pi / 180;
SET lon2 = lon2 * pi / 180;
SET q1 = COS(lon1-lon2);
SET q2 = COS(lat1-lat2);
SET q3 = COS(lat1+lat2);
SET rads = ACOS( 0.5*((1.0+q1)*q2 - (1.0-q1)*q3) );
RETURN 6378.388 * rads;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `orientacion`(id bigint(20), idresp bigint(20)) RETURNS float(7,4)
BEGIN
  DECLARE angle FLOAT (7,4) DEFAULT 0;
  DECLARE lon1, lon2 FLOAT(7,4); 
  DECLARE lat1, lat2 FLOAT(7,4); 
  DECLARE bContinuar BOOLEAN DEFAULT true;
  DECLARE cur1 CURSOR FOR SELECT DISTINCT X(location), Y(location) FROM respuesta WHere idvehiculo = id And idrespuesta <= idresp  order by idrespuesta desc limit 2;
  DECLARE CONTINUE HANDLER FOR 1329 SET bContinuar = false;

 
  OPEN cur1;
    set lat1 =0;
	set lat2 =0;
	set lon1 =0;
	set lon2 =0;
    FETCH cur1 INTO lat1, lon1;
	FETCH cur1 INTO lat2, lon2;
	IF bContinuar THEN
		set lon2 =0;
		set lat2 =0;
	END IF;
    
	set lat1 = 6371 * cos(lat1) * cos(lon1);
    set lon1 = 6371 * cos(lat1) * sin(lon1);
    set lat2 = 6371 * cos(lat2) * cos(lon2);
    set lon2 = 6371 * cos(lat2) * sin(lon2);
  CLOSE cur1;
  
       IF lon2 = lon1 THEN
          IF lat2 > lat1 THEN
			set angle = 0;
		  ELSE
			set angle = 180;
		  END IF;
       ELSE
			IF lat2 = lat1 THEN
				IF lon2 > lon1 THEN
					set angle = 90;
				ELSE
					set angle = 270;
				END IF;
			ELSE
			    
				IF lat2 > lat1 and  lon2 > lon1 THEN
					set angle = 270 + atan((lat2-lat1)/(lon2-lon1))*180/3.14159;
				ELSE
					IF lat2 > lat1 and  lon2 < lon1 THEN
						set angle = 90 - atan((lat2-lat1)/(lon2-lon1))*180/3.14159;
					ELSE
						IF lat2 < lat1 and  lon2 < lon1 THEN
							set angle = 90 + atan((lat2-lat1)/(lon2-lon1))*180/3.14159;
						ELSE
							IF lat2 < lat1 and  lon2 > lon1 THEN
								set angle = 270 - atan((lat2-lat1)/(lon2-lon1))*180/3.14159;
							END IF;
						END IF;
					END IF;
				END IF;
            END IF;	   
          
       END IF;
  
  
RETURN angle;  
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `capturas`
--

CREATE TABLE IF NOT EXISTS `capturas` (
  `idcapturas` int(11) NOT NULL AUTO_INCREMENT,
  `idvehiculo` bigint(20) NOT NULL,
  `captura` longblob NOT NULL,
  `fecha` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`idcapturas`),
  KEY `idvehiculo` (`idvehiculo`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `codigo_activacion`
--

CREATE TABLE IF NOT EXISTS `codigo_activacion` (
  `idcodigo_activacion` int(11) NOT NULL AUTO_INCREMENT,
  `firmware` varchar(50) COLLATE utf8_spanish_ci NOT NULL,
  `codigo` varchar(16) COLLATE utf8_spanish_ci NOT NULL,
  `iddistribuidor` int(11) NOT NULL,
  `creation` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `idzona` int(11) NOT NULL,
  PRIMARY KEY (`idcodigo_activacion`),
  UNIQUE KEY `codigo` (`codigo`),
  KEY `idzona` (`idzona`),
  KEY `iddistribuidor` (`iddistribuidor`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci AUTO_INCREMENT=8 ;

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `codigos_disponibles`
--
CREATE TABLE IF NOT EXISTS `codigos_disponibles` (
`idcodigo_activacion` int(11)
,`firmware` varchar(50)
,`codigo` varchar(16)
,`iddistribuidor` int(11)
,`creation` timestamp
,`idzona` int(11)
);
-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `customgeofence`
--

CREATE TABLE IF NOT EXISTS `customgeofence` (
  `idcustomgeofence` int(11) NOT NULL AUTO_INCREMENT,
  `idred` int(11) NOT NULL,
  `nombre` varchar(50) NOT NULL,
  `idtipogeofence` int(11) NOT NULL,
  `distancia` int(11) DEFAULT '0',
  PRIMARY KEY (`idcustomgeofence`),
  UNIQUE KEY `idred_2` (`idred`,`nombre`),
  KEY `idtipogeofence` (`idtipogeofence`),
  KEY `idred` (`idred`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=87 ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `despacho`
--

CREATE TABLE IF NOT EXISTS `despacho` (
  `iddespacho` int(11) NOT NULL AUTO_INCREMENT,
  `idred` int(11) NOT NULL,
  `origen` varchar(125) COLLATE utf8_spanish_ci NOT NULL,
  `loc_origen` point NOT NULL,
  `fecha_salida` datetime NOT NULL,
  `destino` varchar(125) COLLATE utf8_spanish_ci NOT NULL,
  `loc_destino` point NOT NULL,
  `fecha_entrega` datetime NOT NULL,
  `orden` text COLLATE utf8_spanish_ci NOT NULL,
  `reporte` text COLLATE utf8_spanish_ci NOT NULL,
  `creation` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`iddespacho`),
  KEY `idred` (`idred`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci AUTO_INCREMENT=21 ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `despacho_vehiculo`
--

CREATE TABLE IF NOT EXISTS `despacho_vehiculo` (
  `iddespacho_vehiculo` int(11) NOT NULL AUTO_INCREMENT,
  `iddespacho` int(11) NOT NULL,
  `idvehiculo` bigint(11) NOT NULL,
  `estado` varchar(25) COLLATE utf8_spanish_ci NOT NULL DEFAULT 'delivering',
  `fecha` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`iddespacho_vehiculo`),
  UNIQUE KEY `iddespacho` (`iddespacho`),
  KEY `idvehiculo` (`idvehiculo`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci AUTO_INCREMENT=23 ;

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `despachos_disponibles`
--
CREATE TABLE IF NOT EXISTS `despachos_disponibles` (
`iddespacho` int(11)
,`idred` int(11)
,`origen` varchar(125)
,`loc_origen` point
,`fecha_salida` datetime
,`destino` varchar(125)
,`loc_destino` point
,`fecha_entrega` datetime
,`orden` text
,`reporte` text
,`creation` timestamp
,`lat1` double
,`lon1` double
,`lat2` double
,`lon2` double
,`idvehiculo` bigint(11)
,`estado` varchar(25)
,`fecha` timestamp
);
-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `disparador`
--

CREATE TABLE IF NOT EXISTS `disparador` (
  `iddisparador` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(25) CHARACTER SET utf8 COLLATE utf8_spanish_ci NOT NULL,
  `descripcion` varchar(100) CHARACTER SET utf8 COLLATE utf8_spanish_ci NOT NULL,
  PRIMARY KEY (`iddisparador`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=3 ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `disparador_actividad`
--

CREATE TABLE IF NOT EXISTS `disparador_actividad` (
  `iddisparador_actividad` int(11) NOT NULL AUTO_INCREMENT,
  `iddisparador` int(11) NOT NULL,
  `idgrupo` int(11) NOT NULL,
  `inicio` date NOT NULL,
  `fin` date NOT NULL,
  `nombre` varchar(25) CHARACTER SET utf8 COLLATE utf8_spanish_ci DEFAULT NULL,
  `hora_actividad` text CHARACTER SET utf8 NOT NULL,
  `email` text CHARACTER SET utf8 NOT NULL,
  PRIMARY KEY (`iddisparador_actividad`),
  UNIQUE KEY `nombre` (`nombre`),
  KEY `iddisparador` (`iddisparador`),
  KEY `idgrupo` (`idgrupo`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=18 ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `distribuidor`
--

CREATE TABLE IF NOT EXISTS `distribuidor` (
  `iddistribuidor` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(50) COLLATE utf8_spanish_ci NOT NULL,
  PRIMARY KEY (`iddistribuidor`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci AUTO_INCREMENT=2 ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `file`
--

CREATE TABLE IF NOT EXISTS `file` (
  `idfile` int(11) NOT NULL AUTO_INCREMENT,
  `file` longblob NOT NULL,
  `mimetype` varchar(25) COLLATE utf8_spanish_ci NOT NULL,
  `creation` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`idfile`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci AUTO_INCREMENT=16 ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `filtro`
--

CREATE TABLE IF NOT EXISTS `filtro` (
  `idfiltro` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(25) NOT NULL,
  `idicono` int(11) NOT NULL,
  `idred` int(11) NOT NULL,
  `idusuario` int(11) NOT NULL,
  PRIMARY KEY (`idfiltro`),
  UNIQUE KEY `nombre` (`nombre`,`idred`),
  KEY `idicono` (`idicono`),
  KEY `idred` (`idred`),
  KEY `idusuario` (`idusuario`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=13 ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `filtropoi`
--

CREATE TABLE IF NOT EXISTS `filtropoi` (
  `idfiltropoi` int(11) NOT NULL AUTO_INCREMENT,
  `idfiltro` int(11) NOT NULL,
  `idpoi` int(11) NOT NULL,
  PRIMARY KEY (`idfiltropoi`),
  UNIQUE KEY `idfiltro_2` (`idfiltro`,`idpoi`),
  KEY `idfiltro` (`idfiltro`),
  KEY `idpoi` (`idpoi`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=106 ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `gcmuser`
--

CREATE TABLE IF NOT EXISTS `gcmuser` (
  `idgcmuser` int(11) NOT NULL AUTO_INCREMENT,
  `idusuario` varchar(20) COLLATE utf8_spanish2_ci DEFAULT NULL,
  `movil` varchar(20) COLLATE utf8_spanish2_ci DEFAULT NULL,
  `regGCM` varchar(255) COLLATE utf8_spanish2_ci DEFAULT NULL,
  PRIMARY KEY (`idgcmuser`),
  UNIQUE KEY `regGCM` (`regGCM`),
  UNIQUE KEY `idusuario` (`idusuario`),
  KEY `idvehiculo` (`movil`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_spanish2_ci AUTO_INCREMENT=20 ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `geofence`
--

CREATE TABLE IF NOT EXISTS `geofence` (
  `idgeofence` int(11) NOT NULL AUTO_INCREMENT,
  `lat1` varchar(20) COLLATE utf8_spanish2_ci DEFAULT NULL,
  `lon1` varchar(20) COLLATE utf8_spanish2_ci DEFAULT NULL,
  `lat2` varchar(20) COLLATE utf8_spanish2_ci DEFAULT NULL,
  `lon2` varchar(20) COLLATE utf8_spanish2_ci DEFAULT NULL,
  `accion` varchar(10) COLLATE utf8_spanish2_ci DEFAULT NULL,
  `idvehiculo` bigint(20) NOT NULL,
  `estado` varchar(20) COLLATE utf8_spanish2_ci NOT NULL DEFAULT 'activa',
  `fecha` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`idgeofence`),
  UNIQUE KEY `idvehiculo` (`idvehiculo`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_spanish2_ci AUTO_INCREMENT=37 ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `grupo`
--

CREATE TABLE IF NOT EXISTS `grupo` (
  `idgrupo` int(11) NOT NULL AUTO_INCREMENT,
  `idred` int(11) NOT NULL,
  `idusuario` int(11) NOT NULL,
  `nombre` varchar(25) CHARACTER SET utf8 COLLATE utf8_spanish_ci NOT NULL,
  PRIMARY KEY (`idgrupo`),
  KEY `idred` (`idred`),
  KEY `idusuario` (`idusuario`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=5 ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `grupocustomgeofence`
--

CREATE TABLE IF NOT EXISTS `grupocustomgeofence` (
  `idgrupocustomgeofence` int(11) NOT NULL AUTO_INCREMENT,
  `idgrupo` int(11) NOT NULL,
  `idcustomgeofence` int(11) NOT NULL,
  `entradasalida` varchar(3) NOT NULL,
  PRIMARY KEY (`idgrupocustomgeofence`),
  UNIQUE KEY `idgrupo_2` (`idgrupo`,`idcustomgeofence`,`entradasalida`),
  KEY `idgrupo` (`idgrupo`),
  KEY `idcustomgeofence` (`idcustomgeofence`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=3 ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `grupovehiculo`
--

CREATE TABLE IF NOT EXISTS `grupovehiculo` (
  `idgrupovehiculo` int(11) NOT NULL AUTO_INCREMENT,
  `idgrupo` int(11) NOT NULL,
  `idvehiculo` bigint(20) NOT NULL,
  PRIMARY KEY (`idgrupovehiculo`),
  UNIQUE KEY `idgrupo_2` (`idgrupo`,`idvehiculo`),
  KEY `idgrupo` (`idgrupo`),
  KEY `idvehiculo` (`idvehiculo`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=18 ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `historial_operador`
--

CREATE TABLE IF NOT EXISTS `historial_operador` (
  `idhistorial_operador` int(11) NOT NULL AUTO_INCREMENT,
  `idvehiculo` bigint(11) NOT NULL,
  `idoperador` int(11) NOT NULL,
  `log` int(11) NOT NULL,
  `estado` varchar(25) CHARACTER SET utf8 COLLATE utf8_spanish2_ci NOT NULL DEFAULT 'offline',
  `creation` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`idhistorial_operador`),
  KEY `idvehiculo` (`idvehiculo`),
  KEY `idoperador` (`idoperador`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci AUTO_INCREMENT=3 ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `icono`
--

CREATE TABLE IF NOT EXISTS `icono` (
  `idicono` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(25) NOT NULL,
  `ruta` varchar(250) NOT NULL,
  PRIMARY KEY (`idicono`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=2 ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `mensaje`
--

CREATE TABLE IF NOT EXISTS `mensaje` (
  `idmensaje` int(11) NOT NULL AUTO_INCREMENT,
  `idvehiculo` bigint(20) NOT NULL,
  `nombre` varchar(50) COLLATE utf8_spanish_ci NOT NULL,
  `mensaje` text COLLATE utf8_spanish_ci NOT NULL,
  `creation` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`idmensaje`),
  KEY `idusuario` (`nombre`),
  KEY `idvehiculo` (`idvehiculo`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci AUTO_INCREMENT=56 ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `obd2`
--

CREATE TABLE IF NOT EXISTS `obd2` (
  `idobd2` int(11) NOT NULL AUTO_INCREMENT,
  `idvehiculo` bigint(11) NOT NULL,
  `elcv` varchar(20) COLLATE utf8_spanish_ci NOT NULL,
  `ect` varchar(20) COLLATE utf8_spanish_ci NOT NULL,
  `es` varchar(20) COLLATE utf8_spanish_ci NOT NULL,
  `vspeed` varchar(20) COLLATE utf8_spanish_ci NOT NULL,
  `iat` varchar(20) COLLATE utf8_spanish_ci NOT NULL,
  `amf` varchar(20) COLLATE utf8_spanish_ci NOT NULL,
  `obdmode` varchar(20) COLLATE utf8_spanish_ci NOT NULL,
  `ais` varchar(20) COLLATE utf8_spanish_ci NOT NULL,
  `rtses` varchar(20) COLLATE utf8_spanish_ci NOT NULL,
  `mil` varchar(20) COLLATE utf8_spanish_ci NOT NULL,
  `fli` varchar(20) COLLATE utf8_spanish_ci NOT NULL,
  `warmups` varchar(20) COLLATE utf8_spanish_ci NOT NULL,
  `dtscc` varchar(20) COLLATE utf8_spanish_ci NOT NULL,
  `cmv` varchar(20) COLLATE utf8_spanish_ci NOT NULL,
  `alv` varchar(20) COLLATE utf8_spanish_ci NOT NULL,
  `aat` varchar(20) COLLATE utf8_spanish_ci NOT NULL,
  `hppd` varchar(20) COLLATE utf8_spanish_ci NOT NULL,
  `hppe` varchar(20) COLLATE utf8_spanish_ci NOT NULL,
  `hppf` varchar(20) COLLATE utf8_spanish_ci NOT NULL,
  `trwmo` varchar(20) COLLATE utf8_spanish_ci NOT NULL,
  `tstcc` varchar(20) COLLATE utf8_spanish_ci NOT NULL,
  `ifc` varchar(20) COLLATE utf8_spanish_ci NOT NULL,
  `horsepower` varchar(20) COLLATE utf8_spanish_ci NOT NULL,
  `totaldistance` varchar(20) COLLATE utf8_spanish_ci NOT NULL,
  `aspeed` varchar(20) COLLATE utf8_spanish_ci NOT NULL,
  `hkfc` varchar(20) COLLATE utf8_spanish_ci NOT NULL,
  `presetmileage` varchar(20) COLLATE utf8_spanish_ci NOT NULL,
  `cdc` varchar(20) COLLATE utf8_spanish_ci NOT NULL,
  `rdc` varchar(20) COLLATE utf8_spanish_ci NOT NULL,
  `milfstate` varchar(20) COLLATE utf8_spanish_ci NOT NULL,
  `ecu` varchar(20) COLLATE utf8_spanish_ci NOT NULL,
  `batteryvoltage` varchar(20) COLLATE utf8_spanish_ci NOT NULL,
  `ein` varchar(20) COLLATE utf8_spanish_ci NOT NULL,
  `gin` varchar(20) COLLATE utf8_spanish_ci NOT NULL,
  `fecha` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`idobd2`),
  UNIQUE KEY `idvehiculo` (`idvehiculo`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci AUTO_INCREMENT=13 ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `operador`
--

CREATE TABLE IF NOT EXISTS `operador` (
  `idoperador` int(11) NOT NULL AUTO_INCREMENT,
  `user` varchar(25) COLLATE utf8_spanish_ci DEFAULT NULL,
  `pass` text COLLATE utf8_spanish_ci NOT NULL,
  `nombre` varchar(50) COLLATE utf8_spanish_ci DEFAULT NULL,
  `apellido` varchar(50) COLLATE utf8_spanish_ci DEFAULT NULL,
  `cedula` varchar(15) COLLATE utf8_spanish_ci DEFAULT NULL,
  `licencia` varchar(15) COLLATE utf8_spanish_ci DEFAULT NULL,
  `edad` int(11) DEFAULT NULL,
  `telefono` varchar(12) COLLATE utf8_spanish_ci NOT NULL,
  `correo` varchar(50) COLLATE utf8_spanish_ci NOT NULL,
  `idfile` int(11) DEFAULT NULL,
  `creation` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`idoperador`),
  UNIQUE KEY `user` (`user`),
  UNIQUE KEY `licencia` (`licencia`),
  UNIQUE KEY `cedula` (`cedula`),
  KEY `idfile` (`idfile`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci AUTO_INCREMENT=3 ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `poi`
--

CREATE TABLE IF NOT EXISTS `poi` (
  `idpoi` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(25) NOT NULL,
  `location` point NOT NULL,
  `idred` int(11) NOT NULL,
  PRIMARY KEY (`idpoi`),
  KEY `idred` (`idred`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=51 ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `puntosgeofence`
--

CREATE TABLE IF NOT EXISTS `puntosgeofence` (
  `idpuntosgeofence` int(11) NOT NULL AUTO_INCREMENT,
  `idcustomgeofence` int(11) NOT NULL,
  `location` geometry NOT NULL,
  PRIMARY KEY (`idpuntosgeofence`),
  KEY `idcustomgeofence` (`idcustomgeofence`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=123 ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `red`
--

CREATE TABLE IF NOT EXISTS `red` (
  `idred` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(25) COLLATE utf8_spanish_ci NOT NULL,
  `idusuario` int(11) NOT NULL,
  `creation` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`idred`),
  UNIQUE KEY `nombre` (`nombre`,`idusuario`),
  KEY `idusuario` (`idusuario`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci AUTO_INCREMENT=4 ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `redoperador`
--

CREATE TABLE IF NOT EXISTS `redoperador` (
  `idredoperador` int(11) NOT NULL AUTO_INCREMENT,
  `idred` int(11) NOT NULL,
  `idoperador` int(11) NOT NULL,
  `creation` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`idredoperador`),
  UNIQUE KEY `idred_2` (`idred`,`idoperador`),
  KEY `idred` (`idred`),
  KEY `idoperador` (`idoperador`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci AUTO_INCREMENT=10 ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `redusuario`
--

CREATE TABLE IF NOT EXISTS `redusuario` (
  `idredusuario` int(11) NOT NULL AUTO_INCREMENT,
  `idred` int(11) NOT NULL,
  `idusuario` int(11) NOT NULL,
  `lastmensaje` int(11) NOT NULL DEFAULT '0',
  `creation` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`idredusuario`),
  UNIQUE KEY `idred_2` (`idred`,`idusuario`),
  KEY `idred` (`idred`),
  KEY `idusuario` (`idusuario`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci AUTO_INCREMENT=23 ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `redvehiculo`
--

CREATE TABLE IF NOT EXISTS `redvehiculo` (
  `idredvehiculo` int(11) NOT NULL AUTO_INCREMENT,
  `idred` int(11) NOT NULL,
  `idvehiculo` bigint(20) NOT NULL,
  `creation` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`idredvehiculo`),
  UNIQUE KEY `idred_2` (`idred`,`idvehiculo`),
  KEY `idred` (`idred`),
  KEY `idvehiculo` (`idvehiculo`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci AUTO_INCREMENT=22 ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `respuesta`
--

CREATE TABLE IF NOT EXISTS `respuesta` (
  `idrespuesta` int(11) NOT NULL AUTO_INCREMENT,
  `idvehiculo` bigint(20) NOT NULL,
  `location` point NOT NULL,
  `respuesta` varchar(3) COLLATE utf8_spanish2_ci NOT NULL,
  `tipo` varchar(3) COLLATE utf8_spanish2_ci NOT NULL,
  `velocidad` decimal(6,2) NOT NULL DEFAULT '0.00',
  `bateria` decimal(5,2) DEFAULT '0.00',
  `gsm` decimal(5,2) DEFAULT '0.00',
  `azimuth` varchar(25) COLLATE utf8_spanish2_ci DEFAULT '000',
  `gstation` varchar(25) COLLATE utf8_spanish2_ci DEFAULT '000000-0000-0000',
  `odometro` varchar(25) COLLATE utf8_spanish2_ci NOT NULL DEFAULT '000000',
  `combustible` decimal(5,2) NOT NULL DEFAULT '0.00',
  `motor` varchar(10) COLLATE utf8_spanish2_ci DEFAULT NULL,
  `engine` varchar(11) COLLATE utf8_spanish2_ci DEFAULT NULL,
  `acc` varchar(10) COLLATE utf8_spanish2_ci DEFAULT NULL,
  `doors` varchar(10) COLLATE utf8_spanish2_ci DEFAULT NULL,
  `lights` varchar(10) COLLATE utf8_spanish2_ci DEFAULT NULL,
  `alarm` varchar(10) COLLATE utf8_spanish2_ci DEFAULT NULL,
  `listen` varchar(10) COLLATE utf8_spanish2_ci DEFAULT NULL,
  `vs` varchar(10) COLLATE utf8_spanish2_ci DEFAULT NULL,
  `fecha` datetime NOT NULL,
  `creation` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`idrespuesta`),
  KEY `idvehiculo` (`idvehiculo`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_spanish2_ci AUTO_INCREMENT=48144 ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `speedalarm`
--

CREATE TABLE IF NOT EXISTS `speedalarm` (
  `idspeedalarm` int(11) NOT NULL AUTO_INCREMENT,
  `velocidad` varchar(3) COLLATE utf8_spanish2_ci NOT NULL,
  `idvehiculo` bigint(20) NOT NULL,
  `estado` varchar(20) COLLATE utf8_spanish2_ci NOT NULL DEFAULT 'activa',
  `fecha` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`idspeedalarm`),
  UNIQUE KEY `idvehiculo` (`idvehiculo`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_spanish2_ci AUTO_INCREMENT=54 ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tipogeofence`
--

CREATE TABLE IF NOT EXISTS `tipogeofence` (
  `idtipogeofence` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(50) NOT NULL,
  PRIMARY KEY (`idtipogeofence`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=4 ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tipovehiculo`
--

CREATE TABLE IF NOT EXISTS `tipovehiculo` (
  `idtipovehiculo` int(11) NOT NULL AUTO_INCREMENT,
  `tipo` varchar(25) COLLATE utf8_spanish_ci NOT NULL,
  `idfile` int(11) NOT NULL DEFAULT '1',
  PRIMARY KEY (`idtipovehiculo`),
  KEY `idfile` (`idfile`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci AUTO_INCREMENT=16 ;

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `token_vehiculousuario`
--
CREATE TABLE IF NOT EXISTS `token_vehiculousuario` (
`idred` int(11)
,`owner` int(11)
,`token_owner` varchar(32)
,`idusuario` int(11)
,`token` varchar(32)
,`idvehiculo` bigint(20)
);
-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `ultima_respuesta`
--
CREATE TABLE IF NOT EXISTS `ultima_respuesta` (
`idrespuesta` int(11)
,`idvehiculo` bigint(20)
);
-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuario`
--

CREATE TABLE IF NOT EXISTS `usuario` (
  `idusuario` int(11) NOT NULL AUTO_INCREMENT,
  `user` varchar(45) COLLATE utf8_spanish2_ci DEFAULT NULL,
  `pass` text COLLATE utf8_spanish2_ci,
  `nombre` varchar(25) COLLATE utf8_spanish2_ci DEFAULT NULL,
  `apellido` varchar(50) COLLATE utf8_spanish2_ci NOT NULL,
  `mail` varchar(45) COLLATE utf8_spanish2_ci DEFAULT NULL,
  `country` varchar(50) COLLATE utf8_spanish2_ci DEFAULT NULL,
  `city` varchar(50) COLLATE utf8_spanish2_ci DEFAULT NULL,
  `direccion` varchar(100) COLLATE utf8_spanish2_ci DEFAULT NULL,
  `telefono` varchar(20) COLLATE utf8_spanish2_ci DEFAULT NULL,
  `celular` varchar(20) COLLATE utf8_spanish2_ci DEFAULT NULL,
  `genero` varchar(12) COLLATE utf8_spanish2_ci DEFAULT NULL,
  `fecha` date DEFAULT NULL,
  `postal_code` varchar(25) COLLATE utf8_spanish2_ci DEFAULT NULL,
  `state` varchar(50) COLLATE utf8_spanish2_ci DEFAULT NULL,
  `newsletter` tinyint(1) DEFAULT '0',
  `date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`idusuario`),
  UNIQUE KEY `UQ_usuario_idusuario` (`idusuario`),
  UNIQUE KEY `user` (`user`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_spanish2_ci AUTO_INCREMENT=18 ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `vehicleconfiguration`
--

CREATE TABLE IF NOT EXISTS `vehicleconfiguration` (
  `idvehicleconfiguration` int(11) NOT NULL AUTO_INCREMENT,
  `idvehiculo` bigint(20) NOT NULL,
  `numeroE1` varchar(15) DEFAULT '',
  `numeroE2` varchar(15) DEFAULT '',
  `numeroE3` varchar(15) DEFAULT '',
  `apn` varchar(25) DEFAULT '',
  `doorlocktype` varchar(15) DEFAULT 'electric',
  `doorvoltage` varchar(15) DEFAULT 'low',
  PRIMARY KEY (`idvehicleconfiguration`),
  UNIQUE KEY `idvehiculo` (`idvehiculo`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=21 ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `vehiculo`
--

CREATE TABLE IF NOT EXISTS `vehiculo` (
  `idvehiculo` bigint(20) NOT NULL,
  `nombre` varchar(15) COLLATE utf8_spanish2_ci NOT NULL,
  `marca` varchar(15) COLLATE utf8_spanish2_ci NOT NULL,
  `modelo` varchar(15) COLLATE utf8_spanish2_ci NOT NULL,
  `ano` int(11) NOT NULL,
  `placa` varchar(7) COLLATE utf8_spanish2_ci NOT NULL,
  `telefono` varchar(15) COLLATE utf8_spanish2_ci NOT NULL,
  `idcodigo_activacion` int(11) NOT NULL,
  `idoperador` int(11) NOT NULL DEFAULT '0',
  `disponible` varchar(20) COLLATE utf8_spanish2_ci NOT NULL DEFAULT 'offline',
  `pass` varchar(6) COLLATE utf8_spanish2_ci NOT NULL DEFAULT '123456',
  `creation` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `idtipovehiculo` int(11) NOT NULL,
  PRIMARY KEY (`idvehiculo`),
  UNIQUE KEY `placa` (`placa`),
  UNIQUE KEY `idcodigo_activacion` (`idcodigo_activacion`),
  KEY `idtipovehiculo` (`idtipovehiculo`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish2_ci;

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vehiculo_estado`
--
CREATE TABLE IF NOT EXISTS `vehiculo_estado` (
`idvehiculo` bigint(20)
,`nombre` varchar(15)
,`marca` varchar(15)
,`modelo` varchar(15)
,`ano` int(11)
,`placa` varchar(7)
,`telefono` varchar(15)
,`idcodigo_activacion` int(11)
,`idoperador` int(11)
,`disponible` varchar(20)
,`pass` varchar(6)
,`idtipovehiculo` int(11)
,`lat` double
,`lon` double
,`idrespuesta` int(11)
,`respuesta` varchar(3)
,`tipo` varchar(3)
,`velocidad` decimal(6,2)
,`bateria` decimal(5,2)
,`gsm` decimal(5,2)
,`inclinacion` float(7,4)
,`gstation` varchar(25)
,`odometro` varchar(25)
,`combustible` decimal(5,2)
,`motor` varchar(10)
,`engine` varchar(11)
,`acc` varchar(10)
,`doors` varchar(10)
,`lights` varchar(10)
,`alarm` varchar(10)
,`listen` varchar(10)
,`vs` varchar(10)
,`estado` varchar(7)
,`conectado` timestamp
);
-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `vehiculousuario`
--

CREATE TABLE IF NOT EXISTS `vehiculousuario` (
  `idvehiculousuario` int(11) NOT NULL AUTO_INCREMENT,
  `idusuario` int(11) NOT NULL,
  `idvehiculo` bigint(20) NOT NULL,
  `owner` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`idvehiculousuario`),
  UNIQUE KEY `idusuario_2` (`idusuario`,`idvehiculo`),
  KEY `idusuario` (`idusuario`),
  KEY `idvehiculo` (`idvehiculo`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_spanish2_ci AUTO_INCREMENT=19 ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `zona`
--

CREATE TABLE IF NOT EXISTS `zona` (
  `idzona` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(25) COLLATE utf8_spanish_ci NOT NULL,
  PRIMARY KEY (`idzona`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci AUTO_INCREMENT=7 ;

-- --------------------------------------------------------

--
-- Estructura para la vista `codigos_disponibles`
--
DROP TABLE IF EXISTS `codigos_disponibles`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `codigos_disponibles` AS select `codigo_activacion`.`idcodigo_activacion` AS `idcodigo_activacion`,`codigo_activacion`.`firmware` AS `firmware`,`codigo_activacion`.`codigo` AS `codigo`,`codigo_activacion`.`iddistribuidor` AS `iddistribuidor`,`codigo_activacion`.`creation` AS `creation`,`codigo_activacion`.`idzona` AS `idzona` from `codigo_activacion` where (not(`codigo_activacion`.`idcodigo_activacion` in (select `vehiculo`.`idcodigo_activacion` from `vehiculo`)));

-- --------------------------------------------------------

--
-- Estructura para la vista `despachos_disponibles`
--
DROP TABLE IF EXISTS `despachos_disponibles`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `despachos_disponibles` AS select `d`.`iddespacho` AS `iddespacho`,`d`.`idred` AS `idred`,`d`.`origen` AS `origen`,`d`.`loc_origen` AS `loc_origen`,`d`.`fecha_salida` AS `fecha_salida`,`d`.`destino` AS `destino`,`d`.`loc_destino` AS `loc_destino`,`d`.`fecha_entrega` AS `fecha_entrega`,`d`.`orden` AS `orden`,`d`.`reporte` AS `reporte`,`d`.`creation` AS `creation`,x(`d`.`loc_origen`) AS `lat1`,y(`d`.`loc_origen`) AS `lon1`,x(`d`.`loc_destino`) AS `lat2`,y(`d`.`loc_destino`) AS `lon2`,`dv`.`idvehiculo` AS `idvehiculo`,`dv`.`estado` AS `estado`,`dv`.`fecha` AS `fecha` from (`despacho` `d` left join `despacho_vehiculo` `dv` on((`dv`.`iddespacho` = `d`.`iddespacho`)));

-- --------------------------------------------------------

--
-- Estructura para la vista `token_vehiculousuario`
--
DROP TABLE IF EXISTS `token_vehiculousuario`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `token_vehiculousuario` AS select `r`.`idred` AS `idred`,`vu`.`idusuario` AS `owner`,md5(`vu`.`idusuario`) AS `token_owner`,`ru`.`idusuario` AS `idusuario`,md5(`ru`.`idusuario`) AS `token`,`vu`.`idvehiculo` AS `idvehiculo` from (`vehiculousuario` `vu` left join ((`red` `r` join `redusuario` `ru`) join `redvehiculo` `rv`) on(((`r`.`idusuario` = `vu`.`idusuario`) and (`vu`.`idvehiculo` = `rv`.`idvehiculo`) and (`ru`.`idred` = `r`.`idred`) and (`rv`.`idred` = `r`.`idred`))));

-- --------------------------------------------------------

--
-- Estructura para la vista `ultima_respuesta`
--
DROP TABLE IF EXISTS `ultima_respuesta`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `ultima_respuesta` AS select max(`respuesta`.`idrespuesta`) AS `idrespuesta`,`respuesta`.`idvehiculo` AS `idvehiculo` from `respuesta` group by `respuesta`.`idvehiculo`;

-- --------------------------------------------------------

--
-- Estructura para la vista `vehiculo_estado`
--
DROP TABLE IF EXISTS `vehiculo_estado`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vehiculo_estado` AS select `v`.`idvehiculo` AS `idvehiculo`,`v`.`nombre` AS `nombre`,`v`.`marca` AS `marca`,`v`.`modelo` AS `modelo`,`v`.`ano` AS `ano`,`v`.`placa` AS `placa`,`v`.`telefono` AS `telefono`,`v`.`idcodigo_activacion` AS `idcodigo_activacion`,`v`.`idoperador` AS `idoperador`,`v`.`disponible` AS `disponible`,`v`.`pass` AS `pass`,`v`.`idtipovehiculo` AS `idtipovehiculo`,x(`r`.`location`) AS `lat`,y(`r`.`location`) AS `lon`,`r`.`idrespuesta` AS `idrespuesta`,`r`.`respuesta` AS `respuesta`,`r`.`tipo` AS `tipo`,`r`.`velocidad` AS `velocidad`,`r`.`bateria` AS `bateria`,`r`.`gsm` AS `gsm`,`orientacion`(`r`.`idvehiculo`,`r`.`idrespuesta`) AS `inclinacion`,`r`.`gstation` AS `gstation`,`r`.`odometro` AS `odometro`,`r`.`combustible` AS `combustible`,`r`.`motor` AS `motor`,`r`.`engine` AS `engine`,`r`.`acc` AS `acc`,`r`.`doors` AS `doors`,`r`.`lights` AS `lights`,`r`.`alarm` AS `alarm`,`r`.`listen` AS `listen`,`r`.`vs` AS `vs`,if(isnull(`r`.`creation`),'unknow',if(((now() - interval 2 minute) > `r`.`creation`),'offline','online')) AS `estado`,`r`.`creation` AS `conectado` from ((`vehiculo` `v` join `respuesta` `r`) join `ultima_respuesta` `ur`) where ((`v`.`idvehiculo` = `ur`.`idvehiculo`) and (`r`.`idrespuesta` = `ur`.`idrespuesta`));

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `capturas`
--
ALTER TABLE `capturas`
  ADD CONSTRAINT `capturas_ibfk_1` FOREIGN KEY (`idvehiculo`) REFERENCES `vehiculo` (`idvehiculo`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `codigo_activacion`
--
ALTER TABLE `codigo_activacion`
  ADD CONSTRAINT `codigo_activacion_ibfk_1` FOREIGN KEY (`iddistribuidor`) REFERENCES `distribuidor` (`iddistribuidor`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `codigo_activacion_ibfk_2` FOREIGN KEY (`idzona`) REFERENCES `zona` (`idzona`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `customgeofence`
--
ALTER TABLE `customgeofence`
  ADD CONSTRAINT `customgeofence_ibfk_1` FOREIGN KEY (`idtipogeofence`) REFERENCES `tipogeofence` (`idtipogeofence`) ON UPDATE CASCADE,
  ADD CONSTRAINT `customgeofence_ibfk_2` FOREIGN KEY (`idred`) REFERENCES `red` (`idred`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `despacho`
--
ALTER TABLE `despacho`
  ADD CONSTRAINT `despacho_ibfk_1` FOREIGN KEY (`idred`) REFERENCES `red` (`idred`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `despacho_vehiculo`
--
ALTER TABLE `despacho_vehiculo`
  ADD CONSTRAINT `despacho_vehiculo_ibfk_1` FOREIGN KEY (`iddespacho`) REFERENCES `despacho` (`iddespacho`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `despacho_vehiculo_ibfk_2` FOREIGN KEY (`idvehiculo`) REFERENCES `vehiculo` (`idvehiculo`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `disparador_actividad`
--
ALTER TABLE `disparador_actividad`
  ADD CONSTRAINT `disparador_actividad_ibfk_1` FOREIGN KEY (`iddisparador`) REFERENCES `disparador` (`iddisparador`),
  ADD CONSTRAINT `disparador_actividad_ibfk_2` FOREIGN KEY (`idgrupo`) REFERENCES `grupo` (`idgrupo`);

--
-- Filtros para la tabla `filtro`
--
ALTER TABLE `filtro`
  ADD CONSTRAINT `filtro_ibfk_2` FOREIGN KEY (`idicono`) REFERENCES `icono` (`idicono`) ON UPDATE CASCADE,
  ADD CONSTRAINT `filtro_ibfk_3` FOREIGN KEY (`idred`) REFERENCES `red` (`idred`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `filtro_ibfk_4` FOREIGN KEY (`idusuario`) REFERENCES `usuario` (`idusuario`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `filtropoi`
--
ALTER TABLE `filtropoi`
  ADD CONSTRAINT `filtropoi_ibfk_1` FOREIGN KEY (`idfiltro`) REFERENCES `filtro` (`idfiltro`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `filtropoi_ibfk_2` FOREIGN KEY (`idpoi`) REFERENCES `poi` (`idpoi`) ON UPDATE CASCADE;

--
-- Filtros para la tabla `geofence`
--
ALTER TABLE `geofence`
  ADD CONSTRAINT `geofence_ibfk_1` FOREIGN KEY (`idvehiculo`) REFERENCES `vehiculo` (`idvehiculo`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `grupo`
--
ALTER TABLE `grupo`
  ADD CONSTRAINT `grupo_ibfk_1` FOREIGN KEY (`idred`) REFERENCES `red` (`idred`),
  ADD CONSTRAINT `grupo_ibfk_2` FOREIGN KEY (`idusuario`) REFERENCES `usuario` (`idusuario`) ON UPDATE CASCADE;

--
-- Filtros para la tabla `grupocustomgeofence`
--
ALTER TABLE `grupocustomgeofence`
  ADD CONSTRAINT `grupocustomgeofence_ibfk_1` FOREIGN KEY (`idgrupo`) REFERENCES `grupo` (`idgrupo`) ON UPDATE CASCADE,
  ADD CONSTRAINT `grupocustomgeofence_ibfk_2` FOREIGN KEY (`idcustomgeofence`) REFERENCES `customgeofence` (`idcustomgeofence`) ON UPDATE CASCADE;

--
-- Filtros para la tabla `grupovehiculo`
--
ALTER TABLE `grupovehiculo`
  ADD CONSTRAINT `grupovehiculo_ibfk_1` FOREIGN KEY (`idgrupo`) REFERENCES `grupo` (`idgrupo`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `grupovehiculo_ibfk_2` FOREIGN KEY (`idvehiculo`) REFERENCES `vehiculo` (`idvehiculo`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `historial_operador`
--
ALTER TABLE `historial_operador`
  ADD CONSTRAINT `historial_operador_ibfk_1` FOREIGN KEY (`idoperador`) REFERENCES `operador` (`idoperador`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `historial_operador_ibfk_2` FOREIGN KEY (`idvehiculo`) REFERENCES `vehiculo` (`idvehiculo`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `mensaje`
--
ALTER TABLE `mensaje`
  ADD CONSTRAINT `mensaje_ibfk_3` FOREIGN KEY (`idvehiculo`) REFERENCES `vehiculo` (`idvehiculo`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `obd2`
--
ALTER TABLE `obd2`
  ADD CONSTRAINT `obd2_ibfk_1` FOREIGN KEY (`idvehiculo`) REFERENCES `vehiculo` (`idvehiculo`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `operador`
--
ALTER TABLE `operador`
  ADD CONSTRAINT `operador_ibfk_3` FOREIGN KEY (`idfile`) REFERENCES `file` (`idfile`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Filtros para la tabla `poi`
--
ALTER TABLE `poi`
  ADD CONSTRAINT `poi_ibfk_2` FOREIGN KEY (`idred`) REFERENCES `red` (`idred`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `puntosgeofence`
--
ALTER TABLE `puntosgeofence`
  ADD CONSTRAINT `puntosgeofence_ibfk_1` FOREIGN KEY (`idcustomgeofence`) REFERENCES `customgeofence` (`idcustomgeofence`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `red`
--
ALTER TABLE `red`
  ADD CONSTRAINT `red_ibfk_1` FOREIGN KEY (`idusuario`) REFERENCES `usuario` (`idusuario`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `redoperador`
--
ALTER TABLE `redoperador`
  ADD CONSTRAINT `redoperador_ibfk_1` FOREIGN KEY (`idred`) REFERENCES `red` (`idred`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `redoperador_ibfk_2` FOREIGN KEY (`idoperador`) REFERENCES `operador` (`idoperador`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `redusuario`
--
ALTER TABLE `redusuario`
  ADD CONSTRAINT `redusuario_ibfk_1` FOREIGN KEY (`idred`) REFERENCES `red` (`idred`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `redusuario_ibfk_2` FOREIGN KEY (`idusuario`) REFERENCES `usuario` (`idusuario`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `redvehiculo`
--
ALTER TABLE `redvehiculo`
  ADD CONSTRAINT `redvehiculo_ibfk_1` FOREIGN KEY (`idred`) REFERENCES `red` (`idred`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `redvehiculo_ibfk_2` FOREIGN KEY (`idvehiculo`) REFERENCES `vehiculo` (`idvehiculo`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `respuesta`
--
ALTER TABLE `respuesta`
  ADD CONSTRAINT `respuesta_ibfk_1` FOREIGN KEY (`idvehiculo`) REFERENCES `vehiculo` (`idvehiculo`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `speedalarm`
--
ALTER TABLE `speedalarm`
  ADD CONSTRAINT `speedalarm_ibfk_1` FOREIGN KEY (`idvehiculo`) REFERENCES `vehiculo` (`idvehiculo`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `tipovehiculo`
--
ALTER TABLE `tipovehiculo`
  ADD CONSTRAINT `tipovehiculo_ibfk_1` FOREIGN KEY (`idfile`) REFERENCES `file` (`idfile`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `vehicleconfiguration`
--
ALTER TABLE `vehicleconfiguration`
  ADD CONSTRAINT `vehicleconfiguration_ibfk_1` FOREIGN KEY (`idvehiculo`) REFERENCES `vehiculo` (`idvehiculo`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `vehiculo`
--
ALTER TABLE `vehiculo`
  ADD CONSTRAINT `vehiculo_ibfk_2` FOREIGN KEY (`idtipovehiculo`) REFERENCES `tipovehiculo` (`idtipovehiculo`),
  ADD CONSTRAINT `vehiculo_ibfk_1` FOREIGN KEY (`idcodigo_activacion`) REFERENCES `codigo_activacion` (`idcodigo_activacion`) ON UPDATE CASCADE;

--
-- Filtros para la tabla `vehiculousuario`
--
ALTER TABLE `vehiculousuario`
  ADD CONSTRAINT `FK_vehiculousuario_usuario` FOREIGN KEY (`idusuario`) REFERENCES `usuario` (`idusuario`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `vehiculousuario_ibfk_1` FOREIGN KEY (`idvehiculo`) REFERENCES `vehiculo` (`idvehiculo`) ON DELETE CASCADE ON UPDATE CASCADE;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
