-- CS4400: Introduction to Database Systems (Summer 2025)
-- Project Phase III: Stored Procedures SHELL [v0] Wednesday, Jun 25, 2025
set global transaction isolation level serializable;
set global SQL_MODE = 'ANSI,TRADITIONAL';
set names utf8mb4;
set SQL_SAFE_UPDATES = 0;

use business_supply;
-- -----------------------------------------------------------------------------
-- stored procedures and views
-- -----------------------------------------------------------------------------
/* Standard Procedure: If one or more of the necessary conditions for a procedure to
be executed is false, then simply have the procedure halt execution without changing
the database state. Do NOT display any error messages, etc. */

-- [1] add_owner()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new owner.  A new owner must have a unique
username. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_owner;
delimiter //
create procedure add_owner (in ip_username varchar(40), in ip_first_name varchar(100),
	in ip_last_name varchar(100), in ip_address varchar(500), in ip_birthdate date)
sp_main: begin
    IF NOT EXISTS (SELECT 1 FROM business_owners WHERE username = ip_username) THEN
    INSERT INTO users VALUES (ip_username, ip_first_name, ip_last_name, ip_address, ip_birthdate);
    INSERT INTO business_owners VALUES (ip_username);
    END IF;
end //
delimiter ;

-- [2] add_employee()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new employee without any designated driver or
worker roles.  A new employee must have a unique username and a unique tax identifier. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_employee;
delimiter //
create procedure add_employee (in ip_username varchar(40), in ip_first_name varchar(100),
	in ip_last_name varchar(100), in ip_address varchar(500), in ip_birthdate date,
    in ip_taxID varchar(40), in ip_hired date, in ip_employee_experience integer,
    in ip_salary integer)
sp_main: begin
    -- ensure new owner has a unique username
    -- ensure new employee has a unique tax identifier
    IF NOT EXISTS(SELECT 1 FROM employees WHERE taxID = ip_taxID OR username = ip_username) THEN
    INSERT INTO USERS VALUES (ip_username, ip_first_name, ip_last_name, ip_address, ip_birthdate);
    INSERT INTO EMPLOYEEs VALUES(ip_username, ip_taxID, ip_hired, ip_employee_experience, ip_salary);
    END IF;
end //
delimiter ;

-- [3] add_driver_role()
-- -----------------------------------------------------------------------------
/* This stored procedure adds the driver role to an existing employee.  The
employee/new driver must have a unique license identifier. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_driver_role;
delimiter //
create procedure add_driver_role (in ip_username varchar(40), in ip_licenseID varchar(40),
	in ip_license_type varchar(40), in ip_driver_experience integer)
sp_main: begin
    IF EXISTS (
        SELECT 1 FROM employees WHERE username = ip_username
    ) AND NOT EXISTS (
        SELECT 1 FROM drivers WHERE licenseID = ip_licenseID
    ) THEN
        INSERT INTO drivers(username, licenseID, license_type, successful_trips)
        VALUES (ip_username, ip_licenseID, ip_license_type, ip_driver_experience);
    END IF;
end //
delimiter ;

-- [4] add_worker_role()
-- -----------------------------------------------------------------------------
/* This stored procedure adds the worker role to an existing employee. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_worker_role;
delimiter //
create procedure add_worker_role (in ip_username varchar(40))
sp_main: begin
     IF EXISTS (
        SELECT 1 FROM employees WHERE username = ip_username
    ) AND NOT EXISTS (
        SELECT 1 FROM drivers WHERE username = ip_username
    ) THEN
        INSERT INTO workers(username)
        VALUES (ip_username);
    END IF;
end //
delimiter ;

-- [5] add_product()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new product.  A new product must have a
unique barcode. */
-- -----------------------------------------------------------------------------

drop procedure if exists add_product;
delimiter //
create procedure add_product (in ip_barcode varchar(40), in ip_iname varchar(100),
	in ip_weight integer)
sp_main: begin
	if not exists (select 1 from products where barcode = ip_barcode) then
		insert into products (barcode, iname, weight) values (ip_barcode, ip_iname, ip_weight);
	end if;
