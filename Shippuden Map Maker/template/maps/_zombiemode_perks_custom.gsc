//================================================================================================
// Nombre del Archivo 	: _zombiemode_perks_custom.gsc
// Version				: 1
// Autor     			: Shippuden1592
// Foro					: CCM(http://customcodmapping.foroactivo.com/)
// YouTube				: https://www.youtube.com/user/shippuden1592
//================================================================================================
#include maps\_utility; 
#include common_scripts\utility; 
#include maps\_zombiemode_utility;
#include maps\_zombiemode_net;
#include maps\shippuden_utility;

#using_animtree( "generic_human" );

init()
{
	// Perks-a-cola vending machine use triggers
	vending_triggers = GetEntArray( "zombie_vending", "targetname" );

	flag_init( "solo_game" );

	if ( vending_triggers.size < 1 )
	{
		return;
	}

	//Enable Kino Mod
	level.custom_perks_mod = false;

	// Perks
	PrecacheItem( "zombie_perk_bottle" );

	set_zombie_var( "zombie_perk_limit",							12 ); // Limit Perks
	set_zombie_var( "zombie_perk_give_all",							true ); // All Perks
	set_zombie_var( "zombie_perk_hud_type",							"PERK_STYLE_HUD" ); // HUD Type: normal | cw
	set_zombie_var( "zombie_perk_juggernaut_health",	250 );
	set_zombie_var( "zombie_player_health",				150 );

	set_zombie_var( "use_doubletap",					PERK_ENABLE_DOUBLETAP );
	set_zombie_var( "use_jugg",					PERK_ENABLE_JUGG );
	set_zombie_var( "use_revive",					PERK_ENABLE_REVIVE );
	set_zombie_var( "use_speed",					PERK_ENABLE_SPEED );

	set_zombie_var( "use_tombstone",					PERK_ENABLE_TOMBSTONE );				// Use Tombstone
	set_zombie_var( "use_cherry",				PERK_ENABLE_CHERRY );				// Use Electric Cherry
	set_zombie_var( "use_vulture_aid",					PERK_ENABLE_VULTURE );				// Use Vulture Aid
	set_zombie_var( "use_widows_wine",					PERK_ENABLE_WIDOWS );				// Use Widows Wine
	
	// Electric Cherry
	set_zombie_var( "electric_cherry_laststand_radius",		500 );
	set_zombie_var( "electric_cherry_laststand_damage",		1000 );
	set_zombie_var( "electric_cherry_laststand_zombie_limit",		10 );
	set_zombie_var( "electric_cherry_points",		 	40 );

	// Vulture Aid
	set_zombie_var( "vulture_aid_point",		 	false );

	if( !IsDefined( level.wunderfizz_perks ) )
	{
		level.wunderfizz_perks = [];
	}

	if( !IsDefined( level.zombie_perks ) )
	{
		level.zombie_perks = [];
	}

	// Minimap icons
	PrecacheShader( "minimap_icon_juggernog" );
	PrecacheShader( "minimap_icon_revive" );
	PrecacheShader( "minimap_icon_reload" );

	// Default Perks
	level._effect["doubletap_light"]		= loadfx("misc/fx_zombie_cola_dtap_on");
	level._effect["jugger_light"]			= loadfx("misc/fx_zombie_cola_jugg_on");
	level._effect["revive_light"]			= loadfx("misc/fx_zombie_cola_revive_on");
	level._effect["sleight_light"]			= loadfx("misc/fx_zombie_cola_on");

	if( level.zombie_vars[ "use_doubletap" ] )
		add_perk( "specialty_rof", 2000, undefined, "zombie_vending_doubletap2", "zombie_vending_doubletap2_on", "vending_doubletap", "specialty_doubletap_zombies", "doubletap_light", "Double Tap II Root Beer", 0, "mus_perks_doubletap_sting" );
	
	if( level.zombie_vars[ "use_jugg" ] )
		add_perk( "specialty_armorvest", 2500, undefined, "zombie_vending_jugg", "zombie_vending_jugg_on", "vending_jugg", "specialty_juggernaut_zombies", "jugger_light", "Jugger-Nog", 1, "mus_perks_jugganog_sting" );
	
	if( level.zombie_vars[ "use_revive" ] )
		add_perk( "specialty_quickrevive", 1500, undefined, "zombie_vending_revive", "zombie_vending_revive_on", "vending_revive", "specialty_quickrevive_zombies", "revive_light", "Quick Revive", 2, "mus_perks_revive_sting" );
	
	if( level.zombie_vars[ "use_speed" ] )
		add_perk( "specialty_fastreload", 3000, undefined, "zombie_vending_sleight", "zombie_vending_sleight_on", "vending_sleight", "specialty_fastreload_zombies", "sleight_light", "Speed Cola", 3, "mus_perks_speed_sting" );

	if ( is_true( level.zombiemode_using_marathon_perk ) )
	{
		level._effect["marathon_light"]			= loadfx("maps/zombie/fx_zmb_cola_staminup_on");

		add_perk( "specialty_longersprint", 2000, true, "zombie_vending_marathon", "zombie_vending_marathon_on", "vending_marathon", "specialty_marathon_zombies", "doubletap_light", "Stamin-Up", 4, "mus_perks_stamin_sting", "mus_perks_stamin_jingle" );
	}
	
	if ( is_true( level.zombiemode_using_divetonuke_perk ) )
	{
		if( IsDefined( level.custom_perks_mod ) && level.custom_perks_mod )
		{
			level.zombiemode_divetonuke_perk_func = ::divetonuke_explode;
		}
		else
		{
			level.zombiemode_divetonuke_perk_func = maps\_zombiemode_perks::divetonuke_explode;
		}

		level._effect["divetonuke_groundhit"] = loadfx("maps/zombie/fx_zmb_phdflopper_exp");

		set_zombie_var( "zombie_perk_divetonuke_radius", 300 );
		set_zombie_var( "zombie_perk_divetonuke_min_damage", 1000 );
		set_zombie_var( "zombie_perk_divetonuke_max_damage", 5000 );

		add_perk( "specialty_flakjacket", 2000, true, "zombie_vending_nuke", "zombie_vending_nuke_on", "vending_divetonuke", "specialty_divetonuke_zombies", "doubletap_light", "PHD Flopper", 5, "mus_perks_phd_sting", "mus_pekrs_phd_jingle" );
	}
	
	if( is_true( level.zombiemode_using_deadshot_perk ) )
	{
		add_perk( "specialty_deadshot", 1500, true, "zombie_vending_ads", "zombie_vending_ads_on", "vending_deadshot", "specialty_ads_zombies", "doubletap_light", "Deadshot Daiquiri", 6, "mus_perks_deadshot_sting", "mus_perks_deadshot_jingle" );
	}
	
	if ( is_true( level.zombiemode_using_additionalprimaryweapon_perk ) )
	{
		PrecacheShader( "specialty_three_gun_zombies_glow" );

		level.additionalprimaryweapon_limit = 3;
		level._effect["additionalprimaryweapon_light"] = loadfx("misc/fx_zombie_cola_arsenal_on");

		add_perk( "specialty_additionalprimaryweapon", 4000, true, "zombie_vending_three_gun", "zombie_vending_three_gun_on", "vending_additionalprimaryweapon", "specialty_three_gun_zombies", "sleight_light", "Mule Kick", 7, "mus_perks_mulekick_sting", "mus_perks_mulekick_jingle" );
	}

	// Electric Cherry
	if( level.zombie_vars[ "use_cherry" ] )
	{
		level._effect[ "tesla_shock" ]			= loadfx( "electric_cherry/fx_electric_cherry_shock" );
		level._effect[ "tesla_shock_secondary" ]	= loadfx( "electric_cherry/fx_electric_cherry_shock_secondary" );

		level._effect[ "electric_cherry_explode" ] 			= loadfx( "electric_cherry/fx_electric_cherry_shock_death" );
		level._effect[ "electric_cherry_reload_small" ] 			= loadfx( "electric_cherry/fx_electric_cherry_shock_small" );
		level._effect[ "electric_cherry_reload_medium" ] 			= loadfx( "electric_cherry/fx_electric_cherry_shock_medium" );
		level._effect[ "electric_cherry_reload_large" ] 			= loadfx( "electric_cherry/fx_electric_cherry_shock_large" );

		add_perk( "specialty_bulletaccuracy", 2000, true, "p6_zm_vending_electric_cherry_off", "p6_zm_vending_electric_cherry_on", "vending_cherry", "specialty_cherry_zombies", "revive_light", "Electric Cherry", 8, "mus_perks_cherry_sting", "mus_perks_cherry_jingle" );
	}

	// Vulture Aid
	if( level.zombie_vars[ "use_vulture_aid" ] )
	{
		PrecacheShader( "specialty_vulture_zombies_glow" );
		PrecacheModel( "bo2_p6_zm_perk_vulture_points" );
		PrecacheModel( "bo2_p6_zm_perk_vulture_ammo" );

		// FX Vulture
		level._effect[ "vulture_box_shader" ]			= loadfx( "vulture/fx_vulture_box" );
		level._effect[ "vulture_pap_shader" ]			= loadfx( "vulture/fx_vulture_pap" );
		level._effect[ "vulture_rifle_shader" ]			= loadfx( "vulture/fx_vulture_rifle" );
		level._effect[ "vulture_wunderfizz_shader" ]	= loadfx( "vulture/fx_vulture_wunderfizz" );
		level._effect[ "vulture_glow" ] 				= loadfx( "vulture/fx_vulture_powerup" );
		level._effect[ "vulture_mist" ]			 		= loadfx( "vulture/fx_vulture_mist" );
		level._effect[ "vulture_mist_disperse" ]			 		= loadfx( "vulture/fx_vulture_mist_disperse" );

		// FX Vulture vending shaders
		level._effect[ "vulture_revive_shader" ]	= loadfx( "vulture/fx_vulture_revive" );
		level._effect[ "vulture_speed_shader" ]		= loadfx( "vulture/fx_vulture_speed" );
		level._effect[ "vulture_jugg_shader" ]	 	= loadfx( "vulture/fx_vulture_jugg" );
		level._effect[ "vulture_dt_shader" ]		= loadfx( "vulture/fx_vulture_double" );	
		level._effect[ "vulture_deadshot_shader" ] 	= loadfx( "vulture/fx_vulture_deadshot" );
		level._effect[ "vulture_stamin_shader" ]	= loadfx( "vulture/fx_vulture_stamin" );
		level._effect[ "vulture_mule_shader" ]		= loadfx( "vulture/fx_vulture_mule" );
		level._effect[ "vulture_phd_shader" ] 		= loadfx( "vulture/fx_vulture_phd" );
		level._effect[ "vulture_tombstone_shader" ]	 	= loadfx( "vulture/fx_vulture_tombstone" );
		level._effect[ "vulture_cherry_shader" ] 	= loadfx( "vulture/fx_vulture_cherry" );
		level._effect[ "vulture_vulture_shader" ]	= loadfx( "vulture/fx_vulture_vulture" );
		level._effect[ "vulture_widow_shader" ]		= loadfx( "vulture/fx_vulture_widow" );

		level.vulture_huds = [];
		level.vulture_huds[ "specialty_quickrevive" ] 				= "vulture_revive_shader";
		level.vulture_huds[ "specialty_fastreload" ] 				= "vulture_speed_shader";
		level.vulture_huds[ "specialty_armorvest" ] 				= "vulture_jugg_shader";
		level.vulture_huds[ "specialty_rof" ] 						= "vulture_dt_shader";
		level.vulture_huds[ "specialty_deadshot" ] 					= "vulture_deadshot_shader";
		level.vulture_huds[ "specialty_longersprint" ]				= "vulture_stamin_shader";
		level.vulture_huds[ "specialty_additionalprimaryweapon" ]	= "vulture_mule_shader";
		level.vulture_huds[ "specialty_flakjacket" ] 				= "vulture_phd_shader";
		level.vulture_huds[ "specialty_bulletaccuracy" ]			= "vulture_cherry_shader";
		level.vulture_huds[ "specialty_bulletdamage" ] 				= "vulture_vulture_shader";
		level.vulture_huds[ "specialty_extraammo" ] 				= "vulture_widow_shader";
		level.vulture_huds[ "specialty_altmelee" ] 					= "vulture_tombstone_shader";
		level.vulture_huds[ "vulture_pap_shader" ] 					= "vulture_pap_shader";
		level.vulture_huds[ "vulture_rifle_shader" ] 				= "vulture_rifle_shader";
		level.vulture_huds[ "vulture_wunderfizz_shader" ] 			= "vulture_wunderfizz_shader";
		level.vulture_huds[ "vulture_box_shader" ] 					= "vulture_box_shader";

		set_zombie_var( "vulture_drop_chance", 				20 );
		set_zombie_var( "vulture_ammo_chance", 				33 );
		set_zombie_var( "vulture_points_chance", 			33 );
		set_zombie_var( "vulture_stink_chance",				33 );
		set_zombie_var( "vulture_drops_max", 				10 );
		set_zombie_var( "vulture_stink_max",				4 );
		set_zombie_var( "vulture_mist_time",				10 );

		add_perk( "specialty_bulletdamage", 3000, true, "bo2_zombie_vending_vultureaid", "bo2_zombie_vending_vultureaid_on", "vending_vultureaid", "specialty_vulture_zombies", "jugger_light", "Vulture Aid", 9, "mus_perks_vulture_sting", "mus_perks_vulture_jingle" );
	}

	// Widows Wine
	if( level.zombie_vars[ "use_widows_wine" ] )
	{
		PrecacheModel("bo3_t7_ww_grenade_proj");
		PrecacheModel("bo3_t7_ww_powerup");		
		PrecacheItem("zombie_widows_grenade");

		register_lethal_grenade_for_level( "zombie_widows_grenade" );

		level._effect[ "widows_wine_explode" ]	= loadfx ( "widowswine/fx_widows_wine_explode" );
		level._effect[ "widows_wine_zombie" ]	= loadfx ( "widowswine/fx_widows_wine_zombie" );

		set_zombie_var( "widows_wine_drop_chance", 				30 );		// Chance of a zombie dropping anything at all
		set_zombie_var( "widows_wine_max_range",				175 );		// Widows wine explode max range
		set_zombie_var( "widows_wine_damage",					5 );		// Widows wine exlosion damage in percentage of total health
		set_zombie_var( "widows_wine_melee_damage",				1.5 );		// Widows wine extra melee damage in percentage of total health
		set_zombie_var( "widows_wine_melee_stun_chance",		40 );		// Widows wine melee stun chance 
		set_zombie_var( "widows_wine_grenade",					"zombie_widows_grenade" );
		set_zombie_var( "widows_wine_grenade_backup",			"frag_grenade_zm" );

		add_perk( "specialty_extraammo", 4000, true, "bo3_p7_zm_vending_widows_wine_off", "bo3_p7_zm_vending_widows_wine_on", "vending_widowswine", "specialty_widowswine_zombies", "doubletap_light", "Widow's Wine", 10, "mus_perks_widowswine_sting", "mus_perks_widowswine_jingle" );
	}

	// Tombstone Soda
	if( level.zombie_vars[ "use_tombstone" ] )
	{
		PrecacheModel( "bo2_ch_tombstone1" );

		add_perk( "specialty_altmelee", 2000, true, "bo2_zombie_vending_tombstone", "bo2_zombie_vending_tombstone_on", "vending_tombstone", "specialty_tombstone_zombies", "doubletap_light", "Tombstone Soda", 11, "mus_perks_tombstone_sting", "mus_perks_tombstone_jingle" );
	}

	vending_triggers = GetEntArray( "zombie_vending", "targetname" ); //Fix Perks Spawns

	array_thread( vending_triggers, ::vending_trigger_think );
	array_thread( vending_triggers, maps\_zombiemode_perks::electric_perks_dialog );
	array_thread( GetEntArray( "audio_bump_trigger", "targetname"), ::thread_bump_trigger);
	level thread setup_player_abilities();

	//Zombies Reacts
	maps\_zombiemode_spawner::register_zombie_damage_callback( ::perks_zombie_hit_effect );
}

