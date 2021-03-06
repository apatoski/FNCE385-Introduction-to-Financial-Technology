#### STAT 705  Spring 2019 Final Project
#### NAME: Andrej Patoski

#### Graded out of 100. 15 points for style and elegance.

#### Deliverables: There are 3 deliverables for this final project.
#### 1. The usual text file with R code and output that accompanies Q1 and Q2.
#### 2. A .RMD file for generating the report in Q3.
#### 3. The PDF or HTML file of the report that you make for Q3.


#### If in a question I refer to a function that we have not seen in class, 
#### then use the help facility to find out about it.
#### Insert your answers under each question.
#### Submit your R code solutions to Canvas as a plain text file.
#### If a question asks for a printed result, don't just write a "print" statement; 
#### include the output itself!

#### You may use any of the code published in the solutions to Assignment 5. 


# Hungerville has undergone rapid development from a 24 block square to 36 blocks.
# The goal of these questions is to estimate the number of cyclists (level of effort) that need to be available in order 
# to meet a pre-specified level of service in terms of how long an order would have 
# to wait at a restaurant before being picked up. We will assume that there are at least as many 
# cyclists as orders waiting to be picked up.
# A larger restaurant list is available in the assignments folder on Canvas.
# It is called restaurants.updated.Rdata and contains 40 restaurants.
# The pre-specified level of service is that the average wait time for an order to be picked up is no longer than 4 minutes.


# As a reminder, here is the preamble about the town:

# The town of Hungerville has come onto the radar of a company that offers meal delivery from restaurants. 
# It uses cyclists for these deliveries.
# Hungerville is an interesting town because it is laid out in a perfect city grid and has exactly 
# 36 blocks in both the north and east directions. Roads going north-south are called Avenues,
# and roads east-west are called streets.
# Meal pickups and deliveries can be viewed as only happening at street intersections.
# This means that every cyclist's, restaurant's and customer's location can be represented as a pair (i,j),
# i for the street they are on, and j for the avenue, where both i and j take integer values between 1 and 36.
# The city planners used the convention that the intersection at the south west corner of the grid is (1,1)
# and the intersection in the north east corner is (36,36).



#Q1. (41pts.) Write a function called "run.sim", that runs a simulation, where the function takes the following four arguments
#    (no default values required, but you can add them if you want). 
#    
#    1. num.cyclists --- the number of cyclists initially available.
#    2. num.orders --- the number of orders initially waiting for pick-up.
#    3. grid.size --- the size of the Hungerville city grid (default to 36).
#    4. num.its --- the number of iterations in the Monte Carlo simulation.

# The function should return a one column matrix, with the number of rows equal to num.its. 
# The elements in this matrix should be the average time that orders wait to be picked up (where the average
# is taken over all orders (not cyclists) within an iteration).

# Because grid.size is now a variable you will want to add an extra argument to your "newcyclist" and "neworder" 
# functions from Assignment 5, to reflect this fact. Grid size can default to 36.
# Make sure you are randomly drawing a restaurant from the new list of 40, not the original list of 20. 


newcyclist1 <- function(bid = paste(sample(c(LETTERS,0:9),10),sep="",collapse=""),
                       grid.size = 36, 
                       status = "Waiting",
                       destination = NULL, oid = NULL, speed = 1, ...){
  
  new.cyclist <- list(BID = bid , Location = c(sample(1:grid.size, 1), sample(1:grid.size, 1)) ,
                      Status = status, Destination = destination, OID = oid , Speed = speed)
  return (new.cyclist)
}

neworder1 <- function(OID = paste(sample(c(LETTERS,0:9),10),sep="",collapse="" ), WaitTime = 0,
                      Restaurant = restaurant.list[[sample(1:40,1)]], grid.size = 36)
  {
  return(list(OID = OID, WaitTime = WaitTime, Restaurant = Restaurant, Destination = sample(1:grid.size,2,replace=TRUE)))
}


# The problem you will face in this question is that in Assignment 5, the number of cyclists equaled the number of orders,
# whereas now that is not necessarily true. If the number of orders equals the number of cyclists then the
# distance matrix is square (the same number of rows as columns).
# The optimization function, "lp.assign" in fact requires a square matrix as input and will fail to converge otherwise.

