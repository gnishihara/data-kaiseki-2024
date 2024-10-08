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

plot1 = ggplot(df3) + geom_point(aes(x = fit, y = residual))
plot2 = ggplot(df3) + geom_point(aes(x = fit, y = stdresid))
plot3 = 
  ggplot(df3) +
  geom_qq(aes(sample = residual)) +
  geom_qq_line(aes(sample = residual))

# ここでは patchwork の演算子を使って、上の図を結合する
plot1 + plot2 + plot3 + plot_layout(ncol = 2, nrow = 2)

# 左上の図：fit が上昇すると残渣が下がって、そのあと広がる。
# 等分散性ではない、残渣にパターンが存在する。
# 
# 右上の図：fit が上昇すると、標準化残渣も上昇する。
# 明らかに、等分散性ではない。
# 
# 左下の図：残渣の四分位数は線の上にのるので、正規性に大きな
# 問題はない。

# 説明の上限を１０あたりにしたい
log(4000)
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

m2 = glm(Species ~ logAdj + logArea + logElev + Near5 + Scruz30,
         data = df1, family = gaussian("identity"))

summary(m2) # 一般化線形モデルの係数表

# モデルの診断図
# 残渣、期待値、標準化残渣の絶対値の平方根
df3 = df1 |> 
  select(Species) |> 
  mutate(residual = residuals(m2),
         fit = predict(m2)) |> 
  mutate(stdresid  = sqrt(abs(rstandard(m2))))

plot1 = ggplot(df3) + geom_point(aes(x = fit, y = residual))
plot2 = ggplot(df3) + geom_point(aes(x = fit, y = stdresid))
plot3 = 
  ggplot(df3) +
  geom_qq(aes(sample = residual)) +
  geom_qq_line(aes(sample = residual))

# ここでは patchwork の演算子を使って、上の図を結合する
plot1 + plot2 + plot3 + plot_layout(ncol = 2, nrow = 2)
