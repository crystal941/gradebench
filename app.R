library(DT)
library(shiny)
library(readr)   
source("R/validate.R")
source("R/analytics.R")

ui <- navbarPage("GradeBench Prototype",
                 tabPanel("Upload",
                          sidebarLayout(
                            sidebarPanel(
                              radioButtons("data_source", "Select Data Source:",
                                           choices = c("Local CSV" = "local", "Databricks SQL" = "databricks"),
                                           selected = "local", inline = TRUE),
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
                          sidebarLayout(
                            sidebarPanel(
                              h4("Weights"),
                              sliderInput("w_a1", "Assignment A1 weight (%)", min=0, max=100, value=30),
                              sliderInput("w_a2", "Assignment A2 weight (%)", min=0, max=100, value=30),
                              sliderInput("w_a3", "Assignment A3 weight (%)", min=0, max=100, value=40),
                              helpText("Weights must sum to 100%"),
                              
                              h4("Grade Boundaries (%)"),
                              numericInput("cut_a", "A cutoff", 85, min=0, max=100),
                              numericInput("cut_b", "B cutoff", 75, min=0, max=100),
                              numericInput("cut_c", "C cutoff", 60, min=0, max=100),
                              numericInput("cut_d", "D cutoff", 50, min=0, max=100),
                              
                              downloadButton("download_results", "Download Adjusted Results")
                            ),
                            mainPanel(
                              h4("Before vs After Comparison"),
                              plotOutput("dist_before"),
                              plotOutput("dist_after"),
                              DTOutput("changes_table")
                            )
                          )
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
    if (input$data_source == "local") {
      # ---- Local CSV route ----
      req(input$students_file, input$marks_file)
      
      s_raw <- read_csv_safe(input$students_file$datapath)
      m_raw <- read_csv_safe(input$marks_file$datapath)
      
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
        students(NULL); marks(NULL)
      }
      
    } else if (input$data_source == "databricks") {
      source("R/db_connect.R")
      con <- get_databricks_con()
      if (inherits(con, "error")) {
        validation_results(data.frame(
          column="db", issue=paste("Databricks connection error:", con$message),
          student_id=NA, assignment_id=NA, question_id=NA
        ))
        students(NULL); marks(NULL)
        return()
      }
      on.exit(DBI::dbDisconnect(con), add = TRUE)
      
      s_raw <- DBI::dbGetQuery(con, "SELECT * FROM workspace.gradebench.silver_students")
      m_raw <- DBI::dbGetQuery(con, "SELECT * FROM workspace.gradebench.silver_marks")
      
      validation_results(data.frame(column="OK", issue="Loaded from Databricks",
                                    student_id=NA, assignment_id=NA, question_id=NA))
      students(s_raw); marks(m_raw)
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
  
  # Reactive: base scenario (default weights + default cuts)
  base_results <- reactive({
    req(marks())
    weights <- c(A1=0.3, A2=0.3, A3=0.4)
    cuts <- c(A=85, B=75, C=60, D=50)
    apply_scenario(marks(), weights, cuts)
  })
  
  # Reactive: new scenario from user input
  new_results <- reactive({
    req(marks())
    w_total <- input$w_a1 + input$w_a2 + input$w_a3
    if (w_total == 0) return(NULL)
    
    weights <- c(A1=input$w_a1, A2=input$w_a2, A3=input$w_a3) / w_total
    cuts <- c(A=input$cut_a, B=input$cut_b, C=input$cut_c, D=input$cut_d)
    
    apply_scenario(marks(), weights, cuts)
  })
  
  # Comparison
  comparison <- reactive({
    req(base_results(), new_results())
    compare_scenarios(base_results(), new_results())
  })
  
  # Plots
  output$dist_before <- renderPlot({
    req(base_results())
    hist(base_results()$overall, breaks=10, col="skyblue", main="Before Weights", xlab="Overall %")
  })
  
  output$dist_after <- renderPlot({
    req(new_results())
    hist(new_results()$overall, breaks=10, col="orange", main="After Adjustments", xlab="Overall %")
  })
  
  # Table of changes
  output$changes_table <- renderDT({
    req(comparison())
    datatable(comparison())
  })
  
  # Export
  output$download_results <- downloadHandler(
    filename = function() { paste0("adjusted_results.csv") },
    content = function(file) {
      write.csv(new_results(), file, row.names=FALSE)
    }
  )
  
}



shinyApp(ui, server)
