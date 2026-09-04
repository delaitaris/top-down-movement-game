extends CharacterBody2D
@onready var sprite: Sprite2D = $"Sprite2D"
@export_range(0.0, 180.0) var cone_angle_degrees := 45.0
@export var normal_speed: float = 150.0
@export var boosted_speed: float = 300.0

#mouse look & shooting
func _process(delta: float) -> void:
	var mouse_pos = get_global_mouse_position()
	sprite.look_at(mouse_pos)

#movement
func _physics_process(delta: float) -> void:
	var mouse_direction = global_position.direction_to(get_global_mouse_position())
	var movement_direction := Input.get_vector("a","d", "s", "w")
	var speed: float = normal_speed
	
	if movement_direction != Vector2.ZERO:
		var cone_limit = cos(deg_to_rad(cone_angle_degrees))
		var alignment: float = movement_direction.normalized().dot(mouse_direction)
		
		if alignment >= cone_limit:
			speed = boosted_speed

	velocity = movement_direction * speed
	move_and_slide()
