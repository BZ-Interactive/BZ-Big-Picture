class_name ScreenDimmer extends ColorRect

const DIM_DURATION: float = 1.0
const WAKE_DURATION: float = 0.5

@onready var idle_timer: Timer = $"Idle Timer"
var idle_time: float = 600
@export var dimmed_alpha: float = 0.75
var darkness: float = 0.0 # inverted; 0 is 100% brightness

var dim_tween: Tween
var wake_tween: Tween

func _init() -> void:
	Main.screen_dimmer = self
	Main.buttons_ready.connect(_init_screen_dimmer)

func _ready() -> void:
	idle_timer.timeout.connect(_on_idle_timeout)

func _input(event: InputEvent) -> void:
	if event is InputEventKey or event is InputEventJoypadButton or event is InputEventMouseButton:
		if event.is_pressed():
			_wake_screen()

func _exit_tree() -> void:
	idle_timer.timeout.disconnect(_on_idle_timeout)
	Main.buttons_ready.disconnect(_init_screen_dimmer)

func _init_screen_dimmer() -> void:
	self.color.a = darkness
	idle_timer.wait_time = idle_time - DIM_DURATION

func _wake_screen() -> void:
	idle_timer.start()
	if dim_tween and dim_tween.is_running():
		dim_tween.stop()
	wake_tween = create_tween()
	wake_tween.tween_property(self, "color:a", darkness, WAKE_DURATION)
	await wake_tween.finished
	self.color.a = darkness

func _dim_screen() -> void:
	dim_tween = create_tween()
	dim_tween.tween_property(self, "color:a", clamp(darkness + dimmed_alpha, dimmed_alpha, 1.0), DIM_DURATION)

func _on_idle_timeout() -> void:
	_dim_screen()
