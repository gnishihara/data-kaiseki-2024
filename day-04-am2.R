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

# 負の二項分布のリンク関数はログ関数です

m2 = glm.nb(Species ~ logAdj + logArea + logElev + Near5 + Scruz30,
         data = df1)

# 負の二項分布のGLMの場合、
# Residual deviance の値と関係する自由度の値に大きな違いがあれば、
# モデルは却下します。
summary(m2) # 一般化線形モデルの係数表
# Residual deviance = 32.827
# Residual deviance df = 24
# 345 ~ 24 なので、モデルを却下しません

# モデルの診断図
# 残渣、期待値、標準化残渣の絶対値の平方根
df3 = df1 |> 
  select(Species) |> 
  mutate(residual = qresiduals(m2),
         fit = predict(m2)) |> 
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

df3 = df3 |> mutate(predict = exp(fit)) # ログスケールの期待地を観測スケールの値に戻す

# 期待値と観測地の関係を確認
# 完璧にあてはめられたら、点は線の上に並ぶ
ggplot(df3)  +
  geom_point(aes(x = predict, y = Species)) +
  geom_abline(slope = 1)

summary(m2)

############################################################
# 帰無仮説を棄却できなかった係数は、
# モデルから外せる？
# 帰無仮説を棄却できなかったということは、
# 統計学的に係数と０の区別ができない。
# でも、係数は０だといえない。

# どの変数を残すか？
stepAIC(m2) # AICの変化を利用して、係数を外す

# のこった変数は logArea と Scruz30

m3 = glm.nb(Species ~ logArea + Scruz30, data = df1)

# 負の二項分布のGLMの場合、
# Residual deviance の値と関係する自由度の値に大きな違いがあれば、
# モデルは却下します。
summary(m3) # 一般化線形モデルの係数表
# Residual deviance = 32.86
# Residual deviance df = 27
# 32.86 ~ 27 なので、モデルを却下しません

# モデルの診断図
# 残渣、期待値、標準化残渣の絶対値の平方根
df3 = df1 |> 
  select(Species) |> 
  mutate(residual = qresiduals(m3),
         fit = predict(m3)) |> 
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

df3 = df3 |> mutate(predict = exp(fit)) # ログスケールの期待地を観測スケールの値に戻す

# 期待値と観測地の関係を確認
# 完璧にあてはめられたら、点は線の上に並ぶ
ggplot(df3)  +
  geom_point(aes(x = predict, y = Species)) +
  geom_abline(slope = 1)

summary(m3)

# 論文に入れる図
# フォントの読み込みとggplot の書式設定
font_add_google("Noto Sans", family = "ns")
theme_pubr(base_size = 10,
           base_family = "ns") |> 
  theme_set()

# モデル用のデータを作成する
pdata = df1 |> 
  expand(logArea = seq(min(logArea), max(logArea), length = 21),
         Scruz30 = seq(min(Scruz30), max(Scruz30), length = 5))
pdata = pdata |> 
  mutate(Area = exp(logArea),
         Scruz = Scruz30 * 30)
tmp = predict(m3, newdata = pdata, se.fit = TRUE) |> as_tibble()
pdata = bind_cols(pdata, tmp)


# Scruzの中央値に対するlogAreaの結果

qdata = df1 |> 
  expand(logArea = seq(min(logArea), max(logArea), length = 21),
         Scruz30 = median(Scruz30)) |> 
  mutate(Area = exp(logArea),
         Scruz = Scruz30 * 30)
tmp = predict(m3, newdata = qdata, se.fit = TRUE) |> as_tibble()
qdata = bind_cols(qdata, tmp)

# Areaの中央値に対するScruz30の結果

rdata = df1 |> 
  expand(Area = median(Area),
         Scruz30 = seq(min(Scruz30), max(Scruz30), length = 21)) |> 
  mutate(Scruz = Scruz30 * 30,
         logArea = log(Area))
tmp = predict(m3, newdata = rdata, se.fit = TRUE) |> as_tibble()
rdata = bind_cols(rdata, tmp)



# モデルとデータの図 
xtitle = "log Area (log(m<sup>2</sup>))" # markdown 
ytitle = "Species (-)"
# Scruzの中央値に対するlogArea との関係を示す図。
# 線はモデル結果（期待値）、グレーの範囲は期待値の95%信頼区間。
ggplot(df1) +
  geom_ribbon(aes(x = logArea,
                  ymin = exp(fit - se.fit),
                  ymax = exp(fit + se.fit)),
              data = qdata,
              alpha = 0.5) +
  geom_line(aes(x  = logArea, y = exp(fit)), 
            data = qdata) +
  geom_point(aes(x = logArea, y = Species)) +
  scale_x_continuous(name = xtitle,
                     limits = c(-5, 10),
                     breaks = seq(-5, 10, by = 5)) +
  scale_y_continuous(name = ytitle,
                     limits = c(0, 650),
                     breaks = seq(0, 650, by = 130)) +
  theme(
    axis.title.x = element_markdown(),
    axis.title.y = element_markdown(),
    axis.line.x = element_blank(),
    axis.line.y = element_blank(),
    axis.ticks.x = element_line(color = "black"),
    axis.ticks.y = element_line(color = "black"),
    panel.border = element_rect(fill = NA, color = "black"),
  )

