extends Node2D
class_name Arrow

func init_vector(vt :Vector2, co :Color, w :float)->Arrow:
	return init_2_point(Vector2.ZERO, vt, co, w)

func init_2_point_center(p1 :Vector2, p2 :Vector2, co :Color, w :float)->Arrow:
	var c = (p1+p2)/2
	return init_2_point(p1-c, p2-c, co, w)

func init_2_point(p1 :Vector2, p2 :Vector2, co :Color, w :float)->Arrow:
	set_color(co)
	set_width(w)
	set_points(p1,p2)
	return self

func set_points(p1 :Vector2, p2 :Vector2):
	$CenterLine.points = [p1,p2]
	var p3 = ((p1-p2)*0.2).rotated(PI/6) + p2
	$LeftLine.points = [p2,p3]
	var p4 = ((p1-p2)*0.2).rotated(-PI/6) + p2
	$RightLine.points = [p2,p4]

func set_color(co :Color):
	$CenterLine.default_color = co
	$LeftLine.default_color = co
	$RightLine.default_color = co

func set_width(w :float):
	$CenterLine.width = w
	$LeftLine.width = w
	$RightLine.width = w