add_perk( perk_name, perk_cost, perk_point_spawn, perk_model, perk_model_on, perk_model_targetname, perk_shader, perk_light, perk_hint, perk_bottle, perk_sting, perk_jingle )
{
	if ( isDefined ( level.zombie_perks[ perk_name ] ) )
		return;

	// Spawn Perk
	origin = undefined;
	angles = undefined;

	if( IsDefined( perk_point_spawn ) )
	{
		switch( get_mapname() )
		{
			case "zombie_theater":
				switch( perk_name )
				{
					case "specialty_longersprint":
						origin = (-823.6, -1036.0, 80.1);
						angles = (0, -90, 0);
					break;

					case "specialty_flakjacket":
						origin = (632.5, 1239.6, -15.9);
						angles = (0, -180, 0);
					break;

					case "specialty_deadshot":
						origin = (-1109.36, 1273.81, -15.875);
						angles = (0, 90, 0);
					break;

					case "specialty_additionalprimaryweapon":
						origin = (1172.4, -359.7, 320);
						angles = (0, 90, 0);
					break;

					case "specialty_bulletaccuracy":
						origin = (-1191.0, 1200.4, 168.1);
						angles = (0, 360, 0);
					break;

					case "specialty_bulletdamage":
						origin = (-1343.7, 950.5, 13.4);
						angles = (0, -90, 0);
					break;

					case "specialty_extraammo":
						origin = (582.1, -1002.8, 322.9);
						angles = (0, 90, 0);
					break;

					case "specialty_altmelee":
						origin = (839.4, 1032.4, -15.9);
						angles = (0, 90, 0);
					break;
				}
			break;
		}
	}

	PrecacheModel( perk_model );
	PrecacheModel( perk_model_on );
	PrecacheShader( perk_shader );

	struct = SpawnStruct();
	struct.perk_name = perk_name;
	struct.perk_model = perk_model;
	struct.perk_model_on = perk_model_on;
	struct.perk_model_targetname = perk_model_targetname;
	struct.perk_shader = perk_shader;
	struct.perk_light = perk_light;
	struct.perk_bottle = perk_bottle;
	struct.perk_sting = perk_sting;

	if( IsDefined( perk_jingle ) )
		struct.perk_jingle = perk_jingle;

	struct.perk_hint = "Hold ^3[{+activate}]^7 to buy " + perk_hint + " [Cost: ^3" + perk_cost + "^7]";
	struct.perk_cost = perk_cost;

	level.wunderfizz_perks[ level.wunderfizz_perks.size ] = perk_name;
	level.zombie_perks[ perk_name ] = struct;

	if( IsDefined( origin ) )
	{
		generate_perk_spawn_struct( perk_name, origin, angles );
	}
}

generate_perk_spawn_struct( perk_name, machine_origin, machine_angles )
{
	machine = Spawn( "script_model", machine_origin );
	machine.angles = machine_angles;
	machine setModel( level.zombie_perks[ perk_name ].perk_model );
	machine.targetname = level.zombie_perks[ perk_name ].perk_model_targetname;

	machine_trigger = Spawn( "trigger_radius_use", machine_origin + (0, 0, 30), 0, 20, 70 );
	machine_trigger.targetname = "zombie_vending";
	machine_trigger.target = level.zombie_perks[ perk_name ].perk_model_targetname;
	machine_trigger.script_noteworthy = perk_name;
	machine_trigger.script_sound = level.zombie_perks[ perk_name ].perk_jingle;
	machine_trigger.script_label = level.zombie_perks[ perk_name ].perk_sting;

	machine_clip = spawn( "script_model", machine_origin );
	machine_clip.angles = machine_angles;
	machine_clip setmodel( "collision_geo_64x64x256" );
	machine_clip Hide();

	bump_trigger = Spawn( "trigger_radius", machine_origin, 0, 35, 64 );
	bump_trigger.targetname = "audio_bump_trigger";
	bump_trigger.script_sound = "fly_bump_bottle";
	bump_trigger.script_string = "tap_perk";
}

activate_machine( perk, solo_game )
{
	machine = getentarray( level.zombie_perks[ perk ].perk_model_targetname, "targetname" );

	if( perk == "specialty_quickrevive" && solo_game )
	{
		if( IsDefined( level.custom_perks_mod ) && level.custom_perks_mod )
		{
			machine = getentarray("vending_revive", "targetname");
			machine_model = undefined;
			machine_clip = undefined;

			for( i = 0; i < machine.size; i++ )
			{
				if(IsDefined(machine[i].script_noteworthy) && machine[i].script_noteworthy == "clip")
				{
					machine_clip = machine[i];
				}
				else // then the model
				{	
					machine[i] setmodel("zombie_vending_revive_on");
					machine_model = machine[i];
				}
			}
			wait_network_frame();
			if ( isdefined( machine_model ) )
			{
				machine_model thread maps\_zombiemode_perks::revive_solo_fx(machine_clip);
			}
		}
		else
		{
			for( i = 0; i < machine.size; i++ )
			{
				machine_clip = GetEnt( machine[i].target, "targetname" );
				machine[i] SetModel( level.zombie_perks[ perk ].perk_model_on );
				machine[i] thread maps\_zombiemode_perks::revive_solo_fx( machine_clip );
			}
		}
	}

	if( !solo_game )
	{
		level waittill("juggernog_on");

		for( i = 0; i < machine.size; i++ )
		{
			machine[i] SetModel( level.zombie_perks[ perk ].perk_model_on );
			machine[i] Vibrate( (0,-100,0), 0.3, 0.4, 3);
			machine[i] PlaySound( "zmb_perks_power_on" );
			machine[i] thread maps\_zombiemode_perks::perk_fx( level.zombie_perks[ perk ].perk_light );
		}
		
		level notify( perk + "_power_on" );
	}
}

