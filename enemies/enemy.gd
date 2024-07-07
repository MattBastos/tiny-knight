class_name Enemy
extends Node2D

@export var HEALTH: float = 2;
@export var death_event: PackedScene;

@onready var damage_taken_marker = $DamageTakenMarker;

var damage_digit: PackedScene;

func _ready():
	damage_digit = preload("res://systems/damage_digit.tscn");

func _process(_delta: float) -> void:
	if HEALTH <= 0:
		die();

func create_damage_taken_marker(damage_amount: float):
	var damage_taken = damage_digit.instantiate();
	damage_taken.damage_value = damage_amount;
	
	if damage_taken_marker:
		damage_taken.global_position = damage_taken_marker.global_position;
	else:
		damage_taken.global_position = global_position;
	
	get_parent().add_child(damage_taken);

func take_damage(amount: float) -> void:
	if HEALTH > 0:
		HEALTH -= amount;
		create_damage_taken_marker(amount);

func die() -> void:
	if death_event:
		var death_object = death_event.instantiate();
		death_object.position = position;
		get_parent().add_child(death_object);
		
		queue_free();
