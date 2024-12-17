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
			사다리풀이자료[i].append([])

	for i in n:
		참가자색.append(NamedColorList.color_list.pick_random())

	# 문제 만들기
	for y in n*4:
		for x in n:
			if randf() < 0.5:
				continue
			if 사다리만들기자료[(x-1+n)%n][y] or 사다리만들기자료[(x+1)%n][y]:
				continue
			사다리만들기자료[x][y] = true

	# 풀이 만들기

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
		세로줄.default_color = 참가자색[x][0]
		세로줄.width = 간격x/20
		var xx = x*간격x+간격x/2
		세로줄.points = [Vector2(xx,y1), Vector2(xx,y2)]
		사다리문제.add_child(세로줄)

	for y in n*4:
		for x in n+1:
			if 사다리만들기자료[x%n][y]:
				var 가로줄 = Line2D.new()
				가로줄.default_color = Color.GREEN
				가로줄.width = 간격y/10
				var x1 = x*간격x-간격x/2
				var x2 = x*간격x+간격x/2
				var yy = y*간격y+간격y/2
				가로줄.points = [Vector2(x1,yy), Vector2(x2,yy)]
				사다리문제.add_child(가로줄)

	사다리문제.visible = true

func 사다리풀이그리기() -> void:
	for n in 사다리문제.get_children():
		사다리문제.remove_child(n)
	var n = 참가자수.get_value()
	var 간격x = $"사다리들".size.x / n
	var 간격y = $"사다리들".size.y / n /4


	사다리문제.visible = false
	사다리풀이.visible = true

func 세로줄만들기(x :int, y:int, co :Color)->Line2D:
	var n =  참가자수.get_value()
	var 간격x = $"사다리들".size.x / n
	var 간격y = $"사다리들".size.y / n /4
	var 세로줄 = Line2D.new()
	세로줄.default_color = co
	세로줄.width = 간격x/10
	var xx = x*간격x+간격x/2
	var y1 = y*간격y
	var y2 = y*간격y+간격y
	세로줄.add_point(Vector2(xx,y1))
	세로줄.add_point(Vector2(xx,y2))
	return 세로줄

func 가로줄만들기(x :int, y:int, co :Color) -> Line2D:
	var n =  참가자수.get_value()
	var 간격x = $"사다리들".size.x / n
	var 간격y = $"사다리들".size.y / n /4
	var 가로줄 = Line2D.new()
	가로줄.default_color = co
	가로줄.width = 간격y/10
	var x1 = x*간격x-간격x/2
	var x2 = x*간격x+간격x/2
	var yy = y*간격y+간격y/2
	가로줄.add_point(Vector2(x1,yy))
	가로줄.add_point(Vector2(x2,yy))
	return 가로줄

func _on_참가자수_value_changed(_idx: int) -> void:
	참가자수변경()

func _on_만들기단추_pressed() -> void:
	사다리문제그리기()

func _on_풀기단추_pressed() -> void:
	사다리풀이그리기()
