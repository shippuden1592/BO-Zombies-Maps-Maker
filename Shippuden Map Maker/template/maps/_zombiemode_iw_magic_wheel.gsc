//================================================================================================
// Nombre del Archivo 	: _zombiemode_iw_magic_wheel.gsc
// Version				: 1
// Autor     			: Shippuden1592
// Foro					: CCM(http://customcodmapping.foroactivo.com/)
// YouTube				: https://www.youtube.com/user/shippuden1592
//================================================================================================
#include maps\_utility; 
#include common_scripts\utility;
#include maps\_zombiemode_utility;

init()
{
	level thread magic_wheel_main();
}

magic_wheel_main()
{
	PreCacheModel( "iw_magic_wheel_on" );
	PreCacheModel( "iw_teddy_bear" );
	PreCacheModel( "iw_magic_wheel_spinner_on" );

	level._effect[ "magic_wheel_marker" ]			= Loadfx("iw/fx_magic_wheel_marker");
	level._effect[ "magic_wheel_glow" ]			= Loadfx("iw/fx_magic_wheel_glow");
	
	set_zombie_var( "magic_wheel_cost",							950 );
	set_zombie_var( "magic_wheel_firesale_cost",					10 );
	set_zombie_var( "magic_wheel_index",							0 );
	set_zombie_var( "magic_wheel_fire_sale",							false );
	set_zombie_var( "magic_wheel_can_move",							true );

	level.magic_wheel_triggers = getentarray("magic_wheel_use", "targetname");

	level thread magic_wheel_init();
}

magic_wheel_init()
{
	flag_wait( "all_players_connected" );

	level.zombie_vars[ "magic_wheel_index" ] = RandomInt(level.magic_wheel_triggers.size);

	_debug_magic_wheel_print( "Total Box " + level.magic_wheel_triggers.size );
	_debug_magic_wheel_print( "Index Start " + level.zombie_vars[ "magic_wheel_index" ] );

	if(level.magic_wheel_triggers.size == 1)
		level.zombie_vars[ "magic_wheel_can_move" ] = false;

	for ( i = 0; i < level.magic_wheel_triggers.size; i++ )
	{
		level.magic_wheel_triggers[ i ] setCursorHint( "HINT_NOICON" );
		level.magic_wheel_triggers[ i ] setHintString( magic_wheel_text(i, false) );
		level.magic_wheel_triggers[ i ].active = false;
		level.magic_wheel_triggers[ i ].fire_sale = false;
		level.magic_wheel_triggers[ i ].chest_accessed = 0;
		level.magic_wheel_triggers[ i ].magic_wheel_index = i;
		level.magic_wheel_triggers[ i ].magic_wheel = getent(level.magic_wheel_triggers[ i ].target, "targetname");
		level.magic_wheel_triggers[ i ].magic_wheel_weapon = getent(level.magic_wheel_triggers[ i ].target + "_weapon", "targetname");
		level.magic_wheel_triggers[ i ].magic_wheel_spinner = getent(level.magic_wheel_triggers[ i ].target + "_spinner", "targetname");
		//FX´s
		level.magic_wheel_triggers[ i ].magic_wheel_spinner_fx_rh = [];
		level.magic_wheel_triggers[ i ].magic_wheel_spinner_fx_lh = [];
		for( f = 1; f <= 9; f++ )
		{
			level.magic_wheel_triggers[ i ].magic_wheel_spinner_fx_rh[level.magic_wheel_triggers[ i ].magic_wheel_spinner_fx_rh.size] = getent( level.magic_wheel_triggers[ i ].target + "_fx_rh_" + f, "targetname" );
			level.magic_wheel_triggers[ i ].magic_wheel_spinner_fx_lh[level.magic_wheel_triggers[ i ].magic_wheel_spinner_fx_lh.size] = getent( level.magic_wheel_triggers[ i ].target + "_fx_lh_" + f, "targetname" );
		}

		if( i == level.zombie_vars[ "magic_wheel_index" ] )
		{
			level.magic_wheel_triggers[ i ].active = true;			
			level.magic_wheel_triggers[ i ].magic_wheel thread magic_wheel_create_fx();
			level.magic_wheel_triggers[ i ] thread magic_wheel_set_model(false, true);
		}
		else
		{
			level.magic_wheel_triggers[ i ] thread magic_wheel_set_model(false, false);
		}
		level.magic_wheel_triggers[ i ] thread magic_wheel_watcher();
	}

	level thread magic_wheel_fire_sale_on();
}

