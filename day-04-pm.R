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
# 全データをまとめて、モデルをあてはめている
m1 = gam(uptake ~ s(conc, k = 5, bs = "tp"), data = df1)
draw(m1) # gratia パッケージの関数
# s() スムーズの関数
#  第1引数は説明変数
#  k = 5 スムーズの基底の数
#  bs = "tp" スムーズの種類、このとき薄板平滑化スプライン

basis(m1) |> draw() # 基底毎の図


tmp = gam(uptake ~ s(conc, k = 3, bs = "tp"), data = df1)
draw(tmp)
basis(tmp) |> draw()
coef(tmp)

t1 = basis(tmp) |> filter(.bf == 1) |> pull(.value)
t2 = basis(tmp) |> filter(.bf == 2) |> pull(.value)
conc = basis(tmp) |> filter(.bf == 2) |> pull(conc)

tibble(conc, t1, t2) |> 
  ggplot() + 
  geom_line(aes( x= conc, y = t1, color = "basis 1")) +
  geom_line(aes( x= conc, y = t2, color = "basis 2")) +
  geom_line(aes( x= conc, y = t1 + t2, color = "basis 1 + 2"),
            linewidth = 2) 

