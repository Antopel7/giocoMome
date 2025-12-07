extends CharacterBody2D

var direction := Input.get_axis("left", "right")
var last_direction = 1  # Memorizza l'ultima direzione (1 = destra, -1 = sinistra)

@export var walk_speed = 150.0
@export var jump_velocity = -300.0
@export var walljump = false

@export var run_speed = 200.0
@export_range(0, 1) var acceleration = 0.1
@export_range(0, 1) var deceleration = 0.1
@export_range(0, 1) var decellerate_on_jump_release = 0.5

# Variabili per il dash

@export var dash_speed = 1000.0
@export var dash_max_distance = 300.0
@export var dash_cooldown = 1.0
var is_dashing = false
var dash_start_position = 0
var dash_direction = 0
var dash_timer = 0
var can_uncrouch = false
var is_crouching = false


@export var health = 100
@export var damage_cooldown = 1.0
var can_take_damage = true

@onready var animated_sprite = $AnimatedSprite2D
@onready var player_hitbox = $CollisionShape2D2
@onready var player_crouch_hitbox = $PlayerCrouchHitbox/CollisionShape2D
@export var hitbox_radius = 5
@export var hitbox_height = 16
@export var hitbox_position = -0.5

@onready var attack_area = $AttackArea
@onready var attack_hitbox = $AttackArea/CollisionShape2D
@export var attack_damage = 25
@export var attack_duration = 0.3
var is_attacking = false
var attack_cooldown_timer = 0.0
@export var attack_cooldown_time = 0.5

# Area2D per rilevare le HeatZone (stessa logica dell'AttackArea)
@onready var heat_detection_area = $HeatDetectionArea
@onready var heat_detection_hitbox = $HeatDetectionArea/CollisionShape2D

#Variabili Calorometro
@export_range(0,100) var heat = 0
@export var heat_increase = 20  # Aumento heat al secondo quando sei nella zona
@export var heat_depletion = false
@export var heat_decrease = 5   # Diminuzione heat al secondo quando sei fuori
var is_heated = false
var is_in_heat_zone = false  # TRUE quando il player è nella zona calda


func heat_handler():
	is_heated = true
	heat += heat_increase

# Chiamate dalla HeatZone quando il player entra/esce
func enter_heat_zone():
	is_in_heat_zone = true
	print("Entrando nella zona calda!")

func exit_heat_zone():
	is_in_heat_zone = false
	print("Uscendo dalla zona calda!")

# Aggiorna il calore gradualmente
func update_heat(delta):
	if is_in_heat_zone:
		# Aumenta rapidamente il calore quando sei nella zona
		heat += heat_increase * delta
		heat = clamp(heat, 0, 100)  # Limita tra 0 e 100
	elif(heat_depletion):
		# Diminuisce gradualmente il calore quando sei fuori
		heat -= heat_decrease * delta
		heat = clamp(heat, 0, 100)
	
	# Aggiorna l'UI se necessario
	# Global.aggiorna_ui.emit("heat_updated")


func charge_handler(delta):
	Global.aggiorna_ui.emit("DioPorco")
	
func _ready():
	#segnale per rilevare i nemici colpiti
	attack_area.body_entered.connect(_on_attack_area_body_entered)
	attack_hitbox.disabled = true


func attack_handler():
	if is_dashing or is_crouching:
		return
	
	# Controlla se può attaccare
	if Input.is_action_just_pressed("attack") and !is_attacking and attack_cooldown_timer <= 0:
		is_attacking = true
		attack_cooldown_timer = attack_cooldown_time
		
		# Posiziona l'hitbox nella direzione corretta
		if animated_sprite.flip_h:
			attack_area.scale.x = -1  # Metti l'attacco a sinistra
		else:
			attack_area.scale.x = 1   # Metti l'attacco a destra
		
		# Attiva l'animazione di attacco
		#animated_sprite.play("attack")
		
		# Abilita l'hitbox
		attack_hitbox.disabled = false
		
		# Disabilita l'hitbox dopo la durata dell'attacco
		await get_tree().create_timer(attack_duration).timeout
		attack_hitbox.disabled = true
		is_attacking = false
		
func _on_attack_area_body_entered(body):
	# Controlla se il corpo colpito ha una funzione per ricevere danni
	if body == self:
		return
	if body.has_method("take_damage") and attack_hitbox.disabled == false :
		body.take_damage(attack_damage)
		print("Colpito: ", body.name)
		
		
func crouch_handler():
	if !is_crouching:
		walk_speed -= 50 
		player_hitbox.shape.radius = player_crouch_hitbox.shape.radius
		player_hitbox.shape.height = player_crouch_hitbox.shape.height
		player_hitbox.position.y = player_crouch_hitbox.position.y
		player_crouch_hitbox.disabled = false
		is_crouching = true
		can_uncrouch = false
		
		# Aspetta 2 secondi prima di permettere di alzarsi
		await get_tree().create_timer(1.0).timeout
		can_uncrouch = true

func uncrouch():
	if is_crouching and can_uncrouch:
		
		player_hitbox.shape.radius = hitbox_radius
		player_hitbox.shape.height = hitbox_height
		player_hitbox.position.y = hitbox_position
		player_crouch_hitbox.disabled = true
		is_crouching = false
		can_uncrouch = false

