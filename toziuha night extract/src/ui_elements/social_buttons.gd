extends VBoxContainer

export var auto_focus: bool

onready var TimerURL = $TimerURL

func _ready() -> void :
	
	var Btns: Array = $HbxMain.get_children()
	Btns.append_array($HbxSocial.get_children())
	for b in Btns:
		b.connect(
			"pressed", self, "go_to", [b.name.replace("Btn", "")]
		)

	if auto_focus == true:
		$HbxMain / Btnsteam.grab_focus()

func go_to(opt: String) -> void :
	Audio.play_sfx("ui_accept")
	TimerURL.start()
	yield(TimerURL, "timeout")
	var uri: String
	match opt:
		"web":
			uri = "https://dannygaray60.github.io/"
		"steam":
			uri = "https://store.steampowered.com/app/2112750/Toziuha_Night_Order_of_the_Alchemists/"
		"itchio":
			uri = "https://dannygaray60.itch.io/toziuha-night-order-of-the-alchemists"
		"playstore":
			uri = "https://play.google.com/store/apps/details?id=com.danny_garay.toziuha_night_oota_free"
		"fb":
			uri = "https://www.facebook.com/toziuhanight"
		"tw":
			uri = "https://twitter.com/dannygaray60"
		"ds":
			uri = "https://discord.gg/jygdDzjdya"
		"yt":
			uri = "https://www.youtube.com/@dannygaray60"
		"kf":
			uri = "https://ko-fi.com/dannygaray60"

	
	OS.shell_open(uri)
