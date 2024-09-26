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

# 参考文献
# https://peerj.com/articles/6876/
# Pedersen EJ, Miller DL, Simpson GL, Ross N. 2019. 
# Hierarchical generalized additive models in ecology: an
# introduction with mgcv. PeerJ 7:e6876
# https://doi.org/10.7717/peerj.6876

# データの準備

df1 = CO2 |> as_tibble()
# conc: CO2 濃度
# uptake: CO2吸収速度
# Plant, type, treatment  # 因子
# treatment: 前夜に低い温度を経験したか否か

# すべてのデータをまとめて表示する
ggplot(df1) + 
  geom_point(aes(x = conc, y = uptake, 
                 color = Plant)) 

# type と treatment 毎に表示する
ggplot(df1) + 
  geom_point(aes(x = conc, y = uptake, 
                 color = Plant)) +
  facet_grid(rows = vars(Treatment),
             cols = vars(Type))

# Generalized Additive Model (GAM) のあてはめ
m1 = gam(uptake ~ s(conc, k = 5, bs = "tp"), data = df1)
draw(m1) # gratia パッケージの関数
basis(m1) |> draw()



