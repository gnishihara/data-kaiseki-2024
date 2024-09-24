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


# ggplot() ベースレイヤー
# geom_point()散布図レイヤー
#   aes() で x, y, color の情報をgeom_point() に渡す
#   alpha は記号や線の透明度（0 ~ 1）
#   stroke は記号の線の幅
# scale_x_continuous() はx軸スタイルを決める
# scale_y_continuous() はy軸スタイルを決める
# scale_color_viridis_b() は記号や線の色を決める
# theme() で図の書式を設定する
# 軸の書式はマークダウン (markdown) で定義できるようにする
#   axis.title.x = element_markdown()　
#   axis.title.y = element_markdown()　
#   
# HTMLでは、特定の文字や記号（例えば, &deg;）を表示するために、
# HTMLエンティティという特殊な記述法を使用します。
# <sup>-2</sup> 上付き
# <sub>2</sub> 下付き
# element_blank() 指定したものを削除する

xtitle = "海水温 (&deg; C)" 
ytitle = "水深 (m)"

ggplot(alldata) + 
  geom_point(aes(x = temperature,
                 y = depth,
                 color = location),
             alpha = 0.5,
             stroke = NA) +
  scale_x_continuous(name = xtitle) + 
  scale_y_continuous(name = ytitle) +
  scale_color_viridis_d(end = 0.80) +
  theme(
    axis.title.x = element_markdown(),
    axis.title.y = element_markdown(),
    axis.line.x = element_blank(),
    axis.line.y = element_blank(),
    axis.ticks.x = element_line(color = "black"),
    axis.ticks.y = element_line(color = "black"),
    legend.title = element_blank(),
    legend.position = "inside",
    legend.position.inside = c(0, 1),
    legend.justification = c(0,1),
    legend.background = element_blank(),
    panel.border = element_rect(color = "black", fill = NA)
  )

pngname = "Output/mochipop_japanese.png"
ggsave(filename = pngname,
       width = 80,
       height = 80,
       units = "mm",
       dpi = 300)


# おすすめの図の保存方法 ###################################
font_add_google(name = "Noto Sans JP", family = "notosansjp")
theme_pubr(base_size = 10,
           base_family = "notosansjp") |> 
  theme_set()

showtext_auto()

xtitle = "海水温 (&deg; C)" 
ytitle = "水深 (m)"

ggplot(alldata) + 
  geom_point(aes(x = temperature,
                 y = depth,
                 color = location),
             alpha = 0.5,
             stroke = NA) +
  scale_x_continuous(name = xtitle, limits = c(25, 29)) + 
  scale_y_continuous(name = ytitle,
                     limits = c(18, 0),
                     breaks = seq(18, 0, length = 5),
                     trans = "reverse") +
  scale_color_viridis_d(end = 0.80) +
  theme(
    axis.title.x = element_markdown(),
    axis.title.y = element_markdown(),
    axis.line.x = element_blank(),
    axis.line.y = element_blank(),
    axis.ticks.x = element_line(color = "black"),
    axis.ticks.y = element_line(color = "black"),
    legend.title = element_blank(),
    legend.position = "inside",
    legend.position.inside = c(0, 0),
    legend.justification = c(0, 0),
    legend.background = element_blank(),
    panel.border = element_rect(color = "black", fill = NA)
  )

pdfname = "Output/notosans_japanese.pdf"
pngname = str_replace(pdfname, pattern = "pdf", replacement = "png")
# width, height は 80 mm した理由：ちょうど学術論文の
# １列の幅だからです。
ggsave(filename = pdfname,
       width = 80,
       height = 80,
       units = "mm")

img = image_read_pdf(pdfname, density = 900)
image_write(image = img, path = pngname)


