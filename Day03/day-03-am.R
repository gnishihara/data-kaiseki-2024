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

# df2 のデータを図にする

xtitle = "Date and time"
ytitle = "Temperature (&deg;C)"

# x軸の範囲を調べる
xlimits = df2 |> pull(date) |> range()
xbreaks = seq(xlimits[1], xlimits[2], by = 7)

tmp = c(xlimits, xbreaks) # xlimits と xbreaks をつなげる
tmp = sort(tmp) # 順序を整理する
xbreaks = tmp[!duplicated(tmp)] # 重複している情報を外す

ggplot(df2) +
  geom_point(aes(x = date, y = mean)) +
  geom_errorbar(aes(x = date, 
                    ymin = min,
                    ymax = max),
                width = 0.25) +
  scale_x_date(name = xtitle,
               limits = xlimits,
               breaks = xbreaks) +
  scale_y_continuous(name = ytitle) +
  theme(
    axis.title.x = element_markdown(),
    axis.title.y = element_markdown()
  )

# 時間ごとの集計 (0:23)

df1 = df1 |> 
  mutate(hour = hour(datetime))

ggplot(df1) + 
  geom_point(aes(x = hour,
                 y = temperature))


df3 = df1 |> 
  group_by(hour) |> 
  summarise(min = min(temperature),
            mean = mean(temperature),
            max = max(temperature),
            sd = sd(temperature),
            n = length(temperature)) |> 
  mutate(se = sd / sqrt(n - 1))



# 横軸：hour
# 縦軸：mean

xtitle = "Hour (hr)"
ytitle = "Temperature (&deg;C)"

xlimits = c(0, 24)
xbreaks = seq(0, 24, by = 6)
ggplot(df3) + 
  geom_point(aes(x = hour, y = mean)) +
  geom_errorbar(aes(x = hour,
                    ymin = min,
                    ymax = max),
                width = 0) +
  geom_errorbar(aes(x = hour,
                    ymin = mean - sd,
                    ymax = mean + sd),
                width = 0,
                color = "black",
                linewidth = 1) +
  scale_x_continuous(name = xtitle,
                     breaks = xbreaks,
                     limits = xlimits) +
  scale_y_continuous(name = ytitle) +
  theme(
    axis.title.x = element_markdown(),
    axis.title.y = element_markdown()
  )

# 線とリボン

xtitle = "Hour (hr)"
ytitle = "Temperature (&deg;C)"

xlimits = c(0, 24)
xbreaks = seq(0, 24, by = 6)
ggplot(df3) + 
  geom_ribbon(aes(x = hour,
                    ymin = min,
                    ymax = max)) +
  geom_ribbon(aes(x = hour,
                    ymin = mean - sd,
                    ymax = mean + sd),
              fill = "grey50") +
  geom_line(aes(x = hour, y = mean),
            color = "white") +
  scale_x_continuous(name = xtitle,
                     breaks = xbreaks,
                     limits = xlimits) +
  scale_y_continuous(name = ytitle) +
  theme(
    axis.title.x = element_markdown(),
    axis.title.y = element_markdown()
  )

pdfname = "temperature-hour.pdf"
pngname = str_replace(pdfname, "pdf", "png")
ggsave(pdfname,
       width = 80,
       height = 80,
       units = "mm")
i = image_read_pdf(pdfname, density = 600)
image_write(i, path = pngname)