vending_trigger_think()
{
	perk = self.script_noteworthy;
	solo = false;
	flag_init( "_start_zm_pistol_rank" );

	//Check Solo
	if( IsDefined( perk ) && perk == "specialty_quickrevive" )
	{
		flag_wait( "all_players_connected" );
		players = GetPlayers();
		if ( players.size == 1 )
		{
			solo = true;
			flag_set( "solo_game" );
			level.solo_lives_given = 0;
			players[0].lives = 0;
			level maps\_zombiemode::zombiemode_solo_last_stand_pistol();

			level.zombie_perks[ perk ].perk_cost = 500;
			level.zombie_perks[ perk ].perk_hint = "Hold ^3[{+activate}]^7 to buy Quick Revive [Cost: ^3500^7]";
		}
	}

	//Turn ON
	if( IsDefined( level.zombie_perks[ perk ] ) )
	{
		level thread activate_machine( perk, solo );
	}

	flag_set( "_start_zm_pistol_rank" );

	if ( !solo )
		self SetHintString( &"ZOMBIE_NEED_POWER" );

	self SetCursorHint( "HINT_NOICON" );
	self UseTriggerRequireLookAt();

	if ( !solo )
	{
		notify_name = perk + "_power_on";
		level waittill( notify_name );
	}

	if( !IsDefined( level._perkmachinenetworkchoke ) )
		level._perkmachinenetworkchoke = 0;
	else
		level._perkmachinenetworkchoke ++;
	
	for(i = 0; i < level._perkmachinenetworkchoke; i++)
	{
		wait_network_frame();
	}

	if( IsDefined( self.script_sound ) )
	{
		self thread maps\_zombiemode_audio::perks_a_cola_jingle_timer();
	}

	perk_hum = spawn("script_origin", self.origin);
	perk_hum playloopsound("zmb_perks_machine_loop");

	self thread maps\_zombiemode_perks::check_player_has_perk( perk );
	
	self SetHintString( level.zombie_perks[ perk ].perk_hint );

	for( ;; )
	{
		self waittill( "trigger", player );
		
		if (player maps\_laststand::player_is_in_laststand() || is_true( player.intermission ) )
		{
			continue;
		}

		if(player in_revive_trigger())
		{
			continue;
		}
		
		if( player isThrowingGrenade() )
		{
			wait( 0.1 );
			continue;
		}
		
 		if( player isSwitchingWeapons() )
 		{
 			wait(0.1);
 			continue;
 		}

		if( player is_drinking() )
		{
			wait( 0.1 );
			continue;
		}

		if ( player HasPerk( perk ) )
		{
			self playsound("deny");
			player maps\_zombiemode_audio::create_and_play_dialog( "general", "perk_deny", undefined, 1 );
			continue;
		}

		if ( player.score < level.zombie_perks[ perk ].perk_cost )
		{
			self playsound("evt_perk_deny");
			player maps\_zombiemode_audio::create_and_play_dialog( "general", "perk_deny", undefined, 0 );
			continue;
		}

		if ( player.num_perks >= level.zombie_vars["zombie_perk_limit"] )
		{
			self playsound("evt_perk_deny");
			player maps\_zombiemode_audio::create_and_play_dialog( "general", "sigh" );
			continue;
		}

		sound = "evt_bottle_dispense";
		playsoundatposition(sound, self.origin);
		player maps\_zombiemode_score::minus_to_player_score( level.zombie_perks[ perk ].perk_cost );
		player.perk_purchased = perk;

		self thread maps\_zombiemode_audio::play_jingle_or_stinger( level.zombie_perks[ perk ].perk_sting );
		gun = player perk_give_bottle_begin( perk );
		player waittill_any( "fake_death", "death", "player_downed", "weapon_change_complete" );
		player perk_give_bottle_end( gun, perk );

		if ( player maps\_laststand::player_is_in_laststand() || is_true( player.intermission ) )
		{
			continue;
		}

		if ( isDefined( level.perk_bought_func ) )
		{
			player [[ level.perk_bought_func ]]( perk );
		}

		player.perk_purchased = undefined;
		player give_perk( perk, true );
		player notify( perk + "_drank");
	}
}

perk_give_bottle_begin( perk )
{
	self increment_is_drinking();
	
	self AllowLean( false );
	self AllowAds( false );
	self AllowSprint( false );
	self AllowCrouch( true );
	self AllowProne( false );
	self AllowMelee( false );

	wait( 0.05 );

	if ( self GetStance() == "prone" )
	{
		self SetStance( "crouch" );
	}

	gun = self GetCurrentWeapon();
	self GiveWeapon( "zombie_perk_bottle", level.zombie_perks[ perk ].perk_bottle );
	self SwitchToWeapon( "zombie_perk_bottle" );

	return gun;
}

perk_give_bottle_end( gun, perk )
{
	assert( gun != "zombie_perk_bottle" );
	assert( gun != "syrette_sp" );

	self AllowLean( true );
	self AllowAds( true );
	self AllowSprint( true );
	self AllowProne( true );		
	self AllowMelee( true );

	weapon = "zombie_perk_bottle";

	if ( self maps\_laststand::player_is_in_laststand() || is_true( self.intermission ) )
	{
		self TakeWeapon(weapon);
		return;
	}

	self TakeWeapon(weapon);

	if( self is_multiple_drinking() )
	{
		self decrement_is_drinking();
		return;
	}
	else if( gun != "none" && !is_placeable_mine( gun ) && !is_equipment( gun ) )
	{
		self SwitchToWeapon( gun );
		if( is_melee_weapon( gun ) )
		{
			self decrement_is_drinking();
			return;
		}
	}
	else 
	{
		primaryWeapons = self GetWeaponsListPrimaries();
		if( IsDefined( primaryWeapons ) && primaryWeapons.size > 0 )
		{
			self SwitchToWeapon( primaryWeapons[0] );
		}
	}

	self waittill( "weapon_change_complete" );

	if ( !self maps\_laststand::player_is_in_laststand() && !is_true( self.intermission ) )
	{
		self decrement_is_drinking();
	}
}

give_perk( perk, bought )
{

	self SetPerk( perk );
	self.num_perks++;

	if ( is_true( bought ) )
	{
		self thread maps\_zombiemode_audio::perk_vox( perk );
		self setblur( 4, 0.1 );
		wait(0.1);
		self setblur(0, 0.1);

		self notify( "perk_bought", perk );
	}

	switch( perk )
	{
		case "specialty_armorvest":
			self.preMaxHealth = self.maxhealth;
			self SetMaxHealth( level.zombie_vars["zombie_perk_juggernaut_health"] );
		break;

		case "specialty_deadshot":
			self SetClientFlag(level._ZOMBIE_PLAYER_FLAG_DEADSHOT_PERK);
		break;

		case "specialty_quickrevive":
			players = getplayers();
			if( players.size == 1 )
			{
				self.lives = 1;
		
				level.solo_lives_given++;
				
				if( level.solo_lives_given >= 3 )
				{
					flag_set( "solo_revive" );
				}
				
				self thread maps\_zombiemode_perks::solo_revive_buy_trigger_move( perk );
			}
		break;

		case "specialty_bulletaccuracy":			// !!=====!! Electric Cherry
			self thread electric_cherry_function();
			self thread electric_cherry_laststand();
		break;

		case "specialty_bulletdamage":					// !!=====!! Vulture Aid
			self.vultureFullInMist = false;
			self.vultureMistLevel = 0;
			self.vultureDropCount = 0;
			
			self thread vulture_mist_watcher();
			level thread vulture_waypoint_subscribe();
		break;

		case "specialty_extraammo":					// !!=====!! Widows Wine
			self thread widows_wine_explode_on_melee_watcher();

			if( level.zombie_vars["widows_wine_grenade"] != self get_player_lethal_grenade() )
			{
				self TakeWeapon( level.zombie_vars["widows_wine_grenade_backup"] );
				self GiveWeapon( level.zombie_vars["widows_wine_grenade"] );
				self set_player_lethal_grenade( level.zombie_vars["widows_wine_grenade"] );
			}
		break;

		case "specialty_altmelee":
			self thread tombstone_laststand();
		break;

		default:
			//iprintlnbold("Problem with perkname: " + perk);
		break;
	}

	if (!self player_check_bought_perk(perk))
	{
		self.bought_perks[self.bought_perks.size] = perk;
	}

	self perk_hud_create( perk );
	self.stats["perks"]++;
	self thread perk_think( perk );
}

player_check_bought_perk(perk)
{
	if (self.bought_perks.size == 0)
	{
		return false;
	}

	for(i = 0; i < self.bought_perks.size; i++)
	{
		if (self.bought_perks[i] == perk)
		{
			return true;
		}
	}
	
	return false;
}

perk_hud_create( perk )
{
	if ( !IsDefined( self.perk_hud ) )
	{
		self.perk_hud = [];
	}

	hud = create_simple_hud( self );
    hud.foreground = true; 
    hud.sort = 1; 
    hud.hidewheninmenu = false; 

    if( level.zombie_vars["zombie_perk_hud_type"] == "cw" )
    {
    	hud.alignX = "center"; 
	    hud.alignY = "bottom";
	    hud.horzAlign = "center"; 
	    hud.vertAlign = "bottom";
	    hud.x = 0;
	    hud.y = hud.y - 20;
    }
    else
    {
    	hud.alignX = "left"; 
		hud.alignY = "bottom";
		hud.horzAlign = "user_left"; 
		hud.vertAlign = "user_bottom";
		hud.x = self.perk_hud.size * 30; 
		hud.y = hud.y - 70; 
    }

    hud.alpha = 0;
    hud fadeOverTime(0.6);
    hud.alpha = 1;
    hud SetShader( level.zombie_perks[ perk ].perk_shader, 24, 24 );
    hud scaleOverTime( 0.6, 24, 24 );

    self.perk_hud[ perk ] = hud;

    if( level.zombie_vars["zombie_perk_hud_type"] == "cw" )
    {
    	x_start = -1 * ((self.perk_hud.size * 30) / 2);

	    keys = GetArrayKeys( self.perk_hud );

	    for( i = 0; i < keys.size; i++ )
	    {
	        self.perk_hud[keys[i]].x = x_start;
	        x_start += 30;
	    }
    }
}

