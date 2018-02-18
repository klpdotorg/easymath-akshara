

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL';

CREATE SCHEMA IF NOT EXISTS `abs` DEFAULT CHARACTER SET latin1 COLLATE latin1_swedish_ci ;
USE `abs`;

-- -----------------------------------------------------
-- Table `grade_tbl`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `grade_tbl` ;

CREATE  TABLE IF NOT EXISTS `grade_tbl` (
  `id_grade` INT NOT NULL AUTO_INCREMENT ,
  `description` VARCHAR(30) NULL ,
  PRIMARY KEY (`id_grade`) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `concept_tbl`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `concept_tbl` ;

CREATE  TABLE IF NOT EXISTS `concept_tbl` (
  `id_concept` INT NOT NULL AUTO_INCREMENT ,
  `description` VARCHAR(256) NOT NULL ,
  `id_sequence` INT NULL ,
  PRIMARY KEY (`id_concept`) ,
  CONSTRAINT `fk_sequence_concept`
    FOREIGN KEY (`id_sequence` )
    REFERENCES `concept_tbl` (`id_concept` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `fk_sequence_concept` ON `concept_tbl` (`id_sequence` ASC) ;

-- -----------------------------------------------------
-- Table `micro_concept_tbl`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `micro_concept_tbl` ;

CREATE  TABLE IF NOT EXISTS `micro_concept_tbl` (
  `id_micro_concept` INT NOT NULL AUTO_INCREMENT ,
  `description` VARCHAR(256) NOT NULL ,
  `id_concept` INT NOT NULL ,
  `id_grade` INT NOT NULL ,
  `id_sequence` INT NULL ,
  PRIMARY KEY (`id_micro_concept`) ,
  CONSTRAINT `fk_sequence`
    FOREIGN KEY (`id_sequence` )
    REFERENCES `micro_concept_tbl` (`id_micro_concept` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_grade`
    FOREIGN KEY (`id_grade` )
    REFERENCES `grade_tbl` (`id_grade` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_concept`
    FOREIGN KEY (`id_concept` )
    REFERENCES `concept_tbl` (`id_concept` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `fk_sequence_microconcept` ON `micro_concept_tbl` (`id_sequence` ASC) ;

CREATE INDEX `fk_grade` ON `micro_concept_tbl` (`id_grade` ASC) ;

CREATE INDEX `fk_concept` ON `micro_concept_tbl` (`id_concept` ASC) ;


-- -----------------------------------------------------
-- Table `language_tbl`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `language_tbl` ;

CREATE  TABLE IF NOT EXISTS `language_tbl` (
  `id_language` INT NOT NULL AUTO_INCREMENT ,
  `description` VARCHAR(60) NULL ,
  PRIMARY KEY (`id_language`) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `child_tbl`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `child_tbl` ;

CREATE  TABLE IF NOT EXISTS `child_tbl` (
  `id_child` INT NOT NULL AUTO_INCREMENT ,
  `child_name` VARCHAR(256) NOT NULL ,
  `phone_number` VARCHAR(25) NOT NULL ,
  `age` INT NOT NULL ,
  `id_grade` INT NOT NULL ,
  `school_type` TINYINT(1) NOT NULL ,
  `geo` VARCHAR(256) NOT NULL ,
  `id_language` INT NOT NULL ,
  `organization` VARCHAR(256) NULL ,
  `avatar_pic` VARCHAR(256) NULL, /* picture filename */
  `gender` CHAR(1) NOT NULL, -- B: Boy, G: Girl
  PRIMARY KEY (`id_child`) ,
  KEY (`child_name`,`phone_number`),
  CONSTRAINT `fk_language`
    FOREIGN KEY (`id_language` )
    REFERENCES `language_tbl` (`id_language` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
	/* Set up a unique key constraint for child name and phone number to avoid duplicate kid name for the same phone number */
ENGINE = InnoDB;

CREATE INDEX `fk_language` ON `child_tbl` (`id_language` ASC) ;


-- -----------------------------------------------------
-- Table `question_type_tbl`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `question_type_tbl` ;

CREATE TABLE IF NOT EXISTS `question_type_tbl` ( 
`id_question_type` INT NOT NULL AUTO_INCREMENT ,
`code` VARCHAR(25) NOT NULL ,  
`description` VARCHAR(256) NOT NULL , 
PRIMARY KEY (`id_question_type`)) 
ENGINE = InnoDB; 

-- -----------------------------------------------------
-- Table `question_classification_tbl`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `question_classification_tbl` ;

CREATE TABLE IF NOT EXISTS `question_classification_tbl` ( 
`id_question_classification` INT NOT NULL AUTO_INCREMENT , 
`code` VARCHAR(10)  NULL,
`description` VARCHAR(256) NOT NULL , 
PRIMARY KEY (`id_question_classification`)) 
ENGINE = InnoDB; 


-- -----------------------------------------------------
-- Table `question_tbl`
-- -----------------------------------------------------

DROP TABLE IF EXISTS `question_tbl` ;

CREATE TABLE IF NOT EXISTS `question_tbl` ( 
`idq` INT NOT NULL AUTO_INCREMENT , 
`id_question` VARCHAR(100) NOT NULL , /* A unique varchar identifier as the question ID */
`description` VARCHAR(512) NOT NULL , 
`id_question_type` INT NOT NULL , 
`id_micro_concept` INT NOT NULL , 
`id_level` INT NOT NULL,  /* 1 - beginner; 2 - intermediate ; 3 - expert */ 
`id_question_classification` INT NOT NULL , 
`correct_answer` VARCHAR(500) NULL, /* Not used. (23/1/18)*/
                                    /* 'correct answer' for the question. This field is not being used as the correct answer can not be predefined */
                                    /* (for example, the numbers are randomly generated by the game at the time of */
                                    /* rendering a multiplication question and hence the answer would depend on the numbers generated). */
                                    /* game will return 'Pass' status ('Yes/No') by comparing the correct answer expected and given answer inside the game */ 
`id_game` VARCHAR(100) NOT NULL,
PRIMARY KEY (`idq`) , 
CONSTRAINT `fk_question_type` 
FOREIGN KEY (`id_question_type` ) 
REFERENCES `question_type_tbl` (`id_question_type` ) 
ON DELETE NO ACTION 
ON UPDATE NO ACTION, 
CONSTRAINT `fk_micro_concept` 
FOREIGN KEY (`id_micro_concept` ) 
REFERENCES `micro_concept_tbl` (`id_micro_concept` ) 
ON DELETE NO ACTION 
ON UPDATE NO ACTION, 
CONSTRAINT `fk_question_classification` 
FOREIGN KEY (`id_question_classification` ) 
REFERENCES `question_classification_tbl` (`id_question_classification` ) 
ON DELETE NO ACTION 
ON UPDATE NO ACTION) 
ENGINE = InnoDB; 

-- -----------------------------------------------------
-- Table `game_master_tbl`
-- -----------------------------------------------------

DROP TABLE IF EXISTS `game_master_tbl` ;

CREATE TABLE IF NOT EXISTS `game_master_tbl` ( 
`idg` INT NOT NULL AUTO_INCREMENT , 
`id_game` VARCHAR(100) NOT NULL ,    /* id_game to be a unique varchar instead of autoincrement integer as games can be from multiple vendors */
`game_description` VARCHAR(256) NOT NULL,
`id_grade` INT NOT NULL,
PRIMARY KEY (`idg`)) 
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `game_play_tbl`
-- -----------------------------------------------------

DROP TABLE IF EXISTS `game_play_tbl` ;

CREATE TABLE IF NOT EXISTS `game_play_tbl` ( 
`idgp` INT NOT NULL AUTO_INCREMENT , 
`id_game_play` VARCHAR(100) NOT NULL , /* A unique 10-char idenfitifer for id_game_play. Cannot be autoincrement integer as this ID need to be dynamically created by multiple devices */
`id_game` VARCHAR(100) NOT NULL,
`id_child` INT NOT NULL,
`start_time` datetime not null,
`synced` TINYINT not null default 0,
PRIMARY KEY (`idgp`)) 
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `game_play_detail_tbl`
-- -----------------------------------------------------

DROP TABLE IF EXISTS `game_play_detail_tbl` ;

CREATE TABLE IF NOT EXISTS `game_play_detail_tbl` ( 
`id_game_play_detail` INT NOT NULL AUTO_INCREMENT , 
`id_game_play` VARCHAR(100) NOT NULL , 
`id_child` INT NOT NULL ,
`id_question` VARCHAR(100) NOT NULL , 
/* `answer_given` VARCHAR(500) NOT NULL ,  * Not used (23/1/18). 'actual answer' given by the child. Removing this field as game will return the 'Pass' status*/ 
`date_time_submission` DATETIME NOT NULL,  /* When was the answer submitted to this question */
`time2answer` INT NOT NULL , /*time taken by the child to answer the question in seconds */ 
`pass` VARCHAR(25) NULL , /* Yes/No ('Yes' if 'given answer' and 'correct answer' are same. This comparison will be done within the game and the 'pass' status will be sent by the games ) */
`attempts` INT NULL , /* Number of attempts by the Child before the final submission */
`synced` TINYINT not null default 0,
PRIMARY KEY (`id_game_play_detail`)) 
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `device_accesstoken_tbl`
-- -----------------------------------------------------

DROP TABLE IF EXISTS `device_accesstoken_tbl` ;

CREATE TABLE IF NOT EXISTS `device_accesstoken_tbl` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `access_token` varchar(256) NOT NULL,
  `deviceid` varchar(256) NOT NULL,
  `devicetype` varchar(256) NULL,
  `id_child` int(11) NOT NULL,
  `created_datetime` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `access_token` (`access_token`,`deviceid`, `id_child`)
) ENGINE=InnoDB;


-- -----------------------------------------------------
-- Table `ekstepevent_interact_tbl`
-- -----------------------------------------------------

DROP TABLE IF EXISTS `ekstepevent_interact_tbl` ;

CREATE TABLE IF NOT EXISTS `ekstepevent_interact_tbl` (
  `eventdataid` int(11) NOT NULL AUTO_INCREMENT,
  `id_child` INT NOT NULL ,
  `id_game_play` VARCHAR(100) NOT NULL ,
  `id_question` VARCHAR(100) NOT NULL , 
  `ekstep_eventid` varchar(256) NOT NULL,
  `date_time_event` datetime NOT NULL,
  `event_type` varchar(256) NULL,
  `res_id` varchar(256) NULL,
  `synced` TINYINT not null default 0,
  PRIMARY KEY (`eventdataid`)
) ENGINE=InnoDB;





SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;


INSERT INTO `grade_tbl` (`id_grade`, `description`) VALUES (1, '1st Grade');
INSERT INTO `grade_tbl` (`id_grade`, `description`) VALUES (2, '2nd Grade');
INSERT INTO `grade_tbl` (`id_grade`, `description`) VALUES (3, '3rd Grade');
INSERT INTO `grade_tbl` (`id_grade`, `description`) VALUES (4, '4th Grade');
INSERT INTO `grade_tbl` (`id_grade`, `description`) VALUES (5, '5th Grade');
INSERT INTO `grade_tbl` (`id_grade`, `description`) VALUES (6, '6th Grade');
INSERT INTO `grade_tbl` (`id_grade`, `description`) VALUES (7, '7th Grade');
INSERT INTO `grade_tbl` (`id_grade`, `description`) VALUES (8, '8th Grade');
INSERT INTO `grade_tbl` (`id_grade`, `description`) VALUES (9, '9th Grade');


INSERT INTO `language_tbl` (`id_language`, `description`) VALUES (1, 'Kannada');
INSERT INTO `language_tbl` (`id_language`, `description`) VALUES (2, 'Hindi');
INSERT INTO `language_tbl` (`id_language`, `description`) VALUES (3, 'English');


INSERT INTO `concept_tbl` (`id_concept`, `description`, `id_sequence`) VALUES (1, 'QuantityNumeralAssociation', NULL);
INSERT INTO `concept_tbl` (`id_concept`, `description`, `id_sequence`) VALUES (2, 'Sequence', NULL);
INSERT INTO `concept_tbl` (`id_concept`, `description`, `id_sequence`) VALUES (3, 'PlaceValue', NULL);
INSERT INTO `concept_tbl` (`id_concept`, `description`, `id_sequence`) VALUES (4, 'ComparisionOfNumbers', NULL);
INSERT INTO `concept_tbl` (`id_concept`, `description`, `id_sequence`) VALUES (5, 'AdditionwithQuantity', NULL);
INSERT INTO `concept_tbl` (`id_concept`, `description`, `id_sequence`) VALUES (6, 'NumberBonds', NULL);
INSERT INTO `concept_tbl` (`id_concept`, `description`, `id_sequence`) VALUES (7, 'AdditionUsingPlaceValue', NULL);
INSERT INTO `concept_tbl` (`id_concept`, `description`, `id_sequence`) VALUES (8, 'SubtractionWithQuantity', NULL);
INSERT INTO `concept_tbl` (`id_concept`, `description`, `id_sequence`) VALUES (9, 'SubtractionandAdditionFacts', NULL);
INSERT INTO `concept_tbl` (`id_concept`, `description`, `id_sequence`) VALUES (10, 'SubtractionUsingPlaceValue', NULL);
INSERT INTO `concept_tbl` (`id_concept`, `description`, `id_sequence`) VALUES (11, 'MultiplicationWithQuantity', NULL);
INSERT INTO `concept_tbl` (`id_concept`, `description`, `id_sequence`) VALUES (12, 'MultiplicationTables', NULL);
INSERT INTO `concept_tbl` (`id_concept`, `description`, `id_sequence`) VALUES (13, 'MultiplicationGrid', NULL);
INSERT INTO `concept_tbl` (`id_concept`, `description`, `id_sequence`) VALUES (14, 'LongMultiplication', NULL);
INSERT INTO `concept_tbl` (`id_concept`, `description`, `id_sequence`) VALUES (15, 'DivisonwithQuantity', NULL);
INSERT INTO `concept_tbl` (`id_concept`, `description`, `id_sequence`) VALUES (16, 'DivisionPart1', NULL);
INSERT INTO `concept_tbl` (`id_concept`, `description`, `id_sequence`) VALUES (17, 'DivisionPart2', NULL);


INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (1, 'Oral number name association', 1, 1, NULL);
INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (2, 'Representation', 1, 1, NULL);
INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (3, 'Numeral association', 1, 1, NULL);
INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (4, 'Multiple Choice', 1, 1, NULL);
INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (5, 'Numeral quantity association', 1, 1, NULL);
INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (6, 'Numeral recognition up to 3 digit number', 1, 1, NULL);
INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (7, 'Tracing the numbers', 1, 1, NULL);

INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (8, 'Identifies correct sequence', 2, 1, NULL);
INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (9, 'Arranging', 2, 1, NULL);
INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (10, 'Missing numbers - single digit', 2, 1, NULL);
INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (11, 'Missing numbers - 2 digit ', 2, 2, NULL);
INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (12, 'Missing number - 3 digit', 2, 3, NULL);
INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (13, 'Before and after - single digit', 2, 1, NULL);
INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (14, 'Before and after - 2 digit', 2, 2, NULL);
INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (15, 'Before and after - 3 digit', 2, 3, NULL);
INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (16, 'Between - single digit', 2, 1, NULL);
INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (17, 'Between -2 digit', 2, 2, NULL);
INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (18, 'Between -3 digit', 2, 3, NULL);
INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (19, 'Missing number puzzle - 1to 20', 2, 1, NULL);
INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (20, 'Missing number puzzle - 21 to 99', 2, 2, NULL);
INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (21, 'Missing number puzzle - 100 to 999', 2, 3, NULL);

INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (22, 'Grouping by tens', 3, 1, NULL);
INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (23, 'Identification of number given place value', 3, 1, NULL);
INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (24, 'Representation in Units,Tens, Hundreds', 3, 1, NULL);
INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (25, 'Expansion form', 3, 1, NULL);
INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (26, 'Represent number in place value - Unit, Tens, Hundreds', 3, 1, NULL);
INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (27, 'Identify the place value of a given digit in a number', 3, 1, NULL);

INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (28, 'Grouping by tens', 3, 2, 27);
INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (29, 'Identification of number given place value', 3, 2, 28);
INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (30, 'Representation in Units,Tens, Hundreds', 3, 2, 29);
INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (31, 'Expansion form', 3, 2, 30);
INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (32, 'Represent number in place value - Unit, Tens, Hundreds', 3, 2, 31);
INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (33, 'Identify the place value of a given digit in a number', 3, 2, NULL);

INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (34, 'Grouping by tens', 3, 3, NULL);
INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (35, 'Identification of number given place value', 3, 3, NULL);
INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (36, 'Representation in Units,Tens, Hundreds', 3, 3, NULL);
INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (37, 'Expansion form', 3, 3, NULL);
INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (38, 'Represent number in place value - Unit, Tens, Hundreds', 3, 3, NULL);
INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (39, 'Identify the place value of a given digit in a number', 3, 3, NULL);

INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (40, 'Greater Than and lesser than with quantity only', 4, 1, NULL);
INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (41, 'Equal to with quantity', 4, 1, NULL);
INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (42, 'With symbol: > < = (1 to 20)', 4, 1, NULL);
INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (43, 'With symbol: > < = (21- 99)', 4, 2, NULL);
INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (44, 'With symbol: > < = (100 - 999)', 4, 3, NULL);
INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (45, 'Ascending Order - 1 to 20', 4, 1, NULL);
INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (46, 'Ascending Order  - 21 to 99', 4, 2, NULL);
INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (47, 'Ascending Order - 100- 999', 4, 3, NULL);
INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (48, 'Descending Order - 1to 20', 4, 1, NULL);
INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (49, 'Descending Order - 21 to 99', 4, 2, NULL);
INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (50, 'Descending Order - 100 - 999', 4, 3, NULL);
INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (51, 'Form biggest and smallest number from given digits - 2 digits', 4, 2, NULL);
INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (52, 'Form biggest and smallest number from given digits - 3 digits', 4, 3, NULL);

INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (53, 'Small number - max sum is  9 - Show quantity', 5, 1, NULL);

INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (54, 'Number bonds - fill in the blanks', 6, 1, NULL);

INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (55, 'Addition with Place Value concrete with rods and cubes', 7, 1, NULL);

INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (56, 'Addition with Place Value concrete wth rods and cubes and abstract', 7, 1, 55);
INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (57, 'Addition with Place Vaue abstract without carry', 7, 1, 56);
INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (58, 'Addition with Place Value abstrat with carry', 7, 1, 57);

INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (59, 'Addition with Place Value concrete with rods and cubes', 7, 2, NULL);

INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (60, 'Addition with Place Value concrete wth rods and cubes and abstract', 7, 2, NULL);
INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (61, 'Addition with Place Vaue abstract without carry', 7, 2, NULL);
INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (62, 'Addition with Place Value abstrat with carry', 7, 2, NULL);

INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (63, 'Addition with Place Value concrete with rods and cubes', 7, 3, NULL);
INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (64, 'Addition with Place Value concrete wth rods and cubes and abstract', 7, 3, NULL);
INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (65, 'Addition with Place Vaue abstract without carry', 7, 3, NULL);
INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (66, 'Addition with Place Value abstrat with carry', 7, 3, NULL);

INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (67, 'Subtraction with quantity', 8, 1, NULL);

INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (68, 'Subtraction and addition', 9, 1, NULL);

INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (69, 'Subtraction with place value concrete with rods and cubes', 10, 1, NULL);
INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (70, 'Subtraction with place value with concrete and abstract', 10, 1, NULL);
INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (71, 'Subtraction with place value without borrow', 10, 1, NULL);
INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (72, 'Subtraction with place value with borrow', 10, 1, NULL);

INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (73, 'Subtraction with place value concrete with rods and cubes', 10, 2, NULL);
INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (74, 'Subtraction with place value with concrete and abstract', 10, 2, NULL);
INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (75, 'Subtraction with place value without borrow', 10, 2, NULL);
INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (76, 'Subtraction with place value with borrow', 10, 2, NULL);

INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (77, 'Subtraction with place value concrete with rods and cubes', 10, 3, NULL);
INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (78, 'Subtraction with place value with concrete and abstract', 10, 3, NULL);
INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (79, 'Subtraction with place value without borrow', 10, 3, NULL);
INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (80, 'Subtraction with place value with borrow', 10, 3, NULL);

INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (81, 'Multiplication using repeated addition with representation', 11, 1, NULL);
INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (82, 'Multiplication using repeated addition - arranging in a matrix format ', 11, 1, NULL);

INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (83, 'Multiplication Tables with representation and abstract', 12, 2, NULL);
INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (84, 'Multiplication Tables abstract with fill in the blanks', 12, 2, NULL);
INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (85, 'Multiplication Tables random numbers abstract-1 to 5 tables', 12, 1, NULL);
INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (86, 'Multiplication Tables random numbers abstract - 6 & 7 tables', 12, 2, NULL);
INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (87, 'Multiplication Tables random numbers abstract  - 8 & 9 tables', 12, 2, NULL);

INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (88, 'Multiplication Tables with representation and abstract', 12, 3, NULL);
INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (89, 'Multiplication Tables abstract with fill in the blanks', 12, 3, NULL);

INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (90, 'Multiplication Grid - commutative law', 13, 3, NULL);

INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (91, 'Long multiplication - area method representation', 14, 3, NULL);
INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (92, 'Long Multiplication - area method representation', 14, 3, NULL);

INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (93, 'Equal distribution - representation without remainder', 15, 2, NULL);
INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (94, 'Equal distribution - representation without remainder', 15, 2, NULL);

INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (95, 'Division by Repeated Subtraction - representation', 16, 1, NULL);
INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (96, 'Division by Repeated Subtraction - representation', 16, 1, NULL);
INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (97, 'Division by multiplication', 16, 1, NULL);
INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (98, 'Division by multiplication', 16, 1, NULL);

INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (99, 'Division by Repeated Subtraction - representation', 16, 2, NULL);
INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (100, 'Division by Repeated Subtraction - representation', 16, 2, NULL);
INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (101, 'Division by multiplication', 16, 2, NULL);
INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (102, 'Division by multiplication', 16, 2, NULL);

INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (103, 'Division by Repeated Subtraction - representation', 16, 3, NULL);
INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (104, 'Division by Repeated Subtraction - representation', 16, 3, NULL);
INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (105, 'Division by multiplication', 16, 3, NULL);
INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (106, 'Division by multiplication', 16, 3, NULL);

INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (107, 'Division without remainder 10s and 1s -abstract', 17, 1, NULL);
INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (108, 'Division without remainder representation', 17, 1, NULL);

INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (109, 'Division without remainder 10s and 1s -abstract', 17, 2, NULL);
INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (110, 'Division without remainder representation', 17, 2, NULL);

INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (111, 'Division without remainder 10s and 1s -abstract', 17, 3, NULL);
INSERT INTO `micro_concept_tbl` (`id_micro_concept`, `description`, `id_concept`, `id_grade`, `id_sequence`) VALUES (112, 'Division without remainder representation', 17, 3, NULL);


INSERT INTO `question_type_tbl` (`id_question_type`, `code`, `description`) VALUES (1, 'MTF', 'Match the following'); 
INSERT INTO `question_type_tbl` (`id_question_type`, `code`, `description`) VALUES (2, 'FIB', 'Fill in the blanks'); 
INSERT INTO `question_type_tbl` (`id_question_type`, `code`, `description`) VALUES (3, 'MCQ', 'Multiple choice question'); 
INSERT INTO `question_type_tbl` (`id_question_type`, `code`, `description`) VALUES (4, 'TOF', 'True or False' ); 
INSERT INTO `question_type_tbl` (`id_question_type`, `code`, `description`) VALUES (5, 'RAR', 'Rearrange'); 
INSERT INTO `question_type_tbl` (`id_question_type`, `code`, `description`) VALUES (6, 'WORD', 'Statement or Worded problem'); 

INSERT INTO `question_classification_tbl` (`id_question_classification`, `description`) VALUES (1, 'KNOWLEDGE'); 
INSERT INTO `question_classification_tbl` (`id_question_classification`, `description`) VALUES (2, 'UNDERSTANDING'); 
INSERT INTO `question_classification_tbl` (`id_question_classification`, `description`) VALUES (3, 'APPLICATION');



