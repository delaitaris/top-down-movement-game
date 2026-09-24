extends Node2D

@export var speed: float = 4500.0
@export var damage: float = 35.0
@export var max_lifetime: float = 4.0
@export var max_spread_degrees: float = 2.0
@export var laser_length: float = 200.0

@onready var ray_cast_2d: RayCast2D = $RayCast2D
@onready var line_2d: Line2D = $Line2D

var velocity: Vector2 = Vector2.ZERO
var lifetime: float = 0.0

func _ready() -> void:
	look_at(get_global_mouse_position())
	
	var max_spread_rad = deg_to_rad(max_spread_degrees)
	rotation += randf_range(-max_spread_rad, max_spread_rad)
	
	velocity = Vector2.RIGHT.rotated(rotation) * speed
	ray_cast_2d.target_position = Vector2(laser_length, 0)
	
	line_2d.clear_points()
	line_2d.add_point(Vector2.ZERO)
	line_2d.add_point(Vector2(laser_length, 0))
	
func _process(delta: float) -> void:
	if ray_cast_2d.is_colliding():
		var collider = ray_cast_2d.get_collider()
		if collider and collider.has_method("take_damage"):
			collider.take_damage(damage)
		queue_free()
		return

	position += velocity * delta
	lifetime += delta
	if lifetime >= max_lifetime:
		queue_free()
