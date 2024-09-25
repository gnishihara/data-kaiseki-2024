# 一般化線形モデル
# iris Sepal.Length ~ Sepal.Width * Species モデル解析
# 2024-09-25
# Greg Nishihara
# 

# Read packages
library(tidyverse)
library(emmeans)
library(statmod)

df1 = iris |> as_tibble()
ggplot(df1) + geom_point(aes(x = Sepal.Width, y = Sepal.Length, color = Species))

# Model definitions

m0 = lm(Sepal.Length ~ 1, data = df1)
m1 = lm(Sepal.Length ~ Species, data = df1)
m2 = lm(Sepal.Length ~ Sepal.Width, data = df1)
m3 = lm(Sepal.Length ~ Sepal.Width + Species, data = df1)
m4 = lm(Sepal.Length ~ Sepal.Width * Species, data = df1)
g0 = glm(Sepal.Length ~ 1, data = df1, family = Gamma("log"))
g1 = glm(Sepal.Length ~ Species, data = df1, family = Gamma("log"))
g2 = glm(Sepal.Length ~ Sepal.Width, data = df1, family = Gamma("log"))
g3 = glm(Sepal.Length ~ Sepal.Width + Species, data = df1, family = Gamma("log"))
g4 = glm(Sepal.Length ~ Sepal.Width * Species, data = df1, family = Gamma("log"))

AIC(m0, m1, m2, m3, m4) # Choose model m3
AIC(g0, g1, g2, g3, g4) # Choose model g3

# Diagnostic plots #########################################
# lm() diagnostic plots
plot(m3, which = 1) # Residual vs Fitted
plot(m3, which = 3) # Standardized residuals vs Fitted
plot(m3, which = 2) # QQ plot

# glm() diagnostic plots

df1 = df1 |> 
  mutate(qresid = qresiduals(g3),
         fit = predict(g3)) |> 
  mutate(stdqresid = sqrt(abs(scale(qresid)[,1])))

ggplot(df1) + geom_point(aes(x = fit, y = qresid))
ggplot(df1) + geom_point(aes(x = fit, y = stdqresid))
ggplot(df1) + 
  geom_qq(aes(sample = qresid)) + 
  geom_qq_line(aes(sample = qresid))

# Data and model plot ######################################
pdata = df1 |> 
  group_by(Species) |> 
  expand(Sepal.Width = seq(min(Sepal.Width), 
                           max(Sepal.Width), 
                           length = 21))

tmp1 = predict(m3, newdata = pdata, se.fit = TRUE)
tmp2 = predict(g3, newdata = pdata, se.fit = TRUE)

pdata_m = bind_cols(pdata, tmp1)
pdata_g = bind_cols(pdata, tmp2)


ggplot(df1) + 
  geom_point(aes(x = Sepal.Width, y = Sepal.Length, color = Species)) +
  geom_ribbon(aes(x = Sepal.Width,
                  ymin = fit - se.fit,
                  ymax = fit + se.fit,
                  fill = Species), 
              data = pdata_m,
              alpha = 0.5) +
  geom_line(aes(x = Sepal.Width, y = fit, color = Species),
            data = pdata_m)


ggplot(df1) + 
  geom_point(aes(x = Sepal.Width, y = Sepal.Length, color = Species)) +
  geom_ribbon(aes(x = Sepal.Width,
                  ymin = exp(fit - se.fit),
                  ymax = exp(fit + se.fit),
                  fill = Species), 
              data = pdata_g,
              alpha = 0.5) +
  geom_line(aes(x = Sepal.Width, y = exp(fit), color = Species),
            data = pdata_g)


