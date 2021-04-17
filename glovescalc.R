library(readr)
library(ggplot2)
library(ggthemes)
library(dplyr)
library(reshape2)

############################################################################################
#The data were initially analyzed using the proportion of people wearing gloves in each year
############################################################################################

handsglovesbats <- read.csv("~/R/gloves/handsglovesbats.csv")

handsglovesbats2 <- dcast(handsglovesbats, year ~ gloveOrHand, value.var = "year")

handsglovesbatsAgg <- handsglovesbats2 %>% mutate(percent = glove/(glove+hand)) %>% mutate(weight = glove+hand)

# Get rid of years before 2008, because there is little data
handsglovesbatsAgg <- handsglovesbatsAgg[handsglovesbatsAgg$year > 2007, ]    

#handsglovesbats <- read_delim("handsglovesbats.tsv", "\t", escape_double = FALSE, col_types = cols(percentGloves = col_double(), year = col_integer()), trim_ws = TRUE)
#View(handsglovesbats)

attach(handsglovesbatsAgg)
head(handsglovesbatsAgg)
plot(year,percent)
model <- glm(percent~year, binomial, weights=weight)
summary(model)

# Using the binomial model gives a warming, so I've used the quasibinomial
xv <- seq(2008,2021,1)
yv <- predict(model,list(year=xv),type="response")
plot(year,percent)
lines(xv,yv,col="red")
model2 <- glm(percent~year, family=quasibinomial , weights=weight)
summary(model2)

# This uses the inverse link function to create 95% confidence intervals for the model
# See https://fromthebottomoftheheap.net/2017/05/01/glm-prediction-intervals-i/

ilink <- family(model2)$linkinv
pd <- with(handsglovesbatsAgg, data.frame(year = seq(min(year), max(year), length = 13)))
pd <- cbind(pd, predict(model2, pd, type = "link", se.fit = TRUE)[1:2])
pd <- transform(pd, Fitted = ilink(fit), Upper = ilink(fit + (2 * se.fit)), Lower = ilink(fit - (2 * se.fit)))

ggplot(handsglovesbatsAgg, aes(x = year, y = as.numeric(percent))) +
  geom_ribbon(data = pd, aes(ymin = Lower, ymax = Upper, x = year),
              fill = "steelblue", alpha = 0.3, inherit.aes = FALSE) + scale_x_continuous(breaks = seq(2008, 2021, by = 3)) +
  geom_line(data = pd, aes(y = Fitted, x = year), size = 1.5, linetype = 1, colour = "red") +
  geom_point(colour = "blue", size=2) + 
  labs(y = "Proportion of gloves used", x = "Year") + theme_stata(base_size = 24, base_family = "sans", scheme = "s2color")

getwd()

ggsave(
  "gloveusage.tiff",
  plot = last_plot(),
  device = "tiff",
  scale = 1,
  width = 242.7,
  height = 150,
  units = c("mm"),
  dpi = 300
)

ggsave(
  "gloveusage.jpg",
  plot = last_plot(),
  device = "jpg",
  scale = 1,
  width = 242.7,
  height = 150,
  units = c("mm"),
  dpi = 300
)

###############################################################################
# Can also be analyzed by logistic regression to show the probability
# that someone was using gloves in a year
###############################################################################

handsglovesbats <- read.csv("~/R/gloves/handsglovesbats.csv")

handsglovesbats$gloveOrHand <- as.factor(handsglovesbats$gloveOrHand )
handsglovesbats$gloveOrHand <- as.numeric(handsglovesbats$gloveOrHand)
handsglovesbats$gloveOrHand <- handsglovesbats$gloveOrHand -2
handsglovesbats$gloveOrHand <- handsglovesbats$gloveOrHand *-1

# Get rid of years before 2008, because there is little data
handsglovesbats <- handsglovesbats[handsglovesbats$year > 2007, ]   

#handsglovesbats$gloveOrHand <- ordered(handsglovesbats$gloveOrHand, levels = c("hand", "glove"))

#levels(handsglovesbats$gloveOrHand) <- c(0,1)

modelLG <- glm(gloveOrHand ~year,family=binomial(link='logit'),data=handsglovesbats)

summary(modelLG)

anova(modelLG, test="Chisq")

ggplot(handsglovesbats, aes(x=year, y=gloveOrHand)) + 
  geom_jitter(height = 0.03, width=0.3, shape=1, alpha = 0.4) +
  scale_x_continuous(breaks = seq(2008, 2021, by = 3)) +
  stat_smooth(formula = y ~ x, method="glm", method.args=list(family="binomial"), se=TRUE, fill = "steelblue", inherit.aes = TRUE, size = 1.5, linetype = 1, colour = "red") +
  labs(y = "Probability of gloves being used", x = "Year") + theme_stata(base_size = 20, base_family = "sans", scheme = "s2color")

ggsave(
  "gloveprobability.tiff",
  plot = last_plot(),
  device = "tiff",
  scale = 1,
  width = 242.7,
  height = 150,
  units = c("mm"),
  dpi = 300
)

ggsave(
  "gloveprobability.jpg",
  plot = last_plot(),
  device = "jpg",
  scale = 1,
  width = 242.7,
  height = 150,
  units = c("mm"),
  dpi = 300
)
