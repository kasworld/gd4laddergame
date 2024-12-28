extends VBoxContainer

var 화살표 = preload("res://arrow/arrow.tscn")

@onready var 참가자수 = $"TopMenu/참가자수"
@onready var 사다리문제 = $"사다리_Scroll/사다리들/문제"
@onready var 사다리풀이 = $"사다리_Scroll/사다리들/풀이"
@onready var 참가자들 = $"참가자_Scroll/참가자들"
@onready var 도착지점들 = $"도착지점_Scroll/도착지점들"

const 최소간격 = Vector2(200,50)

class 사다리구성자료:
	var 왼쪽연결길 :bool # 존재여부
	var 왼쪽가는길 :int # 참가자번호
	var 오른쪽가는길 :int # 참가자번호
	func _init() -> void:
		왼쪽연결길 = false # 없음
		왼쪽가는길 = -1 # 미사용
		오른쪽가는길 = -1 # 미사용
	func _to_string() -> String:
		return "[%s %d %d]" % [왼쪽연결길,왼쪽가는길,오른쪽가는길]

# Array[참가자수][참가자수*4]사다리구성자료
var 사다리자료 :Array
var 참가자색 :PackedColorArray
var 참가자위치 :Array # [참가자] = 도착지
var 참가자별풀이이동좌표 :Array  # [참가자][vector2]

func 사다리칸수() -> Vector2i:
	return Vector2i(참가자수.get_value(), 참가자수.get_value()*3 )

func 사다리간격() -> Vector2:
	var 칸수 = 사다리칸수()
	var 간격 = max($"사다리_Scroll/사다리들".size.x / 칸수.x , 최소간격.x)
	return Vector2(간격, $"사다리_Scroll/사다리들".size.y / 칸수.y)

func 세로줄위치(x :int, y :int)->Vector2:
	var 간격 = 사다리간격()
	return Vector2(x * 간격.x +간격.x/2, y * 간격.y)

func 가로줄위치(x :int, y :int)->Vector2:
	var 간격 = 사다리간격()
	return Vector2(x * 간격.x +간격.x/2, y * 간격.y + 간격.y/2 )

func 사다리자료_보기():
	var 칸수 = 사다리칸수()
	for y in 칸수.y:
		var ss :String = ""
		for x in 칸수.x:
			ss += str(사다리자료[x][y]) + " "
		print(ss)
	for i in 칸수.x:
		print(i, "->", 참가자위치[i])

func 사다리자료_만들기() -> void:
	# 초기화
	var 칸수 = 사다리칸수()
	참가자색 = []
	참가자별풀이이동좌표 = []
	참가자위치 = []
	사다리자료 = []
	for i in 칸수.x:
		참가자색.append(NamedColorList.color_list.pick_random()[0])
		참가자위치.append(i)
		참가자별풀이이동좌표.append([])
		사다리자료.append([])
		for j in 칸수.y:
			사다리자료[i].append(사다리구성자료.new())

	# 문제 만들기
	for y in 칸수.y:
		for x in 칸수.x:
			if randf() < 0.5:
				continue
			if 사다리자료[(x-1+칸수.x)%칸수.x][y].왼쪽연결길 == true or 사다리자료[(x+1)%칸수.x][y].왼쪽연결길 == true:
				continue
			if y > 0 and 사다리자료[x][y-1].왼쪽연결길 == true:
				continue
			사다리자료[x][y].왼쪽연결길 = true

	# 풀이 만들기
	# 각 줄을 순서대로 타고
	for 참가자번호 in 칸수.x:
		var 현재줄번호 = 참가자번호
		# 아래로 내려가면서 좌우로 이동
		for y in 칸수.y:
			if 사다리자료[현재줄번호][y].왼쪽연결길 == true:
				# 왼쪽으로 한칸 이동
				사다리자료[현재줄번호][y].왼쪽가는길 = 참가자번호
				현재줄번호 = (현재줄번호-1 + 칸수.x) %칸수.x
				참가자위치[참가자번호] = 현재줄번호
				continue
			if 사다리자료[(현재줄번호+1)%칸수.x][y].왼쪽연결길 == true:
				# 오른쪽으로 한칸 이동
				사다리자료[현재줄번호][y].오른쪽가는길 = 참가자번호
				현재줄번호 = (현재줄번호+1) % 칸수.x
				참가자위치[참가자번호] = 현재줄번호
				continue

