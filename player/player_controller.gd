extends CharacterBody2D

const GRAVITY = 1000

@onready var animated_sprite_2d = $AnimatedSprite2D

# Default values for player attributes – can be adjusted in Editor
@export var run_speed : int = 1000
@export var v_jump_speed = -350
@export var h_jump_speed = 1000
@export var v_dbl_jump_speed = -350
@export var h_dbl_jump_speed = 1500
@export var slow_down_speed = 1700

@export var max_player_horizonal_speed : int = 300
@export var max_h_jump_speed = 250
@export var max_h_dbl_jump_speed = 200

enum State { Idle, Run, Jump, DoubleJump, Shoot, Falling }

# Dynamically typed variables can recieve anything, not so with statically typed
var current_state : State # setting up static typing to remove ambiguity


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

"""
func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
"""

func _ready():
	current_state = State.Idle

func _physics_process(delta : float):
	player_falling(delta)
	player_idle(delta)
	player_run(delta)
	player_jump(delta)
	#player_shooting(delta)
	
	move_and_slide()
	
	# Call player animations AFTER updating the State w/ the Physics funtions
	player_animations()
	
	print("State: ", State.keys()[current_state])

func player_falling(delta : float):
	if !is_on_floor(): #built into CharacterBody2D, press F1 for docs 
		velocity.y += 1000 * delta

func player_idle(delta : float):
	if is_on_floor(): #built into CharacterBody2D, press F1 for docs 
		current_state = State.Idle;

func player_run(delta : float):
	if !is_on_floor():
		return
	
	# Input has been set up in Project Settings > Input Map
	# Q: What type of var is direction?
	var direction = input_movement()
	
	if direction:
		velocity.x += direction * run_speed * delta
		velocity.x = clamp(velocity.x, -max_player_horizonal_speed, max_player_horizonal_speed)
	else:
		velocity.x = move_toward(velocity.x, 0, slow_down_speed * delta)
		
	if direction != 0:
		# use a ternary statement to handle sprite flips!
		current_state = State.Run
		animated_sprite_2d.flip_h = false if direction < 0 else true

func player_jump(delta : float):

	if current_state == State.DoubleJump:
		var direction = input_movement()
		velocity.x += direction * h_dbl_jump_speed * delta
		velocity.x = clamp(velocity.x, -max_h_dbl_jump_speed, max_h_dbl_jump_speed)
		animated_sprite_2d.flip_h = false if direction < 0 else true
		return
		
	if Input.is_action_just_pressed("jump"):
		# we do this bc our y coordinates for our level are currently negative.
		current_state = State.Jump if current_state != State.Jump else State.DoubleJump
		
		# if on the ground when "jump" was pressed, go into the air
		if current_state == State.Jump:
			velocity.y = v_jump_speed
		elif current_state == State.DoubleJump: 
			velocity.y = v_dbl_jump_speed
		
	# if in the air
	if !is_on_floor():
		var direction = input_movement()
		
		if current_state == State.Jump:
			velocity.x += direction * h_jump_speed * delta
			velocity.x = clamp(velocity.x, -max_h_jump_speed, max_h_jump_speed)
		elif current_state == State.DoubleJump: 
			velocity.x += direction * h_dbl_jump_speed * delta
			velocity.x = clamp(velocity.x, -max_h_dbl_jump_speed, max_h_dbl_jump_speed)
			
		animated_sprite_2d.flip_h = false if direction < 0 else true
		


"""
func player_shooting(delta : float):
	var direction = input_movement()
	
	if direction != 0 and Input.is_action_just_pressed("shoot"):
		var bullet_instance = bullet.instantiate() as Node2D
		bullet_instance.global_position = muzzle.global_position
		# Stopping at 7:49 for now.
		# https://www.youtube.com/watch?v=ecAzAtQIh7M&list=PLWTXKdBN8RZdvd3bbCC4mg2kHo3NNnBz7&index=12&ab_channel=RapidVectors
		current_state = State.Shoot
"""

func player_animations():
	if current_state == State.Idle:
		animated_sprite_2d.play("idle")
	elif current_state == State.Run:
		animated_sprite_2d.play("walk")
	elif current_state == State.Jump:
		animated_sprite_2d.play("jump")	#
	elif current_state == State.Falling:
		animated_sprite_2d.play("falling")
	#elif current_state == State.Shoot:
		#animated_sprite_2d.play("run_shoot")

func input_movement():
	var direction : float = Input.get_axis("move_left", "move_right")
	return direction
