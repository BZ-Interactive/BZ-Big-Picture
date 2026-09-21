class_name AppButton extends TextureButton
@export_category("Button Colors")
@export var hover_color: Color = Color.WHITE
@export var pressed_color: Color = Color.DARK_ORANGE
@export var normal_color: Color = Color.DARK_GRAY

@export var command: String
@onready var outline := self.get_child(0) as TextureRect

func _ready():
	outline.visible = false
	self_modulate = normal_color
	# signals
	mouse_entered.connect(_on_hover)
	mouse_exited.connect(_on_normal)
	button_down.connect(_on_pressed)
	button_up.connect(_on_hover)
	focus_entered.connect(_on_focus_entered)
	focus_exited.connect(_on_focus_exited)

func _on_hover():
	self_modulate = hover_color

func _on_normal():
	self_modulate = normal_color

func _on_pressed():
	self_modulate = pressed_color
	Main.launch_app(command)

func _on_focus_entered() -> void:
	self_modulate = hover_color
	outline.visible = true

func _on_focus_exited() -> void:
	self_modulate = normal_color
	outline.visible = false
