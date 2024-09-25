# 時系列データの処理
# 2024-09-25
# Greg Nishihara


# パッケージ読み込み
library(tidyverse) # tidyverse
library(lubridate) # 時系列データの処理
library(ggpubr)    # ggplot のテーマ
library(ggtext)    # ggplot 文字の処理
library(showtext)  # ggplot フォントの読み込み
library(magick)    # 画像処理 (imagemagick)

# 長崎県新上五島町鯛ノ浦湾の海水温データ（ロガーは海底に設置した）
fname = here::here("./Data/Temperature_Dataset/Temp_11000848_tainoura_0m_170614.csv")

# CSVファイルの読み込み
df1 = read_csv(fname, skip = 1)

# 変数を選択して、変数名を変える
df1 = df1 |> 
  select(datetime = `日付 時間, GMT+09:00`,
         temperature = matches("温度"))

# 日時データを文字列から時刻データに変換する
df1 = df1 |> 
  mutate(datetime = parse_date_time(datetime,
                                    orders = "%m/%d/%Y %I:%M:%S %p"))

df1 |> head(n = 3) # tibble の最初の3行を表示する
df1 |> tail(n = 4) # tibble の最後の4行を表示する

ggplot(df1) + 
  geom_point(aes(x = datetime, y = temperature))

# 一日当たりの最小、平均、最大水温を求める

df1 = df1 |> 
  mutate(date = as_date(datetime), .before = "datetime")

df2 = 
  df1 |> 
  group_by(date) |> 
  summarise(min = min(temperature),
            mean = mean(temperature),
            max = max(temperature),
            n = length(temperature))

df2 |> print(n = 50) # 2017-06-17 のデータは N = 17

df1 |> 
  filter(date == as_date("2017-06-17"))

# 2017-06-17 のデータを外す
df2 = df2 |> 
  filter(date < as_date("2017-06-17"))





