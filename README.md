# Smart Healthcare Management Project

## Project Overview

This project provides a comprehensive implementation of a scalable, multi-user database system for a smart healthcare management scenario. The system is designed to manage data for a network of hospitals, including information about patients, doctors, appointments, medical records, billing, and more.

The implementation uses PostgreSQL and includes a complete database schema, sample data, advanced queries, and detailed documentation on the design choices, normalization, and performance considerations.

## How to Run the SQL Scripts

To set up and populate the database, run the SQL scripts in the following order. You can use a tool like `psql` or any graphical database client that supports PostgreSQL.

1.  **`schema.sql`**: This script creates all the tables, constraints, and relationships. It will first drop any existing tables to ensure a clean setup.
    ```bash
    psql -U your_username -d your_database -f schema.sql
    ```

2.  **`data.sql`**: This script populates the tables with realistic sample data. It's important to run this after the schema is created.
    ```bash
    psql -U your_username -d your_database -f data.sql
    ```

3.  **`queries.sql`**: This script contains a set of advanced SQL queries for you to test and see how data can be retrieved from the system. You can run this file or execute the queries one by one.
    ```bash
    psql -U your_username -d your_database -f queries.sql
    ```

4.  **`indexing.sql`**: This script demonstrates the creation of indexes and includes `EXPLAIN ANALYZE` commands to show the performance benefits. It's best to run the `EXPLAIN ANALYZE` statements individually to observe the query plans before and after index creation.
    ```bash
    psql -U your_username -d your_database -f indexing.sql
    ```

## File List

-   `README.md`: This file.
-   `er_diagram.mmd`: Source code for the ER diagram in Mermaid format.
-   `eer_diagram.mmd`: Source code for the EER diagram showing specialization/generalization.
-   `schema.sql`: Contains all `CREATE TABLE` statements for the database schema.
-   `data.sql`: Contains `INSERT` statements to populate the database with sample data.
-   `queries.sql`: A collection of advanced SQL queries to demonstrate the system's capabilities.
-   `indexing.sql`: SQL script for creating indexes and analyzing query performance.
-   `normalization.md`: A detailed explanation of the normalization process from UNF to BCNF.
-   `fd.md`: A document listing the functional dependencies for the major tables.
-   `relational_algebra_and_calculus.md`: Examples of queries written in relational algebra and tuple relational calculus.

## Database Design Explanation

The database is designed using a relational model, normalized to **Boyce-Codd Normal Form (BCNF)** to ensure data integrity and reduce redundancy.

Key design features include:

-   **Specialization/Generalization**: The `app_user` table acts as a supertype for `patient`, `doctor`, and `admin` subtypes. This creates a clean, inheritable structure for user management.
-   **Weak Entity**: `prescription_item` is modeled as a weak entity, dependent on the `prescription` entity. Its primary key is a composite of the `prescription_id` and a partial key `item_number`.
-   **Composite and Multivalued Attributes**:
    -   A user's address is a **composite attribute**, broken down into `street`, `city`, `postal_code`, etc., within the `app_user` table.
    -   A user's phone number is a **multivalued attribute**, handled by a separate `user_phone` table.
-   **N:M Relationships**:
    -   The relationship between `doctor` and `specialty` is many-to-many, resolved through the `doctor_specialty` associative table.
    -   The relationship between `patient` and `insurance_provider` is many-to-many, resolved through the `patient_insurance` table.
-   **Constraints**: The schema makes extensive use of `PRIMARY KEY`, `FOREIGN KEY`, `UNIQUE`, `NOT NULL`, and `CHECK` constraints to enforce data integrity at the database level. `ON DELETE` rules are used to manage cascading deletes where appropriate.