magic_wheel_anim_fx()
{
	self endon( "stop_magic_wheel_fx" );

	self magic_wheel_anim_fx_on( true , 0, "all", false);

	while( 1 )
	{
		for( i = 0; i < 9; i++ )
		{
			self magic_wheel_anim_fx_on( false , i, "rh", true);
			self magic_wheel_anim_fx_on( false , i, "lh", true);

			wait 0.15;
		}

		for( i = 0; i < 9; i++ )
		{
			self magic_wheel_anim_fx_on( false , i, "rh", false);
			self magic_wheel_anim_fx_on( false , i, "lh", false);

			wait 0.15;
		}

		wait 1;
	}
}

magic_wheel_anim_fx_on( all, index, type, isShow )
{
	if( all )
	{
		for( i = 0; i < 9; i++ )
		{
			if( isShow )
			{
				self.magic_wheel_spinner_fx_rh[i] show();
				self.magic_wheel_spinner_fx_lh[i] show();
			}
			else
			{
				self.magic_wheel_spinner_fx_rh[i] hide();
				self.magic_wheel_spinner_fx_lh[i] hide();
			}
		}
	}
	else
	{
		if( type == "rh" )
		{
			if( isShow )
				self.magic_wheel_spinner_fx_rh[index] show();
			else
				self.magic_wheel_spinner_fx_rh[index] hide();
		}
		else if( type == "lh" )
		{
			if( isShow )
				self.magic_wheel_spinner_fx_lh[index] show();
			else
				self.magic_wheel_spinner_fx_lh[index] hide();
		}
	}
}

magic_wheel_fire_sale_on()
{
	while( 1 )
	{
		level waittill( "powerup fire sale" );

		if( level.zombie_vars[ "magic_wheel_fire_sale" ] )
			continue;

		level.zombie_vars[ "magic_wheel_fire_sale" ] = true;

		for ( i = 0; i < level.magic_wheel_triggers.size; i++ )
		{
			if( i != level.zombie_vars[ "magic_wheel_index" ])
			{
				level.magic_wheel_triggers[ i ] setHintString( magic_wheel_text(-1, true ) );
				level.magic_wheel_triggers[ i ].fire_sale = true;
				level.magic_wheel_triggers[ i ].active = true;
				level.magic_wheel_triggers[ i ].magic_wheel thread magic_wheel_create_fx();
				level.magic_wheel_triggers[ i ] thread magic_wheel_set_model(true, false);
			}
		}
		
		level waittill( "fire_sale_off" );

		for ( i = 0; i < level.magic_wheel_triggers.size; i++ )
		{
			if( i != level.zombie_vars[ "magic_wheel_index" ] && !level.magic_wheel_triggers[ i ].open_box )
			{
				level.magic_wheel_triggers[ i ] setHintString( magic_wheel_text(i, false) );
				level.magic_wheel_triggers[ i ].fire_sale = false;
				level.magic_wheel_triggers[ i ].active = false;
				level.magic_wheel_triggers[ i ].magic_wheel thread magic_wheel_delete_fx();
				level.magic_wheel_triggers[ i ] thread magic_wheel_set_model(false, false);
			}
		}

		level.zombie_vars[ "magic_wheel_fire_sale" ] = false;
	}
}

magic_wheel_text(index, fire_sale)
{
	cost = level.zombie_vars[ "magic_wheel_cost" ];
	if( level.zombie_vars[ "magic_wheel_fire_sale" ] )
		cost = level.zombie_vars[ "magic_wheel_firesale_cost" ];

	if( index == level.zombie_vars[ "magic_wheel_index" ] || fire_sale)
		return "Press & hold ^3[{+activate}]^7 for Random Weapon [Cost: " + cost + "]";
	else
		return "";
}

magic_wheel_create_fx()
{
	if ( !isdefined( self.fx_magic_wheel ) )
	{
		self.fx_magic_wheel = Spawn( "script_model", self.origin );
		self.fx_magic_wheel SetModel( "tag_origin" );
		self.fx_magic_wheel.angles = self.angles + ( -90, 0, 0 );
		self.fx_magic_wheel LinkTo( self, "tag_origin" );
		PlayFxOnTag( level._effect[ "magic_wheel_marker" ], self.fx_magic_wheel, "tag_origin" );
		PlayFxOnTag( level._effect[ "doubletap_light" ], self.fx_magic_wheel, "tag_origin" );
	}
}

