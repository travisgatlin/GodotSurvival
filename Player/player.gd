extends CharacterBody3D
signal getInVehicle(state, id)
@onready var globals = $"/root/Config"
@onready var playerGlobals = $"/root/PlayerStats"
#@onready var state_machine = get_node("FirstPerson/MainTree")["parameters/playback"]
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
@onready var currentPosition = $BodyCollision2.position
@onready var cameraPosition = $"FirstPerson/PlayerView".position
var inWater = false
var inVehicle = false
var currentVehicle = null
var lastVelocity = 0
var incomingDamage = 0
var calculatedDamage = 0
var onLadder = false
var respawnFlag = false
var initialSpawn = true
var input_dir = Vector2(0,0)
var equipped = null

@export var inventory = []

@export var dead = false

@export var stamina = {
	"total": 100.0,
	"jumping": 15,
	"punching": 20,
	"meleeSwing": 15,
	"sprinting":0.4,
	"max": 100.0,
	"regenRate": 0.3,
	"regenWaitTime": 3.0
}
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
	"height":1.0,
	"walkSpeed": 1.5,
}
var currentRunSpeed = 5.0
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
func _ready():
	$"FirstPerson/PlayerView/ItemSelect".add_exception(self)
	animation("Movement", false , "Walk",0)
	if respawnFlag == true or initialSpawn == true:
		
		if playerGlobals.spawnPoint != null:
			self.set_global_position(playerGlobals.spawnPoint)
			respawnFlag = false
			initialSpawn = false
	
	playerGlobals.emit_signal("barChange", "stamina", stamina["total"])
	
	playerGlobals.emit_signal("barChange", "health", playerStats["health"])
	
	playerGlobals.connect("dropItem",dropObject)
	playerGlobals.connect("equipItem", _objectEquip)
	self.set_global_rotation(Vector3(0,0,0))

