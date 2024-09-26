# 一般化加法モデル
# 2024-09-26
# Greg Nishihara


# パッケージの読み込み
library(MASS)  
library(mgcv)   # 一般化加法モデル用のパッケージ
library(gratia) # 一般化加法モデル用のパッケージ
library(tidyverse)
library(lubridate)
library(ggtext)
library(ggpubr)
library(showtext)
library(magick)
library(emmeans)
library(patchwork) # 図用の演算子
library(statmod) # ランダム化残渣の関数用

# フォントの読み込みとggplotの書式設定

font_add_google("Noto Sans", family = "ns")
theme_pubr(base_size = 10, base_family = "ns") |> theme_set()
showtext_auto()

# 参考文献
# https://peerj.com/articles/6876/
# Pedersen EJ, Miller DL, Simpson GL, Ross N. 2019. 
# Hierarchical generalized additive models in ecology: an
# introduction with mgcv. PeerJ 7:e6876
# https://doi.org/10.7717/peerj.6876

# データの準備

df1 = CO2 |> as_tibble()
# conc: CO2 濃度
# uptake: CO2吸収速度
# Plant, type, treatment  # 因子
# treatment: 前夜に低い温度を経験したか否か

# すべてのデータをまとめて表示する
ggplot(df1) + 
  geom_point(aes(x = conc, y = uptake, 
                 color = Plant)) 

# type と treatment 毎に表示する
ggplot(df1) + 
  geom_point(aes(x = conc, y = uptake, 
                 color = Plant)) +
  facet_grid(rows = vars(Treatment),
             cols = vars(Type))

# Generalized Additive Model (GAM) のあてはめ
# 全データをまとめて、モデルをあてはめている
m1 = gam(uptake ~ s(conc, k = 5, bs = "tp"), data = df1)
draw(m1) # gratia パッケージの関数
# s() スムーズの関数
#  第1引数は説明変数
#  k = 5 スムーズの基底の数
#  bs = "tp" スムーズの種類、このとき薄板平滑化スプライン

basis(m1) |> draw() # 基底毎の図


tmp = gam(uptake ~ s(conc, k = 3, bs = "tp"), data = df1)
draw(tmp, residuals = T)
basis(tmp) |> draw()

t1 = basis(tmp) |> filter(.bf == 1) |> pull(.value)
t2 = basis(tmp) |> filter(.bf == 2) |> pull(.value)
conc = basis(tmp) |> filter(.bf == 2) |> pull(conc)

tibble(conc, t1, t2) |> 
  ggplot() + 
  geom_line(aes( x= conc, y = t1, color = "basis 1")) +
  geom_line(aes( x= conc, y = t2, color = "basis 2")) +
  geom_line(aes( x= conc, y = t1 + t2, color = "basis 1 + 2"),
            linewidth = 2)

# スムーズ(の基底数をあげよう
df1 |> pull(conc) |> unique()

m3 = gam(uptake ~ s(conc, k = 3, bs = "tp"), data = df1)
m4 = gam(uptake ~ s(conc, k = 4, bs = "tp"), data = df1)
m5 = gam(uptake ~ s(conc, k = 5, bs = "tp"), data = df1)
m6 = gam(uptake ~ s(conc, k = 6, bs = "tp"), data = df1)
m7 = gam(uptake ~ s(conc, k = 7, bs = "tp"), data = df1)
# k = 3 から k = 5 にした場合、スムーズの形が変わる
# k = 5 から k - 7 にした場合、形の変化が小さい
draw(m3)
draw(m5)
draw(m7)

AIC(m3, m4, m5, m6, m7)

summary(m5)
# Parametric coefficients
# 
# Approximate signficance of smooth terms
# s(conc) F(3.442, 3.811) = 13.72; P <= 0.00001
# スムーズは重要

# R-sq (adj) = 0.388 # 当てはめの良さの指標
# Deviance explained = = 41.1% どの程度、データを説明しているのか

# type ごと解析 #######################################

ggplot(df1) + 
  geom_point(aes(x = conc, y = uptake)) +
  facet_wrap(vars(Type))

m0 = gam(uptake ~ s(conc, k = 7), data = df1)
m1 = gam(uptake ~ s(conc, k = 7, by = Type) + Type,
         data = df1)
summary(m1)

# Parametric coefficients:
#   Estimate Std. Error t value Pr(>|t|)    
#   (Intercept)      33.5429     0.7899   42.46   <2e-16 ***
#   TypeMississippi -12.6595     1.1171  -11.33   <2e-16 ***
# 
# Approximate significance of smooth terms:
#                             edf Ref.df      F  p-value    
#   s(conc):TypeQuebec      4.062  4.712 27.105  < 2e-16 ***
#   s(conc):TypeMississippi 3.081  3.683  9.558 1.02e-05 ***
# 
# R-sq.(adj) =  0.776   Deviance explained = 79.8%
# GCV = 29.407  Scale est. = 26.206    n = 84

draw(m1)

# 全データをプールした解析と
# Type 毎に解析したモデルの比較をすると：

AIC(m0, m1) # 低いほうがいい

m2 = gam(uptake ~ 
      s(conc, k = 7, by = Type) +
      s(conc, k = 7, by = Treatment) +
      Type + Treatment,
    data = df1)
draw(m2)

AIC(m0, m1, m2) # m2 がいい

m3 = gam(uptake ~ 
      s(conc, k = 7, by = Type) +
      s(conc, k = 7, by = Treatment) +
          Type * Treatment, 
    data = df1)
summary(m3)
draw(m3)
AIC(m0, m1, m2, m3)


pdata = df1 |> 
  expand(Type, Treatment,
         conc = seq(min(conc), max(conc), length = 21))
tmp = predict(m3, newdata = pdata, se.fit = T) |> as_tibble()

pdata = bind_cols(pdata, tmp)

ggplot() + 
  geom_line(aes(x = conc, y = fit),
            data = pdata) +
  geom_point(aes( x = conc, y = uptake),
             data = df1) + 
  facet_grid(rows = vars(Type),
             cols = vars(Treatment))

# m3 の診断図
  
df1 = df1 |> 
  mutate(residuals = residuals(m3),
         fit = predict(m3)) |> 
  mutate(stdresid = sqrt(abs(scale(residuals)[,1])))

p1 = ggplot(df1) + geom_point(aes(x = fit, y = residuals))
p2 = ggplot(df1) + geom_point(aes(x = fit, y = stdresid))
p3 = ggplot(df1) +
  geom_qq(aes(sample = residuals)) + 
  geom_qq_line(aes(sample = residuals))

p1 + p2 + p3 + plot_layout(ncol = 2, nrow = 2)
# 診断図に問題はなかった。m3 を採択しましょう

## 4日目の課題
# iris データの解析をする
# 作業仮設は、種毎の花弁の長さは、花弁の幅とがく弁長さと
# 幅関係がある。
# 解析には一般化線形モデルを用いる。
# （１）モデルの summary() を示す
# （２）診断図を確認する（診断図をファイルに保存）
# 提出物：スクリプトファイルと診断図の図。
# 提出物は天谷先生に送信してください.










