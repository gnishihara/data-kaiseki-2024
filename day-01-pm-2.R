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
ggsave(filename = pngfile,
       width = 80,
       height = 80,
       units = "mm")


# 凡例の場所を調整する

ytitle = "Mean total length (cm)"
ggplot(df2) +
  geom_col(aes(x = Sex, y = mean , fill = Sex)) +
  scale_y_continuous(name = ytitle) +
  theme(
    legend.position = "inside",
    legend.position.inside = c(0.25, 0.85),
    legend.title = element_blank()
  )

pngfile = "fish_mean_total_length.png"  
ggsave(filename = pngfile,
       width = 80,
       height = 80,
       dpi = 300,
       units = "mm")


