extends RigidBody3D
@onready var playerGlobals = $"/root/PlayerStats"
var reference = "res://SurvivalResources/Ammo/C Battery/c_battery.tscn"
var drop = preload("res://Generic Sounds/Solid Object Hitting Ground.wav")
#ENTRIES PREFILLED MUST BE DEFINED OR OBJECT WILL NOT WORK
@export var itemStats = {
	"ItemName" : "C Battery",
	"ItemType" : "Consumable",
	"Expires" : false,
	"InvIcon" : "res://InventoryIcons/CbatteryIcon.png",
	"Stackable": true,
	"id": 687213
}
#FOR CUSTOM FUNCTIONS, IF SCRAPS INTO AND AMOUNT IS NOT DEFINED WITH AN IN GAME MATERIAL, SCRAPPING OBJECT WILL NOT WORK
@export var itemProps = {
	"Description": "Very useful for portable power. Long lasting",
	"Weight" : 0.1,
	"Scraps into" : ["Steel", "Acid"],
	"Amount" : [2.0, 3.0]
	}

func _ready():
	pass
func USE():
	pass


func _on_body_entered(_body):
	if is_inside_tree():
		$"Sound".set_stream(drop)
		$"Sound".play()
