# シキシマハナダイの生データ
# 2024-09-23
# Greg Nishihara

library(tidyverse)
library(readxl)
# 一番目のシート
# 読み込み範囲 A1:I32

## here::here() 関数は、プロジェクトのルートフォルダを
## 基準にして、相対的なパスを指定することができます。


fname = here::here("Data/20231206シキシマハナダイ_dataset.xlsx")

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

# 課題 #####################################################
## (1) BW と LW の Sex 毎の平均値と中央値を求める。
## (2) BW と LW の Sex 毎の箱ひげ図を作図する。
## (3) BW 対 LW の Sex 毎の散布図を作図する。
## 図はPNGファイルに保存すること。
## (1) の記述統計量をcsvファイルに保存すること。
############################################################

## (1) BW と LW の Sex 毎の平均値と中央値を求める。
fish_data |> 
  group_by(Sex) |> 
  summarise(
    across(
      c(BW, LW),
      list(mean = mean, median = median)
    )
  )

## (2) BW と LW の Sex 毎の箱ひげ図を作図する。
ytitle = "Body weight (g)"
ggplot(fish_data) +
  geom_boxplot(aes(x = Sex, y = BW)) +
  scale_y_continuous(name = ytitle)

ytitle = "Liver weight (g)"
ggplot(fish_data) +
  geom_boxplot(aes(x = Sex, y = LW)) +
  scale_y_continuous(name = ytitle)

## (3) BW 対 LW の Sex 毎の散布図を作図する。

ytitle = "Body weight (g)"
xtitle = "Liver weight (g)"
ggplot(fish_data) +
  geom_point(aes(x = LW, y = BW, color = Sex, shape = Sex)) +
  scale_x_continuous(name = xtitle) +
  scale_y_continuous(name = ytitle)
