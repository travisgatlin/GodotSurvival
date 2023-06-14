extends GridContainer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _can_drop_data(at_position, data):
	return true

func _drop_data(at_position, data):
	var old = data.get_parent()
	old.remove_child(data)
	self.add_child(data)
