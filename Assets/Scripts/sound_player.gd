class_name SoundPlayer extends AudioStreamPlayer

@export var app_move: AudioStream
@export var menu_move: AudioStream
@export var ui_select: AudioStream
@export var notification: AudioStream

@onready var chime_player: AudioStreamPlayer = $"Chime Player"
#@export var exit_chime: AudioStream
var first_menu_focus: bool = true

func _init() -> void:
	Main.sound_player = self

func _play_sound(sound: AudioStream) -> void:
	stop()
	self.stream = sound
	play()

func play_startup_chime() -> void:
	chime_player.volume_linear = self.volume_linear
	chime_player.play()

# needs hardcoding the system buttons which im not willing to do
#func play_exit_chime() -> void:
#	chime_player.stream = exit_chime
#	chime_player.play()

func play_menu_move_sound() -> void:
	if first_menu_focus: # dont play the first time
		first_menu_focus = false
		return
	_play_sound(menu_move)

func play_app_move_sound() -> void:
	_play_sound(app_move)
	
func play_select_sound() -> void:
	_play_sound(ui_select)

func play_notification_sound() -> void:
	_play_sound(notification)
