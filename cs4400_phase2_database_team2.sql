-- CS4400: Introduction to Database Systems (Summer 2025)
-- Phase II: Create Table & Insert Statements [v0] Friday, June 20, 2025
-- Team 2
-- Ethan Lu elu75
-- Arban Gjyzari agjyzari3
-- Michael Spinks mspinks3
-- Lucas Johnson ljohnson392
-- Directions:
-- Please follow all instructions for Phase II as listed on Canvas.
-- Fill in the team number and names and GT usernames for all members above.
-- Create Table statements must be manually written, not taken from an SQL Dump file.
-- This file must run without error for credit.
/* This is a standard preamble for most of our scripts. The intent is to establish
a consistent environment for the database behavior. */
set global transaction isolation level serializable;
set global SQL_MODE = 'ANSI,TRADITIONAL';
set names utf8mb4;
set SQL_SAFE_UPDATES = 0;
set @thisDatabase = 'business_supply';
drop database if exists business_supply;
create database if not exists business_supply;
use business_supply;

CREATE TABLE Location (
    label VARCHAR(40),
    x_coord INT NOT NULL,
    y_coord INT NOT NULL,
    space INT CHECK (space >= 0),
    PRIMARY KEY (label)
);

CREATE TABLE User (
    username VARCHAR(40),
    address VARCHAR(500) NOT NULL,
    birthdate DATE NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    PRIMARY KEY (username)
);

CREATE TABLE Employee (
    username VARCHAR(40),
    experience INT NOT NULL CHECK (experience >= 0),
    hired DATE NOT NULL,
    salary INT NOT NULL CHECK (salary >= 0),
    tax_id CHAR(11) NOT NULL UNIQUE check (tax_id LIKE '___-__-____'),
    FOREIGN KEY (username) REFERENCES User(username),
    
    PRIMARY KEY (username)
);

CREATE TABLE Owner (
    username VARCHAR(40),
    FOREIGN KEY (username) REFERENCES User(username),
    PRIMARY KEY (username)
);

CREATE TABLE Business (
    business_name VARCHAR(40),
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    spent INT NOT NULL DEFAULT 0 CHECK (spent >= 0),
    business_location VARCHAR(40) NOT NULL,
    FOREIGN KEY (business_location) REFERENCES Location(label),
    PRIMARY KEY (business_name)
);

CREATE TABLE Fund (
    to_owner VARCHAR(40),
    to_business VARCHAR(40),
    fund_date DATE NOT NULL,
    invested INT NOT NULL CHECK (invested >= 0),
    PRIMARY KEY (to_owner, to_business),
    FOREIGN KEY (to_owner) REFERENCES Owner(username),
    FOREIGN KEY (to_business) REFERENCES Business(business_name)
);


CREATE TABLE Driver (
    username VARCHAR(40),
    licence_ID VARCHAR(40) NOT NULL unique,
    licence_type VARCHAR(100) NOT NULL,
    successful_trips INT NOT NULL CHECK (successful_trips >= 0),
    PRIMARY KEY (username),
    FOREIGN KEY (username) REFERENCES Employee(username)
);

CREATE TABLE Worker (
    username VARCHAR(40),
    primary key (username),
    FOREIGN KEY (username) REFERENCES Employee(username)
);

CREATE TABLE Service (
    ID VARCHAR(40),
    service_name VARCHAR(100) NOT NULL,
    managed_by VARCHAR(40),
    service_location VARCHAR(40) NOT NULL,
    PRIMARY KEY (ID),
    FOREIGN KEY (managed_by) REFERENCES Worker(username),
    FOREIGN KEY (service_location) REFERENCES Location(label)
);

CREATE TABLE Work_For (
    work_ID VARCHAR(40),
    service_ID VARCHAR(40),
    PRIMARY KEY (work_ID, service_ID),
    FOREIGN KEY (work_ID) REFERENCES Worker(username),
    FOREIGN KEY (service_ID) REFERENCES Service(ID)
);

