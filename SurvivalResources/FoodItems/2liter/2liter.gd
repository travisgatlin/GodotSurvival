extends RigidBody3D
var drop = preload("res://Generic Sounds/Plastic Bottle hit.wav")
var dropFull = preload("res://Generic Sounds/Solid Object Hitting Ground.wav")
var open = preload ("res://Generic Sounds/Open 2 liter.wav")
#ENTRIES PREFILLED MUST BE DEFINED OR OBJECT WILL NOT WORK
@export var itemStats = {
	"ItemName" : "2 Liter",
	"ItemType" : "Drink",
	"Expires" : false,
	"InvIcon" : "res://InventoryIcons/2LiterFullIcon.png",
	"Stackable": true,
	"id": 517621
}
#FOR CUSTOM FUNCTIONS, IF SCRAPS INTO AND AMOUNT IS NOT DEFINED WITH AN IN GAME MATERIAL, SCRAPPING OBJECT WILL NOT WORK
@export var itemProps = {
	"Description" : "A lotta soda. Drink in moderation.",
	"Liquid": 33.0,
	"Weight" : 3.0,
	"Scraps into" : "Plastic",
	"Amount" : 15.0
	}


func USE():
	drink()


func _on_body_entered(_body):
	if itemProps["Liquid"] > 0:
		$"Sound".set_stream(dropFull)
		$"Sound".play()
	else:
		$"Sound".set_stream(drop)
		$"Sound".play()

func drink():
	itemProps["Liquid"] -= 8.0

func liquidDrain(amount):
	var tween = get_tree().create_tween()
