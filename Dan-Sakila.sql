use sakila;

-- 1a. Display the first and last names of all actors from the table actor.
select first_name, last_name from actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name
select concat(upper(first_name), ' ', upper(last_name)) as "Actor Name" from actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
-- What is one query would you use to obtain this information?
select actor_id, first_name, last_name  from actor 
	where first_name="Joe";

-- 2b. Find all actors whose last name contain the letters GEN
select * from actor 
	where last_name like "%GEN%";

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, 
-- in that order
select * from actor 
	where last_name like "%LI%" 
		order by last_name, first_name;

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, 
-- and China
select * from country 
	where country in ("Afghanistan", "Bangladesh", "China");

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a 
-- description, so create a column in the table actor named description and use the data type BLOB
alter table actor 
	add description BLOB;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column
alter table actor
	drop column description;
    
-- 4a. List the last names of actors, as well as how many actors have that last name
select last_name, count(last_name) from actor 
	group by last_name;
    
-- 4b. List last names of actors and the number of actors who have that last name, 
-- but only for names that are shared by at least two actors
select last_name, count(last_name) from actor
	where count(last_name)>1
	group by last_name;
    
-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. 
-- Write a query to fix the record.
select actor_id from actor 
	where first_name="GROUCHO" and last_name="WILLIAMS";

Update actor 
	set first_name="HARPO" 
	where actor_id = 172;
    
-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! 
-- In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO
 Update actor 
	set first_name="GROUCHO" 
	where actor_id = 172 and first_name="HARPO";

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
show create table address;

CREATE TABLE `address` (
   `address_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
   `address` varchar(50) NOT NULL,
   `address2` varchar(50) DEFAULT NULL,
   `district` varchar(20) NOT NULL,
   `city_id` smallint(5) unsigned NOT NULL,
   `postal_code` varchar(10) DEFAULT NULL,
   `phone` varchar(20) NOT NULL,
   `location` geometry NOT NULL,
   `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
   PRIMARY KEY (`address_id`),
   KEY `idx_fk_city_id` (`city_id`),
   SPATIAL KEY `idx_location` (`location`),
   CONSTRAINT `fk_address_city` FOREIGN KEY (`city_id`) REFERENCES `city` (`city_id`) ON UPDATE CASCADE
 ) ENGINE=InnoDB AUTO_INCREMENT=606 DEFAULT CHARSET=utf8
 
-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. 
-- Use the tables staff and address
select s.first_name, s.last_name, a.address
	from staff s
    inner join address a on s.address_id = a.address_id;
    
-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. 
-- Use tables staff and payment
select s.first_name, s.last_name, round(sum(p.amount))
	from staff s
    inner join payment p on s.staff_id = p.staff_id
    where month(p.payment_date)=8 and year(p.payment_date)=2005
    group by s.staff_id;