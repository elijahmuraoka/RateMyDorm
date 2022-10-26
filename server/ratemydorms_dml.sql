-- Welcome to the Rate My Dorms MySQL Database!
-- by Michael Long, Elijah Muraoka, and Dheeraj Valluru
/*
This SQL Script is divided up into 4 key sections:
    (1) - Queries
    (2) - Stored Procedures
    (3) = Triggers
    (4) - Testing
*/

use ratemydorms;

-- (1) [QUERIES] ---------------------------------------------------------------------------------

SELECT 
    *
FROM
    building;
SELECT 
    *
FROM
    comment;
SELECT 
    *
FROM
    dorm;
SELECT 
    *
FROM
    rating;
SELECT 
    *
FROM
    university;
SELECT 
    *
FROM
    user;

-- More useful queries!

SELECT 
    u.name,
    u.state,
    b.name,
    d.name,
    d.occupancy,
    d.avg_rating,
    d.price
FROM
    dorm d
        LEFT JOIN
    building b USING (building_id)
        LEFT JOIN
    university u USING (university_id)
ORDER BY u.name , b.name , d.price;

-- Sorts colleges' dorms by building and then occupancy in ascending order (highest first)

SELECT 
    u.name, u.state, b.name, d.name, d.occupancy, d.price
FROM
    dorm d
        JOIN
    building b USING (building_id)
        LEFT JOIN
    university u USING (university_id)
ORDER BY b.name , d.occupancy DESC;

-- Sorts all buildings by rating at any college

SELECT 
    u.name, b.name, b.avg_rating
FROM
    university u
        LEFT JOIN
    building b USING (university_id)
ORDER BY u.name , b.avg_rating DESC;

-- Sorts all buildings by rating for Northeastern University
 
SELECT 
    u.name, b.name, b.avg_rating
FROM
    university u
        LEFT JOIN
    building b USING (university_id)
WHERE
    u.name LIKE 'Northeastern University'
ORDER BY u.name , b.avg_rating DESC;
 
-- Sorts all universities by buildings' highest average rating first,
-- which dorms have the highest rated dorms overall

SELECT 
    u.name,
    IFNULL(ROUND(AVG(b.avg_rating), 2),
            'no ratings yet') AS uni_overall_rating
FROM
    university u
        JOIN
    building b USING (university_id)
GROUP BY u.name
ORDER BY uni_overall_rating DESC;

-- Finds a single review's average rating by summing all of its individual column rating inputs and dividing it by four

SELECT 
    d.name,
    ROUND(((r.room_rating + r.bathroom_rating + r.building_rating + r.location_rating) / 4),
            2) AS 'avg_rating'
FROM
    rating r
        JOIN
    dorm d USING (dorm_id)
ORDER BY d.building_id , d.occupancy , avg_rating DESC;

-- Sort USERS by the total # of upvotes they have received

SELECT 
    u.username, (SUM(r.num_upvotes)) AS total_upvotes
FROM
    user u
        LEFT JOIN
    rating r USING (user_id)
GROUP BY u.username
ORDER BY total_upvotes DESC;

-- Sort USERS by the total # of upvotes they have received

SELECT 
    u.username, (SUM(r.num_downvotes)) AS total_downvotes
FROM
    user u
        LEFT JOIN
    rating r USING (user_id)
GROUP BY u.username
ORDER BY total_downvotes DESC;

-- Sort USERS by the total # of ratings they have done

SELECT 
    u.username, COUNT(r.rating_id) AS num_ratings
FROM
    user u
        LEFT JOIN
    rating r USING (user_id)
GROUP BY u.username
ORDER BY num_ratings DESC;

-- Sort USERS by the average # of upvotes they have received per post,
-- including both comments and ratings (popular opinion)

SELECT 
    u.username,
    IFNULL(ROUND((AVG(r.num_upvotes) + AVG(c.num_upvotes)) / 2,
                    0),
            0) AS avg_upvotes
FROM
    user u
        LEFT JOIN
    rating r USING (user_id)
        LEFT JOIN
    comment c USING (user_id)
GROUP BY u.username
ORDER BY avg_upvotes DESC;

-- Sort USERS by the average # of downvotes they have received per post,
-- including both comments and ratings (least popular opinion)

SELECT 
    u.username,
    IFNULL(ROUND((AVG(r.num_downvotes) + AVG(c.num_downvotes)) / 2,
                    0),
            0) AS avg_downvotes