perk_think( perk )
{
	perk_str = perk + "_stop";
	result = self waittill_any_return( "fake_death", "death", "player_downed", perk_str );

	do_retain = true;
	
	if( (get_players().size == 1) && perk == "specialty_quickrevive")
	{
		do_retain = false;
	}

	if(do_retain && IsDefined(self._retain_perks) && self._retain_perks)
	{
		return;
	}

	self UnsetPerk( perk );
	self.num_perks--;
	
	switch(perk)
	{
		case "specialty_armorvest":
			self SetMaxHealth( level.zombie_vars["zombie_player_health"] );
			break;
		
		case "specialty_additionalprimaryweapon":
			if ( result == perk_str )
			{
				if( IsDefined( level.custom_perks_mod ) && level.custom_perks_mod )
				{
					self take_additionalprimaryweapon();
				}
				else
				{
					self maps\_zombiemode::take_additionalprimaryweapon();
				}
			}
			break;
		
		case "specialty_deadshot":
			self ClearClientFlag(level._ZOMBIE_PLAYER_FLAG_DEADSHOT_PERK);
			break;

		case "specialty_bulletaccuracy":					// !!=====!! Electric Cherry
			self notify("stop_electric_cherry_reload_attack");
			break;

		case "specialty_bulletdamage":					// !!=====!! Vulture Aid
			self notify("unsubscribe_vulture_aid");
			level thread vulture_waypoint_unsubscribe( self );
			
			if ( !self maps\_laststand::player_is_in_laststand() && self.vultureFullInMist )
			{
				self.ignoreme = false;
			}

			self.vultureFullInMist = false;
		break;

		case "specialty_extraammo":					// !!=====!! Widows Wine
			self notify( "unsubscribe_widows_wine" );

			if( level.zombie_vars["widows_wine_grenade"] == self get_player_lethal_grenade() )
			{
				self TakeWeapon( level.zombie_vars["widows_wine_grenade"] );
				self GiveWeapon( level.zombie_vars["widows_wine_grenade_backup"] );
				self set_player_lethal_grenade( level.zombie_vars["widows_wine_grenade_backup"] );
			}
		break;

		case "specialty_altmelee":
			self notify("player_tombstone_laststand");
		break;
	}
	
	self maps\_zombiemode_perks::perk_hud_destroy( perk );
	self.perk_purchased = undefined;

	if ( IsDefined( level.perk_lost_func ) )
	{
		self [[ level.perk_lost_func ]]( perk );
	}

	self notify( "perk_lost" );
}

// !/=====\!
// !|=====|! Mule Kick
// !\=====/!

player_switch_weapon_watcher()
{
	self endon( "disconnect" );

	while( 1 )
	{
		self waittill( "weapon_change_complete" );		
		
		if (self hasPerk("specialty_additionalprimaryweapon"))
		{
			if (isDefined(self.perk_hud["specialty_additionalprimaryweapon"]))
			{
				current_weapon = self getCurrentWeapon();
				primaries = self GetWeaponsListPrimaries();

				if ( primaries.size == 3 && current_weapon == primaries[2] )
				{
					self.perk_hud["specialty_additionalprimaryweapon"] setShader("specialty_three_gun_zombies_glow", 24, 24);
				}
				else
				{
					self.perk_hud["specialty_additionalprimaryweapon"] setShader("specialty_three_gun_zombies", 24, 24);
				}
			}
		}
	}
}

//Only for Kino Mod
take_additionalprimaryweapon()
{
	weapon_to_take = undefined;

	if ( is_true( self._retain_perks ) )
	{
		return weapon_to_take;
	}

	primary_weapons_that_can_be_taken = [];

	primaryWeapons = self GetWeaponsListPrimaries();
	for ( i = 0; i < primaryWeapons.size; i++ )
	{
		if ( maps\_zombiemode_weapons::is_weapon_included( primaryWeapons[i] ) || maps\_zombiemode_weapons::is_weapon_upgraded( primaryWeapons[i] ) )
		{
			primary_weapons_that_can_be_taken[primary_weapons_that_can_be_taken.size] = primaryWeapons[i];
		}
	}

	if ( primary_weapons_that_can_be_taken.size >= 3 )
	{
		weapon_to_take = primary_weapons_that_can_be_taken[primary_weapons_that_can_be_taken.size - 1];
		if ( weapon_to_take == self GetCurrentWeapon() )
		{
			self SwitchToWeapon( primary_weapons_that_can_be_taken[0] );
		}
		self TakeWeapon( weapon_to_take );
	}

	return weapon_to_take;
}

// !/=====\!
// !|=====|! PHD Flopper & Widows Wine
// !\=====/!

php_widows_grenade( grenade, weaponName, perk )
{
	if( self maps\_laststand::player_is_in_laststand() )
	{
		grenade Delete();
	}

	if( IsDefined( grenade ) )
	{
		grenade Hide();

		model = Spawn( "script_model", grenade.origin );
		modelname = GetWeaponModel( weaponName );
		model SetModel( modelname );
		model.angles = grenade.angles;
		model.thrower = self;
		model LinkTo( grenade );

		velocitySq = 10000 * 10000;
		oldPos = grenade.origin;

		while( velocitySq != 0 )
		{
			wait 0.05;

			if( !isDefined( grenade ) )
			{
				break;
			}

			velocitySq = DistanceSquared( grenade.origin, oldPos );
			oldPos = grenade.origin;
		}

		grenade resetmissiledetonationtime();

		model UnLink();
		model.origin = grenade.origin;
		model.angles = grenade.angles;
		grenade Delete();

		if( perk == "specialty_flakjacket" )
		{
			self.cluster1 = self magicGrenadeType( weaponName, model.origin, ( 0, 75, 300 ), 3 );
			self.cluster2 = self magicGrenadeType( weaponName, model.origin, ( 0, -75, 300 ), 3 );
			self.cluster3 = self magicGrenadeType( weaponName, model.origin, ( 75, 0, 300 ), 3 );
			self.cluster4 = self magicGrenadeType( weaponName, model.origin, ( -75, 0, 300 ), 3 );
		}
		else if( perk == "specialty_extraammo" )
		{
			model thread widows_wine_explode( self );
			model hide();
			wait 1.5;
		}

		model Delete();
	}
}

//Only for Kino Mod
divetonuke_explode( attacker, origin )
{
	RadiusDamage(origin, level.zombie_vars["zombie_perk_divetonuke_radius"], level.zombie_vars["zombie_perk_divetonuke_max_damage"], level.zombie_vars["zombie_perk_divetonuke_min_damage"], attacker, "MOD_GRENADE_SPLASH");
	PlayFX(level._effect["divetonuke_groundhit"], origin);
	attacker PlaySound("wpn_grenade_explode");
}

// !/=====\!
// !|=====|! Electric Cherry
// !\=====/!

electric_cherry_laststand()
{
	self waittill( "stop_electric_cherry_reload_attack" );

	self thread electric_cherry_do_damage(1, level.zombie_vars[ "electric_cherry_laststand_radius" ], level.zombie_vars[ "electric_cherry_laststand_damage" ], level.zombie_vars[ "electric_cherry_laststand_zombie_limit" ], true, false);
}

electric_cherry_function()
{
	self endon( "disconnect" );
	self endon( "stop_electric_cherry_reload_attack" );

	self.wait_on_reload = [];
	self.consecutive_electric_cherry_attacks = 0;

	while( 1 )
	{
		self waittill("reload_start");
		str_current_weapon = self GetCurrentWeapon();

		if( is_in_array(self.wait_on_reload, str_current_weapon) )
		{
			continue;
		}

		self.wait_on_reload[ self.wait_on_reload.size ] = str_current_weapon;
		self.consecutive_electric_cherry_attacks++;
		n_clip_current = self GetWeaponAmmoClip(str_current_weapon);
		n_clip_max = WeaponClipSize(str_current_weapon);
		n_fraction = n_clip_current / n_clip_max;
		perk_radius = linear_map(n_fraction, 1, 0, 32, 128);
		perk_dmg = linear_map(n_fraction, 1, 0, 1, 1045);
		self thread check_for_reload_complete(str_current_weapon);

		switch(self.consecutive_electric_cherry_attacks)
		{
			case 0:
			case 1:
				n_zombie_limit = undefined;
				break;
			case 2:
				n_zombie_limit = 8;
				break;
			case 3:
				n_zombie_limit = 4;
				break;
			case 4:
				n_zombie_limit = 2;
				break;
			default:
				n_zombie_limit = 0;
				break;
		}

		self thread electric_cherry_cooldown_timer(str_current_weapon);
		self thread electric_cherry_do_damage(n_fraction, perk_radius, perk_dmg, n_zombie_limit, undefined, false);
	}
}

electric_cherry_cooldown_timer( str_current_weapon )
{
	self notify("electric_cherry_cooldown_started");
	self endon("electric_cherry_cooldown_started");
	self endon("disconnect");

	n_reload_time = WeaponReloadTime( str_current_weapon );

	if( self HasPerk("specialty_fastreload") )
	{
		n_reload_time *= GetDvarFloat("perk_weapReloadMultiplier");
	}

	wait n_reload_time + 3;
	self.consecutive_electric_cherry_attacks = 0;
}

check_for_reload_complete( weapon )
{
	self endon("disconnect");
	self endon("player_lost_weapon_" + weapon);

	self thread weapon_replaced_monitor(weapon);

	while( 1 )
	{
		self waittill("reload");

		str_current_weapon = self GetCurrentWeapon();

		if(str_current_weapon == weapon)
		{
			self.wait_on_reload = array_remove_nokeys(self.wait_on_reload, weapon);
			self notify("weapon_reload_complete_" + weapon);
			break;
		}
	}
}

weapon_replaced_monitor(weapon)
{
	self endon("disconnect");
	self endon("weapon_reload_complete_" + weapon);

	while( 1 )
	{
		self waittill("weapon_change");

		primaryweapons = self GetWeaponsListPrimaries();

		if(!is_in_array(primaryweapons, weapon))
		{
			self notify("player_lost_weapon_" + weapon);
			self.wait_on_reload = array_remove_nokeys(self.wait_on_reload, weapon);
			break;
		}
	}
}

electric_cherry_do_damage( fraction, radius, damage, zombie_limit, laststand_effect, no_player )
{
	if( IsDefined( zombie_limit ) && zombie_limit <= 0 )
		return;

	if( !is_true( no_player ) )
	{
		self thread electric_cherry_reload_fx(fraction, laststand_effect);
		self PlaySound("cherry_explode");
	}

	a_zombies = get_array_of_closest(self.origin, get_round_enemy_array(), undefined, undefined, radius);
	zombies_hit = 0;

	for(i = 0; i < a_zombies.size; i++)
	{
		if( IsDefined( a_zombies[i] ) && IsAlive( a_zombies[i] ) && !is_magic_bullet_shield_enabled( a_zombies[i] ) )
		{
			if(zombies_hit < zombie_limit)
				zombies_hit++;
			else
				break;

			if( a_zombies[i].health <= damage )
			{
				a_zombies[i] thread electric_cherry_shock_or_death_fx( "tesla_death_fx", "tesla_shock_secondary" );
				self maps\_zombiemode_score::add_to_player_score( add_points( level.zombie_vars[ "electric_cherry_points" ] ) );
			}
			else
			{
				a_zombies[i] thread electric_cherry_stun();
				a_zombies[i] thread electric_cherry_shock_or_death_fx( "tesla_shock_fx", "tesla_shock" );
			}

			wait(0.1);

			a_zombies[i] dodamage(damage, self.origin, self, self);
		}
	}
}