magic_wheel_delete_fx()
{
	if ( isdefined( self.fx_magic_wheel ) )
	{
		self.fx_magic_wheel unlink();
		self.fx_magic_wheel delete();
	}
}

magic_wheel_set_model(firesale, magic)
{
	_debug_magic_wheel_print( "entro al modelo");
	if( firesale || magic )
	{
		//self.magic_wheel PlaySound( "zod_box_arrive" );
		self.magic_wheel SetModel( "iw_magic_wheel_on" );
		self PlayLoopSound( "zod_box_looper" );
		self thread magic_wheel_anim_fx();
	}
	else
	{
		self StopLoopSound();
		self.magic_wheel SetModel( "iw_magic_wheel" );
		//Deter Anim FX
		self notify( "stop_magic_wheel_fx" );
		self magic_wheel_anim_fx_on( true , 0, "all", false);
	}
}

magic_wheel_watcher()
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

		cost = level.zombie_vars[ "magic_wheel_cost" ];
		if( isDefined(level.zombie_vars[ "magic_wheel_fire_sale" ]) && level.zombie_vars[ "magic_wheel_fire_sale" ] )
			cost = level.zombie_vars[ "magic_wheel_firesale_cost" ];
		
		if( player.score < cost )
		{
			player maps\_zombiemode_audio::create_and_play_dialog( "general", "no_money", undefined, 2 );
			continue;
		}

		self.open_box = true;
		self setHintString( "" );
		player maps\_zombiemode_score::minus_to_player_score( cost );

		_debug_magic_wheel_print( "Weapon Random..." );

		self notify( "stop_magic_wheel_fx" );
		self magic_wheel_anim_fx_on( true , 0, "all", false);
		self.magic_wheel_spinner thread magic_wheel_spinner_rotate( self );

		//self.magic_wheel PlaySound( "zod_box_open" );
		play_sound_at_pos( "open_chest", self.magic_wheel.origin );
		play_sound_at_pos( "music_chest", self.magic_wheel.origin );

		self.timedOut = false;

		self.magic_wheel_weapon thread treasure_chest_weapon_spawn( self, player  );
		self.magic_wheel thread treasure_chest_glowfx( self );
		
		self disable_trigger();

		self.magic_wheel_weapon waittill( "randomization_done" );

		if (flag("moving_chest_now"))
		{
			_debug_magic_wheel_print( "La caja se tiene que ir..." );
			self magic_wheel_move();
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
						player thread maps\_zombiemode_weapons::treasure_chest_give_weapon( self.magic_wheel_weapon.weapon_string );
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

			self.magic_wheel notify( "weapon_grabbed" );
			self.chest_accessed += 1;
			self disable_trigger();

			//self.magic_wheel PlaySound( "zod_box_close" );
			play_sound_at_pos( "close_chest", self.magic_wheel.origin );

			wait 2;
			self enable_trigger();
			self setvisibletoall();
		}
		flag_clear("moving_chest_now");

		cost = level.zombie_vars[ "magic_wheel_cost" ];
		if( isDefined(level.zombie_vars[ "magic_wheel_fire_sale" ]) && level.zombie_vars[ "magic_wheel_fire_sale" ] )
			cost = level.zombie_vars[ "magic_wheel_firesale_cost" ];

		self setHintString( "Press & hold ^3[{+activate}]^7 for Random Weapon [Cost: " + cost + "]" );

		if(!self.active)
		{
			self setHintString( "" );
		}

		if( !level.zombie_vars[ "magic_wheel_fire_sale" ] && self.magic_wheel_index != level.zombie_vars[ "magic_wheel_index" ] )
		{
			self setHintString( magic_wheel_text(self.magic_wheel_index, false) );
			self.fire_sale = false;
			self.active = false;
			self.magic_wheel thread magic_wheel_delete_fx();
			self thread magic_wheel_set_model(false, false);
		}

		if( self.active )
			self thread magic_wheel_anim_fx();
	}
}

