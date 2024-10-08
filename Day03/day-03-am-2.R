#' ---
#' title: データ紹介（守岡）
#' date: 2024-09-25
#' 
#' author: Greg Nishihara
#'---

#' # パッケージの読み込み

library(tidyverse)
library(lubridate)
library(showtext)
library(ggtext)
library(ggpubr)
library(readxl)

#' 作図の準備

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


#+ fig.width = 3, fig.height=3, fig.cap = "種毎の体調と幅" 
ggplot(df1) + 
  geom_point(aes(x = width, y = length,
                 color = class))

#' S と M ごとの記述統計量
#' class でグループ化して
#' length と width をまたいで、
#' 平均値、中央値、最小値、最大値、標準偏差、データ数
#' を求める。
#' pivot_longer() で、length と width にマッチした
#' 変数を縦に回転して、_ を区切りにして, 変数名を分解する。
#' 分解した変数は variable と statistic にする。
#' pivot_wider() で、statistic の変数に記録した情報を
#' 変数に展開して、valueを変数の値にする

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

# 上と同じ結果
# ここでは、先にデータを回転する
df1 |> 
  pivot_longer(cols = matches("length|width")) |> 
  group_by(class, name) |> 
  summarise(
    across(c(value),
           list(m = mean,
                median = median,
                min = min,
                max = max,
                s = sd,
                n = length)),
    .groups = "drop"
  )


df1 |> 
  pivot_longer(cols = matches("length|width")) |> 
  group_by(class, name) |> 
  summarise(
    mean = mean(value),
    median = median(value),
    min = min(value),
    max = max(value),
    sd = sd(value),
    n = length(value),
    .groups = "drop"
  ) |> 
  mutate(se = sd / sqrt(n - 1))

# ちょっとした解析

# t検定 2 標本を比べたいときに使います。
# length が応答変数
# class が説明変数
# モデルの組み方：応答変数～説明変数

# デフォルトはウェルチのt検定
t.test(length ~ class, data = df1)
# 帰無仮説：class による length の違いはない
# t = 9.4224 # t値
# df = 95.723 # 自由度
# p-value = 2.657e-15 # p値
# 優位水準が 0.05 の場合、
# P <= 0.05 なので、帰無仮説を棄却します。
# 帰無仮説を棄却できたので、
# 違いはあると考察できる。

t.test(width ~ class, data = df1)

#' 二種の藻類の幅のｔ検定を実施した。
#' 帰無仮説は class による width の違いはないである。
#' この解析の t値は 6.3394 と  
#' 自由度は　95.135だった (P <= 0.05)。
#' 優位水準が 0.05 の場合、
#' 帰無仮説は棄却できる。






