extends SceneTree
func _initialize() -> void:
	for p in ["res://rumput_linear.ktx2"]:
		var tex = load(p) as Texture2D
		var img: Image = tex.get_image()
		var out: String = "/home/hatch/workspace/pesantren-verse/v2/konsep/uji-kompres-tekstur/decode-rumput_linear_ktx2.png"
		print(p, " save err=", img.save_png(out), " format=", img.get_format())
	quit()
