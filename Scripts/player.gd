extends CharacterBody2D

const GRAVITY = 1200
const JUMP_FORCE = -550
const SPEED = 200.0

var is_jumping = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = 0
	
	
	if !is_on_floor():
		velocity.x = direction * (SPEED - 100)
		velocity.y += GRAVITY * delta
	else:
		if not get_parent().game_running:
			$AnimatedSprite2D.play("idle")
		else:
			$AnimatedSprite2D.play("run")
			velocity.y = 0
	
	if (Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_up")) and is_on_floor():
		velocity.y = JUMP_FORCE
		is_jumping = true
		$AnimatedSprite2D.play("jump")
		$JumpSound.play()
	
	if is_jumping and velocity.y > 0:
		$AnimatedSprite2D.play("fall")
		
	
		
	move_and_slide()
