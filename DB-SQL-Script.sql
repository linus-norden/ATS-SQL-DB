SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema ATSDB
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `ATSDB` DEFAULT CHARACTER SET utf8mb4;
USE `ATSDB`;

-- -----------------------------------------------------
-- Table `ATSDB`.`bereich`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ATSDB`.`bereich` (
  `bereich_id` INT NOT NULL AUTO_INCREMENT,
  `bereich_name` VARCHAR(45) NOT NULL,
  `bereich_aktiv_seit` DATETIME NULL DEFAULT NULL,
  `bereich_inaktiv_seit` DATETIME NULL DEFAULT NULL,
  `bereich_aktiv` BIT(1) NOT NULL DEFAULT b'0' COMMENT 'Boolean. Flag für aktiven Bereich',
  PRIMARY KEY (`bereich_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARACTER SET=utf8mb4;

-- -----------------------------------------------------
-- Table `ATSDB`.`raum`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ATSDB`.`raum` (
  `raum_id` INT NOT NULL AUTO_INCREMENT,
  `raum_name` VARCHAR(255) NOT NULL,
  `raum_aktiv_seit` DATETIME NULL DEFAULT NULL,
  `raum_inaktiv_seit` DATETIME NULL DEFAULT NULL,
  `raum_bereich_id` INT NOT NULL,
  `raum_aktiv` BIT(1) NULL DEFAULT NULL COMMENT 'Boolean. Zeigt einen aktiven Raum.',
  PRIMARY KEY (`raum_id`),
  INDEX `fk_Raum_Bereich1_idx` (`raum_bereich_id` ASC),
  CONSTRAINT `fk_Raum_Bereich1`
    FOREIGN KEY (`raum_bereich_id`)
    REFERENCES `ATSDB`.`bereich` (`bereich_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARACTER SET=utf8mb4;

-- -----------------------------------------------------
-- Table `ATSDB`.`hub`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ATSDB`.`hub` (
  `hub_id` INT NOT NULL AUTO_INCREMENT,
  `hub_MAC` VARCHAR(255) NOT NULL,
  `hub_aktiv` TINYINT NOT NULL,
  `hub_aktiv_seit` DATETIME NULL DEFAULT NULL,
  `hub_inaktiv_seit` DATETIME NULL DEFAULT NULL,
  `hub_raum_id` INT NULL DEFAULT NULL,
  `hub_raum_ts` INT NULL DEFAULT NULL,
  `hub_timestamp` INT NULL DEFAULT 0 COMMENT 'Timestamp der letzten \'aktiv\'-Meldung',
  PRIMARY KEY (`hub_id`),
  UNIQUE INDEX `hub_UUID_UNIQUE` (`hub_MAC` ASC),
  INDEX `fk_Hub_Raum1_idx` (`hub_raum_id` ASC),
  CONSTRAINT `fk_Hub_Raum1`
    FOREIGN KEY (`hub_raum_id`)
    REFERENCES `ATSDB`.`raum` (`raum_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARACTER SET=utf8mb4;

-- -----------------------------------------------------
-- Table `ATSDB`.`beacon`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ATSDB`.`beacon` (
  `beacon_id` INT NOT NULL AUTO_INCREMENT,
  `beacon_MAC` VARCHAR(45) NOT NULL,
  `beacon_aktiv` TINYINT NOT NULL DEFAULT 0,
  `beacon_aktiv_seit` DATETIME NOT NULL DEFAULT '0000-00-00 00:00:00',
  `beacon_RSSI` INT NOT NULL DEFAULT 0,
  `beacon_batterie` INT NOT NULL DEFAULT 100,
  `beacon_inaktiv_seit` DATETIME NULL DEFAULT NULL,
  `beacon_hub_id` INT NULL DEFAULT NULL,
  `beacon_timestamp` INT NOT NULL DEFAULT 0,
  `beacon_hub_ts_beginn` INT NULL DEFAULT NULL,
  PRIMARY KEY (`beacon_id`),
  INDEX `fk_beacon_hub1_idx` (`beacon_hub_id` ASC),
  CONSTRAINT `fk_beacon_hub1`
    FOREIGN KEY (`beacon_hub_id`)
    REFERENCES `ATSDB`.`hub` (`hub_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARACTER SET=utf8mb4;

