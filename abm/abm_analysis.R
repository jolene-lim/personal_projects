library(dplyr)
library(ggplot2)

#cleaning data
abm <- read.csv("~/Agent based modelling/abm_project experiment-spreadsheet.csv", header=FALSE)
abm_t <- as.data.frame(t(abm))[2:811, ]
colnames(abm_t) <- c("Run", "Capacity", "mean_dislike", "num_parents", "dist_buffer", "sd_dislike", "num_schools", "result", "value", "min", "max", "mean", "steps")
abm_t[ , c(1:7, 9:13)] <- abm_t[ , c(1:7, 9:13)] %>%
  sapply(as.character) %>%
  sapply(as.numeric)
abm_t[ , 8] <- abm_t[ , 8 ] %>%
  sapply(as.character) %>%
  sapply(as.factor)

mean_dist <- abm_t[abm_t$result == "mean_dist", ]
prop_child <- abm_t[abm_t$result == "prop_child_in_buffer", c(1, 8:13)]
run_cond <- abm_t[abm_t$result == "mean_dist", c(1:7)]
prop_child <- left_join(prop_child, run_cond, by = "Run")
rm(run_cond)

#analysis
mean_dist_summary <- mean_dist %>%
  group_by(dist_buffer, mean_dislike) %>%
  summarise(mean_run_dist = mean(value))

prop_child_summary <- prop_child %>%
  group_by(dist_buffer, mean_dislike) %>%
  summarise(mean_run_dist = mean(value))

#satisfaction
abm_sat <- read.csv("~/Agent based modelling/abm_satisfaction.csv", header=FALSE)
abm_sat <- as.data.frame(t(abm_sat))[2:406, ]
colnames(abm_sat) <- c("Run", "Capacity", "mean_dislike", "num_parents", "dist_buffer", "sd_dislike", "num_schools", "result", "value", "min", "max", "mean", "steps")
abm_sat[ , c(1:7, 9:13)] <- abm_sat[ , c(1:7, 9:13)] %>%
  sapply(as.character) %>%
  sapply(as.numeric)
abm_sat[ , 8] <- abm_sat[ , 8 ] %>%
  sapply(as.character) %>%
  sapply(as.factor)

sat_summary <- abm_sat %>%
  group_by(dist_buffer, mean_dislike) %>%
  summarise(mean_sat = mean(value))

#viz
buffer_vs_mean_dist <- ggplot(mean_dist_summary, aes(x= dist_buffer, y = mean_run_dist, group = mean_dislike, color = mean_dislike)) +
  geom_point() +
  geom_smooth(se = FALSE, span = 0.5) +
  scale_color_gradientn(colors = c("#00AFBB", "#E7B800", "#FC4E07")) +
  labs(x = "Distance Threshold", y = "Mean Distance from School", color = "Mean Unconcerned Factor", title ="Impact of Distance Buffer Length on Mean Distance from School") +
  theme_bw()
buffer_vs_mean_dist

mean_dislike_vs_mean_dist <- ggplot(mean_dist_summary, aes(x= mean_dislike, y = mean_run_dist, group = dist_buffer, color = dist_buffer)) +
  geom_point() +
  geom_smooth(se = FALSE, span = 0.5) +
  scale_color_gradientn(colors = c("#00AFBB", "#E7B800", "#FC4E07")) +
  labs(x = "Mean Unconcerned Factor", y = "Mean Distance from School", color = "Distance Threshold", title = "Impact of Parent Concern on Mean Distance from School") +
  theme_bw()
mean_dislike_vs_mean_dist

buffer_vs_sat <- ggplot(sat_summary, aes(x= dist_buffer, y = mean_sat, group = mean_dislike, color = mean_dislike)) +
  geom_point() +
  geom_smooth(se = FALSE, span = 0.5, method = "lm") +
  scale_color_gradientn(colors = c("#00AFBB", "#E7B800", "#FC4E07")) +
  labs(x = "Distance Threshold", y = "Proportion of Parents in First-Choice School", color = "Mean Unconcerned Factor", title = "Impact of Distance Threshold Length on Proportion of Satisfied Parents") +
  theme_bw()
buffer_vs_sat

mean_dis_vs_sat <- ggplot(sat_summary, aes(x= mean_dislike, y = mean_sat, group = dist_buffer, color = dist_buffer)) +
  geom_point() +
  geom_smooth(se = FALSE, span = 0.5) +
  scale_color_gradientn(colors = c("#00AFBB", "#E7B800", "#FC4E07")) +
  labs(x = "Mean Unconcerned Factor", y = "Proportion of Parents in First-Choice School", color = "Distance Threshold", title = "Impact of Parent Concern on Proportion of Satisfied Parents") +
  theme_bw()
mean_dis_vs_sat