electric_cherry_shock_or_death_fx( fx_type, fx_name )
{
	tag = "J_Spine1";
	if( self.animname == "zombie" )
	{
		tag = "J_SpineUpper";

		if( fx_type == "tesla_death_fx" )
		{
			if( self.has_legs )
				self.deathanim = random( level._zombie_tesla_death["zombie"] );
			else
				self.deathanim = random( level._zombie_tesla_crawl_death["zombie"] );
		}
	}
	
	network_safe_play_fx_on_tag( fx_type, 2, level._effect[fx_name], self, tag );
	self playsound( "cherry_explode" );
}

electric_cherry_stun()
{
	if ( self.ignoreall == false && self.health >= 0 && self.animname == "zombie" )
	{
		if( self.has_legs )
			self animscripted("electric_cherry_hit", self.origin, self.angles, random(level._zombie_tesla_death[self.animname]));
		else
			self animScripted("electric_cherry_hit_crawl", self.origin, self.angles, random(level._zombie_tesla_crawl_death["zombie"]));
	}
}

electric_cherry_reload_fx(fraction, laststand_effect)
{
	if( is_true( laststand_effect ) )
	{
		shock_fx = "electric_cherry_explode";
	}
	else if(fraction >= 0.67)
	{
		shock_fx = "electric_cherry_reload_small";
	}
	else if(fraction >= 0.33 && fraction < 0.67)
	{
		shock_fx = "electric_cherry_reload_medium";
	}
	else
	{
		shock_fx = "electric_cherry_reload_large";
	}

	tag_origin_electric_cherry = spawn("script_model", self.origin + ( 0, 0, 10 ) );
	tag_origin_electric_cherry setmodel("tag_origin");
	tag_origin_electric_cherry linkTo( self, "tag_origin", ( 0, 0, 0 ), ( 270, 0, 0 ) );

	PlayFxOnTag( level._effect[ shock_fx ], tag_origin_electric_cherry, "tag_origin" );

	wait 1.5;

	tag_origin_electric_cherry unlink();
	tag_origin_electric_cherry delete();
}

// !/=====\!
// !|=====|! Vulture Aid
// !\=====/! 

vulture_zombie_function( player )
{	
	if( IsDefined(self.vulture_aid_marked) || Is_Boss( self ) || self.isdog )
	{
		return;
	}
	
	self.vulture_aid_marked = true;
	
	if ( randomint( 100 ) >= level.zombie_vars[ "vulture_drop_chance" ] )
	{
		return;
	}
	
	total = level.zombie_vars[ "vulture_ammo_chance" ] + level.zombie_vars[ "vulture_points_chance" ] + level.zombie_vars[ "vulture_stink_chance" ];
	ammoChance = level.zombie_vars[ "vulture_ammo_chance" ];
	pointsChance = level.zombie_vars[ "vulture_ammo_chance" ] + level.zombie_vars[ "vulture_points_chance" ];
	randomNumber = randomint( total );

	if ( randomNumber < ammoChance )
	{
		self thread vulture_zombie_drop( "ammo", player );
	}
	else if ( randomNumber > ammoChance && randomNumber < pointsChance )
	{
		self thread vulture_zombie_drop( "points", player );
	}
	else
	{
		self thread vulture_zombie_mist_watcher();
	}
}

vulture_zombie_drop( type, player )
{
	self waittill( "death" );

	self.vulture_aid_marked = undefined;

	if( isDefined( player ) && player hasPerk( "specialty_bulletdamage" ) && player.vultureDropCount < level.zombie_vars[ "vulture_drops_max" ] )
	{	
		drop_model = spawn( "script_model", self.origin + ( 0, 0, 10 ) );
		drop_model.angles = self.angles;
		
		if ( isDefined( drop_model ) )
		{
			// Tally mark the drop count
			player.vultureDropCount++;
		
			players = get_players();
			for( i = 0; i < players.size; i++ )
			{
				drop_model SetInvisibleToPlayer( players[ i ] );
			}
		
			drop_model SetVisibleToPlayer( player );
			drop_model playSound( "vulture_drop" );
			drop_model playloopSound( "vulture_loop", 1 );
			drop_model thread vulture_drop_timeout( player );
			drop_model thread vulture_drop_disappear_on_unsubscribe( player );
			
			switch( type )
			{
				case "points":
				{
					drop_model setModel( "bo2_p6_zm_perk_vulture_points" );
					drop_model thread vulture_points_watcher( player );
					break;
				}
				case "ammo":
				{
					drop_model setModel( "bo2_p6_zm_perk_vulture_ammo" );
					drop_model thread vulture_ammo_watcher( player );
					break;
				}
			}	

			playfxontag( level._effect[ "vulture_glow" ], drop_model, "tag_origin" );
		}
	}
}

vulture_drop_timeout( player )
{
	self endon( "vulture_drop_grabbed" );
	player endon( "unsubscribe_vulture_aid" );
	player endon( "disconnect" );
	wait 10;

	for ( i = 0; i < 40; i++ )
	{
		if ( i % 2 )
			self hide();
		else
			self show();

		if ( i < 15 )
			wait .5;
		else if ( i < 25 )
			wait .25;
		else
			wait .1;
	}
	
	player.vultureDropCount--;
	self notify( "vulture_drop_timeout" );
	self StopLoopSound();
	self delete();
}

vulture_drop_disappear_on_unsubscribe( player )
{
	self endon( "vulture_drop_grabbed" );
	self endon( "vulture_drop_timeout" );
	player waittill_any( "disconnect", "unsubscribe_vulture_aid" );
	player.vultureDropCount--;
	self StopLoopSound();
	self delete();
}

vulture_points_watcher( player )
{
	self endon( "vulture_drop_timeout" );
	player endon( "unsubscribe_vulture_aid" );
	player endon( "disconnect" );
	
	while( 1 )
	{
		if ( distance( player.origin, self.origin ) < 50 )
		{
			player playSound( "vulture_pickup" );
			player playSound( "vulture_money" );
			
			points = 10;
			rand = randomInt( 2 );
			if ( rand == 1 )
			{
				points = 20;
			}
			
			player maps\_zombiemode_score::add_to_player_score( add_points( points ) );
			player.vultureDropCount--;
			
			self notify( "vulture_drop_grabbed" );
			self StopLoopSound();
			self delete();
			return;
		}
		wait .1;
	}
}

vulture_ammo_watcher( player )
{
	self endon( "vulture_drop_timeout" );
	player endon( "unsubscribe_vulture_aid" );
	player endon( "disconnect" );

	while( 1 )
	{
		if ( distance( player.origin, self.origin ) < 50 )
		{
			player playSound( "vulture_pickup" );
			
			current_weapon = player getCurrentWeapon();			
			current_ammo = player getWeaponAmmoStock( current_weapon );
			weapon_max_ammo = weaponMaxAmmo( current_weapon );
			clip = WeaponClipSize( current_weapon );
			clip_add = int( clip / 10 );
			if ( clip_add < 1 )
			{
				clip_add = 1;
			}
			
			new_ammo = current_ammo + clip_add;
			if ( new_ammo > weapon_max_ammo )
			{
				new_ammo = weapon_max_ammo;
			}
				
			player SetWeaponAmmoStock( current_weapon, new_ammo );
			player.vultureDropCount--;
			
			self notify( "vulture_drop_grabbed" );
			self StopLoopSound();
			self delete();
			return;
		}
		wait .1;
	}
}

vulture_zombie_mist_watcher()
{		
	vulture_mists = vulture_get_mists();
	if ( vulture_mists.size > level.zombie_vars[ "vulture_stink_max" ] )
	{
		return;
	}
		
	vulture_mist = spawn( "script_model", self.origin + ( 0, 0, 16 ), 1, 1, 1 );
	vulture_mist.linked = true;
	vulture_mist playsound( "vulture_mist_start" );
	vulture_mist playloopSound( "vulture_mist_loop", 1 );
	vulture_mist.targetname = "vulture_mist";
	vulture_mist.angles = self.angles;
	vulture_mist setmodel( "tag_origin" );
	
	vulture_mist linkTo( self, "tag_origin" );
	vulture_mist thread vulture_mist_fx( "tag_origin", level._effect[ "vulture_mist" ] );
	
	self waittill( "death" );
	vulture_mist.linked = false;
	if ( !check_point_in_playable_area( vulture_mist.origin ) )
	{
		vulture_mist stoploopsound( 2 );
		vulture_mist stopsounds( 2 );
		vulture_mist notify( "stop_vulture_fx" );
		wait 2;
		vulture_mist delete();
		vulture_mist = undefined;
		return;
	}
	
	vulture_mist unlink();
	wait level.zombie_vars[ "vulture_mist_time" ];
	vulture_mist stoploopsound( 2 );
	vulture_mist stopsounds( 2 );
	vulture_mist playsound( "vulture_mist_stop" );
	vulture_mist notify( "stop_vulture_fx" );

	PlayFX( level._effect[ "vulture_mist_disperse" ], vulture_mist.origin );

	wait 1;
	vulture_mist.targetname = undefined;
	vulture_mist delete();
	vulture_mist = undefined;
}

