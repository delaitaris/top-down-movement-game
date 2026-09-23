extends CharacterBody2D
@onready var particles: CPUParticles2D = $CPUParticles2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var light: PointLight2D = $Flashlight
@onready var flashlightblock: LightOccluder2D = $FlashlightOccluder
@onready var muzzle: Marker2D = $Muzzle
@onready var muzzleflash: PointLight2D = $Muzzleflash
@onready var timerflash: Timer = $Muzzleflash/Timer
@onready var muzzleblock: LightOccluder2D = $MuzzleOccluder
@onready var lightdarkentimer: Timer = $LightDarkener
@onready var lightdarkencanvas: CanvasModulate = $LightDarkener/CanvasModulate
@onready var flashlight_toggle: PointLight2D = $Flashlight
@onready var reloadtimer: Timer = $Muzzle/Reload
@onready var pistolreloadsfx: AudioStreamPlayer2D = $PistolReload
@onready var pistolshootcooldown: Timer = $Muzzle/ShootCooldown

@export_range(0.0, 180.0) var cone_angle_degrees := 60.0
@export var bullet_scene: PackedScene

enum Gun {PISTOL, RIFLE, SHOTGUN, UNARMED}
enum Stance {STANDING, CROUCHING, CRAWLING}

var north = false
var south = false
var east = false
var west = false
var current_stance = Stance.STANDING
var shootcooldown = false
var reloading = false
var cooldowntime = 1
var current_gun = Gun.UNARMED
var pistolmagazine = 7
var pistolmagazinemax = 1
var riflemagazine = 30
var riflemagazinemax = 1
var shotgunmagazine = 5
var shotgunmagazinemax = 1


func _ready() -> void:
	muzzleflash.shadow_enabled = true

#mouse look & shooting
func _process(_delta: float) -> void:
	var mouse_pos = get_global_mouse_position()
	light.look_at(mouse_pos)
	flashlightblock.look_at(mouse_pos)
	sprite.look_at(mouse_pos)
	muzzle.look_at(mouse_pos)
	muzzleblock.look_at(mouse_pos)
	if current_gun == Gun.PISTOL:
		cooldowntime = 0.2
	if current_gun == Gun.RIFLE:
		cooldowntime = 0.1
	if current_gun == Gun.SHOTGUN:
		cooldowntime = 0.8

	if Input.is_action_pressed("shoot") and !shootcooldown and !reloading and current_gun == Gun.RIFLE:
		shoot_auto()

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

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("shoot") and !shootcooldown and !reloading and current_gun != Gun.RIFLE:
		if current_gun == Gun.PISTOL:
			shoot()
			pistolmagazine -= 1
			print(pistolmagazine)
			if pistolmagazine <= 0:
				pistolmagazine = 0
			pistolshootcooldown.start(cooldowntime)
			shootcooldown = true
		if current_gun == Gun.SHOTGUN:
			shoot()
			shotgunmagazine -= 1
			if shotgunmagazine <= 0:
				shotgunmagazine = 0
			pistolshootcooldown.start(cooldowntime)
			shootcooldown = true
	else:
		pass

	if Input.is_action_just_pressed("reload"):
		reload()
	if Input.is_action_just_pressed("flashlight"):
		flashlight()
	
	
	if Input.is_action_just_pressed("1"):
		current_gun = Gun.UNARMED
		shootcooldown = true
	elif Input.is_action_just_pressed("2"):
		current_gun = Gun.PISTOL
		pistolmagazinemax = 7
	elif Input.is_action_just_pressed("3"):
		current_gun = Gun.RIFLE
		riflemagazinemax = 30
	elif Input.is_action_just_pressed("4"):
		current_gun = Gun.SHOTGUN
		shotgunmagazinemax = 5


func shoot() -> void:
	if not bullet_scene:
		return

	# 1. PISTOL CHECK: Must be holding the pistol AND have ammo
	if current_gun == Gun.PISTOL and pistolmagazine > 0:
		$Muzzleflash.texture_scale = randf_range(4, 6)
		$Muzzleflash.energy = randf_range(1.5, 2.5)
		muzzleflash.enabled = true
		timerflash.start()
		
		# Only instantiate the bullet if we pass the ammo check
		var bullet = bullet_scene.instantiate()
		bullet.global_position = muzzle.global_position
		bullet.global_rotation = muzzle.global_rotation
		get_tree().current_scene.add_child(bullet)

	# 2. SHOTGUN CHECK: Must be holding the shotgun AND have ammo
	elif current_gun == Gun.SHOTGUN and shotgunmagazine > 0:
		$Muzzleflash.texture_scale = randf_range(4, 6)
		$Muzzleflash.energy = randf_range(1.5, 2.5)
		muzzleflash.enabled = true
		timerflash.start()
		
		# For a shotgun, we run a loop to spawn multiple pellets at once
		var bullet = bullet_scene.instantiate()
		bullet.global_position = muzzle.global_position
		bullet.global_rotation = muzzle.global_rotation
		get_tree().current_scene.add_child(bullet)

func shoot_auto() -> void:
	var bullet = bullet_scene.instantiate()
	if current_gun == Gun.RIFLE and riflemagazine != 0:
		pistolshootcooldown.wait_time = 0.15
		pistolshootcooldown.start()
		muzzleflash.enabled = true
		timerflash.start()
	if not bullet_scene:
		return
	bullet.global_position = muzzle.global_position
	bullet.global_rotation = muzzle.global_rotation
	if riflemagazine != 0 and shootcooldown == false and current_gun == Gun.RIFLE:
		riflemagazine -= 1
		shootcooldown = true
		get_tree().current_scene.add_child(bullet)
	
	
func flashlight() -> void:
	if flashlight_toggle.enabled == false:
		flashlight_toggle.enabled = true
	else:
		flashlight_toggle.enabled = false

func reload() -> void:
	if current_gun == Gun.PISTOL:
		if pistolmagazine < 7:
			reloading = true
			reloadtimer.start()
			if pistolreloadsfx.playing == false:
				pistolreloadsfx.play()
	if current_gun == Gun.RIFLE:
		if pistolmagazine < 30:
			reloading = true
			reloadtimer.start()
			if pistolreloadsfx.playing == false:
				pistolreloadsfx.play()
	if current_gun == Gun.SHOTGUN:
		if pistolmagazine < 5:
			reloading = true
			reloadtimer.start()
			if pistolreloadsfx.playing == false:
				pistolreloadsfx.play()
	else:
		return

func _on_timer_timeout() -> void:
	muzzleflash.enabled = false
	lightdarkentimer.start()
	lightdarkencanvas.color = Color(Color(0.2, 0.2, 0.188))

func _on_light_darkener_timeout() -> void:
	lightdarkencanvas.color = Color(Color(0.2, 0.2, 0.188))

func _on_reload_timeout() -> void:
	if current_gun == Gun.PISTOL:
		pistolmagazine = pistolmagazinemax
	if current_gun == Gun.RIFLE:
		riflemagazine = riflemagazinemax
	if current_gun == Gun.SHOTGUN:
		shotgunmagazine = shotgunmagazinemax
	reloading = false

func _on_shoot_cooldown_timeout() -> void:
	shootcooldown = false
