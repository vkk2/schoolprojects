## ui.R
library(shiny)
library(shinydashboard)
library(recommenderlab)
library(data.table)
library(ShinyRatingInput)
library(shinyjs)
library(dplyr)

source('functions/helpers.R')

shinyUI(
    dashboardPage(
          skin = "blue",
          dashboardHeader(title = "Movie Recommender"),
          
          dashboardSidebar(
            sidebarMenu(
              menuItem("By Genre", tabName = "genre", icon = icon("dashboard")),
              #selectInput("category", "Select a category", c("1", "2")),
              menuItem("By Rating", tabName = "rating", icon = icon("dashboard"))
            )),
            

          dashboardBody(
            tabItems(
              tabItem(tabName = "rating",
              includeCSS("css/movies.css"),
              fluidRow(
                  box(width = 12, title = "Step 1: Rate as many movies as possible", status = "info", solidHeader = TRUE, collapsible = TRUE,
                      div(class = "rateitems",
                          uiOutput('ratings')
                      )
                  )
                ),
              fluidRow(
                  useShinyjs(),
                  box(
                    width = 12, status = "info", solidHeader = TRUE,
                    title = "Step 2: Discover movies you might like",
                    br(),
                    withBusyIndicatorUI(
                      actionButton("btn", "Click here to get your recommendations", class = "btn-warning")
                    ),
                    br(),
                    tableOutput("results")
                  )
                )
              ),#ratingtabname
              tabItem(tabName = "genre",
                      #h2("bygenre tab content")
                      includeCSS("css/movies.css"),
                      fluidRow(
                        box(width = 12,height=200, title = "Step 1: Choose a genre", status = "info", solidHeader = TRUE, collapsible = TRUE,
                            div(class = "rateitems",
                               selectInput("state", "Choose Genre", choices=c("Action", "Adventure", "Animation",
                                                                                           "Children's", "Comedy", "Crime",
                                                                                           "Documentary", "Drama", "Fantasy",
                                                                                           "Film-Noir", "Horror", "Musical",
                                                                                           "Mystery", "Romance", "Sci-Fi",
                                                                                           "Thriller", "War", "Western"))
                            )
                        )
                      ),
                      fluidRow(
                        useShinyjs(),
                        box(
                          width = 12, status = "info", solidHeader = TRUE, id="tabset1",
                          title = "Step 2: Top 5 rated movies from selected genre",
                          br(),
                        #  withBusyIndicatorUI(
                        #    actionButton("btn", "Click here to get your recommendations", class = "btn-warning")
                        #  ),
                          br(),
                          #tableOutput("results")
                          
                          #tableOutput("table1")
                          tableOutput("genreresults")
                        )
                      )
              )#genre tab
            )#tabname
          )
    )
) 