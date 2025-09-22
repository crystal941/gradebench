validate_students <- function(df) {
  required_cols <- c("student_id", "tutorial", "name")
  issues <- list()
  
  # Missing columns
  missing <- setdiff(required_cols, names(df))
  if (length(missing) > 0) {
    issues <- append(issues, list(
      data.frame(
        column = missing,
        issue = "Missing required column",
        student_id = NA, assignment_id = NA, question_id = NA,
        stringsAsFactors = FALSE
      )
    ))
  }
  
  # Duplicate student_id
  dup_ids <- df$student_id[duplicated(df$student_id)]
  if (length(dup_ids) > 0) {
    issues <- append(issues, list(
      data.frame(
        column = "student_id",
        issue = paste("Duplicate ID"),
        student_id = dup_ids, assignment_id = NA, question_id = NA,
        stringsAsFactors = FALSE
      )
    ))
  }
  
  if (length(issues) == 0) return(NULL)
  do.call(rbind, issues)
}

validate_marks <- function(df, students_df) {
  required_cols <- c("student_id","assignment_id","question_id","mark","max_mark","marked_at")
  issues <- list()
  
  # --- FAIL FAST: missing columns ---
  missing <- setdiff(required_cols, names(df))
  if (length(missing) > 0) {
    issues <- append(issues, list(
      data.frame(
        column = missing,
        issue = "Missing required column",
        student_id = NA, assignment_id = NA, question_id = NA,
        stringsAsFactors = FALSE
      )
    ))
    # Return immediately to avoid referencing non-existent columns
    return(do.call(rbind, issues))
  }
  
  # --- Type checks (don't assume numeric) ---
  if (!is.numeric(df$mark)) {
    issues <- append(issues, list(
      data.frame(
        column = "mark", issue = "Marks not numeric",
        student_id = NA, assignment_id = NA, question_id = NA
      )
    ))
  }
  if (!is.numeric(df$max_mark)) {
    issues <- append(issues, list(
      data.frame(
        column = "max_mark", issue = "Max marks not numeric",
        student_id = NA, assignment_id = NA, question_id = NA
      )
    ))
  }
  
  # --- Range check ---
  # Guard again: only run if both columns are numeric
  if (is.numeric(df$mark) && is.numeric(df$max_mark)) {
    bad_range <- df[df$mark < 0 | df$mark > df$max_mark, ]
    if (nrow(bad_range) > 0) {
      issues <- append(issues, list(
        data.frame(
          column = "mark",
          issue = "Out of range",
          student_id = bad_range$student_id,
          assignment_id = bad_range$assignment_id,
          question_id = bad_range$question_id,
          stringsAsFactors = FALSE
        )
      ))
    }
  }
  
  # --- Duplicate key check ---
  dup_keys <- df[duplicated(df[c("student_id","assignment_id","question_id")]), ]
  if (nrow(dup_keys) > 0) {
    issues <- append(issues, list(
      data.frame(
        column = "id combo",
        issue = "Duplicate row",
        student_id = dup_keys$student_id,
        assignment_id = dup_keys$assignment_id,
        question_id = dup_keys$question_id,
        stringsAsFactors = FALSE
      )
    ))
  }
  
  # --- Join sanity ---
  missing_students <- setdiff(unique(df$student_id), students_df$student_id)
  if (length(missing_students) > 0) {
    issues <- append(issues, list(
      data.frame(
        column = "student_id",
        issue = "Not found in students.csv",
        student_id = missing_students,
        assignment_id = NA,
        question_id = NA,
        stringsAsFactors = FALSE
      )
    ))
  }
  
  if (length(issues) == 0) return(NULL)
  do.call(rbind, issues)
}
