# 一般化線形モデル
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