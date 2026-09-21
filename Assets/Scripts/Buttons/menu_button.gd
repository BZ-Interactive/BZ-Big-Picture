class_name Menu extends TextureButton

@export_category("Button Colors")
@export var hover_color: Color = Color.WHITE
@export var normal_color: Color = Color.DARK_GRAY

@export var context_page: GridContainer

@onready var outline: TextureRect = self.get_child(0)

func _ready():
	self_modulate = normal_color
	outline.visible = false
	mouse_entered.connect(_on_hover)
	mouse_exited.connect(_on_normal)
	button_up.connect(_on_hover)
	focus_entered.connect(_on_focus_entered)
	focus_exited.connect(_on_focus_exited)

func open_page():
	Main.menu_switcher.close_all_menus()
	context_page.visible = true

func _on_hover():
	self_modulate = hover_color

func _on_normal():
	self_modulate = normal_color

func _on_focus_entered() -> void:
	outline.visible = true
	self_modulate = hover_color
	open_page()

func _on_focus_exited() -> void:
	outline.visible = false
	self_modulate = normal_color