end //
delimiter ;

-- [6] add_van()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new van.  A new van must be assigned
to a valid delivery service and must have a unique tag.  Also, it must be driven
by a valid driver initially (i.e., driver works for the same service). And the van's starting
location will always be the delivery service's home base by default. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_van;
delimiter //
create procedure add_van (in ip_id varchar(40), in ip_tag integer, in ip_fuel integer,
	in ip_capacity integer, in ip_sales integer, in ip_driven_by varchar(40))
sp_main: begin
	declare v_home_base varchar(40);
	if not exists (select 1 from vans where id = ip_id and tag = ip_tag)
		and exists (select 1 from delivery_services where id = ip_id)
		and exists (select 1 from drivers where username = ip_driven_by)
	then
		select home_base into v_home_base from delivery_services where id = ip_id;
		insert into vans (id, tag, fuel, capacity, sales, driven_by, located_at)
        VALUES (ip_id, ip_tag, ip_fuel, ip_capacity, ip_sales, ip_driven_by, v_home_base);
	end if;
end //
delimiter ;

-- [7] add_business()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new business.  A new business must have a
unique (long) name and must exist at a valid location, and have a valid rating.
And a resturant is initially "independent" (i.e., no owner), but will be assigned
an owner later for funding purposes. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_business;
delimiter //
create procedure add_business (in ip_long_name varchar(40), in ip_rating integer,
	in ip_spent integer, in ip_location varchar(40))
sp_main: begin
	if not exists (select 1 from businesses where long_name = ip_long_name)
		and exists (select 1 from locations where label = ip_location)
        and ip_rating between 1 and 5
	then
		insert into businesses (long_name, rating, spent, location) values (ip_long_name, ip_rating, ip_spent, ip_location);
	end if;
end //
delimiter ;

-- [8] add_service()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new delivery service.  A new service must have
a unique identifier, along with a valid home base and manager. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_service;
delimiter //
create procedure add_service (in ip_id varchar(40), in ip_long_name varchar(100),
	in ip_home_base varchar(40), in ip_manager varchar(40))
sp_main: begin
	-- ensure new delivery service doesn't already exist
    -- ensure that the home base location is valid
    -- ensure that the manager is valid
    IF NOT EXISTS(SELECT 1 FROM delivery_services WHERE id = ip_id) THEN
    IF EXISTS (SELECT 1 FROM locations WHERE label = ip_home_base) THEN
    IF EXISTS (SELECT 1 FROM workers WHERE username = ip_manager) AND NOT EXISTS (SELECT 1 FROM work_for WHERE username = ip_manager) THEN
    INSERT INTO delivery_services VALUES (ip_id, ip_long_name, ip_home_base, ip_manager);
    INSERT INTO work_for VALUES (ip_manager, ip_id);
    END IF;
    END IF;
    END IF;
end //
delimiter ;

-- [9] add_location()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new location that becomes a new valid van
destination.  A new location must have a unique combination of coordinates. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_location;
delimiter //
create procedure add_location (in ip_label varchar(40), in ip_x_coord integer,
	in ip_y_coord integer, in ip_space integer)
sp_main: begin
	IF NOT EXISTS (
        SELECT 1 FROM locations WHERE label = ip_label
    ) AND NOT EXISTS (
        SELECT 1 FROM locations WHERE x_coord = ip_x_coord AND y_coord = ip_y_coord
    ) THEN
        INSERT INTO locations (label, x_coord, y_coord, space)
        VALUES (ip_label, ip_x_coord, ip_y_coord, ip_space);
    END IF;
end //
delimiter ;


-- [10] start_funding()
-- -----------------------------------------------------------------------------
/* This stored procedure opens a channel for a business owner to provide funds
to a business. The owner and business must be valid. */
-- -----------------------------------------------------------------------------
drop procedure if exists start_funding;
delimiter //
create procedure start_funding (in ip_owner varchar(40), in ip_amount integer, in ip_long_name varchar(40), in ip_fund_date date)
sp_main: begin
	-- ensure the owner and business are valid
    IF EXISTS (SELECT 1 FROM business_owners WHERE username = ip_owner) AND EXISTS (SELECT 1 FROM businesses where long_name = ip_long_name) THEN
    INSERT INTO fund VALUES (ip_owner, ip_amount, ip_fund_date, ip_long_name);
    END IF;