vulture_mist_watcher()
{
	self endon( "disconnect" );
	self endon( "unsubscribe_vulture_aid" );
	
	touched = false;
	while( 1 )
	{
		//Validate that all players are inside Mist or Solo Player
		players = get_players();
		if(vulture_players_stinky() == players.size || (players.size == 1 && self.ignoreme == true))
		{
			if( !level.zombie_vars["vulture_aid_point"] )
			{
				level.zombie_vars["vulture_aid_point"] = true;
				level thread vulture_find_exit_point( true );
			}
		}
		else
		{
			level.zombie_vars["vulture_aid_point"] = false;
		}

		touching = false;
		vulture_mists = vulture_get_mists();
		for ( i = 0; i < vulture_mists.size; i++ )
		{
			if ( self hasPerk( "specialty_bulletdamage" ) && distance( vulture_mists[ i ].origin, self.origin ) < 50 && !vulture_mists[ i ].linked )
			{
				touching = true;
				if ( !touched )
				{
					self playSound( "vulture_mist_start" );
					touched = true;
				}
				
				if ( self.vultureMistLevel < 1 )
				{
					self.vultureMistLevel += 0.2;
				}
				else
				{
					self.vultureMistLevel = 1;
				}
					
				self setblur( self.vultureMistLevel, .01 );	
				break;
			}
		}
		
		if ( touching )
		{
			if ( !self.vultureFullInMist && self.vultureMistLevel >= 1 )
			{
				self.vultureFullInMist = true;
				self.ignoreme = true;
				
				if (isDefined(self.perk_hud["specialty_bulletdamage"]))
				{
					self.perk_hud["specialty_bulletdamage"] setShader("specialty_vulture_zombies_glow", 24, 24);
				}
			}
			wait 0.25;
			continue;
		}	
		else
		{
			if ( touched )
			{
				self playSound( "vulture_mist_stop" );
				touched = false;
			}
			
			if ( self.vultureMistLevel > 0 )
			{
				self.vultureMistLevel -= 0.2;
				self setblur( self.vultureMistLevel, .01 );
			}
			else
			{
				self.vultureMistLevel = 0;
			}
		}
		
		if ( !self maps\_laststand::player_is_in_laststand() && self.vultureFullInMist && self.vultureMistLevel <= 0 )
		{
			self.vultureFullInMist = false;
			self.ignoreme = false;
			
			if (isDefined(self.perk_hud["specialty_bulletdamage"]))
			{
				self.perk_hud["specialty_bulletdamage"] setShader("specialty_vulture_zombies", 24, 24);
			}
		}

		wait 0.25;
	}
}

vulture_find_exit_point()
{
	players = get_players();

	while( vulture_players_stinky() == players.size )
	{
		zombies = GetAiArray( "axis" );
		for ( i = 0; i < zombies.size; i++ )
		{
			if ( !zombies[i].vulture_ignore_solo ) //Boss no attract
			{
				zombies[i].vulture_ignore_solo = true;

				zombies[i] notify( "stop_find_flesh" );
				zombies[i] notify( "zombie_acquire_enemy" );
				zombies[i] OrientMode( "face default" );
				zombies[i].ignoreall = true;

				zombies[i] SetGoalPos( level.vulture_zombiegoto.origin );
			}
		}

		wait 0.05;
	}

	zombies = GetAiArray( "axis" );
	for ( i = 0; i < zombies.size; i++ )
	{
		if ( is_true( zombies[i].vulture_ignore_solo ) )
		{
			zombies[i].vulture_ignore_solo = false;
			zombies[i].ignoreall = false;
			zombies[i] thread maps\_zombiemode_spawner::find_flesh();
		}
	}
}

vulture_players_stinky()
{
	players = get_players();
	num_stinky = 0;

	for( i = 0; i < players.size; i++ )
	{
		if( players[i].vultureFullInMist && players[i] hasPerk("specialty_bulletdamage") )
			num_stinky++;
	}

	return num_stinky;
}

vulture_get_mists()
{
	return getEntArray( "vulture_mist", "targetname" );
}

vulture_mist_fx( tag, fx )
{
	self endon( "stop_vulture_fx" );
	
	playfxontag( fx, self, tag );

	while( 1 )
	{
		players = get_players();
		for( i = 0; i < players.size; i++ )
		{
			if( players[ i ] hasPerk( "specialty_bulletdamage" ) )
				self SetVisibleToPlayer( players[ i ] );
			else
				self SetInvisibleToPlayer( players[ i ] );			
		}
		wait randomfloatrange( 0.1, 0.2 );
	}
}

// !/=====\!
// !|=====|! Vulture aid waypoint
// !\=====/!

setup_player_vulture_waypoints()
{
	level.vulture_hud_waypoints_is_rebuilding = false;

	level.vulture_hud_waypoints = [];
	level.vulture_hud_waypoints_perks = getEntArray( "zombie_vending", "targetname" );
	level.vulture_hud_waypoints_weapons = getEntArray( "weapon_upgrade", "targetname" );
	// Default and BO2,BO2,IW
	level.vulture_hud_waypoints_boxes = getEntArray( "treasure_chest_use", "targetname" );

	shadows_mystery_box = getEntArray( "shadows_mystery_box_use", "targetname" );
	if( IsDefined( shadows_mystery_box ) && shadows_mystery_box.size )
		level.vulture_hud_waypoints_boxes = array_combine( level.vulture_hud_waypoints_boxes, shadows_mystery_box );

	origins_mystery_box = getEntArray( "origins_mystery_box_use", "targetname" );
	if( IsDefined( origins_mystery_box ) && origins_mystery_box.size )
		level.vulture_hud_waypoints_boxes = array_combine( level.vulture_hud_waypoints_boxes, origins_mystery_box );

	motd_mystery_box = getEntArray( "motd_mystery_box_use", "targetname" );
	if( IsDefined( motd_mystery_box ) && motd_mystery_box.size )
		level.vulture_hud_waypoints_boxes = array_combine( level.vulture_hud_waypoints_boxes, motd_mystery_box );

	magic_wheel_mystery_box = getEntArray( "magic_wheel_use", "targetname" );
	if( IsDefined( magic_wheel_mystery_box ) && magic_wheel_mystery_box.size )
		level.vulture_hud_waypoints_boxes = array_combine( level.vulture_hud_waypoints_boxes, magic_wheel_mystery_box );

	//Default and BO2,IW
	level.vulture_hud_waypoints_paps = getEntArray( "zombie_vending_upgrade", "targetname" );

	iw_pap = getEntArray( "zombie_vending_upgrade_iw", "targetname" );
	if( IsDefined( iw_pap ) && iw_pap.size )
		level.vulture_hud_waypoints_paps = array_combine( level.vulture_hud_waypoints_paps, iw_pap );

	origins_pap = getEntArray( "zombie_vending_upgrade_origins", "targetname" );
	if( IsDefined( origins_pap ) && origins_pap.size )
		level.vulture_hud_waypoints_paps = array_combine( level.vulture_hud_waypoints_paps, origins_pap );

	level.vulture_hud_waypoints_wunder = getEntArray( "wunderfizz_use", "targetname" );
}

vulture_waypoint_subscribe(player)
{
	if (level.vulture_hud_waypoints_is_rebuilding)
	{
		return;
	}
	
	level.vulture_hud_waypoints_is_rebuilding = true;
	level.vulture_hud_temporary_waypoints = [];
	level notify("rebuild_vulture_aid_waypoints");
	
	// SetInvisibleToPlayer is used on model the fx can't longer become visible
	// To solve this ugly problem I rebuild everything...
	destroy_all_fx_vulture_hud_shaders();	
	
	perks = level.vulture_hud_waypoints_perks;
	for( k = 0; k < perks.size; k++ )
	{
		create_fx_vulture_hud_shader( perks[k], level.vulture_huds[ perks[k].script_noteworthy ], (0,0,0), perks[k].script_noteworthy );
	}
	
	weapons = level.vulture_hud_waypoints_weapons;
	for( k = 0; k < weapons.size; k++ )
	{
		create_fx_vulture_hud_shader( weapons[k], "vulture_rifle_shader", (0,0,0), undefined );
	}
	
	boxes = level.vulture_hud_waypoints_boxes;
	for( k = 0; k < boxes.size; k++ )
	{
		create_fx_vulture_hud_shader( boxes[k], "vulture_box_shader", (0,0,0), undefined );
	}
	
	paps = level.vulture_hud_waypoints_paps;
	for( k = 0; k < paps.size; k++ )
	{
		create_fx_vulture_hud_shader( paps[k], "vulture_pap_shader", (0,0,0), undefined );
	}

	paps = level.vulture_hud_waypoints_paps;
	for( k = 0; k < paps.size; k++ )
	{
		create_fx_vulture_hud_shader( paps[k], "vulture_pap_shader", (0,0,0), undefined );
	}
	
	wunder = level.vulture_hud_waypoints_wunder;
	for( k = 0; k < wunder.size; k++ )
	{
		create_fx_vulture_hud_shader( wunder[k], "vulture_wunderfizz_shader", (0,0,0), undefined );
	}
	
	level.vulture_hud_waypoints = level.vulture_hud_temporary_waypoints;
	level.vulture_hud_temporary_waypoints = undefined;
	
	// Somehow SetInvisibleToPlayer(player, false) works the opposite way
	players = get_players();
	for( i = 0; i < players.size; i++ )
	{
		if ( players[i] hasPerk("specialty_bulletdamage") )
		{
			for( k = 0; k < level.vulture_hud_waypoints.size; k++ )
			{
				level.vulture_hud_waypoints[k] SetInvisibleToPlayer(players[i], false);
			}
		}
		else
		{
			for( k = 0; k < level.vulture_hud_waypoints.size; k++ )
			{
				level.vulture_hud_waypoints[k] SetInvisibleToPlayer(players[i]);
			}
		}
	}
	
	level.vulture_hud_waypoints_is_rebuilding = false;
}

vulture_waypoint_unsubscribe(player)
{
	level endon("rebuild_vulture_aid_waypoints");

	for( k = 0; k < level.vulture_hud_waypoints.size; k++ )
	{
		level.vulture_hud_waypoints[k] SetInvisibleToPlayer(player);
	}
}

create_fx_vulture_hud_shader(object, effectName, offset, perk)
{
	shader = Spawn( "script_model", object.origin + offset);
	shader SetModel( "tag_origin" );
	shader LinkTo( object );
	shader.perk = perk;
	PlayFxOnTag( level._effect[effectName], shader, "tag_origin" );	
		
	// register vulture_hud
	level.vulture_hud_temporary_waypoints[level.vulture_hud_temporary_waypoints.size] = shader;
}

destroy_all_fx_vulture_hud_shaders()
{
	for( k = 0; k < level.vulture_hud_waypoints.size; k++ )
	{
		level.vulture_hud_waypoints[k] delete();
	}
}

// !/=====\!
// !|=====|! Widows Wine
// !\=====/! 

widows_wine_explode( player, sound )
{
	origin = self.origin;
	earthquake ( 0.8, 0.6, origin, level.zombie_vars[ "widows_wine_max_range" ] );

	if( IsDefined( sound ) && sound )
	{
		playsoundatposition ( "mx_widows_explode", origin );
		playFX( level._effect[ "widows_wine_explode" ], origin );
	}

	zombies = get_array_of_closest( origin, GetAiSpeciesArray( "axis", "all" ) );
	for( i = 0; i < zombies.size; i++ )
	{		
		if ( distance( origin, zombies[i].origin ) > level.zombie_vars[ "widows_wine_max_range" ] )
		{
			continue;
		}

		if ( Is_Boss(zombies[i]) )
		{
			zombies[i] doDamage( int(zombies[i].maxHealth / 100 * level.zombie_vars[ "widows_wine_damage" ] ) + level.round_number + randomIntRange( 100, 500 ), origin, self, undefined, "grenade" );
			continue;
		}

		if ( isDefined( zombies[i].widow_stunned ) && zombies[i].widow_stunned )
		{
			continue;
		}
		
		zombies[i] thread widows_wine_should_do_drop( player );
		zombies[i] thread widows_wine_stunned();
		zombies[i] thread widows_wine_stunned_fx();
		
		if ( isDefined( level.zombie_vars["zombie_powerup_insta_kill_on"] ) && level.zombie_vars["zombie_powerup_insta_kill_on"] )
		{

			zombies[i] doDamage( zombies[i].health + 666, origin, self, undefined, "grenade" );
		}
		else
		{
			zombies[i] doDamage( int(zombies[i].maxHealth / 100 * level.zombie_vars[ "widows_wine_damage" ] ) + level.round_number + randomIntRange( 100, 500 ), origin, self, undefined, "grenade" );
		}
	}
}

