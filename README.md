# gloves
 An R script to create a graph of the change in glove wearing among bat handlers on iNaturalist
 
 The script takes a CSV file containing a binary factor (gloves/hands), the URL of an iNaturlist observation and a year.
 
 The first part of the script works on the proportion of glove wearing in a year and uses a generized linear model to fint the results/.
 The second part of the script uses the iNaturalist API to extract the observation date and then uses a logistic model to fit and plot the data.
