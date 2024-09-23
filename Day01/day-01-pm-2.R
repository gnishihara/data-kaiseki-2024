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
# ggsave() を使って図を保存する
# pdf, png, jpeg, svg, tiff, などの種類
# width, height は図の寸法
# units は寸法の単位
# dpi は解像度、ポスター用は900、パワーポイント用は300

# エラーバー付き
# エラーバーは１標準偏差を示す
ytitle = "Mean total length (cm)"
ggplot(df2) + 
  geom_point(aes(x = Sex, y = mean, color = Sex)) +
  geom_errorbar(aes(x = Sex,
                    ymin = mean - sd,
                    ymax = mean + sd,
                    color = Sex),
                width = 0.05) +
  scale_y_continuous(name = ytitle,
                     limits = c(150, 350)) +
  guides(color = "none")
# guides() で凡例を外す

pngfile = "fish_mean_length_errorbar.png"
ggsave(filename = pngfile,
       width = 80,
       height = 80,
       dpi = 300,
       units = "mm")


# BW Body weight のエラーバー付き散布図を作図

df3 = 
  df1 |> 
  filter(str_detect(variable, "^BW")) # 正規表現 (regular expression)
df3

ytitle = "Mean body weight (g)"
ggplot(df3) + 
  geom_point(aes(x = Sex, y = mean, color = Sex)) +
  geom_errorbar(aes(x = Sex,
                    ymin = mean - sd,
                    ymax = mean + sd,
                    color = Sex),
                width = 0.05) +
  scale_y_continuous(name = ytitle,
                     limits = c(0, 400)) +
  guides(color = "none")





