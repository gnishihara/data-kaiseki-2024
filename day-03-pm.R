# 多重比較の紹介
# 2024-09-25
# Greg Nishihara


# パッケージの読み込み
# github のリンク https://github.com/gnishihara/data-kaiseki-2024

library(tidyverse) # tidyverse
library(lubridate) # 日時データの処理
library(emmeans)   # 多重比較
library(ggtext)    # ggplot にマークダウンを使う

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

t12


