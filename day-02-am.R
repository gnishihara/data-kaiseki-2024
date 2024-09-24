# Castaway CTD データの解析
# 2024-09-24
# Greg Nishihara

# パッケージの読み込み

library(tidyverse)
library(lubridate) # 時刻データ処理

# CTDファイルの下６桁の番号が 005000 以下のものが
# ステーション１（桟橋の陸側）
# その他はステーション２（桟橋の先端）
# CTD の CSV ファイルは プロジェクトフォルダの
# Data フォルダの CTD_Dataset フォルダにいれましょう。

# データファイルのリスト作る
# here::here() が動かない場合、here パッケージをインストールしましょう
folder = here::here("Data/CTD_Dataset/") # データファイルへのパス
dir(folder) # フォルダ内のファイルのリストを返す

fnames = dir(folder, full.names = TRUE) # パスありリスト
fnames

# データの読み込み

df1 = read_csv(file = fnames[1])
df1
colnames(df1) # tibble の変数名

# 残す変数、
# Depth, Temperature, Salinity
df1 = df1 |> 
  select(Depth =  `Depth (Meter)`,
         Temperature = `Temperature (Celsius)`,
         Salinity = `Salinity (Practical Salinity Scale)`)

# そのほかのデータに読み込み
df2 = read_csv(file = fnames[2])
df3 = read_csv(file = fnames[3])
df4 = read_csv(file = fnames[4])
df5 = read_csv(file = fnames[5])
df6 = read_csv(file = fnames[6])
df7 = read_csv(file = fnames[7])
df8 = read_csv(file = fnames[8])
df9 = read_csv(file = fnames[9])
df10 = read_csv(file = fnames[10])
df11 = read_csv(file = fnames[11])
df12 = read_csv(file = fnames[12])

# read.csv() はベースRの関数 (data.frame) お勧めしません
# read_csv() はtidyverseの関数 (tibble)　使いましょう

df2 = df2 |> select(Depth =  `Depth (Meter)`, Temperature = `Temperature (Celsius)`, Salinity = `Salinity (Practical Salinity Scale)`)
df3 = df3 |> select(Depth =  `Depth (Meter)`, Temperature = `Temperature (Celsius)`, Salinity = `Salinity (Practical Salinity Scale)`)
df4 = df4 |> select(Depth =  `Depth (Meter)`, Temperature = `Temperature (Celsius)`, Salinity = `Salinity (Practical Salinity Scale)`)
df5 = df5 |> select(Depth =  `Depth (Meter)`, Temperature = `Temperature (Celsius)`, Salinity = `Salinity (Practical Salinity Scale)`)
df6 = df6 |> select(Depth =  `Depth (Meter)`, Temperature = `Temperature (Celsius)`, Salinity = `Salinity (Practical Salinity Scale)`)
df7 = df7 |> select(Depth =  `Depth (Meter)`, Temperature = `Temperature (Celsius)`, Salinity = `Salinity (Practical Salinity Scale)`)
df8 = df8 |> select(Depth =  `Depth (Meter)`, Temperature = `Temperature (Celsius)`, Salinity = `Salinity (Practical Salinity Scale)`)
df9 = df9 |> select(Depth =  `Depth (Meter)`, Temperature = `Temperature (Celsius)`, Salinity = `Salinity (Practical Salinity Scale)`)
df10 = df10 |> select(Depth =  `Depth (Meter)`, Temperature = `Temperature (Celsius)`, Salinity = `Salinity (Practical Salinity Scale)`)
df11 = df11 |> select(Depth =  `Depth (Meter)`, Temperature = `Temperature (Celsius)`, Salinity = `Salinity (Practical Salinity Scale)`)
df12 = df12 |> select(Depth =  `Depth (Meter)`, Temperature = `Temperature (Celsius)`, Salinity = `Salinity (Practical Salinity Scale)`)

# 全データ用のtibble を作る
id = 1:12
station = rep(c("桟橋手前", "桟橋先端"), each = 6)
alldata = tibble(id, station)
# ファイル名を追加する

alldata = alldata |> 
  mutate(fnames = dir(folder))

alldata = alldata |> 
  separate(fnames, sep = "_", 
           into = c("ctd", "date", "time"))
# ymd() は lubridate の関数
# 年月日のデータ処理
alldata = 
  alldata |> 
  select(id, station, date) |> 
  mutate(date = ymd(date))

c(2, 4, 5) # 実数のベクトル
list(df1, df2, df3) # tibble のベクトル

alldata = 
  alldata |> 
  mutate(data = list(df1, df2, df3, df4, 
                     df5, df6, df7, df8, 
                     df9, df10, df11, df12))
alldata

# tibble-list の展開

alldata = alldata |> unnest(data)
alldata

# 水温の鉛直分布の図

ggplot(alldata) + 
  geom_line(aes(x = Depth, y = Temperature, color = id))

# 鉛直分布なので、縦は推進、横は水温、idは因子
# id を因子にする (<fct>) factor 
alldata = alldata |> mutate(id = factor(id))

ggplot(alldata) + 
  geom_line(aes(x = Temperature,
                y = Depth,
                color = id))

ggplot(alldata) + 
  geom_point(aes(x = Temperature,
                y = Depth,
                color = id))

# 水深が 0.500 m 以上のものを使う
alldata = alldata |> filter(Depth > 0.500)

# geom_line() は x軸の順序によって作図
ggplot(alldata) + 
  geom_line(aes(x = Temperature,
                y = Depth,
                color = id))
# geom_path() は tibble のデータの順序によって作図される
ggplot(alldata) + 
  geom_path(aes(x = Temperature,
                y = Depth,
                color = id)) +
  scale_y_continuous(trans = "reverse")

