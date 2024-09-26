# 4日目の課題
# 2024-09-26
# Greg Nishihara

library(tidyverse)
library(emmeans)
library(ggpubr)
library(ggtext)
library(showtext)
library(magick)
library(emmeans)

df1 = iris |> as_tibble()

# 作業仮設：種毎の花弁の長さは、花弁の幅とがく弁長さと
# 幅関係がある。
# 帰無仮説：
# (1) 種毎の花弁の長さは花弁の幅と関係ない
# (2) 種毎の花弁の長さはがく弁の長さと関係ない
# (3) 種毎の花弁の長さはがく弁の幅と関係ない
m1 = glm(Petal.Length ~ 
           (Petal.Width + Sepal.Length + Sepal.Width) *
           Species, data = df1)
summary(m1)

emtrends(m1, "pairwise" ~ Species, var = "Petal.Width", adjust = "bonferroni")
# Petal.Width の場合、versicolor - virginica の比較だけ
# が統計学的に有意だった
emtrends(m1, "pairwise" ~ Species, var = "Sepal.Length",
         adjust = "bonferroni")
# Sepal.Length の場合、setosa - virginica 
# と versicolor - virginica の違いは統計学的に有意だった。
emtrends(m1, "pairwise" ~ Species, var = "Sepal.Width",
         adjust = "bonferroni")
# Sepal.Width の場合、統計学的な有意差はなかった

df1 = df1 |> 
  mutate(residuals = residuals(m1),
         fit = predict(m1)) |> 
  mutate(stdresid = sqrt(abs(scale(residuals)[,1])))

p1 = ggplot(df1)+ geom_point(aes(x = fit, y = residuals))
p2 = ggplot(df1)+ geom_point(aes(x = fit, y = stdresid))
p3 = ggplot(df1) + geom_qq(aes(sample = residuals)) +
  geom_qq_line(aes(sample = residuals))

p1 + p2 + p3 + plot_layout(ncol = 2, nrow = 2)

pdfname = "day-04-homework-診断図-gregnishihara.pdf"
pngname = str_replace(pdfname, "pdf", "png")
ggsave(pdfname, width = 160, height = 160, units = "mm")
img = image_read_pdf(pdfname, density = 300)
img |> image_write(pngname)



