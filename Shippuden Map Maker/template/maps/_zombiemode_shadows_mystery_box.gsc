//================================================================================================
// Nombre del Archivo 	: _zombiemode_shadows_mystery_box.gsc
// Version				: 1
// Autor     			: Shippuden1592
// Foro					: CCM(http://customcodmapping.foroactivo.com/)
// YouTube				: https://www.youtube.com/user/shippuden1592
//================================================================================================
#include maps\_utility; 
#include common_scripts\utility;
#include maps\_zombiemode_utility;

#using_animtree( "shadows_mystery_box" );

init()
{
	level thread shadows_mystery_box_main();
}

shadows_mystery_box_main()
{
	PreCacheModel( "p7_zm_zod_magic_box_tentacle_teddy" );

	level.scr_anim[ "shadows_mystery_box" ][ "zm_zod_magic_box_arrive" ] = %zm_zod_magic_box_arrive;
	level.scr_anim[ "shadows_mystery_box" ][ "zm_zod_magic_box_close" ] = %zm_zod_magic_box_close;
	level.scr_anim[ "shadows_mystery_box" ][ "zm_zod_magic_box_idle" ] = %zm_zod_magic_box_idle;
	level.scr_anim[ "shadows_mystery_box" ][ "zm_zod_magic_box_fake_idle" ] = %zm_zod_magic_box_fake_idle;
	level.scr_anim[ "shadows_mystery_box" ][ "zm_zod_magic_box_open" ] = %zm_zod_magic_box_open;
	level.scr_anim[ "shadows_mystery_box" ][ "zm_zod_magic_box_open_idle" ] = %zm_zod_magic_box_open_idle;
	level.scr_anim[ "shadows_mystery_box" ][ "zm_zod_magic_box_leave" ] = %zm_zod_magic_box_leave;

	level._effect[ "shadows_mystery_box_marker" ]			= Loadfx("shadows/fx_shadows_mystery_box_marker");
	level._effect[ "shadows_mystery_box_glow" ]			= Loadfx("shadows/fx_shadows_mystery_box_glow");
	
	set_zombie_var( "shadows_mystery_box_cost",							950 );
	set_zombie_var( "shadows_mystery_box_firesale_cost",					10 );
	set_zombie_var( "shadows_mystery_box_index",							0 );
	set_zombie_var( "shadows_mystery_box_fire_sale",							false );
	set_zombie_var( "shadows_mystery_box_can_move",							true );
	
	level.shadows_mystery_box_triggers = getentarray("shadows_mystery_box_use", "targetname");

	level thread shadows_mystery_box_init();
}

