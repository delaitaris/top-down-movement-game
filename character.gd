extends CharacterBody2D
@onready var sprite: Sprite2D = $"Sprite2D"
@onready var muzzle: Marker2D = $Muzzle
@export var projectile: PackedScene


const SPEED = 300

#mouse look & shooting
func _process(delta: float) -> void:
	var mouse_pos = get_global_mouse_position()
	sprite.look_at(mouse_pos)
	if Input.is_action_just_pressed("shoot"):
		shoot()

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

func shoot() -> void:
	projectile.global_position = muzzle.global_position
	projectile.direction = Vector2.RIGHT.rotated(global_rotation)
	projectile.rotation = global_rotation

	move_and_slide()
