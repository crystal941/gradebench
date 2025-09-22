-- Always work in the right place
USE CATALOG workspace;
USE SCHEMA gradebench;

-- 1) Create (or replace) EXTERNAL SOURCE TABLES that point at your Volume paths
--    These are "raw readers" over the CSV folders; they are not Delta.
DROP TABLE IF EXISTS bronze_students_src;
CREATE EXTERNAL TABLE bronze_students_src
USING CSV
OPTIONS (header 'true')
LOCATION '/Volumes/workspace/gradebench/ingest/students/';

DROP TABLE IF EXISTS bronze_marks_src;
CREATE EXTERNAL TABLE bronze_marks_src
USING CSV
OPTIONS (header 'true')
LOCATION '/Volumes/workspace/gradebench/ingest/marks/';

-- 2) Create (once) the managed Delta BRONZE tables with the exact schema you want
CREATE TABLE IF NOT EXISTS bronze_students (
  student_id STRING,
  tutorial   STRING,
  name       STRING
) USING DELTA;

CREATE TABLE IF NOT EXISTS bronze_marks (
  student_id    STRING,
  assignment_id STRING,
  question_id   INT,
  mark          DOUBLE,
  max_mark      DOUBLE,
  marked_at     DATE
) USING DELTA;

-- 3) Overwrite Bronze from the external sources with explicit CASTs
--    (deterministic schema; avoids any "merge fields" inference issues)
INSERT OVERWRITE TABLE bronze_students
SELECT
  CAST(student_id AS STRING) AS student_id,
  CAST(tutorial   AS STRING) AS tutorial,
  CAST(name       AS STRING) AS name
FROM bronze_students_src;

INSERT OVERWRITE TABLE bronze_marks
SELECT
  CAST(student_id    AS STRING) AS student_id,
  CAST(assignment_id AS STRING) AS assignment_id,
  CAST(question_id   AS INT)    AS question_id,
  CAST(mark          AS DOUBLE) AS mark,
  CAST(max_mark      AS DOUBLE) AS max_mark,
  CAST(TO_DATE(marked_at) AS DATE) AS marked_at
FROM bronze_marks_src;

-- (Optional tidy-up) You can keep the *_src external tables for debugging,
-- or drop them if you prefer a clean schema after loading:
DROP TABLE IF EXISTS bronze_students_src;
DROP TABLE IF EXISTS bronze_marks_src;