end //
delimiter ;

-- [11] hire_employee()
-- -----------------------------------------------------------------------------
/* This stored procedure hires a worker to work for a delivery service.
If a worker is actively serving as manager for a different service, then they are
not eligible to be hired.  Otherwise, the hiring is permitted. */
-- -----------------------------------------------------------------------------
drop procedure if exists hire_employee;
delimiter //
create procedure hire_employee (in ip_username varchar(40), in ip_id varchar(40))
sp_main: begin
	-- ensure that the employee hasn't already been hired by that service
	-- ensure that the employee and delivery service are valid
    -- ensure that the employee isn't a manager for another service
    IF EXISTS (SELECT 1 FROM workers WHERE username = ip_username) AND EXISTS (SELECT 1 FROM delivery_services WHERE id = ip_id) THEN
    IF NOT EXISTS (SELECT 1 FROM work_for WHERE username=ip_username AND id=ip_id) THEN
    IF NOT EXISTS (SELECT 1 FROM delivery_services WHERE manager = ip_username) THEN
    INSERT INTO work_for VALUES (ip_username, ip_id);
    END IF;
    END IF;
    END IF;
end //
delimiter ;

-- [12] fire_employee()
-- -----------------------------------------------------------------------------
/* This stored procedure fires a worker who is currently working for a delivery
service.  The only restriction is that the employee must not be serving as a manager
for the service. Otherwise, the firing is permitted. */
-- -----------------------------------------------------------------------------
drop procedure if exists fire_employee;
delimiter //
create procedure fire_employee (in ip_username varchar(40), in ip_id varchar(40))
sp_main: begin
	-- ensure that the employee is currently working for the service
    -- ensure that the employee isn't an active manager
    IF NOT EXISTS (SELECT 1 FROM delivery_services WHERE id = ip_id AND manager = ip_username) THEN
    DELETE FROM work_for WHERE username = ip_username AND id = ip_id;
    END IF; 
end //
delimiter ;

-- [13] manage_service()
-- -----------------------------------------------------------------------------
/* This stored procedure appoints a worker who is currently hired by a delivery
service as the new manager for that service.  The only restrictions is that
the worker must not be working for any other delivery service. Otherwise, the appointment
to manager is permitted.  The current manager is simply replaced. */
-- -----------------------------------------------------------------------------
drop procedure if exists manage_service;
delimiter //
create procedure manage_service (in ip_username varchar(40), in ip_id varchar(40))
sp_main: begin
	IF EXISTS (
        SELECT 1 FROM work_for 
        WHERE username = ip_username AND id = ip_id
    )
    AND NOT EXISTS (
        SELECT 1 FROM work_for 
        WHERE username = ip_username AND id <> ip_id
    ) THEN
        UPDATE delivery_services
        SET manager = ip_username
        WHERE id = ip_id;
    END IF;
end //
delimiter ;
-- [14] takeover_van()
-- -----------------------------------------------------------------------------
/* This stored procedure allows a valid driver to take control of a van owned by
the same delivery service. The current controller of the van is simply relieved
of those duties. */
-- -----------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS takeover_van;
DELIMITER //

CREATE PROCEDURE takeover_van (
    IN ip_username VARCHAR(40),
    IN ip_id VARCHAR(40),
    IN ip_tag integer
)
sp_main: BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM drivers WHERE username = ip_username
    ) THEN
        LEAVE sp_main;
    END IF;
	IF EXISTS (
    SELECT 1 FROM drivers JOIN vans ON username = driven_by WHERE id <> ip_id AND driven_by = ip_username
    ) THEN
    LEAVE sp_main;
    END IF;
    IF NOT EXISTS (
        SELECT 1 FROM vans WHERE id = ip_id AND tag = ip_tag
    ) THEN
        LEAVE sp_main;
    END IF;
    UPDATE vans
    SET driven_by = ip_username
    WHERE id = ip_id AND tag = ip_tag;
