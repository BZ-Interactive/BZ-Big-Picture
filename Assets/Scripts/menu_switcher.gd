class_name MenuSwitcher extends VBoxContainer

@export var Menus: Array[TextureButton]

@export var media : Menu
@export var media_disabled : bool
@export var games : Menu
@export var games_disabled : bool

var index: int = 0
var menu_count: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Main.menu_switcher = self
	_init_menus()

func _input(event: InputEvent) -> void:
#	print("input of menu " + get_viewport().gui_get_focus_owner().get_parent().name)
	if get_viewport().gui_get_focus_owner().get_parent() == self:
		if event.is_action_pressed("down"):
			index = wrapi(index + 1, 0, menu_count)
			close_all_menus()
		elif event.is_action_pressed("up"):
			index = wrapi(index - 1, 0, menu_count)
			close_all_menus()

func close_all_menus() -> void:
	for menu in Menus:
		(menu as Menu).context_page.visible = false

func _init_menus():
	if media_disabled:
		media.disabled = true
		media.visible = false
	if games_disabled:
		games.disabled = true
		games.visible = false
	
	for menu in self.get_children():
		menu = menu as Menu
		menu.context_page.visible = false
		if menu.visible:
			Menus.append(menu)
	
	menu_count = len(Menus)
	Menus[0].grab_focus()

func _on_focus_exited():
	pass
