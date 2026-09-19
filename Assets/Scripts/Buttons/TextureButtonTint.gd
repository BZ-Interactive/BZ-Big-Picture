extends TextureButton
@export_category("Button Colors")
@export var hover_color: Color = Color.WHITE
@export var pressed_color: Color = Color.DARK_ORANGE
@export var normal_color: Color = Color.DARK_GRAY

func _ready():
	#normal_color = self_modulate
	self_modulate = normal_color
	
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

func _on_focus_entered() -> void:
	self_modulate = hover_color

func _on_focus_exited() -> void:
	self_modulate = normal_color
