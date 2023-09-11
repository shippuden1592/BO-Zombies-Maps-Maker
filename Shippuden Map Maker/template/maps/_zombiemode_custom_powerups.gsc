//================================================================================================
// Nombre del Archivo 	: _zombiemode_custom_powerups.gsc
// Version				: 1
// Autor     			: Shippuden1592
// Foro					: CCM(http://customcodmapping.foroactivo.com/)
// YouTube				: https://www.youtube.com/user/shippuden1592
//================================================================================================
#include maps\_utility; 
#include common_scripts\utility;
#include maps\_zombiemode_utility;
#include maps\_hud_util;

init()
{
	level._effect[ "powerup_head_0" ] = LoadFX( "IW/fx_zombie_head_fire" );
	level._effect[ "powerup_head_1" ] = LoadFX( "IW/fx_zombie_head_fire_pink" );
	level._effect[ "powerup_head_2" ] = LoadFX( "IW/fx_zombie_head_fire_blue" );
	level._effect[ "powerup_head_3" ] = LoadFX( "IW/fx_zombie_head_fire_green" );

	PrecacheShader( "specialty_custom_invincible" );
	PrecacheShader( "specialty_custom_speed" );
	PrecacheShader( "specialty_custom_thunder" );
	PrecacheShader( "specialty_custom_unlimited" );

	set_zombie_var( "zombie_powerup_custom_max_per_round", 				1 );
	set_zombie_var( "zombie_powerup_custom_chance", 				15 );
	set_zombie_var( "zombie_powerup_points_use", 				CUSTOM_POWER_UP_POINTS_ENABLE );
	set_zombie_var( "zombie_powerup_papgun_use", 				CUSTOM_POWER_UP_PAPGUN_ENABLE );
	set_zombie_var( "zombie_powerup_freeperk_use", 				CUSTOM_POWER_UP_PERK_ENABLE );
	set_zombie_var( "zombie_powerup_invincible_use", 				CUSTOM_POWER_UP_INVULNERABILITY_ENABLE );
	set_zombie_var( "zombie_powerup_invincible_time", 				20 );
	set_zombie_var( "zombie_powerup_speed_use", 				CUSTOM_POWER_UP_SPEED_ENABLE );
	set_zombie_var( "zombie_powerup_speed_time", 				30 );
	set_zombie_var( "zombie_powerup_thunder_use", 				CUSTOM_POWER_UP_THUNDER_ENABLE );
	set_zombie_var( "zombie_powerup_thunder_time", 				20 );
	set_zombie_var( "zombie_powerup_unlimited_use", 				CUSTOM_POWER_UP_UMLIMITED_ENABLE );
	set_zombie_var( "zombie_powerup_unlimited_time", 				30 );

	init_powerups();
	thread powerup_round_tracker();
}

powerup_round_tracker()
{
	flag_wait("all_players_connected");

	while( 1 )
	{
		if( level.round_number <= 5 )
		{
			level.zombie_vars["zombie_powerup_custom_max_per_round"] = 1;
			level.zombie_vars["zombie_powerup_custom_chance"] = 2;
		}
		else if( level.round_number > 5 && level.round_number <= 10 )
		{
			level.zombie_vars["zombie_powerup_custom_max_per_round"] = 2;
			level.zombie_vars["zombie_powerup_custom_chance"] = 10;
		}
		else if( level.round_number > 10 && level.round_number < 20 )
		{
			level.zombie_vars["zombie_powerup_custom_max_per_round"] = 3;
			level.zombie_vars["zombie_powerup_custom_chance"] = 15;
		}
		else
		{
			level.zombie_vars["zombie_powerup_custom_max_per_round"] = 4;
			level.zombie_vars["zombie_powerup_custom_chance"] = 20;
		}

		level waittill( "between_round_over" );
	}
}

