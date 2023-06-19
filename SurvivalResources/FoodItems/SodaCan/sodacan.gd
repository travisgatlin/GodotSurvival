extends RigidBody3D
var crushed = false
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
		crushed = true
		var oldId = itemStats["id"]
		itemStats["InvIcon"] = "res://InventoryIcons/SodaCanCrushedIcon.png"
		itemStats["id"] = 644857
		self.freeze = true
		$"GameCan".visible = false
		$"CanCrushedlow".visible = true
		$"/root/PlayerStats".emit_signal("invUpdate", oldId, self)
