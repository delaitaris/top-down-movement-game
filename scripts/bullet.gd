extends Node2D
@onready var speed: float = 10000.0
@onready var damage: float = 35.0
@onready var max_lifetime: float = 4.0
@onready var line_2d: Line2D = $Line2D


var velocity: Vector2 = Vector2.ZERO
var lifetime: float = 0.0
var total_distance_traveled: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	velocity = Vector2.RIGHT.rotated(rotation) * speed
	
	line_2d.clear_points()
	line_2d.add_point(Vector2.ZERO)
	line_2d.add_point(Vector2.ZERO)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var movement_step = velocity * delta
	var current_position = global_position
	var next_position = current_position + movement_step
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(current_position, next_position)
	var result = space_state.intersect_ray(query)

	total_distance_traveled += movement_step.length()
	query.collide_with_areas = true
	query.collide_with_bodies = true

	if result: 
		global_position = result.position
		handle_collision(result)
		print('hit')
	else:
		global_position = next_position
		update_tracer(movement_step)

	lifetime += delta
	if lifetime >= max_lifetime:
		queue_free()

func update_tracer(_movement_step: Vector2) -> void:
	var current_length = min(300, total_distance_traveled)

	line_2d.set_point_position(1, Vector2.ZERO)
	line_2d.set_point_position(0, Vector2(-current_length, 0.0)) #change for differing length of tracer

func handle_collision(result: Dictionary) -> void:
	var collider = result.collider
	
	if collider.has_method("take_damage"):
		collider.take_damage(damage)
		
	
	queue_free()