-- -----------------------------------------------------
-- Table `ATSDB`.`beaconpair`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ATSDB`.`beaconpair` (
  `beaconpair_beacon_id_1` INT NOT NULL,
  `beaconpair_beacon_id_2` INT NOT NULL,
  `beaconpair_timestamp` INT NOT NULL,
  `beaconpair_hub_id` INT NOT NULL,
  PRIMARY KEY (`beaconpair_beacon_id_1`, `beaconpair_beacon_id_2`),
  INDEX `fk_beacon_has_beacon_beacon2_idx` (`beaconpair_beacon_id_2` ASC),
  INDEX `fk_beacon_has_beacon_beacon1_idx` (`beaconpair_beacon_id_1` ASC),
  INDEX `fk_beaconpair_hub1_idx` (`beaconpair_hub_id` ASC),
  CONSTRAINT `fk_beacon_has_beacon_beacon1`
    FOREIGN KEY (`beaconpair_beacon_id_1`)
    REFERENCES `ATSDB`.`beacon` (`beacon_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_beacon_has_beacon_beacon2`
    FOREIGN KEY (`beaconpair_beacon_id_2`)
    REFERENCES `ATSDB`.`beacon` (`beacon_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_beaconpair_hub1`
    FOREIGN KEY (`beaconpair_hub_id`)
    REFERENCES `ATSDB`.`hub` (`hub_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARACTER SET=utf8mb4;

