extends RigidBody3D
var light = false
@export var brightness = 11.0
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
	
func toggleLight():
	light = !light
	if light == true:
		$"Body/Light".light_energy = brightness
	else:
		$"Body/Light".light_energy = 0
