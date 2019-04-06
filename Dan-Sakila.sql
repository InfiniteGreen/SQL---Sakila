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
select s.first_name, s.last_name, round(sum(p.amount)) as "Total Amount"
	from staff s
    inner join payment p on s.staff_id = p.staff_id
    where month(p.payment_date)=8 and year(p.payment_date)=2005
    group by s.staff_id;

-- 6c. List each film and the number of actors who are listed for that film. 
-- Use tables film_actor and film. Use inner join.
select f.title as "Film Title", count(fa.actor_id) as "Number of Actors"
	from film f
    inner join film_actor fa on f.film_id = fa.film_id
    group by f.film_id;
    
-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
select f.title as "Film Title", count(i.inventory_id) as "Number of Copies"
	from film f
    inner join inventory i on f.film_id = i.film_id
    where f.title="Hunchback Impossible"
    group by f.film_id;
    
-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. 
-- List the customers alphabetically by last name
select c.first_name, c.last_name, sum(p.amount) as "Total Amount Paid"
	from customer c
    inner join payment p on c.customer_id = p.customer_id
    group by c.customer_id
    order by c.last_name;
    
-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
-- As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
-- Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
select title from film 
	where title like "k%" or title like "Q%" 
    and language_id = 
    (
		select language_id from language 
			where name="English"
    );

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip
select first_name, last_name from actor
    where actor_id in 
    (
		select actor_id from film_actor where film_id = 
        (
			select film_id from film where title = "Alone Trip"
        )        
    )
    order by last_name;

-- 7c. You want to run an email marketing campaign in Canada, 
-- for which you will need the names and email addresses of all Canadian customers. 
-- Use joins to retrieve this information.
select cu.first_name, cu.last_name, cu.email from customer cu
	inner join address a on cu.address_id = a.address_id
    inner join city ci on a.city_id = ci.city_id 
    inner join country co on ci.country_id = co.country_id
    where co.country="Canada"
    order by cu.last_name;

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as family films	
select f.title from film f
	inner join film_category fc on f.film_id = fc.film_id
    inner join category c on fc.category_id = c.category_id
    where c.name = "Family";

-- 7e. Display the most frequently rented movies in descending order  
SELECT f.title, count(r.rental_id) AS "Total Rentals"
    FROM rental r 
    INNER JOIN inventory i ON r.inventory_id = i.inventory_id
    INNER JOIN film f ON i.film_id = f.film_id
    GROUP BY f.film_id
    ORDER BY count(r.rental_id) DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT s.store_id, SUM(p.amount) AS "Total Business"
    FROM payment p
    INNER JOIN rental r ON p.rental_id = r.rental_id
	INNER JOIN inventory i ON r.inventory_id = i.inventory_id
    INNER JOIN store s ON i.store_id = s.store_id
    GROUP BY s.store_id
    ORDER BY SUM(p.amount) DESC;
    
-- 7g. Write a query to display for each store its store ID, city, and country.
select s.store_id, ci.city, co.country from store s
	inner join address a on s.address_id = a.address_id
    inner join city ci on a.city_id = ci.city_id 
    inner join country co on ci.country_id = co.country_id;

-- 7h. List the top five genres in gross revenue in descending order. 
-- (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT c.name AS "Genres", SUM(p.amount) AS "Gross Revenue"
    FROM payment p
    INNER JOIN rental r ON p.rental_id = r.rental_id
	INNER JOIN inventory i ON r.inventory_id = i.inventory_id
    INNER JOIN film f on i.film_id = f.film_id
    INNER JOIN film_category fc on f.film_id = fc.film_id
    INNER JOIN category c on fc.category_id = c.category_id
    GROUP BY fc.category_id
    ORDER BY SUM(p.amount) DESC
    limit 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the 
-- Top five genres by gross revenue. Use the solution from the problem above to create a view. 
CREATE VIEW `Top_5_Genres` AS SELECT c.name AS "Genres", SUM(p.amount) AS "Gross Revenue"
    FROM payment p
    INNER JOIN rental r ON p.rental_id = r.rental_id
	INNER JOIN inventory i ON r.inventory_id = i.inventory_id
    INNER JOIN film f on i.film_id = f.film_id
    INNER JOIN film_category fc on f.film_id = fc.film_id
    INNER JOIN category c on fc.category_id = c.category_id
    GROUP BY fc.category_id
    ORDER BY SUM(p.amount) DESC
    limit 5;

-- 8b. How would you display the view that you created in 8a?
SELECT * FROM `Top_5_Genres`;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW `Top_5_Genres`;
