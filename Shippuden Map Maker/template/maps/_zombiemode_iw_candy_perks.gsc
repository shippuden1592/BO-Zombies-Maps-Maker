//================================================================================================
// Nombre del Archivo 	: _zombiemode_iw_candy_perks.gsc
// Version				: 1.1
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

	// Candy Perks
	PrecacheItem( "zombie_candy_perk" );

	set_zombie_var( "zombie_candy_limit",							11 ); // Limit Candy
	set_zombie_var( "zombie_candy_give_all",							false ); // All Candy Perks
	set_zombie_var( "zombie_perk_juggernaut_health",	250 );
	set_zombie_var( "zombie_player_health",				150 );

	set_zombie_var( "use_bang_bangs",					CANDY_ENABLE_BANG_BANGS );
	set_zombie_var( "use_tuff_nuff",					CANDY_ENABLE_TUFF_NUFF );
	set_zombie_var( "use_up_atoms",					CANDY_ENABLE_UP_ATOMS );
	set_zombie_var( "use_quickies",					CANDY_ENABLE_QUICKIES );

	set_zombie_var( "use_blue_bolts",				CANDY_ENABLE_BOLTS );				// Use Blue Bolts
	set_zombie_var( "use_slappy_taffy",					CANDY_ENABLE_SLAPPY );				// Use Slappy Taffy
	set_zombie_var( "use_change_chews",					CANDY_ENABLE_CHANGE_CHEWS );				// Use Change Chews
	
	// Blue Bolts
	set_zombie_var( "blue_bolts_laststand_radius",		500 );
	set_zombie_var( "blue_bolts_laststand_damage",		1000 );
	set_zombie_var( "blue_bolts_laststand_zombie_limit",		10 );
	set_zombie_var( "blue_bolts_points",		 	40 );
	
	// Change Chews
	set_zombie_var( "change_chews_shots_max",		15 ); // Default 15
	set_zombie_var( "change_chews_shots_min",		10 ); // Default 10
	set_zombie_var( "change_chews_radius",		120 );
	set_zombie_var( "change_chews_zombies_max",		3 );
	set_zombie_var( "change_chews_damage",		1500 );
	set_zombie_var( "change_chews_chance",		35 );
	set_zombie_var( "change_chews_points",		50 );

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

	if( level.zombie_vars[ "use_bang_bangs" ] )
		candy_add_perk( "specialty_rof", 2000, "iw_vending_bangs_on", "vending_doubletap", "specialty_iw_bang_bangs", "doubletap_light", "Bang Bangs", 0, "mus_perks_doubletap_sting" );
	
	if( level.zombie_vars[ "use_tuff_nuff" ] )
		candy_add_perk( "specialty_armorvest", 2500, "iw_vending_tuff_on", "vending_jugg", "specialty_iw_tuff_nuff", "jugger_light", "Tuff Nuff", 1, "mus_perks_jugganog_sting" );
	
	if( level.zombie_vars[ "use_up_atoms" ] )
		candy_add_perk( "specialty_quickrevive", 1500, "iw_vending_atoms_on", "vending_revive", "specialty_iw_up_atoms", "revive_light", "Up N Atoms", 2, "mus_perks_revive_sting" );
	
	if( level.zombie_vars[ "use_quickies" ] )
		candy_add_perk( "specialty_fastreload", 3000, "iw_vending_quickies_on", "vending_sleight", "specialty_iw_quickies", "sleight_light", "Quickies", 3, "mus_perks_speed_sting" );

	if ( is_true( level.zombiemode_using_marathon_perk ) )
	{
		level._effect["marathon_light"]			= loadfx("maps/zombie/fx_zmb_cola_staminup_on");
		candy_add_perk( "specialty_longersprint", 2000, "iw_vending_racin_on", "vending_marathon", "specialty_iw_racin_stripes", "marathon_light", "Racin Stripes", 4, "mus_perks_stamin_sting" );
	}
	
	if ( is_true( level.zombiemode_using_divetonuke_perk ) )
	{
		level.zombiemode_divetonuke_perk_func = maps\_zombiemode_perks::divetonuke_explode;
		level._effect["divetonuke_groundhit"] = loadfx("maps/zombie/fx_zmb_phdflopper_exp");

		set_zombie_var( "zombie_perk_divetonuke_radius", 300 );
		set_zombie_var( "zombie_perk_divetonuke_min_damage", 1000 );
		set_zombie_var( "zombie_perk_divetonuke_max_damage", 5000 );

		candy_add_perk( "specialty_flakjacket", 1500, "iw_vending_stoppers_on", "vending_divetonuke", "specialty_iw_bombstoppers", "doubletap_light", "Bombstoppers", 5, "mus_perks_phd_sting" );
	}
	
	if( is_true( level.zombiemode_using_deadshot_perk ) )
	{
		candy_add_perk( "specialty_deadshot", 1500, "iw_vending_deadeye_on", "vending_deadshot", "specialty_iw_deadeye_dewdrops", "doubletap_light", "Deadeye Dewdrops", 6, "mus_perks_deadshot_sting" );
	}
	
	if ( is_true( level.zombiemode_using_additionalprimaryweapon_perk ) )
	{
		PrecacheShader( "specialty_iw_mule_munchies_glow" );

		level._effect["additionalprimaryweapon_light"] = loadfx("misc/fx_zombie_cola_arsenal_on");
		candy_add_perk( "specialty_additionalprimaryweapon", 2000, "iw_vending_mule_on", "vending_additionalprimaryweapon", "specialty_iw_mule_munchies", "additionalprimaryweapon_light", "Mule Munchies", 7, "mus_perks_mulekick_sting" );
	}

	// Blue Bolts
	if( level.zombie_vars[ "use_blue_bolts" ] )
	{
		level._effect[ "tesla_shock" ]			= loadfx( "IW/fx_blue_bolts_tesla_shock" );
		level._effect[ "tesla_shock_secondary" ]	= loadfx( "IW/fx_blue_bolts_tesla_shock_secondary" );

		level._effect[ "blue_bolts_explode" ] 			= loadfx( "IW/fx_blue_bolts_shock_death" );
		level._effect[ "blue_bolts_reload_small" ] 			= loadfx( "IW/fx_blue_bolts_shock_small" );
		level._effect[ "blue_bolts_reload_medium" ] 			= loadfx( "IW/fx_blue_bolts_shock_medium" );
		level._effect[ "blue_bolts_reload_large" ] 			= loadfx( "IW/fx_blue_bolts_shock_large" );

		candy_add_perk( "specialty_bulletaccuracy", 1500, "iw_vending_bolts_on", "vending_cherry", "specialty_iw_blue_bolts", "revive_light", "Blue Bolts", 8, "mus_perks_blue_bolts_sting" );
	}

	// Slappy Taffy
	if( level.zombie_vars[ "use_slappy_taffy" ] )
	{
		candy_add_perk( "specialty_bulletdamage", 2000, "iw_vending_slappy_on", "vending_vultureaid", "specialty_iw_slappy_taffy", "jugger_light", "Slappy Taffy", 9, "mus_perks_slappy_taffy_sting" );
	}

	// Change Chews
	if( level.zombie_vars[ "use_change_chews" ] )
	{
		PrecacheShader( "specialty_iw_change_chews_expl" );
		PrecacheShader( "specialty_iw_change_chews_flame" );
		PrecacheShader( "specialty_iw_change_chews_ice" );
		PrecacheShader( "specialty_iw_change_chews_shock" );

		level._effect[ "change_chews_flame_explode" ] 		= loadfx( "explosions/fx_grenade_flash");
		level._effect[ "change_chews_expl_explode" ] 		= loadfx( "IW/fx_change_chews_explo");
		level._effect[ "change_chews_ice_explode" ] 		= loadfx( "IW/fx_change_chews_ice");
		level._effect[ "change_chews_shatter" ]				= LoadFX( "IW/fx_change_chews_shatter" );

		if( !isDefined( level._zombie_ice_death ) )
			level._zombie_ice_death = [];

		level._zombie_ice_death["zombie"] = [];	
		level._zombie_ice_death["zombie"][0] = %ai_zombie_death_icestaff_a;
		level._zombie_ice_death["zombie"][1] = %ai_zombie_death_icestaff_b;
		level._zombie_ice_death["zombie"][2] = %ai_zombie_death_icestaff_c;
		level._zombie_ice_death["zombie"][3] = %ai_zombie_death_icestaff_d;
		level._zombie_ice_death["zombie"][4] = %ai_zombie_death_icestaff_e;

		level._zombie_ice_death["quad_zombie"] = [];
		level._zombie_ice_death["quad_zombie"][0] = %ai_zombie_quad_freeze_death_a;
		level._zombie_ice_death["quad_zombie"][1] = %ai_zombie_quad_freeze_death_a;

		if( !isDefined( level._zombie_ice_death_missing_legs ) )
			level._zombie_ice_death_missing_legs = [];

		level._zombie_ice_death_missing_legs["zombie"] = [];
		level._zombie_ice_death_missing_legs["zombie"][0] = %ai_zombie_crawl_freeze_death_01;
		level._zombie_ice_death_missing_legs["zombie"][1] = %ai_zombie_crawl_freeze_death_02;

		level._zombie_ice_death_missing_legs["quad_zombie"] = [];
		level._zombie_ice_death_missing_legs["quad_zombie"][0] = %ai_zombie_crawl_freeze_death_01;
		level._zombie_ice_death_missing_legs["quad_zombie"][1] = %ai_zombie_crawl_freeze_death_02;

		if( !isDefined( level._zombie_staff_fire_death ) )
			level._zombie_staff_fire_death = [];

		level._zombie_staff_fire_death["zombie"] = [];	
		level._zombie_staff_fire_death["zombie"][0] = %ai_zombie_firestaff_death_walking_a;
		level._zombie_staff_fire_death["zombie"][1] = %ai_zombie_firestaff_death_walking_b;
		level._zombie_staff_fire_death["zombie"][2] = %ai_zombie_firestaff_death_walking_c;

		if( !isDefined( level._zombie_staff_fire_collapse ) )
			level._zombie_staff_fire_collapse = [];

		level._zombie_staff_fire_collapse["zombie"] = [];	
		level._zombie_staff_fire_collapse["zombie"][0] = %ai_zombie_firestaff_death_collapse_a;
		level._zombie_staff_fire_collapse["zombie"][1] = %ai_zombie_firestaff_death_collapse_b;

		candy_add_perk( "specialty_extraammo", 1500, "iw_vending_chew_on", "vending_widowswine", "specialty_iw_change_chews", "deadshot_light", "Change Chews", 10, "mus_perks_change_chews_sting" );
	}

	array_thread( vending_triggers, ::vending_trigger_think );
	array_thread( vending_triggers, maps\_zombiemode_perks::electric_perks_dialog );
	array_thread( GetEntArray( "audio_bump_trigger", "targetname"), ::thread_bump_trigger);
	level thread setup_player_abilities();
}

