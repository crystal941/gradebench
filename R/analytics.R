library(dplyr)
library(ggplot2)

# Compute assignment-level summaries
assignment_summary <- function(marks) {
  marks %>%
    group_by(assignment_id, student_id) %>%
    summarise(assignment_total = sum(mark) / sum(max_mark) * 100, .groups="drop") %>%
    group_by(assignment_id) %>%
    summarise(
      mean_pct = mean(assignment_total),
      median_pct = median(assignment_total),
      sd_pct = sd(assignment_total),
      n = n(),
      .groups="drop"
    )
}

# Compute student-level totals (across all assignments)
student_summary <- function(marks) {
  marks %>%
    group_by(student_id, assignment_id) %>%
    summarise(assignment_total = sum(mark) / sum(max_mark) * 100, .groups="drop") %>%
    group_by(student_id) %>%
    summarise(overall_pct = mean(assignment_total), .groups="drop")
}

# Histogram plot
plot_distribution <- function(marks) {
  ggplot(marks, aes(x = mark/max_mark*100)) +
    geom_histogram(binwidth = 5, fill="steelblue", color="white") +
    labs(title="Distribution of Question Scores (%)",
         x="Percentage", y="Count") +
    theme_minimal()
}

# Boxplot per assignment
plot_box_assignment <- function(marks) {
  ggplot(marks, aes(x=assignment_id, y=mark/max_mark*100)) +
    geom_boxplot(fill="lightgreen") +
    labs(title="Boxplot of Question Scores by Assignment",
         x="Assignment", y="Percentage") +
    theme_minimal()
}
