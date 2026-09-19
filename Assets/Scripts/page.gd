extends GridContainer

@export var parent: TextureButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in self.get_child_count():
		var button := self.get_child(i) as TextureButton
		if i % self.columns == 0:
			button.set_focus_neighbor(SIDE_LEFT, parent.get_path())
