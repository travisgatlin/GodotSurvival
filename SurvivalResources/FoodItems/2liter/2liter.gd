extends RigidBody3D
var drop = preload("res://Generic Sounds/Plastic Bottle hit.wav")
#ENTRIES PREFILLED MUST BE DEFINED OR OBJECT WILL NOT WORK
@export var itemStats = {
	"ItemName" : "Empty 2 Liter",
	"ItemType" : "Junk",
	"Expires" : false,
	"InvIcon" : "res://InventoryIcons/2LiterIcon.png",
	"Stackable": true,
	"id": 517621
}
#FOR CUSTOM FUNCTIONS, IF SCRAPS INTO AND AMOUNT IS NOT DEFINED WITH AN IN GAME MATERIAL, SCRAPPING OBJECT WILL NOT WORK
@export var itemProps = {
	"Description" : "Fun to bonk with",
	"Weight" : 0.2,
	"Scraps into" : "Plastic",
	"Amount" : 15.0
	}


func USE():
	pass


func _on_body_entered(_body):
	$"Sound".set_stream(drop)
	$"Sound".play()
