extends Node2D

@export var damage_value: float = 0.0;

func _ready():
	%DamageNumber.text = str(damage_value);
