extends TextureButton
var stack = 0
@onready var playerGlobals = $"/root/PlayerStats"
@export var itemStats = {
}
@export var itemProps = {
}

# Called when the node enters the scene tree for the first time.
func _ready():
	stackAdd()
	var InvImage = load(str(itemStats["InvIcon"]))
	self.set("texture_normal", InvImage)
	self.set("tooltip_text", str(itemStats["ItemName"]) + "\nType:" + str(itemStats["ItemType"]) + "\n" + str(propFormatter(itemProps)))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func propFormatter(prop):
	var formattedProps = ""
	var baseprop = prop.keys()
	for i in baseprop.size():
		formattedProps = formattedProps + str(baseprop[i]) + ": " + str(prop.get(baseprop[i])) + "\n "
	return formattedProps

func itemDefinition(stats,prop,amount:=1):
	itemStats = stats
	itemProps = prop
	if amount > 1:
		for i in amount:
			stackAdd()

func stackAdd():
	stack += 1
	if stack > 1:
		if $"Amount".visible == false:
			$"Amount".visible = true
		$"Amount".text = "(" + str(stack) + ")"
	else:
		$"Amount".visible = false
func stackRemove():
	stack -= 1
	$"Amount".text = "(" + str(stack) + ")"
	if stack < 1:
		self.queue_free()

func equip():
	pass

func _on_pressed():
	if Input.is_action_pressed("sprint"):
		playerGlobals.emit_signal("dropItem", itemStats["id"], true)
