extends RigidBody3D
var isPopulated = false
var uuid = self.get_instance_id()
var inventoryProps = [
#objectType 0
"chest",
#food 1
0,
#water 2 
0,
#poison 3
0,
#uses 4
0,
#weight/encumberance 5
get_node(".").mass,
#path to icon 6
"res://invIcons/2LiterIcon.png",
#name in inventory 7
"Chest",
#stackable 8
false,
#is this the same object as another instance? aka object type identifier 9
"Chest",
#object Scene Reference 10
"res://chest.tscn",
#uniqueIdentifier 11
uuid,
#storageamount 12
25,

	]

var storage = [
	
]
