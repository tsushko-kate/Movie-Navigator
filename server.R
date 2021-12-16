#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(ggvis)
library(dplyr)
if (FALSE) {
  library(RSQLite)
  library(dbplyr)
}


# Set up handles to database tables on app start
db <- src_sqlite("data/Omdb_tomatoes_movies.db")
tomatoes <- tbl(db, "tomatoes")
omdb <- tbl(db, "omdb")

# Joining the tables by "ID", and also filtering movies that have less than 10 reviews,
# and select the columns that will be used
movies_combined <- inner_join(omdb, tomatoes, by = "ID") %>%
  filter(Reviews >= 10) %>%
  select(ID, imdbID, Title, Year, Rating_m = Rating.x, Runtime, Genre, Language, Released,
         Writer, imdbRating, imdbVotes, Country, Oscars, Director,
         Rating = Rating.y, Meter, Reviews, Fresh, Rotten, userMeter,  userReviews,
         userRating, BoxOffice, Cast, Production)


function(input, output, session) {

# Creating a reactive function that will filter the movies and will return a data frame
  mov <- reactive({
    # Creating temporary variables to use for input values
    reviews <- input$reviews
    oscars <- input$oscars
    minyear <- input$year[1]
    maxyear <- input$year[2]
    minboxoffice <- input$boxoffice[1] * 1e6
    maxboxoffice <- input$boxoffice[2] * 1e6

    # Applying the filters chosen by the user
    v <- movies_combined %>%
      filter(
        Reviews >= reviews,
        Year <= maxyear,
        Year >= minyear,
        Oscars >= oscars,
        BoxOffice <= maxboxoffice,
        BoxOffice >= minboxoffice
      ) %>%
      arrange(Oscars)

    #Additional filter to filter by cast(actors), using an if statement
    if (!is.null(input$cast) && input$cast != "") {
      cast <- paste0("%", input$cast, "%")
      v <- v %>% filter(Cast %like% cast)
    }

    #Additional filter to filter by genre, using an if statement
    if (input$genre != "All") {
      genre <- paste0("%", input$genre, "%")
      v <- v %>% filter(Genre %like% genre)
    }


    v <- as.data.frame(v)

# Add column which says whether the movie won any Oscars

    v$has_oscar <- character(nrow(v))
    v$has_oscar[v$Oscars >= 1] <- "Yes"
    v$has_oscar[v$Oscars == 0] <- "No"
    v
  })

  # Function for generating the  tooltip text
  movie_tooltip <- function(x) {
    if (is.null(x)) return(NULL)
    if (is.null(x$ID)) return(NULL)

    # Pick out the movie with this ID
    movies_combined <- isolate(mov())
    movie <- movies_combined[movies_combined$ID == x$ID, ]

    paste0("<b>", movie$Title, "</b><br>",
           movie$Year, "<br>",
           "$", format(movie$BoxOffice, big.mark = ",", scientific = FALSE)
    )
  }

  # A reactive expression with the ggvis plot
  vis <- reactive({


  #creating a tooltip that will include the movie name, the year it was made and dollars at box office
  #Adding a legend of which movies have won Oscars
    mov %>%
      ggvis(~Reviews, y = ~Rating) %>%
      add_tooltip(movie_tooltip, "hover") %>%
      layer_points(size := 50, size.hover := 300,
                   fillOpacity := 0.2, fillOpacity.hover := 1,
                   stroke = ~has_oscar, key := ~ID) %>%
      add_legend("stroke", title = "Oscar Won", values = c("Yes", "No")) %>%
      scale_nominal("stroke", domain = c("Yes", "No"),
                    range = c("red", "green", "#aaa")) %>%
      set_options(width = 650, height = 650)
  })

  vis %>% bind_shiny("movie_plot")

  output$movies_chosen <- renderText({ nrow(mov()) })

 #Provides data table of the omdb table that can be narrowed down using the search bar.
  output$one <- DT::renderDataTable(
    DT::datatable(data<- as.data.frame(omdb), options = list(pageLength = 25))
  )

 #Provides data table of the combined tomatoe and omdb tables
  output$two <- DT::renderDataTable(
    DT::datatable(data<- as.data.frame(movies_combined), options = list(pageLength = 25))
  )

}
