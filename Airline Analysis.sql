CREATE DATABASE AIRLINE;
USE AIRLINE;

SHOW TABLES;
-- 1.	Create an ER diagram for the given airlines database.

-- 2.Write a query to create a route_details table using suitable data types for the fields,
-- such as route_id, flight_num, origin_airport, destination_airport, aircraft_id, and 
-- distance_miles. Implement the check constraint for the flight number and unique constraint 
-- for the route_id fields. Also, make sure that the distance miles field is greater than 0. 

CREATE TABLE route_details (
    route_id INT PRIMARY KEY,  
    flight_num VARCHAR(10) NOT NULL, 
    origin_airport VARCHAR(10) NOT NULL,
    destination_airport VARCHAR(10) NOT NULL,
    aircraft_id INT NOT NULL,
    distance_miles INT NOT NULL CHECK (distance_miles > 0) 
);


-- 3.Write a query to display all the passengers (customers) who have travelled in routes 01 to 25. 
-- Take data from the passengers_on_flights table.

SELECT * FROM PASSENGERS_ON_FLIGHTS;
SELECT * FROM PASSENGERS_ON_FLIGHTS 
WHERE ROUTE_ID between 1 AND 25;

-- 4.Write a query to identify the number of passengers and total revenue 
--   in business class from the ticket_details table.

SELECT * FROM TICKET_DTL;
SELECT CLASS_ID ,COUNT(CUSTOMER_ID) AS NO_OF_PASSENGER, SUM(PRICE_PER_TICKET) AS REVENUE_OF_BUSSINESS_CLASS
FROM TICKET_DTL
GROUP BY CLASS_ID
HAVING CLASS_ID = 'BUSSINESS';

-- 5.Write a query to display the full name of the customer by extracting 
--   the first name and last name from the customer table.
SELECT * FROM CUSTOMER_DTL;

SELECT CONCAT(FIRST_NAME , ' ' , LAST_NAME ) AS NAME_OF_CUSTOMER FROM CUSTOMER_DTL;


-- 6.Write a query to extract the customers who have registered and booked a ticket. 
--   Use data from the customer and ticket_details tables.
SELECT * FROM 
CUSTOMER_DTL
INNER JOIN TICKET_DTL
ON CUSTOMER_DTL.CUSTOMER_ID = TICKET_DTL.CUSTOMER_ID;


-- 7.Write a query to identify the customer’s first name and last name based
--   on their customer ID and brand (Emirates) from the ticket_details table.

SELECT * FROM TICKET_DTL;

SELECT * FROM CUSTOMER_DTL;

SELECT C.CUSTOMER_ID, C.FIRST_NAME , C.LAST_NAME , T.BRAND
FROM CUSTOMER_DTL C
LEFT JOIN TICKET_DTL T
ON C.CUSTOMER_ID = T.CUSTOMER_ID
WHERE T.BRAND = 'EMIRATES';

-- 8.Write a query to identify the customers who have travelled by Economy Plus class using 
--   Group By and Having clause on the passengers_on_flights table. 

SELECT * FROM passengers_on_flights;
SELECT CUSTOMER_ID, COUNT(CUSTOMER_ID) AS NO_OF_PASSENGERS, CLASS_ID FROM passengers_on_flights
GROUP BY CUSTOMER_ID
HAVING CLASS_ID = 'ECONOMY PLUS';

-- COUNT OF CUSTOMERS
SELECT customer_id, COUNT(*) AS total_trips
FROM passengers_on_flights
WHERE class_id = 'Economy Plus'
GROUP BY customer_id
HAVING COUNT(*) > 0;

-- 9.Write a query to identify whether the revenue has crossed 10000 
--   using the IF clause on the ticket_details table.
SELECT * FROM TICKET_DTL;
SELECT IF(SUM(PRICE_PER_TICKET) > 10000 , 'YES', 'NO') AS REVENUE FROM TICKET_DTL;

SELECT SUM(PRICE_PER_TICKET) FROM TICKET_DTL;

-- 10.Write a query to create and grant access to a new user to perform operations on a database.
CREATE USER 'new_user'@'localhost' IDENTIFIED BY 'user_password';
GRANT ALL PRIVILEGES ON database_name.* TO 'new_user'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON database_name.* TO 'new_user'@'localhost';
GRANT SELECT, INSERT ON database_name.table_name TO 'new_user'@'localhost';
FLUSH PRIVILEGES;
SHOW GRANTS FOR 'new_user'@'localhost';


-- 11.Write a query to find the maximum ticket price for each class 
--   using window functions on the ticket_details table. 
SELECT * FROM TICKET_DTL;

SELECT CUSTOMER_ID,AIRCRAFT_ID, CLASS_ID, BRAND, PRICE_PER_TICKET,
 MAX(PRICE_PER_TICKET) OVER(partition by CLASS_ID) AS MAX_TICKET FROM TICKET_DTL;

-- 12.Write a query to extract the passengers whose route ID is 4 by
--    improving the speed and performance of the passengers_on_flights table.
SELECT * FROM passengers_on_flights;

USE `airline`;
DROP procedure IF EXISTS `PASSENGER`;

DELIMITER $$
USE `airline`$$
CREATE PROCEDURE `PASSENGER` (ROUTE INT)
BEGIN
		SELECT * FROM passengers_on_flights WHERE ROUTE_ID = ROUTE;
END$$

DELIMITER ;

CALL PASSENGER(4);


-- 13. For the route ID 4, write a query to view the execution plan of the 
--     passengers_on_flights table.

SELECT * FROM passengers_on_flights WHERE route_id = 4;

