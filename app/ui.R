ui = fluidPage(
  
  theme = shinytheme("superhero"),
  
  useShinyjs(),
  
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "style/style.css")
  ),
  
  titlePanel("LinkedIn Data Jobs"),
  
  fluidRow(
    plotOutput("plot")
  ),
  
  div(
    fluidRow(
      h3(icon("filter"), "Filters", id = "filtertoggle")
    ),
    
    fluidRow(
      column(4,
             uiOutput("industrySel")
      ),
      column(4,
             fluidRow(
               column(6,
                      h3(" "),
                      uiOutput("senioritySel")
               ),
               column(6,
                      h3(" "),
                      uiOutput("roleSel")
               )
             ),
             fluidRow(
               column(12,
                      uiOutput("countrySel")
               )
             )
      ),
      column(4,
             uiOutput("locSel")
      )
    ),
    class = "filter-panel row filteroff"
  )
  

  # # Alternative layout (too tall)
  # sidebarLayout(sidebarPanel(h3(icon("filter"), "Filters"),
  #                            br(),
  #                            uiOutput("countrySel"), # country selector
  #                            br(),
  #                            uiOutput("locSel"), # region selector
  #                            br(),
  #                            column(12,
  #                              column(6, uiOutput("senioritySel")),
  #                              column(6, uiOutput("roleSel"))
  #                            ),
  #                            br(), br(),
  #                            uiOutput("industrySel")), # industry selector
  #               mainPanel("main panel")
  # )
)