init_powerups()
{
	if( !IsDefined( level.zombie_custom_powerups ) )
		level.zombie_custom_powerups = [];

	if( !IsDefined( level.zombie_custom_powerups_hud ) )
		level.zombie_custom_powerups_hud = [];

	if( level.zombie_vars[ "zombie_powerup_points_use" ] )
		add_zombie_powerup( "points", "zombie_z_money_icon" );

	if( level.zombie_vars[ "zombie_powerup_papgun_use" ] )
		add_zombie_powerup( "papgun", "zombie_icon_pap_gun" );

	if( level.zombie_vars[ "zombie_powerup_freeperk_use" ] )
		add_zombie_powerup( "freeperk", "CUSTOM_POWER_UP_PERK_MODEL" );

	if( level.zombie_vars[ "zombie_powerup_invincible_use" ] )
		add_zombie_powerup( "invincible", "zombie_icon_invulnerability", "specialty_custom_invincible" );

	if( level.zombie_vars[ "zombie_powerup_speed_use" ] )
		add_zombie_powerup( "speed", "zombie_icon_boots", "specialty_custom_speed" );

	if( level.zombie_vars[ "zombie_powerup_thunder_use" ] )
		add_zombie_powerup( "thunder", "zombie_icon_thunder", "specialty_custom_thunder" );

	if( level.zombie_vars[ "zombie_powerup_unlimited_use" ] )
		add_zombie_powerup( "unlimited", "zombie_icon_unlimited_ammo", "specialty_custom_unlimited" );
}

add_zombie_powerup( powerup_name, model_name, shader )
{
	if( IsDefined( level.zombie_custom_powerups ) && IsDefined( level.zombie_custom_powerups[powerup_name] ) )
	{
		return;
	}

	PrecacheModel( model_name );

	struct = SpawnStruct();
	struct.powerup_name = powerup_name;
	struct.model_name = model_name;
	level.zombie_custom_powerups[powerup_name] = struct;

	if( IsDefined( shader ) )
	{
		powerup_hud = SpawnStruct();
		powerup_hud.is_active = false;

		hud = create_simple_hud();
		hud.foreground = true; 
		hud.sort = 2; 
		hud.hidewheninmenu = false; 
		hud.alignX = "center"; 
		hud.alignY = "bottom";
		hud.horzAlign = "user_center"; 
		hud.vertAlign = "user_bottom";
		hud.x = level.zombie_custom_powerups_hud.size * 32;
		hud.y = -80;
		hud.alpha = 0;
		hud setshader(shader, 32, 32);
		
		powerup_hud.powerup_hud = hud;
		powerup_hud.time_var = level.zombie_vars[ "zombie_powerup_" + powerup_name + "_time" ];
		powerup_hud.time_default_var = level.zombie_vars[ "zombie_powerup_" + powerup_name + "_time" ];
		powerup_hud.shader = shader;

		level.zombie_custom_powerups_hud[powerup_name] = powerup_hud;
	}
}

power_on_hud_time( powerup_name )
{
	level endon ("powerup " + powerup_name + " hud");

	level.zombie_custom_powerups_hud[powerup_name].time_var = level.zombie_custom_powerups_hud[powerup_name].time_default_var;
	while ( level.zombie_custom_powerups_hud[powerup_name].time_var >= 0)
	{
		wait 0.1;
		level.zombie_custom_powerups_hud[powerup_name].time_var = level.zombie_custom_powerups_hud[powerup_name].time_var - 0.1;
	}
}

power_on_hud( powerup_name )
{
	level notify ("powerup " + powerup_name + " hud");
	level endon ("powerup " + powerup_name + " hud");

	level.zombie_custom_powerups_hud[powerup_name].is_active = true;
	level.zombie_custom_powerups_hud[powerup_name].powerup_hud.alpha = 1;

	level thread power_on_hud_time( powerup_name );

	while( level.zombie_custom_powerups_hud[powerup_name].is_active )
	{
		if(level.zombie_custom_powerups_hud[powerup_name].time_var < 5)
		{
			wait(0.1);		
			level.zombie_custom_powerups_hud[powerup_name].powerup_hud.alpha = 0;
			wait(0.1);
		}

		else if(level.zombie_custom_powerups_hud[powerup_name].time_var < 10)
		{
			wait(0.2);
			level.zombie_custom_powerups_hud[powerup_name].powerup_hud.alpha = 0;
			wait(0.18);
		}

		if( level.zombie_custom_powerups_hud[powerup_name].is_active )
		{
			x_start = -1 * ((get_hud_active() * 40) / 2);
			keys = GetArrayKeys( level.zombie_custom_powerups_hud );
			for( i = 0; i < keys.size; i++ )
			{
				if( level.zombie_custom_powerups_hud[keys[i]].is_active )
				{
					level.zombie_custom_powerups_hud[keys[i]].powerup_hud.x = x_start;
					x_start += 40;
				}
			}

			level.zombie_custom_powerups_hud[powerup_name].powerup_hud.alpha = 1;
		}
		else
		{
			level.zombie_custom_powerups_hud[powerup_name].powerup_hud.alpha = 0;
		}

		wait( 0.05 );
	}

	level.zombie_custom_powerups_hud[powerup_name].powerup_hud.alpha = 0;
}

