extends Node2D

@export var enemies: Array[PackedScene];
@export var MOBS_PER_MINUTE: float = 60.0;

@onready var path_follow_2d: PathFollow2D = %PathFollow2D;

var COOLDOWN: float = 0.0;

func _process(delta: float):
	COOLDOWN -= delta;
	
	if COOLDOWN <= 0:
		spawn_enemy();

func set_cooldown() -> void:
	var interval = 60.0 / MOBS_PER_MINUTE;
	COOLDOWN = interval;

func create_random_enemy() -> Node2D:
	var random_enemy_index = randi_range(0, enemies.size() - 1);
	var random_enemy = enemies[random_enemy_index];
	var enemy = random_enemy.instantiate();
	return enemy;

func get_random_point() -> Vector2:
	path_follow_2d.progress_ratio = randf();
	return path_follow_2d.global_position;

func spawn_enemy() -> void:
	set_cooldown();
	
	var enemy = create_random_enemy();
	enemy.global_position = get_random_point();
	get_parent().add_child(enemy);
