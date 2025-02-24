extends Control

signal SpawnProp(prop)

func add_prop(name: String, path: String):
    var prop_button := Button.new()
    prop_button.text = name
    prop_button.tooltip_text = path
    prop_button.connect("pressed", func():
        var prop = ResourceLoader.load(path).instantiate()
        SpawnProp.emit(prop)
    )
    
    $Tabs/Props/Props.add_child(prop_button)

func _ready():
    hide()
