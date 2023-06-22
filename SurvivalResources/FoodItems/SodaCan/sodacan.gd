extends RigidBody3D
var crushed = false
var drop = preload("res://Generic Sounds/Metal ding.wav")
var dropFull = preload("res://Generic Sounds/Solid Object Hitting Ground.wav")
var crushCan = preload("res://SurvivalResources/FoodItems/SodaCan/326211__blu_150058__can-crushing.wav")
@export var itemStats = {
	"ItemName" : "Soda Can",
	"ItemType" : "Drink",
	"Expires" : false,
	"InvIcon" : "res://InventoryIcons/sodacanicon.png",
	"Stackable": true,
	"id": 233019
}

@export var itemProps = {
	"Weight" : 0.5,
	"Thirst" : 10.7,
	"Scraps into" : "Aluminum",
	"Amount" : 8.0
	}

func USE():
	crush()
	
func crush():
	if crushed == false:
		$"Sound".set_stream(crushCan)
		$"Sound".play()
		crushed = true
		itemStats["InvIcon"] = "res://InventoryIcons/SodaCanCrushedIcon.png"
		itemStats["id"] = 644857
		self.freeze = true
		$"GameCan".visible = false
		$"CanCrushedlow".visible = true

func _on_body_entered(body):
	if crushed == true:
		$"Sound".set_stream(drop)
		$"Sound".play()
	else:
		$"Sound".set_stream(dropFull)
		$"Sound".play()
