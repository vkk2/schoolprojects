# Movie Recommender System

Link to Rshiny App: https://vkk2.shinyapps.io/recommendsys/

## Description

The MovieLens 1M Dataset from https://grouplens.org/datasets/movielens/ was used to build a movie recommender application using RShiny (an R package to build interactive web apps). The web app will recommend the top-5 movies based on the users input. There are two ways of recommending the movies:

System 1(By Genre): Recommendation based on genres. It takes the users favorite genre as input and recommend top5 movies based on the selected genre.

System 2(By Rating): Collaborative Filtering techign with Singular Value Decomposition was used. It asks for user to rate (1-5 stars) as many movies as possible before recommending the top10 movies based on the ratings provided.