END;
//
DELIMITER ;

-- [15] load_van()
-- -----------------------------------------------------------------------------
/* This stored procedure allows us to add some quantity of fixed-size packages of
a specific product to a van's payload so that we can sell them for some
specific price to other businesses.  The van can only be loaded if it's located
at its delivery service's home base, and the van must have enough capacity to
carry the increased number of items.

The change/delta quantity value must be positive, and must be added to the quantity
of the product already loaded onto the van as applicable.  And if the product
already exists on the van, then the existing price must not be changed. */
-- -----------------------------------------------------------------------------

drop procedure if exists load_van;
delimiter //
create procedure load_van (in ip_id varchar(40), in ip_tag integer, in ip_barcode varchar(40),
	in ip_more_packages integer, in ip_price integer)
sp_main: begin
	-- ensure that the van being loaded is owned by the service
	-- ensure that the product is valid
    -- ensure that the van is located at the service home base
	-- ensure that the quantity of new packages is greater than zero
	-- ensure that the van has sufficient capacity to carry the new packages
    -- add more of the product to the van
    declare v_capacity int;
    declare v_total_weight int;
    declare v_home varchar(40);
    declare v_loc varchar(40);
    declare total_quantity int;

    if ip_more_packages <= 0 then leave sp_main; 
    end if;

    if not exists (select * from vans where id = ip_id and tag = ip_tag) then leave sp_main; 
    end if;
    
    if not exists (select * from products where barcode = ip_barcode) then leave sp_main; 
    end if;

    select located_at into v_loc from vans where id = ip_id and tag = ip_tag;
    select home_base into v_home from delivery_services where id = ip_id;
    if v_loc <> v_home then leave sp_main; 
    end if;

    select capacity into v_capacity from vans where id = ip_id and tag = ip_tag;
    select sum(quantity) into total_quantity
    from contain
    where id = ip_id and tag = ip_tag;

    if total_quantity + (ip_more_packages) > v_capacity then leave sp_main; 
    end if;

    if exists (select * from contain where id = ip_id and tag = ip_tag and barcode = ip_barcode) then
        update contain set quantity = ip_more_packages + total_quantity;
    else
        insert into contain(id, tag, barcode, quantity, price)
        values(ip_id, ip_tag, ip_barcode, ip_more_packages, ip_price);
    end if;
end //
delimiter ;

-- [16] refuel_van()
-- -----------------------------------------------------------------------------
/* This stored procedure allows us to add more fuel to a van. The van can only
be refueled if it's located at the delivery service's home base. */
-- -----------------------------------------------------------------------------
drop procedure if exists refuel_van;
delimiter //
create procedure refuel_van (in ip_id varchar(40), in ip_tag integer, in ip_more_fuel integer)
sp_main: begin
	-- ensure that the van being switched is valid and owned by the service
    -- ensure that the van is located at the service home base
    declare v_loc varchar(40);
    declare v_home varchar(40);

    if not exists (select * from vans where id = ip_id and tag = ip_tag) then leave sp_main; 
    end if;

    select located_at into v_loc from vans where id = ip_id and tag = ip_tag;
    select home_base into v_home from delivery_services where id = ip_id;

    if v_loc != v_home then leave sp_main; 
    end if;

    update vans set fuel = fuel + ip_more_fuel where id = ip_id and tag = ip_tag;
end //
delimiter ;

-- [17] drive_van()
-- -----------------------------------------------------------------------------
/* This stored procedure allows us to move a single van to a new
location (i.e., destination). This will also update the respective driver's
experience and van's fuel. The main constraints on the van(s) being able to
move to a new  location are fuel and space.  A van can only move to a destination
if it has enough fuel to reach the destination and still move from the destination
back to home base.  And a van can only move to a destination if there's enough
space remaining at the destination. */
-- -----------------------------------------------------------------------------
drop function if exists fuel_required;
delimiter //
create function fuel_required (ip_departure varchar(40), ip_arrival varchar(40))
	returns integer reads sql data
