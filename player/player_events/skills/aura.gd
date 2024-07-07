extends Node2D

@export var AURA_DAMAGE: float = 1.0;

@onready var aura_area: Area2D = $AuraArea;

func deal_damage_to_enemies() -> void:
	var enemy_bodies = aura_area.get_overlapping_bodies();
	for enemy_body in enemy_bodies:
		if enemy_body.is_in_group("enemies"):
			var enemy: Enemy = enemy_body;
			enemy.take_damage(AURA_DAMAGE);
