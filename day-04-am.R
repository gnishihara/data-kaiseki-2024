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

# データの準備
# :: <- この演算子は、パッケージにある関数・データを、パッケージを読まず使うためのものです。
df1 = faraway::gala |> as_tibble(rownames = "Island") # faraway パッケージのgala データを tibble化する
df1 # ガラパゴス諸島の島のける植物の種数とその他の情報

# まずは生データの作図
ggplot(df1) + geom_point(aes(x = Area, y = Species))

# 作業仮設：種数は面積および高度と正の関係があり、距離と負の関係がある
# それぞれの説明変数との関係を見る






