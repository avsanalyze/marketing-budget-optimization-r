# ==============================================================================
# PROJEKT: AUDYT EFEKTYWNOŚCI KAMPANII MARKETINGOWYCH (ROI, ROAS & CAC)
# Narzędzia: R (tidyverse: dplyr, ggplot2)
# Opis: Ocena rentowności kanałów reklamowych i optymalizacja alokacji budżetu
# ==============================================================================

library(dplyr)
library(ggplot2)

# PRZYGOTOWANIE DANYCH WEJŚCIOWYCH -------------------------------------------
kampanie <- data.frame(
  ID_Kampanii = paste0("KAMP_", 1:12),
  Kanal = rep(c("Google Ads", "Meta Ads", "TikTok", "Email"), times = 3),
  Koszt = c(5000, 4200, 3500, 800, 6100, 3900, 4800, 950, 5500, 4500, 3200, 700),
  Klikniecia = c(2500, 3100, 4200, 900, 2900, 2800, 5100, 1100, 2700, 3300, 3900, 850),
  Zamowienia = c(120, 85, 40, 65, 145, 70, 35, 80, 130, 90, 28, 55),
  Przychod = c(18000, 11000, 3100, 7800, 22500, 8400, 2900, 9600, 19500, 11700, 2100, 6600)
)

#KLASYFIKACJA DECYZYJNA ----------------------------------
kampanie_analiza <- kampanie |>
  mutate(
    CAC  = round(Koszt / Zamowienia, 2),
    ROAS = round(Przychod / Koszt, 2),
    zysk = Przychod - Koszt,
    decyzja = case_when(
      ROAS >= 3.0 ~ "Skalować",
      ROAS >= 1.0 ~ "Optymalizować",
      TRUE        ~ "Wyłączyć"
    )
  )

#AGREGACJA I RANKING KANAŁÓW REKLAMOWYCH -----------------------------------
ranking_kanalow <- kampanie_analiza |>
  group_by(Kanal) |>
  summarise(
    Kampanie = n(),
    Koszt    = sum(Koszt),
    Przychod = sum(Przychod),
    zysk     = sum(zysk),
    CAC      = round(mean(CAC), 2),
    ROAS     = round(mean(ROAS), 2),
    .groups  = "drop"
  ) |>
  arrange(desc(zysk))

print(ranking_kanalow)

#WIZUALIZACJA WYNIKÓW I EKSPORT GRAFIKI (GGPLOT2) --------------------------
wykres <- ggplot(ranking_kanalow, aes(x = reorder(Kanal, -zysk), y = zysk, fill = zysk > 0)) +
  geom_col(width = 0.55, show.legend = FALSE) +
  geom_hline(yintercept = 0, color = "#2c3e50", linewidth = 0.8) +
  geom_text(
    aes(label = paste0(zysk, " zł")),
    vjust = ifelse(ranking_kanalow$zysk >= 0, -0.5, 1.4),
    fontface = "bold",
    size = 4
  ) +
  scale_fill_manual(values = c("TRUE" = "#2ecc71", "FALSE" = "#e74c3c")) +
  labs(
    title = "Zysk netto według kanału reklamowego (PLN)",
    subtitle = "Porównanie rentowności 12 kampanii w 4 kanałach marketingowych",
    x = "Kanał marketingowy",
    y = "Zysk netto (Przychód - Koszt)"
  ) +
  ylim(-8000, 50000) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    panel.grid.minor = element_blank()
  )

print(wykres)

#Zapis wykresu do pliku PNG (gotowy do osadzenia w README.md na GitHubie)
ggsave("wykres_zysk_kanaly.png", plot = wykres, width = 8, height = 5, dpi = 300)
