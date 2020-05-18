extends KinematicBody

var speed = 5
var acceleration = 10
var gravity = 0.09 #set physics fps to 240
var jump = 10

var mouse_sensitivity = 0.03

var direction = Vector3()
var velocity = Vector3()
var fall = Vector3() 
var vvel = Vector3()
var inertia
var prev_pos

onready var head = $Head
onready var gc = $GroundCast

func _ready():
	prev_pos = global_transform.origin
	
func _input(event):
	
	if event is InputEventMouseMotion:
		rotate_y(deg2rad(-event.relative.x * mouse_sensitivity)) 
		head.rotate_x(deg2rad(-event.relative.y * mouse_sensitivity)) 
		head.rotation.x = clamp(head.rotation.x, deg2rad(-90), deg2rad(90))

func _physics_process(delta):
	
	var fps = Performance.get_monitor(Performance.TIME_FPS)
	
	direction = Vector3()
	
	if Input.is_action_pressed("move_forward"):
	
		direction -= transform.basis.z
	
	elif Input.is_action_pressed("move_backward"):
		
		direction += transform.basis.z
		
	if Input.is_action_pressed("move_left"):
		
		direction -= transform.basis.x			
		
	elif Input.is_action_pressed("move_right"):
		
		direction += transform.basis.x
	
	
	#keeps character controller moving at the same speed whether moving up/down slopes or on flat ground. Thank you Wizardtroll Games
	
	inertia = (prev_pos - global_transform.origin).length() * fps / speed 
	direction = direction.normalized() * speed
	direction += direction * (1.5 - inertia)
	direction.y = vvel.y 
	
	if not is_on_floor():
		vvel.y -= gravity
	else:
		vvel.y = -0.1
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		vvel.y = jump
		move_and_slide(vvel, Vector3.UP) #move_and_slide_with_snap prevents jumping, so I used move_and_slide just for jumping
	
	prev_pos = global_transform.origin
	
	move_and_slide_with_snap(direction, Vector3.DOWN, Vector3.UP, true, 7, 0.8) 
