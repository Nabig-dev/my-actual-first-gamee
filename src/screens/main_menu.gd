extends Control

onready var ButtonListVerticalScroll: = $ButtonListVerticalScroll

var _playstore_loggedin: bool

func _ready() -> void :
	
	
	
	if Features.has("web"):
		ButtonListVerticalScroll.remove_by_id("exit")
	
	
	
	if (
		Features.has("switch")
		or Features.has("xbox")
		or Features.has("ps")
		
	):
		ButtonListVerticalScroll.remove_by_id("website")
		ButtonListVerticalScroll.remove_by_id("prequel")
		ButtonListVerticalScroll.remove_by_id("fullgame")
		ButtonListVerticalScroll.remove_by_id("exit")
	
	elif Features.has("nostore") == false:
		ButtonListVerticalScroll.remove_by_id("website")
	
	
	if Features.has("release") == true:
		ButtonListVerticalScroll.remove_by_id("dev_room")
	
	
	if Features.has("demo") == false:
		ButtonListVerticalScroll.remove_by_id("fullgame")
	
	
	if OS.get_name() != "Android" or Features.has("demo") == true:
		get_node("%HBxAndroidPlayGamesLogin").visible = false
	elif OS.get_name() == "Android":
		GooglePlayGamesServices.connect("sign_in_user_authenticated", self, "_on_playstore_signin")
		GooglePlayGamesServices.connect("players_current_loaded", self, "_on_current_player_loaded")
		GooglePlayGamesServices.sign_in_is_authenticated()

	Audio.play_music("main_menu_theme", "high", 2)

func _process(delta: float) -> void :
	
	if (
		Input.is_action_just_pressed("ui_accept")
		and $AnimationPlayer.is_playing() == false
	):
		_go_to_screen(ButtonListVerticalScroll.item_current_id)

	if (
		(Input.is_action_just_pressed("ui_accept")
		or Input.is_action_just_pressed("ui_start"))
		and $AnimationPlayer.is_playing() == true
	):
		$AnimationPlayer.seek(5, true)
		$AnimationPlayer.advance(delta)

func _go_to_screen(choice: String) -> void :
	
	Audio.play_sfx("ui_success")
	
	match choice:
		"start":
			if Features.has("drm"):
				SceneChanger.change_scene("res://src/screens/steam_check.tscn")
			else:
				
				VarsGlobal.selected_stage = "oota"
				SceneChanger.change_scene("res://src/screens/manage_savegame.tscn")
		"dev_room":
			VarsGlobal.selected_stage = "dev_room"
			SceneChanger.change_scene("res://src/screens/manage_savegame.tscn")
		"gallery":
			SceneChanger.change_scene("res://src/screens/gallery.tscn")
		"achievements":
			
			
			
			if _playstore_loggedin == true:
				GooglePlayGamesServices.achievements_show()
			else:
				SceneChanger.change_scene("res://src/screens/achievements.tscn")
		"options":
			SceneChanger.change_scene("res://src/screens/options.tscn")
		"credits":
			SceneChanger.change_scene("res://src/screens/credits.tscn")
		"prequel":
			var url: String
			if Features.has("pc"):
				url = "https://store.steampowered.com/app/1872040/Toziuha_Night_Draculas_Revenge/"
			elif OS.get_name() == "Android":
				url = "https://play.google.com/store/apps/details?id=com.danny_garay.toziuha_night_dr"
			elif OS.get_name() == "iOS":
				url = "https://apps.apple.com/us/app/toziuha-night/id1672673502"
			else:
				url = "https://dannygaray60.github.io"
			
			if Steam.is_init():
				Steam.friends.activate_game_overlay_to_store(1872040, Steam.OverlayToStoreFlag.AddToCartAndShow)
			else:
				
				OS.shell_open(url)
		"fullgame":
			var url: String
			if Features.has("pc"):
				url = "https://store.steampowered.com/app/2112750/Toziuha_Night_Order_of_the_Alchemists/"
			elif OS.get_name() == "Android":
				url = "https://play.google.com/store/apps/details?id=com.danny_garay.toziuha_night_oota"
			else:
				url = "https://dannygaray60.github.io/tn-oota.html"
			if Steam.is_init():
				Steam.friends.activate_game_overlay_to_store(2112750, Steam.OverlayToStoreFlag.AddToCartAndShow)
			else:
				
				OS.shell_open(url)
		"website":
			var url = "https://dannygaray60.github.io/tn-oota.html"
			if Steam.is_init():
				Steam.friends.activate_game_overlay_to_web_page(url)
			else:
				
				OS.shell_open(url)
		"exit":
			get_tree().quit()

func _on_playstore_signin(is_auth: bool) -> void :
	print("logged: " + str(is_auth))
	_playstore_loggedin = is_auth
	if is_auth == true:
		GooglePlayGamesServices.players_load_current(true)

func _on_current_player_loaded(player: Dictionary) -> void :
	get_node("%BtnLoginPlaygamesAndroid").text = player["displayName"]

func _on_BtnLoginPlaygamesAndroid_pressed() -> void :
	if _playstore_loggedin == false:
		Audio.play_sfx("ui_success")
		print("login playstore...")
		GooglePlayGamesServices.sign_in_show_popup()
	else:
		Audio.play_sfx("ui_success")
		
