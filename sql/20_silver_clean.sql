USE CATALOG workspace;
USE SCHEMA gradebench;

-- Silver = validated / typed / deduped
CREATE OR REPLACE TABLE silver_students AS
SELECT DISTINCT
  TRIM(student_id) AS student_id,
  TRIM(tutorial)   AS tutorial,
  TRIM(name)       AS name
FROM bronze_students
WHERE student_id IS NOT NULL AND student_id <> '';

CREATE OR REPLACE TABLE silver_marks AS
WITH base AS (
  SELECT
    TRIM(student_id)            AS student_id,
    TRIM(assignment_id)         AS assignment_id,
    CAST(question_id AS INT)    AS question_id,
    CAST(mark        AS DOUBLE) AS mark,
    CAST(max_mark    AS DOUBLE) AS max_mark,
    CAST(marked_at   AS DATE)   AS marked_at
  FROM bronze_marks
)
SELECT /* dedupe and basic validation */
  b.student_id, b.assignment_id, b.question_id, b.mark, b.max_mark, b.marked_at
FROM (
  SELECT *,
         ROW_NUMBER() OVER (
           PARTITION BY student_id, assignment_id, question_id
           ORDER BY marked_at DESC, mark DESC
         ) AS rn
  FROM base
) b
JOIN silver_students s
  ON b.student_id = s.student_id
WHERE b.rn = 1
  AND b.mark >= 0
  AND b.max_mark > 0
  AND b.mark <= b.max_mark;
