extends Control

@onready var stopwatch_label = $StopwatchLabel
var time_elapsed := 0.0

func _process(delta):
	time_elapsed += delta
	var minutes = int(time_elapsed) / 60
	var seconds = int(time_elapsed) % 60
	stopwatch_label.text = "%02d:%02d" % [minutes, seconds]