func _ready() -> void:
	var fsize = preload("res://사다리타기.tres").default_font_size
	참가자수.init(0,"참가자수 ",fsize)
	#참가자수.set_limits(2,true,4,100,true)
	$"참가자_Scroll".get_h_scroll_bar().scrolling.connect(_on_참가자_scroll_scroll_started)
	$"도착지점_Scroll".get_h_scroll_bar().scrolling.connect(_on_도착지점_scroll_scroll_started)
	$"사다리_Scroll".get_h_scroll_bar().scrolling.connect(_on_사다리_scroll_scroll_started)
	참가자수변경()

func 참가자수변경() -> void:
	for n in 참가자들.get_children():
		참가자들.remove_child(n)
	for n in 도착지점들.get_children():
		도착지점들.remove_child(n)
	for i in 참가자수.get_value():
		var 참가자 = TextEdit.new()
		참가자.text = "출발%d" % [i+1]
		참가자.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		참가자.size_flags_vertical = Control.SIZE_EXPAND
		참가자.scroll_fit_content_height = true
		참가자.custom_minimum_size.x = 최소간격.x
		참가자들.add_child(참가자)
		var 도착지점 = TextEdit.new()
		도착지점.text = "도착%d" % [i+1]
		도착지점.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		도착지점.size_flags_vertical = Control.SIZE_EXPAND
		도착지점.scroll_fit_content_height = true
		도착지점.custom_minimum_size.x = 최소간격.x
		도착지점들.add_child(도착지점)
	사다리문제.visible = false
	사다리풀이.visible = false
	var 칸수 = 사다리칸수()
	$"사다리_Scroll/사다리들".custom_minimum_size.x = 칸수.x * 최소간격.x
	$"사다리_Scroll/사다리들".custom_minimum_size.y = 칸수.y * 최소간격.y
	$"참가자_Scroll".custom_minimum_size.y = 참가자들.get_child(0).size.y *2 +10
	$"도착지점_Scroll".custom_minimum_size.y = 도착지점들.get_child(0).size.y *2 +10

	$"TopMenu/풀기단추".disabled = true
	$"TopMenu/만들기단추".disabled = false

func 사다리문제그리기() -> void:
	사다리자료_만들기()
	for i in 참가자들.get_child_count():
		참가자들.get_child(i).editable = false
		도착지점들.get_child(i).editable = false
		참가자들.get_child(i).modulate = 참가자색[i]

	for n in 사다리문제.get_children():
		사다리문제.remove_child(n)
	var 칸수 = 사다리칸수()
	var 간격 = 사다리간격()

	for x in 칸수.x:
		var 세로줄 = Line2D.new()
		세로줄.default_color = 참가자색[x]
		세로줄.width = 간격.x/40
		세로줄.points = [세로줄위치(x,0),세로줄위치(x,칸수.y)]
		사다리문제.add_child(세로줄)

	for y in 칸수.y:
		for x in 칸수.x+1:
			if 사다리자료[x%칸수.x][y].왼쪽연결길:
				var 가로줄 = Line2D.new()
				가로줄.default_color = Color.WHITE
				가로줄.width = 간격.y/10
				가로줄.points = [가로줄위치(x,y), 가로줄위치(x-1,y)]
				사다리문제.add_child(가로줄)

	사다리문제.visible = true
	사다리풀이.visible = false
	$"TopMenu/풀기단추".disabled = false
	$"TopMenu/만들기단추".disabled = true

