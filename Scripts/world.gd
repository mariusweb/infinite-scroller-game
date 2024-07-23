extends Node

#Obstacles
var saw_scene = preload("res://Scenes/saw.tscn")
var box_scene = preload("res://Scenes/box.tscn")
var obstacles : Array
var saw_heights = [520, 440]

const PLAYER_START_POSITION = Vector2i(72, 480)
const CAM_START_POSITION = Vector2i(240, 360)

const SPEED = 3
var score = 0
var screen_size : Vector2i
var platform_height : int
var game_running : bool
var paused = false
var last_obs

# Called when the node enters the scene tree for the first time.
func _ready():
	$GameOver.get_node("Button").pressed.connect(new_game)
	new_game()

func new_game():
	get_tree().paused = false
	
	#delete all obsticales
	for obs in obstacles:
		obs.queue_free()
	obstacles.clear()
	if last_obs:
		last_obs.queue_free()
		last_obs = null
		
	#reset the node
	screen_size = get_window().size
	get_platform_height()
	
	$Player.position = PLAYER_START_POSITION
	$Player.velocity = Vector2i(0, 0)
	$Camera2D.position = CAM_START_POSITION
	$Platform.position = Vector2i(0, 0)
	$Walls.position = Vector2i(0, 0)
	game_running = false
	$HUD.get_node("StartLabel").show()
	$HUD.get_node("PauseLabel").hide()
	$GameOver.hide()

func get_platform_height():
	var collision_shape = $Platform.get_node("CollisionShape2D")
	var shape = collision_shape.shape
	var rect_shape = shape as RectangleShape2D
	platform_height =  (rect_shape.extents.y * 2) * $Platform.scale.y
	generate_obs()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if game_running:
		generate_obs()
		
		$HUD.get_node("StartLabel").hide()
		if Engine.time_scale:
			$Player.position.x += SPEED
			$Camera2D.position.x += SPEED
			$Walls.position.x += SPEED
			
		if $Camera2D.position.x - $Platform.position.x > screen_size.x * 1.5 and Engine.time_scale:
			$Platform.position.x += screen_size.x
			
		# Remove obsticles that have gone off screen
		for obs in obstacles:
			if obs.position.x < ($Camera2D.position.x - screen_size.x):
				remove_obs(obs)
			
		if Input.is_action_just_pressed("pause"):
			paused = not paused
			toggle_pause()
			
	else:
		if Input.is_action_just_pressed("ui_accept") or Input.get_axis("ui_left", "ui_right"):
			game_running = true

func generate_obs():
	if not paused:
		score += SPEED
		
	if obstacles.is_empty() or last_obs.position.x < score + randi_range(0, 30):
		var obs 
		var max_obs = 3
		for i in range(randi() % max_obs + 1):
			obs = box_scene.instantiate()
			var obs_height = obs.get_node("Sprite2D").texture.get_height()
			var obs_scale = obs.scale
			var obs_x : int = screen_size.x + score + 500 + (i * 64)
			var obs_y : int = screen_size.y - platform_height - (obs_height * obs_scale.y / 2) + 6
			last_obs = obs
			add_obs(obs, obs_x, obs_y)
		if (randi() % 2) == 0:
			obs = saw_scene.instantiate()
			var obs_x : int = screen_size.x + score + 100
			var obs_y : int = saw_heights[randi() % saw_heights.size()]
			add_obs(obs, obs_x, obs_y)

func add_obs(obs, x, y):
	obs.position = Vector2i(x, y)
	obs.body_entered.connect(hit_obs)
	add_child(obs)
	obstacles.append(obs)
	
func remove_obs(obs):
	obs.queue_free()
	obstacles.erase(obs)
	
func hit_obs(body):
	if body.name == "Player":
		$Player.get_node("AnimatedSprite2D").play("damage")
		game_over()

func toggle_pause():
	if paused:
		$HUD.get_node("PauseLabel").show()
		Engine.time_scale = 0
	else:
		$HUD.get_node("PauseLabel").hide()
		Engine.time_scale = 1
	
func game_over():
	score = 0
	game_running = false
	get_tree().paused = true
	$GameOver.show()