# The trick here, when the number of cyclists does not equal the number of orders, is to pad the distance matrix
# with *zeroes* (not NAs), so that it becomes square. If we have cyclists as rows and orders as columns in the distance matrix,
# and there were 20 cyclists and 10 orders, then you would need to add 10 columns of 20 rows each to make the distance
# matrix square. Because these extra columns (phantom orders) are constructed with all zero entries they don't change
# the solution to the optimization problem. 
# Equivalently, you could create a distance matrix as square and full of zeroes, and then just compute the elements
# that correspond to actual orders. 

# Bottom line: you have to add in an extra step as compared to Assignment 5, where you ensure that the 
# distance matrix is square if necessary, before calling "lp.assign".


#a. Check all the arguments to make sure that they are non-negative numerics. The functions "stopifnot" and "is.numeric"
# will help you do this.

#b. The other thing to check, and stop if it is not true,
# is that the number of cyclists is greater than or equal to the number of orders.

#c. Paste the code for your run.sim function. It will implicitly include your answers to parts a and b.

run.sim <- function(num.cyclists, num.order, grid.size = 36, num.iter, ...)
  {
  stopifnot(is.numeric(num.cyclists) && num.cyclists > 0 && is.numeric(num.order) && num.order > 0 &&
              is.numeric(grid.size) && grid.size > 0 &&is.numeric(num.iter) && num.iter > 0)
  stopifnot(num.cyclists >= num.order)
  ave.wait <- rep(NA, num.iter)
  
  for (k in 1:num.iter){
  cyclist.list <- replicate(num.cyclists, newcyclist1(), simplify = FALSE)
  order.list <- replicate(num.order, neworder1(), simplify = FALSE)
  
  dist.matf <- matrix(0, nrow = num.cyclists, ncol = num.cyclists)
  for(i in 1:num.cyclists){
    for(j in 1:num.order){
      dist.matf[i,j] <- distance(cyclist.list[[i]]$Location, order.list[[j]]$Restaurant$Location)
    }
  }
  fm <- lp.assign(dist.matf)
  ave.wait[k] <- sum(dist.matf*fm$solution)/num.order
  }
  resul <- mean(ave.wait)
  return(resul)
  
}


# Run the function with these arguments and report the estimated mean waiting time for each:

#d. run.sim(num.cyclists = 20, num.orders = 20, grid.size = 36, num.its = 100)

run.sim(num.cyclists = 20, num.order = 20, grid.size = 36, num.iter = 100)

#e. run.sim(num.cyclists = 40, num.orders = 20, grid.size = 36, num.its = 100)

run.sim(num.cyclists = 40, num.order = 20, grid.size = 36, num.iter = 100)

#f. run.sim(num.cyclists = 60, num.orders = 20, grid.size = 36, num.its = 100)

run.sim(num.cyclists = 60, num.order = 20, grid.size = 36, num.iter = 100)

#g. run.sim(num.cyclists = 10, num.orders = 20, grid.size = 36, num.its = 100)

run.sim(num.cyclists = 10, num.order = 20, grid.size = 36, num.iter = 100)

#h. run.sim(num.cyclists = 20, num.orders = 20, grid.size = 36, num.its = TRUE)


# Results for running the simulations
#run.sim(num.cyclists = 20, num.order = 20, grid.size = 36, num.iter = TRUE)

#> run.sim(num.cyclists = 20, num.order = 20, grid.size = 36, num.iter = 100)
#[1] 10.481
#> run.sim(num.cyclists = 40, num.order = 20, grid.size = 36, num.iter = 100)
#[1] 4.9625
#> run.sim(num.cyclists = 60, num.order = 20, grid.size = 36, num.iter = 100)
#[1] 3.6455
#> run.sim(num.cyclists = 10, num.orders = 20, grid.size = 36, num.iter = 100)
#Error in stopifnot(is.numeric(num.cyclists) && num.cyclists > 0 && is.numeric(num.order) &&  : 
 #                    argument "num.order" is missing, with no default
  #                 > run.sim(num.cyclists = 10, num.order = 20, grid.size = 36, num.iter = 100)
   #                Show Traceback
    #               
     #              Rerun with Debug
      #             Error: num.cyclists >= num.order is not TRUE 
       #            > run.sim(num.cyclists = 20, num.order = 20, grid.size = 36, num.iter = TRUE)
        #           Show Traceback
         #          
          #         Rerun with Debug
           #        Error: is.numeric(num.cyclists) && num.cyclists > 0 && is.numeric(num.order) &&  .... is not TRUE 
                   


