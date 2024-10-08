# 一般化線形モデル
# 2024-09-25
# Greg Nishihara

# パッケージの読み込み
# github のリンク https://github.com/gnishihara/data-kaiseki-2024

library(tidyverse) # tidyverse
library(lubridate) # 日時データの処理
library(emmeans)   # 多重比較
library(ggtext)    # ggplot にマークダウンを使う
library(statmod)   # ランダム化残渣よう


# install.packages("palmerpenguins")

# 3種のアヤメ(Iris setosa, Iris versicolor, Iris virginica)

df1 = iris |> as_tibble()

df1
# 作図して、データを可視化する
ggplot(df1) + 
  geom_point(aes(x = Petal.Width,
                 y = Petal.Length,
                 color = Species))
# CTRL + ALT + B # 上から現在の行まで実行する

# 作業仮設：花弁の長さと幅の関係は種によってことなる 
# 帰無仮説：花弁の長さと幅の関係（傾き）は等しい

# Petal.Width * Species = Petal.Length + Species + Petal.Length:Species

m0 = lm(Petal.Length ~ 1, data = df1)                     # 帰無モデル
m1 = lm(Petal.Length ~ Petal.Width, data = df1)           # 傾き等しいモデル
m2 = lm(Petal.Length ~ Species, data = df1)               # 傾きなしモデル
m3 = lm(Petal.Length ~ Petal.Width + Species, data = df1) # 相互作用なしモデル
m4 = lm(Petal.Length ~ Petal.Width * Species, data = df1) # フルモデル

AIC(m0, m1, m2, m3, m4) # m4 モデルのAICが最も低いので、とりあえず採択する

# 診断図の確認
plot(m4, which = 1) # 残渣対期待
plot(m4, which = 3) # 標準化残渣対期待
plot(m4, which = 2) # QQplot (正規性の確認)

summary.aov(m4)

# ペア毎の傾きの比較
# 診断図に問題があった（等分散性ではない、正規性ではない）
# ペア毎の比較の評価は厳しい
emtrends(m4, 'pairwise' ~ Species, var = "Petal.Width")

# 期待値ようの tibble を準備する
pdata = df1 |> 
  expand(Species,
         Petal.Width = seq(min(Petal.Width),
                           max(Petal.Width),
                           length = 21))

tmp = predict(m4, newdata = pdata, se.fit = TRUE) |> 
  as_tibble()

pdata = bind_cols(pdata, tmp)

ggplot(df1) + 
  geom_point(aes(x = Petal.Width,
                 y = Petal.Length,
                 color = Species)) +
  geom_line(aes(x = Petal.Width,
                y = fit,
                color = Species),
            data = pdata)


# 期待値ようの tibble を準備する
pdata = df1 |> 
  group_by(Species) |> 
  expand(Petal.Width = seq(min(Petal.Width),
                           max(Petal.Width),
                           length = 21))

tmp = predict(m4, newdata = pdata, se.fit = TRUE) |> 
  as_tibble()

pdata = bind_cols(pdata, tmp)

ggplot(df1) + 
  geom_point(aes(x = Petal.Width,
                 y = Petal.Length,
                 color = Species)) +
  geom_ribbon(aes(x = Petal.Width,
                  ymin = fit - se.fit,
                  ymax = fit + se.fit,
                  fill = Species),
              data = pdata,
              alpha = 0.5) +
  geom_line(aes(x = Petal.Width,
                y = fit,
                color = Species),
            data = pdata) 

# 診断図に問題があってので、データ解析を工夫しましょう
df1 = df1 |> 
  mutate(lpl = log(Petal.Length),
         lpw = log(Petal.Width), 
         .before = Sepal.Length)

# 作業仮設：花弁のlog(長さ)とlog(幅)の関係は種によってことなる 
# 帰無仮説：花弁のlog(長さ)とlog(幅)の関係（傾き）は等しい
m0 = lm(lpl ~ 1, data = df1)             # 帰無モデル
m1 = lm(lpl ~ lpw, data = df1)           # 傾き等しいモデル
m2 = lm(lpl ~ Species, data = df1)       # 傾きなしモデル
m3 = lm(lpl ~ lpw + Species, data = df1) # 相互作用なしモデル
m4 = lm(lpl ~ lpw * Species, data = df1) # フルモデル
AIC(m0, m1, m2, m3, m4) # m4 モデルのAICが最も低いので、とりあえず採択する
# 診断図の確認
plot(m4, which = 1) # 残渣対期待
plot(m4, which = 3) # 標準化残渣対期待
plot(m4, which = 2) # QQplot (正規性の確認)

summary.aov(m4)
# ペア毎の傾きの比較
# 診断図に問題があった（等分散性ではない、正規性ではない）
# ペア毎の比較の評価は厳しい
emtrends(m4, 'pairwise' ~ Species, var = "lpw")


