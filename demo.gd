extends Node2D

@onready var bound: Polygon2D = $Bound
@onready var left_top = bound.polygon[0]
@onready var right_bottom = bound.polygon[0]

const PoissonDiscSampler = preload('res://poisson_disc_sampler.gd')

var points: PackedVector2Array = []

func _ready() -> void:
	perform()

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed('ui_accept'):
		perform()

func perform() -> void:
	var start_time := Time.get_ticks_msec()
	var generator = PoissonDiscSampler.new()
	generator.bound = bound.polygon
	generator.radius = 15.0
	points = generator.generate()
	var end_time := Time.get_ticks_msec()
	queue_redraw()
	print(end_time - start_time)

func _draw() -> void:
	for point in points:
		draw_circle(point, 5, Color.WHITE)
