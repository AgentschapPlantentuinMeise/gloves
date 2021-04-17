library(readr)
library(ggplot2)
library(ggthemes) 
handsglovesbats <- read_delim("handsglovesbats.tsv", "\t", escape_double = FALSE, col_types = cols(percentGloves = col_double(), year = col_integer()), trim_ws = TRUE)
View(handsglovesbats)

attach(handsglovesbats)
head(handsglovesbats)
plot(year,percentGloves)
model <- glm(percentGloves~year, binomial, weights=weights)
summary(model)

# Using the binomial model gives a warming, so I've used the quasibinomial
xv <- seq(2008,2021,1)
yv <- predict(model,list(year=xv),type="response")
plot(year,percentGloves)
lines(xv,yv,col="red")
model2 <- glm(percentGloves~year, family=quasibinomial , weights=weights)
summary(model2)

# This uses the inverse link function to create 95% confidence intervals for the model
# See https://fromthebottomoftheheap.net/2017/05/01/glm-prediction-intervals-i/

ilink <- family(model2)$linkinv
pd <- with(handsglovesbats, data.frame(year = seq(min(year), max(year), length = 13)))
pd <- cbind(pd, predict(model2, pd, type = "link", se.fit = TRUE)[1:2])
pd <- transform(pd, Fitted = ilink(fit), Upper = ilink(fit + (2 * se.fit)), Lower = ilink(fit - (2 * se.fit)))

ggplot(handsglovesbats, aes(x = year, y = as.numeric(percentGloves))) +
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

