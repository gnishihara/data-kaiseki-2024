# Castaway CTD データの解析
# 2024-09-24
# Greg Nishihara

# パッケージの読み込み
library(tidyverse) # tidyverse（モダンR）
library(lubridate) # 時刻データ処理

library(magick)    # 画像処理用のパッケージ
library(showtext)  # 作図用フォントのパッケージ
library(ggtext)    # 作図用フォントのパッケージ


# 保存済みデータファイルの読み込み
fname = here::here("Output/CTD_dataset.csv")
alldata = read_csv(fname)
alldata