FROM
    user u
        LEFT JOIN
    rating r USING (user_id)
        LEFT JOIN
    comment c USING (user_id)
GROUP BY u.username
ORDER BY avg_downvotes DESC;

-- (2) [STORED PROCEDURES] ----------------------------------------------------------------------------------
-- stored procedure template

drop procedure if exists sampleProcedure;

delimiter //
create procedure sampleProcedure (
	-- determine your parameters
	in variable_param varchar(255)
    )
    
begin

-- declare your variables to assign values later on
declare field_var varchar(255);

-- select relevant values into variables

-- write the procedure

end //
delimiter ;

-- ------------------------------------------------- START ----------------------------------------------------

-- Show all dorms sorted by cheapest price

drop procedure if exists sortByPrice;

delimiter //
create procedure sortByPrice ()
    
begin

select u.name, u.state, b.name, d.name, occupancy, d.price
from dorm d
left join building b
using (building_id)
left join university u
using (university_id)
order by u.name, b.name, d.price;

end //
delimiter ;

-- Show all dorms sorted by housing occupancy

drop procedure if exists sortByHousingOccupancy;

delimiter //
create procedure sortByHousingOccupancy ()
    
begin

declare field_var varchar(255);

select u.name, u.state, b.name, d.name, d.occupancy, d.price
from dorm d
join building b
using (building_id)
left join university u
using (university_id)
order by b.name, d.occupancy desc;

end //
delimiter ;

-- Show all buildings at each university sorted by highest ratings first

drop procedure if exists sortByRating;

delimiter //
create procedure sortByRating ()
    
begin

select u.name, b.name, b.avg_rating
from university u
left join building b
using (university_id)
order by u.name, b.avg_rating desc;

end //
delimiter ;

-- Sort all buildings by "Best Value", 
-- which is essentially the best rating per dollar for a given dorm.
-- Shows the dorms most highly recommended by our algorithm first

drop procedure if exists sortDormsByBestValue;

delimiter // 
create procedure sortDormsByBestValue()

begin

select 
	u.name, 
    d.name,
    d.occupancy,
    d.price, 
	d.avg_rating
from dorm d
join building b using (building_id)
join university u using (university_id)
group by u.name, b.name, d.name, d.avg_rating, d.price, d.occupancy
order by u.name, b.name, (d.avg_rating/avg(d.price)) desc;

end //
delimiter ;

-- Sorts all dorms by price for a given university, 
-- either by cheapest to most expensive or vice versa

DROP PROCEDURE IF EXISTS searchByPrice;

DELIMITER //
CREATE PROCEDURE searchByPrice
(
	IN university_name_param VARCHAR(255),
    IN sort_order_param varchar(255)
)
BEGIN

 if (university_name_param not in (select u.name from university u) or university_name_param is null) then
		signal sqlstate 'HY000' set message_text = "The university is not in the database";
end if;

if ((sort_order_param != 'high' and sort_order_param != 'low') or sort_order_param is null) then
		signal sqlstate 'HY000' set message_text = 'Must enter either "high" or "low" to filter your search.';
end if;

	IF (sort_order_param = 'low') THEN
		select b.name, d.name, d.avg_rating, d.price
		from dorm d
		left join building b
		using (building_id)
		left join university u
		using (university_id)
        where u.name LIKE university_name_param
		order by d.price;
    
	else IF (sort_order_param = 'high') THEN
		select b.name, d.name, d.avg_rating, d.price
		from dorm d
		left join building b
		using (building_id)
		left join university u
		using (university_id)
        where u.name LIKE university_name_param
		order by d.price DESC;
	
	END IF;
    End if;

END //
DELIMITER ;

-- Search for the most popular reviews on a specific dorm (ratings with the most upvotes)

DROP PROCEDURE IF EXISTS findTopRatings;

DELIMITER //
CREATE PROCEDURE findTopRatings
(
    IN dorm_name_param varchar(255)
)

BEGIN

declare message varchar(255);

if (dorm_name_param is not null and dorm_name_param in (select d.name from dorm d)) then
	select d.name, d.occupancy, d.price, r.room_rating, r.bathroom_rating, r.building_rating, r.location_rating, d.avg_rating, r.descr, r.num_upvotes
    from dorm d
    join rating r using (dorm_id)
    where d.name like dorm_name_param
    order by r.num_upvotes desc;
    
    else 
    select "Please input a valid dorm to search the database." into message;
		signal sqlstate 'HY000' set message_text = message;
