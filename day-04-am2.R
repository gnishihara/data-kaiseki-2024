# 一般化線形モデル
# 2024-09-26
# Greg Nishihara


# パッケージの読み込み
library(MASS)
library(tidyverse)
library(lubridate)
library(ggtext)
library(ggpubr)
library(showtext)
library(magick)
library(emmeans)
library(patchwork) # 図用の演算子
library(statmod) # ランダム化残渣の関数用

# データの準備
# :: <- この演算子は、パッケージにある関数・データを、パッケージを読まず使うためのものです。
df1 = faraway::gala |> as_tibble(rownames = "Island") # faraway パッケージのgala データを tibble化する
df1 # ガラパゴス諸島の島のける植物の種数とその他の情報

# まずは生データの作図
ggplot(df1) + geom_point(aes(x = Area, y = Species))
df1 = df1 |> 
  mutate(logAdj = log(Adjacent),
         logArea = log(Area),
         logElev = log(Elevation),
         Near5 = Nearest / 5,
         Scruz30 = Scruz / 30)

# cols = -Species: Species 以外の変数を縦に結合する
df1 |> 
  select(Species, logAdj, logArea, logElev, Near5, Scruz30) |> 
  pivot_longer(cols = -Species) |> 
  ggplot() + 
  geom_point(aes(x = value, y = Species, color = name)) +
  facet_wrap(vars(name), scales = "free")

# 帰無仮説：
# （１）Species と log(Adjacent) との関係はない
# （２）Species と log(Area) との関係はない
# （３）Species と log(Elevation) との関係はない
# （４）Species と Nearest/5 との関係はない
# （５）Species と Scruz/30 との関係はない

# ポアソン分布、リンク関数はログ
# ポアソン分布は離散型の分布(数の分布)
m1 = glm(Species ~ logAdj + logArea + logElev + Near5 + Scruz30,
         data = df1, family = poisson("log"))

# ポアソン分布のGLMの場合、
# Residual deviance の値と関係する自由度の値に大きな違いがあれば、
# モデルは却下します。
summary(m1) # 一般化線形モデルの係数表
# Residual deviance = 346
# Residual deviance df = 24
# 345 >> 24 なので、モデルを却下します

# モデルの診断図
# 残渣、期待値、標準化残渣の絶対値の平方根
df3 = df1 |> 
  select(Species) |> 
  mutate(residual = qresiduals(m1),
         fit = predict(m1)) |> 
  filter(!is.infinite(residual)) |> # 無限の情報外す
  mutate(stdresid  = sqrt(abs(scale(residual)[, 1])))

plot1 = ggplot(df3) + geom_point(aes(x = fit, y = residual))
plot2 = ggplot(df3) + geom_point(aes(x = fit, y = stdresid))
plot3 = 
  ggplot(df3) +
  geom_qq(aes(sample = residual)) +
  geom_qq_line(aes(sample = residual))

# ここでは patchwork の演算子を使って、上の図を結合する
plot1 + plot2 + plot3 + plot_layout(ncol = 2, nrow = 2)

############################################################
# では、ポアソン分布GLMを却下したら、つぎは
# 負の二項分布GLMを検討する

# MASS のパッケージには select() 関数がる
# MASS の select()と tidyverse　select() 関数干渉します

m1 = glm(Species ~ logAdj + logArea + logElev + Near5 + Scruz30,
         data = df1, family = ("log"))

# ポアソン分布のGLMの場合、
# Residual deviance の値と関係する自由度の値に大きな違いがあれば、
# モデルは却下します。
summary(m1) # 一般化線形モデルの係数表
# Residual deviance = 346
# Residual deviance df = 24
# 345 >> 24 なので、モデルを却下します

# モデルの診断図
# 残渣、期待値、標準化残渣の絶対値の平方根
df3 = df1 |> 
  select(Species) |> 
  mutate(residual = qresiduals(m1),
         fit = predict(m1)) |> 
  filter(!is.infinite(residual)) |> # 無限の情報外す
  mutate(stdresid  = sqrt(abs(scale(residual)[, 1])))

plot1 = ggplot(df3) + geom_point(aes(x = fit, y = residual))
plot2 = ggplot(df3) + geom_point(aes(x = fit, y = stdresid))
plot3 = 
  ggplot(df3) +
  geom_qq(aes(sample = residual)) +
  geom_qq_line(aes(sample = residual))

# ここでは patchwork の演算子を使って、上の図を結合する
plot1 + plot2 + plot3 + plot_layout(ncol = 2, nrow = 2)