magic_wheel_spinner_rotate( chest )
{
	//origin_position = self.origin;
	//angles_position = self.angles;

	self SetModel( "iw_magic_wheel_spinner_on" );

	number_cycles = 40;
	for( i = 0; i < number_cycles; i++ )
	{
		wait_number = 0;
		if( i < 20 )
			wait_number = 0.05; 

		else if( i < 30 )
			wait_number = 0.1;

		else if( i < 35 )
			wait_number = 0.2;

		else if( i < 38 )
			wait_number = 0.3;

		self RotatePitch(45, wait_number);

		wait wait_number;
	}

	chest.magic_wheel waittill_any( "weapon_grabbed", "box_moving" );

	_debug_magic_wheel_print( "regresar spinner" );

	//self.origin = origin_position;
	//self.angles = angles_position;
	self SetModel( "iw_magic_wheel_spinner" );
}

treasure_chest_weapon_spawn( chest, player )
{
	// spawn the model
	weapon_model = self;
	model = spawn( "script_model", weapon_model.origin ); 
	model.angles = weapon_model.angles + (0,-90,0);
	//model PlaySound( "zod_box_weapon_cycle" );

	floatHeight = 40; //40 old

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

	if( GetDvar( #"magic_chest_movable") == "1" && level.zombie_vars[ "magic_wheel_can_move" ] )
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

		if (random <= chance_of_joker && !level.zombie_vars[ "magic_wheel_fire_sale" ] && self.magic_wheel_index == level.zombie_vars[ "magic_wheel_index" ])
		{
			model SetModel("iw_teddy_bear");

			model.angles = weapon_model.angles;
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

		chest.magic_wheel PlaySound( "zmb_box_move" );

		model MoveZ(300, 4, 3);

		players = get_players();
		array_thread(players, ::play_crazi_sound);

		chest.magic_wheel notify( "box_moving" );
		
		model waittill("movedone");

		playfx(level._effect["poltergeist"], chest.magic_wheel.origin);

		model delete();
		level notify("weapon_fly_away_end");
	}
	else
	{
		model thread timer_til_despawn(floatHeight);
		chest.magic_wheel waittill( "weapon_grabbed" );

		_debug_magic_wheel_print( "Se eliminan models" );

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
	_debug_magic_wheel_print( "FX BOX" );
	fxObj = spawn( "script_model", self.origin + ( 0, 0, -30 ) ); 
	fxobj setmodel( "tag_origin" ); 
	//fxobj.angles = self.angles +( 90, 90, 0 ); 

	playfxontag( level._effect["magic_wheel_glow"], fxObj, "tag_origin"  ); 

	chest.magic_wheel waittill_any( "weapon_grabbed", "box_moving" ); 

	_debug_magic_wheel_print( "DELETE FX BOX" );
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

magic_wheel_move()
{
	level waittill("weapon_fly_away_end");

	old_index = level.zombie_vars[ "magic_wheel_index" ];

	next_box = undefined;
	while( 1 )
	{
		next_box = RandomInt(level.magic_wheel_triggers.size);
		if( !level.magic_wheel_triggers[next_box].active )
		{
			break;
		}
		wait 0.01;
	}

	level.magic_wheel_triggers[ old_index ] enable_trigger(); 
	level.magic_wheel_triggers[ old_index ].active = false;
	level.magic_wheel_triggers[ old_index ].magic_wheel thread magic_wheel_delete_fx();
	level.magic_wheel_triggers[ old_index ] thread magic_wheel_set_model(false, false);
	level.magic_wheel_triggers[ old_index ] setHintString( magic_wheel_text(old_index, false) );

	wait 5;

	level.zombie_vars[ "magic_wheel_index" ] = next_box;

	level.magic_wheel_triggers[ level.zombie_vars[ "magic_wheel_index" ] ].active = true;
	level.magic_wheel_triggers[ level.zombie_vars[ "magic_wheel_index" ] ].magic_wheel thread magic_wheel_create_fx();
	level.magic_wheel_triggers[ level.zombie_vars[ "magic_wheel_index" ] ] thread magic_wheel_set_model(false, true);
	level.magic_wheel_triggers[ level.zombie_vars[ "magic_wheel_index" ] ] setHintString( magic_wheel_text(next_box, false) );
}

_debug_magic_wheel_print( str )
{
	//iprintln(str);
}