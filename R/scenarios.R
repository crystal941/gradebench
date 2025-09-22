library(dplyr)

# Apply weights + grade boundaries
apply_scenario <- function(marks, weights, cuts) {
  # Per-student per-assignment %
  per_assign <- marks %>%
    group_by(student_id, assignment_id) %>%
    summarise(pct = sum(mark) / sum(max_mark) * 100, .groups="drop")
  
  # Join with weights
  weighted <- per_assign %>%
    mutate(weight = weights[assignment_id]) %>%
    group_by(student_id) %>%
    summarise(
      overall = sum(pct * weight),
      .groups="drop"
    )
  
  # Apply grade boundaries
  weighted$grade <- case_when(
    weighted$overall >= cuts["A"] ~ "A",
    weighted$overall >= cuts["B"] ~ "B",
    weighted$overall >= cuts["C"] ~ "C",
    weighted$overall >= cuts["D"] ~ "D",
    TRUE ~ "E"
  )
  
  weighted
}

# Compare before vs after
compare_scenarios <- function(base_df, new_df) {
  merged <- base_df %>%
    rename(overall_before = overall, grade_before = grade) %>%
    inner_join(new_df, by="student_id") %>%
    rename(overall_after = overall, grade_after = grade)
  
  merged %>%
    mutate(changed = grade_before != grade_after)
}
