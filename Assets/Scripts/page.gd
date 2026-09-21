extends GridContainer

@export var parent: TextureButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_set_navigation()

func _set_navigation() -> void:
	var count := self.get_child_count()
	for i in count:
		var button := self.get_child(i) as TextureButton
		var self_path := button.get_path()
		
		if i % self.columns == 0: # left most goes back to the owner
			button.set_focus_neighbor(SIDE_LEFT, parent.get_path())
		if i < self.columns: # first row
			button.set_focus_neighbor(SIDE_TOP, self_path)
		if i + self.columns >= count: # nothing below
			button.set_focus_neighbor(SIDE_BOTTOM, self_path)
