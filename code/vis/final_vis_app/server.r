library(shiny)
library(ggvis)
# log transform 
data <- read.csv("002_w2vDim400_1215.csv")
log.data <- data[, 9:349 + 9]
data.cates <- data[, 2]

# apply PCA - scale. = TRUE is highly advisable, but default is FALSE. 
data.pca <- prcomp(log.data, center = TRUE, scale = TRUE)

library(ggbiplot)

shinyServer(function(input, output, session) {
    # A reactive subset of mtcars
    #mtc <- reactive({ mtcars[1:input$n,] })

    # A simple visualisation. In shiny apps, need to register observers
    # and tell shiny where to put the controls
    # mtc %>%
    # ggvis(~wt, ~ mpg) %>%
    # layer_points() %>%
    # bind_shiny("plot", "plot_ui")



    output$plot_ui <- renderPlot({
        g <- ggbiplot(data.pca, choices = c(as.numeric(input$horz), as.numeric(input$vert)), obs.scale = 1, var.scale = 1, groups = data.cates)
        g <- g + xlim(4, -4)
        g <- g + ylim(4, -4)
        g <- g + scale_color_discrete(name = '')
        g <- g + theme(legend.direction = 'horizontal', legend.position = 'top')
        g
    }, height = 400, width = 600)

    output$table1 <- renderDataTable(data)
    output$table2 <- renderTable(as.data.frame(data.pca$rotation), rownames = TRUE)
    output$table3 <- renderTable(as.data.frame(apply(data.pca$rotation, 2, summary)), rownames = TRUE)

})
