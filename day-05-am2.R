# 守岡くんのデータの再解析
# GLM を用いた解説
# 2024-09-27
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
  geom_boxplot(aes(x = class, y = length))


ggplot(df1) + 
  geom_point(aes(x = width, y = length,
                 color = class))

# 正規分布を仮定してい glm あてはめた ######################
m0 = glm(length ~ 1, data = df1)
m1 = glm(length ~ width , data = df1)
m2 = glm(length ~ class, data = df1)
m3 = glm(length ~ width + class, data = df1)
m4 = glm(length ~ width * class, data = df1)
AIC(m0, m1, m2, m3, m4)

m3 # AIC が最も低い

df1 = df1 |> mutate(residuals = residuals(m3),
              fit = predict(m3),
              stdresid = sqrt(abs(scale(residuals)[,1])))

# 診断図を確認する
p1 = ggplot(df1) + geom_point(aes(x = fit, y = residuals))
p2 = ggplot(df1) + geom_point(aes(x = fit, y = stdresid))
p3 = ggplot(df1) + 
  geom_qq(aes(sample = residuals)) +
  geom_qq_line(aes(sample = residuals))

p1 + p2 + p3 + plot_layout(nrow = 2, ncol = 2)

# 正規分布が適していないので、ガンマ分布をためす。
# 


m0 = glm(length ~ 1, data = df1, family = Gamma("log"))
m1 = glm(length ~ width , data = df1, family = Gamma("log"))
m2 = glm(length ~ class, data = df1, family = Gamma("log"))
m3 = glm(length ~ width + class, data = df1, family = Gamma("log"))
m4 = glm(length ~ width * class, data = df1, family = Gamma("log"))
AIC(m0, m1, m2, m3, m4)

m4　# AIC がもっとも低い

m4_gamma = m4

df1 = df1 |> mutate(residuals = statmod::qresiduals(m4),
                    fit = predict(m4),
                    stdresid = sqrt(abs(scale(residuals)[,1])))


p1 = ggplot(df1) + geom_point(aes(x = fit, y = residuals))
p2 = ggplot(df1) + geom_point(aes(x = fit, y = stdresid))
p3 = ggplot(df1) + 
  geom_qq(aes(sample = residuals)) +
  geom_qq_line(aes(sample = residuals))

p1 + p2 + p3 + plot_layout(nrow = 2, ncol = 2)





# width と length のログ変換解析

ggplot(df1) + 
  geom_point(aes(x = log(width), y = log(length),
                 color = class))



# 正規分布を仮定してい glm あてはめた ######################

df1 = df1 |> 
  mutate(logL = log(length),
         logW = log(width))

m0 = glm(logL ~ 1, data = df1)
m1 = glm(logL ~ logW , data = df1)
m2 = glm(logL ~ class, data = df1)
m3 = glm(logL ~ logW + class, data = df1)
m4 = glm(logL ~ logW * class, data = df1)
AIC(m0, m1, m2, m3, m4)

m3 # AIC が最も低い
m3_loglog = m3
df1 = df1 |> mutate(residuals = residuals(m3),
                    fit = predict(m3),
                    stdresid = sqrt(abs(scale(residuals)[,1])))

# 診断図を確認する
p1 = ggplot(df1) + geom_point(aes(x = fit, y = residuals))
p2 = ggplot(df1) + geom_point(aes(x = fit, y = stdresid))
p3 = ggplot(df1) + 
  geom_qq(aes(sample = residuals)) +
  geom_qq_line(aes(sample = residuals))

p1 + p2 + p3 + plot_layout(nrow = 2, ncol = 2)


m3
m4_gamma
AIC(m3, m4_gamma)  # m3

summary(m3)



# Gamma分布、logW のモデル

m0 = glm(length ~ 1, data = df1, family = Gamma("log"))
m1 = glm(length ~ logW , data = df1, family = Gamma("log"))
m2 = glm(length ~ class, data = df1, family = Gamma("log"))
m3 = glm(length ~ logW + class, data = df1, family = Gamma("log"))
m4 = glm(length ~ logW * class, data = df1, family = Gamma("log"))
AIC(m0, m1, m2, m3, m4)

m3　# AIC がもっとも低い

m3_gamma_logW = m3

df1 = df1 |> mutate(residuals = statmod::qresiduals(m3_gamma_logW),
                    fit = predict(m3_gamma_logW),
                    stdresid = sqrt(abs(scale(residuals)[,1])))


p1 = ggplot(df1) + geom_point(aes(x = fit, y = residuals))
p2 = ggplot(df1) + geom_point(aes(x = fit, y = stdresid))
p3 = ggplot(df1) + 
  geom_qq(aes(sample = residuals)) +
  geom_qq_line(aes(sample = residuals))

p1 + p2 + p3 + plot_layout(nrow = 2, ncol = 2)


AIC(m3_loglog, m4_gamma, m3_gamma_logW)  # m3_loglog のAICがもっとも低いのです、採択する

summary(m3_loglog)