CREATE TABLE Van (
    to_service VARCHAR(40),
    tag VARCHAR(40),
    fuel INT NOT NULL CHECK (fuel >= 0),
    capacity INT NOT NULL CHECK (capacity >= 0),
    sales INT NOT NULL DEFAULT 0 CHECK (sales >= 0),
    to_username VARCHAR(40),
    van_location VARCHAR(40) NOT NULL,
    PRIMARY KEY (to_service, tag),
    FOREIGN KEY (to_service) REFERENCES Service(ID),
    FOREIGN KEY (to_username) REFERENCES Driver(username),
    FOREIGN KEY (van_location) REFERENCES Location(label)
);

CREATE TABLE Product (
    barcode VARCHAR(40),
    iname VARCHAR(100) NOT NULL,
    weight INT NOT NULL CHECK (weight > 0),
    PRIMARY KEY (barcode)
);

CREATE TABLE Contain (
    to_product VARCHAR(40),
    to_van_service VARCHAR(40),
    to_van_tag VARCHAR(40),
    price INT NOT NULL CHECK (price >= 0),
    quantity INT NOT NULL CHECK (quantity >= 0),
    PRIMARY KEY (to_product, to_van_service, to_van_tag),
    FOREIGN KEY (to_product) REFERENCES Product(barcode),
    FOREIGN KEY (to_van_service, to_van_tag) REFERENCES Van(to_service, tag)
);
INSERT INTO Location (label, x_coord, y_coord, space) VALUES ('southside', 1, -16, 5);
INSERT INTO Location (label, x_coord, y_coord, space) VALUES ('buckhead', 7, 10, 8);
INSERT INTO Location (label, x_coord, y_coord, space) VALUES ('airport', 5, -6, 15);
INSERT INTO Location (label, x_coord, y_coord, space) VALUES ('avalon', 2, 15, 12);
INSERT INTO Location (label, x_coord, y_coord, space) VALUES ('highpoint', 11, 3, 4);
INSERT INTO Location (label, x_coord, y_coord, space) VALUES ('downtown', -4, -3, 10);
INSERT INTO Location (label, x_coord, y_coord, space) VALUES ('springs', 7, 10, 8);
INSERT INTO Location (label, x_coord, y_coord, space) VALUES ('highlands', 2, 1, 7);
INSERT INTO Location (label, x_coord, y_coord, space) VALUES ('midtown', 2, 1, 7);
INSERT INTO Location (label, x_coord, y_coord, space) VALUES ('plaza', -4, -3, 10);
INSERT INTO Location (label, x_coord, y_coord, space) VALUES ('mercedes', -8, 5, NULL);
INSERT INTO User (username, address, birthdate, first_name, last_name) VALUES ('agarcia7', '710 Living Water Drive', '1966-10-29', 'Alejandro', 'Garcia');
INSERT INTO User (username, address, birthdate, first_name, last_name) VALUES ('awilson5', '220 Peachtree Street', '1963-11-11', 'Aaron', 'Wilson');
INSERT INTO User (username, address, birthdate, first_name, last_name) VALUES ('bsummers4', '5105 Dragon Star Circle', '1976-02-09', 'Brie', 'Summers');
INSERT INTO User (username, address, birthdate, first_name, last_name) VALUES ('cjordan5', '77 Infinite Stars Road', '1966-06-05', 'Clark', 'Jordan');
INSERT INTO User (username, address, birthdate, first_name, last_name) VALUES ('ckann5', '64 Knights Square Trail', '1972-09-01', 'Carrot', 'Kann');
INSERT INTO User (username, address, birthdate, first_name, last_name) VALUES ('csoares8', '706 Living Stone Way', '1965-09-03', 'Claire', 'Soares');
INSERT INTO User (username, address, birthdate, first_name, last_name) VALUES ('echarles19', '22 Peachtree Street', '1974-05-06', 'Ella', 'Charles');
INSERT INTO User (username, address, birthdate, first_name, last_name) VALUES ('eross10', '22 Peachtree Street', '1975-04-02', 'Erica', 'Ross');
INSERT INTO User (username, address, birthdate, first_name, last_name) VALUES ('fprefontaine6', '10 Hitch Hikers Lane', '1961-01-28', 'Ford', 'Prefontaine');
INSERT INTO User (username, address, birthdate, first_name, last_name) VALUES ('hstark16', '53 Tanker Top Lane', '1971-10-27', 'Harmon', 'Stark');
INSERT INTO User (username, address, birthdate, first_name, last_name) VALUES ('jstone5', '101 Five Finger Way', '1961-01-06', 'Jared', 'Stone');
INSERT INTO User (username, address, birthdate, first_name, last_name) VALUES ('lrodriguez5', '360 Corkscrew Circle', '1975-04-02', 'Lina', 'Rodriguez');
INSERT INTO User (username, address, birthdate, first_name, last_name) VALUES ('mrobot1', '10 Autonomy Trace', '1988-11-02', 'Mister', 'Robot');
INSERT INTO User (username, address, birthdate, first_name, last_name) VALUES ('mrobot2', '10 Clone Me Circle', '1988-11-02', 'Mister', 'Robot');
INSERT INTO User (username, address, birthdate, first_name, last_name) VALUES ('rlopez6', '8 Queens Route', '1999-09-03', 'Radish', 'Lopez');
INSERT INTO User (username, address, birthdate, first_name, last_name) VALUES ('sprince6', '22 Peachtree Street', '1968-06-15', 'Sarah', 'Prince');
INSERT INTO User (username, address, birthdate, first_name, last_name) VALUES ('tmccall5', '360 Corkscrew Circle', '1973-03-19', 'Trey', 'McCall');
INSERT INTO Employee (username, experience, hired, salary, tax_id) VALUES ('agarcia7', 24, '2019-03-17', 41000, '999-99-9999');
INSERT INTO Employee (username, experience, hired, salary, tax_id) VALUES ('awilson5', 9, '2020-03-15', 46000, '111-11-1111');
INSERT INTO Employee (username, experience, hired, salary, tax_id) VALUES ('bsummers4', 17, '2018-12-06', 35000, '000-00-0000');
INSERT INTO Employee (username, experience, hired, salary, tax_id) VALUES ('ckann5', 27, '2019-08-03', 46000, '640-81-2357');
INSERT INTO Employee (username, experience, hired, salary, tax_id) VALUES ('csoares8', 26, '2019-02-25', 57000, '888-88-8888');
INSERT INTO Employee (username, experience, hired, salary, tax_id) VALUES ('echarles19', 3, '2021-01-02', 27000, '777-77-7777');
INSERT INTO Employee (username, experience, hired, salary, tax_id) VALUES ('eross10', 10, '2020-04-17', 61000, '444-44-4444');
INSERT INTO Employee (username, experience, hired, salary, tax_id) VALUES ('fprefontaine6', 5, '2020-04-19', 20000, '121-21-2121');
INSERT INTO Employee (username, experience, hired, salary, tax_id) VALUES ('hstark16', 20, '2018-07-23', 59000, '555-55-5555');
INSERT INTO Employee (username, experience, hired, salary, tax_id) VALUES ('lrodriguez5', 20, '2019-04-15', 58000, '222-22-2222');
INSERT INTO Employee (username, experience, hired, salary, tax_id) VALUES ('mrobot1', 8, '2015-05-27', 38000, '101-01-0101');
INSERT INTO Employee (username, experience, hired, salary, tax_id) VALUES ('mrobot2', 8, '2015-05-27', 38000, '010-10-1010');
INSERT INTO Employee (username, experience, hired, salary, tax_id) VALUES ('rlopez6', 51, '2017-02-05', 64000, '123-58-1321');
INSERT INTO Employee (username, experience, hired, salary, tax_id) VALUES ('tmccall5', 29, '2018-10-17', 33000, '333-33-3333');
INSERT INTO Owner (username) VALUES ('cjordan5');
INSERT INTO Owner (username) VALUES ('jstone5');
INSERT INTO Owner (username) VALUES ('sprince6');
INSERT INTO Worker (username) VALUES ('ckann5');
INSERT INTO Worker (username) VALUES ('echarles19');
INSERT INTO Worker (username) VALUES ('eross10');
INSERT INTO Worker (username) VALUES ('hstark16');
INSERT INTO Worker (username) VALUES ('mrobot2');
INSERT INTO Worker (username) VALUES ('tmccall5');
INSERT INTO Driver (username, licence_ID, licence_type, successful_trips) VALUES ('agarcia7', '610623', 'CDL', 38);
INSERT INTO Driver (username, licence_ID, licence_type, successful_trips) VALUES ('awilson5', '314159', 'commercial', 41);
INSERT INTO Driver (username, licence_ID, licence_type, successful_trips) VALUES ('bsummers4', '411911', 'private', 35);
INSERT INTO Driver (username, licence_ID, licence_type, successful_trips) VALUES ('csoares8', '343563', 'commercial', 7);
INSERT INTO Driver (username, licence_ID, licence_type, successful_trips) VALUES ('fprefontaine6', '657483', 'private', 2);
INSERT INTO Driver (username, licence_ID, licence_type, successful_trips) VALUES ('lrodriguez5', '287182', 'CDL', 67);
INSERT INTO Driver (username, licence_ID, licence_type, successful_trips) VALUES ('mrobot1', '101010', 'CDL', 18);
INSERT INTO Driver (username, licence_ID, licence_type, successful_trips) VALUES ('rlopez6', '235711', 'private', 58);
INSERT INTO Service (ID, service_name, managed_by, service_location) VALUES ('mbm', 'Metro Business Movers', 'hstark16', 'southside');
INSERT INTO Service (ID, service_name, managed_by, service_location) VALUES ('lcc', 'Local Commerce Couriers', 'eross10', 'plaza');
INSERT INTO Service (ID, service_name, managed_by, service_location) VALUES ('pbl', 'Pro Business Logistics', 'echarles19', 'avalon');
INSERT INTO Work_For (work_ID, service_ID) VALUES ('ckann5', 'lcc');
INSERT INTO Work_For (work_ID, service_ID) VALUES ('echarles19', 'pbl');
INSERT INTO Work_For (work_ID, service_ID) VALUES ('eross10', 'lcc');
INSERT INTO Work_For (work_ID, service_ID) VALUES ('hstark16', 'mbm');
INSERT INTO Work_For (work_ID, service_ID) VALUES ('tmccall5', 'mbm');
INSERT INTO Work_For (work_ID, service_ID) VALUES ('mrobot2', 'pbl');
INSERT INTO Business (business_name, rating, spent, business_location) VALUES ('Aircraft Electrical Svc', 5, 10, 'airport');
INSERT INTO Business (business_name, rating, spent, business_location) VALUES ('Homestead Insurance', 5, 30, 'downtown');
INSERT INTO Business (business_name, rating, spent, business_location) VALUES ('Jones and Associates', 3, 0, 'springs');
INSERT INTO Business (business_name, rating, spent, business_location) VALUES ('Prime Solutions', 4, 30, 'buckhead');
INSERT INTO Business (business_name, rating, spent, business_location) VALUES ('Innovative Ventures', 4, 0, 'avalon');
INSERT INTO Business (business_name, rating, spent, business_location) VALUES ('Blue Horizon Enterprises', 4, 10, 'mercedes');
INSERT INTO Business (business_name, rating, spent, business_location) VALUES ('Peak Performance Group', 5, 20, 'highlands');
INSERT INTO Business (business_name, rating, spent, business_location) VALUES ('Summit Strategies', 2, 0, 'southside');
INSERT INTO Business (business_name, rating, spent, business_location) VALUES ('Elevate Consulting', 5, 30, 'midtown');
INSERT INTO Business (business_name, rating, spent, business_location) VALUES ('Pinnacle Partners', 4, 10, 'plaza');
INSERT INTO Fund (to_owner, to_business, fund_date, invested) VALUES ('jstone5', 'Jones and Associates', '2022-10-25', 20);
INSERT INTO Fund (to_owner, to_business, fund_date, invested) VALUES ('sprince6', 'Blue Horizon Enterprises', '2022-03-06', 10);
INSERT INTO Fund (to_owner, to_business, fund_date, invested) VALUES ('jstone5', 'Peak Performance Group', '2022-09-08', 30);
INSERT INTO Fund (to_owner, to_business, fund_date, invested) VALUES ('jstone5', 'Elevate Consulting', '2022-07-25', 5);
INSERT INTO Van (to_service, tag, fuel, capacity, sales, to_username, van_location) VALUES ('mbm', '1', 100, 6, 0, 'fprefontaine6', 'southside');
INSERT INTO Van (to_service, tag, fuel, capacity, sales, to_username, van_location) VALUES ('mbm', '5', 27, 7, 100, 'fprefontaine6', 'buckhead');
INSERT INTO Van (to_service, tag, fuel, capacity, sales, to_username, van_location) VALUES ('mbm', '8', 100, 8, 0, 'bsummers4', 'southside');
INSERT INTO Van (to_service, tag, fuel, capacity, sales, to_username, van_location) VALUES ('mbm', '11', 25, 10, 0, NULL, 'buckhead');
INSERT INTO Van (to_service, tag, fuel, capacity, sales, to_username, van_location) VALUES ('mbm', '16', 17, 5, 40, 'fprefontaine6', 'buckhead');
INSERT INTO Van (to_service, tag, fuel, capacity, sales, to_username, van_location) VALUES ('lcc', '1', 100, 9, 0, 'awilson5', 'airport');
INSERT INTO Van (to_service, tag, fuel, capacity, sales, to_username, van_location) VALUES ('lcc', '2', 75, 7, 0, NULL, 'airport');
INSERT INTO Van (to_service, tag, fuel, capacity, sales, to_username, van_location) VALUES ('pbl', '3', 100, 5, 50, 'agarcia7', 'avalon');
INSERT INTO Van (to_service, tag, fuel, capacity, sales, to_username, van_location) VALUES ('pbl', '7', 53, 5, 100, 'agarcia7', 'avalon');
INSERT INTO Van (to_service, tag, fuel, capacity, sales, to_username, van_location) VALUES ('pbl', '8', 100, 6, 0, 'agarcia7', 'highpoint');
INSERT INTO Van (to_service, tag, fuel, capacity, sales, to_username, van_location) VALUES ('pbl', '11', 90, 6, 0, NULL, 'highpoint');
INSERT INTO Product (barcode, iname, weight) VALUES ('pn_2D7Z6C', 'pens', 5);
INSERT INTO Product (barcode, iname, weight) VALUES ('pt_16WEF6', 'paper towels', 6);
INSERT INTO Product (barcode, iname, weight) VALUES ('st_2D4E6L', 'shipping tape', 3);
INSERT INTO Product (barcode, iname, weight) VALUES ('hm_5E7L23M', 'hammer', 3);
INSERT INTO Contain (to_product, to_van_service, to_van_tag, price, quantity) VALUES ('pn_2D7Z6C', 'pbl', '3', 28, 2);
INSERT INTO Contain (to_product, to_van_service, to_van_tag, price, quantity) VALUES ('pn_2D7Z6C', 'mbm', '5', 30, 1);
INSERT INTO Contain (to_product, to_van_service, to_van_tag, price, quantity) VALUES ('pt_16WEF6', 'lcc', '1', 20, 5);
INSERT INTO Contain (to_product, to_van_service, to_van_tag, price, quantity) VALUES ('pt_16WEF6', 'mbm', '8', 18, 4);
INSERT INTO Contain (to_product, to_van_service, to_van_tag, price, quantity) VALUES ('st_2D4E6L', 'lcc', '1', 23, 3);
INSERT INTO Contain (to_product, to_van_service, to_van_tag, price, quantity) VALUES ('st_2D4E6L', 'mbm', '11', 19, 3);
INSERT INTO Contain (to_product, to_van_service, to_van_tag, price, quantity) VALUES ('st_2D4E6L', 'mbm', '1', 27, 6);
INSERT INTO Contain (to_product, to_van_service, to_van_tag, price, quantity) VALUES ('hm_5E7L23M', 'lcc', '2', 14, 7);
INSERT INTO Contain (to_product, to_van_service, to_van_tag, price, quantity) VALUES ('hm_5E7L23M', 'pbl', '3', 15, 2);
INSERT INTO Contain (to_product, to_van_service, to_van_tag, price, quantity) VALUES ('hm_5E7L23M', 'mbm', '5', 17, 4);