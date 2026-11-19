extends Node
## Tes MSAA di renderer GL Compatibility (Rangga, 19 Nov 2026):
##   (Xvfb :98) godot --path . --resolution 1280x720 skrip/test_msaa.tscn
## Apakah Viewport.msaa_3d benar-benar menerima MSAA_4X, atau ditolak
## seperti scaling_3d (setter menolak BILINEAR, baca-balik 0)?
## MSAA hanya dipakai tingkat Tinggi BILA tes ini membuktikan setter
## menerimanya. Baca-balik yang bertahan BUKAN bukti driver benar-
## benar menerapkan di HP — itu perlu T1 Mas — tapi penolakan di sini
## sudah cukup untuk TIDAK memakainya.

func _ready() -> void:
	var vp := get_viewport()
	print("MSAA: awal msaa_3d=%d (0=mati)" % vp.msaa_3d)
	vp.msaa_3d = Viewport.MSAA_4X
	for i in 3:
		await get_tree().process_frame
	var balik := int(vp.msaa_3d)
	print("MSAA: sesudah set MSAA_4X, baca-balik msaa_3d=%d" % balik)
	var ps: int = int(ProjectSettings.get_setting("rendering/anti_aliasing/quality/msaa_3d", -1))
	print("MSAA: project setting msaa_3d=%d" % ps)
	# Coba juga via RenderingServer (jalur lain yang dipakai engine).
	RenderingServer.viewport_set_msaa_3d(vp.get_viewport_rid(), RenderingServer.VIEWPORT_MSAA_4X)
	for i in 2:
		await get_tree().process_frame
	print("MSAA: sesudah RenderingServer set 4X, baca-balik msaa_3d=%d" % int(vp.msaa_3d))
	var ok := balik == int(Viewport.MSAA_4X)
	print("MSAA: %s" % ("DITERIMA (baca-balik 4X)" if ok else "DITOLAK (baca-balik bukan 4X)"))
	get_tree().quit(0 if ok else 1)
