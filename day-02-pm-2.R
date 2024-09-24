# Castaway CTD データの解析
# 2024-09-24
# Greg Nishihara

# パッケージの読み込み
library(tidyverse) # tidyverse（モダンR）
library(lubridate) # 時刻データ処理

library(magick)    # 画像処理用のパッケージ
library(showtext)  # 作図用フォントのパッケージ
library(ggtext)    # 作図用フォントのパッケージ
library(ggpubr)    # ggplot() テーマパッケージ

# フォントの準備
# この関数の場合はネットへのアクセスが必要
# google のサーバへアクセスする
font_add_google(name = "Noto Sans JP", family = "notosansjp")

# ggplot のテーマを設定する
# この場合は、背景が白、軸線あり
theme_pubr(base_size = 10,
           base_family = "notosansjp") |> 
  theme_set()


# 保存済みデータファイルの読み込み
fname = here::here("Output/CTD_dataset.csv")
alldata = read_csv(fname)
alldata