pdata = df1 |> 
  group_by(Species) |> 
  expand(Petal.Width = seq(min(Petal.Width),
                           max(Petal.Width),
                           length = 21))
pdata = pdata |> 
  mutate(lpw = log(Petal.Width))

tmp = predict(m4, newdata = pdata, se.fit = TRUE) |> 
  as_tibble()

pdata = bind_cols(pdata, tmp)

ggplot(df1) + 
  geom_point(aes(x = Petal.Width,
                 y = Petal.Length,
                 color = Species)) +
  geom_ribbon(aes(x = Petal.Width,
                  ymin = exp(fit - se.fit),
                  ymax = exp(fit + se.fit),
                  fill = Species),
              data = pdata,
              alpha = 0.5) +
  geom_line(aes(x = Petal.Width,
                y = exp(fit),
                color = Species),
            data = pdata) 

# 一般化線形モデル（分布を ガンマ分布）

g0 = glm(Petal.Length ~ 1, data = df1, family = Gamma("log"))
g1 = glm(Petal.Length ~ lpw, data = df1, family = Gamma("log"))
g2 = glm(Petal.Length ~ Species, data = df1, family = Gamma("log"))
g3 = glm(Petal.Length ~ lpw + Species, data = df1, family = Gamma("log"))
g4 = glm(Petal.Length ~ lpw * Species, data = df1, family = Gamma("log"))
AIC(g0, g1, g2, g3, g4) # g4 のAICが最も低い

# ランダム化残渣 (randomized quantile residuals) を追加する
# モデル期待値も追加する
df1 = df1 |> 
  mutate(qresid = qresiduals(g4),
         fit = predict(g4))

# 診断図の確認
## 残渣対期待値
ggplot(df1) + geom_point(aes(x = fit, y = qresid))

## 標準化残渣対期待値
df1 = df1 |> mutate(stdqr = sqrt(abs(scale(qresid)[, 1])))
ggplot(df1) + geom_point(aes(x = fit, y = stdqr))

## QQplot （正規性の確認）
## 一般化線形モデルで指定した分布にかかわらず、
## モデル当てはめに問題がなければ、
## ランダム化残渣は正規分布に従う。
ggplot(df1) +
  geom_qq(aes(sample = qresid)) +
  geom_qq_line(aes(sample = qresid))




anova(g4) # デビアス表
# ペア毎の傾きの比較
# 診断図に問題があった（等分散性ではない、正規性ではない）
# ペア毎の比較の評価は厳しい
emtrends(g4, 'pairwise' ~ Species, var = "lpw")
emtrends(m4, 'pairwise' ~ Species, var = "lpw")


pdata = df1 |> 
  group_by(Species) |> 
  expand(Petal.Width = seq(min(Petal.Width),
                           max(Petal.Width),
                           length = 21))
pdata = pdata |> 
  mutate(lpw = log(Petal.Width))

tmp = predict(g4, newdata = pdata, se.fit = TRUE) |> 
  as_tibble()

pdata = bind_cols(pdata, tmp)

ggplot(df1) + 
  geom_point(aes(x = Petal.Width,
                 y = Petal.Length,
                 color = Species)) +
  geom_ribbon(aes(x = Petal.Width,
                  ymin = exp(fit - se.fit),
                  ymax = exp(fit + se.fit),
                  fill = Species),
              data = pdata,
              alpha = 0.5) +
  geom_line(aes(x = Petal.Width,
                y = exp(fit),
                color = Species),
            data = pdata) 

# m4 と g4 の結果はほぼ同じでした。
# モデルの違い
# g4 = glm(Petal.Length ~ lpw * Species, data = df1, family = Gamma("log"))
# m4 = lm(lpl ~ lpw * Species, data = df1) # フルモデル
# 一般化線形モデルの場合、Gamma 分布とログリンク関数
# 一般線形モデル Petal.Length のログ変換
# 
# g4: eta    = lpw + species + lpw:species; 
#          y ~ Gamma(mu, theta); 
#          mu = exp(eta) # リンク関数
# m4: mu = lpw + species + lpw:species; 
# 　　log(y) ~ Normal(mu, error)
# https://gnishihara.github.io/kenkyushitsu-kaiseki/glm.html#一般化線形モデル


## 課題
## iris の Sepal.Length ~ Sepal.Width*Species の解析をしましょう。
## （１）lm() で当てはめてみる
## （２）glm() で当てはめてみる（family = Gamma("log")）
## どちらがいいか？
## 作成する図：
## 各モデルの診断図、
## 各モデルのモデルとデータの図
## 
## Script ファイルのファイル名に名前をいれて、天谷先生に提出する。
## 










