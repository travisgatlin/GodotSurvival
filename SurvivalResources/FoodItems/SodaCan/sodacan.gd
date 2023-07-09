extends RigidBody3D
var reference = "res://SurvivalResources/FoodItems/SodaCan/soda_can.tscn"
var drop = preload("res://Generic Sounds/Metal ding.wav")
var dropFull = preload("res://Generic Sounds/Solid Object Hitting Ground.wav")
var crushCan = preload("res://SurvivalResources/FoodItems/SodaCan/326211__blu_150058__can-crushing.wav")
var canOpen = preload ("res://SurvivalResources/FoodItems/SodaCan/393877__inspectorj__fizzy-drink-can-opening-a.wav")
var drink = preload ("res://Generic Sounds/534336__defaultv__drink_gulp.wav")
@export var itemStats = {
	"Crushed" : false,
	"ItemName" : "Soda Can",
	"ItemType" : "Drink",
	"Expires" : false,
	"InvIcon" : "res://InventoryIcons/sodacanicon.png",
	"Stackable": true,
	"id": 233019,
	"Crush" : 0,
	"OpenTop" : 0,
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
	updateBlendShape("OpenTop","blend_shapes/Open Top")
	updateBlendShape("Crush","blend_shapes/Crush")
func USE():
	openCan()

func _on_body_entered(_body):
	if itemStats["Crushed"] == true and is_inside_tree():
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
	"Amount" : 12.0,
	}
	itemStats = {
		"ItemName" : "Empty Can",
		"ItemType" : "Junk",
		"Expires" : false,
		"InvIcon" : "res://InventoryIcons/SodaCanCrushedIcon.png",
		"Stackable": true,
		"Crush" : 1,
		"OpenTop" : 1,
		"Crushed" : true,
		"id": 302976
	}

func updateBlendShape(prop,shape,amount:=0.0,time:=0.0):
	if amount > 0.0:
		var tween = get_tree().create_tween()
		tween.parallel().tween_property($"GameCan",shape,amount,time)
		await !tween.is_running()
		itemStats[prop] = $"GameCan".get(shape)
	else:
		$"GameCan".set(shape,itemStats[prop])

func openCan():
	if itemStats["Crushed"] == false:
		$"Sound".connect("finished", drinking)
		$"Sound".set_stream(canOpen)
		$"Sound".play()
		updateBlendShape("OpenTop","blend_shapes/Open Top", 0.1, 1.03)
		await get_tree().create_timer(1.03).timeout
		updateBlendShape("OpenTop","blend_shapes/Open Top", 1, 0.09)

func drinking():
	await get_tree().create_timer(0.5).timeout
	$"Sound".disconnect("finished", drinking)
	$"Sound".connect("finished", crush)
	$"Sound".set_stream(drink)
	$"Sound".play()

func crush():
	if itemStats["Crushed"] == false:
		$"Sound".set_stream(crushCan)
		$"Sound".play()
		updateBlendShape("Crush","blend_shapes/Crush",1,1)
		itemStats["Crushed"] = true
		self.freeze = true
		changeProps()
