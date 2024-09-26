# 一般化加法モデル
# 2024-09-26
# Greg Nishihara


# パッケージの読み込み
library(MASS)  
library(mgcv)   # 一般化加法モデル用のパッケージ
library(gratia) # 一般化加法モデル用のパッケージ
library(tidyverse)
library(lubridate)
library(ggtext)
library(ggpubr)
library(showtext)
library(magick)
library(emmeans)
library(patchwork) # 図用の演算子
library(statmod) # ランダム化残渣の関数用

# フォントの読み込みとggplotの書式設定

font_add_google("Noto Sans", family = "ns")
theme_pubr(base_size = 10, base_family = "ns") |> theme_set()
showtext_auto()

# データの準備
# :: <- この演算子は、パッケージにある関数・データを、パッケージを読まず使うためのものです。
df1 = faraway::gala |> as_tibble(rownames = "Island") # faraway パッケージのgala データを tibble化する
df1 # ガラパゴス諸島の島のける植物の種数とその他の情報