begin
	if (ip_departure = ip_arrival) then return 0;
    else return (select 1 + truncate(sqrt(power(arrival.x_coord - departure.x_coord, 2) + power(arrival.y_coord - departure.y_coord, 2)), 0) as fuel
		from (select x_coord, y_coord from locations where label = ip_departure) as departure,
        (select x_coord, y_coord from locations where label = ip_arrival) as arrival);
	end if;
end //
delimiter ;

drop procedure if exists drive_van;
delimiter //
create procedure drive_van (in ip_id varchar(40), in ip_tag integer, in ip_destination varchar(40))
sp_main: begin
    -- ensure that the destination is a valid location
    -- ensure that the van isn't already at the location
    -- ensure that the van has enough fuel to reach the destination and (then) home base
    -- ensure that the van has enough space at the destination for the trip
    declare v_loc, v_home, v_driver varchar(40);
    declare fuel_needed_to_dest, fuel_needed_to_home, fuel_total int;
    declare remaining_space int;

    if not exists (select * from locations where label = ip_destination) then leave sp_main; 
    end if;
    if not exists (select * from vans where id = ip_id and tag = ip_tag) then leave sp_main; 
    end if;

    select located_at, driven_by into v_loc, v_driver from vans where id = ip_id and tag = ip_tag;
    if v_loc = ip_destination then leave sp_main; 
    end if;
    if v_driver is null then leave sp_main; 
    end if;

    select home_base into v_home from delivery_services where id = ip_id;

    select fuel_required(v_loc, ip_destination) into fuel_needed_to_dest;
    select fuel_required(ip_destination, v_home) into fuel_needed_to_home;
    set fuel_total = fuel_needed_to_dest + fuel_needed_to_home;

    if (select fuel from vans where id = ip_id and tag = ip_tag) < fuel_total then leave sp_main; 
    end if;

    select space into remaining_space from locations where label = ip_destination;
    if remaining_space <= 0 then leave sp_main; 
    end if;

    update vans set located_at = ip_destination, fuel = fuel - fuel_needed_to_dest where id = ip_id and tag = ip_tag;
    update drivers set successful_trips = successful_trips + 1 where username = v_driver;
end //
delimiter ;

-- [18] purchase_product()
-- -----------------------------------------------------------------------------
/* This stored procedure allows a business to purchase products from a van
at its current location.  The van must have the desired quantity of the product
being purchased.  And the business must have enough money to purchase the
products.  If the transaction is otherwise valid, then the van and business
information must be changed appropriately.  Finally, we need to ensure that all
quantities in the payload table (post transaction) are greater than zero. */
-- -----------------------------------------------------------------------------
drop procedure if exists purchase_product;
delimiter //
create procedure purchase_product (in ip_long_name varchar(40), in ip_id varchar(40),
in ip_tag integer, in ip_barcode varchar(40), in ip_quantity integer)
sp_main: begin
    declare v_business_location varchar(40);
    declare v_van_product_qty int;
    declare v_price int;
    declare v_fail int;
    select location into v_business_location from businesses where long_name = ip_long_name;
    if v_business_location is null then
        leave sp_main;
    end if;
    select count(*) into v_fail from vans where id = ip_id and tag = ip_tag and located_at = v_business_location;
    if v_fail = 0 then
        leave sp_main;
    end if;
    select quantity, price into v_van_product_qty, v_price from contain where id = ip_id and tag = ip_tag and barcode = ip_barcode;
    if v_van_product_qty is null or v_van_product_qty < ip_quantity then
        leave sp_main;
    end if;
    select count(*) into v_fail from contain where id = ip_id and tag = ip_tag and tag = ip_tag and quantity <= 0;
    if v_fail > 0 then
        leave sp_main;
    end if;
    update contain set quantity = quantity - ip_quantity where id = ip_id and tag = ip_tag and barcode = ip_barcode;
    update businesses set spent = spent + (v_price * ip_quantity) where long_name = ip_long_name;
    update vans set sales = sales + (v_price * ip_quantity) where id = ip_id and tag = ip_tag;
    delete from contain where quantity <= 0 and id = ip_id and tag = ip_tag and barcode = ip_barcode;