End if;
    
END //
DELIMITER ;

-- Returns all dorms for a given university and a given occupancy

DROP PROCEDURE IF EXISTS searchByOccupancy;

DELIMITER //
CREATE PROCEDURE searchByOccupancy
(
	IN university_name_param VARCHAR(255),
    IN occupancy_param INT
)
BEGIN

 if ((university_name_param in (select name from university)) and university_name_param is not null and occupancy_param > 0) then
	select b.name as 'building', d.name as 'room_type', d.avg_rating as 'rating', d.price
	from dorm d
	join building b
	using (building_id)
	left join university u
	using (university_id)
    where u.name LIKE university_name_param AND d.occupancy = occupancy_param
	order by b.avg_rating desc;
else if (occupancy_param < 0) then
	signal sqlstate 'HY000' set message_text = "Housing occupancy cannot be negative";
else 
signal sqlstate 'HY000' set message_text = "Please insert valid search parameters into the database.";

End if;
End if;

END //
DELIMITER ;

-- Given a University, order all its buildings then dorms by "Best Value", 
-- which is essentially the best rating per dollar for a given dorm.
-- Shows the dorms most highly recommended by our algorithm first

drop procedure if exists searchUniDormsByBestValue;

delimiter // 
create procedure searchUniDormsByBestValue (
	in university_name_param varchar(255)
)

begin

if ((university_name_param in (select name from university)) and university_name_param is not null) then
select 
	d.name, 
    d.price, 
    d.occupancy
from dorm d
join building b using (building_id)
join university u using (university_id)
where u.name like university_name_param
order by (d.avg_rating/d.price) desc;
else 
		signal sqlstate 'HY000' set message_text = "This university is not in the database yet.";
end if;


end //
delimiter ;

drop procedure if exists searchRatingsBound;
 
 delimiter //
 
 create procedure searchRatingsBound(
 
 in max_or_min_param varchar(10),
 in rating_param double

 )
 
 begin
 
 if(max_or_min_param like "max") then
 select r.room_rating, r.descr, d.name as "dorm name", d.occupancy, b.name "building name", u.name "university name"
 from rating r
 left join dorm d using (dorm_id)
 left join building b using (building_id)
 left join university u using (university_id)
 where r.room_rating <= rating_param;
 end if;
 
 if(max_or_min_param like "min") then
 select r.room_rating, r.descr, d.name as "dorm name", d.occupancy, b.name "building name", u.name "university name"
 from rating r
 left join dorm d using (dorm_id)
 left join building b using (building_id)
 left join university u using (university_id)
 where r.room_rating >= rating_param;
 end if;
 
if((max_or_min_param != "max" and max_or_min_param != "min") 
or max_or_min_param is null
or rating_param is null) then
SIGNAL SQLSTATE 'HY000' SET MESSAGE_TEXT = 'Must enter either "min" or "max" to filter your search.';
end if;

if(0 > rating_param or rating_param > 5) then
SIGNAL SQLSTATE 'HY000' SET MESSAGE_TEXT = 'Must enter a rating value between 0 and 5.';
end if;
 
 end //
 
 delimiter ;

-- Shows USER statistics when given a specific username

drop procedure if exists showUserStats;

delimiter //
create procedure showUserStats(
	in username_param varchar(45)
)

begin

if ((username_param in (select username from user)) and username_param is not null) then
select 
	u.username,
	(select count(rating_id) 
    from rating
    where username like username_param)
    as 'total ratings', 
	(select count(comment_id) 
    from comment
    where username like username_param)
    as 'total comments', 
	ifnull(round(avg(r.num_upvotes), 2), 'user has not posted a rating yet') as 'average upvotes per rating', 
	ifnull(round(avg(r.num_downvotes), 2), 'user has not posted a rating yet') as 'average downvotes per rating',
    ifnull(round(avg(c.num_upvotes), 2), 'user has not posted a comment yet') as 'average upvotes per comment', 
	ifnull(round(avg(c.num_downvotes), 2), 'user has not posted a comment yet')  as 'average downvotes per comment'
from user u
left join rating r using (user_id)
left join comment c using (user_id)
where username like username_param
group by username;
else 
signal sqlstate 'HY000' set message_text = "This username is not in the database yet.";
end if;

end //
delimiter ;

-- Find the Universities, buildings and dorms in a certain state
-- and then order by university, average rating of the building, and price of dorm

