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

# データファイルを読み込む
alldata = tibble(fnames)
## read_csv() を fnames 変数に適応して、
## data 変数にcsvファイルのデータを tibble 
## として記録する。
alldata = alldata |> 
  mutate(data = map(fnames, read_csv))
## id 変数を追加する。
alldata = alldata |> 
  mutate(id = seq_along(fnames), 
         .before = fnames)
## fnames変数からファイルのパスを外す
## fnames 変数は上書きされる
alldata = alldata |> 
  mutate(fnames = basename(fnames))


