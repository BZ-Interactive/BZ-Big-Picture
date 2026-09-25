extends Node

var menu_switcher: MenuSwitcher

var active_fps: int = 60
var background_fps: int = 2
var vsync: DisplayServer.VSyncMode = DisplayServer.VSyncMode.VSYNC_ENABLED
var display_names: bool = false
@onready var font: FontFile = FontFile.new()

# Bare X11 timeout user parameters
var user_timeout: int = 0
var user_cycle: int = 0
var user_dpms: bool = true

# Dbus timeout parameters
var used_dbus: bool = false
var inhibit_cookie: int = -1


@warning_ignore("unused_signal") signal buttons_ready # used in LauncherManager

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_inhibit_screensaver()
	Engine.max_fps = active_fps

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("exit"):
		get_tree().quit()

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_WM_WINDOW_FOCUS_IN:
			on_focus()
		NOTIFICATION_WM_WINDOW_FOCUS_OUT:
			on_focus_lost()

func _exit_tree() -> void:
	DisplayServer.screen_set_keep_on(false)
	_restore_screensaver()

func launch_app(command: String) -> void:
	var parts := command.split(" ", false)
	OS.create_process(parts[0], parts.slice(1))

func _capture_screensaver_state() -> void:
	var output := []
	OS.execute("xset", ["q"], output, true)
	var text: String = output[0] if output.size() > 0 else ""

	var saver_line := ""
	for line in text.split("\n"):
		if "timeout:" in line:
			saver_line = line.strip_edges()
			break

	if saver_line != "":
		var parts := saver_line.split(" ", false)
		for i in parts.size():
			if parts[i] == "timeout:" and i + 1 < parts.size():
				user_timeout = parts[i + 1].to_int()
			elif parts[i] == "cycle:" and i + 1 < parts.size():
				user_cycle = parts[i + 1].to_int()
	
	#print(user_timeout)
	#print(user_cycle)
	user_dpms = text.find("DPMS is Enabled") != -1
	#print(user_dpms)

func _inhibit_screensaver() -> void:
	DisplayServer.screen_set_keep_on(true)
	
	var output := []
	var exit_code := OS.execute("dbus-send", [
		"--session", "--dest=org.freedesktop.ScreenSaver",
		"--type=method_call", "--print-reply",
		"/org/freedesktop/ScreenSaver",
		"org.freedesktop.ScreenSaver.Inhibit",
		"string:bz-big-picture", "string:running"
	], output, true)
	
	if exit_code == 0 and output.size() > 0:
		var parts: PackedStringArray = output[0].split(" ")
		var index:= parts.find("uint32")
		
		if index != -1 and index + 1 < parts.size():
			inhibit_cookie = parts[index + 1].to_int()
			used_dbus = true
			return
	#print(user_cycle)
	#print(user_timeout)
	if DisplayServer.get_name() == "X11":
		_capture_screensaver_state()
		OS.create_process("xset", ["s", "off"])
		OS.create_process("xset", ["-dpms"])

func _restore_screensaver():
	if used_dbus:
		OS.execute("dbus-send", [
			"--session", "--dest=org.freedesktop.ScreenSaver",
			"--type=method_call",
			"/org/freedesktop/ScreenSaver",
			"org.freedesktop.ScreenSaver.UnInhibit",
			"uint32:%d" % inhibit_cookie
		])
		return
	
	elif DisplayServer.get_name() == "X11":
		OS.create_process("xset", ["s", str(user_timeout), str(user_cycle)])
		OS.create_process("xset", ["+dpms" if user_dpms else "-dpms"])

func on_focus() -> void:
	process_mode = Node.PROCESS_MODE_INHERIT
	Engine.max_fps = active_fps
	DisplayServer.window_set_vsync_mode(vsync)
	#print("in focus")

func on_focus_lost() -> void:
	process_mode = Node.ProcessMode.PROCESS_MODE_DISABLED
	Engine.max_fps = background_fps
	DisplayServer.window_set_vsync_mode(DisplayServer.VSyncMode.VSYNC_DISABLED)
	#print("out of focus")
