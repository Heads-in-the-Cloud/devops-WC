#!/bin/bash

yum update -y
yum install mysql -y


mysql -h ${RDS_MYSQL_ENDPOINT} -u ${RDS_MYSQL_USER} -p${RDS_MYSQL_PASS} -D ${RDS_MYSQL_BASE} << EOF 

-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE="ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION";

-- -----------------------------------------------------
-- Schema utopia
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema utopia
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS \`utopia\` DEFAULT CHARACTER SET utf8 ;
USE \`utopia\` ;

-- -----------------------------------------------------
-- Table \`utopia\`.\`airport\`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS \`utopia\`.\`airport\` (
  \`iata_id\` CHAR(3) NOT NULL,
  \`city\` VARCHAR(45) NOT NULL,
  PRIMARY KEY (\`iata_id\`),
  UNIQUE INDEX \`iata_id_UNIQUE\` (\`iata_id\` ASC) VISIBLE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table \`utopia\`.\`route\`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS \`utopia\`.\`route\` (
  \`id\` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  \`origin_id\` CHAR(3) NOT NULL,
  \`destination_id\` CHAR(3) NOT NULL,
  PRIMARY KEY (\`id\`, \`origin_id\`, \`destination_id\`),
  INDEX \`fk_route_airport1_idx\` (\`origin_id\` ASC) VISIBLE,
  INDEX \`fk_route_airport2_idx\` (\`destination_id\` ASC) VISIBLE,
  UNIQUE INDEX \`unique_route\` (\`origin_id\` ASC, \`destination_id\` ASC) VISIBLE,
  UNIQUE INDEX \`id_UNIQUE\` (\`id\` ASC) VISIBLE,
  CONSTRAINT \`fk_route_airport1\`
    FOREIGN KEY (\`origin_id\`)
    REFERENCES \`utopia\`.\`airport\` (\`iata_id\`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT \`fk_route_airport2\`
    FOREIGN KEY (\`destination_id\`)
    REFERENCES \`utopia\`.\`airport\` (\`iata_id\`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table \`utopia\`.\`airplane_type\`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS \`utopia\`.\`airplane_type\` (
  \`id\` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  \`max_capacity\` INT UNSIGNED NOT NULL,
  PRIMARY KEY (\`id\`),
  UNIQUE INDEX \`id_UNIQUE\` (\`id\` ASC) VISIBLE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table \`utopia\`.\`airplane\`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS \`utopia\`.\`airplane\` (
  \`id\` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  \`type_id\` INT UNSIGNED NOT NULL,
  PRIMARY KEY (\`id\`),
  UNIQUE INDEX \`id_UNIQUE\` (\`id\` ASC) VISIBLE,
  INDEX \`fk_airplane_airplane_model1_idx\` (\`type_id\` ASC) VISIBLE,
  CONSTRAINT \`fk_airplane_airplane_model1\`
    FOREIGN KEY (\`type_id\`)
    REFERENCES \`utopia\`.\`airplane_type\` (\`id\`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table \`utopia\`.\`flight\`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS \`utopia\`.\`flight\` (
  \`id\` INT UNSIGNED NOT NULL,
  \`route_id\` INT UNSIGNED NOT NULL,
  \`airplane_id\` INT UNSIGNED NOT NULL,
  \`departure_time\` DATETIME NOT NULL,
  \`reserved_seats\` INT UNSIGNED NOT NULL,
  \`seat_price\` FLOAT NOT NULL,
  PRIMARY KEY (\`id\`),
  INDEX \`fk_tbl_flight_tbl_route1_idx\` (\`route_id\` ASC) VISIBLE,
  UNIQUE INDEX \`id_UNIQUE\` (\`id\` ASC) VISIBLE,
  INDEX \`fk_flight_airplane1_idx\` (\`airplane_id\` ASC) VISIBLE,
  CONSTRAINT \`fk_tbl_flight_tbl_route1\`
    FOREIGN KEY (\`route_id\`)
    REFERENCES \`utopia\`.\`route\` (\`id\`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT \`fk_flight_airplane1\`
    FOREIGN KEY (\`airplane_id\`)
    REFERENCES \`utopia\`.\`airplane\` (\`id\`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table \`utopia\`.\`booking\`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS \`utopia\`.\`booking\` (
  \`id\` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  \`is_active\` TINYINT NOT NULL DEFAULT 1,
  \`confirmation_code\` VARCHAR(255) NOT NULL,
  PRIMARY KEY (\`id\`),
  UNIQUE INDEX \`id_UNIQUE\` (\`id\` ASC) VISIBLE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table \`utopia\`.\`user_role\`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS \`utopia\`.\`user_role\` (
  \`id\` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  \`name\` VARCHAR(45) NOT NULL,
  PRIMARY KEY (\`id\`),
  UNIQUE INDEX \`id_UNIQUE\` (\`id\` ASC) VISIBLE,
  UNIQUE INDEX \`name_UNIQUE\` (\`name\` ASC) VISIBLE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table \`utopia\`.\`user\`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS \`utopia\`.\`user\` (
  \`id\` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  \`role_id\` INT UNSIGNED NOT NULL,
  \`given_name\` VARCHAR(255) NOT NULL,
  \`family_name\` VARCHAR(255) NOT NULL,
  \`username\` VARCHAR(45) NOT NULL,
  \`email\` VARCHAR(255) NOT NULL,
  \`password\` VARCHAR(255) NOT NULL,
  \`phone\` VARCHAR(45) NOT NULL,
  PRIMARY KEY (\`id\`),
  INDEX \`fk_user_user_role1_idx\` (\`role_id\` ASC) VISIBLE,
  UNIQUE INDEX \`id_UNIQUE\` (\`id\` ASC) VISIBLE,
  UNIQUE INDEX \`username_UNIQUE\` (\`username\` ASC) VISIBLE,
  UNIQUE INDEX \`email_UNIQUE\` (\`email\` ASC) VISIBLE,
  UNIQUE INDEX \`phone_UNIQUE\` (\`phone\` ASC) VISIBLE,
  CONSTRAINT \`fk_user_user_role1\`
    FOREIGN KEY (\`role_id\`)
    REFERENCES \`utopia\`.\`user_role\` (\`id\`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table \`utopia\`.\`passenger\`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS \`utopia\`.\`passenger\` (
  \`id\` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  \`booking_id\` INT UNSIGNED NOT NULL,
  \`given_name\` VARCHAR(255) NOT NULL,
  \`family_name\` VARCHAR(255) NOT NULL,
  \`dob\` DATE NOT NULL,
  \`gender\` VARCHAR(45) NOT NULL,
  \`address\` VARCHAR(45) NOT NULL,
  PRIMARY KEY (\`id\`),
  INDEX \`fk_traveler_booking1_idx\` (\`booking_id\` ASC) VISIBLE,
  UNIQUE INDEX \`id_UNIQUE\` (\`id\` ASC) VISIBLE,
  CONSTRAINT \`fk_traveler_booking1\`
    FOREIGN KEY (\`booking_id\`)
    REFERENCES \`utopia\`.\`booking\` (\`id\`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table \`utopia\`.\`flight_bookings\`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS \`utopia\`.\`flight_bookings\` (
  \`flight_id\` INT UNSIGNED NOT NULL,
  \`booking_id\` INT UNSIGNED NOT NULL,
  INDEX \`fk_flight_bookings_booking\` (\`booking_id\` ASC) VISIBLE,
  INDEX \`fk_flight_bookings_flight\` (\`flight_id\` ASC) VISIBLE,
  PRIMARY KEY (\`booking_id\`, \`flight_id\`),
  CONSTRAINT \`fk_flight_bookings_flight\`
    FOREIGN KEY (\`flight_id\`)
    REFERENCES \`utopia\`.\`flight\` (\`id\`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT \`fk_flight_bookings_booking\`
    FOREIGN KEY (\`booking_id\`)
    REFERENCES \`utopia\`.\`booking\` (\`id\`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table \`utopia\`.\`booking_payment\`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS \`utopia\`.\`booking_payment\` (
  \`booking_id\` INT UNSIGNED NOT NULL,
  \`stripe_id\` VARCHAR(255) NOT NULL,
  \`refunded\` TINYINT NOT NULL DEFAULT 0,
  PRIMARY KEY (\`booking_id\`),
  INDEX \`fk_booking_payment_booking1_idx\` (\`booking_id\` ASC) VISIBLE,
  UNIQUE INDEX \`booking_id_UNIQUE\` (\`booking_id\` ASC) VISIBLE,
  CONSTRAINT \`fk_booking_payment_booking1\`
    FOREIGN KEY (\`booking_id\`)
    REFERENCES \`utopia\`.\`booking\` (\`id\`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table \`utopia\`.\`booking_user\`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS \`utopia\`.\`booking_user\` (
  \`booking_id\` INT UNSIGNED NOT NULL,
  \`user_id\` INT UNSIGNED NOT NULL,
  PRIMARY KEY (\`booking_id\`),
  INDEX \`fk_user_bookings_booking1_idx\` (\`booking_id\` ASC) VISIBLE,
  INDEX \`fk_user_bookings_user1_idx\` (\`user_id\` ASC) VISIBLE,
  UNIQUE INDEX \`booking_id_UNIQUE\` (\`booking_id\` ASC) VISIBLE,
  CONSTRAINT \`fk_user_bookings_booking1\`
    FOREIGN KEY (\`booking_id\`)
    REFERENCES \`utopia\`.\`booking\` (\`id\`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT \`fk_user_bookings_user1\`
    FOREIGN KEY (\`user_id\`)
    REFERENCES \`utopia\`.\`user\` (\`id\`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table \`utopia\`.\`booking_guest\`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS \`utopia\`.\`booking_guest\` (
  \`booking_id\` INT UNSIGNED NOT NULL,
  \`contact_email\` VARCHAR(255) NOT NULL,
  \`contact_phone\` VARCHAR(45) NOT NULL,
  PRIMARY KEY (\`booking_id\`),
  UNIQUE INDEX \`booking_id_UNIQUE\` (\`booking_id\` ASC) VISIBLE,
  CONSTRAINT \`fk_booking_guest_booking1\`
    FOREIGN KEY (\`booking_id\`)
    REFERENCES \`utopia\`.\`booking\` (\`id\`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table \`utopia\`.\`booking_agent\`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS \`utopia\`.\`booking_agent\` (
  \`booking_id\` INT UNSIGNED NOT NULL,
  \`agent_id\` INT UNSIGNED NOT NULL,
  INDEX \`fk_booking_booker_user1_idx\` (\`agent_id\` ASC) VISIBLE,
  PRIMARY KEY (\`booking_id\`),
  UNIQUE INDEX \`booking_id_UNIQUE\` (\`booking_id\` ASC) VISIBLE,
  CONSTRAINT \`fk_booking_booker_user1\`
    FOREIGN KEY (\`agent_id\`)
    REFERENCES \`utopia\`.\`user\` (\`id\`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT \`fk_booking_booker_booking1\`
    FOREIGN KEY (\`booking_id\`)
    REFERENCES \`utopia\`.\`booking\` (\`id\`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;

USE \`utopia\` ;

-- -----------------------------------------------------
-- Placeholder table for view \`utopia\`.\`flight_status\`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS \`utopia\`.\`flight_status\` (\`id\` INT, \`route_id\` INT, \`airplane_id\` INT, \`departure_time\` INT, \`reserved_seats\` INT, \`seat_price\` INT, \`max_capacity\` INT, \`passenger_count\` INT, \`available_seats\` INT);

-- -----------------------------------------------------
-- Placeholder table for view \`utopia\`.\`flight_passengers\`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS \`utopia\`.\`flight_passengers\` (\`flight_id\` INT, \`booking_id\` INT, \`passenger_id\` INT);

-- -----------------------------------------------------
-- Placeholder table for view \`utopia\`.\`guest_booking\`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS \`utopia\`.\`guest_booking\` (\`id\` INT, \`is_active\` INT, \`confirmation_code\` INT, \`contact_email\` INT, \`contact_phone\` INT, \`agent_id\` INT);

-- -----------------------------------------------------
-- Placeholder table for view \`utopia\`.\`user_booking\`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS \`utopia\`.\`user_booking\` (\`id\` INT, \`is_active\` INT, \`confirmation_code\` INT, \`user_id\` INT, \`agent_id\` INT);

-- -----------------------------------------------------
-- View \`utopia\`.\`flight_status\`
-- -----------------------------------------------------



DELIMITER ;

-- MySQL dump 10.13  Distrib 8.0.26, for Win64 (x86_64)
--
-- Host: localhost    Database: utopia
-- ------------------------------------------------------
-- Server version	8.0.23

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
SET @MYSQLDUMP_TEMP_LOG_BIN = @@SESSION.SQL_LOG_BIN;
SET @@SESSION.SQL_LOG_BIN= 0;

--
-- GTID state at the beginning of the backup 
--

SET @@GLOBAL.GTID_PURGED=/*!80000 '+'*/ '';

--
-- Dumping data for table \`airplane\`
--

LOCK TABLES \`airplane\` WRITE;
/*!40000 ALTER TABLE \`airplane\` DISABLE KEYS */;
INSERT INTO \`airplane\` VALUES (27,1),(28,1),(40,1),(8,2),(31,2),(33,2),(35,2),(36,2),(43,2),(45,2),(1,3),(5,3),(15,3),(18,3),(24,3),(30,3),(9,4),(26,4),(29,4),(11,5),(6,6),(7,6),(10,6),(22,6),(25,6),(13,7),(16,7),(21,7),(46,7),(49,7),(3,8),(12,8),(20,8),(32,8),(47,8),(50,8),(2,9),(4,9),(34,9),(38,9),(48,9),(14,10),(17,10),(19,10),(23,10),(37,10),(39,10),(41,10),(42,10),(44,10);
/*!40000 ALTER TABLE \`airplane\` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table \`airplane_type\`
--

LOCK TABLES \`airplane_type\` WRITE;
/*!40000 ALTER TABLE \`airplane_type\` DISABLE KEYS */;
INSERT INTO \`airplane_type\` VALUES (1,175),(2,275),(3,175),(4,125),(5,100),(6,175),(7,100),(8,150),(9,50),(10,150);
/*!40000 ALTER TABLE \`airplane_type\` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table \`airport\`
--

LOCK TABLES \`airport\` WRITE;
/*!40000 ALTER TABLE \`airport\` DISABLE KEYS */;
INSERT INTO \`airport\` VALUES ('BOS','Boston'),('BTL','Battlecreek'),('FAY','Fayetteville'),('LGA','New York City'),('LNK','Lincoln'),('MSY','New Orleans'),('ORD','Chicago'),('SAN','San Diego'),('SYR','Syracuse'),('TVL','Lake Tahoe');
/*!40000 ALTER TABLE \`airport\` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table \`booking\`
--

LOCK TABLES \`booking\` WRITE;
/*!40000 ALTER TABLE \`booking\` DISABLE KEYS */;
INSERT INTO \`booking\` VALUES (1,1,'osKELScGZlECmhOzv509SIk6Cs49tWDwPyJRGu._aBTYjsczKl'),(2,1,'WwkE-Meb7hDOuehROtam4E.s9qi6J3BTppjI_G.g9DAs74X9if'),(3,1,'A28EsZH2OkD7HzLMLXXmiLpuRd8cpo66dW.0wno6lgBZl0xGGa'),(4,1,'pOyZMIBU4NjP0DCuu0wmIGQ2LEp3RLjqkGa-AMiALe4bY8.n_p'),(5,1,'JHonM2uLTLWEjNjuSlzoa.nXeBLzYe1G8hRYdNzZ_wj_D5dLub'),(6,1,'Bj26Dr4Mr4YuLgCT-0viSm-9iRy6fM8IZzS6gNFFsm-TZUM_w3'),(7,1,'.me.ZJQ7xHHV.6448R1HTMtB8Ij7RJpGyVO72.sBhJHNjZafjZ'),(8,1,'Aes7f-iOKIBBIjSYhWSS33kaymTLIXDdW-RO2yNefhjobDNHcL'),(9,1,'eIxgM7rdZZl7DsfFjV14C0VkiSS27Vo8GMwIs-v1_sTr4tYzTc'),(10,1,'0kPTfOVmT6lKBIMU_1wwiuqnSstuHFIz_Dlj.Zxx1rIvmr.7Zf'),(11,1,'jm2WTQJOCLMDEnZbdxN0eCM2FP82hRXJob-paAa191.tfRNbQ8'),(12,1,'_qBacG_oPo1KkPxqexsqB9lTQrTl9b0Wdx54WTHT1dHXFyDmp3'),(13,1,'NOxpLosKK0wMvuxTxYdCVK-LQO.E_q-g_KFBLQwd.WWy.MSGEl'),(14,1,'i6lyiyXeABnOsDyY4Rs3YNMeCG32a7SP4pQtwJpMismia3cG-7'),(15,1,'WLsJbs2Spmbf3s_JVw-0VwJ1Z7Z6P_lM3Ov7-Sl1urAXvgcSvk'),(16,1,'A0pPs6LrzyDEHw52Cdn2qEENOJtLDwZO.iup_cL4.r25nmX2uj'),(17,1,'yM9t8Yh9d5-GrZ.VMhcLVhW-hhDuCH.2ecqxnL25895Y2V.DKP'),(18,1,'lSkKzHeVhJjALllVLOerTakbkOtVQ756g-C0dE9JcRke3gpgVR'),(19,1,'6tLEjZFaxivpNwRftwx4M1dkRt7AnBU8gX494oGTUMnPKa-goi'),(20,1,'nyIveGHrtFsicnFyjOBQUaqr9Yq.MfRyuFzWhU-E-_aQqmKdUo'),(21,1,'7pkigaHngYJlAz0ChmPyrB1q1EYOsUL8uBVNofcfHqVSUtWjUK'),(22,1,'mnt.ULMCVTWlU76vYJc4mVHyysZKjdtcNX5eCR1po3Oxhmr9Mz'),(23,1,'A17zpB1kX6oQJ6m7b_NMU8Hl33xXfIlVthTBxt927w6.cqhVsC'),(24,1,'i9-HtxSzO3cJD37Xd0Fob3v41t-ADI13SBDHWwWhWWNeeSnNzh'),(25,1,'6bTPfDp22_PIWAHhL21wRcM8KPXP.vEjAng8eiIMgCiNH7x9_5'),(26,1,'AWh23wl4T24EKzRY7Ocjd_Jfs3wfN.S3o78SNV1pLzNrxG6vlk'),(27,1,'NzHJPWts.X8DdcDVo_Cwl8IRI7lI0T.pzJFg22KivAILRcLT4l'),(28,1,'fWXjkzftQt2zOqSrLdNfIpK8J7_0NB-yJ3GFL6NN21sLRgghMx'),(29,1,'Ro_caaQGc84aZYcJEloQXwG0N9FyK8iTt5WIDAaYtb0DQ6kn-c'),(30,1,'.njdzt7IyUofq12Pc7fduJfIAz.x22fCo6cxXgQk_Z0Wrm8Dzg');
/*!40000 ALTER TABLE \`booking\` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table \`booking_agent\`
--

LOCK TABLES \`booking_agent\` WRITE;
/*!40000 ALTER TABLE \`booking_agent\` DISABLE KEYS */;
INSERT INTO \`booking_agent\` VALUES (10,107),(4,108),(5,110),(8,110),(6,112),(9,112),(1,113),(7,113),(2,116),(3,116);
/*!40000 ALTER TABLE \`booking_agent\` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table \`booking_guest\`
--

LOCK TABLES \`booking_guest\` WRITE;
/*!40000 ALTER TABLE \`booking_guest\` DISABLE KEYS */;
INSERT INTO \`booking_guest\` VALUES (21,'kgarcia@example.org','900-031-3049'),(22,'jonathan99@example.org','909-924-2826'),(23,'catherinebishop@example.org','900-895-9074'),(24,'wrodriguez@example.net','714-842-2641'),(25,'nunezjessica@example.com','909-577-3393'),(26,'ygallegos@example.net','909-389-0020'),(27,'robertrose@example.net','626-804-4227'),(28,'whitebrenda@example.net','900-648-9434'),(29,'haley93@example.org','900-676-0393'),(30,'ecarroll@example.org','714-492-7565');
/*!40000 ALTER TABLE \`booking_guest\` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table \`booking_payment\`
--

LOCK TABLES \`booking_payment\` WRITE;
/*!40000 ALTER TABLE \`booking_payment\` DISABLE KEYS */;
INSERT INTO \`booking_payment\` VALUES (1,'jw3OasFqPx-ib4xMG-lfETT.r',0),(2,'14oue3aafkKES3BTUkZBTMeKA',0),(3,'tdCjDaYkSW6YnV9fNJZET1QOo',0),(4,'9jR3mCFXmH4r7mKHODF08GcWo',0),(5,'T8F6pA-4PC-rc0QnrGZyFXsau',0),(6,'SObeUD6yNI9ugKU8uCmH63ybs',0),(7,'2B7LkZS03QMpOUIrZ.wfKVu_F',0),(8,'iReXgGDotHextRuSYEweHllcS',0),(9,'HGQoQjlFEJ8ViNGZZBjWJIQMZ',0),(10,'-1rfLW6Xbw_LRN-Ui7ylQKyh8',0),(11,'8ylhfNuay8D90fIC6kpJknayN',0),(12,'aCjoTkDjmbJyepMnr0kI4IjJO',0),(13,'SIa.D9qyDFxy5Xy-HjIRmu82h',0),(14,'S_5oT5tY4DUv84b5kBmD.zXQT',0),(15,'IkjJ-_rwIO_usCuE-ivfvu8Rg',0),(16,'RF_EKFdXaqtD92Rtyxttz9E0C',0),(17,'5ggUNEufTUATK5WqApgXCppG8',0),(18,'x_TLqhwRk-bRtkwQH0tOHOsul',0),(19,'ebIKBbLf7KG14SASpNj4EXysI',0),(20,'VvgY6qDSiMPd1eQmoCCgumGZ5',0),(21,'0o2duCQU659dJXrkxT.sPfPhm',0),(22,'lfaBAVRHjg7Y3NFTSMefVySuE',0),(23,'vigdkxLE5j_Das.EJ74KrcKJW',0),(24,'rD.sx1.eKwPf5ADkrNTpnfyeA',0),(25,'pTzsLP_OR5RkGPHLJ6xpiACa0',0),(26,'oM6oT4ca6FeD0MLyShNRbb76M',0),(27,'hGar-mmk1JlPYtxf8Cf2R9seW',0),(28,'QAAosMM2rg0.oXvKemkr4Fnjc',0),(29,'kc23pb.7aJ1M_3tVIETwQRJLk',0),(30,'UiUThc6-47LMLg9a56aBbn4Vb',0);
/*!40000 ALTER TABLE \`booking_payment\` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table \`booking_user\`
--

LOCK TABLES \`booking_user\` WRITE;
/*!40000 ALTER TABLE \`booking_user\` DISABLE KEYS */;
INSERT INTO \`booking_user\` VALUES (11,109),(13,109),(17,109),(18,109),(14,111),(15,111),(19,111),(20,111),(12,114),(16,114);
/*!40000 ALTER TABLE \`booking_user\` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table \`flight\`
--

LOCK TABLES \`flight\` WRITE;
/*!40000 ALTER TABLE \`flight\` DISABLE KEYS */;
INSERT INTO \`flight\` VALUES (1,41,47,'2021-12-29 16:05:16',0,235),(2,47,24,'2021-12-29 16:05:16',0,370),(3,19,45,'2021-12-29 16:05:16',0,360),(4,4,35,'2021-12-29 16:05:16',0,150),(5,30,10,'2021-12-29 16:05:16',0,325),(6,45,31,'2021-12-29 16:05:16',2,190),(7,49,22,'2021-12-29 16:05:16',12,490),(8,2,21,'2021-12-29 16:05:16',8,370),(9,41,50,'2021-12-29 16:05:16',0,155),(10,32,39,'2021-12-29 16:05:16',5,485),(11,20,19,'2021-12-29 16:05:16',0,155),(12,22,14,'2021-12-29 16:05:16',4,245),(13,45,13,'2021-12-29 16:05:17',0,225),(14,27,42,'2021-12-29 16:05:17',1,360),(15,36,18,'2021-12-29 16:05:17',0,460),(16,33,2,'2021-12-29 16:05:17',11,210),(17,47,22,'2021-12-31 16:05:16',1,450),(18,16,45,'2021-12-31 16:05:16',0,450),(19,16,36,'2021-12-29 16:05:17',0,135),(20,23,40,'2021-12-29 16:05:17',3,420),(21,34,37,'2021-12-29 16:05:17',10,380),(22,21,25,'2021-12-29 16:05:17',0,165),(23,14,33,'2021-12-29 16:05:17',17,270),(24,34,25,'2021-12-31 16:05:17',0,395),(25,13,32,'2021-12-29 16:05:17',0,355),(26,31,43,'2021-12-29 16:05:17',9,245),(27,1,7,'2021-12-29 16:05:17',0,115),(28,9,17,'2021-12-29 16:05:17',16,315),(29,28,18,'2021-12-31 16:05:17',0,215),(30,23,21,'2021-12-31 16:05:16',0,450),(31,32,37,'2021-12-31 16:05:17',3,445),(32,3,43,'2021-12-31 16:05:17',7,390),(33,18,15,'2021-12-29 16:05:17',0,190),(34,47,33,'2021-12-31 16:05:17',5,355),(35,13,38,'2021-12-29 16:05:17',0,340),(36,17,25,'2022-01-02 16:05:17',0,275),(37,23,46,'2021-12-29 16:05:17',8,495),(38,24,34,'2021-12-29 16:05:17',7,305),(39,37,4,'2021-12-29 16:05:17',0,455),(40,38,42,'2021-12-31 16:05:17',9,250),(41,2,6,'2021-12-29 16:05:17',2,430),(42,24,12,'2021-12-29 16:05:17',2,355),(43,32,48,'2021-12-29 16:05:17',10,475),(44,27,27,'2021-12-29 16:05:17',5,490),(45,29,47,'2021-12-31 16:05:16',0,120),(46,27,28,'2021-12-29 16:05:17',5,415),(47,33,31,'2021-12-31 16:05:16',0,385),(48,22,9,'2021-12-29 16:05:17',0,165),(49,8,43,'2022-01-02 16:05:17',0,350),(50,10,32,'2021-12-31 16:05:17',0,145);
/*!40000 ALTER TABLE \`flight\` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table \`flight_bookings\`
--

LOCK TABLES \`flight_bookings\` WRITE;
/*!40000 ALTER TABLE \`flight_bookings\` DISABLE KEYS */;
INSERT INTO \`flight_bookings\` VALUES (7,1),(23,2),(10,3),(20,4),(34,5),(21,6),(8,7),(28,8),(7,9),(43,10),(37,11),(46,12),(16,13),(42,14),(44,15),(17,16),(38,17),(14,18),(16,19),(6,20),(31,21),(32,22),(12,23),(23,24),(26,25),(40,26),(41,27),(12,28),(28,29),(37,30);
/*!40000 ALTER TABLE \`flight_bookings\` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table \`flight_passengers\`
--

LOCK TABLES \`flight_passengers\` WRITE;
/*!40000 ALTER TABLE \`flight_passengers\` DISABLE KEYS */;
/*!40000 ALTER TABLE \`flight_passengers\` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table \`flight_status\`
--

LOCK TABLES \`flight_status\` WRITE;
/*!40000 ALTER TABLE \`flight_status\` DISABLE KEYS */;
/*!40000 ALTER TABLE \`flight_status\` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table \`guest_booking\`
--

LOCK TABLES \`guest_booking\` WRITE;
/*!40000 ALTER TABLE \`guest_booking\` DISABLE KEYS */;
/*!40000 ALTER TABLE \`guest_booking\` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table \`passenger\`
--

LOCK TABLES \`passenger\` WRITE;
/*!40000 ALTER TABLE \`passenger\` DISABLE KEYS */;
INSERT INTO \`passenger\` VALUES (1,1,'Robert','Graham','1945-02-14','male','7279 Ross Station'),(2,1,'James','Owen','1981-02-27','male','851 Wagner Lodge'),(3,2,'Alan','Cruz','1946-01-15','male','USCGC Fisher'),(4,2,'Steven','Salinas','1958-06-26','male','0402 Cynthia Falls'),(5,2,'Jamie','Davis','2000-05-06','male','33890 Kyle Common Apt. 194'),(6,2,'Vanessa','Hancock','1920-12-07','male','6071 Jane Island'),(7,2,'Nicole','Miller','1982-01-21','male','1974 Wade Rapid'),(8,2,'Jason','Joseph','1985-08-18','male','136 Clinton Motorway'),(9,2,'Sara','Best','2004-06-21','female','264 Mosley Flat'),(10,2,'Sharon','Allison','1997-06-09','female','390 Lindsay Port Suite 708'),(11,2,'Andrew','Adkins','1926-03-16','male','2708 Cain Dam Suite 110'),(12,2,'Elaine','Williams','1978-10-10','female','932 Fox Circles'),(13,3,'Maria','Ewing','1997-07-27','female','3987 Harris Pike'),(14,3,'Travis','King','2005-04-14','female','2038 Wyatt Hill'),(15,3,'Tammy','Flowers','1959-08-04','female','82853 Hudson Light Apt. 802'),(16,3,'Timothy','Blackwell','1979-11-26','female','963 Sullivan Pines Apt. 426'),(17,3,'Christopher','Cooper','1990-04-14','male','3140 Murray Mills'),(18,4,'Kelsey','Little','1966-01-01','female','253 Lewis Mountains Suite 251'),(19,4,'Laura','Reynolds','1964-10-02','male','USCGC Decker'),(20,4,'Zachary','Graham','1969-03-30','male','54101 Frank Groves Suite 556'),(21,5,'Christopher','Dominguez','2002-04-12','male','06119 Cassandra Causeway Suite 803'),(22,5,'Christopher','Sharp','2018-06-06','male','45338 Valencia Lakes Apt. 863'),(23,5,'David','Fowler','1928-01-21','female','076 Solis Road'),(24,5,'William','Bernard','1950-09-04','male','8021 Leonard Centers Suite 675'),(25,5,'Deborah','Salas','1960-06-10','female','651 Padilla Center Suite 037'),(26,6,'Kari','Jones','2002-08-01','female','852 Peter Glens'),(27,6,'Carolyn','Henry','1984-04-23','female','2449 Leslie Shoal Apt. 170'),(28,6,'Steven','Olson','1930-07-05','male','83872 Brady Falls Suite 845'),(29,6,'Angelica','Fowler','1986-07-10','female','90384 Oconnor Grove'),(30,6,'Thomas','Pope','1931-10-30','male','05964 Henderson Meadows Suite 550'),(31,6,'Charles','Simmons','1991-11-13','female','Unit 4255 Box 9616'),(32,6,'John','Webb','1948-08-10','female','126 Anna Stream Apt. 925'),(33,6,'Micheal','Silva','2017-10-16','female','97292 Smith Fort Suite 526'),(34,6,'Jessica','May','1968-12-19','female','008 Bryan Ranch'),(35,6,'Miranda','Johnson','1963-01-12','male','Unit 4139 Box 6260'),(36,7,'Karen','Paul','1932-04-05','female','Unit 3300 Box 9597'),(37,7,'Ryan','Williams','2004-04-23','male','6811 Gilbert Junction Suite 234'),(38,7,'Robert','Beck','1966-06-02','male','54237 Kathleen Prairie'),(39,7,'Harry','Pitts','1964-05-27','male','305 Jose Shoals Apt. 818'),(40,7,'Janet','Olsen','2006-12-01','female','7044 Holly Tunnel'),(41,7,'Brandon','Scott','2014-03-12','female','4181 Hardin Falls'),(42,7,'Amy','Villanueva','2003-12-25','female','675 Henderson Camp'),(43,7,'Andrew','Berry','1983-08-27','male','796 Fry Isle Apt. 030'),(44,8,'John','Edwards','1986-12-31','male','821 Lane Vista'),(45,8,'Sarah','Dunn','1963-11-04','male','448 Moreno Rest'),(46,8,'Erica','Walker','1979-01-13','female','481 Murray Grove'),(47,8,'Michael','Lopez','2013-01-13','female','5906 Johnson Harbor Apt. 847'),(48,8,'James','Hernandez','1995-11-06','male','Unit 1552 Box 6950'),(49,8,'Ryan','Petersen','2001-05-22','female','5444 Sarah Terrace Apt. 070'),(50,8,'Douglas','Clark','1948-09-05','female','4552 Warner Neck'),(51,8,'Clarence','Pierce','1964-11-11','female','93906 Samantha Land'),(52,8,'Megan','Pham','1998-02-23','female','94252 Jennifer Crescent'),(53,8,'Anita','Robinson','1953-09-29','female','94390 Charles Motorway Suite 061'),(54,9,'Barbara','Luna','1988-10-29','male','3161 Kelly Spur Apt. 074'),(55,9,'Caitlin','Trujillo','1925-08-17','male','484 Cabrera Square Apt. 053'),(56,9,'Rachel','Ryan','1939-01-13','male','8572 Jeffrey Village'),(57,9,'Nicholas','Simmons','1973-09-20','male','422 Scott Drive Apt. 905'),(58,9,'Allen','Leonard','1986-12-24','female','PSC 8999, Box 0377'),(59,9,'Ian','Bell','1953-05-02','male','94429 Diane Rue Suite 351'),(60,9,'Kenneth','Peters','2009-06-07','female','30475 Cook Underpass'),(61,9,'Nicole','Johnson','1924-01-07','female','PSC 6541, Box 8737'),(62,9,'Scott','Williamson','1938-12-26','male','3624 Riddle Well'),(63,9,'John','Olsen','1929-07-06','female','7953 Laura Avenue Apt. 586'),(64,10,'Corey','Robinson','1988-06-23','male','98347 Lauren Avenue'),(65,10,'Patrick','Gonzales','1992-08-10','female','994 Robert Plaza Apt. 276'),(66,10,'Blake','Marsh','1971-12-28','female','440 Randolph Park'),(67,10,'Natasha','Morris','2019-04-28','female','3170 Phillips Inlet'),(68,10,'Mary','Contreras','1940-06-27','male','4520 Le Crest Apt. 527'),(69,10,'Audrey','Hardy','1931-06-22','male','3292 Pamela Inlet'),(70,10,'Michael','Miller','2006-03-17','female','68566 Beverly Knolls Suite 299'),(71,10,'Jennifer','Martinez','1981-05-28','male','69420 Taylor Knoll Suite 456'),(72,10,'Luis','Williams','1995-03-28','male','0569 Carla Inlet'),(73,10,'Kristina','Hudson','1948-11-17','male','05818 David Brook Suite 148'),(74,11,'Miguel','Rodgers','1933-04-28','female','6133 Dakota Lodge'),(75,11,'Wayne','Roberts','1921-08-02','male','97075 Erin Expressway'),(76,11,'Christopher','Davis','2003-09-26','female','76569 Timothy Loop Suite 235'),(77,11,'Carlos','Hall','1935-02-04','male','674 Davis Spur'),(78,11,'Sarah','Boone','1953-03-05','male','107 Morris Ferry'),(79,11,'Ann','Lopez','1946-11-27','male','115 Travis Knoll'),(80,12,'Deanna','Perez','1938-12-07','male','77038 Cindy Valley'),(81,12,'Randall','Thomas','1937-06-09','male','490 Goodman Viaduct'),(82,12,'Christopher','Cohen','1984-10-30','female','8980 Dana Crescent'),(83,12,'Michelle','Macias','2019-08-19','male','60428 Green Prairie Apt. 531'),(84,12,'Thomas','Hanna','1985-03-15','male','78416 Elizabeth Square'),(85,13,'Joe','Scott','1971-06-27','male','9358 Delgado Road Apt. 369'),(86,13,'Jeffrey','Serrano','1986-10-23','female','22869 Morales Square'),(87,13,'Sarah','Petersen','2008-01-25','male','001 Rose Avenue Suite 167'),(88,13,'Charlene','Mccoy','1958-01-13','male','021 Anderson Fords'),(89,13,'Timothy','Washington','1925-11-18','male','929 Stacy Court'),(90,13,'Luke','Keller','1959-10-17','male','3367 Bowman Highway'),(91,13,'Larry','Armstrong','2019-11-15','male','6706 Tanya Skyway'),(92,14,'Brenda','Barnes','2016-05-20','female','45498 Michael Ridges Suite 999'),(93,14,'Joseph','Ballard','2005-04-16','female','11043 Santos Haven'),(94,15,'David','Reyes','1993-04-10','male','814 Meghan Station'),(95,15,'Michael','Velasquez','2017-12-23','male','62311 Charles Burgs'),(96,15,'Jennifer','Aguirre','2004-04-06','male','PSC 5883, Box 5791'),(97,15,'Patricia','Taylor','1939-09-22','female','51233 James Knolls Apt. 219'),(98,15,'Karen','Torres','1990-07-29','male','008 Kevin Rapids Suite 989'),(99,16,'Cheryl','King','1923-11-24','male','503 Nathaniel Avenue Apt. 250'),(100,17,'Clayton','Moore','1977-11-30','female','6473 Ortega Cliffs'),(101,17,'Samuel','Smith','2004-11-18','female','107 Martinez Motorway Apt. 891'),(102,17,'Kayla','Taylor','1965-03-30','female','Unit 4472 Box 6158'),(103,17,'Joshua','Banks','1945-04-18','male','27149 Thomas Creek Suite 083'),(104,17,'Eduardo','Guerrero','1937-11-14','male','09045 Barry Lights Apt. 916'),(105,17,'Jamie','Collins','1927-03-30','female','742 Brown Way'),(106,17,'Joshua','Wright','1951-04-25','female','1829 Flowers Plains'),(107,18,'Ryan','Boyle','1921-09-01','male','9431 Tammy Mall Suite 375'),(108,19,'Cynthia','Patton','1927-11-05','male','09873 Kimberly Ranch'),(109,19,'Darlene','Hubbard','1952-03-14','male','822 James Streets'),(110,19,'Danielle','Glover','1930-04-26','male','0130 Collins Walks'),(111,19,'Kenneth','Miller','1960-11-20','male','PSC 7379, Box 3307'),(112,20,'Joseph','Ferguson','1958-03-11','male','165 Wilson Ville'),(113,20,'Kim','Bauer','1989-07-20','male','45051 Melissa Isle'),(114,21,'Brady','Jimenez','1974-08-12','female','710 Medina Harbor Suite 845'),(115,21,'Amanda','Jacobs','1994-09-09','male','845 Todd Hill Suite 684'),(116,21,'Christopher','Gross','1952-01-13','female','81389 Soto Course'),(117,22,'Kayla','Wilson','1969-07-21','male','430 Gabrielle Landing Suite 065'),(118,22,'Wayne','Hoffman','1967-03-25','female','099 Rebecca Neck'),(119,22,'Vincent','Lee','1927-12-15','female','1826 Elizabeth Drive'),(120,22,'Sheila','Edwards','1984-12-02','male','5357 Sarah Ports'),(121,22,'Susan','Young','1927-03-14','female','303 Huffman View Apt. 936'),(122,22,'Kevin','Crawford','1957-11-12','male','245 Cynthia Groves'),(123,22,'Amber','Carey','1999-02-22','female','USCGC Santiago'),(124,23,'Jim','Hayes','2013-04-28','male','8147 Bradford Mountain Suite 793'),(125,24,'David','Carter','1953-02-01','female','PSC 5356, Box 0181'),(126,24,'Brittany','Gross','1923-02-14','female','735 Carroll Keys Suite 798'),(127,24,'Colton','Williams','1975-07-27','female','0763 Johnson Greens Apt. 105'),(128,24,'John','Wright','2001-10-13','male','85429 Parrish Landing Suite 676'),(129,24,'Ricardo','Mendez','1933-01-27','female','6148 Karen Crest'),(130,24,'Tommy','Perry','1948-04-19','male','1708 Evan Ports Suite 905'),(131,24,'Gary','Peterson','2010-11-11','female','77219 Michael Track'),(132,25,'Nathaniel','Ramos','1946-06-04','female','42643 Michael Ranch Apt. 708'),(133,25,'Jennifer','Collins','1988-05-14','female','258 Megan View Suite 050'),(134,25,'Andrew','Fowler','1992-01-01','male','8489 Denise Tunnel'),(135,25,'Ashley','Cabrera','1930-06-02','male','Unit 4792 Box 4344'),(136,25,'Erik','Kelley','1976-10-24','female','540 Pham Mountains Apt. 822'),(137,25,'Christy','Harrison','2008-03-07','female','89025 Mark Inlet Apt. 823'),(138,25,'Michael','Simmons','2005-12-23','female','32064 Russell Terrace'),(139,25,'Jeremy','Moore','1971-09-02','female','08811 Dorothy Street'),(140,25,'Joyce','Flores','1990-08-18','male','021 Huff Lake'),(141,26,'Spencer','Kirk','1986-09-07','male','844 Phelps Village'),(142,26,'Kevin','Gonzalez','1944-11-02','male','547 Michael Overpass Apt. 064'),(143,26,'Jeremy','Hughes','1962-06-30','female','USNV Walters'),(144,26,'Emily','Zhang','1979-06-01','male','616 Richard Island Apt. 728'),(145,26,'Kimberly','Lee','1944-01-12','female','935 Jeffery Neck Suite 371'),(146,26,'Kathy','Vazquez','1990-12-18','female','1454 Sanchez Circles'),(147,26,'Lee','Khan','1995-10-28','male','380 Erica Flats'),(148,26,'Samuel','Edwards','1981-12-20','male','USCGC Lewis'),(149,26,'Megan','Johnson','1957-05-11','male','076 Taylor Rapid Apt. 792'),(150,27,'Daniel','Watson','2007-10-24','female','89355 Mitchell Cliffs'),(151,27,'Sarah','Jackson','1947-12-27','male','399 Jessica Loaf'),(152,28,'Renee','Malone','1950-01-24','male','2913 Barbara Brook'),(153,28,'Jeffery','Jones','1929-08-30','male','80112 Stanley Greens'),(154,28,'Emily','Rivera','1924-07-02','female','830 Harding Villages Apt. 669'),(155,29,'John','Armstrong','1920-09-10','female','USNV Mejia'),(156,29,'Sandra','Avery','2010-03-06','female','41511 Bowman Turnpike'),(157,29,'Lance','Evans','2016-11-13','male','8326 Rivera Circle Suite 010'),(158,29,'Allison','Hunt','1920-02-09','female','5509 Maria Causeway'),(159,29,'Allen','Thompson','1990-11-28','female','55733 Ross Parkways'),(160,29,'Kelly','Charles','1925-10-15','female','52425 Nguyen Branch Apt. 724'),(161,30,'Karen','Holden','1930-10-31','male','183 Hunter Locks Suite 523'),(162,30,'Brandon','Rogers','1965-12-22','female','7416 Russell Corner Apt. 831');
/*!40000 ALTER TABLE \`passenger\` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table \`route\`
--

LOCK TABLES \`route\` WRITE;
/*!40000 ALTER TABLE \`route\` DISABLE KEYS */;
INSERT INTO \`route\` VALUES (1,'LNK','LGA'),(2,'FAY','BOS'),(3,'ORD','MSY'),(4,'LGA','BTL'),(5,'SAN','BOS'),(6,'TVL','BOS'),(7,'LGA','LNK'),(8,'SAN','FAY'),(9,'LNK','BOS'),(10,'SAN','TVL'),(11,'ORD','LGA'),(12,'MSY','SYR'),(13,'TVL','MSY'),(14,'BOS','SYR'),(15,'SYR','LGA'),(16,'BTL','SYR'),(17,'LGA','BOS'),(18,'BOS','BTL'),(19,'BOS','MSY'),(20,'SYR','LNK'),(21,'SYR','BTL'),(22,'LNK','FAY'),(23,'FAY','SAN'),(24,'BTL','MSY'),(25,'BOS','TVL'),(26,'LGA','ORD'),(27,'SAN','BTL'),(28,'SYR','TVL'),(29,'TVL','SAN'),(30,'FAY','LNK'),(31,'LNK','TVL'),(32,'BTL','BOS'),(33,'FAY','ORD'),(34,'MSY','LNK'),(35,'LGA','FAY'),(36,'LGA','TVL'),(37,'MSY','LGA'),(38,'FAY','BTL'),(39,'SYR','MSY'),(40,'TVL','LGA'),(41,'MSY','BOS'),(42,'SAN','MSY'),(43,'LNK','SYR'),(44,'MSY','BTL'),(45,'BOS','LNK'),(46,'ORD','BOS'),(47,'ORD','FAY'),(48,'FAY','SYR'),(49,'LGA','SAN'),(50,'TVL','LNK');
/*!40000 ALTER TABLE \`route\` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table \`user\`
--

LOCK TABLES \`user\` WRITE;
/*!40000 ALTER TABLE \`user\` DISABLE KEYS */;
INSERT INTO \`user\` VALUES (107,1,'Jennifer','Ross','JenniferRoss293','lavila@example.net','$2b$12$AG5hfFfdsUPxxlbBFhR5yOX2B/VwLoT1gvtYj4VqrzCPTaosWIrVG','626-585-7051'),(108,1,'Richard','Skinner','RichardSkinner774','franklinconnie@example.com','$2b$12$NkJv/XabH6l8LN5w1SVIFueTMRpG9.U.92KPHM8Eufl0yw.c907Ga','626-756-4930'),(109,3,'Danielle','Greer','DanielleGreer33','ejones@example.net','$2b$12$lbouAwRFuO8G9V7siOdIvOgAs9dhw/GiK71zCk6fGVCU5P6FhJCkm','909-504-1206'),(110,1,'David','White','DavidWhite849','gomezjenna@example.net','$2b$12$A0MozME2vjQ4wRdml4NfT.azuhq7kDA6nEIAd7v3TlcJfo8ufxZni','714-353-7556'),(111,3,'Jennifer','Campbell','JenniferCampbell431','emcdonald@example.net','$2b$12$DeCa0jgAeB/1eRLnII3XpOAE2jHkKig/wrVQLYRZE7bNV9XEn.hf6','626-846-2917'),(112,2,'Christina','Maldonado','ChristinaMaldonado13','rachelwilliamson@example.org','$2b$12$9CMzFYfuKwFVp1995IveIuUQm8F5eOI.uuERviIiIs7JXZNBWNURW','900-058-6189'),(113,2,'Heidi','Bailey','HeidiBailey','lance47@example.net','$2b$12$DeD7LggvSoggc0mXsu0DwOuxReBNAYS70/CpClufaY2268/T/zRKS','714-789-9985'),(114,3,'Adam','Ramos','traveler_example','yward@example.org','$2b$12$J8Kabbv7V1klaQ4FHDLb8.Hh0khnl.Qe3zFH.9XqS1dZOWZDlnGbO','714-219-6058'),(115,2,'Crystal','Chen','agent_example','zkim@example.com','$2b$12$oFcoHe0EAGKveMZ5GygJ5eBVCGOvFGgDggzaLzi8KgTjOLc/ODbNC','626-628-4090'),(116,1,'Mark','Hogan','admin_example','wdunlap@example.net','$2b$12$HUSQ/dYlqY5PruN3K/dmPuOOaMc73iyKNKtJzKk2T12Q7tyj4IIeC','626-283-4159');
/*!40000 ALTER TABLE \`user\` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table \`user_booking\`
--

LOCK TABLES \`user_booking\` WRITE;
/*!40000 ALTER TABLE \`user_booking\` DISABLE KEYS */;
/*!40000 ALTER TABLE \`user_booking\` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table \`user_role\`
--

LOCK TABLES \`user_role\` WRITE;
/*!40000 ALTER TABLE \`user_role\` DISABLE KEYS */;
INSERT INTO \`user_role\` VALUES (1,'ROLE_ADMIN'),(2,'ROLE_AGENT'),(3,'ROLE_TRAVELER');
/*!40000 ALTER TABLE \`user_role\` ENABLE KEYS */;
UNLOCK TABLES;
SET @@SESSION.SQL_LOG_BIN = @MYSQLDUMP_TEMP_LOG_BIN;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2021-12-22 16:12:56

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

EOF
