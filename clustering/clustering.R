library(tidyverse)
library(cluster)
library(ggplot2)
library(RColorBrewer)

#tidying
industry <- read.csv("~/Personal_projects/cluster_econ_gdpp_indus.csv", header=TRUE)
manu <- read.csv("~/Personal_projects/cluster_econ_gbpp_manu.csv", header=TRUE)
service <- read.csv("~/Personal_projects/cluster_econ_gdpp_service.csv", header=TRUE)
agri <- read.csv("~/Personal_projects/cluster_econ_gdpp_agri.csv", header=TRUE)

in_2017 <- industry[, c(2, 60)]
manu_2017 <- manu[, c(2, 60)]
service_2017 <- service[, c(2, 60)]
agri_2017 <- agri[, c(2, 60)]

analysis <- list(in_2017, manu_2017, service_2017, agri_2017) %>%
  reduce(left_join, by = "Code")
colnames(analysis) <- c("Code", "Industry", "Manufacturing", "Service", "Agriculture")

com_analysis <- analysis[complete.cases(analysis), ]

#missing data

#hierarchical clustering
dist_analy <- dist(com_analysis, method = "euclidean")
hc_analy <- hclust(dist_analy)
plot(as.dendrogram(hc_analy))
cut_analy <- cutree(hc_analy, k = 3)
hclust_analysis <- mutate(com_analysis, hcluster = cut_analy)

hclust_summary <- hclust_analysis %>%
  group_by(hcluster) %>%
  summarise(mean_indus = mean(Industry), 
            mean_manu = mean(Manufacturing),
            mean_serv = mean(Service),
            mean_agri = mean(Agriculture))

hclust_summary <- gather(hclust_summary, key = "Sector", value = "value", mean_indus, mean_manu, mean_serv, mean_agri)

ggplot(hclust_summary, aes(x = hcluster, y = value, fill = Sector)) +
  geom_bar(stat = "identity", position = "fill")+
  labs(title = "Mean Value Added (% of GDP) by Sector 2017, Hierarchical Clustering",
       x = "Cluster", y = "Relative Value Add of Sector Within Cluster") +
  scale_fill_brewer(palette = "Set2", labels = c("Agriculture", "Industry", "Manufacturing", "Service")) + 
  theme_bw()

#ggplot(hclust_analysis, aes(x = Agriculture, y = Manufacturing, color = as.factor(hcluster))) +
#  geom_point() +
#  scale_fill_brewer(palette = "Set2") +
#  theme_bw()

#k-means
ktemp <- com_analysis[, 2:5]

#elbow plot
tot.withinss <- map_dbl(1:10,  function(k){
  model <- kmeans(x = ktemp, centers = k)
  model$tot.withinss})

analy_elbow <- data.frame(
  k = 1:10,
  clus_size = tot.withinss)

ggplot(analy_elbow, aes(x = k, y = clus_size)) +
  geom_line() +
  labs(title = "Elbow Plot", x = "No. of Clusters", y = "Cluster Size") +
  scale_x_continuous(breaks = 1:10) +
  theme_bw()

# sihoulette plot
sil_width <- map_dbl(2:10,  function(k){
  model <- pam(x = ktemp, k = k)
  model$silinfo$avg.width})

sil_df <- data.frame(
  k = 2:10,
  sil_width = sil_width)

ggplot(sil_df, aes(x = k, y = sil_width)) +
  geom_line() +
  scale_x_continuous(breaks = 2:10)+
  labs(title = "Sihoulette Plot", x = "No. of Clusters", y = "Silhouette Width") +
  theme_bw()

# final
model_analy <- kmeans(ktemp, centers = 3)
analysis_clus <- mutate(com_analysis, cluster = model_analy$cluster)

kmeans_summary <- analysis_clus %>%
  group_by(cluster) %>%
  summarise(mean_indus = mean(Industry), 
            mean_manu = mean(Manufacturing),
            mean_serv = mean(Service),
            mean_agri = mean(Agriculture))

kmeans_summary <- gather(kmeans_summary, key = "Sector", value = "value", mean_indus, mean_manu, mean_serv, mean_agri)

ggplot(kmeans_summary, aes(x = cluster, y = value, fill = Sector)) +
  geom_bar(stat = "identity", position = "fill")+
  labs(title = "Mean Value Added by Sector 2017 (% of GDP), K-Means Clustering",
       x = "Cluster", y = "Relative Value Add of Sector Within Cluster") +
  scale_fill_brewer(palette = "Set2", labels = c("Agriculture", "Industry", "Manufacturing", "Service")) + 
  theme_bw()

#ggplot(analysis_clus, aes(x = Agriculture, y = Manufacturing, color = as.character(cluster))) +
#  geom_point() +
#  scale_colour_brewer(palette = "Spectral") + 
#  geom_text(data = analysis_clus[sample(nrow(analysis_clus), 10), ], aes(label = Code)) +
#  theme_bw()

#export
write.csv(analysis, file = "~/Personal_projects/cluster_econ_2017_analysis.csv")