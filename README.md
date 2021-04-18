# Are people starting to use gloves to handle bats?
 An R script to create a graph of the change in glove wearing among bat handlers on iNaturalist
 
 The script takes a CSV file containing a binary factor (gloves/hands), the URL of an iNaturlist observation and a year.
 
 The first part of the script works on the proportion of glove wearing in a year and uses a generized linear model to fit the results.
 
 ![Proportion of people using gloves to handle bats in a year](/gloveusage.jpg)
 
 The second part of the script uses the iNaturalist API to extract the observation date and then uses a logistic model to fit and plot the data.
 
 ![Probability that the person will be using gloves to handle a bat](/gloveprobability.jpg)
 
 ![A map of those observations with coordinates](/glovemap.jpg)

