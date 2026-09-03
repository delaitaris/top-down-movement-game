extends CharacterBody2D
@onready var sprite: Sprite2D = $"Sprite2D"

const SPEED = 300

#mouse look
func _process(delta: float) -> void:
	var mouse_pos = get_global_mouse_position()
	sprite.look_at(mouse_pos)

#movement
func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("w"):
		velocity.y = -SPEED
	if Input.is_action_pressed("s"):
		velocity.y = SPEED
	if Input.is_action_pressed("a"):
		velocity.x = -SPEED
	if Input.is_action_pressed("d"):
		velocity.x = SPEED
	if Input.is_action_just_released("w"):
		velocity.y = move_toward(velocity.y, 0, SPEED)
	if Input.is_action_just_released("s"):
		velocity.y = move_toward(velocity.y, 0, SPEED)
	if Input.is_action_just_released("a"):
		velocity.x = move_toward(velocity.x, 0, SPEED)
	if Input.is_action_just_released("d"):
		velocity.x = move_toward(velocity.x, 0, SPEED)



	move_and_slide()
