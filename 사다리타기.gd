extends VBoxContainer

var 화살표 = preload("res://arrow/arrow.tscn")

@onready var 참가자수 = $"HBoxContainer/참가자수"
@onready var 사다리문제 = $"사다리들/문제"
@onready var 사다리풀이 = $"사다리들/풀이"

# Array[참가자수][참가자수*4]Bool
var 사다리만들기자료 :Array
# Array[참가자수][참가자수*4][참가자번호:int*2]
var 사다리풀이자료 :Array
var 참가자색 :Array = []

func 사다리자료_만들기() -> void:
	# 초기화
	사다리만들기자료 = []
	사다리풀이자료 = []
	참가자색 = []
	var 칸수 = 사다리칸수()
	for i in 칸수.x:
		사다리만들기자료.append([])
		사다리풀이자료.append([])
		for j in 칸수.y:
			사다리만들기자료[i].append(false)
			사다리풀이자료[i].append([-1,-1])

	for i in 칸수.x:
		참가자색.append(NamedColorList.color_list.pick_random()[0])

	# 문제 만들기
	for y in 칸수.y:
		for x in 칸수.x:
			if randf() < 0.5:
				continue
			if 사다리만들기자료[(x-1+칸수.x)%칸수.x][y] or 사다리만들기자료[(x+1)%칸수.x][y]:
				continue
			사다리만들기자료[x][y] = true

	# 풀이 만들기
	# 각 줄을 순서대로 타고
	for 참가자번호 in 칸수.x:
		var 현재줄번호 = 참가자번호
		# 아래로 내려가면서 좌우로 이동
		for y in 칸수.y:
			if 사다리만들기자료[현재줄번호][y] == true:
				# 왼쪽으로 한칸 이동
				사다리풀이자료[현재줄번호][y][0] = 참가자번호
				참가자번호 = (참가자번호-1 + 칸수.x) %칸수.x
				continue
			if 사다리만들기자료[(현재줄번호+1)%칸수.x][y] == true:
				# 오른쪽으로 한칸 이동
				사다리풀이자료[현재줄번호][y][1] = 참가자번호
				참가자번호 = (참가자번호+1) % 칸수.x
				continue

func _ready() -> void:
	var fsize = preload("res://사다리타기.tres").default_font_size
	참가자수.init(0,"참가자수 ",fsize)
	참가자수.set_limits(2,true,4,30,true)
	$"참가자들".custom_minimum_size.y = 참가자수.size.y/2
	$"도착지점들".custom_minimum_size.y = 참가자수.size.y/2
	참가자수변경()

func 참가자수변경() -> void:
	for n in $"참가자들".get_children():
		$"참가자들".remove_child(n)
	for n in $"도착지점들".get_children():
		$"도착지점들".remove_child(n)
	for i in 참가자수.get_value():
		var 참가자 = TextEdit.new()
		참가자.text = "출발%d" % [i+1]
		참가자.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		$"참가자들".add_child(참가자)
		var 도착지점 = TextEdit.new()
		도착지점.text = "도착%d" % [i+1]
		도착지점.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		$"도착지점들".add_child(도착지점)
	사다리자료_만들기()
	사다리문제.visible = false
	사다리풀이.visible = false

func 사다리문제그리기() -> void:
	for n in 사다리문제.get_children():
		사다리문제.remove_child(n)
	var 칸수 = 사다리칸수()
	var 간격 = 사다리간격()

	for x in 칸수.x:
		var 세로줄 = Line2D.new()
		세로줄.default_color = 참가자색[x]
		세로줄.width = 간격.x/20
		세로줄.points = [세로줄위치(x,0),세로줄위치(x,칸수.y)]
		사다리문제.add_child(세로줄)

	for y in 칸수.y:
		for x in 칸수.x+1:
			if 사다리만들기자료[x%칸수.x][y]:
				var 가로줄 = Line2D.new()
				가로줄.default_color = Color.WHITE
				가로줄.width = 1 #간격.y/10
				가로줄.points = [가로줄위치(x,y), 가로줄위치(x+1,y)]
				사다리문제.add_child(가로줄)

	사다리문제.visible = true
	사다리풀이.visible = false

func 사다리풀이그리기() -> void:
	for n in 사다리풀이.get_children():
		사다리풀이.remove_child(n)
	var 칸수 = 사다리칸수()
	var 간격 = 사다리간격()

	var shift = Vector2(0,2 * 간격.y/10)
	for y in 칸수.y:
		for x in 칸수.x+1:
			var 참가번호 = 사다리풀이자료[x%칸수.x][y][0]
			if  참가번호 < 0:
				continue
			#if y == 0:
				# 첫 세로줄 그리기
			#참가번호 = x % n
			#var 세로줄 = 화살표.instantiate()
			#세로줄.init_2_point(세로줄위치(x,y), 세로줄위치(x,y+1)-shift, 참가자색[참가번호], 간격.x/10/10, 0.3)
			#사다리풀이.add_child(세로줄)

			참가번호 = 사다리풀이자료[x%칸수.x][y][0] # 왼쪽
			var 가로줄 = 화살표.instantiate()
			가로줄.init_2_point(가로줄위치(x+1,y)-shift, 가로줄위치(x,y)-shift, 참가자색[참가번호], 간격.y/10, 0.05)
			사다리풀이.add_child(가로줄)

			참가번호 = 사다리풀이자료[x%칸수.x][y][1] # 오른쪽
			가로줄 = 화살표.instantiate()
			가로줄.init_2_point(가로줄위치(x,y)+shift, 가로줄위치(x+1,y)+shift, 참가자색[참가번호], 간격.y/10, 0.05)
			사다리풀이.add_child(가로줄)

	#사다리문제.visible = false
	사다리풀이.visible = true

func 사다리칸수() -> Vector2i:
	return Vector2i(참가자수.get_value(), 참가자수.get_value() )

func 사다리간격() -> Vector2:
	var 칸수 = 사다리칸수()
	return Vector2($"사다리들".size.x / 칸수.x, $"사다리들".size.y / 칸수.y)

func 세로줄위치(x :int, y :int)->Vector2:
	var 간격 = 사다리간격()
	return Vector2(x * 간격.x +간격.x/2, y * 간격.y)

func 가로줄위치(x :int, y :int)->Vector2:
	var 간격 = 사다리간격()
	return Vector2(x * 간격.x -간격.x/2, y * 간격.y + 간격.y/2 )

func _on_참가자수_value_changed(_idx: int) -> void:
	참가자수변경()

func _on_만들기단추_pressed() -> void:
	사다리문제그리기()

func _on_풀기단추_pressed() -> void:
	사다리풀이그리기()
