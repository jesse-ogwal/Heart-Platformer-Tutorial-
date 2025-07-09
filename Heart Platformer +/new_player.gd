extends CharacterBody2D

@export var new_movement_data : NewPlayerMovementData

var air_jump = false
var just_wall_jumped = false
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var was_wall_normal = Vector2.ZERO

var dashDirection = Vector2(1, 0)
var canDash = false
var dashing = false

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var coyote_jump_timer = $CoyoteJumpTimer
@onready var starting_position = global_position
@onready var wall_jump_timer = $WallJumpTimer

#sfx
@onready var sfx_jump = $sfx_jump
@onready var sfx_wall_bounce = $sfx_wall_bounce
@onready var sfx_walk2 = $sfx_walk2
@onready var sfx_walk_2 = $sfx_walk2




func _physics_process(delta):
	apply_gravity(delta)
	handle_wall_jump()
	handle_jump()
	var input_axis = Input.get_axis("move_left", "move_right")
	handle_acceleration(input_axis, delta)
	handle_air_acceleration(input_axis, delta)
	apply_friction(input_axis, delta)
	apply_air_resistance(input_axis, delta)
	dash()

	var was_on_floor = is_on_floor()
	var was_on_wall = is_on_wall_only()
	if was_on_wall:
		was_wall_normal = get_wall_normal()
	move_and_slide()
	var just_left_ledge = was_on_floor and not is_on_floor() and velocity.y >= 0
	if just_left_ledge:
		coyote_jump_timer.start()
	just_wall_jumped = false
	var just_left_wall = was_on_wall and not is_on_wall()
	if just_left_ledge:
		wall_jump_timer.start()
	update_animations(input_axis)
	

func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * new_movement_data.gravity_scale * delta
		
func handle_wall_jump():
	if not is_on_wall_only() and wall_jump_timer.time_left <= 0.0 : return
	var wall_normal = get_wall_normal()
	if wall_jump_timer.time_left > 0.0:
		wall_normal = was_wall_normal
	if Input.is_action_just_pressed("jump"):
		velocity.x = wall_normal.x * new_movement_data.speed
		velocity.y = new_movement_data.jump_velocity
		just_wall_jumped = true
		sfx_wall_bounce.play()
	

func dash():
	if is_on_floor():
		canDash = true
		
	var walking = false
		
	if Input.is_action_pressed("ui_right"):
		dashDirection = Vector2(1,0)
		walking = true
	if Input.is_action_pressed("ui_left"):
		dashDirection = Vector2(-1, 0)
		walking = true
		
	if walking and is_on_floor() and not sfx_walk2.is_playing():
		sfx_walk2.play()
	
	if Input.is_action_just_pressed("dash") and canDash and not is_on_floor():
		velocity = dashDirection.normalized() * 300
		canDash = false
		dashing = true
		await get_tree().create_timer(0.2).timeout
		dashing = false
		
func handle_jump():
	if is_on_floor(): air_jump = true
	
	if is_on_floor() or coyote_jump_timer.time_left > 0:
		if Input.is_action_pressed("jump"):
			velocity.y = new_movement_data.jump_velocity
			coyote_jump_timer.stop()
			sfx_jump.play()
			
	if not is_on_floor():
		if Input.is_action_just_released("jump") and velocity.y < new_movement_data.jump_velocity / 2:
			velocity.y = new_movement_data.jump_velocity / 2
			
		if Input.is_action_just_pressed("jump") and air_jump and not just_wall_jumped:
			velocity.y = new_movement_data.jump_velocity * 0.8
			air_jump = false
			sfx_jump.play()
			
func handle_acceleration(input_axis, delta):
	if not is_on_floor(): return
	if input_axis != 0:
		velocity.x = move_toward(velocity.x, new_movement_data.speed * input_axis, new_movement_data.acceleration * delta)

func handle_air_acceleration(input_axis, delta):
	if is_on_floor() : return
	if input_axis != 0:
		velocity.x = move_toward(velocity.x, new_movement_data.speed * input_axis, new_movement_data.air_acceleration * delta)
		
func apply_friction(input_axis, delta):
	if input_axis == 0 and is_on_floor():
		velocity.x = move_toward(velocity.x, 0 , new_movement_data.friction * delta)
	
func apply_air_resistance(input_axis, delta):
	if input_axis == 0 and not is_on_floor():
		velocity.x = move_toward(velocity.x, 0, new_movement_data.air_resistance * delta)

func update_animations(input_axis):
	if input_axis != 0:
		animated_sprite_2d.flip_h = (input_axis < 0)
		animated_sprite_2d.play("run")
	else:
		animated_sprite_2d.play("idle")
	
	if not is_on_floor():
		animated_sprite_2d.play("jump")


func _on_hazard_detector_area_entered(area):
	global_position = starting_position # Replace with function body.
