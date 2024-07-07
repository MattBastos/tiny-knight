extends CanvasLayer

@onready var timer_label: Label = %TimerLabel;
@onready var meat_label: Label = %MeatLabel;

var elapsed_time: float = 0.0;
var meat_counter: int = 0;

func _ready():
	meat_label.text = str(meat_counter);
	GameManager.player.meat_collected.connect(on_meat_collected);

func _process(delta: float):
	increment_elapsed_time(delta);
	format_elapsed_time();

func increment_elapsed_time(delta: float) -> void:
	elapsed_time += delta;

func format_elapsed_time() -> void:
	var elapsed_time_in_seconds: int = floori(elapsed_time);
	var seconds: int = elapsed_time_in_seconds % 60;
	var minutes: int = elapsed_time_in_seconds / 60;
	
	timer_label.text = "%02d:%02d" % [minutes, seconds];

func on_meat_collected(_meat_collected: int) -> void:
	meat_counter += 1;
	meat_label.text = str(meat_counter);
