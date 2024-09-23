# Rパッケージのインストールと読み込み
# 2024-09-23
# Greg Nishihara

# パッケージは１回だけインストールすればいい
# install.packages("tidyverse") # コードからインストール

# パッケージの読み込み
# この作業は必ず最初にすること

library(tidyverse) # tidyverse はメタパッケージ：複数のパッケージを読み込む

# データを作る

fish_size = rpois(n = 10, lambda = 200) # ポアソン分布の疑似乱数関数
fish_id = seq(from = 1, to = 10, by = 1)
fish_loc = rep(c("A", "B"), each = 5)
fish_data = tibble(fish_loc, fish_id, fish_size)
# <chr>: character, 文字列
# <dbl>: double, 実数
# <int>: integer, 整数
fish_data

# tidyverse におけるデータの抽出
# |> CTRL + SHIFT + M パイプ演算子
# %>% もパイプ演算子

fish_data |> pull(fish_loc) # pull() は tibble の変数を返す
fish_data$fish_loc # 28と同じ

x = fish_data |> pull(fish_id)
x

# tibble のデータ操作
# mutate() は新しい変数を作ってくれる
fish_data = 
  fish_data |> 
  mutate(fish_size2 = fish_size / 100)
fish_data

fish_data = 
  fish_data |> 
  mutate(
    fs = fish_size2^2,
    invfs = 1 / fs
  )

fish_data


