extends SceneTree


func _initialize() -> void:
	for p in ["res://rumput_uastc.ktx2", "res://rumput_etc1s.ktx2", "res://tanah_uastc.ktx2", "res://tanah_etc1s.ktx2", "res://rumput_asli.jpg"]:
		var tex = load(p)
		if tex == null:
			print(p, " -> GAGAL LOAD (null)")
			continue
		print(p, " -> OK class=", tex.get_class())
		var img: Image = (tex as Texture2D).get_image()
		if img == null:
			print("   get_image null")
		else:
			print("   format=", img.get_format(), " size=", img.get_size(), " data=", img.get_data().size(), " mipmaps=", img.has_mipmaps())
	quit()
