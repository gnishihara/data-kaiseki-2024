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

# 作業仮設：種数は面積および高度と正の関係があり、距離と負の関係がある
# それぞれの説明変数との関係を見る

df2 = df1 |> 
  pivot_longer(cols = c("Area", "Elevation",
                        "Nearest","Scruz", "Adjacent"))

ggplot(df2) + 
  geom_point(aes(x = value, y = Species, color = name)) +
  facet_wrap(vars(name), scales = "free")

# 作業仮設を検証しましょう
# 帰無仮説：
# （１）Species と Adjacent との関係はない
# （２）Species と Area との関係はない
# （３）Species と Elevation との関係はない
# （４）Species と Nearest との関係はない
# （５）Species と Scruz との関係はない

m1 = glm(Species ~ Adjacent + Area + Elevation + Nearest + Scruz,
         data = df1, family = gaussian("identity"))

summary(m1) # 一般化線形モデルの係数表

# モデルの診断図
# 残渣、期待値、標準化残渣の絶対値の平方根
df3 = df1 |> 
  select(Species) |> 
  mutate(residual = residuals(m1),
         fit = predict(m1)) |> 
  mutate(stdresid  = sqrt(abs(rstandard(m1))))





