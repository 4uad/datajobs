combineTownNames = function(names) {
  # Combines comma-separated parts of a string:
  # i.e.
  # "Campello, El" becomes "El Campello"
  # "Estartit, L'" becomes "L'Estartit"
  
  newNames = lapply(
    names,
    function(name) {
      binome = strsplit(name, ", ")[[1]]
      
      if(grepl("'", binome[2], fixed = T)) {
        return(paste0(binome[2], binome[1]))
      } else {
        return(paste(binome[2], binome[1]))
      }
    }
  )
  
  return(newNames)
  
}

splitTownName = function(dt, sep = "/") {
  
  # Splits a string separated by sep into different rows of the dt
  # i.e.
  # A row with value "Elche / Elx" becomes two rows:
  # one with Elche
  # other with Elx
  
  output1 = copy(dt)
  output2 = copy(dt)
  
  output1$town = lapply(
    output1$town,
    function(name) {
      binome = strsplit(name, sep)[[1]]
      
      return(binome[1])
    }
  )
  
  output2$town = lapply(
    output2$town,
    function(name) {
      binome = strsplit(name, sep)[[1]]
      
      return(binome[2])
    }
  )
  
  return(
    rbind(
      output1,
      output2
    )
  )
  
}

loadLocations = function(path) {
  # Given a filename in the wd, loads
  # a list of towns and their region
  
  # town <-> zip code mapping
  towns = setDT(read_excel(path, skip = 1))
  
  towns[, CPRO := as.integer(CPRO)] # zip code is an integer
  setnames(towns, "NOMBRE", "town")
  towns = towns[, c("CPRO", "town")]
  
  # zip code <-> region mapping
  zip = setDT(read_excel(path, sheet = 2, skip = 2, col_names = c("CPRO", "town", "code")))
  zip = zip[, c("CPRO", "town")]
  
  # some locations only include the region name, so we list region names as towns too
  towns = rbind(towns, zip)
  
  setnames(zip, "town", "region")
  
  # assign each town-zip pair its correpsonding region
  towns = zip[towns, on = "CPRO"]
  
  # if there is no region for town name, assume the region name is the same as town
  towns[is.na(region), region := town]
  
  return(towns)
}

splitTownNames = function(dt, sep = "/") {
  
  townBilingual = dt[grepl(sep, town, fixed = T)]
  
  return(
    rbind(
      dt,
      splitTownName(townBilingual, sep = sep)
    )
  )
  
}

standardizeLocations = function(dt) {
  
  dt = copy(dt)
  
  # Given a town name <-> region mapping,
  # standardizes town names by different methods:
  
  # 1.- Split bilingual naming into multiple rows
  # i.e.
  # "Elche/Elx" results in two rows:
  # one as "Elche" (name in Spanish)
  # other as "Elx" (name in Catalan)
  
  # These are separated by either / or - in the original mapping
  dt = splitTownNames(dt, "/")
  dt = splitTownNames(dt, "-")
  
  # Also, some Catalan compound names are separated by " i ":
  dt = splitTownNames(dt, " i ")
  
  # 2.- Combine names starting with an article.
  # i.e.
  # "Campello, El" becomes "El Campello"
  
  townsWithComma = dt[grepl(",", town, fixed = T)]
  
  townsWithComma[, town := combineTownNames(town)]
  
  dt = rbind(
    dt,
    townsWithComma
  )
  
  # replace non ASCII characters from location to facilitate regex matching
  dt[, town := iconv(as.character(town), from="UTF-8",to="ASCII//TRANSLIT")]
  
  # Prepare regex column for merging
  dt[, len := nchar(town)] 
  setorder(dt, -len) # longer names are tested first for matches
  dt = dt[, regex := paste0("(^|\\s|,)", town, "([^A-Za-z]|$)")] # construct regex from town name
  # only town names between string start / end, space or comma are matched
  
  return(dt)
}


removeHTML = function(text) {
  out = gsub("[^\x01-\x7F]", "", text)
  return(gsub("<\\/?[a-zA-Z]+>", "", out))
}

removeSpaces = function(text, sep = "-") {
  return(gsub("\\s+", sep, text))
}

dropNonAlpha = function(text, keep = "", replace = "") {
  return(gsub(sprintf("[^A-Za-z0-9%s]", keep), replace, text))
}

dropMissing = function(dt, col, warning_col = 1) {
  dt = copy(dt)
  
  naCount = sum(is.na(dt[, ..col]))
  
  if(naCount) {
    warning(sprintf("%i missing values in %s:\n %s", naCount, col, paste0(unlist(dt[as.logical(is.na(dt[, ..col])), ..warning_col]), collapse = "\n")))
    
    dt = dt[as.logical(!is.na(dt[, ..col]))]
  }
  
  return(dt)
}

standardizeText = function(text) {
  # prepare text for regex join, by:
  # 1. removing HTML tags
  # 2. replacing spaces by hyphens
  # 3. removing any non alphabetic characters but & and -
  
  text = removeHTML(text)
  text = removeSpaces(text, sep = "-")
  text = dropNonAlpha(text, keep = "'&-", replace = "-")
  
  return(text)
}