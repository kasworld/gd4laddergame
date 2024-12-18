extends VBoxContainer

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
	var n = 참가자수.get_value()
	for i in n:
		사다리만들기자료.append([])
		사다리풀이자료.append([])
		for j in n*4:
			사다리만들기자료[i].append(false)
			사다리풀이자료[i].append([-1,-1])

	for i in n:
		참가자색.append(NamedColorList.color_list.pick_random()[0])

	# 문제 만들기
	for y in n*4:
		for x in n:
			if randf() < 0.5:
				continue
			if 사다리만들기자료[(x-1+n)%n][y] or 사다리만들기자료[(x+1)%n][y]:
				continue
			사다리만들기자료[x][y] = true

	# 풀이 만들기
	for y in n*4:
		for x in n:
			if 사다리만들기자료[x][y] != true:
				continue
			# TODO 임시로 랜덤 참가번호를 부여한다.
			사다리풀이자료[x][y][0] = randi_range(0,n-1)
			사다리풀이자료[x][y][1] = randi_range(0,n-1)

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
	var n = 참가자수.get_value()
	var 간격x = $"사다리들".size.x / n
	var 간격y = $"사다리들".size.y / n /4
	var y1 = 0
	var y2 = $"사다리들".size.y

	for x in n:
		var 세로줄 = Line2D.new()
		세로줄.default_color = 참가자색[x]
		세로줄.width = 간격x/20
		세로줄.points = [세로줄위치(x,0),세로줄위치(x,n*4)]
		사다리문제.add_child(세로줄)

	for y in n*4:
		for x in n+1:
			if 사다리만들기자료[x%n][y]:
				var 가로줄 = Line2D.new()
				가로줄.default_color = Color.GREEN
				가로줄.width = 간격y/10
				가로줄.points = [가로줄위치(x,y,0), 가로줄위치(x+1,y,0)]
				사다리문제.add_child(가로줄)

	사다리문제.visible = true
	사다리풀이.visible = false

func 사다리풀이그리기() -> void:
	for n in 사다리풀이.get_children():
		사다리풀이.remove_child(n)
	var n = 참가자수.get_value()
	var 간격 = 사다리간격()
	var shift = 간격.y/10 *2

	for y in n*4:
		for x in n+1:
			for i in 사다리풀이자료[x%n][y].size():
				var 참가번호 = 사다리풀이자료[x%n][y][i]
				if  참가번호 < 0:
					continue
				var 가로줄 = 가로줄만들기(x,y, 참가자색[참가번호], shift *i -shift/2)
				사다리풀이.add_child(가로줄)

	#사다리문제.visible = false
	사다리풀이.visible = true

func 사다리간격() -> Vector2:
	var n = 참가자수.get_value()
	return Vector2($"사다리들".size.x / n, $"사다리들".size.y / n / 4)

func 세로줄위치(x :int, y :int)->Vector2:
	var 간격 = 사다리간격()
	return Vector2(x * 간격.x +간격.x/2, y * 간격.y)

func 가로줄위치(x :int, y :int, shift :int)->Vector2:
	var 간격 = 사다리간격()
	return Vector2(x * 간격.x -간격.x/2, y * 간격.y + 간격.y/2 + shift)

func 세로줄만들기(x :int, y:int, co :Color)->Line2D:
	var 간격 = 사다리간격()
	var 세로줄 = Line2D.new()
	세로줄.default_color = co
	세로줄.width = 간격.x/10
	세로줄.points = [ 세로줄위치(x,y), 세로줄위치(x,y+1)]
	return 세로줄

func 가로줄만들기(x :int, y:int, co :Color, shift :int) -> Line2D:
	var 간격 = 사다리간격()
	var 가로줄 = Line2D.new()
	가로줄.default_color = co
	가로줄.width = 간격.y/10
	가로줄.points = [ 가로줄위치(x,y,shift), 가로줄위치(x+1,y,shift)]
	return 가로줄

func _on_참가자수_value_changed(_idx: int) -> void:
	참가자수변경()

func _on_만들기단추_pressed() -> void:
	사다리문제그리기()

func _on_풀기단추_pressed() -> void:
	사다리풀이그리기()
