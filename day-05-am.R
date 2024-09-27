# 非線形モデル
# 2024-09-27
# Greg Nishihara

# パッケージの読み込み
library(tidyverse)
library(nlme)     # 非線形モデル用のパッケージ
library(nlstools) # 非線形モデルの補助パッケージ
library(ggpubr)
library(ggtext)
library(showtext)
library(magick)

# データの準備

df1 = CO2 |> as_tibble()

# データの確認

ggplot(df1) +
  geom_point(aes(x = conc, y = uptake)) + 
  facet_grid(rows = vars(Type),
             cols = vars(Treatment))

# 初期モデルあてはめ
ggplot(df1) + geom_point(aes(x = conc, y = uptake))

uptake_model = function(x, p1, p2, p3) {
  # p1 は切片
  # p2 は初期勾配
  # p3 は収束地
  p1 + p3 * (1 - exp(-p2/p3 * x))
}

# モデルの形を確認する
tibble(x = seq(0, 1, length = 11)) |> 
  mutate(y = uptake_model(x, p1 = 10, p2 = 50, p3 = 10)) |> 
  ggplot() + 
  geom_point(aes(x = x, y = y))

# preview() 非線形モデル用の係数の
# 初期値を決める
preview(uptake ~ uptake_model(x = conc,
                              p1 = p1, 
                              p2 = p2, 
                              p3 = p3),
        data = df1,
        start = list(p1 = 10,
                     p2 = 30/250,
                     p3 = 30),
        variable = 4)

# 実際のあてはめ

m1 = nls(uptake ~ uptake_model(x = conc,
                          p1 = p1, 
                          p2 = p2, 
                          p3 = p3),
    data = df1,
    start = list(p1 = 10, p2 = 30/250, p3 = 30))

summary(m1)

# Quebec, nonchilled
# Quebec, chilled
# Mississippi, nonchilled
# Mississippi, chilled

tmp = df1 |> 
  filter(str_detect(Type, "Que")) |> 
  filter(str_detect(Treatment, "nonchill"))

t1 = nls(uptake ~ uptake_model(x = conc,
                               p1 = p1, 
                               p2 = p2, 
                               p3 = p3),
         data = tmp,
         start = list(p1 = 10, p2 = 30/250, p3 = 30))

summary(t1)

# フルモデル (Treatment, Type ごとに係数を求める)

df1 = df1 |> 
  group_nest(Type, Treatment) |> 
  mutate(i = 1:4, .before = Type) |> 
  unnest(data)

m2 = nls(uptake ~ uptake_model(x = conc,
                          p1 = p1[i],
                          p2 = p2[i],
                          p3 = p3[i]),
    data = df1,
    start = list(p1 = rep(10, 4),
                 p2 = rep(30/250, 4),
                 p3 = rep(30, 4)))

summary(m2)

# モデル2（Treatment ごとの係数）
df1 = df1 |> 
  group_nest(Treatment) |> 
  mutate(j = 1:2) |> unnest(data)

m2 = nls(uptake ~ uptake_model(x = conc,
                               p1 = p1[j],
                               p2 = p2[j],
                               p3 = p3[j]),
         data = df1,
         start = list(p1 = rep(10, 2),
                      p2 = rep(30/250, 2),
                      p3 = rep(30, 2)))

summary(m2)

# モデル3（Type ごとの係数）























