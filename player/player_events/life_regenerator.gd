extends Node2D

@export var regeneration_amount: float = 10;

@onready var hitbox: Area2D = $HitBox;

func _ready():
	hitbox.body_entered.connect(on_body_entered);

func on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		var player: Player = body;
		player.heal(regeneration_amount);
		player.meat_collected.emit(regeneration_amount);
		queue_free();
