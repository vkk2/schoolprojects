## server.R
library(recommenderlab)
library(Matrix)

# load functions
#source('functions/cf.R')
#source('functions/cf_algorithm.R') # collaborative filtering
#source('functions/similarity_measures.R') # similarity measures

# define functions
get_user_ratings = function(value_list) {
  dat = data.table(MovieID = sapply(strsplit(names(value_list), "_"), 
                                    function(x) ifelse(length(x) > 1, x[[2]], NA)),
                   Rating = unlist(as.character(value_list)))
  dat = dat[!is.null(Rating) & !is.na(MovieID)]
  dat[Rating == " ", Rating := 0]
  dat[, ':=' (MovieID = as.numeric(MovieID), Rating = as.numeric(Rating))]
  dat = dat[Rating > 0]
}

# read in data
myurl = "https://liangfgithub.github.io/MovieData/"
movies = readLines(paste0(myurl, 'movies.dat?raw=true'))
movies = strsplit(movies, split = "::", fixed = TRUE, useBytes = TRUE)
movies = matrix(unlist(movies), ncol = 3, byrow = TRUE)
movies = data.frame(movies, stringsAsFactors = FALSE)
colnames(movies) = c('MovieID', 'Title', 'Genres')
movies$MovieID = as.integer(movies$MovieID)
movies$Title = iconv(movies$Title, "latin1", "UTF-8")

small_image_url = "https://liangfgithub.github.io/MovieImages/"
movies$image_url = sapply(movies$MovieID, 
                          function(x) paste0(small_image_url, x, '.jpg?raw=true'))

####
genre_ratingdf=read.csv("data/genre_rating.csv",stringsAsFactors = FALSE)
genre_list = c("Action", "Adventure", "Animation",
               "Children's", "Comedy", "Crime",
               "Documentary", "Drama", "Fantasy",
               "Film-Noir", "Horror", "Musical",
               "Mystery", "Romance", "Sci-Fi",
               "Thriller", "War", "Western")

