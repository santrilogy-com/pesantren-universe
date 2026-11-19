extends SceneTree


func _initialize() -> void:
	for p in ["res://rumput_asli.jpg", "res://rumput_uastc.ktx2", "res://rumput_etc1s.ktx2", "res://tanah_asli.jpg", "res://tanah_uastc.ktx2"]:
		var tex = load(p) as Texture2D
		var img: Image = tex.get_image()
		var out: String = "/home/hatch/workspace/pesantren-verse/v2/konsep/uji-kompres-tekstur/decode-" + p.get_file().replace(".", "_") + ".png"
		var err: int = img.save_png(out)
		print(p, " -> ", out, " err=", err, " format=", img.get_format())
	quit()
