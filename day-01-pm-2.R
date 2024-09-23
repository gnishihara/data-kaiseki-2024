# シキシマハナダイの記述統計量結果
# 2024-09-23
# Greg Nishihara

# パッケージの読み込み
library(tidyverse)
library(readxl)

# CSVファイルの読み込み

fname = "シキシマハナダイ_記述統計量.csv"
df1 = read_csv(fname)
df1

# Sex　毎の平均TLの図
# filter() を用いて、TLに関係するデータを抽出する

df2 = 
  df1 |> 
  filter(str_detect(variable, "TL"))
df2

# ggplot ：作図
# 棒グラフ

ggplot(df2) +
  geom_col(aes(x = Sex, y = mean))

ggplot(df2) +
  geom_col(aes(x = Sex, y = mean , color = Sex))

ggplot(df2) +
  geom_col(aes(x = Sex, y = mean , fill = Sex))

ytitle = "Mean total length (cm)"
ggplot(df2) +
  geom_col(aes(x = Sex, y = mean , fill = Sex)) +
  scale_y_continuous(name = ytitle)

pngfile = "fish_mean_total_length.png"  
ggsave(filename = pngname,
       width = 80,
       height = 80,
       units = "mm")