shinyServer(function(input, output, session) {
  
  # show the books to be rated
  output$ratings <- renderUI({
    num_rows <- 20
    num_movies <- 6 # movies per row
    
    lapply(1:num_rows, function(i) {
      list(fluidRow(lapply(1:num_movies, function(j) {
        list(box(width = 2,
                 div(style = "text-align:center", img(src = movies$image_url[(i - 1) * num_movies + j], height = 150)),
                 #div(style = "text-align:center; color: #999999; font-size: 80%", books$authors[(i - 1) * num_books + j]),
                 div(style = "text-align:center", strong(movies$Title[(i - 1) * num_movies + j])),
                 div(style = "text-align:center; font-size: 150%; color: #f0ad4e;", ratingInput(paste0("select_", movies$MovieID[(i - 1) * num_movies + j]), label = "", dataStop = 5)))) #00c0ef
      })))
    })
  })
  
  # Calculate recommendations when the sbumbutton is clicked
  df <- eventReactive(input$btn, {
    withBusyIndicatorServer("btn", { # showing the busy indicator
      # hide the rating container
      useShinyjs()
      jsCode <- "document.querySelector('[data-widget=collapse]').click();"
      runjs(jsCode)
      
      # get the user's rating data
      value_list <- reactiveValuesToList(input)
      user_ratings <- get_user_ratings(value_list)
      
      user_results = (1:10)/10
      user_predicted_ids = 1:10
      user_ratings=na.omit(user_ratings)
      #userid=rep(9999,nrow(user_ratings))

      #print(nrow(user_ratings))
#      print(user_ratings[1:5])
      #user_ratings=data.frame("MovieID"=user_ratings$MovieID[1:nrow(user_ratings)],"Rating"=user_ratings$Rating[1:nrow(user_ratings)])
      #userdf=data.frame("UserID"=rep(9999,nrow(user_ratings)))
      #newuser=cbind(userdf,user_ratings)
      #print(head(newuser))
      #print(tail(newuser))
      #print(nrow(newuser))
      #print(ncol(newuser))
      #print(newuser$Rating[1:5])
      
      Rmat_ex=matrix(NA,3706)
      for (i in 1:nrow(user_ratings)){
        Rmat_ex[user_ratings$MovieID[i]]=user_ratings$Rating[i]
      }
      #Rmat_ex[1]=5
      #Rmat_ex[2]=5
     # print(Rmat_ex[1:5])
      Rmat_ex <- as(t(Rmat_ex), "realRatingMatrix")

       trainedmodel=readRDS("data/trainedmodel.rds")
       #Rmat_ex=gettestmatrix(newuser)
       model3_predtop_ex <- predict(object = trainedmodel, newdata = Rmat_ex, n = 10,
                                    type = "topNList")
       recom_list=as(model3_predtop_ex,"list")
      # print(recom_list)
       recom_movieid=as.integer(substring(recom_list[[1]],first=2))
       
       #print(recom_movieid)
       #recom_movieid=as.integer(recom_list[[1]])
      recom_results <- data.table(MovieID=recom_movieid)
      

      
    }) # still busy
    
  }) # clicked on button
  
  
  # display the recommendations
  output$results <- renderUI({
    num_rows <- 2
    num_movies <- 5
    recom_result <- df()

  lapply(1:num_rows, function(i) {
    list(fluidRow(lapply(1:num_movies, function(j) {
      box(width = 2, status = "success", solidHeader = TRUE, title = paste0("Rank ", (i - 1) * num_movies + j),

          div(style = "text-align:center",
              a(img(src = paste0(small_image_url, recom_result$MovieID[(i - 1) * num_movies + j], '.jpg?raw=true'), height = 150))
          ),
          div(style="text-align:center; font-size: 100%",
              strong(movies$Title[which(movies$MovieID==recom_result$MovieID[(i - 1) * num_movies + j])])
          )

      )
    })))
  }) # rows


  }) # renderUI function
  
  #adding
  # category <- c("Action", "Adventure", "Animation")
  # population <- c(3,8,4)
  # 
  # df2 <- data.frame(category,population)
  # 
  # df_subset <- reactive({
  #    a <- subset(df2, category == input$state)
  #  return(a)
  #})
  
  #output$table1 <- renderTable(df_subset()) #Note how df_subset() was used and not df_subset
  ##########################################################
  # This is the By genre portion for server.r
  # output name is genreresults
  # 
  ###########################################################
  output$genreresults <- renderUI({
    num_rows <- 2
    num_movies <- 5
    #genre_ratingdf=genre_ratingdf %>% filter(Action==1) %>% top_n(5, ave_ratings)
    genre_selected=input$state
    if(genre_selected=="Action")
      genre_ratingdf=genre_ratingdf %>% filter(Action==1) %>% top_n(5, ave_ratings)
    else if (genre_selected=="Adventure")
      genre_ratingdf=genre_ratingdf %>% filter(Adventure==1) %>% top_n(5, ave_ratings)
    else if (genre_selected=="Animation")
      genre_ratingdf=genre_ratingdf %>% filter(Animation==1) %>% top_n(5, ave_ratings)
    else if (genre_selected=="Children's")
      genre_ratingdf=genre_ratingdf %>% filter(Children.s==1) %>% top_n(5, ave_ratings)
    else if (genre_selected=="Comedy")
      genre_ratingdf=genre_ratingdf %>% filter(Comedy==1) %>% top_n(5, ave_ratings)
    else if (genre_selected=="Crime")
      genre_ratingdf=genre_ratingdf %>% filter(Crime==1) %>% top_n(5, ave_ratings)
    else if (genre_selected=="Documentary")
      genre_ratingdf=genre_ratingdf %>% filter(Documentary==1) %>% top_n(5, ave_ratings)
    else if (genre_selected=="Drama")
      genre_ratingdf=genre_ratingdf %>% filter(Drama==1) %>% top_n(5, ave_ratings)
    else if (genre_selected=="Fantasy")
      genre_ratingdf=genre_ratingdf %>% filter(Fantasy==1) %>% top_n(5, ave_ratings)
    else if (genre_selected=="Film-Noir")
      genre_ratingdf=genre_ratingdf %>% filter(Film.Noir==1) %>% top_n(5, ave_ratings)
    else if (genre_selected=="Horror")
      genre_ratingdf=genre_ratingdf %>% filter(Horror==1) %>% top_n(5, ave_ratings)
    else if (genre_selected=="Musical")
      genre_ratingdf=genre_ratingdf %>% filter(Musical==1) %>% top_n(5, ave_ratings)
    else if (genre_selected=="Mystery")
      genre_ratingdf=genre_ratingdf %>% filter(Mystery==1) %>% top_n(5, ave_ratings)
    else if (genre_selected=="Romance")
      genre_ratingdf=genre_ratingdf %>% filter(Romance==1) %>% top_n(5, ave_ratings)
    else if (genre_selected=="Sci-Fi")
      genre_ratingdf=genre_ratingdf %>% filter(Sci.Fi==1) %>% top_n(5, ave_ratings)
    else if (genre_selected=="Thriller")
      genre_ratingdf=genre_ratingdf %>% filter(Thriller==1) %>% top_n(5, ave_ratings)
    else if (genre_selected=="War")
      genre_ratingdf=genre_ratingdf %>% filter(War==1) %>% top_n(5, ave_ratings)
    else if (genre_selected=="Western")
      genre_ratingdf=genre_ratingdf %>% filter(Western==1) %>% top_n(5, ave_ratings)
    
    list(fluidRow(lapply(1:5, function(j) {
      box(width = 2, status = "success", solidHeader = TRUE, title = paste0("Rank ", j ),
          
          div(style = "text-align:center", 
              a(img(src = paste0(small_image_url, genre_ratingdf$MovieID[j], '.jpg?raw=true'), height = 150))
          ),
          div(style="text-align:center; font-size: 100%", 
              strong(genre_ratingdf$Title[j])
          )
          
      )        
    }))) 
    
    # lapply(1:num_rows, function(i) {
    #   list(fluidRow(lapply(1:num_movies, function(j) {
    #     box(width = 2, status = "success", solidHeader = TRUE, title = paste0("Rank ", (i - 1) * num_movies + j),
    #         
    #         div(style = "text-align:center", 
    #             a(img(src = paste0(small_image_url, genre_ratingdf$MovieID[i], '.jpg?raw=true'), height = 150))
    #         ),
    #         div(style="text-align:center; font-size: 100%", 
    #             strong(genre_ratingdf$Title[i])
    #         )
    #         
    #     )        
    #   }))) # columns
    # })
      #df1=genre_ratingdf %>% filter(Action==1))
    #recom_result <- genre_ratingdf
    
    # fluidRow({
    #   div(style = "text-align:center", 
    #                    a(img(src = paste0(small_image_url, 318, '.jpg?raw=true', height = 150)))
    #                )
    # })
    
    # lapply(1:num_rows, function(i) {
    #   list(fluidRow(lapply(1:num_movies, function(j) {
    #     box(width = 2, status = "success", solidHeader = TRUE, title = paste0("Rank ", (i - 1) * num_movies + j),
    #         
    #         div(style = "text-align:center", 
    #             a(img(src = movies$image_url[recom_result$MovieID[(i - 1) * num_movies + j]], height = 150))
    #         ),
    #         div(style="text-align:center; font-size: 100%", 
    #             strong(movies$Title[recom_result$MovieID[(i - 1) * num_movies + j]])
    #         )
    #         
    #     )        
    #   }))) # columns
    # }) # rows
    
  }) # renderUI function
  
}) # server function