extends Node
## Probe ulang (Cakra): semantik window_get_mode SETELAH jendela
## ter-map (tunggu 30 frame dulu — probe pertama membaca di _ready
## saat jendela mungkin belum ter-map, hasilnya 0 terus).

func _ready() -> void:
	for i in 30:
		await get_tree().process_frame
	print("PROBE2 MODE AWAL (setelah 30 frame): ", DisplayServer.window_get_mode())
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	print("PROBE2 MODE LANGSUNG SETELAH SET FULLSCREEN: ", DisplayServer.window_get_mode())
	for i in 5:
		await get_tree().process_frame
	print("PROBE2 MODE SETELAH 5 FRAME: ", DisplayServer.window_get_mode())
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	print("PROBE2 MODE LANGSUNG SETELAH SET WINDOWED: ", DisplayServer.window_get_mode())
	for i in 5:
		await get_tree().process_frame
	print("PROBE2 MODE SETELAH 5 FRAME (windowed): ", DisplayServer.window_get_mode())
	get_tree().quit(0)