candy_add_perk( perk_name, perk_cost, perk_model_on, perk_model_targetname, perk_shader, perk_light, perk_hint, perk_bottle, perk_sting )
{
	if ( isDefined ( level.zombie_perks[ perk_name ] ) )
		return;

	PrecacheModel( perk_model_on );
	PrecacheShader( perk_shader );

	struct = SpawnStruct();
	struct.perk_name = perk_name;
	struct.perk_model_on = perk_model_on;
	struct.perk_model_targetname = perk_model_targetname;
	struct.perk_shader = perk_shader;
	struct.perk_light = perk_light;
	struct.perk_bottle = perk_bottle;
	struct.perk_sting = perk_sting;
	struct.perk_hint = "Hold ^3[{+activate}]^7 to purchase the " + perk_hint + " [Cost: ^3" + perk_cost + "^7]";
	struct.perk_cost = perk_cost;

	level.wunderfizz_perks[ level.wunderfizz_perks.size ] = perk_name;
	level.zombie_perks[ perk_name ] = struct;
}

candy_activate_machine( perk, solo_game )
{
	machine = getentarray( level.zombie_perks[ perk ].perk_model_targetname, "targetname" );

	if( perk == "specialty_quickrevive" && solo_game )
	{
		for( i = 0; i < machine.size; i++ )
		{
			machine_clip = GetEnt( machine[i].target, "targetname" );
			machine[i] SetModel( level.zombie_perks[ perk ].perk_model_on );
			machine[i] thread maps\_zombiemode_perks::revive_solo_fx( machine_clip );
		}
	}

	if( !solo_game )
	{
		//flag_wait( "power_on" ); // Need Power
		level waittill("juggernog_on"); //Jugg for all

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
			level.zombie_perks[ perk ].perk_hint = "Hold ^3[{+activate}]^7 to purchase the Up N Atoms [Cost: ^3500^7]";
		}
	}

	//Turn ON
	if( IsDefined( level.zombie_perks[ perk ] ) )
	{
		level thread candy_activate_machine( perk, solo );
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

	self thread maps\_zombiemode_audio::perks_a_cola_jingle_timer();

	perk_hum = spawn("script_origin", self.origin);
	perk_hum playloopsound("zmb_perks_machine_loop");

	self thread maps\_zombiemode_perks::check_player_has_perk( perk );
	
	self SetHintString( level.zombie_perks[ perk ].perk_hint );

	for( ;; )
	{
		self waittill( "trigger", player );

		index = maps\_zombiemode_weapons::get_player_index(player);
		
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

		if ( player.num_perks >= level.zombie_vars["zombie_candy_limit"] )
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
	self GiveWeapon( "zombie_candy_perk", level.zombie_perks[ perk ].perk_bottle );
	self SwitchToWeapon( "zombie_candy_perk" );

	return gun;
}

perk_give_bottle_end( gun, perk )
{
	assert( gun != "zombie_candy_perk" );
	assert( gun != "syrette_sp" );

	self AllowLean( true );
	self AllowAds( true );
	self AllowSprint( true );
	self AllowProne( true );		
	self AllowMelee( true );

	weapon = "zombie_candy_perk";

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

		case "specialty_bulletaccuracy":			// !!=====!! Blue Bolts
			self thread blue_bolts_function();
			self thread blue_bolts_laststand();
		break;

		case "specialty_extraammo":					// !!=====!! Change Chews
			all_effects = [];
			all_effects[0] = "shock";
			all_effects[1] = "flame";
			all_effects[2] = "expl";
			all_effects[3] = "ice";

			self.change_chews_shoots = randomintrange(level.zombie_vars[ "change_chews_shots_min" ], level.zombie_vars[ "change_chews_shots_max" ]);
			self.change_chews_type = all_effects[RandomInt(all_effects.size)];

			//IPrintLn( "Ammo: " + self.change_chews_type );
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
    hud.alignX = "center"; 
    hud.alignY = "bottom";
    hud.horzAlign = "center"; 
    hud.vertAlign = "bottom";
    hud.x = 0; //self.perk_hud.size * 30; 
    hud.y = hud.y - 20;
    hud.alpha = 0;
    hud fadeOverTime(0.6);
    hud.alpha = 1;

    if( perk == "specialty_extraammo" && (IsDefined( self.change_chews_type ) && self.change_chews_type != "" ))
    {
    	perk_shader = "specialty_iw_change_chews_" + self.change_chews_type;
    	hud SetShader( perk_shader, 26, 24 );
    }
    else
    {
    	hud SetShader( level.zombie_perks[ perk ].perk_shader, 26, 24 );
    }

    hud scaleOverTime( 0.6, 26, 24 );

    self.perk_hud[ perk ] = hud;

    x_start = -1 * ((self.perk_hud.size * 28) / 2);

    keys = GetArrayKeys( self.perk_hud );

    for( i = 0; i < keys.size; i++ )
    {
        self.perk_hud[keys[i]].x = x_start;
        x_start += 28;
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
				self maps\_zombiemode::take_additionalprimaryweapon();
			}
			break;
		
		case "specialty_deadshot":
			self ClearClientFlag(level._ZOMBIE_PLAYER_FLAG_DEADSHOT_PERK);
			break;

		case "specialty_bulletaccuracy":
			self notify("stop_blue_bolts_reload_attack");
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
// !|=====|! Bombstoppers
// !\=====/!

player_grenade_weapon_watcher()
{

}

bombstoppers_grenade_spawn( grenade, weaponName )
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

		self.cluster1 = self magicGrenadeType( weaponName, model.origin, ( 0, 75, 300 ), 3 );
		self.cluster2 = self magicGrenadeType( weaponName, model.origin, ( 0, -75, 300 ), 3 );
		self.cluster3 = self magicGrenadeType( weaponName, model.origin, ( 75, 0, 300 ), 3 );
		self.cluster4 = self magicGrenadeType( weaponName, model.origin, ( -75, 0, 300 ), 3 );

		model Delete();
	}
}

