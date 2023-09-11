#include common_scripts\utility;
#include maps\_utility;
#include maps\_zombiemode_utility;
#include maps\_zombiemode_zone_manager; 

#include maps\zombie_theater_quad;
//WEATHER_RAIN_CLASS
#include maps\_weather;

main()
{
	//WEAPON_GLOW_FX
	level._effect["wall_weapon_light"]				= loadfx( "weapon_glow" );

	//WEATHER_RAIN_FX
	level._effect["lightning_strike"] = LoadFX( "maps/zombie/fx_zombie_lightning_flash" );
    level._effect["rain_10"]   = LoadFX( "env/weather/fx_rain_sys_heavy" );
    level._effect["rain_9"]  = LoadFX( "env/weather/fx_rain_sys_heavy" );
    level._effect["rain_8"]  = LoadFX( "env/weather/fx_rain_sys_heavy" );
    level._effect["rain_7"]  = LoadFX( "env/weather/fx_rain_sys_heavy" );
    level._effect["rain_6"]  = LoadFX( "env/weather/fx_rain_sys_med" );
    level._effect["rain_5"]  = LoadFX( "env/weather/fx_rain_sys_med" );
    level._effect["rain_4"]  = LoadFX( "env/weather/fx_rain_sys_med" );
    level._effect["rain_3"]  = LoadFX( "env/weather/fx_rain_sys_med" );
    level._effect["rain_2"]  = LoadFX( "env/weather/fx_rain_sys_lght" );
    level._effect["rain_1"]  = LoadFX( "env/weather/fx_rain_sys_lght" );
    level._effect["rain_0"]  = LoadFX( "env/weather/fx_rain_sys_lght" );

    //WEATHER_SNOW_FX
    level._effect["snow_thick"]            = LoadFx ( "env/weather/WEATHER_SNOW_INTENSITY" );

	maps\template_fx::main();
	maps\template_amb::main();

	PreCacheModel("zombie_zapper_cagelight_red");
	precachemodel("zombie_zapper_cagelight_green");
	precacheShader("ac130_overlay_grain");	
	precacheshellshock( "electrocution" );
	// ww: viewmodel arms for the level
	PreCacheModel( "PLAYERS_VIEWHANDS_PRECACHE_0" ); // Dempsey
	PreCacheModel( "PLAYERS_VIEWHANDS_PRECACHE_1" ); // Nikolai
	PreCacheModel( "PLAYERS_VIEWHANDS_PRECACHE_2" );// Takeo
	PreCacheModel( "PLAYERS_VIEWHANDS_PRECACHE_3" );// Richtofen
	//PLAYERS_MODEL_PRIMIS_PRECACHE
	PreCacheModel( "c_zom_tomb_dempsey_fb_LOD0" );
	PreCacheModel( "c_zom_tomb_nikolai_fb_LOD0" );
	PreCacheModel( "c_zom_tomb_richtofen_fb_LOD0" );
	PreCacheModel( "c_zom_tomb_takeo_fb_LOD0" );
	//PLAYERS_MODEL_VICTIS_PRECACHE
	PreCacheModel( "c_zom_player_engineer_fb_LOD0" );
	PreCacheModel( "c_zom_player_farmgirl_fb_LOD0" );
	PreCacheModel( "c_zom_player_oldman_fb_LOD0" );
	PreCacheModel( "c_zom_player_reporter_dam_fb_LOD0" );
	//PLAYERS_MODEL_CIA_PRECACHE
	PreCacheModel( "c_zom_player_cia_fb" );
	//PLAYERS_MODEL_CDC_PRECACHE
	PreCacheModel( "c_zom_player_cdc_fb" );
	// DSM: models for light changing
	PreCacheModel("zombie_zapper_cagelight_on");
	precachemodel("zombie_zapper_cagelight");

	if(GetDvarInt( #"artist") > 0)
	{
		return;
	}
	
	level.dogs_enabled = true;	
	level.mixed_rounds_enabled = 1;//true;
	level.random_pandora_box_start = true;

	level.zombiemode_using_marathon_perk = PERK_ENABLE_MARATHON;
	level.zombiemode_using_divetonuke_perk = PERK_ENABLE_PHD;
	level.zombiemode_using_deadshot_perk = PERK_ENABLE_DEADSHOT;
	level.zombiemode_using_additionalprimaryweapon_perk = PERK_ENABLE_MULE;

	level.zombiemode_precache_player_model_override = ::precache_player_model_override;
	level.zombiemode_give_player_model_override = ::give_player_model_override;
	level.zombiemode_player_set_viewmodel_override = ::player_set_viewmodel_override;
	//level.register_offhand_weapons_for_level_defaults_override = ::register_offhand_weapons_for_level_defaults_override; 
	
	level.zombie_anim_override = maps\template::anim_override_func;

	level thread maps\_callbacksetup::SetupCallbacks();
	
	level.quad_move_speed = 350;
	level.quad_traverse_death_fx = maps\zombie_theater_quad::quad_traverse_death_fx;
	level.quad_explode = true;

	level.dog_spawn_func = maps\_zombiemode_ai_dogs::dog_spawn_factory_logic;
	level.exit_level_func = ::template_exit_level;

	// Special zombie types, engineer and quads.
	level.custom_ai_type = [];
	level.custom_ai_type = array_add( level.custom_ai_type, maps\_zombiemode_ai_quad::init );
	level.custom_ai_type = array_add( level.custom_ai_type, maps\_zombiemode_ai_dogs::init );

	level.door_dialog_function = maps\_zombiemode::play_door_dialog;
	level.first_round_spawn_func = true;

	include_weapons();
	include_powerups();

	level.use_zombie_heroes = true;
	level.disable_protips = 1;

	// DO ACTUAL ZOMBIEMODE INIT
	precacheShader( "bo4_hitmarker_white" );
	precacheShader( "bo4_hitmarker_red" );
	maps\_zombiemode::main();
	//ZOMBIE_COUNTER_THREAD
	thread zombiesleft_hud();
	//WEAPON_GLOW_THREAD
	thread weapon_glow();
	//WEATHER_RAIN_THREAD
	thread weather_control();
	//TIMED_GAMEPLAY_THREAD
	thread maps\ccm_timed_gameplay::init();
	//END_GAME_THREAD
	level.end_game_round = false;
	end_game = GetEnt("end_game", "targetname");
	end_game thread end_game_battle();
	//IW_HUD_THREAD
	thread infinite_warfare_hud();
	// maps\_zombiemode_timer::init();

	// Turn off generic battlechatter - Steve G
	battlechatter_off("allies");
	battlechatter_off("axis");

	maps\_zombiemode_ai_dogs::enable_dog_rounds();

	init_template();
	
	// Setup the levels Zombie Zone Volumes
	maps\_compass::setupMiniMap("menu_map_template"); 
	level.ignore_spawner_func = ::template_ignore_spawner;

	level.zone_manager_init_func = ::template_zone_init;
	init_zones[0] = "test_zone";
	//init_zones[0] = "foyer_zone";
	//init_zones[1] = "foyer2_zone";	
	level thread maps\_zombiemode_zone_manager::manage_zones( init_zones );

	level thread maps\_zombiemode_auto_turret::init();

	init_sounds();
	level thread add_powerups_after_round_1();

	visionsetnaked( "template", 0 );

	//maps\zombie_theater_teleporter::teleport_pad_hide_use();

	//level.round_number = 1245;
}


#using_animtree( "generic_human" );
anim_override_func()
{
	level.scr_anim["zombie"]["walk7"] 	= %ai_zombie_walk_v8;	//goose step walk
}




//*****************************************************************************


theater_playanim( animname )
{
	self UseAnimTree(#animtree);
	self animscripted(animname + "_done", self.origin, self.angles, level.scr_anim[animname],"normal", undefined, 2.0  );
}


//*****************************************************************************
// WEAPON FUNCTIONS
//
// Include the weapons that are only in your level so that the cost/hints are accurate
// Also adds these weapons to the random treasure chest.
// Copy all include_weapon lines over to the level.csc file too - removing the weighting funcs...
//*****************************************************************************
include_weapons()
{
	//POWER_UP_MINIGUN
	include_weapon( "minigun_zm", false );
	include_weapon( "minigun_upgraded_zm", false );

	include_weapon( "frag_grenade_zm", false, true );
	include_weapon( "claymore_zm", false, true );

	//	Weapons - Pistols
	include_weapon( "m1911_zm", false );						// colt
	include_weapon( "m1911_upgraded_zm", false );
	include_weapon( "python_zm" );						// 357
	include_weapon( "python_upgraded_zm", false );
  	include_weapon( "cz75_zm" );
  	include_weapon( "cz75_upgraded_zm", false );

	//	Weapons - Semi-Auto Rifles
	include_weapon( "m14_zm", false, true );							// gewehr43
	include_weapon( "m14_upgraded_zm", false );

	//	Weapons - Burst Rifles
	include_weapon( "m16_zm", false, true );						
	include_weapon( "m16_gl_upgraded_zm", false );
	include_weapon( "g11_lps_zm" );
	include_weapon( "g11_lps_upgraded_zm", false );
	include_weapon( "famas_zm" );
	include_weapon( "famas_upgraded_zm", false );

	//	Weapons - SMGs
	include_weapon( "ak74u_zm", false, true );						// thompson, mp40, bar
	include_weapon( "ak74u_upgraded_zm", false );
	include_weapon( "mp5k_zm", false, true );
	include_weapon( "mp5k_upgraded_zm", false );
	include_weapon( "mp40_zm", false, true );
	include_weapon( "mp40_upgraded_zm", false );
	include_weapon( "mpl_zm", false, true );
	include_weapon( "mpl_upgraded_zm", false );
	include_weapon( "pm63_zm", false, true );
	include_weapon( "pm63_upgraded_zm", false );
	include_weapon( "spectre_zm" );
	include_weapon( "spectre_upgraded_zm", false );

	//	Weapons - Dual Wield
  	include_weapon( "cz75dw_zm" );
  	include_weapon( "cz75dw_upgraded_zm", false );

	//	Weapons - Shotguns
	include_weapon( "ithaca_zm", false, true );						// shotgun
	include_weapon( "ithaca_upgraded_zm", false );
	include_weapon( "rottweil72_zm", false, true );
	include_weapon( "rottweil72_upgraded_zm", false );
	include_weapon( "spas_zm" );						// 
	include_weapon( "spas_upgraded_zm", false );
	include_weapon( "hs10_zm" );
	include_weapon( "hs10_upgraded_zm", false );

	//	Weapons - Assault Rifles
	include_weapon( "aug_acog_zm" );
	include_weapon( "aug_acog_mk_upgraded_zm", false );
	include_weapon( "galil_zm" );
	include_weapon( "galil_upgraded_zm", false );
	include_weapon( "commando_zm" );
	include_weapon( "commando_upgraded_zm", false );
	include_weapon( "fnfal_zm" );
	include_weapon( "fnfal_upgraded_zm", false );

	//	Weapons - Sniper Rifles
	include_weapon( "dragunov_zm" );					// ptrs41
	include_weapon( "dragunov_upgraded_zm", false );
	include_weapon( "l96a1_zm" );
	include_weapon( "l96a1_upgraded_zm", false );

	//	Weapons - Machineguns
	include_weapon( "rpk_zm" );							// mg42, 30 cal, ppsh
	include_weapon( "rpk_upgraded_zm", false );
	include_weapon( "hk21_zm" );
	include_weapon( "hk21_upgraded_zm", false );

	//	Weapons - Misc
	include_weapon( "m72_law_zm" );
	include_weapon( "m72_law_upgraded_zm", false );
	include_weapon( "china_lake_zm" );
	include_weapon( "china_lake_upgraded_zm", false );

	//	Weapons - Special
	include_weapon( "zombie_cymbal_monkey" );
	include_weapon( "ray_gun_zm" );
	include_weapon( "ray_gun_upgraded_zm", false );

	include_weapon( "thundergun_zm", true );
	include_weapon( "thundergun_upgraded_zm", false );
	include_weapon( "crossbow_explosive_zm" );
	include_weapon( "crossbow_explosive_upgraded_zm", false );

	include_weapon( "knife_ballistic_zm", true );
	include_weapon( "knife_ballistic_upgraded_zm", false );
	include_weapon( "knife_ballistic_bowie_zm", false );
	include_weapon( "knife_ballistic_bowie_upgraded_zm", false );
	level._uses_retrievable_ballisitic_knives = true;

	// limited weapons
	maps\_zombiemode_weapons::add_limited_weapon( "m1911_zm", 0 );
	maps\_zombiemode_weapons::add_limited_weapon( "thundergun_zm", 1 );
	maps\_zombiemode_weapons::add_limited_weapon( "crossbow_explosive_zm", 1 );
	maps\_zombiemode_weapons::add_limited_weapon( "knife_ballistic_zm", 1 );

	precacheItem( "explosive_bolt_zm" );
	precacheItem( "explosive_bolt_upgraded_zm" );
}

//*****************************************************************************
// POWERUP FUNCTIONS
//*****************************************************************************

include_powerups()
{
	include_powerup( "nuke" );
	include_powerup( "insta_kill" );
	include_powerup( "double_points" );
	include_powerup( "full_ammo" );
	include_powerup( "carpenter" );
	include_powerup( "fire_sale" );
	//include_powerup( "minigun" );
}

add_powerups_after_round_1()
{
	
	//want to precache all the stuff for these powerups, but we don't want them to be available in the first round
	level.zombie_powerup_array = array_remove (level.zombie_powerup_array, "nuke"); 
	level.zombie_powerup_array = array_remove (level.zombie_powerup_array, "fire_sale");

	while (1)
	{
		if (level.round_number > 1)
		{
			level.zombie_powerup_array = array_add(level.zombie_powerup_array, "nuke");
			level.zombie_powerup_array = array_add(level.zombie_powerup_array, "fire_sale");
			break;
		}
		wait (1);
	}
}			

//*****************************************************************************

init_template()
{
	flag_init( "curtains_done" );
	flag_init( "lobby_occupied" );
	flag_init( "dining_occupied" );
	flag_init( "special_quad_round" );


	level thread electric_switch();		
	//INTRO_KINO_THREAD
	level thread teleporter_intro();
	//WEATHER_SNOW_THREAD
	level thread player_Snow();
	//INTRO_TYPEWRITER_THREAD
	level thread phil_typewriter_intro();
}

//*****************************************************************************
teleporter_intro()
{
	flag_wait( "all_players_spawned" );

	wait( 0.25 );

	players = get_players();
	for ( i = 0; i < players.size; i++ )
	{
		players[i] SetTransported( 2 );
	}
	
	playsoundatposition( "evt_beam_fx_2d", (0,0,0) );
    playsoundatposition( "evt_pad_cooldown_2d", (0,0,0) );
}
//INTRO_TYPEWRITER_FUNCTION
phil_typewriter_intro()
{
	text = [];
	text[text.size] = "INTRO_TEXT_1";
	text[text.size] = "INTRO_TEXT_2";
	text[text.size] = "INTRO_TEXT_3";

	intro_hud = [];
	for(i = 0;  i < text.size; i++)
	{
    	intro_hud[i] = create_simple_hud();
    	intro_hud[i].alignX = "left";
    	intro_hud[i].alignY = "bottom";
    	intro_hud[i].horzAlign = "left";
    	intro_hud[i].vertAlign = "bottom";
    	intro_hud[i].foreground = true;
    	intro_hud[i].sort = 100;

    	if ( level.splitscreen && !level.hidef )
    	{
        		intro_hud[i].fontScale = 2.75;
    	}
    	else
    	{
        		intro_hud[i].fontScale = 1.75;
    	}
    	intro_hud[i].alpha = 1;
    	intro_hud[i].color = (1, 1, 1);
    	intro_hud[i].y = -210 + 20 * i;
	}

	for(i = 0 ; i < text.size; i++)
	{
    	intro_hud[i].label = "";
    	for(k = 0; k <= text[i].size; k++)
    	{
        		intro_hud[i].label = GetSubStr(text[i], 0, k);
        		PlaySoundAtPosition("typewriter", (0, 0, 0));
        		wait(0.1);
    	}
    	wait(1.5);
	}
	wait(1.5);
	for(i = 0 ; i < text.size; i++)
	{
    	intro_hud[i] FadeOverTime( 3.5 ); 
    	intro_hud[i].alpha = 0;
    	wait(1.5);
	}    
	wait(2);
	for(i = 0 ; i < text.size; i++)
	{
    	intro_hud[i] destroy_hud();
	}
}
//*****************************************************************************
// ELECTRIC SWITCH
// once this is used, it activates other objects in the map
// and makes them available to use
//*****************************************************************************
electric_switch()
{
	trig = getent("use_elec_switch","targetname");
	trig sethintstring(&"ZOMBIE_ELECTRIC_SWITCH");
	trig setcursorhint( "HINT_NOICON" );


	level thread wait_for_power();

	trig waittill("trigger",user);

	trig delete();	
	flag_set( "power_on" );
	Objective_State(8,"done");

	//Enable quad zombie spawners
	reinit_zone_spawners();
}


//
//	Wait for the power_on flag to be set.  This is needed to work in conjunction with
//		the devgui cheat.
//
wait_for_power()
{
	master_switch = getent("elec_switch","targetname");	
	master_switch notsolid();

	flag_wait( "power_on" );

	master_switch rotateroll(-90,.3);
	master_switch playsound("zmb_switch_flip");

	clientnotify( "ZPO" );		// Zombie power on.

	master_switch waittill("rotatedone");
	playfx(level._effect["switch_sparks"] ,getstruct("elec_switch_fx","targetname").origin);
	
	//Sound - Shawn J  - adding temp sound to looping sparks & turning on power sources
	master_switch playsound("zmb_turn_on");

	//get the teleporter ready
	//maps\zombie_theater_teleporter::teleporter_init();	
	wait_network_frame();
	// Set Perk Machine Notifys
	level notify("revive_on");
	wait_network_frame();
	level notify("juggernog_on");
	wait_network_frame();
	level notify("sleight_on");
	wait_network_frame();
	level notify("doubletap_on");
	wait_network_frame();
	level notify("Pack_A_Punch_on" );	
	wait_network_frame();

	//SE2Dev - Enable additional perks
	level notify("marathon_on" );	
	wait_network_frame();
	level notify("divetonuke_on" );	
	wait_network_frame();
	level notify("deadshot_on" );	
	wait_network_frame();
	level notify("additionalprimaryweapon_on" );	
	wait_network_frame();

	// start quad round
	// Set number of quads per round
	players = get_players();
	level.quads_per_round = 4 * players.size;	// initial setting

	level notify("quad_round_can_end");
	level.delay_spawners = undefined;
	
	// DCS: start check for potential quad waves after power turns on.
	level thread quad_wave_init();
}

//AUDIO

init_sounds()
{
	maps\_zombiemode_utility::add_sound( "wooden_door", "zmb_door_wood_open" );
	maps\_zombiemode_utility::add_sound( "fence_door", "zmb_door_fence_open" );
}


// *****************************************************************************
// Zone management
// *****************************************************************************

template_zone_init()
{
	flag_init( "always_on" );
	flag_set( "always_on" );

	// foyer_zone
	add_adjacent_zone( "test_zone", "test_zone", "always_on" );	

	// theater_zone
	add_adjacent_zone( "test_zone", "zone1", "enter_zone1" );
	add_adjacent_zone( "zone1", "zone2", "enter_zone2" );
	add_adjacent_zone( "zone1", "zone3", "enter_zone3" );
}	

template_ignore_spawner( spawner )
{
	// no power, no quads
	if ( !flag("power_on") )
	{
		if ( spawner.script_noteworthy == "quad_zombie_spawner" )
		{
			return true;
		}
	}
	//DISABLED_NOVA_CRAWLERS
	if ( spawner.script_noteworthy == "quad_zombie_spawner" )
    {
        return true;
    }

	return false;
}

// *****************************************************************************
// 	DCS: random round change quad emphasis
// 	This should only happen in zones where quads spawn into
// 	and crawl down the wall.
//	potential zones: foyer_zone, theater_zone, stage_zone, dining_zone
// *****************************************************************************
quad_wave_init()
{
	level thread time_for_quad_wave("foyer_zone");
	level thread time_for_quad_wave("theater_zone");
	level thread time_for_quad_wave("stage_zone");
	level thread time_for_quad_wave("dining_zone");
	
	level waittill( "end_of_round" );
	flag_clear( "special_quad_round" );	
}

time_for_quad_wave(zone_name)
{

	if(!IsDefined(zone_name))
	{
		return;
	}
	zone = level.zones[ zone_name ];

	//	wait for round change.
	level waittill( "between_round_over" );
	
	//avoid dog rounds.
	if ( IsDefined( level.next_dog_round ) && level.next_dog_round == level.round_number )
	{
		level thread time_for_quad_wave(zone_name);			
		return;
	}	

	// ripped from spawn script for accuracy.	-------------------------------------
	max = level.zombie_vars["zombie_max_ai"];
	multiplier = level.round_number / 5;
	if( multiplier < 1 )
	{
		multiplier = 1;
	}

	if( level.round_number >= 10 )
	{
		multiplier *= level.round_number * 0.15;
	}

	player_num = get_players().size;

	if( player_num == 1 )
	{
		max += int( ( 0.5 * level.zombie_vars["zombie_ai_per_player"] ) * multiplier ); 
	}
	else
	{
		max += int( ( ( player_num - 1 ) * level.zombie_vars["zombie_ai_per_player"] ) * multiplier ); 
	}
	// ripped from spawn script for accuracy.	-------------------------------------

	//percent chance.
	chance = 100;
	max_zombies = [[ level.max_zombie_func ]]( max );
	current_round = level.round_number;
	
	// every third round a chance of a quad wave.
	if((level.round_number % 3 == 0) && chance >= RandomInt(100))
	{	
		if(zone.is_occupied)
		{
			flag_set( "special_quad_round" );
			maps\_zombiemode_zone_manager::reinit_zone_spawners();

			while( level.zombie_total < max_zombies /2 && current_round == level.round_number )
			{
				wait(0.1);
			}

			//level waittill( "end_of_round" );

			flag_clear( "special_quad_round" );
			maps\_zombiemode_zone_manager::reinit_zone_spawners();
			
		}
	}
	level thread time_for_quad_wave(zone_name);
}

template_exit_level()
{
	zombies = GetAiArray( "axis" );
	for ( i = 0; i < zombies.size; i++ )
	{
		zombies[i] thread template_find_exit_point();
	}
}

template_find_exit_point()
{
	self endon( "death" );

	player = getplayers()[0];

	dist_zombie = 0;
	dist_player = 0;
	dest = 0;

	away = VectorNormalize( self.origin - player.origin );
	endPos = self.origin + vector_scale( away, 600 );

	locs = array_randomize( level.enemy_dog_locations );

	for ( i = 0; i < locs.size; i++ )
	{
		dist_zombie = DistanceSquared( locs[i].origin, endPos );
		dist_player = DistanceSquared( locs[i].origin, player.origin );

		if ( dist_zombie < dist_player )
		{
			dest = i;
			break;
		}
	}

	self notify( "stop_find_flesh" );
	self notify( "zombie_acquire_enemy" );

	self setgoalpos( locs[dest].origin );

	while ( 1 )
	{
		if ( !flag( "wait_and_revive" ) )
		{
			break;
		}
		wait_network_frame();
	}
	
	self thread maps\_zombiemode_spawner::find_flesh();
}

precache_player_model_override()
{
	mptype\player_t5_zm_theater::precache();
}

give_player_model_override( entity_num )
{
	if( IsDefined( self.zm_random_char ) )
	{
		entity_num = self.zm_random_char;
	}

	switch( entity_num )
	{
		case 0:
			character\c_usa_dempsey_zt::main();// Dempsy
			//PLAYERS_MODEL_PRIMIS_0
			self DetachAll();
			self SetModel( "c_zom_tomb_dempsey_fb_LOD0" );
			//PLAYERS_MODEL_VICTIS_0
			self DetachAll();
			self SetModel( "c_zom_player_engineer_fb_LOD0" );
			//PLAYERS_MODEL_CIA_0
			self DetachAll();
			self SetModel( "c_zom_player_cia_fb" );
			//PLAYERS_MODEL_CDC_0
			self DetachAll();
			self SetModel( "c_zom_player_cdc_fb" );
			break;
		case 1:
			character\c_rus_nikolai_zt::main();// Nikolai
			//PLAYERS_MODEL_PRIMIS_1
			self DetachAll();
			self SetModel( "c_zom_tomb_nikolai_fb_LOD0" );
			//PLAYERS_MODEL_VICTIS_1
			self DetachAll();
			self SetModel( "c_zom_player_farmgirl_fb_LOD0" );
			//PLAYERS_MODEL_CIA_1
			self DetachAll();
			self SetModel( "c_zom_player_cia_fb" );
			//PLAYERS_MODEL_CDC_1
			self DetachAll();
			self SetModel( "c_zom_player_cdc_fb" );
			break;
		case 2:
			character\c_jap_takeo_zt::main();// Takeo
			//PLAYERS_MODEL_PRIMIS_2
			self DetachAll();
			self SetModel( "c_zom_tomb_takeo_fb_LOD0" );
			//PLAYERS_MODEL_VICTIS_2
			self DetachAll();
			self SetModel( "c_zom_player_oldman_fb_LOD0" );
			//PLAYERS_MODEL_CIA_2
			self DetachAll();
			self SetModel( "c_zom_player_cia_fb" );
			//PLAYERS_MODEL_CDC_2
			self DetachAll();
			self SetModel( "c_zom_player_cdc_fb" );
			break;
		case 3:
			character\c_ger_richtofen_zt::main();// Richtofen
			//PLAYERS_MODEL_PRIMIS_3
			self DetachAll();
			self SetModel( "c_zom_tomb_richtofen_fb_LOD0" );
			//PLAYERS_MODEL_VICTIS_3
			self DetachAll();
			self SetModel( "c_zom_player_reporter_dam_fb_LOD0" );
			//PLAYERS_MODEL_CIA_3
			self DetachAll();
			self SetModel( "c_zom_player_cia_fb" );
			//PLAYERS_MODEL_CDC_3
			self DetachAll();
			self SetModel( "c_zom_player_cdc_fb" );
			break;	
	}
}

player_set_viewmodel_override( entity_num )
{
	switch( self.entity_num )
	{
		case 0:
			// Dempsey
			self SetViewModel( "PLAYERS_VIEWHANDS_SETMODEL_0" );
			break;
		case 1:
			// Nikolai
			self SetViewModel( "PLAYERS_VIEWHANDS_SETMODEL_1" );
			break;
		case 2:
			// Takeo
			self SetViewModel( "PLAYERS_VIEWHANDS_SETMODEL_2" );
			break;
		case 3:
			// Richtofen
			self SetViewModel( "PLAYERS_VIEWHANDS_SETMODEL_3" );
			break;		
	}
}

register_offhand_weapons_for_level_defaults_override()
{
	register_lethal_grenade_for_level( "stielhandgranate" );
	level.zombie_lethal_grenade_player_init = "stielhandgranate";

	register_tactical_grenade_for_level( "zombie_cymbal_monkey" );
	level.zombie_tactical_grenade_player_init = undefined;

	register_placeable_mine_for_level( "mine_bouncing_betty" );
	level.zombie_placeable_mine_player_init = undefined;

	register_melee_weapon_for_level( "knife_zm" );
	level.zombie_melee_weapon_player_init = "knife_zm";
} 
 
//ZOMBIE_COUNTER_FUNCTION
zombiesleft_hud()
{   
	level endon( "stop_zombiesleft_hud" );

	level.HUDRemaining = create_simple_hud();
  	level.HUDRemaining.horzAlign = "center";
  	level.HUDRemaining.vertAlign = "middle";
   	level.HUDRemaining.alignX = "Left";
   	level.HUDRemaining.alignY = "middle";
   	level.HUDRemaining.y = 230;
   	level.HUDRemaining.x = 60;
   	level.HUDRemaining.foreground = 1;
   	level.HUDRemaining.fontscale = 8.0;
   	level.HUDRemaining.alpha = 1;
   	level.HUDRemaining.color = ZOMBIE_COUNTER_COLOR_COUNT;

   	level.HUDZombiesLeft = create_simple_hud();
   	level.HUDZombiesLeft.horzAlign = "center";
   	level.HUDZombiesLeft.vertAlign = "middle";
   	level.HUDZombiesLeft.alignX = "center";
   	level.HUDZombiesLeft.alignY = "middle";
   	level.HUDZombiesLeft.y = 230;
   	level.HUDZombiesLeft.x = -1;
   	level.HUDZombiesLeft.foreground = 1;
   	level.HUDZombiesLeft.fontscale = 8.0;
   	level.HUDZombiesLeft.alpha = 1;
   	level.HUDZombiesLeft.color = ZOMBIE_COUNTER_COLOR_TEXT;
   	level.HUDZombiesLeft SetText( "Zombies: " );

	while( 1 )
	{
		remainingZombies = get_enemy_count() + level.zombie_total;
		level.HUDRemaining SetValue(remainingZombies);

		if(remainingZombies == 0 )
		{
			level.HUDRemaining.alpha = 0; 
			while( 1 )
			{
				remainingZombies = get_enemy_count() + level.zombie_total;
				if(remainingZombies != 0 )
				{
					level.HUDRemaining.alpha = 1; 
					break;
				}
				wait 0.5;
			}
		}
		wait 0.5;
	}		
}

//WEAPON_GLOW_FUNCTION
weapon_glow()
{
	weaponslocations = GetEntArray( "weapon_upgrade", "targetname" );
	
	for(i = 0; i < weaponslocations.size; i++)
	{
		weaponslocations[i] thread fx_weapon();
	}
}

fx_weapon()
{
	self.tag_origin = spawn("script_model", self.origin);
	self.tag_origin setmodel("tag_origin");
	self.tag_origin.angles = self.angles;
	
	playfxontag(level._effect["wall_weapon_light"], self.tag_origin, "tag_origin");
}

//WEATHER_RAIN_FUNCTION
weather_control()
{
	flag_wait("all_players_connected");

	rainInit( "WEATHER_RAIN_INTENSITY" ); // get rain going
	level thread rainEffectChange( 9, 0.1 );  // tweak initial rain strength ... default is hard
	thread playerWeather(); // make the actual rain effect generate around the players

	level.thunder_sound_active = true; //disable or enable thunder sounds

	players = get_players();
	for(i = 0; i < players.size; i++)
	{
		players[i] thread watchRainSFX();
	}

	level.nextLightning = GetTime() + 1;
	thread lightning( ::lightning_normal, ::lightning_flash );
}

watchRainSFX()
{
    self endon("death");
    self endon("disconnect");
    
    self.isInside = false;
    self.isInsideLoop = false;
    self.isOutsideLoop = false;

    zones = GetEntArray("inside_rain", "targetname");

    while(1)
    {
        for(i = 0; i < zones.size; i++)
        {
            if(self IsTouching(zones[i]))
            {
                self.isInside = true;
                break;
            }
            else
            {
                self.isInside = false;
            }
        }
        
        if(self.isInside)
        {
            if(!self.isInsideLoop)
            {
                iprintln("Jugador isInSide");
                self.isInsideLoop = true;
                self.isOutsideLoop = false;
                self StopLoopSound();
                self PlayLoopSound("rain_inside");
            }
        }
        else
        {
            if(!self.isOutsideLoop)
            {
                iprintln("Jugador isOutSide");
                self.isOutsideLoop = true;
                self.isInsideLoop = false;
                self StopLoopSound();
                self PlayLoopSound("rain_outside");
            }
        }
        wait(0.1);
    }
}

lightning_normal()
{
    wait( 0.05 );
    ResetSunLight();
}

lightning_flash()
{
	SetSunLight( 4, 4, 4.5 );
	SetSunLight( 1, 1, 1.5 );

	wait( 0.0014 );  

	SetSunLight( 3, 3, 3.5 );
	SetSunLight( 2, 2, 2.5 );
	SetSunLight( 1.5, 1.5, 2 );

	wait( 0.0010 );

	SetSunLight( 1, 1, 1.5 );
	SetSunLight( 5, 5, 5.5 );

	wait( 0.0011 );

	SetSunLight( 4, 4, 4.5 );
	SetSunLight( 1, 1, 1.5 );

	wait( 0.0015 );

	SetSunLight( 2.5, 2.5, 3 ); 
}

//WEATHER_SNOW_FUNCTION
player_Snow()
{
    flag_wait("all_players_connected");

    players = get_players();
    array_thread( players, ::_player_Snow );
}

_player_Snow()
{
    self endon("death");
    self endon("disconnect");

    for (;;)
    {
        playfx ( level._effect["snow_thick"], self.origin + (-90,90,0));
        wait (0.2);
    }
}

//END_GAME_FUNCTION
end_game_battle()
{
	cost = END_GAME_COST;
	self sethintstring( "Press ^3[{+activate}]^7 to End Game [Cost: " + cost + "]" );
	self setCursorHint( "HINT_NOICON" ); 
	self UseTriggerRequireLookAt();

	while( IsDefined( self ) )
	{
		self waittill("trigger", player );

		if( !is_player_valid( player ) )
		{
			player thread ignore_triggers( 0.5 );
			continue;
		}

		if( player.score < cost )
		{
			player play_sound_on_ent( "no_purchase" );
			player maps\_zombiemode_audio::create_and_play_dialog( "general", "no_money", undefined, 1 );
			continue;
		}

		player maps\_zombiemode_score::minus_to_player_score( cost );

		self Delete();

		players = get_players(); 
		for(i = 0; i < players.size; i++)
		{
			if( !players[i].isInvulnerability )
			{
				players[i] EnableInvulnerability();
				players[i].isInvulnerability = true;
			}
		}

		level.end_game_round = true;
		level notify("end_game");
	}
}

//IW_HUD_FUNCTION
infinite_warfare_hud()
{
	flag_wait( "all_players_connected" );

	wait 1;

	players = getplayers();
	for ( i = 0; i < players.size; i++ )
	{
		players[i] thread create_infinite_warfare_hud();
	}
}

create_infinite_warfare_hud()
{
	hud = create_simple_hud(self);
    hud.foreground = true;
    hud.hidewheninmenu = true;
    hud.y = -5;
    hud.x = 5;
    hud.alignX = "left";
    hud.alignY = "bottom";
    hud.horzAlign = "user_left";
    hud.vertAlign = "user_bottom";

    player_shader = "IW_HUD_MAIN_1";
    if( self.entity_num == 1 )
    	player_shader = "IW_HUD_MAIN_2";
    else if( self.entity_num == 2 )
    	player_shader = "IW_HUD_MAIN_3";
    else if( self.entity_num == 3 )
    	player_shader = "IW_HUD_MAIN_4";
    
    hud.alpha = 0;
    hud SetShader( player_shader, 64, 90 );

	wait( 0.7 );

	hud FadeOverTime( 0.5 );
	hud.alpha = 1;

	level waittill( "end_game" );

	hud Destroy();
}