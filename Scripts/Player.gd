extends CharacterBody3D

@export var walk_speed := 5.0
@export var run_speed := 250.0
@export_range(0, 1) var acceleration := 0.1
@export_range(0, 1) var deceleration := 0.1

@export var jump_force := 7.0 # in 3D, positive Y is up
@export_range(0, 1) var decelerate_on_jump_release := 0.5

@export var dash_speed := 1000.0
@export var dash_max_distance := 3.0 # world units
@export var dash_curve : Curve
@export var dash_cooldown := 1.0
@export var current_distance := 0.0

@export var wall_stick_time := 0.5 
@export var wall_slide_speed := 1.5 
var wall_timer := 0.0
var is_wall_clinging := false

@onready var anim: AnimatedSprite3D = $AnimatedSprite3D

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var is_dashing := false
var dash_start_x := 0.0
var dash_direction := 0.0
var dash_timer := 0.0

func _physics_process(delta: float):
	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	if is_on_wall() and not is_on_floor():
		if wall_timer <= 0.0:
			wall_timer = wall_stick_time
			is_wall_clinging = true
		
		if is_wall_clinging:
			velocity.y = 0
			wall_timer -= delta
			if wall_timer <= 0.0:
				velocity.y -= gravity * delta
	else:
		is_wall_clinging = false
		wall_timer = 0.0

	# Determine speed
	var speed := run_speed if Input.is_action_pressed("run") else walk_speed

	# Get horizontal input
	var direction := Input.get_axis("left", "right") # -1, 0, 1

	# Handle movement
	if direction != 0.0:
		velocity.x = move_toward(velocity.x, direction * speed, speed * acceleration)
		if is_on_floor():
			anim.play("WalkAnimation" if Input.is_action_pressed("run") else "WalkAnimation")
	else:
		velocity.x = move_toward(velocity.x, 0.0, walk_speed * deceleration)
		if is_on_floor():
			anim.play("IdleAnimation")

	# Handle jump
	if Input.is_action_just_pressed("jump") and (is_on_floor() or is_on_wall()):
		velocity.y = jump_force
		anim.play("JumpAnimation")

	if Input.is_action_just_released("jump") and velocity.y > 0:
		velocity.y *= decelerate_on_jump_release

	# Handle dash input
	if Input.is_action_just_pressed("dash") and direction != 0.0 and not is_dashing and dash_timer <= 0.0:
		is_dashing = true
		dash_start_x = position.x
		dash_direction = direction
		dash_timer = dash_cooldown
		current_distance = 0.0

   

	# Dash cooldown
	if dash_timer > 0.0:
		dash_timer -= delta

	# Move the character
	move_and_slide()