shadows_mystery_box_init()
{
	flag_wait( "all_players_connected" );

	level.zombie_vars[ "shadows_mystery_box_index" ] = RandomInt(level.shadows_mystery_box_triggers.size);

	_debug_shadows_mystery_box_print( "Total Box " + level.shadows_mystery_box_triggers.size );
	_debug_shadows_mystery_box_print( "Index Start " + level.zombie_vars[ "shadows_mystery_box_index" ] );

	if(level.shadows_mystery_box_triggers.size == 1)
		level.zombie_vars[ "shadows_mystery_box_can_move" ] = false;

	for ( i = 0; i < level.shadows_mystery_box_triggers.size; i++ )
	{
		level.shadows_mystery_box_triggers[ i ] setCursorHint( "HINT_NOICON" );
		level.shadows_mystery_box_triggers[ i ] setHintString( shadows_mystery_box_text(i, false) );
		level.shadows_mystery_box_triggers[ i ].active = false;
		level.shadows_mystery_box_triggers[ i ].fire_sale = false;
		level.shadows_mystery_box_triggers[ i ].chest_accessed = 0;
		level.shadows_mystery_box_triggers[ i ].shadows_mystery_box_index = i;
		level.shadows_mystery_box_triggers[ i ].shadows_mystery_box = getent(level.shadows_mystery_box_triggers[ i ].target, "targetname");
		level.shadows_mystery_box_triggers[ i ].shadows_mystery_box UseAnimTree(#animtree);
		level.shadows_mystery_box_triggers[ i ].shadows_mystery_box_weapon = getent(level.shadows_mystery_box_triggers[ i ].target + "_weapon", "targetname");

		if( i == level.zombie_vars[ "shadows_mystery_box_index" ] )
		{
			level.shadows_mystery_box_triggers[ i ].active = true;
			
			level.shadows_mystery_box_triggers[ i ].shadows_mystery_box thread shadows_mystery_box_create_fx();
			level.shadows_mystery_box_triggers[ i ] thread shadows_mystery_box_set_model(false, true);
		}
		else
		{
			level.shadows_mystery_box_triggers[ i ] thread shadows_mystery_box_set_model(false, false);
		}
		level.shadows_mystery_box_triggers[ i ] thread shadows_mystery_box_watcher();
	}

	level thread shadows_mystery_box_fire_sale_on();
}

shadows_mystery_box_fire_sale_on()
{
	while( 1 )
	{
		level waittill( "powerup fire sale" );

		if( level.zombie_vars[ "shadows_mystery_box_fire_sale" ] )
			continue;

		level.zombie_vars[ "shadows_mystery_box_fire_sale" ] = true;

		for ( i = 0; i < level.shadows_mystery_box_triggers.size; i++ )
		{
			if( i != level.zombie_vars[ "shadows_mystery_box_index" ])
			{
				level.shadows_mystery_box_triggers[ i ] setHintString( shadows_mystery_box_text(-1, true ) );
				level.shadows_mystery_box_triggers[ i ].fire_sale = true;
				level.shadows_mystery_box_triggers[ i ].active = true;
				level.shadows_mystery_box_triggers[ i ].shadows_mystery_box thread shadows_mystery_box_create_fx();
				level.shadows_mystery_box_triggers[ i ] thread shadows_mystery_box_set_model(true, false);
			}
		}
		
		level waittill( "fire_sale_off" );

		for ( i = 0; i < level.shadows_mystery_box_triggers.size; i++ )
		{
			if( i != level.zombie_vars[ "shadows_mystery_box_index" ] && !level.shadows_mystery_box_triggers[ i ].open_box )
			{
				level.shadows_mystery_box_triggers[ i ] setHintString( shadows_mystery_box_text(i, false) );
				level.shadows_mystery_box_triggers[ i ].fire_sale = false;
				level.shadows_mystery_box_triggers[ i ].active = false;
				level.shadows_mystery_box_triggers[ i ].shadows_mystery_box thread shadows_mystery_box_delete_fx();
				level.shadows_mystery_box_triggers[ i ] thread shadows_mystery_box_set_model(false, false);
			}
		}

		level.zombie_vars[ "shadows_mystery_box_fire_sale" ] = false;
	}
}

shadows_mystery_box_text(index, fire_sale)
{
	cost = level.zombie_vars[ "shadows_mystery_box_cost" ];
	if( level.zombie_vars[ "shadows_mystery_box_fire_sale" ] )
		cost = level.zombie_vars[ "shadows_mystery_box_firesale_cost" ];

	if( index == level.zombie_vars[ "shadows_mystery_box_index" ] || fire_sale)
		return "Press & hold ^3[{+activate}]^7 for Random Weapon [Cost: " + cost + "]";
	else
		return "";
}

shadows_mystery_box_create_fx()
{
	if ( !isdefined( self.fx_shadows_mystery_box ) )
	{
		self.fx_shadows_mystery_box = Spawn( "script_model", self.origin );
		self.fx_shadows_mystery_box SetModel( "tag_origin" );
		self.fx_shadows_mystery_box.angles = self.angles + ( -90, 0, 0 );
		self.fx_shadows_mystery_box LinkTo( self, "tag_origin" );
		PlayFxOnTag( level._effect[ "shadows_mystery_box_marker" ], self.fx_shadows_mystery_box, "tag_origin" );
	}
}

shadows_mystery_box_delete_fx()
{
	if ( isdefined( self.fx_shadows_mystery_box ) )
	{
		self.fx_shadows_mystery_box unlink();
		self.fx_shadows_mystery_box delete();
	}
}

shadows_mystery_box_set_model(firesale, magic)
{
	_debug_shadows_mystery_box_print( "entro al mdel ");
	if( firesale || magic )
	{
		self trigger_off();
		self.shadows_mystery_box PlaySound( "zod_box_arrive" );
		self.shadows_mystery_box SetAnimKnob(level.scr_anim[ "shadows_mystery_box" ][ "zm_zod_magic_box_arrive" ], 1, 0, 1);
		wait getAnimLength(level.scr_anim[ "shadows_mystery_box" ][ "zm_zod_magic_box_arrive" ]);
		self trigger_on();
		self PlayLoopSound( "zod_box_looper" );
	}
	else
	{
		self StopLoopSound();
		self.shadows_mystery_box SetAnimKnob(level.scr_anim[ "shadows_mystery_box" ][ "zm_zod_magic_box_fake_idle" ], 1, 0, 1);
	}
}

shadows_mystery_box_watcher()
{
	while( 1 )
	{
		player = undefined;
		self.weapon = undefined;
		self.open_box = false;

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

		if( !self.active && !self.fire_sale )
		{
			wait( 0.1 );
			continue;
		}

		cost = level.zombie_vars[ "shadows_mystery_box_cost" ];
		if( isDefined(level.zombie_vars[ "shadows_mystery_box_fire_sale" ]) && level.zombie_vars[ "shadows_mystery_box_fire_sale" ] )
			cost = level.zombie_vars[ "shadows_mystery_box_firesale_cost" ];
		
		if( player.score < cost )
		{
			player maps\_zombiemode_audio::create_and_play_dialog( "general", "no_money", undefined, 2 );
			continue;
		}

		self.open_box = true;
		self setHintString( "" );
		player maps\_zombiemode_score::minus_to_player_score( cost );

		_debug_shadows_mystery_box_print( "Weapon Random..." );

		self.shadows_mystery_box PlaySound( "zod_box_open" );
		self.shadows_mystery_box SetAnimKnob(level.scr_anim[ "shadows_mystery_box" ][ "zm_zod_magic_box_open" ], 1, 0, 1);
		wait getAnimLength(level.scr_anim[ "shadows_mystery_box" ][ "zm_zod_magic_box_open" ]);

		self.shadows_mystery_box SetAnimKnob(level.scr_anim[ "shadows_mystery_box" ][ "zm_zod_magic_box_open_idle" ], 1, 0, 1);

		self.timedOut = false;

		self.shadows_mystery_box_weapon thread treasure_chest_weapon_spawn( self, player  );
		self.shadows_mystery_box thread treasure_chest_glowfx( self );
		
		self disable_trigger();

		self.shadows_mystery_box_weapon waittill( "randomization_done" );

		if (flag("moving_chest_now"))
		{
			_debug_shadows_mystery_box_print( "La caja se tiene que ir..." );
			self shadows_mystery_box_move();
		}
		else
		{
			// Let the player grab the weapon and re-enable the box //
			self.grab_weapon_hint = true;
			self.chest_user = player;

			self sethintstring( "Press & hold ^3[{+activate}]^7 to trade Weapons" ); 
			self setCursorHint( "HINT_NOICON" ); 
			self setvisibletoplayer( player );

			// Limit its visibility to the player who bought the box
			self enable_trigger(); 
			self thread treasure_chest_timeout();

			while( 1 )
			{
				self waittill( "trigger", grabber ); 

				if( grabber == player || grabber == level )
				{
					if( grabber == player && is_player_valid( player ) && player GetCurrentWeapon() != "mine_bouncing_betty" )
					{
						self notify( "user_grabbed_weapon" );
						player thread maps\_zombiemode_weapons::treasure_chest_give_weapon( self.shadows_mystery_box_weapon.weapon_string );
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
			
			self.grab_weapon_hint = false;
			self.chest_user = undefined;

			self.shadows_mystery_box notify( "weapon_grabbed" );
			self.chest_accessed += 1;
			self disable_trigger();

			self.shadows_mystery_box PlaySound( "zod_box_close" );
			self.shadows_mystery_box SetAnimKnob(level.scr_anim[ "shadows_mystery_box" ][ "zm_zod_magic_box_close" ], 1, 0, 1);
			wait getAnimLength(level.scr_anim[ "shadows_mystery_box" ][ "zm_zod_magic_box_close" ]);

			wait 2;
			self enable_trigger();
			self setvisibletoall();
		}

		flag_clear("moving_chest_now");

		cost = level.zombie_vars[ "shadows_mystery_box_cost" ];
		if( isDefined(level.zombie_vars[ "shadows_mystery_box_fire_sale" ]) && level.zombie_vars[ "shadows_mystery_box_fire_sale" ] )
			cost = level.zombie_vars[ "shadows_mystery_box_firesale_cost" ];

		self setHintString( "Press & hold ^3[{+activate}]^7 for Random Weapon [Cost: " + cost + "]" );

		if(!self.active)
		{
			self setHintString( "" );
		}

		if( !level.zombie_vars[ "shadows_mystery_box_fire_sale" ] && self.shadows_mystery_box_index != level.zombie_vars[ "shadows_mystery_box_index" ] )
		{
			self setHintString( shadows_mystery_box_text(self.shadows_mystery_box_index, false) );
			self.fire_sale = false;
			self.active = false;
			self.shadows_mystery_box thread shadows_mystery_box_delete_fx();
			self thread shadows_mystery_box_set_model(false, false);
		}
	}
}

treasure_chest_weapon_spawn( chest, player )
{
	// spawn the model
	weapon_model = self;
	model = spawn( "script_model", weapon_model.origin ); 
	model.angles = weapon_model.angles; // + (0,90,0);
	model PlaySound( "zod_box_weapon_cycle" );

	floatHeight = 25; //40 old

	// rotation would go here

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

		if( i+1 < number_cycles )
			rand = maps\_zombiemode_weapons::treasure_chest_ChooseRandomWeapon( player );
		else
			rand = maps\_zombiemode_weapons::treasure_chest_ChooseWeightedRandomWeapon( player );

		modelname = GetWeaponModel( rand );
		model setmodel( modelname );
		model useweaponhidetags( rand );
	}

	self.weapon_string = rand; // here's where the org get it's weapon type for the give function

	if ( maps\_zombiemode_weapons::weapon_is_dual_wield(rand))
	{
		self.weapon_model_dw = spawn( "script_model", model.origin - ( 3, 3, 3 ) ); // extra model for dualwield weapons
		self.weapon_model_dw.angles = self.angles +( 0, 90, 0 );		

		self.weapon_model_dw setmodel( maps\_zombiemode_weapons::get_left_hand_weapon_model_name( rand ) ); 
		self.weapon_model_dw useweaponhidetags( rand );
	}

	// random change of getting the joker that moves the box
	random = Randomint(100);

	if( !isdefined( chest.chest_min_move_usage ) )
		chest.chest_min_move_usage = 4;

	if( GetDvar( #"magic_chest_movable") == "1" && level.zombie_vars[ "shadows_mystery_box_can_move" ] )
	{
		if(chest.chest_accessed < chest.chest_min_move_usage)
			chance_of_joker = -1;
		else
		{
			chance_of_joker = chest.chest_accessed + 20;
			
			if( level.chest_moves == 0 && chest.chest_accessed >= 8)
				chance_of_joker = 100;

			if( chest.chest_accessed >= 4 && chest.chest_accessed < 8 )
			{
				if( random < 15 )
					chance_of_joker = 100;
				else
					chance_of_joker = -1;
			}
			
			if( isDefined(level.magic_box_first_move) && level.magic_box_first_move == true )
			{
				if( chest.chest_accessed >= 8 && chest.chest_accessed < 13 )
				{
					if( random < 30 )
						chance_of_joker = 100;
					else
						chance_of_joker = -1;
				}
				
				if( chest.chest_accessed >= 13 )
				{
					if( random < 50 )
						chance_of_joker = 100;
					else
						chance_of_joker = -1;
				}
			}
		}

		if (random <= chance_of_joker && !level.zombie_vars[ "shadows_mystery_box_fire_sale" ] && self.shadows_mystery_box_index == level.zombie_vars[ "shadows_mystery_box_index" ])
		{
			model SetModel("p7_zm_zod_magic_box_tentacle_teddy");

			model.angles = weapon_model.angles + (0,180,0);
			wait 1;
			flag_set("moving_chest_now");
			self notify( "move_imminent" );
			chest.chest_accessed = 0;

			if(IsDefined(self.weapon_model_dw))
			{
				self.weapon_model_dw Delete();
				self.weapon_model_dw = undefined;
			}

			level.chest_moves++;

			player maps\_zombiemode_score::add_to_player_score( 950 );

			level.box_moved = true;
		}
	}
	self notify( "randomization_done" );

	if (flag("moving_chest_now"))
	{
		wait .5;	// we need a wait here before this notify
		level notify("weapon_fly_away_start");
		wait 2;

		chest.shadows_mystery_box PlaySound( "zod_box_leave" );
		chest.shadows_mystery_box SetAnimKnob(level.scr_anim[ "shadows_mystery_box" ][ "zm_zod_magic_box_leave" ], 1, 0, 1);

		model MoveZ(500, 4, 3);

		players = get_players();
		array_thread(players, ::play_crazi_sound);

		chest.shadows_mystery_box notify( "box_moving" );
		wait getAnimLength(level.scr_anim[ "shadows_mystery_box" ][ "zm_zod_magic_box_leave" ]);

		playfx(level._effect["poltergeist"], chest.shadows_mystery_box.origin);

		model delete();
		level notify("weapon_fly_away_end");
	}
	else
	{
		model thread timer_til_despawn(floatHeight);
		chest.shadows_mystery_box waittill( "weapon_grabbed" );

		_debug_shadows_mystery_box_print( "Se eliminan models" );

		if( !chest.timedOut )
		{
			model Delete();

			if(IsDefined(self.weapon_model_dw))
			{
				self.weapon_model_dw Delete();
				self.weapon_model_dw = undefined;
			}
		}
	}
}

play_crazi_sound()
{
	if( is_true( level.player_4_vox_override ) )
	{
		self playlocalsound( "zmb_laugh_rich" );
	}
	else
	{
		self playlocalsound( "zmb_laugh_child" );	
	}
}

treasure_chest_glowfx( chest )
{
	_debug_shadows_mystery_box_print( "FX BOX" );
	fxObj = spawn( "script_model", self.origin +( 0, 0, 30 ) ); 
	fxobj setmodel( "tag_origin" ); 
	fxobj.angles = self.angles +( 90, 90, 0 ); 

	playfxontag( level._effect["chest_light"], fxObj, "tag_origin"  ); 

	chest.shadows_mystery_box waittill_any( "weapon_grabbed", "box_moving" ); 

	_debug_shadows_mystery_box_print( "DELETE FX BOX" );
	fxobj delete(); 
}

treasure_chest_timeout()
{
	self endon( "user_grabbed_weapon" );

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

shadows_mystery_box_move()
{
	level waittill("weapon_fly_away_end");

	old_index = level.zombie_vars[ "shadows_mystery_box_index" ];

	next_box = undefined;
	while( 1 )
	{
		next_box = RandomInt(level.shadows_mystery_box_triggers.size);
		if( !level.shadows_mystery_box_triggers[next_box].active )
		{
			break;
		}
		wait 0.01;
	}

	level.shadows_mystery_box_triggers[ old_index ] enable_trigger(); 
	level.shadows_mystery_box_triggers[ old_index ].active = false;
	level.shadows_mystery_box_triggers[ old_index ].shadows_mystery_box thread shadows_mystery_box_delete_fx();
	level.shadows_mystery_box_triggers[ old_index ] thread shadows_mystery_box_set_model(false, false);
	level.shadows_mystery_box_triggers[ old_index ] setHintString( shadows_mystery_box_text(old_index, false) );

	wait 5;

	level.zombie_vars[ "shadows_mystery_box_index" ] = next_box;

	level.shadows_mystery_box_triggers[ level.zombie_vars[ "shadows_mystery_box_index" ] ].active = true;
	level.shadows_mystery_box_triggers[ level.zombie_vars[ "shadows_mystery_box_index" ] ].shadows_mystery_box thread shadows_mystery_box_create_fx();
	level.shadows_mystery_box_triggers[ level.zombie_vars[ "shadows_mystery_box_index" ] ] thread shadows_mystery_box_set_model(false, true);
	level.shadows_mystery_box_triggers[ level.zombie_vars[ "shadows_mystery_box_index" ] ] setHintString( shadows_mystery_box_text(next_box, false) );

	level.shadows_mystery_box_triggers[ level.zombie_vars[ "shadows_mystery_box_index" ] ].shadows_mystery_box PlaySound( "zod_box_arrive" );
	level.shadows_mystery_box_triggers[ level.zombie_vars[ "shadows_mystery_box_index" ] ].shadows_mystery_box SetAnimKnob(level.scr_anim[ "shadows_mystery_box" ][ "zm_zod_magic_box_arrive" ], 1, 0, 1);
	wait getAnimLength(level.scr_anim[ "shadows_mystery_box" ][ "zm_zod_magic_box_arrive" ]);
}

_debug_shadows_mystery_box_print( str )
{
	//iprintln(str);
}