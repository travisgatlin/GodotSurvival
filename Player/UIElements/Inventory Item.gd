extends TextureButton
var stack = []
var icon = null
var isEquipped = false
var defaultStats = null
@export var mpID = 0
@onready var playerGlobals = $"/root/PlayerStats"

# Called when the node enters the scene tree for the first time.
func _ready():
	playerGlobals.connect("updateItem",findDifferentItem)
	#playerGlobals.connect("itemUsed",itemUse)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	highlight()
#	for i in stack.size():
#		if shouldBeInStack(stack[i].itemProps) != true:
#			playerGlobals.emit_signal("invRestack", stack[i])

func setup(ref,id):
	mpID=id
	var InvImage = load(str(ref.itemStats["InvIcon"]))
	icon = InvImage
	self.set("texture_normal", InvImage)
	self.set("tooltip_text", str(ref.itemStats["ItemName"]) + "\nType:" + str(ref.itemStats["ItemType"]) + "\n" + str(propFormatter(ref.itemProps)))
	stackAdd(ref)

func propFormatter(prop):
	var formattedProps = ""
	var baseprop = prop.keys()
	for i in baseprop.size():
		formattedProps = formattedProps + str(baseprop[i]) + ": " + str(prop.get(baseprop[i])) + "\n "
	return formattedProps

func stackAdd(ref):
	stack.append(ref)
	defaultStats = ref.itemStats
	if stack.size() > 1:
		if $"Amount".visible == false:
			$"Amount".visible = true
		$"Amount".text = "(" + str(stack.size()) + ")"
	elif stack.size() == 1:
		$"Amount".visible = false
		
func stackRemove(index:=0):
	stack.remove_at(index)
	$"Amount".text = "(" + str(stack.size()) + ")"
	if stack.size() < 1:
		self.queue_free()
	if stack.size() == 1:
		$"Amount".visible = false

func _on_pressed():
	if Input.is_action_pressed("sprint"):
		playerGlobals.emit_signal("dropItem", stack[0].itemStats["id"],self.get_parent(), true)

func highlight():
	if !Input.is_action_pressed("sprint"):
		if is_hovered() or isEquipped == true:
			self.grab_focus()
		else:
			self.release_focus()

func _get_drag_data(_at_position):
	var invItem = TextureRect.new()
	invItem.set("expand_mode", 1)
	invItem.size = self.size
	invItem.texture = icon
	set_drag_preview(invItem)
	return self

func _can_drop_data(_at_position, _data):
	if stack[0].itemStats["Stackable"] == true:
		return true
	else:
		return false

func findDifferentItem():
	for i in stack.size():
		if stack[i].itemStats != defaultStats:
			playerGlobals.emit_signal("invRestack",stack[i],stack[i].itemStats["id"],self.get_parent())
			stackRemove(i)
			break

#func itemUse(object):
#	if defaultStats["singleUse"] == true:
#		for i in stack.size():
#			if object == stack[i]:
#				stackRemove(i)
