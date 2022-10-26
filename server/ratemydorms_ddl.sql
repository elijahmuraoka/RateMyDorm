-- -----------------------------------------------------
-- Schema ratemydorms
-- -----------------------------------------------------
DROP SCHEMA IF EXISTS `ratemydorms`;
CREATE SCHEMA IF NOT EXISTS `ratemydorms`;
USE `ratemydorms` ;

-- -----------------------------------------------------
-- Table `ratemydorms`.`user`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `ratemydorms`.`user` ;

CREATE TABLE IF NOT EXISTS `ratemydorms`.`user` (
  `user_id` INT NOT NULL AUTO_INCREMENT,
  `username` VARCHAR(255) NOT NULL,
  `password` VARCHAR(255) NOT NULL,
  `name` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`user_id`))
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `ratemydorms`.`university`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `ratemydorms`.`university` ;

CREATE TABLE IF NOT EXISTS `ratemydorms`.`university` (
  `university_id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(255) NOT NULL,
  `city` VARCHAR(45) NOT NULL,
  `state` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`university_id`))
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `ratemydorms`.`building`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `ratemydorms`.`building` ;

CREATE TABLE IF NOT EXISTS `ratemydorms`.`building` (
  `building_id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(255) NOT NULL,
  `street_address` VARCHAR(255) NOT NULL,
  `avg_rating` DECIMAL(2, 1) NOT NULL DEFAULT 0,
  `num_ratings` INT NOT NULL DEFAULT 0,
  `university_id` INT NOT NULL,
  PRIMARY KEY (`building_id`, `university_id`),
  INDEX `fk_building_university1_idx` (`university_id` ASC) VISIBLE,
  CONSTRAINT `fk_building_university1`
    FOREIGN KEY (`university_id`)
    REFERENCES `ratemydorms`.`university` (`university_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `ratemydorms`.`dorm`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `ratemydorms`.`dorm` ;

CREATE TABLE IF NOT EXISTS `ratemydorms`.`dorm` (
  `dorm_id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(255) NOT NULL,
  `occupancy` INT NOT NULL,
  `price` INT NOT NULL,
  `avg_rating` DECIMAL(2, 1) NOT NULL DEFAULT 0,
  `building_id` INT NOT NULL,
  PRIMARY KEY (`dorm_id`, `building_id`),
  INDEX `fk_dorm_building1_idx` (`building_id` ASC) VISIBLE,
  CONSTRAINT `fk_dorm_building1`
    FOREIGN KEY (`building_id`)
    REFERENCES `ratemydorms`.`building` (`building_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `ratemydorms`.`rating`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `ratemydorms`.`rating` ;

CREATE TABLE IF NOT EXISTS `ratemydorms`.`rating` (
  `rating_id` INT NOT NULL AUTO_INCREMENT,
  `room_rating` INT NOT NULL,
  `bathroom_rating` INT NOT NULL,
  `building_rating` INT NOT NULL,
  `location_rating` INT NOT NULL,
  `descr` VARCHAR(1000) NOT NULL,
  `num_upvotes` INT NOT NULL DEFAULT 0,
  `num_downvotes` INT NOT NULL DEFAULT 0,
  `user_id` INT NOT NULL,
  `dorm_id` INT NOT NULL,
  PRIMARY KEY (`rating_id`, `user_id`, `dorm_id`),
  INDEX `fk_rating_user_idx` (`user_id` ASC) VISIBLE,
  INDEX `fk_rating_dorm1_idx` (`dorm_id` ASC) VISIBLE,
  CONSTRAINT `fk_rating_user`
    FOREIGN KEY (`user_id`)
    REFERENCES `ratemydorms`.`user` (`user_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_rating_dorm1`
    FOREIGN KEY (`dorm_id`)
    REFERENCES `ratemydorms`.`dorm` (`dorm_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;
    
-- -----------------------------------------------------
-- Table `ratemydorms`.`comment`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `ratemydorms`.`comment` ;

CREATE TABLE IF NOT EXISTS `ratemydorms`.`comment` (
  `comment_id` INT NOT NULL AUTO_INCREMENT,
  `descr` VARCHAR(1000) NOT NULL,
  `num_upvotes` INT NOT NULL DEFAULT 0,
  `num_downvotes` INT NOT NULL DEFAULT 0,
  `user_id` INT NOT NULL,
  `rating_id` INT NOT NULL,
  PRIMARY KEY (`comment_id`, `user_id`, `rating_id`),
  INDEX `fk_comment_rating1_idx` (`rating_id` ASC) VISIBLE,
  INDEX `fk_comment_user1_idx` (`user_id` ASC) VISIBLE,
  CONSTRAINT `fk_comment_rating1`
    FOREIGN KEY (`rating_id`)
    REFERENCES `ratemydorms`.`rating` (`rating_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_comment_user1`
    FOREIGN KEY (`user_id`)
    REFERENCES `ratemydorms`.`user` (`user_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

-- ---------------------------------------------------

insert into user(username, password, name) values 
	("firstyearneu", "ilovepuppies", "David Alade"),
	("cooper", "joespehaoun", "Joeseph Aoun"),
	("john", "29292", "Emily Sish"),
	("westen", "dkiikd3o9", "Molly Westen"),
	("falls", "jid3d392hc", "Gravity Falls"),
	("Mordecai", "929d2jd", "Rigby Mordecai"),
	("Advtime", "comongra", "Jake Finn"),
	("Spgbob", "square", "Bob Pants"),
	("Eli", "NFTsrcool", "Elijah"),
	("Aden", "Swimmerw229", "Aden Lue"),
	("Niko", "ManU292", "Niko Trip"),
	("Jiwoo", "U029", "Ben Yoon"),
	("Squiggley", "i338", "Owen Quigley"),
	("Yassir", "2uc3", "Yassir Soukaki"),
	("gregg", "iamgregg", "Gregg"),
	("matt", "guyfromwii", "Matt");
    
insert into university(name, city, state) values
	("Northeastern University", "Boston", "MA"), -- users 1 and 2 and 11 and 13 and 16
	("Boston University", "Boston", "MA"), -- users 3 and 4 and 12
	("Emerson College", "Boston", "MA"), -- user 5 and 9 and 14
	("University of Pennsylvania", "Philadelphia", "PA"), -- user 6 and 10
	("Stanford University", "Palo Alto", "CA"); -- user 7 and 8 and 15
    
insert into building(name, street_address, university_id) values
	("White Hall","21 Forsyth St", 1),
	("East Village","291 Botolph St", 1),
	("International Village","131 Tremont", 1),
	("Warren Towers","2 Green Acres St", 2),
	("Charles River House", "179 Charles St", 2),
	("River Tower", "178 Charles St", 2),
	("Park Ave", "19 Park St", 3),
	("Eight St", "17 Dover Rd", 3),
	("Rocks", "2930 Sherborn Ave", 3),
	("Walnut", "171 Campus Dr", 4),
	("Gryffindor", "173 Campus Dr", 4),
	("Sarker", "176 Campus Dr", 4),
	("Neighbors", "139 Westen St", 5),
	("Torubles", "100 Champlain Rd", 5),
	("Edges", "91 Champlain Rd", 5);
    
insert into dorm(name, occupancy, price, building_id) values
	('White Hall single', 1, 4800, 1),
	('White Hall double', 2, 4600, 1),
	('White Hall triple', 3, 4400, 1),
	('East Village single', 1, 5600, 2),
	('East Village double', 2, 5500, 2),
	('International Village single', 1, 6700, 3),
	('International Village double', 2, 6500, 3),
	('Warren Towers single', 1, 7400, 4),
	('Warren Towers double', 2, 5500, 4),
	('Warren Towers triple', 3, 5000, 4),
	('Charles River House double', 2, 5000, 5),
	('Charles River House triple', 3, 4700, 5),
	('River Tower single', 1, 7700, 6),
	('River Tower double', 2, 7000, 6),
	('River Tower triple', 3, 6300, 6),
	('Park Ave single', 1, 3300, 7),
	('Park Ave double', 2, 3000, 7),
	('Park Ave triple', 3, 3000, 7),
	('Eight St single', 1, 6300, 8),
	('Eight St double', 2, 5500, 8),
	('Rocks single', 1, 4000, 9),
	('Rocks double', 2, 3700, 9),
	('Rocks triple', 3, 3400, 9),
	('Walnut single', 1, 4900, 10),
	('Walnut double', 2, 4600, 10),
	('Walnut triple', 3, 4300, 10),
	('Gryffindor single', 1, 4600, 11),
	('Gryffindor double', 2, 4400, 11),
	('Gryffindor triple', 3, 4300, 11),
	('Sarker single', 1, 9000, 12),
	('Sarker double', 2, 8700, 12),
	('Sarker triple', 3, 7700, 12),
	('Neighbors single', 1, 6000, 13),
	('Neighbors double', 2, 5500, 13),
	('Torubles single', 1, 4400, 14),
	('Torubles double', 2, 4200, 14),
	('Torubles triple', 3, 4000, 14),
	('Edges single', 1, 9000, 15),
	('Edges double', 2, 8500, 15),
	('Edges triple', 3, 8000, 15);
    
DROP TRIGGER IF EXISTS rating_check;

DELIMITER //

CREATE TRIGGER rating_check
	BEFORE INSERT ON rating
    FOR EACH ROW
BEGIN
	IF (NEW.room_rating NOT BETWEEN 1 AND 5 OR
		NEW.bathroom_rating NOT BETWEEN 1 AND 5 OR
        NEW.building_rating NOT BETWEEN 1 AND 5 OR
        NEW.location_rating NOT BETWEEN 1 AND 5) 
	THEN
		SIGNAL SQLSTATE 'HY000' SET message_text = 'Ratings are on a scale from 1-5';
	END IF;
END; //

DELIMITER ;

DROP TRIGGER IF EXISTS insert_rating;

DELIMITER //

CREATE TRIGGER insert_rating
	AFTER INSERT ON rating
	FOR EACH ROW
BEGIN
	DECLARE new_rating_avg decimal(2,1);
    DECLARE dorm_id_of_rating int;
    DECLARE dorm_num_ratings_before_insert int;
    DECLARE building_id_of_rating int;
    DECLARE building_num_ratings_before_insert int;
    DECLARE dorm_avg_rating_before_insert decimal(2,1);
	DECLARE building_avg_rating_before_insert decimal(2,1);
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  
    IF (NEW.room_rating BETWEEN 1 AND 5 AND
		NEW.bathroom_rating BETWEEN 1 AND 5 AND
        NEW.building_rating BETWEEN 1 AND 5 AND
        NEW.location_rating BETWEEN 1 AND 5) 
	THEN 
		SELECT (NEW.room_rating + NEW.bathroom_rating + NEW.building_rating + NEW.location_rating) / 4
		INTO new_rating_avg;
		
		SELECT dorm_id
		INTO dorm_id_of_rating
		FROM rating
		WHERE rating_id = NEW.rating_id;
		
		SELECT count(rating_id)
		INTO dorm_num_ratings_before_insert
		FROM rating
		WHERE dorm_id = dorm_id_of_rating;
		
		SELECT building_id
		INTO building_id_of_rating
		FROM dorm
		WHERE dorm_id = dorm_id_of_rating;
		
		SELECT count(rating_id)
		INTO building_num_ratings_before_insert
		FROM 
			rating JOIN 
			dorm d USING (dorm_id)
		WHERE building_id = building_id_of_rating;
		
		SELECT avg_rating
		INTO dorm_avg_rating_before_insert
		FROM dorm
		WHERE dorm_id = dorm_id_of_rating;

		SELECT avg_rating
		INTO building_avg_rating_before_insert
		FROM building 
		WHERE building_id = building_id_of_rating;
        
		UPDATE dorm
		SET avg_rating = (dorm_avg_rating_before_insert * dorm_num_ratings_before_insert + new_rating_avg) / (dorm_num_ratings_before_insert + 1)
		WHERE dorm_id = dorm_id_of_rating;
        
		UPDATE building
		SET avg_rating = (building_avg_rating_before_insert * building_num_ratings_before_insert + new_rating_avg) / (building_num_ratings_before_insert + 1),
			num_ratings = building_num_ratings_before_insert + 1
		WHERE building_id = building_id_of_rating;
	END IF;
END //

DELIMITER ;

DROP TRIGGER IF EXISTS delete_rating;

DELIMITER //

CREATE TRIGGER delete_rating
	AFTER DELETE ON rating
	FOR EACH ROW
BEGIN
	DECLARE deleted_rating_avg decimal(2,1);
    DECLARE dorm_id_of_deleted_rating int;
    DECLARE dorm_num_ratings_after_delete int;
    DECLARE building_id_of_deleted_rating int;
    DECLARE building_num_ratings_after_delete int;
    DECLARE new_dorm_avg_rating decimal(2,1);
	DECLARE new_building_avg_rating decimal(2,1);
    
	SELECT (OLD.room_rating + OLD.bathroom_rating + OLD.building_rating + OLD.location_rating) / 4
	INTO deleted_rating_avg;
    
    SELECT dorm_id
    INTO dorm_id_of_deleted_rating
    FROM rating
    WHERE rating_id = OLD.rating_id;
    
    SELECT count(rating_id)
    INTO dorm_num_ratings_after_delete
    FROM rating
    WHERE dorm_id = dorm_id_of_deleted_rating;
    
	SELECT building_id
    INTO building_id_of_deleted_rating
    FROM dorm
    WHERE dorm_id = dorm_id_of_deleted_rating;
    
    SELECT count(rating_id)
    INTO building_num_ratings_after_delete
    FROM 
		rating JOIN 
        dorm USING (dorm_id)
	WHERE building_id = building_id_of_deleted_rating;
    
	SELECT ROUND(((avg_rating * (dorm_num_ratings_after_delete + 1)) - deleted_rating_avg) / dorm_num_ratings_after_delete, 1)
    INTO new_dorm_avg_rating
    FROM dorm
    WHERE dorm_id = dorm_id_of_deleted_rating;
    
    SELECT ROUND(((avg_rating * (building_num_ratings_after_delete + 1)) - deleted_rating_avg) / building_num_ratings_after_delete, 1)
    INTO new_building_avg_rating
    FROM building 
    WHERE building_id = building_id_of_deleted_rating;

	UPDATE dorm
    SET avg_rating = new_dorm_avg_rating
    WHERE dorm_id = dorm_id_of_deleted_rating;
    
    UPDATE building
    SET avg_rating = new_building_avg_rating,
		num_ratings = building_num_ratings_after_delete
	WHERE building_id = building_id_of_deleted_rating;
END //

DELIMITER ;
    
INSERT INTO rating (room_rating, bathroom_rating, building_rating, location_rating, descr, 
num_upvotes, num_downvotes, user_id, dorm_id) VALUES
    (5,1,4,5,"No complaints except bathrooms were communal", 48, 57, 3, 6), -- dorm 6 -
	(2,1,2,2,"Overall not a great dorm to live in", 82, 23, 4, 4), -- dorm 4 -
	(5,5,5,5,"White hall is the best dorm", 45, 1, 1, 1), -- dorm 1 -
	(5,5,3,5,"My room was in great condition but the building needs to be cleaned", 22, 20, 2, 2), -- dorm 2 -
	(4,4,4,5,"Great dorm overall", 29, 2, 2, 1), -- dorm 1 -
	(3,5,3,3,"Private bathrooms but rooms were dirtyy upon arrival and building is off campus", 2, 1, 3, 4), -- dorm 4 -
	(2,2,2,2,"Not a great place to live, very expensive and hard to get to campus", 10, 34, 3, 5), -- dorm 5 -
	(1,1,1,1,"Awful dorm DO NOT choose to live here", 26, 84, 4, 5), -- dorm 5 -
	(5,3,5,5,"Very modern dorm as it was just built but shower pressure is very bad", 92, 23, 1, 2), -- dorm 2 -
	(2,5,5,2,"Located very far from campus and walls are very thin", 23, 30, 1, 3), -- dorm 3 -
	(5,3,5,4,"Overall very good dorm, but bathrooms are unclean", 27, 52, 4, 6), -- dorm 6 -
	(4,4,4,4,"Solid place to live, not the best dorm on campus but very comfortable", 23, 23, 5, 7), -- dorm 7 -
	(1,1,5,5,"Right in the middle of campus but very small living space and bathroom", 3, 9, 5, 8), -- dorm 8 -
	(5,5,5,1,"Too far from campus, car required", 5, 2, 5, 9), -- dorm 9 -
	(5,5,5,5,"I had a great experience here", 38, 85, 6, 10), -- dorm 10 -
	(5,4,5,3,"Only qualm was the walk from the dorm to the dining hall", 29, 2, 6, 11), -- dorm 11 -
	(5,5,5,5,"No complaints", 56, 93, 6, 12), -- dorm 12 -
	(1,5,2,5,"The room was very small and lacked windows", 47, 55, 7, 13), -- dorm 13 -
	(1,1,1,1,"Strongly advise to not room here", 23, 23, 8, 13), -- dorm 13 -
	(3,5,4,5,"Great location and bathroom", 22, 28, 16, 3), -- dorm 3 -
	(5,4,5,4,"Great choice for a dorm", 64, 7, 7, 14), -- dorm 14 -
	(2,2,5,5,"The building was new but rooms were packed and so were the bathrooms", 2, 23, 8, 14), -- dorm 14 -
	(1,3,5,1,"Too far from campus and also small rooms", 2, 3, 7, 15), -- dorm 15 -
	(1,3,3,3,"Not a very good dorm compared to other options", 99, 25, 8, 15), -- dorm 15 -
	(2,2,4,3,"Bathroom is not connected to room", 29, 52, 2, 3), -- dorm 3 -
	(5,5,4,4,"Great dorm experience", 192, 92, 11, 1), -- dorm 1  -
	(5,4,5,4,"I had a very good time here", 82, 29, 11, 2), -- dorm 2 -
	(4,4,5,4,"Solid dorm", 29, 22, 11, 3), -- dorm 3 -
	(5,1,5,5,"Bathrooms were never cleaned", 59, 56, 12, 4), -- dorm 4 -
	(1,1,2,2,"Packed dorm and building was very old", 75, 92, 12, 5), -- dorm 5 -
	(3,3,4,3,"Rooms were fine but nothing extraordinary", 94, 65, 12, 6), -- dorm 6 -
	(2,2,3,1,"Too far from campus", 82, 1, 9, 7), -- dorm 7 -
	(4,5,4,4,"Good dorm strongly reccomend", 92, 100, 9, 8), -- dorm 8 -
	(3,3,2,4,"Building was dirty", 74, 45, 9, 9), -- dorm 9 -
	(5,4,3,2,"Good dorm but not close to any dining halls", 29, 69, 10, 10), -- dorm 10 -
	(2,1,4,3,"Bathroom and dorm was shared amongst 5 students", 282, 37, 10, 11), -- dorm 11 -
	(5,3,4,2,"Good experience but location was not good", 92, 64, 10, 12), -- dorm 12 -
	(4,4,2,3,"Building is not aesthetically pleasing", 19, 35, 13, 1), -- dorm 1 -
	(4,2,3,3,"Bathrooms should be cleaned more often", 92, 72, 13, 2), -- dorm 2 -
	(4,5,3,5,"Good dorm but building was not well kept", 38, 45, 13, 3), -- dorm 3 -
	(1,2,1,5,"Location is great but that is it", 28, 12, 14, 7), -- dorm 7 -
	(4,5,5,2,"Everything is great other that location", 1, 12, 14, 8), -- dorm 8 -
	(3,4,5,1,"Location is very bad", 22, 75, 15, 13), -- dorm 13 -
	(5,1,2,3,"There is only one bathroom in the building", 2, 1, 15, 14), -- dorm 14 -
	(1,3,4,3,"Rooms were made smaller in the remodeling", 4, 3, 15, 15); -- dorm 15 -

INSERT INTO comment (descr, num_upvotes, num_downvotes, user_id, rating_id) VALUES
	("couldn't agree more IV is far away from most things", 28, 2, 1, 10),
    ("no ur opinion is bad", 2, 9, 2, 3),
    ("I think its also good to add that those rooms were very clean", 2, 0, 2, 9),
    ("I'll add that this dorm is very close to the river", 19, 4, 4, 7),
    ("I don't really think this is a representative review", 2, 9, 4, 29),
    ("sure", 0, 11, 5, 33),
    ("I don't really agree my experience was that the dorm was too cramped", 22, 19, 14, 34),
    ("Good review", 0, 0, 7, 24),
    ("I think you are right but it is important to mention that it depends on your RA", 22, 0, 7, 19),
    ("That dorm sucks", 0, 9, 10, 15),
    ("That dorm sucks", 0, 11, 10, 16),
    ("That dorm sucks", 0, 22, 10, 17),
    ("I honestly think I had my best experience in that dorm", 32, 2, 13, 28),
    ("As long as your roommates are good you will be fine", 18, 0, 16, 39),
    ("I can't agree with your opinion I had the complete opposite experience", 5, 3, 11, 5);
    
select * from user;
SELECT * FROM comment;
SELECT * FROM rating;
SELECT * FROM dorm;
SELECT * FROM building;
select * from university;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;