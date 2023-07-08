extends CharacterBody3D
signal getInVehicle(state, id)
@onready var peerID = multiplayer.get_unique_id()
@onready var globals = $"/root/Config"
@onready var playerGlobals = $"/root/PlayerStats"
@onready var mp = $"/root/Networking"
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
@onready var holdingPosition =$"FirstPerson/PlayerView/EquipPosition"
var rng = RandomNumberGenerator.new()
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
var spawnLocation = null

@export var inventory = []

@export var dead = false

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
var currentRunSpeed = 5.0
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
func _ready():
	animation.rpc("Movement", false, "Walk")
	if multiplayer.has_multiplayer_peer():
		for i in mp.peerList.size():
			if mp.peerList[i] != multiplayer.get_unique_id():
				mp.rpc("spawnInstance",mp.peerList[i])
	self.name = str(multiplayer.get_unique_id())
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
			
			var direction = ($"FirstPerson/PlayerView".transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
			
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
	
	rpc("syncLocation",self.get_global_position(),$"FirstPerson/DummyAnimated".rotation.y)
	
	climbLadder()
	
	if inVehicle==true and currentVehicle != null:
		get_node(".").global_transform.origin = currentVehicle.get_global_position()
		currentVehicle.seatCam.make_current()
		
	if Input.is_action_just_pressed("leaveVehicle") and inVehicle == true:
		_getOutOfVehicle()
	
	input_dir = Input.get_vector("left","right","forward","back")
	
	if crouching["isCrouching"] == false and onLadder == false:
		moveAnimController.rpc("Front","Side", input_dir)
	
	elif crouching["isCrouching"] == true:
		moveAnimController.rpc("Crouch Front", "Crouch Side", input_dir)
	
	elif onLadder == true:
		moveAnimController.rpc("Ladder", null, input_dir)
	
	elif inVehicle == true:
		moveAnimController.rpc("Swimming", null, input_dir)
	
	if playerStats["health"] <= 0:
		_on_death()
	
	if Input.is_action_just_pressed("action") and dead == false and inVehicle == false:
		if _vehicleSelect() != null and inVehicle == false:
			_getInVehicle(_vehicleSelect(), true)
		if $"FirstPerson/PlayerView/ItemSelect".is_colliding() == true:
			pickupObject()
	
	if Input.is_action_just_pressed("Attack") and equipped != null:
		useEquipped.rpc()
	encumberanceAdd()
	
func _objectEquip(object,id):
	if equipped != null:
		_unequip()
	for i in object.get_child_count():
		var objects = object.get_children()
		if objects[i] is CollisionShape3D:
			objects[i].disabled = true
			object.set_rotation_degrees(Vector3(0,0,0))
			if object.get_parent() != holdingPosition:
				holdingPosition.add_child(object)
				equipSync.rpc(id)
			object.set_global_position(holdingPosition.get_global_position())
			equipped = object
@rpc("any_peer","call_remote")

func equipSync(objectName):
	pass

func findEquippableObject(objectID):
	for i in inventory.size():
		if inventory[i].itemStats["id"] == objectID:
			return inventory[i]

func _unequip():
	for i in equipped.get_child_count():
		var objects = equipped.get_children()
		if objects[i] is CollisionShape3D:
			objects[i].disabled = false
	holdingPosition.remove_child(equipped)
	equipped = null

func _on_death():
	playerGlobals.call_deferred("emit_signal", "playerDeath")
	animation.rpc("Death", false, "Death")
	#get_node("BodyCollision").shape.height = 0.5
	dead = true

func _crouch():
	if _crouchCheck() == false or crouching["isCrouching"] == false:
		crouching["isCrouching"] = !crouching["isCrouching"]
		syncCrouching.rpc(crouching)
		
	if crouching["isCrouching"] == true:
		animation.rpc("Movement", false, "Crouch")
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
			animation.rpc("Movement", false, "Sprint")
			_staminadrain(stamina["sprinting"])

func _walk():
	animation.rpc("Movement", false, "Walk",0)
	currentRunSpeed = playerStats["walkSpeed"]

func _staminadrain(amount):
	$"StaminaRegen".start(stamina["regenWaitTime"])
	stamina["total"] = stamina["total"] - amount
	syncStamina.rpc(stamina)
	playerGlobals.emit_signal("barChange","stamina", stamina["total"])

func _staminaregen():
	while stamina["total"] < stamina["max"] and $StaminaRegen.is_stopped():
		stamina["total"] += stamina["regenRate"]
		syncStamina(stamina)
		playerGlobals.emit_signal("barChange", "stamina", stamina["total"])
		await create_tween().tween_interval(0.02).finished
		
		#s += stamina["regenRate"]

func _jump():
	if onLadder == true:
		pass
		#self.velocity = Vector3($"FirstPerson/PlayerView".transform.basis * Vector3(0, 0,1).normalized()*15)
	if is_on_floor() and stamina["total"] > stamina["jumping"]:
		_crouchCheck()
		if _crouchCheck() == false or crouching["isCrouching"] == false:
			if onLadder == false:
				animation.rpc("Jump")
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
			animation.rpc("Falling", false, str(false), 1)
		elif onLadder == true:
			animation.rpc("Falling", false, str(false), 0)
		if self.velocity.y < -10:
			lastVelocity = self.velocity.y
	else:
		animation.rpc("Falling", false, str(false), 0)
		calculatedDamage = lastVelocity*-1*playerStats["fallDamageMultiplier"]
		lastVelocity=0
		if calculatedDamage > 0:
			animation.rpc("Hard Landing")
			_incomingDamage(round(calculatedDamage))

func _incomingDamage(amount):
	incomingDamage = amount
	playerStats["health"] = playerStats["health"]-amount
	incomingDamage = 0
	syncStats(playerStats)
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
		animation.rpc("Movement", false,"OnLadder")
		velocity.y = input_dir.y*-playerStats["climbLadderSpeed"]
	else: 
		onLadder = false

func respawnSetup():
	print("spawned")
	respawnFlag = true
	get_node("FirstPerson/DummyAnimated/RiggedDummy/Skeleton3D/BoneAttachment3D/Deathcam").clear_current(false)

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
		
func pickupObject():
	var objects = $"FirstPerson/PlayerView/ItemSelect".get_collision_count()
	var selectedObject = null
	if objects != null:
		for i in objects:
			var itemParent = str($"FirstPerson/PlayerView/ItemSelect".get_collider(i).get_parent())
			if "Items" in itemParent:
				var id = rng.randi()
				selectedObject = $"FirstPerson/PlayerView/ItemSelect".get_collider(i)
				playerGlobals.emit_signal("itemPickedUp", selectedObject,id)
				var objParent = selectedObject.get_parent()
				if selectedObject is RigidBody3D:
					selectedObject.freeze = true
				inventory.append([selectedObject,id])
				pickupSync.rpc(selectedObject.get_parent().get_path(),selectedObject.get_path(),id)
				objParent.remove_child(selectedObject)
				return selectedObject

@rpc("any_peer","call_remote")
func pickupSync(path,objPath,objID):
	pass

@rpc("any_peer","call_remote")
func dropSync(path,objID):
	pass

func dropObject(index,grid,idFlag:=false):
	var object = null
	if idFlag == true:
		object = findInventoryIndexFromID(index)
	else:
		object = index
	if range(inventory.size()).has(object):
		var array = inventory[object]
		var droppedObject = array[0]
		if droppedObject == equipped:
			_unequip()
			equipped = null
		if droppedObject is RigidBody3D:
			droppedObject.freeze = false
#			droppedObject.set_angular_velocity(Vector3(0,0,0))
#			droppedObject.set_axis_velocity(self.velocity)
#			droppedObject.linear_velocity.y = 1
#			droppedObject.set_rotation_degrees(Vector3(0,0,0))
			$"/root/Overworld/Items".add_child(droppedObject)
			var dropTransform = Transform3D(droppedObject.basis,$"FirstPerson/PlayerView/ItemSelect/ClippingChecker/ObjectSpawn".get_global_position())
			print(dropTransform)
			PhysicsServer3D.body_set_state (droppedObject.get_rid(),PhysicsServer3D.BODY_STATE_TRANSFORM,dropTransform)
#			droppedObject.set_global_position($"FirstPerson/PlayerView/ItemSelect/ClippingChecker/ObjectSpawn".get_global_position())
			
			dropSync.rpc(droppedObject.get_parent().get_path(),array[1])
		#syncObjectLocation.rpc(droppedObject.get_path(),$"FirstPerson/PlayerView/ItemSelect/ClippingChecker/ObjectSpawn".get_global_position())
		playerGlobals.emit_signal("itemDropped",droppedObject,grid)
		inventory.remove_at(object)

func encumberanceAdd():
	var weight = 0
	for i in inventory.size():
		var invObj = inventory[i]
		weight += invObj[0].itemProps["Weight"]
	syncStats(playerStats)
	playerStats["equipWeight"] = weight

func findInventoryIndexFromID(id):
	for i in inventory.size():
		var invEntry = inventory[i]
		if invEntry[0].itemStats["id"] == id:
			return i

@rpc("any_peer","call_local")
func useEquipped():
	if playerGlobals.inventoryOpen == false:
		equipped.USE()

@rpc("call_remote","any_peer")
func syncLocation(vector3,yAngle):
	pass
	
@rpc("any_peer","call_local")
func syncObjectLocation(path,loc):
	pass

@rpc("reliable","any_peer","call_local")
func syncStats(stats):
	pass

@rpc("any_peer","call_remote")
func syncCrouching(crouch):
	pass

@rpc("any_peer","call_remote")
func syncStamina(stam):
	pass
