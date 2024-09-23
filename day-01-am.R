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
fish_data

fish_data$fish_loc # string 文字列
fish_data$fish_id # data.frame の変数はベクトルです
fish_data$fish_size

fish_data[3, ] # 行列の位置を指定する、ここは 3 行目
fish_data[c(1,3), ] # 1 と 3 行目の情報を返す
fish_data[c(1,3), c(2,3)] # 1と3行、2と3列
fish_data[ , 3] # 3列目
fish_data$fish_size # 55行と同じ結果
fish_data$fish_size[3] # データフレームの fish_size の変数から3番目の要素を返す

# ベクトルの作り方その２

seq(from = 1, to = 10, by = 2)
seq(from = 0, to = 20, by = 3)
seq(from = -4, to = 4, by = 1.2)
seq(from = 10, to = 30, length = 3)
seq(from = 0, to = 10, length = 5)

replicate(n = 3, "A") # 行列が戻ってくる
replicate(n = 5, c("A", "B"))

rep(x = "A", times = 3) # ベクトルが戻ってくる
rep(x = c("A", "B"), times = 3) # ベクトルを３回複製する
rep(x = c("A", "B"), each = 3) # ベクトルの要素を３回複製する
rep(x = c(1,2,5), each = 2)
rep(x = c(1,2,3), times = 4)

