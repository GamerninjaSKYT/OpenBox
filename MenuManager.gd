class_name MenuManager
extends Node2D

@export var newgame_ui:TextureRect
@export var loadgame_ui:TextureRect
@export var seed_ui:SpinBox
@export var name_ui:LineEdit
@export var saves_path:String = "user://saves"
@export var mainworld:PackedScene
@export var worldui:PackedScene
@export var worlds_ui:VBoxContainer

func _ready():
	newgame_ui.visible = false
	loadgame_ui.visible = false
	seed_ui.value = randi_range(0,2147480000)

func OpenCloseNewGame():
	newgame_ui.visible = !newgame_ui.visible
	loadgame_ui.visible = false
func OpenCloseLoadGame():
	DirAccess.make_dir_recursive_absolute(saves_path)
	loadgame_ui.visible = !loadgame_ui.visible
	newgame_ui.visible = false
	if loadgame_ui.visible:
		for c in worlds_ui.get_children():
			c.queue_free()
			worlds_ui.custom_minimum_size.y = 0
		for s in DirAccess.get_directories_at(saves_path):
			var p = worldui.instantiate()
			worlds_ui.add_child(p)
			worlds_ui.custom_minimum_size.y += 135
			p.name_ui.text = str(s)
			p.world = str(s)
			p.man = self
func Exit():
	get_tree().quit()

func Play():
	if !name_ui.text.is_empty():
		if name_ui.text.is_valid_filename():
			if !DirAccess.dir_exists_absolute(saves_path + "/" + name_ui.text):
				Load(name_ui.text)
func Load(world):
	var file = FileAccess.open("user://load.data",FileAccess.WRITE)
	file.store_var(world)
	file.close()
	get_tree().change_scene_to_packed(mainworld)


func _on_open_folder_button_down():
	DirAccess.make_dir_recursive_absolute(saves_path)
	OS.shell_show_in_file_manager(ProjectSettings.globalize_path(saves_path),true)