#func dash_handler(delta):
	## Controlla se premere dash mentre sei accovacciato (per alzarsi)
	#if Input.is_action_just_pressed("dash") and is_crouching and can_uncrouch:
		#uncrouch()
		#walk_speed += 50
		#return
	#
	## Fa partire il dash
	#if Input.is_action_just_pressed("dash") and direction and !is_dashing and dash_timer <= 0 and !is_crouching:
		#is_dashing = true
		#dash_start_position = position.x
		#dash_direction = direction
		#dash_timer = dash_cooldown
		#animated_sprite.flip_h = dash_direction < 0
		#animated_sprite.play("dash")
		#
	#if is_dashing:
		## Mantieni l'animazione dash
		#animated_sprite.play("dash")
		#
		## Controlla se è stata superata la distanza massima del dash
		##var current_distance = abs(position.x - dash_start_position)
		## Ferma il dash
		##if current_distance >= dash_max_distance or is_on_wall():
#
		#velocity.x = move_toward(position.x, direction * (position.x + 700), dash_speed)
		#await get_tree().create_timer(1.0).timeout
		#is_dashing = false
		#
		#crouch_handler()  # Si accovaccia quando finisce il dash
		##else:
			### Aumenta la velocità in caso di dash
			##velocity.x = dash_direction * dash_speed
			##velocity.y = 0
#
	## Decrementa il timer del dash
	#if dash_timer > 0:
		#dash_timer -= delta

func dash_handler(delta):
	# Controlla se premere dash mentre sei accovacciato (per alzarsi)
	if Input.is_action_just_pressed("dash") and is_crouching and can_uncrouch:
		uncrouch()
		walk_speed += 50
		return
	
	# Fa partire il dash
	if Input.is_action_just_pressed("dash") and direction and !is_dashing and dash_timer <= 0 and !is_crouching:
		is_dashing = true
		dash_start_position = position.x
		dash_direction = direction
		dash_timer = dash_cooldown
		animated_sprite.flip_h = dash_direction < 0
		animated_sprite.play("dash")
		velocity.y = 0  # Azzera la velocità verticale all'inizio del dash
		
	if is_dashing:
		# Mantieni l'animazione dash
		animated_sprite.play("dash")
		
		# Mantieni la velocità verticale a zero durante il dash
		velocity.y = 0
		velocity.x = dash_direction * dash_speed
		
		# Aspetta la fine del dash
		await get_tree().create_timer(0.3).timeout  # Ridotto per un dash più rapido
		is_dashing = false
		
		crouch_handler()  # Si accovaccia quando finisce il dash

	# Decrementa il timer del dash
	if dash_timer > 0:
		dash_timer -= delta

func run_handler():
	# Non cambiare animazione se stai dashando
	if is_dashing:
		return
	
	# Aggiorna last_direction quando c'è input
	if direction != 0:
		last_direction = direction
		
	if direction != 0:
		animated_sprite.flip_h = direction < 0
		if !is_crouching:
			animated_sprite.play("run")
		else:
			animated_sprite.play("dash")

		velocity.x = move_toward(velocity.x, direction * run_speed, walk_speed * acceleration)
	else:
		velocity.x = move_toward(velocity.x, 0, run_speed * deceleration)
		#if !is_crouching:
			#animated_sprite.play("idle")

func jump_handler():
	# Non permettere salti durante il dash
	if is_dashing:
		return
		
	direction = Input.get_axis("left", "right")
	
	# Aggiorna last_direction quando c'è input
	if direction != 0:
		last_direction = direction
	
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
		if !Input.is_action_just_pressed("run"):
			animated_sprite.flip_h = last_direction < 0
			if !is_crouching:
				animated_sprite.play("jump")
		
	# Gestisce l'aggrapparsi al muro
	if is_on_wall() and not Input.is_action_just_pressed("jump") and walljump == true:
		velocity.y *= 0.9
		animated_sprite.flip_h = last_direction < 0
		if !is_crouching:
			animated_sprite.play("fall")
	
	# Gestisce il walljump
	if Input.is_action_just_pressed("jump") and is_on_wall() and walljump == true:
		velocity.y = jump_velocity
		if !Input.is_action_just_pressed("run"):
			animated_sprite.flip_h = last_direction < 0
			if !is_crouching:
				animated_sprite.play("jump")
	
	# Gestisce la caduta dopo il salto
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= decellerate_on_jump_release
		animated_sprite.flip_h = last_direction < 0
		if !is_crouching:
			animated_sprite.play("fall")

func take_damage(damage):
	if not can_take_damage:
		return
	
	print(health)
	
	can_take_damage = false
	health -= 10
	
	if health <= 0:
		print("You died")
		get_tree().reload_current_scene()
		return
	
	await get_tree().create_timer(damage_cooldown).timeout
	
	if is_inside_tree():
		can_take_damage = true

func _physics_process(delta: float) -> void:
	print(heat)

	# Add the gravity SOLO se non stai dashando
	if not is_on_floor() and !is_dashing:
		velocity += get_gravity() * delta
		
	if attack_cooldown_timer > 0:
		attack_cooldown_timer -= delta
	
	
	# Imposta la direzione e le animazioni in caso di "inattività"
	direction = Input.get_axis("left", "right")
	
	# Aggiorna last_direction quando c'è input
	if direction != 0:
		last_direction = direction
	
	if !Input.is_anything_pressed() and is_on_floor() and !is_crouching:
		animated_sprite.flip_h = last_direction < 0
		animated_sprite.play("idle")
	elif !Input.is_anything_pressed() and !is_on_floor() and !is_crouching:
		animated_sprite.flip_h = last_direction < 0
		animated_sprite.play("fall")
		
		


	jump_handler()
	run_handler()
	dash_handler(delta)
	attack_handler()
	charge_handler(delta)
	update_heat(delta)  # Aggiorna il calore ogni frame
	move_and_slide()
