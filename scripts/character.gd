extends CharacterBody2D
@onready var particles: CPUParticles2D = $CPUParticles2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@export_range(0.0, 180.0) var cone_angle_degrees := 60.0

enum Stance {STANDING, CROUCHING, CRAWLING}

var north = false
var south = false
var east = false
var west = false
var current_stance = Stance.STANDING

#mouse look & shooting
func _process(_delta: float) -> void:
	var mouse_pos = get_global_mouse_position()
	sprite.look_at(mouse_pos)
	if current_stance == Stance.STANDING:
		print("yes")
#movement
func _physics_process(_delta: float) -> void:
	var _mouse_direction = global_position.direction_to(get_global_mouse_position())
	var movement_direction := Input.get_vector("a","d", "w", "s").normalized()
	var speed: float = 250.0
	var boosted_speed: = speed * 1.8

	if movement_direction != Vector2.ZERO:
		if current_stance == Stance.STANDING:
			speed = speed
			boosted_speed = speed * 1.4
		elif current_stance == Stance.CROUCHING:
			speed = 150.0
			boosted_speed = speed * 1.6
		else:
			speed = 50.0
			boosted_speed = speed * 1.8

		if north and velocity.y < 0:
			speed = boosted_speed
		if south and velocity.y > 0:
			speed = boosted_speed
		if east and velocity.x > 0:
			speed = boosted_speed
		if west and velocity.x < 0:
			speed = boosted_speed

	if speed == boosted_speed and movement_direction:
		particles.emitting = true
	else: 
		particles.emitting = false
	velocity = movement_direction * speed


#standing -> crouching -> crawling toggle
	if Input.is_action_just_pressed("lower height") and current_stance == Stance.STANDING:
		current_stance = Stance.CROUCHING
		print("crouch")
	elif Input.is_action_just_pressed("lower height") and current_stance == Stance.CROUCHING:
		current_stance = Stance.CRAWLING
		print("crawl")
#crawling -> crouching -> standing toggle
	if Input.is_action_just_pressed("raise height") and current_stance == Stance.CRAWLING:
		current_stance = Stance.CROUCHING
		print("crouch")
	elif Input.is_action_just_pressed("raise height") and current_stance == Stance.CROUCHING:
		current_stance = Stance.STANDING
		print("standing")



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
