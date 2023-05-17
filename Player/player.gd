extends CharacterBody3D
signal getInVehicle(state, id)
@onready var globals = get_node("/root/Config")
@onready var playerGlobals = get_node("/root/PlayerStats")
#@onready var state_machine = get_node("FirstPerson/MainTree")["parameters/playback"]
@onready var mainTree = get_node("FirstPerson/MainTree")
@onready var animationBlends = {
	"Movement": "parameters/Locomotion",
	"Jump": "parameters/JumpTransition",
	"Shooting": "parameters/ShootingBlend",
	"Death": "parameters/DeathTrans",
	"Side": "parameters/Side/blend_amount",
	"Front": "parameters/Front/blend_amount"
}
@onready var animationTrees = {
	"Sprinting": ["parameters/Sprinting/playback"],
	"Crouching": ["parameters/Crouching/playback"],
	"Jump": ["parameters/Jumping/playback"],
	"Shooting": ["parameters/Shooting/playback"]
}

var inWater = false
var inVehicle = false
var currentVehicle = null
var lastVelocity = 0
var incomingDamage = 0
var calculatedDamage = 0
var onLadder = false
var respawnFlag = false
var initialSpawn = true
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
	"height":2.0,
	"baseCamHeight":0.595,
	"fallDamageMultiplier":3,
	"minimumFallDamageTime":1.5,
	"climbLadderSpeed": 2.0,
}
@export var crouching = {
	"isCrouching":false,
	"height":1.0,
	"walkSpeed": 1.5,
	"crouchCheck": false
}
var currentRunSpeed = 5.0
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
func _ready():
	animation("Movement", "Walk")
	if respawnFlag == true or initialSpawn == true:
		
		if playerGlobals.spawnPoint != null:
			self.set_global_position(playerGlobals.spawnPoint)
			respawnFlag = false
			initialSpawn = false
	
	playerGlobals.emit_signal("barChange", "stamina", stamina["total"])
	
	playerGlobals.emit_signal("barChange", "health", playerStats["health"])
	
	self.set_global_rotation(Vector3(0,0,0))
	
