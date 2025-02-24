# General Shiny App

library(shiny)
library(Seurat)
library(ggplot2)
library(readxl)
library(xlsx)
library(cowplot)


# Define UI for application that draws a histogram
options(shiny.maxRequestSize = 1024^3)

# UI
ui <- fluidPage(
  titlePanel("Gene Feature Plot App"),
  sidebarLayout(
    sidebarPanel(
      fileInput("file1", "Choose RDS object", accept = ".RDS"),
      textInput("gene", "Enter gene (single gene name):", ""),
      uiOutput("reduction_ui"),
      uiOutput("assay_ui"),
      actionButton("search", "Search Gene"),
      hr(),
      verbatimTextOutput("gene_status")
    ),
    mainPanel(
      plotOutput("featurePlot", height = "900px", width = "900px"),  
      downloadButton("downloadPlot", "Download Plot")
    )
  )
)

# Server
server <- function(input, output, session) {
  values <- reactiveValues(plot = NULL, status = NULL, reductions = NULL, assays = NULL)
  
  observeEvent(input$file1, {
    req(input$file1)
    
    # Load the RDS object safely
    object <- tryCatch({
      readRDS(input$file1$datapath)
    }, error = function(e) {
      values$status <- paste("Error reading RDS file:", e$message)
      return(NULL)
    })
    
    if (!is.null(object)) {
      # Get available reductions and assays
      values$reductions <- Reductions(object)
      values$assays <- Assays(object)
    }
  })
  
  output$reduction_ui <- renderUI({
    req(values$reductions)
    selectInput("subset", "Select Reduction:", choices = values$reductions)
  })
  
  output$assay_ui <- renderUI({
    req(values$assays)
    selectInput("assay", "Select Assay:", choices = values$assays)
  })
  
  observeEvent(input$search, {
    req(input$gene, input$file1, input$subset, input$assay)
    
    # Load the RDS object safely
    object <- tryCatch({
      readRDS(input$file1$datapath)
    }, error = function(e) {
      values$status <- paste("Error reading RDS file:", e$message)
      return(NULL)
    })
    
    if (is.null(object)) return()
    
    # Check if the reduction exists
    reduction <- input$subset
    if (!reduction %in% Reductions(object)) {
      values$status <- paste("Reduction", reduction, "not found in the object.")
      return()
    }
    
    gene <- input$gene
    assay <- input$assay
    
    DefaultAssay(object) = assay
    # Generate plots safely
    plots <- tryCatch({
      dotplot_rna <- DotPlot(object, features = gene, assay = assay, dot.scale = 6)
      feature_plot <- FeaturePlot(object, features = gene, reduction = reduction)
      
      cowplot::plot_grid(
        dotplot_rna, feature_plot,
        ncol = 2,
        rel_heights = c(1, 1),
        rel_widths = c(1, 1)
      )
    }, error = function(e) {
      values$status <- paste("Error generating plots:", e$message)
      return(NULL)
    })
    
    if (!is.null(plots)) {
      values$plot <- plots
      values$status <- paste0("Gene '", gene, "' analyzed using assay '", assay, "'.")
    }
  })
  
  output$gene_status <- renderText({
    values$status
  })
  
  output$featurePlot <- renderPlot({
    req(values$plot)
    values$plot
  })
  
  output$downloadPlot <- downloadHandler(
    filename = function() {
      paste0("Feature_Plot_", input$gene, "_", input$assay, ".TIFF")
    },
    content = function(file) {
      ggsave(file, plot = values$plot, width = 12, height = 12)
    }
  )
}

# Run the app
shinyApp(ui = ui, server = server)
