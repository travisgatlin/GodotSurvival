extends RigidBody3D
var reference = "res://SurvivalResources/FoodItems/Chips/Bag of Chips.tscn"
var openbag = load("res://SurvivalResources/FoodItems/Chips/open bag.mp3")
var eat = load("res://SurvivalResources/FoodItems/Chips/Chips.mp3")
var drop = load("res://SurvivalResources/FoodItems/Chips/drop bag.mp3")
@onready var playerGlobals = $"/root/PlayerStats"
# Called when the node enters the scene tree for the first time.

@export var itemStats = {
	"ItemName" : "Bag of Chips",
	"ItemType" : "Food",
	"Expires" : false,
	"InvIcon" : "res://InventoryIcons/ChipBag.png",
	"Stackable": true,
	"id": 35602,
	"singleUse": true
}

@export var itemProps = {
	"Description" : "Salty. Mostly air. Nothing really good comes from these, unless you're hungry and not thirsty.",
	"Weight" : 0.25,
	"Hunger" : 12.0,
	"Thirst" : -6.0,
	"Scraps into" : "Aluminum",
	"Amount" : 0.1
	}
func _ready():
	pass

func USE():
	eatChips()
	playerGlobals.emit_signal("eatFood", itemProps["Hunger"])
	playerGlobals.emit_signal("drinkLiquid",itemProps["Thirst"])

func _on_body_entered(_body):
	if is_inside_tree():
		$"Sound".set_stream(drop)
		$"Sound".play()

func eatChips():
	if !$"Sound".playing:
		$"Sound".set_stream(openbag)
		$"Sound".play()
		await $"Sound".finished
		$"Sound".set_stream(eat)
		$"Sound".play()
