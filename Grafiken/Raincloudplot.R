# Pakete laden
library(dplyr)
library(ggplot2)
library(ggdist)      # für density / Halfeye Plots
library(gghalves)    # für Halbviolinplots (Raincloud)
library(tidyr)

# Daten vorbereiten
plot_data <- df %>%
  filter(
    !is.na(T1_SPQ_Sum),
    !is.na(T4_SPQ_Sum),
    ENT_Gruppe %in% c("rTMS-React", "Placebo-React")
  ) %>%
  mutate(
    T1_SPQ_Sum = as.numeric(T1_SPQ_Sum),
    T4_SPQ_Sum = as.numeric(T4_SPQ_Sum),
    ENT_Gruppe = factor(ENT_Gruppe, levels = c("rTMS-React", "Placebo-React"))
  ) %>%
  pivot_longer(
    cols = c(T1_SPQ_Sum, T4_SPQ_Sum),
    names_to = "Zeitpunkt",
    values_to = "SPQ_Sum"
  ) %>%
  mutate(
    Zeitpunkt = factor(Zeitpunkt, levels = c("T1_SPQ_Sum", "T4_SPQ_Sum"), labels = c("T1", "T4"))
  )

# Raincloud Plot erstellen
ggplot(plot_data, aes(x = Zeitpunkt, y = SPQ_Sum, fill = ENT_Gruppe)) +
  gghalves::geom_half_violin(
    aes(color = ENT_Gruppe),
    side = "l",
    position = position_dodge(width = 0.6),
    alpha = 0.5,
    trim = FALSE
  ) +
  geom_boxplot(
    aes(color = ENT_Gruppe),
    width = 0.1,
    position = position_dodge(width = 0.6),
    outlier.shape = NA,
    alpha = 0.6
  ) +
  geom_jitter(
    aes(color = ENT_Gruppe),
    position = position_jitterdodge(jitter.width = 0.1, dodge.width = 0.6),
    size = 1.2,
    alpha = 0.4,
    show.legend = FALSE
  ) +
  labs(
    title = "Raincloud Plot der SPQ Sum Scores nach Zeitpunkt und Gruppe",
    x = "Zeitpunkt",
    y = "SPQ Sum Score",
    fill = "Gruppe",
    color = "Gruppe"
  ) +
  theme_minimal()
