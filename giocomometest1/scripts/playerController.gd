extends CharacterBody2D


@export var walk_speed = 150.0
@export var jump_velocity = -400.0
@export var walljump = false
@export var run_speed = 300.0
@export_range(0, 1) var acceleration = 0.1
@export_range(0, 1) var deceleration = 0.1
@export_range(0, 1) var decellerate_on_jump_release = 0.5
@export var dash_speed = 1000.0
@export var dash_max_distance = 300.0
@export var dash_cooldown = 1.0
@export var health = 100
@export var damage_cooldown = 1.0
@onready var animated_sprite = $AnimatedSprite2D
@onready var player_hitbox = $CollisionShape2D2
@onready var player_crouch_hitbox = $PlayerCrouchHitbox/CollisionShape2D
var direction := Input.get_axis("left", "right")
var is_crouching = false
@export var hitbox_radius = 5
@export var hitbox_height = 16
@export var hitbox_position = -0.5



func charge_handler(delta):
	Global.aggiorna_ui.emit("DioPorco")
	

func crouch_handler():
	# Attiva hitbox crouch e cambia le dimensioni della hitbox normale
	player_hitbox.shape.radius = player_crouch_hitbox.shape.radius
	player_hitbox.shape.height = player_crouch_hitbox.shape.height
	player_hitbox.position.y = player_crouch_hitbox.position.y
	player_crouch_hitbox.disabled = false
	is_crouching = true


#gestisce il dash
func dash_handler(delta):
	var is_dashing = false
	var is_crashing = false
	var dash_start_position = 0
	var dash_direction = 0
	var dash_timer = 0

	var direction := Input.get_axis("left", "right")
	#fa partire il dash
	if Input.is_action_just_pressed("dash") and direction and not is_dashing and dash_timer <= 0:
		is_dashing = true
		dash_start_position = position.x
		dash_direction = direction
		dash_timer = dash_cooldown
		animated_sprite.flip_h = direction < 0
		animated_sprite.play("dash")
		
	if is_dashing:
		#Controlla se è stata superata la distanza massima del dash
		var current_distance = abs(position.x - dash_start_position)
		#ferma il dash
		if current_distance >= dash_max_distance or is_on_wall():
			is_dashing = false
		else:
			#aumenta la velocità in caso di dash
			velocity.x = dash_direction * dash_speed
			velocity.y = 0

		crouch_handler()

	#Decrementa il timer del dash
	if dash_timer > 0:
		dash_timer -= delta
	

#gestisce la corsa
func run_handler():
	var speed = walk_speed
	if Input.is_action_pressed("run"):
		speed = run_speed
	direction = Input.get_axis("left", "right")
		
	if (direction != 0):
		animated_sprite.flip_h = direction < 0
		if(Input.is_action_pressed("run")):
			animated_sprite.play("run")
		velocity.x = move_toward(velocity.x, direction * speed, walk_speed * acceleration)
	else:
		velocity.x = move_toward(velocity.x, 0, speed * deceleration)
		animated_sprite.play("idle")
		
		
		
func jump_handler():
	direction = Input.get_axis("left", "right")
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
		if(!Input.is_action_just_pressed("run")):
			animated_sprite.flip_h = direction < 0
			animated_sprite.play("jump")
		
	#gestice l'aggrapparsi al muro
	if is_on_wall() and not Input.is_action_just_pressed("jump") and walljump == true:
		velocity.y *= 0.9
		animated_sprite.flip_h = direction < 0
		animated_sprite.play("fall")
	
	#Gestisce il walljump
	if Input.is_action_just_pressed("jump") and is_on_wall() and walljump == true:
		velocity.y = jump_velocity
		if(!Input.is_action_just_pressed("run")):
			animated_sprite.flip_h = direction < 0
			animated_sprite.play("jump")
	
	#gestisce la caduta dopo il salto
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= decellerate_on_jump_release
		animated_sprite.flip_h = direction < 0
		animated_sprite.play("fall")
		


#sistema di danno DA COMPLETARE
func take_damage(damage):
	
	#if damage_cooldown > 0:
		#damage_cooldown -= delta
	if health > 0 and damage_cooldown == 0:
		health -= 10
	else:
		print("You died")
		

	





func _physics_process(delta: float) -> void:
	# Add the gravity.	
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	#imposta la direzione e le animazioni in caso di "inattività"
	direction = Input.get_axis("left", "right")
	if(!Input.is_anything_pressed() and is_on_floor()):
		animated_sprite.flip_h = direction < 0
		animated_sprite.play("idle")
	elif(!Input.is_anything_pressed() and !is_on_floor()):
		animated_sprite.flip_h = direction < 0
		animated_sprite.play("fall")
	
	#ripristina le hitbox dopo il dash
	if(!Input.is_action_pressed("dash")):
		player_hitbox.shape.radius = hitbox_radius
		player_hitbox.shape.height = hitbox_height
		player_hitbox.position.y = hitbox_position
		player_crouch_hitbox.disabled = true
		is_crouching = false
		


		
	jump_handler()
	run_handler()
	dash_handler(delta)
	charge_handler(delta)
	move_and_slide()
	