// !/=====\!
// !|=====|! Mule Munchies
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
					self.perk_hud["specialty_additionalprimaryweapon"] setShader("specialty_iw_mule_munchies_glow", 26, 24);
				}
				else
				{
					self.perk_hud["specialty_additionalprimaryweapon"] setShader("specialty_iw_mule_munchies", 26, 24);
				}
			}
		}
	}
}

// !/=====\!
// !|=====|! Blue Bolts
// !\=====/!

blue_bolts_laststand()
{
	self waittill( "stop_blue_bolts_reload_attack" );

	self thread blue_bolts_do_damage(1, level.zombie_vars[ "blue_bolts_laststand_radius" ], level.zombie_vars[ "blue_bolts_laststand_damage" ], level.zombie_vars[ "blue_bolts_laststand_zombie_limit" ], true, false);
}

blue_bolts_function()
{
	self endon( "disconnect" );
	self endon( "stop_blue_bolts_reload_attack" );

	self.wait_on_reload = [];
	self.consecutive_blue_bolts_attacks = 0;

	while( 1 )
	{
		self waittill("reload_start");
		str_current_weapon = self GetCurrentWeapon();

		if( is_in_array(self.wait_on_reload, str_current_weapon) )
		{
			continue;
		}

		self.wait_on_reload[ self.wait_on_reload.size ] = str_current_weapon;
		self.consecutive_blue_bolts_attacks++;
		n_clip_current = self GetWeaponAmmoClip(str_current_weapon);
		n_clip_max = WeaponClipSize(str_current_weapon);
		n_fraction = n_clip_current / n_clip_max;
		perk_radius = linear_map(n_fraction, 1, 0, 32, 128);
		perk_dmg = linear_map(n_fraction, 1, 0, 1, 1045);
		self thread check_for_reload_complete(str_current_weapon);

		switch(self.consecutive_blue_bolts_attacks)
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

		self thread blue_bolts_cooldown_timer(str_current_weapon);
		self thread blue_bolts_do_damage(n_fraction, perk_radius, perk_dmg, n_zombie_limit, undefined, false);
	}
}