-- -----------------------------------------------------
-- Table `ATSDB`.`hub_historie`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ATSDB`.`hub_historie` (
  `hub_historie_id` BIGINT(20) NOT NULL AUTO_INCREMENT,
  `hub_historie_hub_id` INT NOT NULL,
  `hub_historie_raum_id` INT NOT NULL,
  `hub_historie_raum_ts_start` INT NULL DEFAULT NULL,
  `hub_historie_raum_ts_end` INT NULL DEFAULT NULL,
  PRIMARY KEY (`hub_historie_id`),
  INDEX `hub_historie_hub_id_idx` (`hub_historie_hub_id` ASC),
  INDEX `hub_historie_raum_id_idx` (`hub_historie_raum_id` ASC),
  CONSTRAINT `hub_historie_hub_id`
    FOREIGN KEY (`hub_historie_hub_id`)
    REFERENCES `ATSDB`.`hub` (`hub_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `hub_historie_raum_id`
    FOREIGN KEY (`hub_historie_raum_id`)
    REFERENCES `ATSDB`.`raum` (`raum_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARACTER SET=utf8mb4 COMMENT='Änderung der Raumzuweisung von Hubs.\\nNutzung: Absicherung der Gerätehistorie, da diese IDs referenziert.\\nBefüllung durch AfterUpdate Trigger auf der Tabelle hub.';

-- -----------------------------------------------------
-- Table `ATSDB`.`mp_typ`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ATSDB`.`mp_typ` (
  `mp_typ_id` INT NOT NULL AUTO_INCREMENT,
  `mp_typ_name` VARCHAR(255) NOT NULL,
  `mp_typ_aktiv` BIT(1) NULL DEFAULT b'0' COMMENT 'Boolean. Zeigt einen aktiven MP Typen.',
  PRIMARY KEY (`mp_typ_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARACTER SET=utf8mb4;

-- -----------------------------------------------------
-- Table `ATSDB`.`mp`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ATSDB`.`mp` (
  `mp_id` INT NOT NULL AUTO_INCREMENT,
  `mp_name` VARCHAR(255) NOT NULL,
  `mp_SN` VARCHAR(255) NOT NULL,
  `mp_aktiv_seit` DATETIME NULL DEFAULT NULL,
  `mp_inaktiv_seit` DATETIME NULL DEFAULT NULL,
  `mp_mp_typ_id` INT NOT NULL,
  `mp_beacon_id` INT NULL DEFAULT NULL,
  `mp_aktiv` BIT(1) NULL DEFAULT b'1' COMMENT 'Boolean. Zeigt eine aktives MP.',
  PRIMARY KEY (`mp_id`),
  INDEX `fk_mp_mptyp1_idx` (`mp_mp_typ_id` ASC),
  INDEX `fk_mp_beacon1_idx` (`mp_beacon_id` ASC),
  CONSTRAINT `fk_mp_beacon1`
    FOREIGN KEY (`mp_beacon_id`)
    REFERENCES `ATSDB`.`beacon` (`beacon_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_mp_mptyp1`
    FOREIGN KEY (`mp_mp_typ_id`)
    REFERENCES `ATSDB`.`mp_typ` (`mp_typ_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARACTER SET=utf8mb4;

-- -----------------------------------------------------
-- Table `ATSDB`.`mp_historie`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ATSDB`.`mp_historie` (
  `mp_historie_id` BIGINT(20) NOT NULL AUTO_INCREMENT,
  `mp_historie_raum_id` INT NOT NULL,
  `mp_historie_mp_id` INT NOT NULL,
  `mp_historie_raum_ts_start` INT NOT NULL,
  `mp_historie_raum_ts_end` INT NOT NULL,
  PRIMARY KEY (`mp_historie_id`),
  INDEX `mp_historie_raum_id_idx` (`mp_historie_raum_id` ASC),
  INDEX `mp_historie_mp_id_idx` (`mp_historie_mp_id` ASC),
  CONSTRAINT `mp_historie_mp_id`
    FOREIGN KEY (`mp_historie_mp_id`)
    REFERENCES `ATSDB`.`mp` (`mp_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `mp_historie_raum_id`
    FOREIGN KEY (`mp_historie_raum_id`)
    REFERENCES `ATSDB`.`raum` (`raum_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARACTER SET=utf8mb4;

-- -----------------------------------------------------
-- Table `ATSDB`.`mp_mapping`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ATSDB`.`mp_mapping` (
  `mp_mapping_id` INT NOT NULL AUTO_INCREMENT,
  `mp_mapping_mp_typ_id_1` INT NOT NULL,
  `mp_mapping_mp_typ_id_2` INT NOT NULL,
  PRIMARY KEY (`mp_mapping_id`),
  INDEX `mp_mapping_mp_typ1_idx` (`mp_mapping_mp_typ_id_1` ASC),
  INDEX `mp_mapping_mp_typ2_idx` (`mp_mapping_mp_typ_id_2` ASC),
  CONSTRAINT `mp_mapping_mp_typ_id_1`
    FOREIGN KEY (`mp_mapping_mp_typ_id_1`)
    REFERENCES `ATSDB`.`mp_typ` (`mp_typ_id`),
  CONSTRAINT `mp_mapping_mp_typ_id_2`
    FOREIGN KEY (`mp_mapping_mp_typ_id_2`)
    REFERENCES `ATSDB`.`mp_typ` (`mp_typ_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARACTER SET=utf8mb4;

-- -----------------------------------------------------
-- Placeholder table for view `ATSDB`.`beacon_left_join_mp`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ATSDB`.`beacon_left_join_mp` (
  `beacon_id` INT,
  `beacon_hub_id` INT,
  `beacon_RSSI` INT,
  `beacon_timestamp` INT,
  `beacon_hub_ts_beginn` INT,
  `beacon_batterie` INT,
  `beacon_MAC` INT,
  `mp_mp_typ_id` INT
);

-- -----------------------------------------------------
-- Placeholder table for view `ATSDB`.`beacon_mp`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ATSDB`.`beacon_mp` (
  `beacon_id` INT,
  `beacon_MAC` INT,
  `beacon_RSSI` INT,
  `beacon_batterie` INT,
  `beacon_hub_id` INT,
  `beacon_timestamp` INT,
  `beacon_hub_ts_beginn` INT,
  `mp_id` INT,
  `mp_name` INT,
  `mp_mp_typ_id` INT
);

-- -----------------------------------------------------
-- Placeholder table for view `ATSDB`.`beacon_raum_bereich`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ATSDB`.`beacon_raum_bereich` (
  `beacon_id` INT,
  `beacon_MAC` INT,
  `beacon_aktiv` INT,
  `beacon_aktiv_seit` INT,
  `beacon_inaktiv_seit` INT,
  `beacon_timestamp` INT,
  `beacon_hub_ts_beginn` INT,
  `beacon_hub_id` INT,
  `raum_id` INT,
  `raum_name` INT,
  `raum_aktiv` INT,
  `raum_aktiv_seit` INT,
  `raum_inaktiv_seit` INT,
  `bereich_name` INT,
  `bereich_id` INT
);

-- -----------------------------------------------------
-- Placeholder table for view `ATSDB`.`hub_raum_bereich`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ATSDB`.`hub_raum_bereich` (
  `hub_id` INT,
  `hub_MAC` INT,
  `hub_aktiv` INT,
  `hub_aktiv_seit` INT,
  `hub_inaktiv_seit` INT,
  `hub_timestamp` INT,
  `hub_raum_ts` INT,
  `raum_id` INT,
  `raum_name` INT,
  `raum_aktiv` INT,
  `raum_aktiv_seit` INT,
  `raum_inaktiv_seit` INT,
  `bereich_name` INT,
  `bereich_id` INT
);

-- -----------------------------------------------------
-- Placeholder table for view `ATSDB`.`mapping_typ_namen`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ATSDB`.`mapping_typ_namen` (
  `mp_mapping_id` INT,
  `mp_typ_name_1` INT,
  `mp_typ_name_2` INT,
  `mp_typ_id_1` INT,
  `mp_typ_id_2` INT
);

-- -----------------------------------------------------
-- Placeholder table for view `ATSDB`.`mp_raum_bereich`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ATSDB`.`mp_raum_bereich` (
  `mp_id` INT,
  `mp_name` INT,
  `mp_SN` INT,
  `mp_mp_typ_name` INT,
  `mp_mp_typ_id` INT,
  `mp_aktiv` INT,
  `mp_aktiv_seit` INT,
  `mp_inaktiv_seit` INT,
  `bereich_name` INT,
  `raum_name` INT,
  `hub_id` INT,
  `mp_beacon_id` INT
);

-- -----------------------------------------------------
-- Placeholder table for view `ATSDB`.`raum_bereich`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ATSDB`.`raum_bereich` (
  `raum_id` INT,
  `raum_name` INT,
  `raum_aktiv` INT,
  `raum_aktiv_seit` INT,
  `raum_inaktiv_seit` INT,
  `bereich_name` INT,
  `bereich_id` INT
);

-- -----------------------------------------------------
-- View `ATSDB`.`beacon_left_join_mp`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `ATSDB`.`beacon_left_join_mp`;
USE `ATSDB`;
CREATE OR REPLACE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `ATSDB`.`beacon_left_join_mp` AS
SELECT `ATSDB`.`beacon`.`beacon_id` AS `beacon_id`,
       `ATSDB`.`beacon`.`beacon_hub_id` AS `beacon_hub_id`,
       `ATSDB`.`beacon`.`beacon_RSSI` AS `beacon_RSSI`,
       `ATSDB`.`beacon`.`beacon_timestamp` AS `beacon_timestamp`,
       `ATSDB`.`beacon`.`beacon_hub_ts_beginn` AS `beacon_hub_ts_beginn`,
       `ATSDB`.`beacon`.`beacon_batterie` AS `beacon_batterie`,
       `ATSDB`.`beacon`.`beacon_MAC` AS `beacon_MAC`,
       `ATSDB`.`mp`.`mp_mp_typ_id` AS `mp_mp_typ_id`
FROM (`ATSDB`.`beacon`
      LEFT JOIN `ATSDB`.`mp` ON (`ATSDB`.`mp`.`mp_beacon_id` = `ATSDB`.`beacon`.`beacon_id`));

-- -----------------------------------------------------
-- View `ATSDB`.`beacon_mp`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `ATSDB`.`beacon_mp`;
USE `ATSDB`;
CREATE OR REPLACE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `ATSDB`.`beacon_mp` AS
SELECT `ATSDB`.`beacon`.`beacon_id` AS `beacon_id`,
       `ATSDB`.`beacon`.`beacon_MAC` AS `beacon_MAC`,
       `ATSDB`.`beacon`.`beacon_RSSI` AS `beacon_RSSI`,
       `ATSDB`.`beacon`.`beacon_batterie` AS `beacon_batterie`,
       `ATSDB`.`beacon`.`beacon_hub_id` AS `beacon_hub_id`,
       `ATSDB`.`beacon`.`beacon_timestamp` AS `beacon_timestamp`,
       `ATSDB`.`beacon`.`beacon_hub_ts_beginn` AS `beacon_hub_ts_beginn`,
       `ATSDB`.`mp`.`mp_id` AS `mp_id`,
       `ATSDB`.`mp`.`mp_name` AS `mp_name`,
       `ATSDB`.`mp`.`mp_mp_typ_id` AS `mp_mp_typ_id`
FROM (`ATSDB`.`beacon`
      JOIN `ATSDB`.`mp` ON (`ATSDB`.`mp`.`mp_beacon_id` = `ATSDB`.`beacon`.`beacon_id`));

-- -----------------------------------------------------
-- View `ATSDB`.`beacon_raum_bereich`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `ATSDB`.`beacon_raum_bereich`;
USE `ATSDB`;
CREATE OR REPLACE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `ATSDB`.`beacon_raum_bereich` AS
SELECT `ATSDB`.`beacon`.`beacon_id` AS `beacon_id`,
       `ATSDB`.`beacon`.`beacon_MAC` AS `beacon_MAC`,
       `ATSDB`.`beacon`.`beacon_aktiv` AS `beacon_aktiv`,
       `ATSDB`.`beacon`.`beacon_aktiv_seit` AS `beacon_aktiv_seit`,
       `ATSDB`.`beacon`.`beacon_inaktiv_seit` AS `beacon_inaktiv_seit`,
       `ATSDB`.`beacon`.`beacon_timestamp` AS `beacon_timestamp`,
       `ATSDB`.`beacon`.`beacon_hub_ts_beginn` AS `beacon_hub_ts_beginn`,
       `ATSDB`.`beacon`.`beacon_hub_id` AS `beacon_hub_id`,
       `hub_raum_bereich`.`raum_id` AS `raum_id`,
       `hub_raum_bereich`.`raum_name` AS `raum_name`,
       `hub_raum_bereich`.`raum_aktiv` AS `raum_aktiv`,
       `hub_raum_bereich`.`raum_aktiv_seit` AS `raum_aktiv_seit`,
       `hub_raum_bereich`.`raum_inaktiv_seit` AS `raum_inaktiv_seit`,
       `hub_raum_bereich`.`bereich_name` AS `bereich_name`,
       `hub_raum_bereich`.`bereich_id` AS `bereich_id`
FROM (`ATSDB`.`beacon`
      LEFT JOIN `ATSDB`.`hub_raum_bereich` ON (`hub_raum_bereich`.`hub_id` = `ATSDB`.`beacon`.`beacon_hub_id`));

-- -----------------------------------------------------
-- View `ATSDB`.`hub_raum_bereich`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `ATSDB`.`hub_raum_bereich`;
USE `ATSDB`;
CREATE OR REPLACE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `ATSDB`.`hub_raum_bereich` AS
SELECT `ATSDB`.`hub`.`hub_id` AS `hub_id`,
       `ATSDB`.`hub`.`hub_MAC` AS `hub_MAC`,
       `ATSDB`.`hub`.`hub_aktiv` AS `hub_aktiv`,
       `ATSDB`.`hub`.`hub_aktiv_seit` AS `hub_aktiv_seit`,
       `ATSDB`.`hub`.`hub_inaktiv_seit` AS `hub_inaktiv_seit`,
       `ATSDB`.`hub`.`hub_timestamp` AS `hub_timestamp`,
       `ATSDB`.`hub`.`hub_raum_ts` AS `hub_raum_ts`,
       `raum_bereich`.`raum_id` AS `raum_id`,
       `raum_bereich`.`raum_name` AS `raum_name`,
       `raum_bereich`.`raum_aktiv` AS `raum_aktiv`,
       `raum_bereich`.`raum_aktiv_seit` AS `raum_aktiv_seit`,
       `raum_bereich`.`raum_inaktiv_seit` AS `raum_inaktiv_seit`,
       `raum_bereich`.`bereich_name` AS `bereich_name`,
       `raum_bereich`.`bereich_id` AS `bereich_id`
FROM (`ATSDB`.`hub`
      LEFT JOIN `ATSDB`.`raum_bereich` ON (`raum_bereich`.`raum_id` = `ATSDB`.`hub`.`hub_raum_id`));

-- -----------------------------------------------------
-- View `ATSDB`.`mapping_typ_namen`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `ATSDB`.`mapping_typ_namen`;
USE `ATSDB`;
CREATE OR REPLACE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `ATSDB`.`mapping_typ_namen` AS
SELECT `ATSDB`.`mp_mapping`.`mp_mapping_id` AS `mp_mapping_id`,
       `mp_typ_1`.`mp_typ_name` AS `mp_typ_name_1`,
       `mp_typ_2`.`mp_typ_name` AS `mp_typ_name_2`,
       `mp_typ_1`.`mp_typ_id` AS `mp_typ_id_1`,
       `mp_typ_2`.`mp_typ_id` AS `mp_typ_id_2`
FROM ((`ATSDB`.`mp_mapping`
       JOIN `ATSDB`.`mp_typ` `mp_typ_1` ON (`ATSDB`.`mp_mapping`.`mp_mapping_mp_typ_id_1` = `mp_typ_1`.`mp_typ_id`))
      JOIN `ATSDB`.`mp_typ` `mp_typ_2` ON (`ATSDB`.`mp_mapping`.`mp_mapping_mp_typ_id_2` = `mp_typ_2`.`mp_typ_id`));

-- -----------------------------------------------------
-- View `ATSDB`.`mp_raum_bereich`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `ATSDB`.`mp_raum_bereich`;
USE `ATSDB`;
CREATE OR REPLACE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `ATSDB`.`mp_raum_bereich` AS
SELECT `ATSDB`.`mp`.`mp_id` AS `mp_id`,
       `ATSDB`.`mp`.`mp_name` AS `mp_name`,
       `ATSDB`.`mp`.`mp_SN` AS `mp_SN`,
       `ATSDB`.`mp_typ`.`mp_typ_name` AS `mp_mp_typ_name`,
       `ATSDB`.`mp_typ`.`mp_typ_id` AS `mp_mp_typ_id`,
       `ATSDB`.`mp`.`mp_aktiv` AS `mp_aktiv`,
       `ATSDB`.`mp`.`mp_aktiv_seit` AS `mp_aktiv_seit`,
       `ATSDB`.`mp`.`mp_inaktiv_seit` AS `mp_inaktiv_seit`,
       `ATSDB`.`bereich`.`bereich_name` AS `bereich_name`,
       `ATSDB`.`raum`.`raum_name` AS `raum_name`,
       `ATSDB`.`hub`.`hub_id` AS `hub_id`,
       `ATSDB`.`mp`.`mp_beacon_id` AS `mp_beacon_id`
FROM (((((`ATSDB`.`mp`
         JOIN `ATSDB`.`mp_typ` ON (`ATSDB`.`mp`.`mp_mp_typ_id` = `ATSDB`.`mp_typ`.`mp_typ_id`))
        LEFT JOIN `ATSDB`.`beacon` ON (`ATSDB`.`mp`.`mp_beacon_id` = `ATSDB`.`beacon`.`beacon_id`))
       LEFT JOIN `ATSDB`.`hub` ON (`ATSDB`.`beacon`.`beacon_hub_id` = `ATSDB`.`hub`.`hub_id`))
      LEFT JOIN `ATSDB`.`raum` ON (`ATSDB`.`hub`.`hub_raum_id` = `ATSDB`.`raum`.`raum_id`))
     LEFT JOIN `ATSDB`.`bereich` ON (`ATSDB`.`raum`.`raum_bereich_id` = `ATSDB`.`bereich`.`bereich_id`));

-- -----------------------------------------------------
-- View `ATSDB`.`raum_bereich`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `ATSDB`.`raum_bereich`;
USE `ATSDB`;
CREATE OR REPLACE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `ATSDB`.`raum_bereich` AS
SELECT `ATSDB`.`raum`.`raum_id` AS `raum_id`,
       `ATSDB`.`raum`.`raum_name` AS `raum_name`,
       `ATSDB`.`raum`.`raum_aktiv` AS `raum_aktiv`,
       `ATSDB`.`raum`.`raum_aktiv_seit` AS `raum_aktiv_seit`,
       `ATSDB`.`raum`.`raum_inaktiv_seit` AS `raum_inaktiv_seit`,
       `ATSDB`.`bereich`.`bereich_name` AS `bereich_name`,
       `ATSDB`.`bereich`.`bereich_id` AS `bereich_id`
FROM (`ATSDB`.`raum`
      JOIN `ATSDB`.`bereich` ON (`ATSDB`.`bereich`.`bereich_id` = `ATSDB`.`raum`.`raum_bereich_id`));

-- -----------------------------------------------------
-- Trigger `ATSDB`.`hub_AFTER_UPDATE`
-- -----------------------------------------------------
DELIMITER $$
CREATE DEFINER=`root`@`localhost` TRIGGER `ATSDB`.`hub_AFTER_UPDATE`
AFTER UPDATE ON `ATSDB`.`hub`
FOR EACH ROW
BEGIN
  IF NOT ISNULL(OLD.hub_raum_id) THEN
    IF OLD.hub_raum_id != NEW.hub_raum_id AND NOT ISNULL(NEW.hub_raum_ts) THEN
      -- Trage Raumänderung in Historientabelle ein.
      INSERT INTO hub_historie (hub_historie_hub_id, hub_historie_raum_id, hub_historie_raum_ts_start, hub_historie_raum_ts_end)
      VALUES (OLD.hub_id, OLD.hub_raum_id, OLD.hub_raum_ts, NEW.hub_raum_ts);
    END IF;
  END IF;
END$$
DELIMITER ;

-- -----------------------------------------------------
-- Trigger `ATSDB`.`beacon_AFTER_UPDATE`
-- -----------------------------------------------------
DELIMITER $$
CREATE DEFINER=`root`@`localhost` TRIGGER `ATSDB`.`beacon_AFTER_UPDATE`
AFTER UPDATE ON `ATSDB`.`beacon`
FOR EACH ROW
BEGIN
  IF OLD.beacon_hub_id != NEW.beacon_hub_id THEN
    IF (SELECT mp_id FROM mp WHERE mp_beacon_id = OLD.beacon_id) IS NOT NULL THEN
      -- Trage Beacon-Änderung in Historientabelle ein.
      INSERT INTO mp_historie (mp_historie_raum_id, mp_historie_mp_id, mp_historie_raum_ts_start, mp_historie_raum_ts_end)
      VALUES ((SELECT hub_raum_id FROM hub WHERE hub_id = OLD.beacon_hub_id), (SELECT mp_id FROM mp WHERE mp_beacon_id = OLD.beacon_id), OLD.beacon_hub_ts_beginn, NEW.beacon_hub_ts_beginn);
    END IF;
  END IF;
END$$
DELIMITER ;

-- -----------------------------------------------------
-- Trigger `ATSDB`.`beaconpair_AFTER_INSERT`
-- -----------------------------------------------------
DELIMITER $$
CREATE DEFINER=`root`@`localhost` TRIGGER `ATSDB`.`beaconpair_AFTER_INSERT`
AFTER INSERT ON `ATSDB`.`beaconpair`
FOR EACH ROW
BEGIN
  -- Implement logic here if needed
END$$
DELIMITER ;

-- Restore SQL modes
SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
