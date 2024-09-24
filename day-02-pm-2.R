# Castaway CTD データの解析
# 2024-09-24
# Greg Nishihara

# パッケージの読み込み
library(tidyverse)
library(lubridate) # 時刻データ処理

# 保存済みデータファイルの読み込み
fname = here::here("Output/CTD_dataset.csv")
alldata = read_csv(fname)
alldata
