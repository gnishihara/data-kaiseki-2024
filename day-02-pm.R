# Castaway CTD データの解析
# 2024-09-24
# Greg Nishihara

# パッケージの読み込み

library(tidyverse)
library(lubridate) # 時刻データ処理

# CTDファイルの下６桁の番号が 005000 以下のものが
# ステーション１（桟橋手前）
# その他はステーション２（桟橋先端）
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
## 正規表現を用いて、文字列から情報を抽出する
## \\d は数字
## \\d{8} 数字８連続抽出 
## _\\d{6}. _123456. <-このどっとはすべての文字にマッチする
## _\\d{6}\\. <- \\. は . だけにマッチする 
## (?<=_)\\d{6}(?=\\.) ６桁の数字の前に _ がる存在する条件と
## 数字のあとに . が存在する条件を満たせば、抽出する。

alldata = alldata |> 
  mutate(date = str_extract(fnames, pattern = "\\d{8}"),
         .after = id) |> 
  mutate(time = str_extract(fnames, pattern = "(?<=_)\\d{6}(?=\\.)"), 
         .before = date) |> 
  select(-fnames)

alldata = alldata |> 
  mutate(datetime = str_c(date, " ", time),
         .after = id) |> 
  mutate(datetime = ymd_hms(datetime)) |> 
  select(-date, -time)
# case_when() 条件を満たしたら ～ の右辺を返す

alldata = alldata  |> 
  mutate(location = 
           case_when(datetime <  ymd_hm("2024-09-24 00:50") ~ "手前",
                     datetime >= ymd_hm("2024-09-24 00:50") ~ "先端"),
         .after = id)

# alldata の data　を展開する
# matches() に渡すパターンは正規表現
alldata = alldata  |> 
  unnest(data) |> 
  select(id, location, 
         depth = matches("^Depth"),
         temperature = matches("^Temp"),
         salinity = matches("^Sali"))
# id と location を因子に変換する
alldata = alldata |> 
  mutate(id = factor(id),
         location = factor(location))

# Output はフォルダ名、Files パネルの New Folder アイコンを
# クリックして作ります。

csvfname = "Output/CTD_dataset.csv"
write_csv(alldata, file = csvfname)

## 作図

# ID ごとのプロット

ytitle = "Depth (m)"
ggplot(alldata) +
  geom_path(aes( x = temperature, y = depth, color = id)) +
  scale_y_continuous(name = ytitle,
                     limits = c(18, 0),
                     breaks = c(18, 9, 0),
                     trans = "reverse")

# location でわける
xtitle = "Temperature (℃)"
ytitle = "Depth (m)"
ggplot(alldata) +
  geom_path(aes( x = temperature, y = depth, color = id)) +
  scale_y_continuous(name = ytitle,
                     limits = c(18, 0),
                     breaks = c(18, 9, 0),
                     trans = "reverse") +
  scale_x_continuous(name = xtitle,
                     limits = c(25, 29),
                     breaks = seq(25, 29, by = 1)) +
  facet_wrap(facets = vars(location))

