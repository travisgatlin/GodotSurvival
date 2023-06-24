extends RigidBody3D
var drop = preload("res://Generic Sounds/Plastic Bottle hit.wav")
var dropFull = preload("res://Generic Sounds/Solid Object Hitting Ground.wav")
var open = preload ("res://Generic Sounds/Open 2 liter.wav")
var drink = preload ("res://Generic Sounds/534336__defaultv__drink_gulp.wav")
var empty = false
var isOpened = false
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
	"Liquid": 68.0,
	"Weight" : 3.0,
	"Scraps into" : "Plastic",
	"Amount" : 15.0
	}


func USE():
	openBottle()


func _on_body_entered(_body):
	if itemProps["Liquid"] > 0:
		$"Sound".set_stream(dropFull)
		$"Sound".play()
	else:
		$"Sound".set_stream(drop)
		$"Sound".play()

func openBottle():
	if empty == false:
		if isOpened == false:
			$"Sound".connect("finished", liquidDrain)
			$"Sound".set_stream(open)
			$"Sound".play()
			isOpened = true
		else:
			liquidDrain()
	else:
		return

func liquidDrain():
	var tween = get_tree().create_tween()
	if $"Sound".is_connected("finished", liquidDrain):
		$"Sound".disconnect("finished",liquidDrain)
	$"Sound".set_stream(drink)
	$"Sound".play()
	itemProps["Liquid"] -= 8.0
	if itemProps["Liquid"] > 51:
		tween.tween_property($"Liquid", "blend_shapes/LiquidTop", $"Liquid".get("blend_shapes/LiquidTop")+0.5,1)
	else:
		tween.tween_property($"Liquid", "blend_shapes/Liquid", $"Liquid".get("blend_shapes/Liquid")+0.154,1)
	if itemProps["Liquid"] <=0 and empty == false:
		empty = true
		$"Liquid".queue_free()
		propChange()

func propChange():
	itemProps = {
		"Description": "Fun to bonk with. Or put water in it, I'm not your dad.",
		"Liquid": 0,
		"Weight": 0.5,
		"Scraps into": "Plastic",
		"Amount": 15.0
	}
	itemStats = {
		"ItemName" : "Empty 2 liter",
		"ItemType" : "Junk",
		"Expires" : false,
		"InvIcon" : "res://InventoryIcons/2LiterIcon.png",
		"Stackable": true,
		"id": 911374
	}
	
