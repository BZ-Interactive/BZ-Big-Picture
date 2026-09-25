class_name LauncherManager extends Control

@export var button_template: PackedScene

@export_category("Menus")
@onready var media_menu: Menu = $"Menu VboxContainer/Media"
@onready var game_menu: Menu = $"Menu VboxContainer/Games"
@onready var utilities_menu: Menu = $"Menu VboxContainer/Utilities"
@onready var system_menu: Menu = $"Menu VboxContainer/System"

var config_path: String = ""
var config = ConfigFile.new()

var display_names: bool = false
var media_disabled: bool = false
var games_disabled: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	read_config()

const CATEGORIES := [
	"media",
	"games",
	"utilities",
	"system"
]

func _load_font(path: String) -> void:
	if path == "":
		return
	var font_dir: String = "Fonts".path_join(path)
	if OS.has_feature("editor"):
		font_dir = "res://.gdignore/Build/Fonts".path_join(path)
	
	if ( # font exist now type check
		path.ends_with(".ttf")
		or path.ends_with(".otf")
		or path.ends_with(".woff")
		or path.ends_with(".woff2")
		or path.ends_with(".pfb")
		or path.ends_with(".pfm")
		):
		Main.font.load_dynamic_font(font_dir)
	elif path.ends_with(".fnt") or path.ends_with(".font"):
		Main.font.load_bitmap_font(path)
	else:
		print("Invalid font file format.")

func _load_icon(path: String) -> Texture2D:
	var icon_dir: String = "Icons".path_join(path)
	if OS.has_feature("editor"):
		icon_dir = "res://.gdignore/Build/Icons".path_join(path)
	
	if FileAccess.file_exists(icon_dir):
		var image = Image.new()
		var image_error = image.load(icon_dir)
		if image_error == OK:
			return ImageTexture.create_from_image(image) as Texture2D 
	return null

## Instantiate app buttons to respective menus
func _instantiate_buttons() -> void:
	for section in config.get_sections():
		var category := section.get_slice(".", 0)
		if not category in CATEGORIES:
			continue
		if media_disabled && category == CATEGORIES[0]:
			continue
		if games_disabled && category == CATEGORIES[1]:
			continue
		
		if OS.has_feature("editor"):
			print("Found a " +  category + " entry: " + section)
		var button: AppButton = button_template.instantiate() as AppButton
		var icon := _load_icon(config.get_value(section, "icon", ""))
		# set icon
		if icon:
			button.texture_normal = icon
		# set app name
		if OS.has_feature("editor"):
			button.name = section.get_slice(".", 1)
		if display_names:
			button.display_name = config.get_value(section, "name", "")
		# set command
		button.command = config.get_value(section, "command", "")
		if button.command == "":
			print("No command set for: " + section)
		
		match category:
			CATEGORIES[0]:
				media_menu.context_page.add_child(button)
			CATEGORIES[1]:
				game_menu.context_page.add_child(button)
			CATEGORIES[2]:
				utilities_menu.context_page.add_child(button)
			CATEGORIES[3]:
				system_menu.context_page.add_child(button)
	Main.buttons_ready.emit()

func read_config() -> bool:
	if OS.has_feature("editor"): # in editor look at project root
		config_path = ProjectSettings.globalize_path("res://config.cfg")
	else: # exported look beside executable
		config_path = OS.get_executable_path().get_base_dir().path_join("config.cfg")
	
	var err = config.load(config_path)
	if err != OK:
		printerr("Error: Could not load config at: ", config_path)
		return false
	
	var active_fps = config.get_value("main", "active_fps")
	var background_fps = config.get_value("main", "background_fps")
	var vsync = config.get_value("main", "vsync_mode")
	display_names = config.get_value("main", "display_names")
	media_disabled = config.get_value("main", "media_disabled")
	games_disabled = config.get_value("main", "games_disabled")
	# assign main variables
	_load_font(config.get_value("main", "font", ""))
	Main.active_fps = active_fps
	Main.background_fps = background_fps
	Main.vsync = vsync
	Main.display_names = display_names
	Main.menu_switcher.media_disabled = media_disabled
	Main.menu_switcher.games_disabled = games_disabled
	
	_instantiate_buttons()
	return true
	
