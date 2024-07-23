extends Area2D


var screen_size : Vector2i

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not get_parent().paused and get_parent().game_running:
		position.x -= get_parent().SPEED / 4