widows_wine_stunned( player )
{
	self endon( "death" );

	if ( isDefined( self.widow_stunned ) && self.widow_stunned )
		return;
	
	self.widow_stunned = true;
	self.moveplaybackrate = 0.5;
	self.animplaybackrate = 0.5;
	self.traverseplaybackrate = 0.5;

	self.old_move_speed = self.zombie_move_speed;
	self maps\_zombiemode_spawner::set_zombie_run_cycle("walk");

	if( isDefined( player ) && IsPlayer( player ) )
		self thread widows_wine_stunned_zombie_score( player, 16, 10 );

	self waittill_any_or_timeout(16, "death");

	if( !isDefined( self ) )
		return;

	self.moveplaybackrate = 1;
	self.animplaybackrate = 1;
	self.traverseplaybackrate = 1;

	self maps\_zombiemode_spawner::set_zombie_run_cycle( self.old_move_speed );
	
	self notify( "widows_effects_over" );
	self playSound( "ww_lp_end" );

	if( IsAlive( self ) )
		self.widow_stunned = undefined;
}

widows_wine_stunned_fx()
{
	self endon( "death" );
	self endon( "widows_effects_over" );
	
	while( 1 )
	{
		playFX( level._effect[ "widows_wine_zombie" ], self getTagOrigin( "j_spinelower" ) );
		wait 1;
	}
}

widows_wine_stunned_zombie_score( player, duration, max_score )
{
	self endon( "death" );
	self endon( "widows_effects_over" );

	start_time = GetTime();
	end_time = start_time + (duration * 1000);

	while(GetTime() < end_time)
	{
		player maps\_zombiemode_score::add_to_player_score( add_points( max_score ) );
		wait duration / max_score;
	}
}

widows_wine_explode_on_melee_watcher()
{
	self endon( "unsubscribe_widows_wine" );

	weapon = level.zombie_vars["widows_wine_grenade"];

	while( 1 )
	{
		self waittill("widows_wine_melee", zombie);
	
		if ( isDefined( self.widows_exploded ) )
		{
			continue;
		}
			
		if ( !self hasWeapon( weapon ) )
		{
			continue;
		}
		
		if ( isDefined( zombie ) && Distance( self.origin, zombie.origin ) > 80)
		{
			continue;
		}
		
		clip_ammo = self GetWeaponAmmoClip( weapon );
		if ( !isDefined( clip_ammo ) )
		{
			clip_ammo = 0;
		}
		
		if ( clip_ammo < 1 || (clip_ammo == 1 && self isThrowingGrenade()))
		{
			continue;
		}
		
		clip_ammo--;
		
		// ugly solution but works well enough to show the player how many grenades are left
		self SwitchToOffhand( weapon );
		
		self setWeaponAmmoClip( weapon, clip_ammo );
		self.widows_exploded = 1;
		self thread widows_wine_explode( self, true );

		if( !self.isInvulnerability )
		{
			self enableInvulnerability();
			self.isInvulnerability = true;
		}

		wait 0.25;

		if( self.isInvulnerability )
		{
			self disableInvulnerability();
			self.isInvulnerability = false;
		}
		
		wait 1.25;
		self.widows_exploded = undefined;
	}
}

widows_wine_should_do_drop( player )
{
	self waittill( "death" );
	self.widow_stunned = undefined;
	
	if ( isDefined( level.zombie_vars[ "zombie_drop_item" ] ) && level.zombie_vars[ "zombie_drop_item" ] >= 1 )
		return;
	
	if ( self.isdog || Is_Boss( self ) )
		return;
	
	random_number = randomint( 100 );
	b_should_drop = random_number > ( 100 - level.zombie_vars[ "widows_wine_drop_chance" ] );
	if ( !b_should_drop )
		return;
		
	if ( !maps\_zombiemode_utility::is_player_valid( player ) || !player hasWeapon( level.zombie_vars["widows_wine_grenade"] ) || !player hasPerk("specialty_extraammo") )
		return;
	
	if ( !check_point_in_playable_area( self.origin ) )
		return;
	
	widows_spider_model = spawn( "script_model", self.origin + ( 0, 0, 40 ) );
	effect = spawn( "script_model", widows_spider_model.origin );
	effect setModel( "tag_origin" );
	playfxontag( level._effect[ "monkey_glow" ], effect, "tag_origin" );
	widows_spider_model setModel( "bo3_t7_ww_powerup" );
	widows_spider_model PlayLoopSound( "zmb_spawn_powerup_loop" );
	widows_spider_model thread wiggle_object();
	widows_spider_model thread widows_wine_timeout( effect, player );
	widows_spider_model thread widows_wine_grab_powerup( effect, player );
	widows_spider_model thread widows_wine_check_for_down_or_disconnect( player );
}

widows_wine_timeout( effect, player )
{
	self endon ( "widows_grabbed" );
	wait 1;
	for ( i = 0; i < 10; i++ )
	{
		if ( i % 2 )
			self widows_wine_hide();
		else
			self widows_wine_show(player);

		wait 0.5;
	}

	self notify ( "widows_timedout" );
	effect delete();
	self delete();
}

widows_wine_grab_powerup( effect, player )
{
	self endon( "widows_timedout" );

	while ( isDefined( self ) && player hasWeapon( level.zombie_vars["widows_wine_grenade"] ) )
	{
		if ( distance ( player.origin, self.origin ) < 75 )
		{
			playfx( level._effect[ "powerup_grabbed" ], self.origin );
			playfx( level._effect[ "powerup_grabbed_wave" ], self.origin );	
			playsoundatposition( "zmb_powerup_grabbed", self.origin );
			self stoploopsound();
			
			clip_ammo = player GetWeaponAmmoClip( level.zombie_vars["widows_wine_grenade"] );		
			if ( !isDefined( clip_ammo ) )
			{
				clip_ammo = 0;
			}
	
			clip_ammo += 1;
			if ( clip_ammo > 4 )
				clip_ammo = 4;
	
			player setWeaponAmmoClip( level.zombie_vars["widows_wine_grenade"], clip_ammo );		
			self notify ( "widows_grabbed" );
			break;
		}
		wait .1;
	}
	effect delete();
	self delete();
}

widows_wine_check_for_down_or_disconnect( player )
{
	self endon( "widows_timedout" );
	self endon( "widows_grabbed" );
	player waittill_any( "death", "fake_death", "player_downed", "disconnect" );
	self notify( "widows_timedout" );
}

widows_wine_hide()
{
	players = get_players();
	for( i = 0; i < players.size; i++ )
		self SetInvisibleToPlayer( players[ i ] );
}

widows_wine_show( player )
{
	players = get_players();
	for( i = 0; i < players.size; i++ )
		self SetInvisibleToPlayer( players[ i ] );
	
	self SetVisibleToPlayer( player );
}

widows_wine_override_wallbuy_purchase( zombie_weapon_upgrade )
{
	if( !level.zombie_vars[ "use_widows_wine" ] )
		return false;

	if( self HasPerk( "specialty_extraammo" ) && is_lethal_grenade( zombie_weapon_upgrade ) )
		return true;

	return false;
}

// !/=====\!
// !|=====|! Tombstone Soda
// !\=====/! 

tombstone_laststand()
{
	self endon( "disconnect" );

	self waittill( "player_tombstone_laststand" );

	//Spawn Tomb
	stone = spawn( "script_model", self.origin + (0, 0, 35) );
	stone.angles = (90, 264.803, 84.8025);
	stone setmodel( "bo2_ch_tombstone1" );
	stone thread wiggle_object();
	stone.tombstone_player = self;
	stone.grabbed = false;
	playsoundatposition("zmb_spawn_powerup", stone.origin);
	stone PlayLoopSound( "zmb_spawn_powerup_loop" );
	playfxontag( level._effect[ "powerup_on" ], stone, "tag_origin" );

	stone thread tombstone_grab_powerup();
}

tombstone_grab_powerup()
{
	self endon( "tombstone_grabbed" );

	while ( !self.grabbed )
	{
		players = get_players();
		for( i = 0; i < players.size; i++ )
		{
			if ( distance ( players[i].origin, self.origin ) < 75 && self.tombstone_player == players[i] && is_player_valid( players[i] ) )
			{
				playfx( level._effect[ "powerup_grabbed" ], self.origin );
				playfx( level._effect[ "powerup_grabbed_wave" ], self.origin );	
				playsoundatposition( "zmb_powerup_grabbed", self.origin );

				players[i] thread tombstone_give_perks();

				self.grabbed = true;
				break;
			}
		}

		wait 0.1;
	}

	if( self.grabbed )
	{
		self StopLoopSound();
		self Delete();
	}
}

tombstone_give_perks()
{
	if( IsDefined( self.bought_perks ) && self.bought_perks.size > 0 )
	{
		for(i = 0; i < self.bought_perks.size; i++)
		{
			if(self HasPerk( self.bought_perks[i] ) || self.bought_perks[i] == "specialty_altmelee" )
				continue;

			self give_perk( self.bought_perks[i] );
		}

		self.bought_perks = [];
	}

	if( IsDefined( self.invetory_backup ) && self.invetory_backup.size > 0 )
	{
		self player_get_inventory_backup();
	}
}

player_set_inventory_backup()
{	
	backup = [];
	backup[ "score" ] = self.score;
	backup[ "current_weapon" ] = self getCurrentWeapon();
	backup[ "weapon_inventory" ] = [];
	backup[ "ammo_inventory" ] = [];
	backup[ "stock_inventory" ] = [];

	primaryWeapons = self GetWeaponsListPrimaries();
	for( i = 0; i < primaryWeapons.size; i++ )
	{
		if( primaryWeapons[i] == "minigun_zm" )
			continue;

		backup[ "weapon_inventory" ][i] = primaryWeapons[i];
		backup[ "ammo_inventory" ][i] = self GetWeaponAmmoClip( primaryWeapons[i] );
		backup[ "stock_inventory" ][i] = self GetWeaponAmmoStock( primaryWeapons[i] );
	}
	
	return backup;
}