-- 14.Write a query to calculate the total price of all tickets booked by a customer 
--    across different aircraft IDs using rollup function. 

SELECT p.customer_id, p.aircraft_id, SUM(t.price_per_ticket) AS total_price
FROM passengers_on_flights p
LEFT JOIN ticket_dtl t ON p.customer_id = t.customer_id
GROUP BY ROLLUP (p.customer_id, p.aircraft_id);

SELECT * FROM  TICKET_DTL;

-- 15.Write a query to create a view with only 
--    business class customers along with the brand of airlines. 
CREATE OR REPLACE VIEW AIRLINE_VIEW AS 
SELECT CLASS_ID , BRAND FROM TICKET_DTL
WHERE CLASS_ID LIKE 'BUSSINESS';

SELECT * FROM AIRLINE_VIEW;

-- 16.Write a query to create a stored procedure to get the details 
--    of all passengers flying between a range of routes defined in run time. 
--    Also, return an error message if the table doesn't exist.
USE `airline`;
DROP procedure IF EXISTS `GetPassengersByRoutedistance`;
USE `airline`;
DROP procedure IF EXISTS `airline`.`GetPassengersByRoutedistance`;
;
DELIMITER $$
USE `airline`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetPassengersByRoutedistance`( IN start_route_id INT, IN end_route_id INT)
BEGIN
		IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'passengers_on_flights') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: passengers_on_flights table does not exist';
    ELSE
    SELECT p.*
        FROM passengers_on_flights p
        JOIN routes_dtl r ON p.route_id = r.route_id
        WHERE r.route_id BETWEEN start_route_id AND end_route_id;
    END IF;
END$$
DELIMITER ;
;
call GetPassengersByRoutedistance(10,20);

-- 17.Write a query to create a stored procedure that extracts all the details from the routes 
--    table where the travelled distance is more than 2000 miles.

SELECT * FROM ROUTES_DTL
WHERE DISTANCE_MILES > 2000;

USE `airline`;
DROP procedure IF EXISTS `MILES_PROC`;

DELIMITER $$
USE `airline`$$
CREATE PROCEDURE `MILES_PROC` (DISTANCE INT)
BEGIN
	SELECT * FROM ROUTES_DTL
WHERE DISTANCE_MILES > DISTANCE;
END$$

DELIMITER ;

CALL MILES_PROC(2000);

-- 18.Write a query to create a stored procedure that groups
--   the distance travelled by each flight into three categories. 
--   The categories are, short distance travel (SDT) for >=0 AND <= 2000 miles, 
--   intermediate distance travel (IDT) for >2000 AND <=6500, and long-distance travel (LDT) 
--   for >6500.
USE `airline`;
DROP procedure IF EXISTS `PROC_2`;
DELIMITER ;

CALL PROC_2 (6800);
USE `airline`;
CREATE DEFINER=`root`@`localhost` PROCEDURE `CategorizeFlightDistance`()
BEGIN
	SELECT * ,
     CASE 
            WHEN distance_miles >= 0 AND distance_miles <= 2000 THEN 'SDT'  
            WHEN distance_miles > 2000 AND distance_miles <= 6500 THEN 'IDT' 
            WHEN distance_miles > 6500 THEN 'LDT' 
            ELSE 'Unknown'
        END AS travel_category
    FROM ROUTES_DTL
END$$
DELIMITER ;

CALL CategorizeFlightDistance();

-- 19.Write a query to extract ticket purchase date, customer ID, class ID and specify 
--    if the complimentary services are provided for the specific class using a stored function
--    in stored procedure on the ticket_details table. 
-- Condition: 
-- ● If the class is Business and Economy Plus, then complimentary services 
--   are given as Yes, else it is No
SELECT CUSTOMER_ID, P_DATE,CLASS_ID,
	CASE 
		WHEN CLASS_ID = 'BUSSINESS'THEN 'YES'
        WHEN CLASS_ID = 'ECONOMY PLUS' THEN 'YES'
        ELSE 'NO'
	END AS COMPLEMENTARY_SERVICES
    FROM TICKET_DTL;
    
    USE `airline`;
DROP procedure IF EXISTS `SERVICES_PROC`;

DELIMITER $$
USE `airline`$$
CREATE PROCEDURE `SERVICES_PROC` ()
BEGIN
SELECT CUSTOMER_ID, P_DATE,CLASS_ID,
	CASE 
		WHEN CLASS_ID = 'BUSSINESS'THEN 'YES'
        WHEN CLASS_ID = 'ECONOMY PLUS' THEN 'YES'
        ELSE 'NO'
	END AS COMPLEMENTARY_SERVICES
    FROM TICKET_DTL;
END$$

DELIMITER ;

CALL SERVICES_PROC();
    
    
-- 20.Write a query to extract the first record of the customer whose last name ends 
--    with Scott using a cursor from the customer table.

DELIMITER $$

CREATE PROCEDURE GetFirstCustomerWithLastNameScott()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE customer_id INT;
    DECLARE first_name VARCHAR(50);
    DECLARE last_name VARCHAR(50);
    DECLARE email VARCHAR(100);
    
    DECLARE cur CURSOR FOR 
    SELECT customer_id, first_name, last_name, email 
    FROM customer_dtl 
    WHERE last_name LIKE '%Scott'
    LIMIT 1;  

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;
    
    FETCH cur INTO customer_id, first_name, last_name, email;

    IF NOT done THEN
        SELECT customer_id, first_name, last_name, email;
    ELSE
        SELECT 'No customer found with last name ending in Scott' AS message;
    END IF;

    CLOSE cur;
END$$

DELIMITER ;

CALL GetFirstCustomerWithLastNameScott();





