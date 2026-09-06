extends AnimatedSprite2D
enum Stance {STANDING, CROUCHING, CRAWLING}
var current_stance = Stance.STANDING

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	play("default")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("lower height"):
		match current_stance:
			Stance.STANDING: 
				current_stance = Stance.CROUCHING
				play("crouch")
			Stance.CROUCHING:
				current_stance = Stance.CRAWLING
				play("crawl")
	if Input.is_action_just_pressed("raise height"):
		match current_stance:
			Stance.CROUCHING: 
				current_stance = Stance.STANDING
				play("default")
			Stance.CRAWLING:
				current_stance = Stance.CROUCHING
				play("crouch")