player_get_inventory_backup()
{
	weapon_limit = 2;
	if( self HasPerk( "specialty_additionalprimaryweapon" ) )
		weapon_limit = 3;

	self.invetory_backup[ "weapon_inventory" ] = array_randomize( self.invetory_backup[ "weapon_inventory" ] );

	for (i = 0; i < self.invetory_backup[ "weapon_inventory" ].size; i++)
	{
		primaries = self GetWeaponsListPrimaries();
		if( !self HasWeapon( self.invetory_backup[ "weapon_inventory" ][i] ) && primaries.size < weapon_limit )
		{
			if( IsSubStr( self.invetory_backup[ "weapon_inventory" ][i], "upgraded" ) )
				self GiveWeapon( self.invetory_backup[ "weapon_inventory" ][i], 0, self maps\_zombiemode_weapons::get_pack_a_punch_weapon_options( self.invetory_backup[ "weapon_inventory" ][i] ) ); 
			else
				self GiveWeapon( self.invetory_backup[ "weapon_inventory" ][i] ); 

			self SetWeaponAmmoClip( self.invetory_backup[ "weapon_inventory" ][i], self.invetory_backup[ "ammo_inventory" ][i] );
			self SetWeaponAmmoStock( self.invetory_backup[ "weapon_inventory" ][i], self.invetory_backup[ "stock_inventory" ][i] );
		}
	}
	
	self SwitchToWeapon( self.invetory_backup[ "current_weapon" ] );

	self.invetory_backup = undefined;
}

// !/=====\!
// !|=====|! Zombie Effect
// !\=====/! 

perks_zombie_hit_effect( mod, hit_location, point, attacker, amount )
{
	if( !isDefined(attacker) || !isAlive( self ) || !isPlayer( attacker ) )
	{
		return false;
	}

	// Double tap 2.0
	if(attacker HasPerk("specialty_rof") && ( mod == "MOD_PISTOL_BULLET" || mod == "MOD_RIFLE_BULLET" ) )
	{
        self perks_doubletap_damage( amount, self.origin, attacker, self.damageLocation );
    }           

    // Deadshot Daiquiri
    if ( ( self.damageLocation == "head" || self.damageLocation == "helmet" ) && attacker hasPerk( "specialty_deadshot" )  )
    {
        self perks_deadshot_damage( amount, attacker, mod, self.damageLocation );
    }

    // Boss no damage
    if( Is_Boss( self ) )
    {
    	return false;
    }

    // Vulture Aid
    if ( attacker hasPerk( "specialty_bulletdamage" ) && !self.isdog )
	{
		self thread vulture_zombie_function(attacker);
	}
	else
	{
		self.vulture_aid_marked = undefined;
	}

	// Widows Wine
	if ( attacker hasPerk( "specialty_extraammo" ) && mod == "MOD_MELEE" )
	{
		if ( isAlive( self ) && RandomInt( 100 ) < level.zombie_vars[ "widows_wine_melee_stun_chance" ] )
		{
			if ( Is_Boss( self ) )
			{
				self doDamage( int(self.maxHealth / 100 * level.zombie_vars[ "widows_wine_damage" ] ) + level.round_number + randomIntRange( 100, 500 ), point, self, undefined, "grenade" );

				return true;
			}
			else if (isAlive( self ) && RandomInt( 100 ) < level.zombie_vars[ "widows_wine_melee_stun_chance" ])
			{
				if ( !(isDefined( self.widow_stunned ) && self.widow_stunned) )
				{
					self thread widows_wine_stunned();
					self thread widows_wine_stunned_fx();

					extra_damage = int( amount * level.zombie_vars[ "widows_wine_melee_damage" ] );
					self DoDamage( extra_damage, self.origin, attacker );

					return true;
				}
			}
		}
	}

	return false;
}

// !/=====\!
// !|=====|! Double tap 2.0
// !\=====/!

perks_doubletap_damage( amount, origin, attacker, location, direction_vec, point, type )
{
    self endon( "death" );
    self.damageLocation = location;
    wait_network_frame();
    setPlayerIgnoreRadiusDamage( true );
    self.attacker radiusDamage( self.origin, 1, amount, amount, self.attacker, self.damagemod );
    setPlayerIgnoreRadiusDamage( false );
    // self doDamage( amount, origin, attacker );
    self.damageLocation = location;
    wait_network_frame();
}

// !/=====\!
// !|=====|! Deadshot Daiquiri
// !\=====/!

perks_deadshot_damage( amount, origin, attacker, location )
{
    self endon( "death" );
    self.deadshot_hit = true;
    new_damage = amount / 4;
    if ( attacker hasPerk( "specialty_rof" ) )
        new_damage = new_damage * 2;

    if ( new_damage > self.health )
    {
        score = 40;
        if ( isDefined( level.zombie_vars["zombie_powerup_point_doubler_on"] ) && level.zombie_vars["zombie_powerup_point_doubler_on"] )
            score = score * 2;

        attacker maps\_zombiemode_score::add_to_player_score( score );
    }
    self.damageLocation = location;
    wait_network_frame();
    self.attacker radiusDamage( self.origin, 1, amount, amount, self.attacker, self.damagemod );
    // self doDamage( new_damage, origin, attacker );
    wait_network_frame();
    self.deadshot_hit = undefined;
}

//================ End Functions ======================\\

get_mapname()
{
	if(isdefined(level.script))
		return level.script;
	else
		//return GetDvarString(#"mapname");
		return "";
}

add_points( points )
{
	if(level.zombie_vars["zombie_powerup_point_doubler_on"] == true)
		return ( points * 2 );
	else
		return points;
}

wiggle_object()
{
	self endon( "delete" );
	
	while ( isDefined( self ) )
	{
		waittime = randomFloatRange( 2.5, 5 );
		yaw = RandomInt( 360 );
		if( yaw > 300 )
			yaw = 300;
		if( yaw < 60 )
			yaw = 60;
		
		yaw = self.angles[ 1 ] + yaw;
		self rotateto ( ( -60 + randomint( 120 ), yaw, -45 + randomint( 90 ) ), waittime, waittime * 0.5, waittime * 0.5 );
		wait randomfloat( waittime - 0.1 );
	}
}

setup_player_abilities()
{
	flag_wait( "all_players_connected" );

	//Settings Vulture Aid
	level.vulture_zombiegoto = undefined;
	level thread vulture_set_zombiegoto();
	level thread setup_player_vulture_waypoints();

	players = get_players();
	for(i = 0; i < players.size; i++)
	{
		players[i] thread player_reset_abilities();
	}

	for( ;; )
	{
		level waittill( "connecting", player );

		player thread player_reset_abilities();
	}
}

vulture_set_zombiegoto()
{
	level endon( "end_game" );

	wait 5;

	level.vulture_zombiegoto = level.enemy_dog_locations[ RandomInt( level.enemy_dog_locations.size ) ];
}

player_reset_abilities()
{
	self SetClientDvar("perk_weapRateEnhanced", "1");
	self SetMaxHealth( level.zombie_vars["zombie_player_health"] );
	self thread player_cook_grenade_watcher();
	self thread player_switch_weapon_watcher();
	self thread return_fix();

	self.vultureFullInMist = false;
	self.vultureMistLevel = 0;
	self.vultureDropCount = 0;
	
	self.widow_backup_grenade_name = undefined;
	self.bought_perks = [];

	level thread vulture_waypoint_unsubscribe( self );

	if( level.zombie_vars["zombie_perk_give_all"] )
		self thread give_all_perks();
}

return_fix()
{
	self endon( "disconnect" );

    while( 1 )
    {
        self waittill_any_return( "player_revived", "spawned_player");
        self SetMaxHealth( level.zombie_vars["zombie_player_health"] );
    }
}

give_all_perks()
{
	wait 5; //Delay

	if( !IsDefined( level.wunderfizz_perks ) )
	{
		return;
	}

	for(i = 0; i < level.wunderfizz_perks.size; i++)
	{
		if(self HasPerk( level.wunderfizz_perks[i] ) )
			continue;

		self give_perk( level.wunderfizz_perks[i] );
	}
}

// Fixed ugly bug while holding / cooking the grenade
player_cook_grenade_watcher()
{
	self endon( "disconnect" );

	while( 1 )
	{
		self waittill("grenade_fire", grenade, weaponName);

		if( IsDefined( grenade ) )
		{
			wait 0.125;
			
			if (distance( self.origin, grenade.origin ) <= 0 && self fragButtonPressed() && self isThrowingGrenade())
			{
				self FreezeControls(true);
				self DisableOffhandWeapons();
				
				grenade delete();
				
				ammo_clip = self GetWeaponAmmoClip( weaponName );
				self TakeWeapon(weaponName);
				
				if(self fragButtonPressed())
				{
					self waittill("grenade_fire", grenade2, weaponName);
					if( IsDefined( grenade2 ) )
					{
						grenade2 delete();
					}
				}
				
				wait 0.05;
				
				self EnableOffhandWeapons();
				self FreezeControls(false);
				
				wait 1.75;
				
				self GiveWeapon(weaponName);
				self SetWeaponAmmoClip(weaponName, ammo_clip);
			}

			//Widows Wine
			if( self HasPerk( "specialty_extraammo" ) && weaponName == level.zombie_vars["widows_wine_grenade"] )
			{
				self thread php_widows_grenade( grenade, weaponName, "specialty_extraammo" );
			}

			//PHD Spawn Grenades
			if( self HasPerk( "specialty_flakjacket" ) && ( weaponName == level.zombie_vars["widows_wine_grenade"] || weaponName == level.zombie_vars["widows_wine_grenade_backup"] ) )
			{
				self php_widows_grenade( grenade, weaponName, "specialty_flakjacket" );
			}
		}
	}
}

thread_bump_trigger()
{
	// Check under the machines for change
	if ( IsDefined(self.script_sound) && self.script_sound == "fly_bump_bottle" )
	{
		self thread check_for_change();
	}

	self thread bump_trigger_listener();

	if(!IsDefined(self.script_activated)) //Sets a flag to turn the trigger on or off
	{
		self.script_activated = 1;
	}

	while( 1 )
	{
		self waittill("trigger", who);

		//Store sound to play in script_sound/ alias name
		if(IsDefined (self.script_sound) && self.script_activated)
		{	
			self playsound (self.script_sound);
		}

		while(IsDefined (who) && (who) IsTouching (self))
		{
			wait(0.1);
		}		
	}
}

//This will deactivate the trigger on a level notify if its stored on the trigger
bump_trigger_listener()
{
	//Store End-On conditions in script_label so you can turn off the bump trigger if a condition is met
	if(IsDefined (self.script_label))
	{
		level waittill(self.script_label);
		self.script_activated = 0;
	}
}

check_for_change()
{
	while ( 1 )
	{
		self waittill( "trigger", player );

		if ( player GetStance() == "prone" && is_player_valid( player ) )
		{
			player maps\_zombiemode_score::add_to_player_score( 100 );
			play_sound_at_pos( "purchase", player.origin );
			break;
		}
	}
}