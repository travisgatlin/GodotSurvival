extends CharacterBody3D
@export var peerID = 0
@export var nickname=""
@onready var mainTree = $"FirstPerson/MainTree"
@onready var animationBlends = {
	"Movement": "parameters/Locomotion",
	"Jump": "parameters/Jump/request",
	"Shooting": "parameters/ShootingBlend",
	"Death": "parameters/DeathTrans",
	"Side": "parameters/Side/blend_amount",
	"Front": "parameters/Front/blend_amount",
	"Crouch Front": "parameters/Crouch Front/blend_amount",
	"Crouch Side": "parameters/Crouch Side/blend_amount",
	"Falling": "parameters/Falling/blend_amount",
	"Ladder": "parameters/Climb/scale",
	"Hard Landing": "parameters/Hard Landing/request",
	"Swim": "parameters/SwimBlend/blend_amount",
}
@export var inventory = []
@export var equipped = Node
@export var playerStats = {
	"health": 100,
	"food": 100,
	"thirst":100,
	"runSpeed":8.0,
	"walkSpeed":4.0,
	"jumpHeight":6.0,
	"equipWeight":0,
	"maxWeight":100,
	"height":1.8,
	"baseCamHeight":0.595,
	"fallDamageMultiplier":3,
	"minimumFallDamageTime":1.5,
	"climbLadderSpeed": 2.0,
	"maxStairHeight": 1.0,
}
@export var crouching = {
	"isCrouching":false,
	"height":1.25,
	"walkSpeed": 1.5,
}
@export var stamina = {
	"total": 10000.0,
	"jumping": 15,
	"punching": 20,
	"meleeSwing": 15,
	"sprinting":0.4,
	"max": 100.0,
	"regenRate": 0.3,
	"regenWaitTime": 3.0
}
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
func _ready():
	equipped = null
	peerID = self.name
func _physics_process(_delta):
	pass
func _process(_delta):
	pass
@rpc("reliable","any_peer")
func syncLocation(vector3,yAngle):
	self.set_global_position(vector3)
	$"FirstPerson/DummyAnimated".rotation.y = yAngle


@rpc("unreliable","any_peer","call_local")
func animation(key,oneshot:=true,state:=str(false),value:=0, time:=0.2):
	if state != str(false) and oneshot == false:
		if state != mainTree[animationBlends[key]+"/current_state"]:
			mainTree.set(animationBlends[key]+"/transition_request",state)
	if oneshot == true:
		mainTree.set(animationBlends[key], AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	if oneshot == false and state == "false":
		create_tween().tween_property(mainTree,animationBlends[key],value,time)

@rpc("unreliable","any_peer","call_local")
func moveAnimController(moveset1,moveset2,vector2):
	var tween = create_tween().set_parallel(true)
	if moveset1 != null:
		tween.tween_property($FirstPerson/MainTree, animationBlends[moveset1], vector2.y, 0.1)
	if moveset2 != null:
		tween.tween_property($FirstPerson/MainTree, animationBlends[moveset2], vector2.x, 0.1)

@rpc("any_peer","reliable")
func pickupSync(path,objName,reference,stats,props):
	inventory.append([reference,objName,stats,props])
	get_node((str(path)+"/"+str(objName))).queue_free()

@rpc("any_peer","reliable")
func dropSync(path,objname,loc,reference,stats,props):
	$"/root/Overworld".itemSpawn(reference,objname,loc,stats,props)
	for i in inventory.size():
		var invSlot = inventory[i]
		print (invSlot, objname)
		if invSlot[1] == objname:
			inventory.remove_at(i)
			break

@rpc("any_peer")
func useEquipped():
	if equipped != null:
		equipped.USE()

@rpc("any_peer","reliable","call_local")
func syncStats(stats):
	playerStats = stats

@rpc("any_peer","call_remote")
func syncCrouching(crouch):
	crouching = crouch
	crouch()

@rpc("any_peer","call_remote")
func syncStamina(stam):
	stamina = stam

func crouch():
	if crouching["isCrouching"] == true:
		var crouchPosition = playerStats["height"] - crouching["height"]
		$"FirstPerson/DummyAnimated".position.y = crouchPosition
	else:
		$"BodyCollision2".shape.height = playerStats["height"]
		$"FirstPerson/DummyAnimated".position.y = 0

@rpc("any_peer","call_remote")
func equipSync(reference):
	pass

@rpc("any_peer","call_remote")
func invSync(objName,reference,stats,props):
	inventory.append([objName,reference,stats,props])
