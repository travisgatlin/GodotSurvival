extends BoneAttachment3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

@rpc("any_peer","unreliable")
func headSync(rot):
	$"../DummyAnimated/RiggedDummy/Skeleton3D".set_bone_pose_rotation(37,rot)