get_hud_active()
{
	active = 0;
	keys = GetArrayKeys( level.zombie_custom_powerups_hud );

	for( i = 0; i < keys.size; i++ )
	{
		if( level.zombie_custom_powerups_hud[keys[i]].is_active )
		{
			active++;
		}
	}

	if( active == 0 )
		return 1;
	else
		return active;
}

zombie_can_powerup()
{
	if( level.zombie_vars["zombie_powerup_custom_max_per_round"] <= 0 )
		return false;

	if( !isDefined(level.zombie_custom_powerups) || level.zombie_custom_powerups.size == 0 )
		return false;

	if (RandomInt(100) > level.zombie_vars["zombie_powerup_custom_chance"])
		return false;

	level.zombie_vars["zombie_powerup_custom_max_per_round"]--;

	return true;
}

powerup_drop()
{
	self endon( "death" );

	wait 0.5;

	self.no_powerups = true;
	self thread powerup_drop_playable_area();
}

powerup_drop_playable_area()
{
	self.fx_head = Spawn( "script_model", self GetTagOrigin( "j_head" ) );
	self.fx_head.angles = self GetTagAngles( "j_head" );
	self.fx_head SetModel( "tag_origin" );
	self.fx_head LinkTo( self, "j_head" );
	PlayFxOnTag( level._effect["powerup_head_" + RandomInt(4) ], self.fx_head, "tag_origin" );

	self.fx_hand_rh = Spawn( "script_model", self GetTagOrigin( "j_wrist_ri" ) );
	self.fx_hand_rh.angles = self GetTagAngles( "j_wrist_ri" );
	self.fx_hand_rh SetModel( "tag_origin" );
	self.fx_hand_rh LinkTo( self, "j_wrist_ri" );
	PlayFxOnTag( level._effect["powerup_head_" + RandomInt(4) ], self.fx_hand_rh, "tag_origin" );

	self.fx_hand_lh = Spawn( "script_model", self GetTagOrigin( "j_wrist_le" ) );
	self.fx_hand_lh.angles = self GetTagAngles( "j_wrist_le" );
	self.fx_hand_lh SetModel( "tag_origin" );
	self.fx_hand_lh LinkTo( self, "j_wrist_le" );
	PlayFxOnTag( level._effect["powerup_head_" + RandomInt(4) ], self.fx_hand_lh, "tag_origin" );

	self waittill( "death" );

	if( IsDefined( self.fx_head ) )
	{
		self.fx_head unlink();
		self.fx_head delete();
	}

	if( IsDefined( self.fx_hand_rh ) )
	{
		self.fx_hand_rh unlink();
		self.fx_hand_rh delete();
	}

	if( IsDefined( self.fx_hand_lh ) )
	{
		self.fx_hand_lh unlink();
		self.fx_hand_lh delete();
	}

	if( !check_point_in_playable_area( self.origin ) )
	{
		level.zombie_vars["zombie_powerup_custom_max_per_round"]++;
		return;
	}

	powerup = spawn( "script_model", self.origin + (0,0,40) );
	powerup powerup_setup();
	powerup thread powerup_timeout();
	powerup thread powerup_wobble();
	powerup thread powerup_grab();
}

specific_powerup_drop(powerup, origin)
{
	powerup = spawn( "script_model", origin + (0,0,35) );
	powerup powerup_setup();
	powerup thread powerup_timeout();
	powerup thread powerup_wobble();
	powerup thread powerup_grab();
}

powerup_setup()
{
	keys = GetArrayKeys( level.zombie_custom_powerups );
	struct = level.zombie_custom_powerups[ random( keys ) ];

	self.powerup_name = struct.powerup_name;
	self SetModel( struct.model_name );
	self PlayLoopSound("zmb_spawn_powerup_loop");
}