blue_bolts_cooldown_timer( str_current_weapon )
{
	self notify("blue_bolts_cooldown_started");
	self endon("blue_bolts_cooldown_started");
	self endon("disconnect");

	n_reload_time = WeaponReloadTime( str_current_weapon );

	if( self HasPerk("specialty_fastreload") )
	{
		n_reload_time *= GetDvarFloat("perk_weapReloadMultiplier");
	}

	wait n_reload_time + 3;
	self.consecutive_blue_bolts_attacks = 0;
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

blue_bolts_do_damage( fraction, radius, damage, zombie_limit, laststand_effect, no_player )
{
	if( IsDefined( zombie_limit ) && zombie_limit <= 0 )
		return;

	if( !is_true( no_player ) )
	{
		self thread blue_bolts_reload_fx(fraction, laststand_effect);
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
				a_zombies[i] thread blue_bolts_shock_or_death_fx( "tesla_death_fx", "tesla_shock_secondary" );
				self maps\_zombiemode_score::add_to_player_score( add_points( level.zombie_vars[ "blue_bolts_points" ] ) );
			}
			else
			{
				a_zombies[i] thread blue_bolts_stun();
				a_zombies[i] thread blue_bolts_shock_or_death_fx( "tesla_shock_fx", "tesla_shock" );
			}

			wait(0.1);

			a_zombies[i] dodamage(damage, self.origin, self, self);
		}
	}
}

