## ----label=opts, results='hide', echo=FALSE, message = FALSE, warning=FALSE----
library(knitr)
opts_chunk$set(echo=TRUE, prompt=FALSE, message=FALSE, warning=FALSE, comment="", results='hide')

## ----plot----------------------------------------------------------------
library(ggplot2)
ggplot(data = quakes, aes(x = lat,y = long,colour = stations)) + geom_point()

## ----save_plot-----------------------------------------------------------
g = ggplot(data = quakes, 
           aes(x = lat,y = long,colour = stations)) + 
  geom_point()

## ----bigger_axis---------------------------------------------------------
g + theme(text = element_text(size = 20))

## ----bigger_axis2--------------------------------------------------------
gbig = g + theme(axis.text = element_text(size = 18),
                 axis.title = element_text(size = 20),
                 legend.text = element_text(size = 15),
                 legend.title = element_text(size = 15))
gbig

## ----lab_full------------------------------------------------------------
gbig = gbig + xlab("Latitude") + ylab("Longitude")
gbig

## ----title---------------------------------------------------------------
gbig + ggtitle("Spatial Distribution of Stations")

## ----big_title-----------------------------------------------------------
gbig +
  ggtitle("Spatial Distribution of Stations") + 
  theme(title = element_text(size = 30))

## ----leg-----------------------------------------------------------------
gbigleg_orig = gbig + guides(colour = guide_colorbar(title = "Number of Stations Reporting"))
gbigleg_orig

## ----leg2----------------------------------------------------------------
gbigleg = gbig + guides(colour = guide_colorbar(title = "Number\nof\nStations\nReporting"))
gbigleg

## ----leg_adjust----------------------------------------------------------
gbigleg = gbigleg + 
  guides(colour = guide_colorbar(title = "Number\nof\nStations\nReporting",
                                 title.hjust = 0.5))
gbigleg

## ----leg_inside----------------------------------------------------------
gbigleg + 
  theme(legend.position = c(0.3, 0.35))

## ----change_ylim---------------------------------------------------------
gbigleg +
  theme(legend.position = c(0.3, 0.35)) +
  ylim(c(160, max(quakes$long)))

## ----trans_leg-----------------------------------------------------------
transparent_legend =  theme(
  legend.background = element_rect(fill = "transparent"),
  legend.key = element_rect(fill = "transparent", 
                            color = "transparent")
)

## ----leg_inside2---------------------------------------------------------
gtrans_leg = gbigleg + 
  theme(legend.position = c(0.3, 0.35)) +
  transparent_legend
gtrans_leg

## ----leg_left------------------------------------------------------------
gtrans_leg + guides(colour = guide_colorbar(title.position = "left"))

## ----leg_left_correct----------------------------------------------------
gtrans_leg + guides(
  colour = guide_colorbar(title = "Number\nof\nStations\nReporting",
                          title.hjust = 0.5,
                          title.position = "left"))

## ----respec--------------------------------------------------------------
gtrans_leg$guides$colour$title.position = "left"
gtrans_leg

## ----themes--------------------------------------------------------------
g + theme_bw()
g + theme_dark()
g + theme_minimal()
g + theme_classic()

## ------------------------------------------------------------------------
g = ggplot(aes(y = am), data = mtcars) + 
  geom_point(position = position_jitter(height = 0.2)) + 
  geom_smooth(method = "glm", 
              method.args = list(family = "binomial"), se = FALSE) +
  geom_smooth(method = "loess", se = FALSE, col = "red")

## ------------------------------------------------------------------------
g + aes(x = mpg)
g + aes(x = drat)
g + aes(x = qsec)

