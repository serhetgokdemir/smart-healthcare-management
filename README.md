# Smart Healthcare Management Project

## Project Overview

This project provides a database system for a smart healthcare management scenario. The system is designed to manage data for a network of hospitals, including information about patients, doctors, appointments, medical records, billing, and more.

The implementation uses PostgreSQL and includes a complete database schema, sample data, advanced queries, and detailed documentation on the design choices, normalization, and performance considerations.

## Prerequisites

- **PostgreSQL** installed and running.
- Command-line tools available: `psql`, `createdb`, `dropdb`.
- A PostgreSQL role/user with permission to create and drop databases (needed for `setup.sh`).

Schema notes:

- The schema uses a GiST exclusion constraint to prevent overlapping doctor appointments. This requires the `btree_gist` extension (created via `CREATE EXTENSION IF NOT EXISTS btree_gist;`). Your PostgreSQL role must have permission to create extensions.

For the PDF report:

- A LaTeX distribution (e.g., TeX Live) and `latexmk`.

## How to Run the SQL Scripts

There are two ways to set up and populate the database.

### Option A (Recommended): Run the setup script

The repository includes `setup.sh`, which will **drop and recreate** the database and then run the SQL scripts in order.

```bash
chmod +x setup.sh
./setup.sh
```

Notes:

- The default database name is `smart_healthcare` (edit `DB_NAME` in `setup.sh` if needed).
- This script is destructive for the target database name.

### Option B: Run the SQL files manually

If you prefer, you can run the SQL scripts in order using `psql` (or a GUI client that supports PostgreSQL):

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

    Note:

    - Because the sample dataset is small, PostgreSQL may still choose sequential scans even after an index is created. This is normal; index benefits are clearer on larger datasets.

## Build the Report PDF

The LaTeX report source is under `docs/`. To build `report.pdf`:

```bash
cd docs
latexmk -pdf -interaction=nonstopmode -halt-on-error report.tex
```

Output:

- `docs/report.pdf`

Tip:

- If you paste relational algebra/calculus into the LaTeX sources, avoid raw Unicode math symbols when compiling with `pdflatex` (prefer LaTeX commands like `\sigma`, `\in`, `\wedge`).

## File List

-   `README.md`: This file.
-   `setup.sh`: One-command database setup script (drops/creates DB and runs SQL files).
-   `er_diagram.mmd`: Source code for the ER diagram in Mermaid format.
-   `eer_diagram.mmd`: Source code for the EER diagram showing specialization/generalization.
-   `er_diagram.png`: Exported ER diagram image used in the LaTeX report.
-   `eer_diagram.png`: Exported EER diagram image used in the LaTeX report.
-   `schema.sql`: Contains all `CREATE TABLE` statements for the database schema.
-   `data.sql`: Contains `INSERT` statements to populate the database with sample data.
-   `queries.sql`: A collection of advanced SQL queries to demonstrate the system's capabilities.
-   `indexing.sql`: SQL script for creating indexes and analyzing query performance.
-   `normalization.md`: A detailed explanation of the normalization process from UNF to BCNF.
-   `fd.md`: A document listing the functional dependencies for the major tables.
-   `relational_algebra_and_calculus.md`: Examples of queries written in relational algebra and tuple relational calculus.
-   `docs/report.tex`: Main LaTeX entry file for the report.
-   `docs/sections/`: LaTeX sections included by the report.

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