blue_bolts_shock_or_death_fx( fx_type, fx_name )
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

blue_bolts_stun()
{
	if ( self.ignoreall == false && self.health >= 0 && self.animname == "zombie" )
	{
		if( self.has_legs )
			self animscripted("blue_bolts_hit", self.origin, self.angles, random(level._zombie_tesla_death[self.animname]));
		else
			self animScripted("blue_bolts_hit_crawl", self.origin, self.angles, random(level._zombie_tesla_crawl_death["zombie"]));
	}
}

blue_bolts_reload_fx(fraction, laststand_effect)
{
	if( is_true( laststand_effect ) )
	{
		shock_fx = "blue_bolts_explode";
	}
	else if(fraction >= 0.67)
	{
		shock_fx = "blue_bolts_reload_small";
	}
	else if(fraction >= 0.33 && fraction < 0.67)
	{
		shock_fx = "blue_bolts_reload_medium";
	}
	else
	{
		shock_fx = "blue_bolts_reload_large";
	}

	tag_origin_blue_bolts = spawn("script_model", self.origin + ( 0, 0, 10 ) );
	tag_origin_blue_bolts setmodel("tag_origin");
	tag_origin_blue_bolts linkTo( self, "tag_origin", ( 0, 0, 0 ), ( 270, 0, 0 ) );

	PlayFxOnTag( level._effect[ shock_fx ], tag_origin_blue_bolts, "tag_origin" );

	wait 1.5;

	tag_origin_blue_bolts unlink();
	tag_origin_blue_bolts delete();
}

