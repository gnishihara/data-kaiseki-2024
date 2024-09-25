# 多重比較の紹介
# 2024-09-25
# Greg Nishihara


# パッケージの読み込み
# github のリンク https://github.com/gnishihara/data-kaiseki-2024

library(tidyverse) # tidyverse
library(lubridate) # 日時データの処理
library(emmeans)   # 多重比較
library(ggtext)    # ggplot にマークダウンを使う

# install.packages("palmerpenguins")

# 3種のアヤメ(Iris setosa, Iris versicolor, Iris virginica)

df1 = iris |> as_tibble()

df1
# 作図して、データを可視化する
ggplot(df1) + 
  geom_point(aes(x = Petal.Width,
                 y = Petal.Length,
                 color = Species))


# 作業仮設：種によって花弁の長さは異なる
# 帰無仮説：種による花弁の長さは等しい（または、同じである）

# t検定を利用
# このとき、すべて種の組み合わせによる違いを検討する
# setosa vs versicolor (t12)
# setosa vs virginica (t13)
# versicolor vs virginica (t23)
# t検定の関数は t.test()

filter(df1, !str_detect(Species, "virginica"))

t12 = t.test(Petal.Length ~ Species,
       data = filter(df1, !str_detect(Species, "virginica")))

t13 = t.test(Petal.Length ~ Species,
             data = filter(df1, !str_detect(Species, "versicolor")))

t23 = t.test(Petal.Length ~ Species,
             data = filter(df1, !str_detect(Species, "setosa")))

t12 # t値 (-39.49), 自由度 (62.14), p値 (<2.2e-16)
t13
t23
# 一つの作業仮設にたいして、t検定を複数回すると、
# 第１種の誤りを起こしやすい。
# ３回比較した場合、第１誤り = (1-(1-0.05)^3)
(1-(1-0.05)^3)


# 数種類の因子の影響を見たいとき、分散分析

m1 = lm(Petal.Length ~ Species, data = df1)
summary.aov(m1) # 一元配置分散分析
emmeans(m1, specs = 'pairwise'~Species) # デフォルトは TukeyHSD 法
emmeans(m1, specs = 'pairwise'~Species, # ボンフェロニー法
        adjust = "bonferroni")

# 二元配置分散分析
# species, island, sex が因子
# bill_length_mm, bill_depth_mm, flipper_length_mm,
# body_mass_g, year
# 作業仮設：Species と Sex によって body mass は異なる
# 帰無仮説：
#   Species による効果はない
#   Sex による効果はない
#   Species と Sex による効果はない
 
df2 = palmerpenguins::penguins

ggplot(df2) + 
  geom_point(aes(x = species,
                 y = body_mass_g, 
                 color = sex),
             position = position_jitterdodge(jitter.width = 0.1,
                                             dodge.width = 0.3))
df2 = df2 |> drop_na() # NA を解析データから外す
m0 = lm(body_mass_g ~ 1, data = df2) # 帰無モデル
m1 = lm(body_mass_g ~ species, data = df2) # species に対するモデル
m2 = lm(body_mass_g ~ sex, data = df2) # sex に対するモデル
m3 = lm(body_mass_g ~ species + sex, data = df2) # species + sex に対するモデル
m4 = lm(body_mass_g ~ species + sex + species:sex, data = df2) # フルモデル（相互作用項あり）
# 相互作用は species:sex です。
# AIC (Akaike Information Criterion)
# 一番低いAICがもっともいいモデル
AIC(m0, m1, m2, m3, m4)

summary.aov(m4) # 分散分析表
# すべての効果のP値は 0.05 より引くい

# 分散分析の仮定
# （１）残渣は独立して同分布に従う
# （２）残渣は正規分布に従う
# （３）残渣の分散は等しい

# モデル診断図を確認して、分散分析の仮定が守られているかを
# 評価する
plot(m4, which = 1) # 残渣対期待値の図
plot(m4, which = 3) # 標準化残渣対期待値の図
plot(m4, which = 2) # 正規性の確認(QQplot)
# 診断図に問題はなかったので、m4 モデルを採択する

# m4 を用いた多重比較
# Species 内の sex 毎の多重比較
emmeans(m4, 
        specs = 'pairwise' ~ sex,
        by = "species", adjust = "bonferonni")
# Sex 内の Species 毎の多重比較
emmeans(m4, 
        specs = 'pairwise' ~ species,
        by = "sex", adjust = "bonferroni")

# すべての組み合わせのペア事比較 
# ナンセンスですので、普段はしません。
emmeans(m4, specs = 'pairwise' ~ species:sex)