drop procedure if exists findUniNearMe;

delimiter //
create procedure findUniNearMe(
	in state_param varchar(45),
    in city_param varchar(45)
)

begin


declare message varchar(255);

if (city_param is null and state_param is null) then
select "Please input valid values to search the database." into message;
		signal sqlstate 'HY000' set message_text = message;
End if;

if ((state_param is not null) and (state_param not in (select state from university))) then
select concat(state_param, ' is not a state in the database yet.') into message;
		signal sqlstate 'HY000' set message_text = message;
End if;

if ((city_param is not null) and (city_param not in (select city from university))) then
select concat(city_param, ' is not a city in the database yet.') into message;
		signal sqlstate 'HY000' set message_text = message;
End if;

if (state_param is null) then
select u.name, d.name, b.avg_rating, d.price
from university u
left join building b using (university_id)
left join dorm d using (building_id)
where city like city_param
order by u.name, b.avg_rating desc, d.price;
End if;

if (city_param is null) then
select u.name, d.name, b.avg_rating, d.price
from university u
left join building b using (university_id)
left join dorm d using (building_id)
where state like state_param
order by u.name, b.avg_rating desc, d.price;
End if;

if ((state_param in (select state from university)) and 
(city_param in (select city from university))) then
select u.name, d.name, b.avg_rating, d.price
from university u
join building b using (university_id)
join dorm d using (building_id)
where state like state_param and city like city_param
order by u.name, b.avg_rating desc, d.price;
End if;

end //
delimiter ;

-- Updates the user's info with the new information

drop procedure if exists updateUserInfo;

delimiter //
create procedure updateUserInfo (
	in user_id_param int,
	in username_param varchar(255),
    in password_param varchar(255),
    in name_param varchar(255)
    )
    
begin

declare username_old_var varchar(255);
declare password_old_var varchar(255);
declare name_old_var varchar(255);

select u.username, u.password, u.name
into username_old_var, password_old_var, name_old_var
from user u
where user_id = user_id_param;

if (user_id_param is null or (user_id_param not in (select user_id from user))) then
		signal sqlstate 'HY000' set message_text = 'Please insert valid user ID to call update.';
End if;

if (username_param is not null and password_param is not null and name_param is not null)
then
update user 
set user_id = user_id_param, username = username_param, password = password_param, name = name_param
where user_id = user_id_param;
End if;

if (username_param is null or password_param is null or name_param is null) then
update user 
set user_id = user_id_param, username = ifnull(username_param, username_old_var), 
password = ifnull(password_param, password_old_var), name = ifnull(name_param, name_old_var)
where user_id = user_id_param;
end if;

end //
delimiter ;

-- (3) [TRIGGERS]
-- trigger template

drop trigger if exists sampleTrigger;

delimiter //
CREATE 
    TRIGGER  sampleTrigger
 AFTER UPDATE ON rating FOR EACH ROW 
    BEGIN END//
delimiter ;

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

-- ------------------------------------------------- START ----------------------------------------------------






-- (4) [Testing] -----------------------------------------------------------------------------------------------

-- manually check each sort stored procedure by referencing the queries created in part one
call sortByPrice();
call sortByRating();
call sortByHousingOccupancy();
call sortDormsByBestValue();

-- here we will begin to include 'should work' and 'should fail' tests for each stored procedure,
-- hhich will help us test our data constraints and functionality more thoroughly

-- should work
call searchUniDormsByBestValue("Northeastern University");
call searchUniDormsByBestValue("Stanford University");
call searchUniDormsByBestValue("Boston University");

-- should fail
call searchUniDormsByBestValue("braddah university");
call searchUniDormsByBestValue(382);
call searchUniDormsByBestValue(null);

-- should work
-- following two queries should produce the same results

CALL searchByPrice('Northeastern University', 'low');

SELECT 
    b.name, d.name, d.avg_rating, d.price
FROM
    dorm d
        JOIN
    building b USING (building_id)
        JOIN
    university u USING (university_id)
WHERE
    u.name LIKE 'Northeastern University'
ORDER BY d.price;

-- should work
-- following two queries should produce the same results

CALL searchByPrice('Northeastern University', 'high');

SELECT 
    b.name, d.name, d.avg_rating, d.price
FROM
    dorm d
        JOIN
    building b USING (building_id)
        JOIN
    university u USING (university_id)
WHERE
    u.name LIKE 'Northeastern University'
