extends RigidBody3D
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
	"Weight" : 0.2,
	"Scraps into" : "Plastic",
	"Amount" : 15.0
	}
