extends TextureButton

const GITHUB_URL = "https://api.github.com/repos/bz-interactive/BZ-Big-Picture/releases/latest"
const LATEST_RELEASE_URL: String = "https://github.com/BZ-Interactive/BZ-Big-Picture/releases/latest"
var http_request: HTTPRequest

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.visible = false
	self.pressed.connect(on_button_pressed)
	self.mouse_entered.connect(on_mouse_entered)
	self.mouse_exited.connect(on_mouse_exited)
	 # for style reasons, wait 2 seconds (lenght of intro)
	await get_tree().create_timer(Main.screen_dimmer.INTRO_DURATION).timeout
	_check_version()

func _check_version():
	http_request = HTTPRequest.new()
	add_child(http_request)
	var headers = ["User-Agent: GodotEngine"]
	var error = http_request.request(GITHUB_URL, headers)
	if error != OK:
		print("An error occurred while making the HTTP request.")
		return
	http_request.request_completed.connect(_on_request_completed)

func _show_update_notification():
	self.visible = true
	Main.sound_player.play_notification_sound()

func _open_webpage(url):
	var result := OS.shell_open(url)
	
	if result != OK:
		print("Could not open URL: " + str(result))

func _compare_versions(remote: String, local: String) -> bool:
	if local == remote: # up to date
		return true
	
	var remote_parts := remote.trim_prefix("v").split(".")
	var local_parts := local.trim_prefix("v").split(".")
	
	for i in range(3):
		var r := int(remote_parts[i]) if i < remote_parts.size() else 0
		var l := int(local_parts[i]) if i < local_parts.size() else 0
		
		if r > l:
			return true
		if r < l:
			return false
		
	return false

func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if response_code == 200:
		var json = JSON.new()
		var error = json.parse(body.get_string_from_utf8())
		
		if error == OK:
			var response_data = json.get_data()
			if response_data is Dictionary and response_data.has("tag_name"):
				var tag_name = response_data["tag_name"]
				if not _compare_versions(ProjectSettings.get_setting("application/config/version"), tag_name):
					_show_update_notification()
			else:
				print("Response did not contain 'tag_name'.")
		else:
			print("JSON Parse Error: ", json.get_error_message(), " at line ", json.get_error_line())
	else:
		print("GitHub API returned non-200 response code: ", response_code)
	
	http_request.request_completed.disconnect(_on_request_completed)
	http_request.queue_free()

func on_button_pressed() -> void:
	_open_webpage(LATEST_RELEASE_URL)

func on_mouse_entered() -> void:
	self.modulate = Color.ORANGE

func on_mouse_exited() -> void:
	self.modulate = Color.WHITE
