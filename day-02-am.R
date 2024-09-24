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
dir(folder)


