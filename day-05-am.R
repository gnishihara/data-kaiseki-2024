# 非線形モデル
# 2024-09-27
# Greg Nishihara

# パッケージの読み込み
library(tidyverse)
library(nlme)     # 非線形モデル用のパッケージ
library(nlstools) # 非線形モデルの補助パッケージ
library(ggpubr)
library(ggtext)
library(showtext)
library(magick)
library(patchwork)

# データの準備

df1 = CO2 |> as_tibble()

# データの確認

ggplot(df1) +
  geom_point(aes(x = conc, y = uptake)) + 
  facet_grid(rows = vars(Type),
             cols = vars(Treatment))

# 初期モデルあてはめ
ggplot(df1) + geom_point(aes(x = conc, y = uptake))

uptake_model = function(x, p1, p2, p3) {
  # p1 は切片
  # p2 は初期勾配
  # p3 は収束地
  p1 + p3 * (1 - exp(-p2/p3 * x))
}

# モデルの形を確認する
tibble(x = seq(0, 1, length = 11)) |> 
  mutate(y = uptake_model(x, p1 = 10, p2 = 50, p3 = 10)) |> 
  ggplot() + 
  geom_point(aes(x = x, y = y))

# preview() 非線形モデル用の係数の
# 初期値を決める
preview(uptake ~ uptake_model(x = conc,
                              p1 = p1, 
                              p2 = p2, 
                              p3 = p3),
        data = df1,
        start = list(p1 = 10,
                     p2 = 30/250,
                     p3 = 30),
        variable = 4)

# 実際のあてはめ

m1 = nls(uptake ~ uptake_model(x = conc,
                          p1 = p1, 
                          p2 = p2, 
                          p3 = p3),
    data = df1,
    start = list(p1 = 10, p2 = 30/250, p3 = 30))

summary(m1)

# Quebec, nonchilled
# Quebec, chilled
# Mississippi, nonchilled
# Mississippi, chilled

tmp = df1 |> 
  filter(str_detect(Type, "Que")) |> 
  filter(str_detect(Treatment, "nonchill"))

t1 = nls(uptake ~ uptake_model(x = conc,
                               p1 = p1, 
                               p2 = p2, 
                               p3 = p3),
         data = tmp,
         start = list(p1 = 10, p2 = 30/250, p3 = 30))

summary(t1)

# フルモデル (Treatment, Type ごとに係数を求める)

df1 = df1 |> 
  group_nest(Type, Treatment) |> 
  mutate(i = 1:4, .before = Type) |> 
  unnest(data)

m4 = nls(uptake ~ uptake_model(x = conc,
                          p1 = p1[i],
                          p2 = p2[i],
                          p3 = p3[i]),
    data = df1,
    start = list(p1 = rep(10, 4),
                 p2 = rep(30/250, 4),
                 p3 = rep(30, 4)))

summary(m4)

# モデル2（Treatment ごとの係数）
df1 = df1 |> 
  group_nest(Treatment) |> 
  mutate(j = 1:2) |> unnest(data)

m2 = nls(uptake ~ uptake_model(x = conc,
                               p1 = p1[j],
                               p2 = p2[j],
                               p3 = p3[j]),
         data = df1,
         start = list(p1 = rep(10, 2),
                      p2 = rep(30/250, 2),
                      p3 = rep(30, 2)))

summary(m2)

# モデル3（Type ごとの係数）
df1 = df1 |> 
  group_nest(Treatment) |> 
  mutate(k = 1:2) |> unnest(data)

m3 = nls(uptake ~ uptake_model(x = conc,
                               p1 = p1[k],
                               p2 = p2[k],
                               p3 = p3[k]),
         data = df1,
         start = list(p1 = rep(10, 2),
                      p2 = rep(30/250, 2),
                      p3 = rep(30, 2)))

summary(m3)


# モデル選択 ###############################################
AIC(m1, m2, m3, m4)

# モデル診断 ###############################################
df1 = df1 |> 
  mutate(residuals = residuals(m4),
         fit = predict(m4)) |> 
  mutate(stdresid = sqrt(abs(scale(residuals)[, 1])))

