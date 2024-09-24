# Castaway CTD データの解析
# 複数プロットの作成
# 2024-09-24
# Greg Nishihara

# パッケージの読み込み
library(tidyverse) # tidyverse（モダンR）
library(lubridate) # 時刻データ処理

library(magick)    # 画像処理用のパッケージ
library(showtext)  # 作図用フォントのパッケージ
library(ggtext)    # 作図用フォントのパッケージ
library(ggpubr)    # ggplot() テーマパッケージ


# 保存済みデータファイルの読み込み
fname = here::here("Output/CTD_dataset.csv")
alldata = read_csv(fname)
alldata


font_add_google(name = "Noto Sans JP", family = "notosansjp")
theme_pubr(base_size = 10,
           base_family = "notosansjp") |> 
  theme_set()

showtext_auto()


# 水温の鉛直分布
xtitle = "海水温 (&deg; C)" 
ytitle = "水深 (m)"

plot_temperature = 
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


# 塩分の鉛直分布
xtitle = "塩分 (-)" 
ytitle = "水深 (m)"

plot_salinity = 
  ggplot(alldata) + 
  geom_point(aes(x = salinity,
                 y = depth,
                 color = location),
             alpha = 0.5,
             stroke = NA) +
  scale_x_continuous(name = xtitle, limits = c(26, 34)) + 
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

pdfname = "Output/notosans_temperature.pdf"
pngname = str_replace(pdfname, pattern = "pdf", replacement = "png")
# width, height は 80 mm した理由：ちょうど学術論文の
# １列の幅だからです。
ggsave(filename = pdfname,
       plot = plot_temperature,
       width = 80,
       height = 80,
       units = "mm")

img = image_read_pdf(pdfname, density = 900)
image_write(image = img, path = pngname)

pdfname = "Output/notosans_salinity.pdf"
pngname = str_replace(pdfname, pattern = "pdf", replacement = "png")
# width, height は 80 mm した理由：ちょうど学術論文の
# １列の幅だからです。
ggsave(filename = pdfname,
       plot = plot_salinity,
       width = 80,
       height = 80,
       units = "mm")

img = image_read_pdf(pdfname, density = 900)
image_write(image = img, path = pngname)

