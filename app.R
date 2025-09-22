library(shiny)

ui <- fluidPage(
  titlePanel("GradeBench Prototype"),
  sidebarLayout(
    sidebarPanel(
      fileInput("marks", "Upload marks CSV"),
      fileInput("students", "Upload students CSV")
    ),
    mainPanel(
      h3("Hello, Shiny is working 🎉")
    )
  )
)

server <- function(input, output, session) {}

shinyApp(ui, server)
