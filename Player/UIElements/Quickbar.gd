extends GridContainer
@export var validInventory = true
@onready var playerGlobals = $"/root/PlayerStats"
var equippedIndex = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	for i in self.get_child_count():
		if i != equippedIndex:
			if self.get_child(i) != null: self.get_child(i).set("isEquipped", false)
	
	if Input.is_action_just_released("hotbarScrollDown"):
		equippedIndex += 1
		changeItem()
	
	if Input.is_action_just_released("hotbarScrollUp"):
		equippedIndex -= 1
		changeItem()
	
	if equippedIndex > self.get_child_count()-1:
		equippedIndex = 0
		changeItem()
	
	elif equippedIndex < 0:
		equippedIndex = self.get_child_count()-1
func _can_drop_data(_at_position, _data):
	var itemsInBar = self.get_child_count()
	if itemsInBar < 8:
		return true
	else:
		return false

func _drop_data(_at_position, data):
	var old = data.get_parent()
	old.remove_child(data)
	self.add_child(data)

func changeItem():
		if equippedIndex <= self.get_child_count()-1 and self.get_child_count() != 0:
			var item = self.get_child(equippedIndex)
			if item != null: 
				item.set("isEquipped", true)
				playerGlobals.emit_signal("equipItem", item.itemStats["id"])
