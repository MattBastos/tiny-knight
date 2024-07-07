extends Node

@export var SPEED: float = 1;

var enemy: Enemy;
var sprite: AnimatedSprite2D;

func _ready():
	enemy = get_parent();
	sprite = enemy.get_node("AnimatedSprite2D");

func _physics_process(_delta: float) -> void:
	follow_player_sprite();

func follow_player_sprite() -> void:
	var player_position = GameManager.player_position;
	var difference = player_position - enemy.position;
	var input_vector = difference.normalized();
	enemy.velocity = input_vector * SPEED * 100.0;
	enemy.move_and_slide();
	
	flip_enemy_sprite(input_vector);

func flip_enemy_sprite(input_vector) -> void:
	if input_vector.x > 0:
		sprite.flip_h = false;
	elif input_vector.x < 0:
		sprite.flip_h = true;
