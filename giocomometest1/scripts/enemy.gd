extends CharacterBody2D

@export var health = 100
@export var speed = 5
@export var damage_cooldown = 1.0

var player: Node2D  

func _ready() -> void:
	player = get_node("/root/game/player")
	
	
func take_damage(damage):
	if health > 0 and damage_cooldown == 0:
		health -= damage
	else:
		queue_free()

func _physics_process(delta: float) -> void:
	
	
	if not is_on_floor():
		velocity += get_gravity() * delta
		
		
	#if (player.position.x - position.x ) > 0:
			#velocity.x += speed
	#else:
		#velocity.x -= speed
	move_and_slide()



			
