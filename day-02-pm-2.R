# Castaway CTD データの解析
# 2024-09-24
# Greg Nishihara

# パッケージの読み込み
library(tidyverse) # tidyverse（モダンR）
library(lubridate) # 時刻データ処理

library(magick)    # 画像処理用のパッケージ
library(showtext)  # 作図用フォントのパッケージ
library(ggtext)    # 作図用フォントのパッケージ
library(ggpubr)    # ggplot() テーマパッケージ

# フォントの準備
# この関数の場合はネットへのアクセスが必要
# google のサーバへアクセスする
# font_add_google(name = "Noto Sans JP", family = "notosansjp")
# font_add_google(name = "Hachi Maru Pop", family = "hachimaru")
font_add_google(name = "Mochiy Pop One", family = "mochipop")

# font_files() # パソコン上のフォントを確認する
# font_add() # パソコン上のフォントの読み込み

# ggplot のテーマを設定する
# この場合は、背景が白、軸線あり
theme_pubr(base_size = 20,
           base_family = "mochipop") |> 
  theme_set()

showtext_auto()

# 保存済みデータファイルの読み込み
fname = here::here("Output/CTD_dataset.csv")
alldata = read_csv(fname)
alldata

xtitle = "海水温 (&deg; C)"
ytitle = "水深 (m)"

ggplot(alldata) + 
  geom_point(aes(x = temperature,
                 y = depth,
                 color = location)) +
  scale_x_continuous(name = xtitle) + 
  scale_y_continuous(name = ytitle) +
  theme(
    axis.title.x = element_markdown(),
    axis.title.y = element_markdown(),
    legend.title = element_blank(),
    legend.position = "inside",
    legend.position.inside = c(0, 1),
    legend.justification = c(0,1),
    legend.background = element_blank()
  )

pngname = "Output/mochipop_japanese.png"
ggsave(filename = pngname,
       width = 80,
       height = 80,
       units = "mm",
       dpi = 300)
