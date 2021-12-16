#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(ggvis)
library(shinythemes)


fluidPage(
#Selecting a theme for the application from shinythemes
 theme = shinytheme("sandstone"),

 tags$head(
   # Importing fonts as well as choosing one and it's color
   tags$style(HTML("
      @import url('https://fonts.googleapis.com/css2?family=Yusei+Magic&display=swap');
      body {
        color: Green;
      }
      h2 {
        font-family: 'Yusei Magic', sans-serif;
      }
      .shiny-input-container {
        color: #474747;
      }"))),

#Creating all the input options and labels
  titlePanel("Kate's Movie Navigator"),
  sidebarLayout(
    sidebarPanel(
           wellPanel(
             h4("Select Filters:"),
             sliderInput("reviews", "Minimum number of Reviews",
                         10, 300, 80, step = 10),
             sliderInput("year", "Year Movie was Released", 1940, 2014, value = c(1970, 2014),
                         sep = ""),
             selectInput("genre", "Genre - Some movies have multiple genres)",
                         c("All", "Action", "Adventure", "Animation", "Biography", "Comedy",
                           "Crime", "Documentary", "Drama", "Family", "Fantasy", "History",
                           "Horror", "Music", "Musical", "Mystery", "Romance", "Sci-Fi",
                           "Short", "Sport", "Thriller", "War", "Western")),
             sliderInput("oscars", "Number of won Oscars for all categories)",
                         0, 4, 0, step = 1),
             sliderInput("boxoffice", "Dollars at Box Office (millions)",
                         0, 800, c(0, 800), step = 1),

             textInput("cast", "Actor Name:  ")),
    ),


mainPanel(
  tabsetPanel(
    tabPanel("Movie Rating Plot", ggvisOutput("movie_plot"),
                 wellPanel(
                   span("Number of Movies Chosen:",
                        textOutput("movies_chosen")))),
    tabPanel("Explore the Data",
             navbarPage(
               title = 'Data Options:',
               tabPanel('OMDB Data',
                        DT::dataTableOutput('one')),
               tabPanel('Rotten Tomatoes Combined',
                        DT::dataTableOutput('two')),

             plotOutput("mapPlot"))
              )
)
)
)
)
