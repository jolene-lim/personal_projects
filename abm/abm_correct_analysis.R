library(dplyr)
library(ggplot2)

#dist
abm <- read.csv("~/Agent based modelling/abm_dist.csv", header=FALSE)
abm_t <- as.data.frame(t(abm))[2:101, ]
colnames(abm_t) <- c("Run", "Capacity", "num_parents", "dist_buffer", "num_schools", "result", "value", "min", "max", "mean", "steps")
abm_t[ , c(1:5, 7:11)] <- abm_t[ , c(1:5, 7:11)] %>%
  sapply(as.character) %>%
  sapply(as.numeric)
abm_t[ , 6] <- abm_t[ , 6 ] %>%
  sapply(as.character) %>%
  sapply(as.factor)

mean_dist_summary <- abm_t %>%
  group_by(dist_buffer) %>%
  summarise(mean_run_dist = mean(value))

buffer_vs_mean_dist <- ggplot(mean_dist_summary, aes(x= dist_buffer, y = mean_run_dist, colour = "#E69F00")) +
  geom_point() +
  geom_smooth(se = FALSE, span = 0.4) +
  labs(x = "Distance Threshold", y = "Mean Distance from School", title ="Impact of Distance Buffer Length on Mean Distance from School") +
  theme_bw()
buffer_vs_mean_dist

#satisfaction
sat <- read.csv("~/Agent based modelling/abm_sat2.csv", header=FALSE)
sat <- as.data.frame(t(sat))[2:101, ]
colnames(sat) <- c("Run", "Capacity", "num_parents", "dist_buffer", "num_schools", "result", "value", "min", "max", "mean", "steps")
sat[ , c(1:5, 7:11)] <- sat[ , c(1:5, 7:11)] %>%
  sapply(as.character) %>%
  sapply(as.numeric)
sat[ , 6] <- sat[ , 6 ] %>%
  sapply(as.character) %>%
  sapply(as.factor)

sat_summary <- sat %>%
  group_by(dist_buffer) %>%
  summarise(mean_sat = mean(value))

buffer_vs_sat <- ggplot(sat_summary, aes(x= dist_buffer, y = mean_sat, colour = "#009E73")) +
  geom_point() +
  geom_smooth(se = FALSE, span = 0.4, method ="lm") +
  labs(x = "Distance Threshold", y = "Proportion of Parents enrolled in First Choice", title ="Impact of Distance Buffer Length on Parent Satisfaction") +
  theme_bw()
buffer_vs_sat

