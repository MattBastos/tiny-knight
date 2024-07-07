class_name Player
extends CharacterBody2D

@export_category("Health")
@export var MAX_HEALTH: float = 100;
@export var CURRENT_HEALTH: float = MAX_HEALTH;
@export var death_event: PackedScene;
@export_category("Movement")
@export var SPEED: float = 3;
@export var MOVEMENT_SPEED_ATTACKING: float = 0.25;
@export_category("Attack")
@export var SWORD_DAMAGE: float = 2;
@export_category("Defense")
@export var HITBOX_COOLDOWN_DURATION: float = 0.5;
@export_category("Skills")
@export var aura: PackedScene;
@export var AURA_DAMAGE: float = 1;
@export var AURA_COOLDOWN_DURATION: float = 10.0;

@onready var sprite: Sprite2D = $Sprite2D;
@onready var animation_player: AnimationPlayer = $AnimationPlayer;
@onready var health_progress_bar: ProgressBar = $HealthProgressBar;
@onready var sword_area: Area2D = $SwordArea;
@onready var hitbox: Area2D = $HitBox;

var input_vector: Vector2 = Vector2(0, 0);

var is_running: bool = false;
var was_running: bool = false;
var is_attacking: bool = false;

var attack_direction: Vector2 = Vector2();
var ATTACK_ANIMATION_TIME: float = 0.6;
var ATTACK_COOLDOWN: float = 0.0;
var CURRENT_AURA_COOLDOWN: float = 0.0;
var CURRENT_HITBOX_COOLDOWN: float = 0.0;

signal meat_collected(value: int);

func _ready():
	GameManager.player = self;

func _process(delta: float) -> void:
	if CURRENT_HEALTH <= 0:
		die();
	
	GameManager.player_position = position;
	
	read_movement_input();
	set_player_movement_animation();
	
	if not is_attacking:
		flip_player_sprite();
	
	update_health_progress_bar();
	
	handle_player_attack_input();
	update_attack_cooldown(delta);
	
	update_hitbox_cooldown(delta);
	update_hit_taken_detection();
	
	use_aura_skill(delta);

func _physics_process(_delta: float) -> void:
	update_player_movement_speed();

func read_movement_input() -> void:
	input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down");
	was_running = is_running;
	is_running =  not input_vector.is_zero_approx();

func update_player_movement_speed() -> void:
	var player_velocity = input_vector * SPEED * 100.0;
	
	if is_attacking:
		player_velocity *= MOVEMENT_SPEED_ATTACKING;
	
	velocity = lerp(velocity, player_velocity, 0.15);
	move_and_slide();

func set_player_movement_animation() -> void:
	if is_attacking:
		return;
	
	if was_running != is_running:
		if is_running:
			animation_player.play("running");
		else:
			animation_player.play("idle");

func flip_player_sprite() -> void:
	var mouse_position = get_global_mouse_position();
	var player_position = GameManager.player_position;
	
	if mouse_position.x > player_position.x:
		sprite.flip_h = false;
	else:
		sprite.flip_h = true;

func update_health_progress_bar() -> void:
	health_progress_bar.max_value = MAX_HEALTH;
	health_progress_bar.value = CURRENT_HEALTH;

func deal_damage_to_enemies() -> void:
	var enemy_bodies = sword_area.get_overlapping_bodies();
	
	for enemy_body in enemy_bodies:
		if enemy_body.is_in_group("enemies"):
			var enemy: Enemy = enemy_body;
			var enemy_direction = (enemy.position - position).normalized();
			
			if attack_direction.dot(enemy_direction) > 0.1:
				enemy.take_damage(SWORD_DAMAGE);

func attack(attack_type: String) -> void:
	if is_attacking:
		return;
	
	is_attacking = true;
	animation_player.play(attack_type);
	ATTACK_COOLDOWN = ATTACK_ANIMATION_TIME;

func handle_player_attack_input() -> void:	
	var mouse_position = get_global_mouse_position();
	var player_position = GameManager.player_position;
	var direction_to_mouse = (mouse_position - player_position).normalized();

	if Input.is_action_just_pressed("light_attack"):
		if abs(direction_to_mouse.x) > abs(direction_to_mouse.y):
			attack_direction = Vector2(1, 0) if direction_to_mouse.x > 0 else Vector2(-1, 0);
			attack("attack_side_a");
		elif direction_to_mouse.y < 0:
			attack_direction = Vector2(0, -1);
			attack("attack_up_a");
		else:
			attack_direction = Vector2(0, 1);
			attack("attack_down_a");
	
	if Input.is_action_just_pressed("heavy_attack"):
		if abs(direction_to_mouse.x) > abs(direction_to_mouse.y):
			attack_direction = Vector2(1, 0) if direction_to_mouse.x > 0 else Vector2(-1, 0);
			attack("attack_side_b");
		elif direction_to_mouse.y < 0:
			attack_direction = Vector2(0, -1);
			attack("attack_up_b");
		else:
			attack_direction = Vector2(0, 1);
			attack("attack_down_b");

func update_attack_cooldown(delta: float) -> void:
	if is_attacking:
		ATTACK_COOLDOWN -= delta;
		
		if ATTACK_COOLDOWN <= 0.0:
			is_attacking = false;
			is_running = false;
			animation_player.play("idle");

func use_aura_skill(delta: float) -> void:
	CURRENT_AURA_COOLDOWN -= delta;
	if CURRENT_AURA_COOLDOWN <= 0:
		CURRENT_AURA_COOLDOWN = AURA_COOLDOWN_DURATION;
		var aura_skill = aura.instantiate();
		add_child(aura_skill);

func set_player_sprite_color_animation(from_color: Color, to_color: Color) -> void:
	modulate = from_color;
	var tween = create_tween();
	tween.set_ease(Tween.EASE_IN);
	tween.set_trans(Tween.TRANS_QUINT);
	tween.tween_property(self, "modulate", to_color, 0.3);

func take_damage(amount: float) -> void:
	if CURRENT_HEALTH > 0:
		CURRENT_HEALTH -= amount;
		set_player_sprite_color_animation(Color.RED, Color.WHITE);

func update_hitbox_cooldown(delta: float) -> void:
	if CURRENT_HITBOX_COOLDOWN > 0.0:
		CURRENT_HITBOX_COOLDOWN -= delta;

func update_hit_taken_detection() -> void:
	if CURRENT_HITBOX_COOLDOWN <= 0.0:
		var enemy_bodies = hitbox.get_overlapping_bodies();
		for enemy_body in enemy_bodies:
			if enemy_body.is_in_group("enemies"):
				take_damage(1);
				CURRENT_HITBOX_COOLDOWN = HITBOX_COOLDOWN_DURATION;

func die() -> void:
	if death_event:
		var death_object = death_event.instantiate();
		death_object.position = position;
		get_parent().add_child(death_object);
		
		queue_free();

func heal(amount: float) -> float:
	CURRENT_HEALTH += amount;
	if CURRENT_HEALTH > MAX_HEALTH:
		CURRENT_HEALTH = MAX_HEALTH;
		return CURRENT_HEALTH;
	return 0.0;