end //
delimiter;

-- [19] remove_product()
-- -----------------------------------------------------------------------------
/* This stored procedure removes a product from the system.  The removal can
occur if, and only if, the product is not being carried by any vans. */
-- -----------------------------------------------------------------------------
drop procedure if exists remove_product;
delimiter //
create procedure remove_product (in ip_barcode varchar(40))
sp_main: begin
	if exists (select 1 from products where barcode = ip_barcode)
		and not exists (select 1 from contain where barcode = ip_barcode)
	then
		delete from products where barcode = ip_barcode;
	end if;
end //
delimiter ;

-- [20] remove_van()
-- -----------------------------------------------------------------------------
/* This stored procedure removes a van from the system.  The removal can
occur if, and only if, the van is not carrying any products.*/
-- -----------------------------------------------------------------------------
drop procedure if exists remove_van;
delimiter //
create procedure remove_van (in ip_id varchar(40), in ip_tag integer)
sp_main: begin
	if exists (select 1 from vans where id = ip_id and tag = ip_tag)
		and not exists (select 1 from contain where id = ip_id and tag = ip_tag)
	then
		delete from vans where id = ip_id and tag = ip_tag;
	end if;
end //
delimiter ;

-- [21] remove_driver_role()
-- -----------------------------------------------------------------------------
/* This stored procedure removes a driver from the system.  The removal can
occur if, and only if, the driver is not controlling any vans.
The driver's information must be completely removed from the system. */
-- -----------------------------------------------------------------------------
drop procedure if exists remove_driver_role;
delimiter //
create procedure remove_driver_role (in ip_username varchar(40))
sp_main: begin
	IF EXISTS (
        SELECT 1 FROM drivers WHERE username = ip_username
    ) AND NOT EXISTS (
        SELECT 1 FROM vans WHERE driven_by = ip_username
    ) THEN
        DELETE FROM drivers WHERE username = ip_username;
        DELETE FROM users WHERE username=ip_username;
    END IF;
end //
delimiter ;
-- [22] display_owner_view()
-- -----------------------------------------------------------------------------
/* This view displays information in the system from the perspective of an owner.
For each owner, it includes the owner's information, along with the number of
businesses for which they provide funds and the number of different places where
those businesses are located. It also includes the highest and lowest ratings
for each of those businesses, as well as the total amount of debt based on the
monies spent purchasing products by all of those businesses. And if an owner
doesn't fund any businesses then display zeros for the highs, lows and debt. */
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW display_owner_view AS
SELECT 
    bo.username,
    u.first_name, 
    u.last_name,
    u.address,
    COUNT(DISTINCT f.business) AS num_businesses,
    COUNT(DISTINCT b.location) AS num_places,
    IFNULL(MAX(b.rating), 0) AS highs,
    IFNULL(MIN(b.rating), 0) AS lows,
    IFNULL(SUM(b.spent), 0) AS debt
FROM business_owners bo
NATURAL JOIN users u
LEFT JOIN fund f ON bo.username = f.username
LEFT JOIN businesses b ON f.business = b.long_name
GROUP BY bo.username, u.first_name, u.last_name, u.address;


-- [23] display_employee_view()
-- -----------------------------------------------------------------------------
/* This view displays information in the system from the perspective of an employee.
For each employee, it includes the username, tax identifier, salary, hiring date and
experience level, along with license identifer and driving experience (if applicable,
'n/a' if not), and a 'yes' or 'no' depending on the manager status of the employee. */
-- -----------------------------------------------------------------------------
create or replace view display_employee_view as
SELECT 
    e.username,
    e.taxID,
    e.salary,
    e.hired,
    e.experience,
    IFNULL(d.licenseID, 'n/a') AS licenseID,
    IFNULL(d.successful_trips, 'n/a') AS driving_experience,
    IF(w.username IS NOT NULL AND ds.manager IS NOT NULL, 'yes', 'no') AS is_manager
FROM employees e
LEFT JOIN drivers d ON e.username = d.username
LEFT JOIN workers w ON e.username = w.username
LEFT JOIN delivery_services ds ON e.username = ds.manager;