func 사다리풀이그리기() -> void:
	var 칸수 = 사다리칸수()
	var 간격 = 사다리간격()

	for i in 칸수.x:
		var s = 도착지점들.get_child(참가자위치[i]).text
		도착지점들.get_child(참가자위치[i]).text += "<-" + 참가자들.get_child(i).text
		참가자들.get_child(i).text += "->" + s
		도착지점들.get_child(참가자위치[i]).modulate = 참가자색[i]

	for n in 사다리풀이.get_children():
		사다리풀이.remove_child(n)

	var 화살표두께 = max(간격.x * 0.01, 2)
	var 화살표날개길이 = max(간격.x * 0.1, 10)
	var 화살표날개폭 = PI/9
	var shift = Vector2(0, 화살표두께 *0.7)
	var 세로위치보정 = Vector2(0,간격.y/2)

	# 각 줄을 순서대로 타고
	for 참가자번호 in 칸수.x:
		var 현재줄번호 = 참가자번호
		# 아래로 내려가면서 좌우로 이동
		var oldy = 0
		# 시작 세로줄 그리기
		참가자별풀이이동좌표[참가자번호].append_array([세로줄위치(현재줄번호,0), 가로줄위치(현재줄번호,0)])
		for y in 칸수.y:
			if 사다리자료[현재줄번호][y].왼쪽연결길 == true: # 왼쪽으로 한칸 이동
				# 현재까지의 세로줄 그리기
				참가자별풀이이동좌표[참가자번호].append_array([가로줄위치(현재줄번호,oldy), 가로줄위치(현재줄번호,y)])
				#왼쪽 화살표
				참가자별풀이이동좌표[참가자번호].append_array([가로줄위치(현재줄번호,y)-shift, 가로줄위치(현재줄번호-1,y)-shift])
				현재줄번호 -= 1
				if 현재줄번호 < 0:
					# 절반 길이 화살표가 필요
					참가자별풀이이동좌표[참가자번호].append_array([가로줄위치(현재줄번호+1,y)-shift, 가로줄위치(현재줄번호,y)-shift])
					현재줄번호 += 칸수.x
					참가자별풀이이동좌표[참가자번호].append_array([가로줄위치(현재줄번호+1,y)-shift, 가로줄위치(현재줄번호,y)-shift])
				else :
					참가자별풀이이동좌표[참가자번호].append_array([가로줄위치(현재줄번호+1,y)-shift, 가로줄위치(현재줄번호,y)-shift])
				oldy = y
				continue
			if 사다리자료[(현재줄번호+1)%칸수.x][y].왼쪽연결길 == true: # 오른쪽으로 한칸 이동
				# 현재까지의 세로줄 그리기
				참가자별풀이이동좌표[참가자번호].append_array([가로줄위치(현재줄번호,oldy), 가로줄위치(현재줄번호,y)])
				# 오른쪽 화살표
				현재줄번호 += 1
				if 현재줄번호 >= 칸수.x:
					# 절반 길이 화살표가 필요
					참가자별풀이이동좌표[참가자번호].append_array([가로줄위치(현재줄번호-1,y)+shift, 가로줄위치(현재줄번호,y)+shift])
					현재줄번호 -= 칸수.x
					참가자별풀이이동좌표[참가자번호].append_array([가로줄위치(현재줄번호-1,y)+shift, 가로줄위치(현재줄번호,y)+shift])
				else:
					참가자별풀이이동좌표[참가자번호].append_array([가로줄위치(현재줄번호-1,y)+shift, 가로줄위치(현재줄번호,y)+shift])
				oldy = y
				continue
		# 나머지 끝까지 그린다.
		참가자별풀이이동좌표[참가자번호].append_array([가로줄위치(현재줄번호,oldy), 가로줄위치(현재줄번호,칸수.y)-세로위치보정])

	for 참가자번호 in 참가자별풀이이동좌표.size():
		for i in 참가자별풀이이동좌표[참가자번호].size()/2:
			var p1 = 참가자별풀이이동좌표[참가자번호][i*2]
			var p2 = 참가자별풀이이동좌표[참가자번호][i*2+1]
			사다리풀이.add_child(
				화살표.instantiate().init_2_point(p1, p2, 참가자색[참가자번호], 화살표두께, 화살표날개길이, 화살표날개폭) )

	사다리문제.visible = false
	사다리풀이.visible = true
	$"TopMenu/풀기단추".disabled = true

func _on_참가자수_value_changed(_idx: int) -> void:
	참가자수변경()

func _on_만들기단추_pressed() -> void:
	사다리문제그리기()

func _on_풀기단추_pressed() -> void:
	사다리풀이그리기()

func _on_참가자_scroll_scroll_started() -> void:
	$"사다리_Scroll".scroll_horizontal = $"참가자_Scroll".scroll_horizontal
	$"도착지점_Scroll".scroll_horizontal = $"참가자_Scroll".scroll_horizontal

func _on_도착지점_scroll_scroll_started() -> void:
	$"사다리_Scroll".scroll_horizontal = $"도착지점_Scroll".scroll_horizontal
	$"참가자_Scroll".scroll_horizontal = $"도착지점_Scroll".scroll_horizontal

func _on_사다리_scroll_scroll_started() -> void:
	$"참가자_Scroll".scroll_horizontal = $"사다리_Scroll".scroll_horizontal
	$"도착지점_Scroll".scroll_horizontal = $"사다리_Scroll".scroll_horizontal
