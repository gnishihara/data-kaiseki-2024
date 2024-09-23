# Excelファイルの読み込み
# 2024-09-23
# Greg Nishihara

library(tidyverse)
library(readxl)
# 一番目のシート
# 読み込み範囲 A1:I32

fname = "Data/20231206シキシマハナダイ_dataset.xlsx"
sheets = excel_sheets(fname)
range = "A1:I32"

fish_data = 
  read_xlsx(path = fname,
            sheet = sheets[1],
            range = range)
fish_data
# No. 資料番号
# TL Total length (mm)
# FL Fork length びさちょう (mm)
# SL Standard length (mm)
# BW Body weight (g)
# LW Liver weight (g)
# GW Gonad weight (g)
# UBW Bladder weight (g) 欠損値あり
# Sex 

# TL の平均値

TL = fish_data$TL
mean(TL)   # 平均値
sd(TL)     # 標準偏差
var(TL)    # 分散
median(TL) # 中央値
mad(TL)    # 中央絶対偏差
sd(TL) / sqrt(length(TL) - 1) # 標準誤差
length(TL) # データ数

# TL と FL の統計量
# tibble 内のデータの統計量は summarise() を使いましょう
fish_data |> 
  summarise(
    TL_mean = mean(TL),
    TL_sd = sd(TL),
    FL_mean = mean(FL),
    FL_sd = sd(FL)
  )

fish_data_summary = 
  fish_data |> 
  summarise(
    across(c(TL, FL, SL, BW, LW, GW, UBW),
           list(mean = mean,
                sd = sd,
                n = length))
  )
fish_data_summary

fish_data_summary |> 
  pivot_longer(cols = everything())


fish_data_summary |> 
  pivot_longer(cols = everything(),
               names_sep = "_",
               names_to = c("variable", "statistic"))

# データの記述統計量の求め方
# 欠損対応なし
fish_data_summary |> 
  pivot_longer(cols = everything(),
               names_sep = "_",
               names_to = c("variable", "statistic")) |> 
  pivot_wider(names_from = "statistic",
              values_from = "value") |> 
  mutate(se = sd / sqrt(n - 1))




