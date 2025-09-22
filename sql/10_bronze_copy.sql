USE CATALOG workspace;
USE SCHEMA gradebench;

CREATE TABLE IF NOT EXISTS bronze_students (
  student_id STRING, tutorial STRING, name STRING
) USING DELTA;

CREATE TABLE IF NOT EXISTS bronze_marks (
  student_id STRING, assignment_id STRING, question_id INT,
  mark DOUBLE, max_mark DOUBLE, marked_at DATE
) USING DELTA;

TRUNCATE TABLE bronze_students;
TRUNCATE TABLE bronze_marks;

COPY INTO bronze_students
  FROM '/Volumes/workspace/gradebench/ingest/students/'
  FILEFORMAT = CSV
  FORMAT_OPTIONS('header'='true', 'inferSchema'='false');

COPY INTO bronze_marks
  FROM '/Volumes/workspace/gradebench/ingest/marks/'
  FILEFORMAT = CSV
  FORMAT_OPTIONS('header'='true', 'inferSchema'='false');