p1 = ggplot(df1) + geom_point(aes(x = fit, y = residuals))
p2 = ggplot(df1) + geom_point(aes(x = fit, y = stdresid))
p3 = ggplot(df1) + 
  geom_qq(aes(sample = residuals)) +
  geom_qq_line(aes(sample = residuals))

p1 + p2 + p3 + plot_layout(nrow = 2, ncol = 2)

# 結果について #############################################

summary(m4)

# 次のコードは非線形モデルの係数の結果をcsvファイルに保存する
csvname = "nls_coefficients.csv"
summary(m4)$coefficients |> 
  as_tibble(rownames = "coefficient") |> 
  write_csv(file = csvname)

# モデル用のデータ
pdata = 
  df1 |> 
  group_by(i, Type, Treatment) |> 
  expand(conc = seq(min(conc), max(conc), length = 21)) |> 
  ungroup()

# 非線形モデルなので、se.fit=Tはできない
fit = predict(m4, newdata = pdata)
pdata = pdata |> mutate(fit = fit)

ggplot(df1) + 
  geom_line(aes(x = conc, y = fit), 
            data = pdata) + 
  geom_point(aes(x = conc, y = uptake)) +
  facet_grid(rows = vars(Type),
             cols = vars(Treatment))

# 95% 信頼区間ありの図
m4boot = nlsBoot(m4, niter = 2000)
pdata = 
  df1 |> 
  group_by(i, Type, Treatment) |> 
  expand(conc = seq(min(conc), max(conc), length = 21)) |> 
  ungroup()

m4boot$coefboot |> as_tibble() # bootstrap から抽出した係数のサンプル
m4boot$estiboot |> as_tibble() # bootstrap から抽出した係数の平均値
m4boot$bootCI |> as_tibble()   # bootstrap から抽出した係数の95%CI

cfdata = m4boot$coefboot |> as_tibble() # bootstrap から抽出した係数のサンプル

cfdata = cfdata |> 
  mutate(n = 1:n(), .before = 1)

cfdata = cfdata |> 
  pivot_longer(cols = -n)

cfdata = cfdata |> 
  mutate(i = str_extract(name, "\\d{1}$")) |> 
  mutate(i = as.integer(i))

cfdata |> 
  group_nest(n, i)

pdata = pdata |> group_nest(i)
cfdata = cfdata |> group_nest(n, i, .key = "cf") 
pdata = full_join(pdata, cfdata, by = "i")

pdata2 = pdata |> 
  mutate(data = map2(data, cf, \(df, cf) {
    fit = uptake_model(x = df$conc,
                 p1 = cf$value[1],
                 p2 = cf$value[2],
                 p3 = cf$value[3])
    tibble(fit, conc = df$conc)
  })) 
pdata2 = pdata2 |> 
  select(i, data) |> 
  unnest(data) |> 
  group_by(i, conc) |> 
  summarise(mean = mean(fit),
            sd = sd(fit),
            n = length(fit), 
            .groups = "drop")
tmp = df1 |> 
  select(i, Type, Treatment) |> 
  distinct()

pdata2  = full_join(tmp, pdata2)

pdata2

# Bootstrap の平均値と１標準偏差
ggplot(df1) + 
  geom_ribbon(aes(x = conc, 
                  ymin = mean - sd,
                  ymax = mean + sd),
              data = pdata2,
              alpha = 0.5) +
  geom_line(aes(x = conc, y = mean), 
            data = pdata2) +
  geom_point(aes(x = conc, y = uptake)) +
  facet_grid(rows = vars(Type),
             cols = vars(Treatment))

# Bootstrap の平均値と95%信頼区間
ggplot(df1) + 
  geom_ribbon(aes(x = conc, 
                  ymin = mean - 1.96 * sd,
                  ymax = mean + 1.96 * sd),
              data = pdata2,
              alpha = 0.5) +
  geom_line(aes(x = conc, y = mean), 
            data = pdata2) +
  geom_point(aes(x = conc, y = uptake)) +
  facet_grid(rows = vars(Type),
             cols = vars(Treatment))




























