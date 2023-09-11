//================================================================================================
// Nombre del Archivo 	: _zombiemode_wunderfizz.gsc
// Version				: 1
// Autor     			: Shippuden1592
// Foro					: CCM(http://customcodmapping.foroactivo.com/)
// YouTube				: https://www.youtube.com/user/shippuden1592
//================================================================================================
#include maps\_utility; 
#include common_scripts\utility;
#include maps\_zombiemode_utility;

#using_animtree( "wunderfizz" );

init()
{
	level thread wunderfizz_main();
}

wunderfizz_main()
{
	PreCacheModel( "t6_wpn_zmb_perk_bottle_bear_world" );
	PreCacheModel( "p6_zm_vending_diesel_magic" );
	PreCacheModel( "p6_zm_vending_diesel_magic_off" );

	level.scr_anim[ "wunderfizz" ][ "idle" ] = %zm_dlc4_vending_diesel_on_idle;
	level.scr_anim[ "wunderfizz" ][ "turn_on" ] = %zm_dlc4_vending_diesel_turn_on;
	level.scr_anim[ "wunderfizz" ][ "turn_off" ] = %zm_dlc4_vending_diesel_turn_off;
	level.scr_anim[ "wunderfizz" ][ "ballspin_loop" ] = %zm_dlc4_vending_diesel_ballspin_loop;

	level._effect[ "wunderfizz_use" ] 					= loadfx( "wunderfizz/fx_wunderfizz" );
	level._effect[ "wunderfizz_marker" ] 			= loadfx( "wunderfizz/fx_wunderfizz_marker" );
	level._effect[ "wunderfizz_spotlight" ]				= loadfx( "wunderfizz/fx_wunderfizz_spotlight" );
	level._effect[ "wunderfizz_ball_glow" ]				= loadfx( "wunderfizz/fx_wunderfizz_ball_glow" );
	level._effect[ "zapper_light_ready" ]					= loadfx("maps/zombie/fx_zombie_light_glow_green");
	level._effect[ "zapper_light_notready" ]				= loadfx("maps/zombie/fx_zombie_light_glow_red");
	
	set_zombie_var( "wunderfizz_cost",							1500 );
	set_zombie_var( "wunderfizz_index",							0 );
	set_zombie_var( "wunderfizz_bear_immunity",							2 );
	set_zombie_var( "wunderfizz_bear_chance",							55 );
	set_zombie_var( "wunderfizz_can_move",							false );

	flag_init( "moving_wunderfizz_now" );
	flag_clear( "moving_wunderfizz_now" );

	level.wunderfizz_triggers = getentarray("wunderfizz_use", "targetname");
	level thread wunderfizz_init();
}

