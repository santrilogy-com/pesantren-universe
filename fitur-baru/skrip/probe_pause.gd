extends Node
## Probe: apakah SceneTree.process_frame tetap terpancar saat tree
## di-pause? Dijalankan HEADLESS (tanpa render) — cukup untuk
## menguji perilaku sinyal. Timeout luar 30 dtk.

func _ready() -> void:
	print("PROBE START")
	await get_tree().process_frame
	await get_tree().process_frame
	print("PROBE 2-FRAME-OK")
	get_tree().paused = true
	print("PROBE PAUSED")
	for i in 5:
		await get_tree().process_frame
		print("PROBE FRAME-SAMBIL-PAUSE ", i)
	print("PROBE RESUMED-AFTER-PAUSE")
	get_tree().quit(0)
