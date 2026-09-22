# Business Supply Express - Relational Database System
For this project I designed and implemented a MySQL database system that models a multi-service product delivery network. I worked through the full relational database lifecycle: conceptual design, logical schema, and physical implementation.

## What it models

The system tracks delivery services that manage fleets of vans, employ workers and drivers, and sell products to local businesses. Employees can hold a worker role, a driver role, or manage a service, and a business's purchases are tied to which van is currently at its location. Owners can fund businesses, and the system tracks revenue for each service and debt for each owner.

## What I built

**EERD.** I modeled the entities, weak entities, and subclass/superclass relationships (an employee can be a worker or a driver) along with the multivalued and derived attributes needed to capture the scenario.

**Relational schema.** I converted the EERD into a set of normalized tables with primary keys, foreign keys, and discriminants where entities needed to be identified relative to another entity, like a van being identified relative to its service.

**Stored procedures.** I wrote 17 stored procedures that enforce the system's business rules, including things like preventing a driver from operating vans for two services at once, checking van capacity before loading a payload, and making sure a van only moves if it has enough fuel to reach its destination and get back to home base.

**Views.** I built 6 reporting views that aggregate data across the system, covering service revenue, van payloads, driver stats, and the total debt an owner has taken on based on the businesses they fund.

## Stack

MySQL 8.0, standard SQL (DDL/DML), stored procedures and views

## Files

- `schema.sql` - CREATE TABLE statements with keys and constraints
- `data.sql` - INSERT statements for the initial data set
- `procedures.sql` - stored procedures and views