#Q2 (16 pts.) We now assume that there are 30 orders waiting, the grid size is 36 and num.its = 1000. 
#   In this question you will explore the average order wait time as the 
#   number of cyclists varies between 30 and 80 in increments of 5.
#   As you *develop* your code it will be a good idea to work with a num.its much smaller than 1000,
#   but the final results should use 1000. It took 13 minutes to run the complete simulation
#   on my laptop.  

#a. Create an empty container to hold the results of all the simulations.   
#   This should be a matrix of dimensions num.its by 11.
#   Provide columns names for this matrix that describe the level of effort associated with each column.
#   Show the code you used to create this matrix. 

col.namess <- seq(30,80, by = 5)
container.mat <- matrix(0, nrow = 1000, ncol = 11)
colnames(container.mat) <- col.namess

#b. Set the random number seed to your birthday seed and show the code.

set.seed(12121997)


#c. Use a "for" loop to execute the run.sim command as the number of cyclists varies.
#   Each pass through the loop should populate one column of the results container.
#   Show the code that implements the for loop. 


run.sim1 <- function(num.cyclists, num.order, grid.size = 36, num.iter, ...)
{
  stopifnot(is.numeric(num.cyclists) && num.cyclists > 0 && is.numeric(num.order) && num.order > 0 &&
              is.numeric(grid.size) && grid.size > 0 &&is.numeric(num.iter) && num.iter > 0)
  stopifnot(num.cyclists >= num.order)
  ave.wait <- rep(NA, num.iter)
  
  for (k in 1:num.iter){
    cyclist.list <- replicate(num.cyclists, newcyclist1(), simplify = FALSE)
    order.list <- replicate(num.order, neworder1(), simplify = FALSE)
    
    dist.matf <- matrix(0, nrow = num.cyclists, ncol = num.cyclists)
    for(i in 1:num.cyclists){
      for(j in 1:num.order){
        dist.matf[i,j] <- distance(cyclist.list[[i]]$Location, order.list[[j]]$Restaurant$Location)
      }
    }
    fm <- lp.assign(dist.matf)
    ave.wait[k] <- sum(dist.matf*fm$solution)/num.order
  }
  
  return(ave.wait)
  
}


for (i in 1:11) {
  container.mat[,i] <-  run.sim1(num.cyclists = 30 + 5*(i-1), num.order = 30, num.iter = 1000)
  
}

#d. Estimate the mean wait time for each level of effort (number of cyclists)
#   and print them below. 

for (i in 1:11) {
  print (mean(container.mat[,i]))
}

[1] 9.0796
[1] 7.201133
[1] 6.1518
[1] 5.474833
[1] 4.885833
[1] 4.543167
[1] 4.231
[1] 3.974067
[1] 3.770633
[1] 3.613467
[1] 3.423267

#e. Use the "write.csv" command to save the results container to disk and paste the command 
#   you used to do it below. Using the argument "row.names = FALSE" to write.csv, can save 
#   a little bit of pain later.  

write.csv(container.mat, file= "results.csv", row.names = FALSE)


#Q3. (28 pts.) Using RMarkdown, create a markdown document that summarizes your simulation and render the 
#   document as either an HTML or PDF slide presentation. Your markdown document will read in the results file that you saved
#   in Q2e to answer this question. 

#a. The document should contain the following elements:
#   A title slide with a project title and your name.

#b. A slide that presents the date on which the document was rendered (not just created),
#   the name of the simulation results file and the number of iterations in the simulation 
#   (calculated after having read in the file that you saved in Q2e, not hardcoded).

#c. A plot that shows the level of effort (on the x-axis) against estimated average wait time on the y-axis.
#   It should also have a horizontal line added at height y = 4, so that an optimal level of effort can 
#   be visualized. Axes should be labeled appropriately (use arguments xlab and ylab). The commands "plot" and "abline"
#   are enough to make the plot. Make the y-axis go between 0 and 15 by using the argument to plot, "ylim=c(0,15)".
#   Add a text comment to this slide that states what the least number of cyclists is, to meet the effort goal.
#   You can just eyeball this answer from the plot. 


#d. A plot that shows the level of effort (on the x-axis) against the 80% percentile of the distribution of the
#   mean wait time. That is, apply the "quantile" command to the columns of your results matrix and plot the
#   result. Axes should be labeled appropriately.  It should also have a horizontal line added at height y = 4. 
#   Add a text comment to this slide that states what the least number of cyclists is to meet the effort goal, when
#   expressed in terms of the 80-th percentile of the distribution of the mean.
#   You can just eyeball this answer from the plot. 












