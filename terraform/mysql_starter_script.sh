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

INSERT INTO user_role VALUES(1, 'ROLE_ADMIN');
INSERT INTO user_role VALUES(2, 'ROLE_AGENT');
INSERT INTO user_role VALUES(3, 'ROLE_TRAVELER');

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
EOF
