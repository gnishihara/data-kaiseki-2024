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

