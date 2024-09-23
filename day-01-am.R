# データ解析演習I（午前）
# Rの基礎
# 2024-09-23
# Greg Nishihara

# Rは計算機

52 + 48
60 / 23.5
40 * (40 + 2.1)^2
sqrt(96) # 平方根
sqrt(-8) # Warning 
sqrt(x)  # Error (オブジェクト x が存在しないから)

x = 2024 # x はオブジェクトといいます
y = 80
x1 = 96
y2 = -0.193
# オブジェクト名は半角文字でつくること
# 記号を名前に使わないこと
# アルファベットから始まること
# 基本はアルファベットと数字（半角）
# オブジェクト名にスペースを入れたいときは _ をつかう。
fish_size1 = 190 # cm
fish_size2 = 185 # cm

# オブジェクトを用いての算数
x + y
x / y
x^y # 3.13e+264 == 3.13 x 10^264

# ベクトル (1d)
fish_size = c(190, 185, 200, 210, 180) # num: numeric (実数) [1:5] 要素の数
# fish_size には5つの要素 (Environment tab で確認できる)
# fish_size <- c(190, 185, 200, 210, 180) # 代入演算子 <- (ALT + -)

# データフレーム (2d) data.frame()
# スプレッドシートのようなオブジェクト
# 複数のベクトルの集まり

fish_id = 1:5 # 1 から 5 の数字を fish_id にいれる
# int: integer (整数) 
fish_loc = c("A", "A", "B", "B", "B")

fish_data = data.frame(fish_loc, fish_id, fish_size)




