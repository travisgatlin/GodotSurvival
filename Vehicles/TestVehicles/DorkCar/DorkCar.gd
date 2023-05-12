extends VehicleBody3D
var playerEntered = false
@onready var playerGlobals = get_node("/root/PlayerStats")
var uuid = RandomNumberGenerator.new()
#@onready var seatCam = get_node("Player Seat/Camera3D")
var vehicleStats = {
	"maxAcceleration":110324.8125,
	"backupAcceleration":3000, 
	"braking":50,
	"turningRadius":45,
	"health":100,
	"gas":100
}
var inventory = []
var currentAcceleration = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	playerGlobals.enterVehicle.connect(playerGetIn)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if playerEntered == true:
		if Input.is_action_pressed ("brake"):
			if self.get_linear_velocity().x > 0:
				self.brake = vehicleStats["braking"]
				currentAcceleration = 0
			if self.get_linear_velocity().x < 1:
				currentAcceleration = vehicleStats["backupAcceleration"]
		else:
			self.brake = 0
		
		if Input.is_action_just_pressed("accelerate"):
			currentAcceleration = vehicleStats["maxAcceleration"]
		var steeringdir = Input.get_vector("brake", "accelerate", "turn right", "turn left")
		self.engine_force = steeringdir.x*currentAcceleration
		self.steering = steeringdir.y


func playerGetIn(state, id):
	self.brake=0
	if uuid == id or state == false:
		playerEntered = state
