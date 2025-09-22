USE CATALOG workspace;
USE SCHEMA gradebench;

-- Per-student per-assignment percentages
CREATE OR REPLACE TABLE gold_assignment_pct AS
SELECT
  student_id,
  assignment_id,
  100.0 * SUM(mark) / SUM(max_mark) AS assignment_pct
FROM silver_marks
GROUP BY student_id, assignment_id;

-- Assignment summary for dashboards
CREATE OR REPLACE TABLE gold_assignment_summary AS
SELECT
  assignment_id,
  AVG(assignment_pct)   AS mean_pct,
  PERCENTILE_APPROX(assignment_pct, 0.5) AS median_pct,
  STDDEV(assignment_pct) AS sd_pct,
  COUNT(*) AS n
FROM gold_assignment_pct
GROUP BY assignment_id;

-- Overall student totals (simple average of assignment % for now)
CREATE OR REPLACE TABLE gold_student_totals AS
SELECT
  student_id,
  AVG(assignment_pct) AS overall_pct
FROM gold_assignment_pct
GROUP BY student_id;
