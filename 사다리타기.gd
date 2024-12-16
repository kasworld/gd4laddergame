extends VBoxContainer

@onready var 참가자수 = $"HBoxContainer/참가자수"
@onready var 세로선들 = $"사다리들/세로선들"
@onready var 가로선들 = $"사다리들/가로선들"


func _ready() -> void:
	var fsize = preload("res://사다리타기.tres").default_font_size
	참가자수.init(0,"참가자수 ",fsize)
	참가자수.set_limits(2,true,4,30,true)
	$"참가자들".custom_minimum_size.y = 참가자수.size.y/2
	$"도착지점들".custom_minimum_size.y = 참가자수.size.y/2
	참가자수변경()

func 참가자수변경()->void:
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
	세로선만들기()
	가로선만들기()

func 세로선만들기()->void:
	for n in 세로선들.get_children():
		세로선들.remove_child(n)
	var n =  참가자수.get_value()
	var 간격 = $"사다리들".size.x / n
	var y1 = 0
	var y2 = 세로선들.size.y
	for i in n:
		var 세로줄 = Line2D.new()
		세로줄.default_color = Color.WHITE
		세로줄.width = 간격/20
		세로줄.add_point(Vector2(i*간격+간격/2,y1))
		세로줄.add_point(Vector2(i*간격+간격/2,y2))
		세로선들.add_child(세로줄)

func _on_참가자수_value_changed(idx: int) -> void:
	참가자수변경()

func 가로선만들기()->void:
	for n in 가로선들.get_children():
		가로선들.remove_child(n)
	var n =  참가자수.get_value()
	var 간격x = $"사다리들".size.x / n
	var 간격y = $"사다리들".size.y / n /4
	var 선만듬:bool
	for y in n*4:
		for x in n+1:
			if 선만듬 or randf() < 0.6:
				선만듬 = false
				continue
			var 가로줄 = Line2D.new()
			가로줄.default_color = Color.WHITE
			가로줄.width = 간격y/10
			가로줄.add_point(Vector2(x*간격x-간격x/2,y*간격y+간격y/2))
			가로줄.add_point(Vector2(x*간격x+간격x/2,y*간격y+간격y/2))
			가로선들.add_child(가로줄)
			선만듬 = true