-- [24] display_driver_view()
-- -----------------------------------------------------------------------------
/* This view displays information in the system from the perspective of a driver.
For each driver, it includes the username, licenseID and drivering experience, along
with the number of vans that they are controlling. */
-- -----------------------------------------------------------------------------
create or replace view display_driver_view as
select 
  d.username, 
  d.licenseID, 
  d.successful_trips as driver_experience,
  count(v.tag) as num_vans
from drivers d
left join vans v on d.username = v.driven_by
group by d.username, d.licenseID, d.successful_trips;

-- [25] display_location_view()
-- -----------------------------------------------------------------------------
/* This view displays information in the system from the perspective of a location.
For each location, it includes the label, x- and y- coordinates, along with the
name of the business or service at that location, the number of vans as well as
the identifiers of the vans at the location (sorted by the tag), and both the
total and remaining capacity at the location. */
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW display_location_view AS
SELECT
    l.label,
    LOWER(REPLACE(REPLACE(
        CASE
            WHEN b.long_name IS NOT NULL THEN b.long_name
            WHEN ds.long_name IS NOT NULL THEN ds.long_name
            ELSE ''
        END,
    ' ', ''), '.', '')) AS name_at_location,
    l.x_coord,
    l.y_coord,
    l.space AS total_capacity,
    COUNT(v.tag) AS num_vans,
    GROUP_CONCAT(CONCAT(v.id, v.tag) ORDER BY v.tag ASC SEPARATOR ',') AS van_tags,
    CASE
        WHEN l.space IS NULL THEN NULL
        ELSE l.space - COUNT(v.tag)
    END AS remaining_capacity
FROM locations l
LEFT JOIN businesses b ON l.label = b.location
LEFT JOIN delivery_services ds ON l.label = ds.home_base
JOIN vans v ON l.label = v.located_at 
WHERE b.long_name IS NOT NULL OR ds.long_name IS NOT NULL
GROUP BY
    l.label, name_at_location, l.x_coord, l.y_coord, l.space;
-- [26] display_product_view()
-- -----------------------------------------------------------------------------
/* This view displays information in the system from the perspective of the products.
For each product that is being carried by at least one van, it includes a list of
the various locations where it can be purchased, along with the total number of packages
that can be purchased and the lowest and highest prices at which the product is being
sold at that location. */
-- -----------------------------------------------------------------------------

-- SELECT * FROM products NATURAL JOIN contain NATURAL JOIN vans;
create or replace view display_product_view as
SELECT
    p.iname AS product_name,
    v.located_at as location,
    quantity AS amount_available,
    (SELECT MIN(price)
			FROM products p1
			NATURAL JOIN contain c1
			NATURAL JOIN vans v1
            WHERE p1.barcode = p.barcode AND v1.located_at = v.located_at) as low_price,
	(SELECT MAX(price)
	FROM products p1
	NATURAL JOIN contain c1
	NATURAL JOIN vans v1
	WHERE p1.barcode = p.barcode AND v1.located_at = v.located_at) as high_price
FROM products p
NATURAL JOIN contain c
NATURAL JOIN vans v;
-- [27] display_service_view()
-- -----------------------------------------------------------------------------
/* This view displays information in the system from the perspective of a delivery
service.  It includes the identifier, name, home base location and manager for the
service, along with the total sales from the vans.  It must also include the number
of unique products along with the total cost and weight of those products being
carried by the vans. */
-- -----------------------------------------------------------------------------
create or replace view display_service_view as
select ds.id, ds.long_name, ds.home_base, ds.manager, ifnull(van_sales.total_van_sales, 0) as total_sales,
    count(distinct c.barcode) as num_products, ifnull(sum(c.price * c.quantity), 0) as total_cost,
    ifnull(sum(p.weight * c.quantity), 0) as total_weight
from delivery_services ds
left join (select id, sum(sales) as total_van_sales from vans group by id) van_sales on ds.id = van_sales.id
left join contain c on ds.id = c.id
left join products p on c.barcode = p.barcode
group by ds.id, ds.long_name, ds.home_base, ds.manager;
