# 一般化線形モデル
# 2024-09-26
# Greg Nishihara


# パッケージの読み込み
library(tidyverse)
library(lubridate)
library(ggtext)
library(ggpubr)
library(showtext)
library(magick)
library(emmeans)
library(patchwork) # 図用の演算子

# データの準備
# :: <- この演算子は、パッケージにある関数・データを、パッケージを読まず使うためのものです。
df1 = faraway::gala |> as_tibble(rownames = "Island") # faraway パッケージのgala データを tibble化する
df1 # ガラパゴス諸島の島のける植物の種数とその他の情報

# まずは生データの作図
ggplot(df1) + geom_point(aes(x = Area, y = Species))
