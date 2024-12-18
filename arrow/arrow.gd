extends Node2D
class_name Arrow

var wing_rate :float = 0.2
var wing_rotate :float = PI/6

func init_wing(rate :float, rot :float = PI/6 ) -> void:
	wing_rate = rate
	wing_rotate = rot

func init_vector(vt :Vector2, co :Color, w :float) -> Arrow:
	return init_2_point(Vector2.ZERO, vt, co, w)

func init_2_point_center(p1 :Vector2, p2 :Vector2, co :Color, w :float) -> Arrow:
	var c = (p1+p2)/2
	return init_2_point(p1-c, p2-c, co, w)

func init_2_point(p1 :Vector2, p2 :Vector2, co :Color, w :float) -> Arrow:
	set_color(co)
	set_width(w)
	make_arrow(p1,p2)
	return self

func make_arrow(p1 :Vector2, p2 :Vector2):
	$CenterLine.points = [p1,p2]
	p2_wing(p1,p2)
	#p1_wing(p1,p2)

func p1_wing(p1 :Vector2, p2 :Vector2):
	var p3 = ((p2-p1)*wing_rate).rotated(wing_rotate) + p1
	$P1_W1.points = [p1,p3]
	var p4 = ((p2-p1)*wing_rate).rotated(-wing_rotate) + p1
	$P1_W2.points = [p1,p4]
	$P1_W1.visible = true
	$P1_W2.visible = true

func p2_wing(p1 :Vector2, p2 :Vector2):
	var p3 = ((p1-p2)*wing_rate).rotated(wing_rotate) + p2
	$P2_W1.points = [p2,p3]
	var p4 = ((p1-p2)*wing_rate).rotated(-wing_rotate) + p2
	$P2_W2.points = [p2,p4]
	$P2_W1.visible = true
	$P2_W2.visible = true

func set_color(co :Color):
	$CenterLine.default_color = co
	$P2_W1.default_color = co
	$P2_W2.default_color = co
	$P1_W1.default_color = co
	$P1_W2.default_color = co

func set_width(w :float):
	$CenterLine.width = w
	$P2_W1.width = w
	$P2_W2.width = w
	$P1_W1.width = w
	$P1_W2.width = w
