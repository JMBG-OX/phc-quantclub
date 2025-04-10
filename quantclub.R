#Before we can do anything, we need to install the relevant packages.
install.packages("rnaturalearth")
install.packages("rnaturalearthdata")
install.packages("giscoR")
#The package containing the hi-res files for rnaturalearth is too large to be stored on CRAN
#Therefore, it must be installed from GitHub instead
install.packages("remotes")
remotes::install_github("ropensci/rnaturalearthhires")

library(rnaturalearth)
library(rnaturalearthdata)
library(rnaturalearthhires)
library(giscoR)

#Use this command to see possible palettes for your maps.
hcl.pals()

#Let's say we want to make a map of US states by murder rate in 1973.
#Thankfully, R has that exact data as a built-in file called USArrests.
data(USArrests)
#Now, use rnaturalearth to import a state-level map of the USA.
#Note that the relevant shape files are a part of the package.
#(in other words, you don't need to import them manually!)
usstates <- ne_states(country="united states of america") |> sort_by(~name)
#(you have to use the exact name of the country as it appears in the database)
#The data is sorted by name to put it in the same order as USArrests.
#This makes joining the two easier.
usstates <- cbind(usstates, USArrests$Murder)
#Oops! The sizes of the two data frames don't match.
#Inspecting the data reveals the problem: USArrests doesn't include Washington DC.
#We will need to drop that row when trying it again:
usstates <- cbind(usstates[-9,], USArrests$Murder)
#Now we can get a preview of the map before finalising it:
plot(usstates[,"USArrests.Murder"])
#The map shows Alaska and Hawaii to scale, which means it has a lot of empty space.
#We can drop those rows from the table to make it look better.
#Finally, add a title and a nice colour scheme:
plot(usstates[-c(2,11),"USArrests.Murder"],
     pal=hcl.colors(9,palette="Earth"),
     main="Murder rate per 100,000 by US state in 1973")

#In order to show off giscoR, we can make another map using built-in data.
#This time, it'll be conversion rates of 11 pre-Euro currencies to the Euro.
data(euro)
#giscoR is more lenient with names than rnaturalearth, but you still can't mix formats when importing.
#We will import the 11 relevant countries using their Eurostat codes to save space.
eucountries <- gisco_get_countries(country=c("AT","BE","DE","ES","FI","FR","IE","IT","LU","NL","PT"))
eucountries$conv_rate <- euro
#Preview the map again:
plot(eucountries[,"conv_rate"])
#Two immediate issues: the map needs to be zoomed in a bit, and the scale is hard to read.
#We should try it again with a log scale:
eucountries$log_conv_rate <- log10(euro)
plot(eucountries[,"log_conv_rate"],
     main="Conversion rates of pre-Euro currencies to the Euro (logarithmic scale)",
     pal=hcl.colors(10,palette="Oslo"),
     xlim=c(-15,35),
     ylim=c(35,75))
#All done!