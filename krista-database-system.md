---
layout: page
title: KRISTA Student Registration System
subtitle: Oracle APEX + Relational Database Design (3NF)
---

## Project Overview
KRISTA Seremban 2 previously relied on manual logbooks and hardcopy documents to manage student registration and operational records. This project delivered a database-driven system to centralize data, reduce duplication, and improve reporting consistency.

## Objectives
- Replace manual record-keeping with a structured database system
- Improve data accuracy and reduce duplicate / inconsistent records
- Enable quick retrieval of student, parent, class, and registration details
- Provide dashboards and reports to support daily operations

## Solution Summary
Built an **Oracle APEX** application backed by a normalized relational database.

**Core modules included:**
- Student and Parent management
- Registration and Class assignment
- Teacher and Package management
- Fee and Receipt tracking
- Reporting dashboards for operational monitoring

## Data Model (ERD)
Designed an ERD for the main business entities (Student, Parent, Registration, Class, Teacher, Package, Fees, Receipts) and normalized the schema up to **Third Normal Form (3NF)** to reduce redundancy and improve data integrity.

![KRISTA ERD](/assets/img/projects/krista/krista-erd.png)  
*Entity-Relationship Diagram showing core entities and key relationships.*

## Database Implementation (SQL DDL/DML)
Implemented tables with primary/foreign keys and validation rules to enforce data quality. Prepared SQL scripts for database creation and sample data population (DDL/DML).

![Student Table DDL](/assets/img/projects/krista/student-table-ddl.png)  
*Example DDL implementation for the Student table with constraints and foreign key relationships.*

## Dashboard & Reporting (Oracle APEX)
Built dashboards and reports to support monitoring and review (e.g., registration handled by teacher, student distribution, and basic operational KPIs).

![KRISTA Dashboard](/assets/img/projects/krista/krista-dashboard.png)  
*Oracle APEX dashboard summarizing registrations, student distribution, and basic KPIs.*

## Skills Demonstrated
- Oracle APEX application development (forms, reports, dashboards)
- SQL (DDL/DML, joins, constraints)
- Relational database design (ERD, normalization to 3NF)
- Data integrity and validation rules
- Documentation (data dictionary, system overview)

[← Back to Projects](/projects.md)