// !/=====\!
// !|=====|! Slappy Taffy & Change Chews
// !\=====/! 

perks_zombie_hit_effect(amount, attacker, point, mod)
{
	if( !isDefined(attacker) || !isAlive( self ) || !isPlayer( attacker ) )
	{
		return;
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

	//Slappy Taffy Melee
	if ( attacker hasPerk( "specialty_bulletdamage" ) && mod == "MOD_MELEE" )
	{
		if ( !Is_Boss( self ) )
		{
			self DoDamage( self.health + 115, point, attacker, mod );
		}
	}

	//Change Chews
	if ( attacker hasPerk( "specialty_extraammo" ) && mod != "MOD_MELEE" && !exclude_weapons(attacker.damageweapon) && Distance(point, self GetTagOrigin( "j_head" )) < 15 )
	{
		if ( self.animname == "zombie" && randomint( 100 ) < level.zombie_vars[ "change_chews_chance" ] )
		{
			attacker player_change_effect();

			switch( attacker.change_chews_type )
			{
				case "shock":
					self thread zombie_effect_electrocuted( attacker );
					break;
				case "flame":
					PlayFx(level._effect["change_chews_flame_explode"], self getTagOrigin("tag_origin"));
					self thread zombie_effect_burned( attacker );
					break;
				case "expl":
					PlayFx(level._effect["change_chews_expl_explode"], self getTagOrigin("tag_origin"));
					self thread zombie_effect_exploited( attacker );
					break;
				case "ice":
					PlayFx(level._effect["change_chews_ice_explode"], self getTagOrigin("tag_origin"));
					self thread zombie_effect_frozen( attacker );
					break;
				default:
					break;
			}
		}
	}
}

player_change_effect()
{
	self.change_chews_shoots--;
	if( self.change_chews_shoots > 0 )
	{
		return;
	}

	all_effects = [];
	all_effects[0] = "shock";
	all_effects[1] = "flame";
	all_effects[2] = "expl";
	all_effects[3] = "ice";

	all_effects_random = [];
	for(i = 0; i < all_effects.size; i++)
	{
		if( self.change_chews_type != all_effects[i] )
			all_effects_random[all_effects_random.size] = all_effects[i];
	}
	all_effects = array_randomize(all_effects_random);
	self.change_chews_shoots = randomintrange(level.zombie_vars[ "change_chews_shots_min" ], level.zombie_vars[ "change_chews_shots_max" ]);
	self.change_chews_type = random(all_effects);

	//iprintln( "Change: " + self.change_chews_type);

	perk_shader = "specialty_iw_change_chews_" + self.change_chews_type;
	self.perk_hud[ "specialty_extraammo" ] SetShader( perk_shader, 26, 24 );
}

zombie_effect_electrocuted( player )
{
	self thread blue_bolts_shock_or_death_fx( "tesla_death_fx", "tesla_shock_secondary" );
	self dodamage( self.health + 115, self.origin, player );
	
	player notify("zom_kill");
	player maps\_zombiemode_score::add_to_player_score( add_points( level.zombie_vars[ "change_chews_points" ] ) );
	player thread blue_bolts_do_damage(1, level.zombie_vars[ "change_chews_radius" ], level.zombie_vars[ "change_chews_damage" ], level.zombie_vars[ "change_chews_zombies_max" ], undefined, true);
}

zombie_effect_burned( player )
{
	zombies = get_array_of_closest(self.origin, get_round_enemy_array(), undefined, undefined, level.zombie_vars[ "change_chews_radius" ]);
	
	self magic_bullet_shield();
	self thread zombie_burned_playanim( player );

	for(i = 0; i < zombies.size; i++)
	{
		if ( Is_Boss( zombies[i] ) || is_magic_bullet_shield_enabled( zombies[i] ) || zombies[i].isdog )
			continue;

		if( i < level.zombie_vars[ "change_chews_zombies_max" ] && (zombies[i].health - level.zombie_vars[ "change_chews_damage" ]) < 0)
		{
			zombies[i] magic_bullet_shield();
			zombies[i] thread zombie_burned_playanim();
		}
	}
}

zombie_burned_playanim( player )
{
	self playlocalsound( "zmb_ignite" );
	self thread animscripts\zombie_death::flame_death_fx();

	if( self.has_legs && self.animname == "zombie" )
	{
		self.deathanim = random( level._zombie_staff_fire_collapse["zombie"] );
		self useanimtree(#animtree);
 		self animscripted("zombie_burned", self.origin,self.angles, random( level._zombie_staff_fire_death["zombie"] ));
 		self waittill( "zombie_burned" );
	}

	self stop_magic_bullet_shield();
 	self dodamage( self.health + 115, self.origin, player );

 	if( IsDefined( player ) )
 	{
 		player notify("zom_kill");
		player maps\_zombiemode_score::add_to_player_score( add_points( level.zombie_vars[ "change_chews_points" ] ) );
 	}
}

zombie_effect_exploited( player )
{
	zombies = get_array_of_closest(self.origin, get_round_enemy_array(), undefined, undefined, level.zombie_vars[ "change_chews_radius" ]);
	
	PlayFx(level._effect["dog_gib"], self.origin);
	playsoundatposition("wpn_grenade_explode", self.origin);
	self DoDamage( self.health + 115, self.origin, player );
	self delete();

	player notify("zom_kill");
	player maps\_zombiemode_score::add_to_player_score( add_points( level.zombie_vars[ "change_chews_points" ] ) );

	for(i = 0; i < zombies.size; i++)
	{
		if ( Is_Boss( zombies[i] ) || is_magic_bullet_shield_enabled( zombies[i] ) || zombies[i].isdog )
			continue;

		if( i < level.zombie_vars[ "change_chews_zombies_max" ] && (zombies[i].health - level.zombie_vars[ "change_chews_damage" ]) < 0)
		{
			zombies[i] thread zombie_fling( player );
		}
	}
}

zombie_fling( player )
{
	Angles = player.angles;
	Angles += (RandomFloatRange(-30, -20), RandomFloatRange(-5, 5), 0);
	launchDir = AnglesToForward(Angles);
	launchForce = RandomFloatRange(350, 400);
	
	self StartRagdoll();
	self launchragdoll(launchDir * launchForce);
	self dodamage(self.health + 115, self.origin, player );
}

zombie_effect_frozen( player )
{
	zombies = get_array_of_closest(self.origin, get_round_enemy_array(), undefined, undefined, level.zombie_vars[ "change_chews_radius" ]);
	
	self magic_bullet_shield();
	self thread zombie_frozen_playanim();
	self thread zombie_frozen( player );

	for(i = 0; i < zombies.size; i++)
	{
		if ( Is_Boss( zombies[i] ) || is_magic_bullet_shield_enabled( zombies[i] ) || zombies[i].isdog )
			continue;

		if( i < level.zombie_vars[ "change_chews_zombies_max" ] && (zombies[i].health - level.zombie_vars[ "change_chews_damage" ]) < 0)
		{
			zombies[i] magic_bullet_shield();
			zombies[i] thread zombie_frozen_playanim();
			zombies[i] thread zombie_frozen();
		}
	}
}

zombie_frozen_playanim()
{
	animname = undefined;

	if(self.has_legs)
		animname = random( level._zombie_ice_death[self.animname] );
	else
		animname = random( level._zombie_ice_death_missing_legs[self.animname] );

	self useanimtree(#animtree);
 	self animscripted("zombie_frozen", self.origin,self.angles, animname);
 	self PlaySound( "wpn_freezegun_freeze_zombie" ); 

 	self waittill( "zombie_frozen" );

 	self stop_magic_bullet_shield();
 	self dodamage( self.health + 115, self.origin );
}

zombie_frozen( player )
{
	self waittill( "death" );

	self PlaySound( "wpn_freezegun_shatter_zombie" );
	PlayFx(level._effect["change_chews_shatter"], self getTagOrigin("tag_origin"));
	self delete();

	if( IsDefined( player ) )
	{
		player notify("zom_kill");
		player maps\_zombiemode_score::add_to_player_score( add_points( level.zombie_vars[ "change_chews_points" ] ) );
	}
}

exclude_weapons( weap )
{
	res = undefined;
	switch( weap )
	{
		case "iw_axe":
			res = true;
			break;
		default:
			res = false;
			break;
	}
	return res;
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

player_reset_abilities()
{
	self SetClientDvar("perk_weapRateEnhanced", "1");
	self SetMaxHealth( level.zombie_vars["zombie_player_health"] );
	self thread player_cook_grenade_watcher();
	self thread player_switch_weapon_watcher();
	self thread return_fix();
	self.bought_perks = [];

	if( level.zombie_vars["zombie_candy_give_all"] )
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

		//IPrintLn( "Perk: " + level.wunderfizz_perks[i] );

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

			//PHD Spawn Grenades
			if( self HasPerk( "specialty_flakjacket" ) )
			{
				self bombstoppers_grenade_spawn( grenade, weaponName );
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