xtitle2 = "Distance to Santa Cruz (km / 30)"
ggplot(df1) +
  geom_ribbon(aes(x = Scruz30,
                  ymin = exp(fit - se.fit),
                  ymax = exp(fit + se.fit)),
              data = rdata,
              alpha = 0.5) +
  geom_line(aes(x = Scruz30, y = exp(fit)),
            data = rdata) + 
  geom_point(aes(x = Scruz30, y = Species)) +
  scale_x_continuous(name = xtitle2,
                     limits = c(0, 10),
                     breaks = seq(0, 10, by = 2)) +
  scale_y_continuous(name = ytitle,
                     limits = c(0, 650),
                     breaks = seq(0, 650, by = 130)) +
  theme(
    axis.title.x = element_markdown(),
    axis.title.y = element_markdown(),
    axis.line.x = element_blank(),
    axis.line.y = element_blank(),
    axis.ticks.x = element_line(color = "black"),
    axis.ticks.y = element_line(color = "black"),
    panel.border = element_rect(fill = NA, color = "black"),
  )


ggplot(df1) + 
  geom_tile(aes(x = logArea,
                y = Scruz30,
                fill = exp(fit)), 
            data = pdata) + 
  geom_point(aes(x = logArea,
                 y = Scruz30))


############################################################

# Scruzの中央値に対するlogAreaの結果

qdata = df1 |> 
  expand(logArea = seq(min(logArea), max(logArea), length = 21),
         Scruz30 = c(min(Scruz30), median(Scruz30), max(Scruz30))) |> 
  mutate(Area = exp(logArea),
         Scruz = Scruz30 * 30)

tmp = predict(m3, newdata = qdata, se.fit = TRUE) |> as_tibble()
qdata = bind_cols(qdata, tmp)

# Areaの中央値に対するScruz30の結果

rdata = df1 |> 
  expand(Area = c(min(Area), median(Area), max(Area)),
         Scruz30 = seq(min(Scruz30), max(Scruz30), length = 21)) |> 
  mutate(Scruz = Scruz30 * 30,
         logArea = log(Area))
tmp = predict(m3, newdata = rdata, se.fit = TRUE) |> as_tibble()
rdata = bind_cols(rdata, tmp)



# モデルとデータの図 
xtitle = "log Area (log(m<sup>2</sup>))" # markdown 
ytitle = "Species (-)"
# Scruzの中央値に対するlogArea との関係を示す図。
# 線はモデル結果（期待値）、グレーの範囲は期待値の95%信頼区間。
ggplot(df1) +
  geom_ribbon(aes(x = logArea,
                  ymin = exp(fit - se.fit),
                  ymax = exp(fit + se.fit),
                  fill = factor(Scruz)),
              data = qdata,
              alpha = 0.5) +
  geom_line(aes(x  = logArea, y = exp(fit), color = factor(Scruz)), 
            data = qdata) +
  geom_point(aes(x = logArea, y = Species)) +
  scale_x_continuous(name = xtitle,
                     limits = c(-5, 10),
                     breaks = seq(-5, 10, by = 5)) +
  scale_y_continuous(name = ytitle,
                     limits = c(0, 800),
                     breaks = seq(0, 800, length = 5)) +
  theme(
    axis.title.x = element_markdown(),
    axis.title.y = element_markdown(),
    axis.line.x = element_blank(),
    axis.line.y = element_blank(),
    axis.ticks.x = element_line(color = "black"),
    axis.ticks.y = element_line(color = "black"),
    panel.border = element_rect(fill = NA, color = "black"),
  )

xtitle2 = "Distance to Santa Cruz (km / 30)"
ggplot(df1) +
  geom_ribbon(aes(x = Scruz30,
                  ymin = exp(fit - se.fit),
                  ymax = exp(fit + se.fit)),
              data = rdata,
              alpha = 0.5) +
  geom_line(aes(x = Scruz30, y = exp(fit)),
            data = rdata) + 
  geom_point(aes(x = Scruz30, y = Species)) +
  scale_x_continuous(name = xtitle2,
                     limits = c(0, 10),
                     breaks = seq(0, 10, by = 2)) +
  scale_y_continuous(name = ytitle,
                     limits = c(0, 650),
                     breaks = seq(0, 650, by = 130)) +
  theme(
    axis.title.x = element_markdown(),
    axis.title.y = element_markdown(),
    axis.line.x = element_blank(),
    axis.line.y = element_blank(),
    axis.ticks.x = element_line(color = "black"),
    axis.ticks.y = element_line(color = "black"),
    panel.border = element_rect(fill = NA, color = "black"),
  )


ggplot(df1) + 
  geom_tile(aes(x = logArea,
                y = Scruz30,
                fill = exp(fit)), 
            data = pdata) + 
  geom_point(aes(x = logArea,
                 y = Scruz30))