func _physics_process(delta):
	if not is_on_floor() and inWater == false and inVehicle==false and onLadder == false:
		velocity.y -= gravity * delta
		_fallDamage()
	else:
		_fallDamage()
		
	if dead == false:
		
		if inVehicle == false:
			if Input.is_action_just_pressed("jump"):
				_jump()
			if Input.is_action_just_pressed("crouch"):
				_crouch()
			if Input.is_action_pressed("sprint"):
				_sprint()
			elif crouching["isCrouching"] == false and onLadder == false:
				_walk()
			
			var direction = (get_node("FirstPerson/PlayerView").transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
			
			if direction and onLadder == false:
				velocity.x = direction.x * currentRunSpeed
				velocity.z = direction.z * currentRunSpeed
			else:
				velocity.x = move_toward(velocity.x, 0, currentRunSpeed)
				velocity.z = move_toward(velocity.z, 0, currentRunSpeed)
			playerGlobals.emit_signal("debug", str(inventory))
		move_and_slide()

func _process(_delta):
	
	onLadder = ladderCheck()
	
	climbLadder()
	if inVehicle==true and currentVehicle != null:
		get_node(".").global_transform.origin = currentVehicle.get_global_position()
		currentVehicle.seatCam.make_current()
		
	if Input.is_action_just_pressed("leaveVehicle") and inVehicle == true:
		_getOutOfVehicle()
	
	input_dir = Input.get_vector("left","right","forward","back")
	
	if crouching["isCrouching"] == false and onLadder == false:
		moveAnimController("Front","Side", input_dir)
	
	elif crouching["isCrouching"] == true:
		moveAnimController("Crouch Front", "Crouch Side", input_dir)
	
	elif onLadder == true:
		moveAnimController("Ladder", null, input_dir)
	
	elif inVehicle == true:
		moveAnimController("Swimming", null, input_dir)
	
	if playerStats["health"] <= 0:
		_on_death()
	
	if Input.is_action_just_pressed("action") and dead == false and inVehicle == false:
		if _vehicleSelect() != null and inVehicle == false:
			_getInVehicle(_vehicleSelect(), true)
		if $"FirstPerson/PlayerView/ItemSelect".is_colliding() == true:
			pickupObject()
	
	if Input.is_action_just_pressed("Attack") and equipped != null:
		useEquipped()
	encumberanceAdd()
func _objectEquip(objectID):
	if equipped != null:
		_unequip()
	var object = null
	var equipPosition = $"FirstPerson/PlayerView/EquipPosition"
	for i in inventory.size():
		if inventory[i].itemStats["id"] == objectID:
			object = inventory[i]
			equipped = object
			break
	for i in object.get_child_count():
		var objects = object.get_children()
		if objects[i] is CollisionShape3D:
			objects[i].disabled = true
	object.set_rotation_degrees(Vector3(0,0,0))
	$"FirstPerson/PlayerView/EquipPosition".add_child(object)
	object.set_global_position(equipPosition.get_global_position())

func _unequip():
	for i in equipped.get_child_count():
		var objects = equipped.get_children()
		if objects[i] is CollisionShape3D:
			objects[i].disabled = false
	$"FirstPerson/PlayerView/EquipPosition".remove_child(equipped)
	equipped = null
func _on_death():
	playerGlobals.call_deferred("emit_signal", "playerDeath")
	animation("Death", false, "Death")
	#get_node("BodyCollision").shape.height = 0.5
	dead = true

func _crouch():
	if _crouchCheck() == false or crouching["isCrouching"] == false:
		crouching["isCrouching"] = !crouching["isCrouching"]
		
	if crouching["isCrouching"] == true:
		animation("Movement", false, "Crouch")
		var crouchPosition = playerStats["height"] - crouching["height"]
		$"BodyCollision2".shape.height = crouching["height"]
		$"FirstPerson/DummyAnimated".position.y = crouchPosition
		currentRunSpeed = crouching["walkSpeed"]
	else:
		$"BodyCollision2".shape.height = playerStats["height"]
		$"FirstPerson/DummyAnimated".position.y = 0

func _crouchCheck():
	return $"CrouchCheck".is_colliding()

func _sprint():
	if crouching["isCrouching"] == false and stamina["total"] > 0:
		currentRunSpeed = playerStats["runSpeed"]
		if velocity.z != 0:
			animation("Movement", false, "Sprint")
			_staminadrain(stamina["sprinting"])

func _walk():
	animation("Movement", false, "Walk",0)
	currentRunSpeed = playerStats["walkSpeed"]

func _staminadrain(amount):
	get_node("StaminaRegen").start(stamina["regenWaitTime"])
	stamina["total"] = stamina["total"] - amount
	playerGlobals.emit_signal("barChange","stamina", stamina["total"])

func _staminaregen():
	while stamina["total"] < stamina["max"] and $StaminaRegen.is_stopped():
		stamina["total"] += stamina["regenRate"]
		playerGlobals.emit_signal("barChange", "stamina", stamina["total"])
		await create_tween().tween_interval(0.02).finished
		
		#s += stamina["regenRate"]

func _jump():
	if onLadder == true:
		self.velocity = Vector3($"FirstPerson/PlayerView".transform.basis * Vector3(0, 0,1).normalized()*15)
	if is_on_floor() and stamina["total"] > stamina["jumping"]:
		_crouchCheck()
		if _crouchCheck() == false or crouching["isCrouching"] == false:
			if onLadder == false:
				animation("Jump")
				velocity.y = playerStats["jumpHeight"]
			_staminadrain(stamina["jumping"])

func _on_stamina_regen_timeout():
	_staminaregen()

func _getInVehicle(vehicle, state):
	inVehicle = state
	if inVehicle == true:
		currentVehicle = vehicle
		playerGlobals.emit_signal("enterVehicle",true,currentVehicle.get("uuid"))
		#get_node("FirstPerson/PlayerView").current = false
		#get_node("VehicleCamera3D").current = true
		get_node("BodyCollision2").disabled = true

func _getOutOfVehicle():
		inVehicle = false
		playerGlobals.emit_signal("enterVehicle",false, null)
		#var currentPosition = Vector3()
		transform.origin = currentVehicle.get_node("Door").get_global_position()
		currentVehicle = null
		get_node("FirstPerson/PlayerView").current = true
		get_node("VehicleCamera3D").current = false
		await get_tree().create_timer(0.1).timeout
		get_node("BodyCollision2").disabled = false

func _vehicleSelect():
	if $"FirstPerson/PlayerView/ItemSelect/VehicleCheck".is_colliding():
		var vehicle = $"FirstPerson/PlayerView/ItemSelect/VehicleCheck".get_collider()
		if vehicle.get("vehicleStats"):
			return vehicle
		else:
			return null

func _fallDamage():
	if not is_on_floor():
		if onLadder == false and crouching["isCrouching"] == false and !$"FallCheck".is_colliding():
			animation("Falling", false, str(false), 1)
		elif onLadder == true:
			animation("Falling", false, str(false), 0)
		if self.velocity.y < -10:
			lastVelocity = self.velocity.y
	else:
		animation("Falling", false, str(false), 0)
		calculatedDamage = lastVelocity*-1*playerStats["fallDamageMultiplier"]
		lastVelocity=0
		if calculatedDamage > 0:
			animation("Hard Landing")
			_incomingDamage(round(calculatedDamage))

func _incomingDamage(amount):
	incomingDamage = amount
	playerStats["health"] = playerStats["health"]-amount
	incomingDamage = 0
	playerGlobals.emit_signal("barChange", "health", playerStats["health"])

func ladderCheck():
	var headRay = $"FirstPerson/DummyAnimated/LadderRayHead".get_collider()
	var feetRay = $"FirstPerson/DummyAnimated/LadderRayFeet".get_collider()
	if headRay != null:
		if "Ladder" in headRay.name:
			return true
	if feetRay != null:
		if "Ladder" in feetRay.name:
			return true
	if headRay == null and feetRay == null:
		return false

func climbLadder():
	if onLadder == true:
		animation("Movement", false,"OnLadder")
		velocity.y = input_dir.y*-playerStats["climbLadderSpeed"]
	else: 
		onLadder = false

func respawnSetup():
	respawnFlag = true
	get_node("FirstPerson/DummyAnimated/RiggedDummy/Skeleton3D/BoneAttachment3D/Deathcam").clear_current(false)
		
func animation(key,oneshot:=true,state:=str(false),value:=0, time:=0.2):
	if state != str(false) and oneshot == false:
		if state != mainTree[animationBlends[key]+"/current_state"]:
			mainTree.set(animationBlends[key]+"/transition_request",state)
	if oneshot == true:
		mainTree.set(animationBlends[key], AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	if oneshot == false and state == "false":
		create_tween().tween_property(mainTree,animationBlends[key],value,time)

func moveAnimController(moveset1,moveset2,vector2):
	var tween = create_tween().set_parallel(true)
	if moveset1 != null:
		tween.tween_property($FirstPerson/MainTree, animationBlends[moveset1], vector2.y, 0.1)
	if moveset2 != null:
		tween.tween_property($FirstPerson/MainTree, animationBlends[moveset2], vector2.x, 0.1)

func pickupObject():
	var objects = $"FirstPerson/PlayerView/ItemSelect".get_collision_count()
	var selectedObject = null
	if objects != null:
		for i in objects:
			var itemParent = str($"FirstPerson/PlayerView/ItemSelect".get_collider(i).get_parent())
			if "Items" in itemParent:
				selectedObject = $"FirstPerson/PlayerView/ItemSelect".get_collider(i)
				playerGlobals.emit_signal("itemPickedUp", selectedObject)
				var objParent = selectedObject.get_parent()
				if selectedObject is RigidBody3D:
					selectedObject.freeze = true
				inventory.append(selectedObject)
				objParent.remove_child(selectedObject)
				return selectedObject

func dropObject(index,grid,idFlag:=false):
	var object = null
	if idFlag == true:
		object = findInventoryIndexFromID(index)
	else:
		object = index
	if range(inventory.size()).has(object):
		var droppedObject = inventory[object]
		if droppedObject == equipped:
			_unequip()
			equipped == null
		$"/root/Overworld/Items".add_child(droppedObject)
		droppedObject.set_rotation_degrees(Vector3(0,0,0))
		droppedObject.set_global_position($"FirstPerson/PlayerView/ItemSelect/ClippingChecker/ObjectSpawn".get_global_position())
		if droppedObject is RigidBody3D:
			droppedObject.freeze = false
			droppedObject.set_angular_velocity(Vector3(0,0,0))
			droppedObject.set_axis_velocity(self.velocity)
		playerGlobals.emit_signal("itemDropped",droppedObject,grid)
		inventory.remove_at(object)

func encumberanceAdd():
	var weight = 0
	for i in inventory.size():
		weight += inventory[i].itemProps["Weight"]
	playerStats["equipWeight"] = weight

func findInventoryIndexFromID(id):
	for i in inventory.size():
		var invEntry = inventory[i]
		if invEntry.itemStats["id"] == id:
			return i

func useEquipped():
	if playerGlobals.inventoryOpen == false:
		equipped.USE()
#func highlightObject():
#	var objects = $"FirstPerson/PlayerView/ItemSelect".get_collision_count()
#	var selectedObject = null
#	if objects != null:
#		for i in objects:
#			var itemParent = str($"FirstPerson/PlayerView/ItemSelect".get_collider(i).get_parent())
#			if "Items" in itemParent:
#				selectedObject = $"FirstPerson/PlayerView/ItemSelect".get_collider(i)
#func climbStairs():
#	print (str($"FirstPerson/DummyAnimated/LadderRayFeet".is_colliding())+ " " + str($"FirstPerson/DummyAnimated/StairCheck".is_colliding()))
#	if $"FirstPerson/DummyAnimated/LadderRayFeet".is_colliding() and !$"FirstPerson/DummyAnimated/StairCheck".is_colliding() and onLadder == false:
#		self.translate(Vector3(0,0.3,0))
