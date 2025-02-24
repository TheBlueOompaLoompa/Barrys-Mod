extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@export var player := 1

var in_pause_menu = false

func _enter_tree():
    set_multiplayer_authority(str(name).to_int())
    if not is_multiplayer_authority(): return
    
    get_node('/root/Game/Mods/ModMenu').SpawnProp.connect(func(prop):
        if not is_multiplayer_authority(): return
        if $Camera/RayCast3D.is_colliding():
            get_node('/root/Game/Mods/Props').add_child(prop)
            prop.global_position = $Camera/RayCast3D.get_collision_point()
    )

func _ready():
    if not is_multiplayer_authority(): return
    $Camera.current = true

func _unhandled_input(event):
    if (not is_multiplayer_authority()) or in_pause_menu: return
    
    if event is InputEventMouseMotion:
        rotate_y(-event.relative.x * .005)
        $Camera.rotate_x(-event.relative.y * .005)
        $Camera.rotation.x = clamp($Camera.rotation.x, -PI/2, PI/2)

func _input(event):
    if not is_multiplayer_authority(): return
    if event.is_action_pressed("open_mod_menu"):
        in_pause_menu = get_tree().root.get_node("/root/Game/Mods").toggle_mod_menu()
        if in_pause_menu: get_tree().root.get_node("/root/Game/Mods").connect("Closed", func(): in_pause_menu = false)

func _process(_delta):
    if not is_multiplayer_authority(): return
    if in_pause_menu:
        Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    else:
        Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

var positon_set = false

func _physics_process(delta):
    if not is_multiplayer_authority(): return
    # Add the gravity.
    if not is_on_floor():
        velocity.y -= gravity * delta
    
    if not positon_set:
        if name != '1': global_position = Vector3(0, 1, 0)
        axis_lock_linear_x = false
        axis_lock_linear_y = false
        axis_lock_linear_z = false
        positon_set = true

    # Handle Jump.
    if Input.is_action_just_pressed("ui_accept") and is_on_floor():
        velocity.y = JUMP_VELOCITY

    # Get the input direction and handle the movement/deceleration.
    # As good practice, you should replace UI actions with custom gameplay actions.
    var input_dir = Input.get_vector("left", "right", "forward", "backward")
    var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
    if not in_pause_menu:
        if direction:
            velocity.x = direction.x * SPEED
            velocity.z = direction.z * SPEED
        else:
            velocity.x = move_toward(velocity.x, 0, SPEED)
            velocity.z = move_toward(velocity.z, 0, SPEED)

    move_and_slide()