ORDER BY d.price;

-- should fail
CALL searchByPrice(null, 'low');
CALL searchByPrice('London School of Economics', 'low');
CALL searchByPrice('Emerson college', 'pizza');
CALL searchByPrice('Emerson college', null);
CALL searchByPrice('cuculmber', null);

-- should work
CALL searchByOccupancy('Boston University', 3); -- returns all triples (3) in BU
CALL searchByOccupancy('Stanford University', 2); -- returns all doubles (2) at Stanford
CALL searchByOccupancy('Emerson College', 1); -- returns all singles (1) at Emerson

-- should fail
CALL searchByOccupancy('Boston University', -39);
CALL searchByOccupancy('Stanford Elderly Hospital', 2);
CALL searchByOccupancy('Emerson College', null);
CALL searchByOccupancy(null, null);

-- should work
call searchRatingsBound("max", 3);
call searchRatingsBound("max", 1);
call searchRatingsBound("min", 4);
call searchRatingsBound("min", 2);

-- should fail
call searchRatingsBound("dog", 4);
call searchRatingsBound("min", null);
call searchRatingsBound(null, 3);
call searchRatingsBound(null, null);
call searchRatingsBound("min", 6);
call searchRatingsBound("max", -2);

-- should work
call showUserStats("Eli");
call showUserStats("Jiwoo");
call showUserStats("Aden");

-- should fail
call showUserStats("pasclabo");
call showUserStats("ILoveDatabaseMan");
call showUserStats("TheHombre");
call showUserStats(null);
call showUserStats(832);

-- should work

call findTopRatings("River Tower double");
call findTopRatings("River Tower triple");
call findTopRatings("White Hall single");

-- should fail

call findTopRatings(null);
call findTopRatings("Six Flags");

insert into university (name, city, state) values
	("Worcester Polytechnic Institute", "Worcester", "MA");

-- should work

call findUniNearMe(null, "Boston");
call findUniNearMe(null, "Worcester");
call findUniNearMe("MA", null);

-- should fail
call findUniNearMe("MA", "dog");
call findUniNearMe("Pineapple", null);
call findUniNearMe(null, null);

-- check result

SELECT 
    *
FROM
    user
WHERE
    user_id = 5;

-- update and check result again, you can choose which fields you want to update if not all of them!
-- should work

call updateUserInfo(5, 'BigJohn85', 'newpassword', 'Jonathan AppleBee');
call updateUserInfo(5, 'DragonBaller', 'ilovedogs72', 'Mr. AppleBee');
call updateUserInfo(5, null, 'ilovecatsnow', 'Mr. Potato');
call updateUserInfo(5, 'blasterpastor', null, 'fashionistaboiii');
call updateUserInfo(5, null, 'ilovepotatoes', null);
call updateUserInfo(5, null, null, null);
call updateUserInfo(5, 'mr.beast', 'tomatogod', null);

-- should fail
call updateUserInfo(-7, 'LeGM James', 'ilovedogs72', 'Mr. AppleBee');
call updateUserInfo(94, 'BugsBunny', 'ilovedogs72', 'Mr. AppleBee');

-- to see how the database updates itself after a new rating is inserted
-- avg_rating for dorm and avg_rating and num_ratings for building are updated accordingly
SELECT * FROM rating;
SELECT name, occupancy, price, avg_rating FROM dorm WHERE dorm_id = 6;
SELECT b.name, b.avg_rating, num_ratings FROM building b JOIN dorm USING (building_id) WHERE dorm_id = 6;
INSERT INTO rating (room_rating, bathroom_rating, building_rating, location_rating, descr, user_id, dorm_id) VALUES
(5,5,5,5,"Fantastic dorm!",5,6);
SELECT * FROM rating;
SELECT name, occupancy, price, avg_rating FROM dorm WHERE dorm_id = 6;
SELECT b.name, b.avg_rating, num_ratings FROM building b JOIN dorm USING (building_id) WHERE dorm_id = 6;

-- should fail (rating_check trigger maintains data integrity, follows the business rules)
INSERT INTO rating (room_rating, bathroom_rating, building_rating, location_rating, descr, user_id, dorm_id) VALUES
(0,1,2,1,"Awful dorm!",7,8);
INSERT INTO rating (room_rating, bathroom_rating, building_rating, location_rating, descr, user_id, dorm_id) VALUES
(10,9,9,10,"Best dorm ever!",10,2);