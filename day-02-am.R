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











