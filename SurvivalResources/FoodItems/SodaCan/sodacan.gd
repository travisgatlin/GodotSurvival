extends RigidBody3D
var crushed = false
var drop = preload("res://Generic Sounds/Metal ding.wav")
var dropFull = preload("res://Generic Sounds/Solid Object Hitting Ground.wav")
var crushCan = preload("res://SurvivalResources/FoodItems/SodaCan/326211__blu_150058__can-crushing.wav")
var canOpen = preload ("res://SurvivalResources/FoodItems/SodaCan/393877__inspectorj__fizzy-drink-can-opening-a.wav")
var drink = preload ("res://Generic Sounds/534336__defaultv__drink_gulp.wav")
@export var itemStats = {
	"ItemName" : "Soda Can",
	"ItemType" : "Drink",
	"Expires" : false,
	"InvIcon" : "res://InventoryIcons/sodacanicon.png",
	"Stackable": true,
	"id": 233019
}

@export var itemProps = {
	"Description" : "Was once delicious. Probably flat now.",
	"Weight" : 0.5,
	#Liquid in ounces
	"Liquid" : 12.0,
	"Scraps into" : "Aluminum",
	"Amount" : 12.0
	}
func _ready():
	pass
func USE():
	openCan()

func _on_body_entered(_body):
	if crushed == true and is_inside_tree():
		$"Sound".set_stream(drop)
		$"Sound".play()
	elif is_inside_tree():
		$"Sound".set_stream(dropFull)
		$"Sound".play()

func changeProps():
	itemProps = {
	"Description" : "Whatever you do, don't check for one last drop",
	"Weight" : 0.1,
	#Liquid in ounces
	"Liquid" : 0,
	"Scraps into" : "Aluminum",
	"Amount" : 12.0
	}
	itemStats = {
		"ItemName" : "Empty Can",
		"ItemType" : "Junk",
		"Expires" : false,
		"InvIcon" : "res://InventoryIcons/SodaCanCrushedIcon.png",
		"Stackable": true,
		"id": 302976
	}

func openCan():
	if crushed == false:
		var tween = get_tree().create_tween()
		$"Sound".connect("finished", drinking)
		$"Sound".set_stream(canOpen)
		$"Sound".play()
		tween.tween_property($"GameCan", "blend_shapes/Open Top", 1,0.5)

func drinking():
	$"Sound".disconnect("finished", drinking)
	$"Sound".connect("finished", crush)
	$"Sound".set_stream(drink)
	$"Sound".play()

func crush():
	if crushed == false:
		var tween = get_tree().create_tween()
		$"Sound".set_stream(crushCan)
		$"Sound".play()
		tween.tween_property($"GameCan","blend_shapes/Crush",1,1)
		crushed = true
		self.freeze = true
		changeProps()
