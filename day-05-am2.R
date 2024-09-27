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


m0 = glm(length ~ 1, data = df1)
m1 = glm(length ~ width , data = df1)
m2 = glm(length ~ class, data = df1)
m3 = glm(length ~ width + class, data = df1)
m4 = glm(length ~ width * class, data = df1)
AIC(m0, m1, m2, m3, m4)

m3

df1 = df1 |> mutate(residuals = residuals(m3),
              fit = predict(m3),
              stdresid = sqrt(abs(scale(residuals)[,1])))


p1 = ggplot(df1) + geom_point(aes(x = fit, y = residuals))
p2 = ggplot(df1) + geom_point(aes(x = fit, y = stdresid))
p3 = ggplot(df1) + 
  geom_qq(aes(sample = residuals)) +
  geom_qq_line(aes(sample = residuals))

p1 + p2 + p3 + plot_layout(nrow = 2, ncol = 2)

#


m0 = glm(length ~ 1, data = df1, family = Gamma("log"))
m1 = glm(length ~ width , data = df1, family = Gamma("log"))
m2 = glm(length ~ class, data = df1, family = Gamma("log"))
m3 = glm(length ~ width + class, data = df1, family = Gamma("log"))
m4 = glm(length ~ width * class, data = df1, family = Gamma("log"))
AIC(m0, m1, m2, m3, m4)
m4

df1 = df1 |> mutate(residuals = statmod::qresiduals(m4),
                    fit = predict(m4),
                    stdresid = sqrt(abs(scale(residuals)[,1])))


p1 = ggplot(df1) + geom_point(aes(x = fit, y = residuals))
p2 = ggplot(df1) + geom_point(aes(x = fit, y = stdresid))
p3 = ggplot(df1) + 
  geom_qq(aes(sample = residuals)) +
  geom_qq_line(aes(sample = residuals))

p1 + p2 + p3 + plot_layout(nrow = 2, ncol = 2)






