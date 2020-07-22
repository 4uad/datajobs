server = function(input, output) {
  
  # toggle filters panel
  
  onclick("filtertoggle", toggleClass(class = "filteroff", selector = ".filter-panel"))
  
  # Country selector, based on unique dt$country
  
  output$countrySel = renderUI({
    
    countries = unique(data$country)
    choices = sprintf("<img src='images/%s.png' width=30px><div class='icon-list-item'>%s</div></img>", countries, countries)
    
    pickerInput(inputId = "countries",
                  label = "Countries",
                  choices = countries,
                  choicesOpt = list(content = choices))
    
    
    # # Try this when there are multiple countries:
    # countries = unique(data$country)
    # flags = sprintf("images/%s.png", countries)
    # 
    # multiInput(
    #   inputId = "country",
    #   label = "Countries", 
    #   choices = countries,
    #   choiceNames = lapply(seq_along(countries), 
    #                        function(i) tagList(tags$img(src = flags[i],
    #                                                     width = 20, 
    #                                                     height = 15), countries[i])),
    #   choiceValues = countries,
    #   selected = countries
    # )
    
  })
  
  # location selector, based on unique data$region
  
  output$locSel = renderUI({
    
    dtByLoc = data[!duplicated(id)]
    dtByLoc = dtByLoc[, .(n = .N), by = region]
    
    setorder(dtByLoc, -n)
    locations = paste0(dtByLoc$region, " (", dtByLoc$n, ")")
    
    multiInput(
      inputId = "locations",
      label = "Locations",
      choiceNames = locations,
      choiceValues = dtByLoc$region,
      selected = dtByLoc$region,
    )
    
  })
  
  # seniority selector, based on unique dt$seniority
  
  output$senioritySel = renderUI({
    
    dtBySeniority = data[!duplicated(id)]
    dtBySeniority = dtBySeniority[, .(n = .N), by = seniority]
    
    setorder(dtBySeniority, -n)
    seniorities = paste0(dtBySeniority$seniority, " (", dtBySeniority$n, ")")
    
    checkboxGroupInput("seniority", "Seniority", selected = dtBySeniority$seniority,
                             choiceNames = seniorities, choiceValues = dtBySeniority$seniority)

    
    # # use this when there are more levels
    # multiInput(
    #   inputId = "seniority",
    #   label = "Seniority",
    #   choices = seniorities,
    #   choiceNames = seniorities,
    #   choiceValues = dtByLoc$region,
    #   selected = seniorities
    # )
    
  })
  
  # industry selector, based on unique dt$seniority
  
  output$industrySel = renderUI({
    
    dtByIndustry = data[!duplicated(id)]
    dtByIndustry = dtByIndustry[, .(n = .N), by = industry]
    
    setorder(dtByIndustry, -n)
    industries = paste0(dtByIndustry$industry, " (", dtByIndustry$n, ")")
    
    multiInput(
      inputId = "industry",
      label = "Industry",
      choiceNames = industries,
      choiceValues = dtByIndustry$industry,
      selected = dtByIndustry$industry
    )
    
  })
  
  # role selector, based on unique dt$role
  
  output$roleSel = renderUI({
    
    dtByRole = data[!duplicated(id)]
    dtByRole = dtByRole[, .(n = .N), by = role]
    
    setorder(dtByRole, -n)
    roles = paste0(dtByRole$role, " (", dtByRole$n, ")")
    
    checkboxGroupInput("role", "Role", selected = dtByRole$role,
                       choiceNames = roles, choiceValues = dtByRole$role)
    
  })
  
  # plot output, barplot
  
  output$plot = renderPlot({
    
    req(input$role)
    req(input$industry)
    req(input$seniority)
    req(input$locations)
    req(input$countries)
    
    # filter according to user input
    
    dt = data[role %in% input$role &
              industry %in% input$industry &
              seniority %in% input$seniority &
              region %in% input$locations &
              country %in% input$countries]
    
    validate(
      need(nrow(dt) > 10, "Please, remove some filters. There aren't enough values to extract relevant results.")
    )
    
    # frequency table
    
    dt = unique(dt[, c("id", "skill")])
    
    ad_count = sum(!duplicated(dt$id))
    
    skill_freq = dt[, .(n = .N / ad_count), by = skill]
    
    setorder(skill_freq, -n) # most wanted skills first
    
    skill_freq$skill = paste0("#", gsub("-", " ", toupper(skill_freq$skill))) # skill name pre-processing (esthetics)
    
    skill_freq = skill_freq[1:nskills, ] # keep only top demanded skills
    
    skill_freq$skill = factor(skill_freq$skill, levels = skill_freq$skill) # character to factor, so the order is preserved in plot
    
    palette = colorRampPalette(colors=c("#C70010", "#8100C6"))
    colors = palette(nrow(skill_freq))
    
    par(mar = c(0, 4, 4, 2)) # removes bottom margin
    
    bp = barplot(n ~ skill,
                data = skill_freq,
                axes = F,
                xlab = "",
                xaxt = "n",
                yaxt = "n",
                ylim = c(0, max(skill_freq$n) + 0.02),
                ann = F,
                col = colors)
    
    bp
    
    # add labels
    
    text(x = bp,
         y = skill_freq$n + 0.005,
         labels = sprintf("%.1f%% of jobs demand...", skill_freq$n * 100),
         col = "#808080",
         font = 2)
    
    text(x = bp,
         y = skill_freq$n - 0.01,
         labels = skill_freq$skill,
         col = "white",
         font = 2,
         cex = 2,
         pos = 4,
         srt = -90,
         offset = -0.2)
    
  }, height = 1000)
}