powerup_grab()
{
	self endon ("powerup_timedout");
	self endon ("powerup_grabbed");

	range_squared = 64 * 64;
	while ( IsDefined( self )  )
	{
		players = get_players();
		for (i = 0; i < players.size; i++)
		{
			if ( DistanceSquared( players[i].origin, self.origin ) < range_squared )
			{
				switch (self.powerup_name)
				{
					case "points":
						if( RandomInt(100) < 50 ) //Solo
						{
							level thread maps\_zombiemode_powerups::bonus_points_player_powerup( self, players[i] );
							players[i] thread maps\_zombiemode_powerups::powerup_vo( "bonus_points_solo" );
						}
						else //Team
						{
							level thread maps\_zombiemode_powerups::bonus_points_team_powerup( self );
							players[i] thread maps\_zombiemode_powerups::powerup_vo( "bonus_points_team" );
						}

						break;
					case "papgun":
						level thread pack_punch_powerup( players[i] );
						break;
					case "freeperk":
						//FREE_PERK_THREAD
						break;
					case "invincible":
						level thread invincible_powerup( self.powerup_name );
						break;
					case "speed":
						level thread player_speed_powerup( self.powerup_name );
						break;
					case "thunder":
						level thread player_thunder_powerup( self.powerup_name );
						break;
					case "unlimited":
						level thread unlimited_ammo_powerup( self.powerup_name );
						break;
				}

				playfx( level._effect["powerup_grabbed_solo"], self.origin );
				playfx( level._effect["powerup_grabbed_wave_solo"], self.origin );

				wait( 0.1 );

				playsoundatposition("zmb_powerup_grabbed", self.origin);
				self stoploopsound();

				self delete();
				self notify ("powerup_grabbed");
			}
		}

		wait 0.1;
	}
}

unlimited_ammo_powerup( powerup_name )
{
	level notify ("powerup unlimited_ammo");
	level endon ("powerup unlimited_ammo");

	level thread power_on_hud( powerup_name );

	players = get_players();
	for( i = 0; i < players.size; i++ )
	{
		players[i] thread player_unlimited_ammo( powerup_name );
	}

	wait level.zombie_vars["zombie_powerup_unlimited_time"];
	level.zombie_custom_powerups_hud[powerup_name].is_active = false;
}

player_unlimited_ammo( powerup_name )
{
	level endon ("powerup unlimited_ammo");

	while( level.zombie_custom_powerups_hud[powerup_name].is_active )
	{
		currentweapon = self GetCurrentWeapon();
		ammoclip = WeaponClipSize( currentweapon );
		self SetWeaponAmmoClip( currentweapon, ammoclip );

		wait 0.1;
	}
}

player_thunder_powerup( powerup_name )
{
	level notify ("powerup thunder");
	level endon ("powerup thunder");

	level thread power_on_hud( powerup_name );
	
	players = get_players();
	for( i = 0; i < players.size; i++ )
	{
		players[i] thread player_thunder( powerup_name );
	}

	wait level.zombie_vars["zombie_powerup_thunder_time"];
	level.zombie_custom_powerups_hud[powerup_name].is_active = false;
}

