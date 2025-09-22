library(DT)
library(shiny)
library(readr)   
source("R/validate.R")
source("R/analytics.R")

ui <- navbarPage("GradeBench Prototype",
                 tabPanel("Upload",
                          sidebarLayout(
                            sidebarPanel(
                              fileInput("students_file", "Upload Students CSV"),
                              fileInput("marks_file", "Upload Marks CSV"),
                              actionButton("validate", "Run Validation")
                            ),
                            mainPanel(
                              h3("Validation Results"),
                              DTOutput("validation_table")
                            )
                          )
                 ),
                 tabPanel("Explore",
                          fluidRow(
                            column(6,
                                   h4("Assignment Summaries"),
                                   DTOutput("assignment_summary")
                            ),
                            column(6,
                                   h4("Student Totals"),
                                   DTOutput("student_summary")
                            )
                          ),
                          fluidRow(
                            column(6,
                                   plotOutput("hist_plot")
                            ),
                            column(6,
                                   plotOutput("box_plot")
                            )
                          )
                 ),
                 tabPanel("What-if",
                          h3("Coming soon: weights & scenarios")
                 )
)


server <- function(input, output, session) {
  students <- reactiveVal(NULL)
  marks <- reactiveVal(NULL)
  validation_results <- reactiveVal(NULL)
  
  read_csv_safe <- function(path) {
    tryCatch(
      readr::read_csv(path, show_col_types = FALSE, progress = FALSE),
      error = function(e) e  # return the error object
    )
  }
  
  observeEvent(input$validate, {
    req(input$students_file, input$marks_file)
    
    s_raw <- read_csv_safe(input$students_file$datapath)
    m_raw <- read_csv_safe(input$marks_file$datapath)
    
    # If readr returned an error object, show it nicely
    if (inherits(s_raw, "error") || inherits(m_raw, "error")) {
      msg <- paste(
        if (inherits(s_raw, "error")) paste0("Students CSV error: ", s_raw$message) else NULL,
        if (inherits(m_raw, "error")) paste0("Marks CSV error: ", m_raw$message) else NULL,
        sep = "\n"
      )
      validation_results(data.frame(
        column = "read_csv", issue = msg,
        student_id = NA, assignment_id = NA, question_id = NA
      ))
      students(NULL); marks(NULL)
      return()
    }
    
    # Run validations (row-specific)
    issues <- rbind(
      validate_students(s_raw),
      validate_marks(m_raw, s_raw)
    )
    
    if (is.null(issues)) {
      validation_results(data.frame(column="OK", issue="No issues found",
                                    student_id = NA, assignment_id = NA, question_id = NA))
      students(s_raw); marks(m_raw)
    } else {
      validation_results(issues)
      students(NULL); marks(NULL)  # block downstream tabs until fixed
    }
  })
  
  output$validation_table <- renderDT({
    req(validation_results())
    datatable(validation_results(), options = list(pageLength = 10))
  })
  
  output$assignment_summary <- renderDT({
    req(marks())
    datatable(assignment_summary(marks()))
  })
  
  output$student_summary <- renderDT({
    req(marks())
    datatable(student_summary(marks()))
  })
  
  output$hist_plot <- renderPlot({
    req(marks())
    plot_distribution(marks())
  })
  
  output$box_plot <- renderPlot({
    req(marks())
    plot_box_assignment(marks())
  })
}



shinyApp(ui, server)
