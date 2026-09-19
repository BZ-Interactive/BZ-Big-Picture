extends VBoxContainer

@export var MenuDict: Dictionary[TextureButton, GridContainer]

var index: int = 0
var menu_count: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	menu_count = len(MenuDict.keys())
	open_page(0)
	MenuDict.keys()[0].grab_focus()
	#MenuDict.keys()[0]._on_hover()

func _input(event: InputEvent) -> void:
#	print("input of menu " + get_viewport().gui_get_focus_owner().get_parent().name)
	if get_viewport().gui_get_focus_owner().get_parent() == self:
		if event.is_action_pressed("down"):
			index = wrapi(index + 1, 0, menu_count)
			open_page(index)
			#MenuDict.keys()[index]._on_hover()
		elif event.is_action_pressed("up"):
			index = wrapi(index - 1, 0, menu_count)
			open_page(index)
			#MenuDict.keys()[index]._on_hover()
	#elif event.is_action_pressed("right"):
		#MenuDict.values()[index].get_child(0).grab_focus()

func launch_app(command: String) -> void:
	var parts := command.split(" ", false)
	OS.create_process(parts[0], parts.slice(1))

func close_all_menus() -> void:
	for context in MenuDict.values():
		context.visible = false

func open_page(_index: int) -> void:
	close_all_menus()
	MenuDict.values()[_index].visible = true
	#make_menus_normal()
	#MenuDict.keys()[index]._on_hover()

func _on_focus_entered(_index: int):
	open_page(_index)

func _on_focus_exited():
	pass
