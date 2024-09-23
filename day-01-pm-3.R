# シキシマハナダイの生データ
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

# Sex 箱ひげ図
ggplot(fish_data) + 
  geom_boxplot(aes(x = Sex, y = TL))

# Sex 散布図
# position_jitter() で点にｘ方向の位置をずらす 
ggplot(fish_data) + 
  geom_point(aes(x = Sex, y = TL),
             position = position_jitter(width = 0.1))

# Sex 毎 TL vs SL
ggplot(fish_data)+ 
  geom_point(aes(x = SL, y = TL, color = Sex))

# Sex 毎 SL vs FL
ggplot(fish_data)+ 
  geom_point(aes(x = SL, y = FL, color = Sex))




