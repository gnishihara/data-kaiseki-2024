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

fname = here::here("./Data/Temperature_Dataset/Temp_11000848_tainoura_0m_170614.csv")

df1 = read_csv(fname, skip = 1)

df1 = df1 |> 
  select(datetime = `日付 時間, GMT+09:00`,
         temperature = matches("温度"))
df1

df1 = df1 |> 
  mutate(datetime = parse_date_time(datetime,
                                    orders = "%m/%d/%Y %I:%M:%S %p"))

df1