func _physics_process(delta):
	if get_node("FirstPerson/DummyAnimated/LadderRay").is_colliding():
		ladderUp()
	else:
		onLadder = false
	
	if inVehicle==true and currentVehicle != null:
		#get_node(".").global_transform.origin = currentVehicle.get_global_position()
		#currentVehicle.seatCam.make_current()
		pass
	
	if playerStats["health"] <= 0:
		_on_death()
	
	if not is_on_floor() and inWater == false and inVehicle==false and onLadder == false:
		velocity.y -= gravity * delta
		_fallDamage()
	else:
		_fallDamage()
		
	if dead == false:
		#print(get_node("BodyCollision2").get_global_rotation())
		
		if inVehicle == false:
			if Input.is_action_just_pressed("jump"):
				_jump()
			if Input.is_action_just_pressed("crouch"):
				_crouch()
			if Input.is_action_pressed("sprint"):
				_sprint()
			elif crouching["isCrouching"] == false:
				_walk()
			
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
			var input_dir = Input.get_vector("left","right","forward","back")
			var direction = (get_node("FirstPerson/PlayerView").transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
			if direction and onLadder == false:
				velocity.x = direction.x * currentRunSpeed
				velocity.z = direction.z * currentRunSpeed
			else:
				velocity.x = move_toward(velocity.x, 0, currentRunSpeed)
				velocity.z = move_toward(velocity.z, 0, currentRunSpeed)
			moveAnimController("Front","Side", input_dir)
			playerGlobals.emit_signal("debug", str(input_dir))
		if Input.is_action_just_pressed("action"):
			if _vehicleSelect() != null and inVehicle == false:
				_getInVehicle(_vehicleSelect(), true)
		
		if Input.is_action_just_pressed("leaveVehicle") and inVehicle == true:
			_getOutOfVehicle()
		move_and_slide()

func _on_death():
	playerGlobals.call_deferred("emit_signal", "playerDeath")
	#animationController("Falling Back")
	#get_node("BodyCollision").shape.height = 0.5
	dead = true
	
func _crouch():
	_crouchCheck()
	if crouching["isCrouching"] == false:
		crouching["isCrouching"] = true
	elif crouching["crouchCheck"] == false:
		crouching["isCrouching"] = false
		
	if crouching["isCrouching"] == true:
		var crouchPosition = playerStats["height"] - crouching["height"]
		get_node("BodyCollision2").shape.height = crouching["height"]
		get_node("FirstPerson/DummyAnimated").position.y = crouchPosition
		currentRunSpeed = crouching["walkSpeed"]
	else:
		get_node("BodyCollision2").shape.height = playerStats["height"]
		get_node("FirstPerson/DummyAnimated").position.y = 0

func _crouchCheck():
	
	crouching["crouchCheck"] = get_node("CrouchCheck").is_colliding()

func _sprint():
	if crouching["isCrouching"] == false and stamina["total"] > 0:
		currentRunSpeed = playerStats["runSpeed"]
		if velocity.z != 0:
			_staminadrain(stamina["sprinting"])
	else:
		_walk()

func _walk():
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
		onLadder = false
		get_node("FirstPerson/DummyAnimated/LadderRay").enabled = false
		await get_tree().create_timer(0.2).timeout
		get_node("FirstPerson/DummyAnimated/LadderRay").enabled = true
		
	
	if is_on_floor() and stamina["total"] > stamina["jumping"]:
		_crouchCheck()
		if crouching["crouchCheck"] == false or crouching["isCrouching"] == false:
			if onLadder == false:
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
func _selectObject():
	var collisions = get_node("PlayerView/ItemSelect").get_collision_count()
	var validSelections = []
	validSelections = []
	if get_node("FirstPerson/PlayerView/ItemSelect").is_colliding():
		for i in collisions:
			if get_node("FirstPerson/PlayerView/ItemSelect").get_collider(i).get_parent() != get_node("../StaticLevel"):
				var object = get_node("FirstPerson/PlayerView/ItemSelect").get_collider(i)
				if object.get_parent() == get_node("../Items"):
					validSelections.append(object)
				return validSelections

func _vehicleSelect():
	if get_node("FirstPerson/PlayerView/ItemSelect/VehicleCheck").is_colliding():
		var vehicle = get_node("FirstPerson/PlayerView/ItemSelect/VehicleCheck").get_collider()
		if vehicle.get("vehicleStats"):
			return vehicle
		else:
			return null

func _fallDamage():
	if not is_on_floor():
		if onLadder == false and crouching["isCrouching"] == false:
			pass
			#animationController("FallingIdle")
		if self.velocity.y < -10:
			lastVelocity = self.velocity.y
	else:
		calculatedDamage = lastVelocity*-1*playerStats["fallDamageMultiplier"]
		lastVelocity=0
		if calculatedDamage > 0:
			_incomingDamage(round(calculatedDamage))
func _incomingDamage(amount):
	incomingDamage = amount
	playerStats["health"] = playerStats["health"]-amount
	incomingDamage = 0
	playerGlobals.emit_signal("barChange", "health", playerStats["health"])

func ladderUp():
	var currentObject = null
	var ladderObjects = []
	for n in get_node("FirstPerson/DummyAnimated/LadderRay").get_collision_count():
		currentObject=get_node("FirstPerson/DummyAnimated/LadderRay").get_collider(n).get_parent().get_parent()
		if currentObject.has_meta("Ladder") == true:
			ladderObjects.append("Ladder")
	if ladderObjects.has("Ladder") and get_node("FirstPerson/DummyAnimated/LadderRay").is_colliding()==true:
		onLadder = true
		if Input.is_action_pressed("forward"):
			velocity.y = playerStats["climbLadderSpeed"]
		else: 
			velocity.y = 0
		if Input.is_action_pressed("back"):
			velocity.y = playerStats["climbLadderSpeed"] * -1
	else: 
		onLadder = false
func respawnSetup():
	respawnFlag = true
	get_node("FirstPerson/DummyAnimated/RiggedDummy/Skeleton3D/BoneAttachment3D/Deathcam").clear_current(false)
		
func animation(key,state:=str(null),destination:="start"):
	if state != null and state != mainTree[animationBlends[key]+"/current_state"]:
		mainTree.set(animationBlends[key]+"/transition_request",state)
	if destination != "start" and state != mainTree["parameters/Locomotion/current_state"]:
		mainTree[animationTrees[state]].travel(destination)

func moveAnimController(moveset1,moveset2,vector2):
	var tween = create_tween().set_parallel(true)
	tween.tween_property($FirstPerson/MainTree, animationBlends[moveset1], vector2.y, 0.1)
	tween.tween_property($FirstPerson/MainTree, animationBlends[moveset2], vector2.x, 0.1)
#	mainTree.set(animationBlends[str(moveset1)], vector2.y)
#	mainTree.set(animationBlends[str(moveset2)], vector2.x)
