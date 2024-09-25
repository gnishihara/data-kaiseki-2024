# データ紹介（守岡）
# 2024-09-25
# 
# Greg Nishihara

# パッケージの読み込み

library(tidyverse)
library(lubridate)
library(showtext)
library(ggtext)
library(ggpubr)
library(readxl)

# 作図の準備
font_add_google("Noto Sans JP", family = "notosansjp")
theme_pubr(base_size = 10,
           base_family = "notosansjp") |> 
  theme_set()
showtext_auto()

# データの読み込み
# length: mm
# width: mm
# class: s, m (種の表記)
fname = "Data/Morioka/海藻データ集め R用.xlsx"
sheets = excel_sheets(fname) # 2番目のシートを使う
df1 = read_xlsx(fname, sheet = sheets[2])

df1 = df1 |> 
  select(length = matches("Length"),
         width = matches("width"),
         class,
         id = matches("元番"))

ggplot(df1) + 
  geom_point(aes(x = class, y = length))

ggplot(df1) + 
  geom_point(aes(x = width, y = length,
                 color = class))

# S と M ごとの記述統計量

df1 |> 
  group_by(class) |> 
  summarise(
    across(c(length, width),
           list(m = mean,
                median = median,
                min = min,
                max = max,
                s = sd,
                n = length))
  ) |> 
  pivot_longer(cols = matches("length|width"),
               names_sep = "_",
               names_to = c("variable", "statistic")) |> 
  pivot_wider(names_from = statistic,
              values_from = value)