player_thunder( powerup_name )
{
	level endon ("powerup thunder");

	while( level.zombie_custom_powerups_hud[powerup_name].is_active )
	{
		zombies = maps\shippuden_utility::get_round_enemy_array();
		for( i = 0; i < zombies.size; i++ )
		{
			if( Distance( self.origin, zombies[i].origin ) < 120 && !maps\shippuden_utility::Is_Boss( zombies[i] ) )
			{
				zombies[i] thread zombie_fling( self );
			}
		}

		wait 0.5;
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

	player maps\_zombiemode_score::add_to_player_score( add_points(50) );
}

add_points( points )
{
	if(level.zombie_vars["zombie_powerup_point_doubler_on"] == true)
		return ( points * 2 );
	else
		return points;
}

player_speed_powerup( powerup_name )
{
	level notify ("powerup speed");
	level endon ("powerup speed");

	level thread power_on_hud( powerup_name );

	players = get_players(); 
	for(i = 0; i < players.size; i++)
	{
		players[i] SetMoveSpeedScale(1.57);
	}

	wait level.zombie_vars["zombie_powerup_speed_time"];
	level.zombie_custom_powerups_hud[powerup_name].is_active = false;

	for(i = 0; i < players.size; i++)
	{
		if(players[i] hasperk("specialty_longersprint"))
			players[i] SetMoveSpeedScale(1.1);
		else
			players[i] SetMoveSpeedScale(1);
	}
}

invincible_powerup( powerup_name )
{
	level notify ("powerup invincible");
	level endon ("powerup invincible");

	level thread power_on_hud( powerup_name );

	time = level.zombie_vars["zombie_powerup_invincible_time"];
	while( time > 0 )
	{
		players = get_players(); 
		for(i = 0; i < players.size; i++)
		{
			if( !players[i].isInvulnerability )
			{
				players[i] EnableInvulnerability();
				players[i].isInvulnerability = true;
			}
		}

		wait 1;
		time--;
	}

	level.zombie_custom_powerups_hud[powerup_name].is_active = false;

	players = get_players(); 
	for(i = 0; i < players.size; i++)
	{
		if( players[i].isInvulnerability )
		{
			players[i] DisableInvulnerability();
			players[i].isInvulnerability = false;
		}
	}
}

//FREE_PERK_FUNCTION
free_perk_powerup()
{
	players = get_players();
	for( i = 0; i < players.size; i++ )
	{
		if ( !players[i] maps\_laststand::player_is_in_laststand() && !(players[i].sessionstate == "spectator") )
		{
			perk_name = ChooseRandomPerk( players[i] );
			if( perk_name != "" )
			{
				players[i] thread maps\CUSTOM_POWER_THREAD_GIVE_PERK::give_perk( perk_name );
			}
		}
	}
}

ChooseRandomPerk( player )
{
	perk = "";
	level.wunderfizz_perks = array_randomize( level.wunderfizz_perks );

	for(i = 0; i < level.wunderfizz_perks.size; i++)
	{
		if(!player HasPerk( level.wunderfizz_perks[i] ))
		{
			perk = level.wunderfizz_perks[i];
			break;
		}
	}
	return perk;
}

pack_punch_powerup( player )
{
	if( IsDefined( level.zombie_vars[ "zombie_gungame" ] ) && level.zombie_vars[ "zombie_gungame" ] )
	{
		player.next_weapon_kills = -1;
		player notify( "player_next_gun" );
	}
	else
	{
		players = get_players();
		for( i = 0; i < players.size; i++ )
		{
			current_weapon = players[i] getCurrentWeapon();

			if( !players[i] maps\_zombiemode_weapons::can_buy_weapon() ||
				players[i] maps\_laststand::player_is_in_laststand() ||
				is_true( players[i].intermission ) ||
				players[i] isThrowingGrenade() ||
				players[i] maps\_zombiemode_weapons::is_weapon_upgraded( current_weapon ) )
			{
				wait( 0.1 );
				continue;
			}

			if( players[i] isSwitchingWeapons() )
	 		{
	 			wait(0.1);
	 			continue;
	 		}

	 		if ( !IsDefined( level.zombie_include_weapons[current_weapon] ) )
			{
				continue;
			}

			if( IsDefined( level.zombie_weapons[current_weapon].upgrade_name ) || current_weapon != "minigun_zm" )
			{
				upgrade_weapon = level.zombie_weapons[current_weapon].upgrade_name;
				weapon_limit = 2;

				if ( players[i] HasPerk( "specialty_additionalprimaryweapon" ) )
				{
					weapon_limit = 3;
				}

				primaries = players[i] GetWeaponsListPrimaries();
				if( isDefined( primaries ) && primaries.size >= weapon_limit )
				{
					players[i] maps\_zombiemode_weapons::weapon_give( upgrade_weapon );
				}
				else
				{
					currentweapon = players[i] GetCurrentWeapon();
					players[i] TakeWeapon( currentweapon );
					players[i] GiveWeapon( upgrade_weapon, 0, players[i] maps\_zombiemode_weapons::get_pack_a_punch_weapon_options( upgrade_weapon ) );
					players[i] GiveStartAmmo( upgrade_weapon );
				}

				players[i] SwitchToWeapon( upgrade_weapon );
				players[i] maps\_zombiemode_weapons::play_weapon_vo(upgrade_weapon);
			}
		}
	}
}

powerup_wobble()
{
	self endon( "powerup_grabbed" );
	self endon( "powerup_timedout" );

	playfxontag( level._effect[ "powerup_on_solo" ], self, "tag_origin" );

	while ( isdefined( self ) )
	{
		waittime = randomfloatrange( 2.5, 5 );

		yaw = RandomInt( 360 );
		if( yaw > 300 )		
			yaw = 300;
		else if( yaw < 60 )
			yaw = 60;

		yaw = self.angles[1] + yaw;
		new_angles = (-60 + randomint( 120 ), yaw, -45 + randomint( 90 ));
		self rotateto( new_angles, waittime, waittime * 0.5, waittime * 0.5 );
		wait randomfloat( waittime - 0.1 );
	}
}

powerup_timeout()
{
	self endon( "powerup_grabbed" );
	self endon( "death" );

	wait 15;

	for ( i = 0; i < 40; i++ )
	{
		if ( i % 2 )
			self hide();
		else
			self show();

		if ( i < 15 )
			wait( 0.5 );
		else if ( i < 25 )
			wait( 0.25 );
		else
			wait( 0.1 );
	}

	self notify( "powerup_timedout" );
	self delete();
}