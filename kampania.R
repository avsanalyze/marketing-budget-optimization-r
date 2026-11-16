kampanie <- data.frame(
  ID_Kampanii = paste0("KAMP_", 1:12),
  Kanal = c("Google Ads", "Meta Ads", "TikTok", "Email",
            "Google Ads", "Meta Ads", "TikTok", "Email",
            "Google Ads", "Meta Ads", "TikTok", "Email"),
  Koszt = c(5000, 4200, 3500, 800, 6100, 3900, 4800, 950, 5500, 4500, 3200, 700),
  Klikniecia = c(2500, 3100, 4200, 900, 2900, 2800, 5100, 1100, 2700, 3300, 3900, 850),
  Zamowienia = c(120, 85, 40, 65, 145, 70, 35, 80, 130, 90, 28, 55),
  Przychod = c(18000, 11000, 3100, 7800, 22500, 8400, 2900, 9600, 19500, 11700, 2100, 6600)
)

# KROK 1: Podgląd tabeli i sprawdzenie braków danych
kampanie
colSums(is.na(kampanie))

#policzyć CAC, Return on a ad spend, zysk
kampanie$CAC <- round(kampanie$Koszt/kampanie$Zamowienia, 2)
kampanie$ROAS <- round(kampanie$Przychod/kampanie$Koszt, 2)
kampanie$zysk <- round(kampanie$Przychod - kampanie$Koszt, 2)


#podejmowanie deyczji
kampanie$decyzja <- ifelse(
  kampanie$ROAS >= 3.0, "skalować",
  ifelse(kampanie$ROAS >= 1.0 , "optymalizować", "wyłączyć")
)
#sumowanie na kanały
sumy_kanal <- aggregate(
  cbind(Koszt, Przychod, zysk) ~ Kanal,
  data = kampanie,
  FUN = sum
)
srednie_kanal <- aggregate(
  cbind(CAC, ROAS) ~ Kanal,
  data = kampanie,
  FUN = mean
)
srednie_kanal$CAC <- round(srednie_kanal$CAC,2)
srednie_kanal$ROAS <- round(srednie_kanal$ROAS,2)

#tworzenie rankingu kanałów
ranking_kanalow <- merge(sumy_kanal,srednie_kanal, by = "Kanal")
ranking_kanalow <- ranking_kanalow[order(-ranking_kanalow$zysk),]
ranking_kanalow


#wizualizacja
kolory <- ifelse(
  ranking_kanalow$zysk < 0, "red",
  ifelse(ranking_kanalow$ROAS >= 3, "green", "yellow")
)
wykres <- barplot(
  ranking_kanalow$zysk,
  names.arg = ranking_kanalow$Kanal,
  col = kolory,
  main = "Zysk netto według kanału",
  xlab = "kanał marketingowy",
  ylab = "Zysk netto",
  ylim = c(-8000,50000),
  border = NA
)

abline(h=0, col="black",lwd=1.5)

text(
  x = wykres,
  y = ifelse(ranking_kanalow$zysk >= 0, ranking_kanalow$zysk + 2200, ranking_kanalow$zysk - 2500),
  labels = paste0(ranking_kanalow$zysk, " zł"),
  font = 2,
  cex = 0.9
)









