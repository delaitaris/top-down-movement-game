extends CharacterBody2D
@onready var particles: CPUParticles2D = $CPUParticles2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@export_range(0.0, 180.0) var cone_angle_degrees := 60.0
@export var normal_speed: float = 250.0
@export var boosted_speed: float = 320.0

var north = false
var south = false
var east = false
var west = false

#mouse look & shooting
func _process(_delta: float) -> void:
	var mouse_pos = get_global_mouse_position()
	sprite.look_at(mouse_pos)

#movement
func _physics_process(_delta: float) -> void:
	var _mouse_direction = global_position.direction_to(get_global_mouse_position())
	var movement_direction := Input.get_vector("a","d", "w", "s").normalized()
	var speed: float = normal_speed

	if movement_direction != Vector2.ZERO:
			if north and velocity.y < -100:
				speed = boosted_speed
			if south and velocity.y > 100:
				speed = boosted_speed
			if east and velocity.x > 100:
				speed = boosted_speed
			if west and velocity.x < -100:
				speed = boosted_speed

	if speed == boosted_speed and movement_direction:
		particles.emitting = true
	else: 
		particles.emitting = false
	velocity = movement_direction * speed
	move_and_slide()


# POLES CHECKING

#north
func _on_north_mouse_entered() -> void:
	print("north")
	north = true
func _on_north_mouse_exited() -> void:
	north = false
#south
func _on_south_mouse_entered() -> void:
	print("south")
	south = true
func _on_south_mouse_exited() -> void:
	south = false
#west
func _on_west_mouse_entered() -> void:
	print("west")
	west = true
func _on_west_mouse_exited() -> void:
	west = false
#east
func _on_east_mouse_entered() -> void:
	print("east")
	east = true
func _on_east_mouse_exited() -> void:
	east = false
