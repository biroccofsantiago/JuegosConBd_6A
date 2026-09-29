-- MySQL dump 10.13  Distrib 8.0.46, for Linux (x86_64)
--
-- Host: localhost    Database: juegos_6A
-- ------------------------------------------------------
-- Server version	8.0.46-0ubuntu0.24.04.4

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `usuarios`
--

DROP TABLE IF EXISTS `usuarios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `usuarios` (
  `usu_id` int NOT NULL AUTO_INCREMENT,
  `usu_usuario` varchar(50) DEFAULT NULL,
  `usu_nombre` varchar(50) DEFAULT NULL,
  `usu_apellido` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`usu_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usuarios`
--

LOCK TABLES `usuarios` WRITE;
/*!40000 ALTER TABLE `usuarios` DISABLE KEYS */;
INSERT INTO `usuarios` VALUES (1,'Admin','Santiago','Birocco');
/*!40000 ALTER TABLE `usuarios` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-09-22 14:43:50

-- CRUD para la tabla `usuarios` (MySQL 8)
DELIMITER $$

DROP PROCEDURE IF EXISTS `sp_usuarios_crear`$$
CREATE PROCEDURE `sp_usuarios_crear`(
  IN p_usuario varchar(50),
  IN p_nombre varchar(50),
  IN p_apellido varchar(50)
)
BEGIN
  INSERT INTO `usuarios` (`usu_usuario`, `usu_nombre`, `usu_apellido`)
  VALUES (p_usuario, p_nombre, p_apellido);

  SELECT LAST_INSERT_ID() AS `usu_id`;
END$$

DROP PROCEDURE IF EXISTS `sp_usuarios_listar`$$
CREATE PROCEDURE `sp_usuarios_listar`()
BEGIN
  SELECT `usu_id`, `usu_usuario`, `usu_nombre`, `usu_apellido`
  FROM `usuarios`
  ORDER BY `usu_id`;
END$$

DROP PROCEDURE IF EXISTS `sp_usuarios_obtener`$$
CREATE PROCEDURE `sp_usuarios_obtener`(IN p_usu_id int)
BEGIN
  SELECT `usu_id`, `usu_usuario`, `usu_nombre`, `usu_apellido`
  FROM `usuarios`
  WHERE `usu_id` = p_usu_id;
END$$

DROP PROCEDURE IF EXISTS `sp_usuarios_actualizar`$$
CREATE PROCEDURE `sp_usuarios_actualizar`(
  IN p_usu_id int,
  IN p_usuario varchar(50),
  IN p_nombre varchar(50),
  IN p_apellido varchar(50)
)
BEGIN
  UPDATE `usuarios`
  SET `usu_usuario` = p_usuario,
      `usu_nombre` = p_nombre,
      `usu_apellido` = p_apellido
  WHERE `usu_id` = p_usu_id;
END$$

DROP PROCEDURE IF EXISTS `sp_usuarios_eliminar`$$
CREATE PROCEDURE `sp_usuarios_eliminar`(IN p_usu_id int)
BEGIN
  DELETE FROM `usuarios`
  WHERE `usu_id` = p_usu_id;
END$$

DELIMITER ;

-- Ejemplos de uso:
-- CALL sp_usuarios_crear('usuario1', 'Nombre', 'Apellido');
-- CALL sp_usuarios_listar();
-- CALL sp_usuarios_obtener(1);
-- CALL sp_usuarios_actualizar(1, 'usuario1', 'Nombre actualizado', 'Apellido actualizado');
-- CALL sp_usuarios_eliminar(1);
