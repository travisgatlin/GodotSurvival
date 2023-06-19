extends RigidBody3D
var light = false
var battery = true
#ENTRIES PREFILLED MUST BE DEFINED OR OBJECT WILL NOT WORK
@export var itemStats = {
	"ItemName" : "Flashlight",
	"ItemType" : "Tool",
	#REMOVE COMMENT AND DEFINE ONLY IF ITEM IS FOOD OR DRINK
	#"Expires" : ,
	"InvIcon" : "res://InventoryIcons/Flashlight_icon.png",
	"Stackable": false,
	#USE AN RNG GENERATOR TO MAKE THIS, HIGHER NUMBER USUALLY THE BETTER, MAX NUMBER OF 9223372036854775807
	#THAT NUMBER IS THE HIGHEST A 64 BIT INTEGER CAN BE, I HAVE NO IDEA WHAT WOULD HAPPEN IF YOU WENT OVER THAT
	"id": 170160
}
#FOR CUSTOM FUNCTIONS, IF SCRAPS INTO AND AMOUNT IS NOT DEFINED WITH AN IN GAME MATERIAL, SCRAPPING OBJECT WILL NOT WORK
@export var itemProps = {
	"Weight" : 3.5 ,
	"Scraps into" : "Aluminum",
	"Amount" : 3.5,
	"Battery" : 100
	}
func _process(delta):
	if light == true:
		var batteryPercent = ($Battery.time_left/$Battery.wait_time)*100
		itemProps["Battery"] = batteryPercent
		$"Battery".paused = false
	else:
		$"Battery".paused = true
func USE():
	toggleLight()
	
func toggleLight():
	if battery == true:
		light = !light
	if light == true:
		$"Lens on".visible = true
		$"Light".visible = true
		$"Lens off".visible = false
	else:
		$"Lens off".visible = true
		$"Light".visible = false
		$"Lens on".visible = false


func _on_battery_timeout():
	toggleLight()
	battery = false
	$"Battery".stop()

func newBattery():
	battery = true
	$"Battery".start($"Battery".wait_time)