wunderfizz_init()
{
	flag_wait( "all_players_connected" );

	if( level.wunderfizz_triggers.size == 0 )
		return;

	level.zombie_vars["wunderfizz_can_move"] = wunderfizz_can_move();

	_debug_wunderfizz_print( "Total Wunderfizz " + level.wunderfizz_triggers.size );

	for ( i = 0; i < level.wunderfizz_triggers.size; i++ )
	{
		level.wunderfizz_triggers[ i ] setCursorHint( "HINT_NOICON" );
		level.wunderfizz_triggers[ i ] setHintString( "Power Must Be Activated!" );
		level.wunderfizz_triggers[ i ].active = false;
		level.wunderfizz_triggers[ i ].wunderfizz_index = i;
		level.wunderfizz_triggers[ i ].wunder_uses = 0;
		level.wunderfizz_triggers[ i ].wunderfizz = getent(level.wunderfizz_triggers[ i ].target, "targetname");
		level.wunderfizz_triggers[ i ].wunderfizz UseAnimTree(#animtree);
		level.wunderfizz_triggers[ i ].wunderfizz_bottle = getent(level.wunderfizz_triggers[ i ].target + "_bottle", "targetname");
		level.wunderfizz_triggers[ i ] thread wunderfizz_set_model( false );
		level.wunderfizz_triggers[ i ] thread wunderfizz_watcher();
	}

	wait 5;

	flag_wait( "power_on" );

	level.zombie_vars[ "wunderfizz_index" ] = RandomInt(level.wunderfizz_triggers.size);

	//Fix Static
	while( 1 )
	{		
		if( !IsDefined( level.wunderfizz_triggers[ level.zombie_vars[ "wunderfizz_index" ] ].script_noteworthy ) )
		{
			break;
		}
		wait 0.01;

		level.zombie_vars[ "wunderfizz_index" ] = RandomInt(level.wunderfizz_triggers.size);

		_debug_wunderfizz_print( "New Index: " + level.zombie_vars[ "wunderfizz_index" ] );
	}

	_debug_wunderfizz_print( "Index Start " + level.zombie_vars[ "wunderfizz_index" ] );

	for ( i = 0; i < level.wunderfizz_triggers.size; i++ )
	{
		level.wunderfizz_triggers[ i ] setHintString( wunderfizz_text( i, false ) );

		if( i == level.zombie_vars[ "wunderfizz_index" ] || ( IsDefined( level.wunderfizz_triggers[ i ].script_noteworthy ) && level.wunderfizz_triggers[ i ].script_noteworthy == "normal_wunderfizz" ) )
		{
			level.wunderfizz_triggers[ i ] thread wunderfizz_set_model( true );

			if( IsDefined( level.wunderfizz_triggers[ i ].script_noteworthy ) && level.wunderfizz_triggers[ i ].script_noteworthy == "normal_wunderfizz" )
			{
				level.wunderfizz_triggers[ i ] setHintString( wunderfizz_text( i, true ) );
			}
		}
	}
}

wunderfizz_text( index, static )
{
	if( index == level.zombie_vars[ "wunderfizz_index" ] || static )
		return "Press & hold ^3[{+activate}]^7 to buy Perk-a-Cola [Cost: " + level.zombie_vars[ "wunderfizz_cost" ] + "]";
	else
		return "Der Wunderfizz is at another location";
}

wunderfizz_create_fx()
{
	if ( !isdefined( self.fx_wunderfizz ) )
	{
		self.fx_wunderfizz = Spawn( "script_model", self.origin );
		self.fx_wunderfizz SetModel( "tag_origin" );
		self.fx_wunderfizz.angles = self.angles + ( -90, 0, 0 );
		self.fx_wunderfizz LinkTo( self, "tag_origin" );
		PlayFxOnTag( level._effect[ "wunderfizz_marker" ], self.fx_wunderfizz, "tag_origin" );
	}
}

wunderfizz_use_fx( state )
{
	if ( isDefined( self.ball_glow_ent ) )
	{
		self.ball_glow_ent delete();
	}

	if ( isDefined( self.fake_model ) )
	{
		self.fake_model delete();
	}	

	self.fake_model = spawn( "script_model", self.origin ); 
	self.fake_model setModel( "p6_zm_vending_diesel_magic" );
	self.fake_model.angles = self.angles;
	self.fake_model hide();

	switch( state )
	{
		case "idle" :
		{
			self.ball_glow_ent = spawn( "script_model", self GetTagOrigin( "j_ball" ) );
			self.ball_glow_ent setModel( "tag_origin" );
			PlayFxOnTag( level._effect[ "wunderfizz_spotlight" ], self.fake_model, "tag_fx_spotlight_0" ); 
			PlayFxOnTag( level._effect[ "wunderfizz_spotlight" ], self.fake_model, "tag_fx_spotlight_1" );
			PlayFxOnTag( level._effect[ "zapper_light_ready" ], self.fake_model, "tag_fx_light_base" ); 		
			PlayFxOnTag( level._effect[ "zapper_light_ready" ], self.fake_model, "tag_fx_light_panel" );
			PlayFxOnTag( level._effect[ "wunderfizz_ball_glow" ], self.ball_glow_ent, "tag_origin" );
			return;
		}
		case "in_use" :
		{
			self.ball_glow_ent = spawn( "script_model", self GetTagOrigin( "j_ball" ) );
			self.ball_glow_ent setModel( "tag_origin" );
			PlayFxOnTag( level._effect[ "wunderfizz_spotlight" ], self.fake_model, "tag_fx_spotlight_0" ); 
			PlayFxOnTag( level._effect[ "wunderfizz_spotlight" ], self.fake_model, "tag_fx_spotlight_1" );
			PlayFxOnTag( level._effect[ "zapper_light_ready" ], self.fake_model, "tag_fx_light_base" ); 		
			PlayFxOnTag( level._effect[ "zapper_light_notready" ], self.fake_model, "tag_fx_light_panel" );
			PlayFxOnTag( level._effect[ "wunderfizz_ball_glow" ], self.ball_glow_ent, "tag_origin" );
			return;
		}
		case "inactive" :
		{
			PlayFxOnTag( level._effect[ "wunderfizz_spotlight" ], self.fake_model, "tag_fx_spotlight_0" ); 
			PlayFxOnTag( level._effect[ "wunderfizz_spotlight" ], self.fake_model, "tag_fx_spotlight_1" );
			PlayFxOnTag( level._effect[ "zapper_light_notready" ], self.fake_model, "tag_fx_light_base" ); 		
			PlayFxOnTag( level._effect[ "zapper_light_notready" ], self.fake_model, "tag_fx_light_panel" );
			return;
		}
		default :
		{
			return;
		}
	}
}

wunderfizz_delete_fx()
{
	if ( isdefined( self.fx_wunderfizz ) )
	{
		self.fx_wunderfizz unlink();
		self.fx_wunderfizz delete();
	}

	if ( isDefined( self.ball_glow_ent ) )
	{
		self.ball_glow_ent delete();
	}
}

wunderfizz_set_model( wunderfizz )
{
	if( wunderfizz )
	{
		self.wunderfizz SetModel("p6_zm_vending_diesel_magic");
		self disable_trigger();
		self.wunderfizz PlaySound( "wonderfizz_ball_drop" );
		self.wunderfizz SetAnimKnob(level.scr_anim[ "wunderfizz" ][ "turn_on" ], 1, 0, 1);
		wait getAnimLength(level.scr_anim[ "wunderfizz" ][ "turn_on" ]);
		self enable_trigger();
		self.active = true;
		self.wunderfizz wunderfizz_use_fx( "idle" );
		self.wunderfizz thread wunderfizz_create_fx();
	}
	else
	{
		self.active = false;
		self.wunderfizz thread wunderfizz_delete_fx();
		self.wunderfizz PlaySound( "wonderfizz_ball_drop" );
		self.wunderfizz SetAnimKnob(level.scr_anim[ "wunderfizz" ][ "turn_off" ], 1, 0, 1);
		self.wunderfizz PlaySound( "wonderfizz_leave" );
		wait getAnimLength(level.scr_anim[ "wunderfizz" ][ "turn_off" ]);
		self.wunderfizz SetModel("p6_zm_vending_diesel_magic_off");
		self.wunderfizz wunderfizz_use_fx( "inactive" );
	}
}

wunderfizz_watcher()
{
	while( 1 )
	{
		self waittill( "trigger", player );

		if( player in_revive_trigger() )
		{
			wait( 0.1 );
			continue;
		}

		if( player is_drinking() )
		{
			wait( 0.1 );
			continue;
		}

		if( player GetCurrentWeapon() == "none" )
		{
			wait( 0.1 );
			continue;
		}

		if( !self.active )
		{
			wait( 0.1 );
			continue;
		}

		if( ChooseRandomPerk( player ) == "" )
		{
			wait( 0.1 );
			continue;
		}

		if( player.num_perks == level.zombie_vars[ "PERK_LIMIT" ])
		{
			wait( 0.1 );
			continue;
		}

		cost = level.zombie_vars[ "wunderfizz_cost" ];
		
		if( player.score < cost )
		{
			player maps\_zombiemode_audio::create_and_play_dialog( "general", "no_money", undefined, 2 );
			continue;
		}

		self.wunderfizz wunderfizz_use_fx( "in_use" );
		self.wunderfizz playsound( "wonderfizz_start" );
		self.wunderfizz SetAnimKnob(level.scr_anim[ "wunderfizz" ][ "ballspin_loop" ], 1, 0, 1);
		
		_debug_wunderfizz_print( "Random Perk..." );

		self setHintString( "" );
		player maps\_zombiemode_score::minus_to_player_score( cost );
		self.timedOut = false;
		self.wunderfizz_bottle thread wunderfizz_bottle_spawn( self, player );
		self disable_trigger();

		self.wunderfizz_bottle waittill( "randomization_done" );

		_debug_wunderfizz_print( "randomization_done" );

		self.wunderfizz playsound ( "wonderfizz_stop" );
		self.wunderfizz wunderfizz_use_fx( "idle" );
		self.wunderfizz SetAnimKnob(level.scr_anim[ "wunderfizz" ][ "idle" ], 1, 0, 1);

		if (flag("moving_wunderfizz_now"))
		{
			self sethintstring( "Moving Wunderfizz!!!" );
			_debug_wunderfizz_print( "El wunderfizz se tiene que ir..." );
			self wunderfizz_move();
		}
		else
		{
			// Let the player grab the weapon and re-enable the box //
			self sethintstring( "Press & hold ^3[{+activate}]^7 to drink Perk-a-Cola" ); 
			self setCursorHint( "HINT_NOICON" ); 
			self setvisibletoplayer( player );

			// Limit its visibility to the player who bought the box
			self enable_trigger(); 
			self thread wunderfizz_timeout();

			while( 1 )
			{
				self waittill( "trigger", grabber ); 

				if( grabber == player || grabber == level )
				{
					if( grabber == player && is_player_valid( player ) && player GetCurrentWeapon() != "mine_bouncing_betty" && !(grabber HasPerk( self.wunderfizz_bottle.perk_string )) )
					{
						self notify( "user_grabbed_perk" );						
						player thread give_perk( self.wunderfizz_bottle.perk_string );		
						break; 
					}
					else if( grabber == level )
					{
						self.timedOut = true;
						break;
					}
				}

				wait 0.05;
			}

			self.wunderfizz notify( "perk_grabbed" );
			self.wunder_uses += 1;
			self disable_trigger();

			wait 2;
			self enable_trigger();
			self setvisibletoall();

			self setHintString( wunderfizz_text( self.wunderfizz_index, false ) );
		}
		flag_clear("moving_wunderfizz_now");
	}
}

give_perk( perk )
{
	gun = self maps\THREAD_GIVE_PERK::perk_give_bottle_begin( perk );
	self waittill_any( "fake_death", "death", "player_downed", "weapon_change_complete" );
	self maps\THREAD_GIVE_PERK::perk_give_bottle_end( gun, perk );
	self maps\THREAD_GIVE_PERK::give_perk( perk, true );
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

wunderfizz_bottle_spawn( wunderfizz, player )
{
	// spawn the model
	model = spawn( "script_model", self.origin );
	PERK_BOTTLE_ANGLE
	model setmodel( "tag_origin" );
	model PlayLoopSound( "wonderfizz_loop" );
	playfxontag ( level._effect["wunderfizz_use"], model, "tag_origin" );

	floatHeight = 25; 

	// make with the mario kart
	modelname = undefined; 
	rand = undefined; 
	number_cycles = 40;
	for( i = 0; i < number_cycles; i++ )
	{
		if( i < 20 )
			wait( 0.05 ); 

		else if( i < 30 )
			wait( 0.1 ); 

		else if( i < 35 )
			wait( 0.2 ); 

		else if( i < 38 )
			wait( 0.3 );

		rand = ChooseRandomPerk( player );
		modelname = GetWeaponModel( "PERK_WEAPON", level.zombie_perks[ rand ].perk_bottle );
		model setmodel( modelname );
	}

	self.perk_string = rand;

	_debug_wunderfizz_print( "Choosen: " + self.perk_string );

	// random change of getting the joker that moves the box
	random = Randomint(100);

	if( level.zombie_vars["wunderfizz_can_move"] && !IsDefined( wunderfizz.script_noteworthy ) )
	{
		if ( wunderfizz.wunder_uses > level.zombie_vars[ "wunderfizz_bear_immunity" ] && random <= level.zombie_vars[ "wunderfizz_bear_chance" ] )
		{
			model SetModel("t6_wpn_zmb_perk_bottle_bear_world");

			wait 1;
			flag_set("moving_wunderfizz_now");
			wunderfizz.wunder_uses = 0;

			player maps\_zombiemode_score::add_to_player_score( level.zombie_vars[ "wunderfizz_cost" ] );
		}
	}

	model StopLoopSound();

	self notify( "randomization_done" );

	if (flag("moving_wunderfizz_now"))
	{
		wait 2;

		//model MoveZ(500, 4, 3);
		//wunderfizz.wunderfizz notify( "wunderfizz_moving" );
		//model waittill("movedone");
		
		model delete();
		level notify("wunderfizz_fly_away_end");
	}
	else
	{
		model thread timer_til_despawn(floatHeight);
		wunderfizz.wunderfizz waittill( "perk_grabbed" );

		_debug_wunderfizz_print( "Se eliminan models" );

		if( !wunderfizz.timedOut )
		{
			model Delete();
		}
	}
}

wunderfizz_timeout()
{
	self endon( "user_grabbed_perk" );

	wait( 12 );
	self notify( "trigger", level ); 
}

timer_til_despawn(floatHeight)
{
	wait( 12 );

	if(isdefined(self))
	{	
		self Delete();
	}
}

wunderfizz_move()
{
	level waittill("wunderfizz_fly_away_end");

	old_index = level.zombie_vars[ "wunderfizz_index" ];

	next_wunderfizz = undefined;
	while( 1 )
	{
		next_wunderfizz = RandomInt(level.wunderfizz_triggers.size);
		if( !level.wunderfizz_triggers[next_wunderfizz].active )
		{
			break;
		}
		wait 0.01;
	}

	level.wunderfizz_triggers[ old_index ] enable_trigger(); 
	level.wunderfizz_triggers[ old_index ].active = false;
	level.wunderfizz_triggers[ old_index ] thread wunderfizz_set_model(false);
	level.wunderfizz_triggers[ old_index ] setHintString( wunderfizz_text( -1, false ) );

	wait 5;

	level.zombie_vars[ "wunderfizz_index" ] = next_wunderfizz;

	level.wunderfizz_triggers[ level.zombie_vars[ "wunderfizz_index" ] ].active = true;
	level.wunderfizz_triggers[ level.zombie_vars[ "wunderfizz_index" ] ] thread wunderfizz_set_model(true);
	level.wunderfizz_triggers[ level.zombie_vars[ "wunderfizz_index" ] ] setHintString( wunderfizz_text(next_wunderfizz, false) );
}

wunderfizz_can_move()
{
	count = 0;

	for ( i = 0; i < level.wunderfizz_triggers.size; i++ )
	{
		if( !IsDefined( level.wunderfizz_triggers[ i ].script_noteworthy ) )
		{
			count++;
		}
	}

	if( count > 1 )
		return true;

	return false;
}

_debug_wunderfizz_print( str )
{
	//iprintln(str);
}