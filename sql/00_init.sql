-- Switch to the correct catalog
USE CATALOG workspace;

-- Create your working schema if it doesn’t exist
CREATE SCHEMA IF NOT EXISTS gradebench;

-- Switch into it
USE SCHEMA gradebench;

-- Optional: show where we are (handy for logs)
SELECT current_catalog() AS catalog, current_schema() AS schema;
