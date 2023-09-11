#include maps\_utility; 
#include common_scripts\utility; 
#include maps\_zombiemode_utility;

#using_animtree( "pack_a_punch" );

init()
{
	PreCacheModel( "iw_pap_machine" );
	flag_init("pack_machine_in_use");

	vending_weapon_upgrade_trigger = GetEntArray("zombie_vending_upgrade_iw", "targetname");

	if ( vending_weapon_upgrade_trigger.size >= 1 )
	{
		array_thread( vending_weapon_upgrade_trigger, ::vending_weapon_upgrade );

		for( i = 0; i < vending_weapon_upgrade_trigger.size; i++)
		{
			vending_weapon_upgrade_trigger[i].perk_machine = GetEnt( vending_weapon_upgrade_trigger[i].target, "targetname" );
			vending_weapon_upgrade_trigger[i].perk_machine.angles = vending_weapon_upgrade_trigger[i].perk_machine.angles + (0, 180, 0);
			vending_weapon_upgrade_trigger[i].perk_machine SetModel( "iw_pap_machine" );
			vending_weapon_upgrade_trigger[i].perk_machine UseAnimTree(#animtree);
			vending_weapon_upgrade_trigger[i].perk_machine SetAnimKnob(%zmb_papa_machine_open, 1, 0, 1);
		}
	}

	PrecacheItem( "zombie_knuckle_crack" );

	level._effect["packapunch_fx"] = loadfx("maps/zombie/fx_zombie_packapunch");
	level._effect["fx_pap_smoke_left"] = loadfx("IW/fx_pap_smoke_left");
	level._effect["fx_pap_smoke_up"] = loadfx("IW/fx_pap_smoke_up");

	if( !isDefined( level.packapunch_timeout ) )
		level.packapunch_timeout = 15;

	PrecacheString( &"ZOMBIE_PERK_PACKAPUNCH" );

	level thread turn_PackAPunch_on();
}

third_person_weapon_upgrade( current_weapon, origin, angles, packa_rollers, perk_machine )
{
	forward = anglesToForward( angles );
	interact_pos = origin + (forward*-25);
	PlayFx( level._effect["packapunch_fx"], origin+(5,1,-34), forward );
	
	worldgun = spawn( "script_model", interact_pos );
	worldgun.angles  = self.angles;
	worldgun setModel( GetWeaponModel( current_weapon ) );
	worldgun useweaponhidetags( current_weapon );
	worldgun rotateto( angles+(0,90,0), 0.35, 0, 0 );

	offsetdw = ( 3, 3, 3 );
	worldgundw = undefined;
	if ( maps\_zombiemode_weapons::weapon_is_dual_wield( current_weapon ) )
	{
		worldgundw = spawn( "script_model", interact_pos + offsetdw );
		worldgundw.angles  = self.angles;

		worldgundw setModel( maps\_zombiemode_weapons::get_left_hand_weapon_model_name( current_weapon ) );
		worldgundw useweaponhidetags( current_weapon );
		worldgundw rotateto( angles+(0,90,0), 0.35, 0, 0 );
	}

	wait( 0.5 );

	worldgun moveto( origin, 0.5, 0, 0 );
	if ( isdefined( worldgundw ) )
	{
		worldgundw moveto( origin + offsetdw, 0.5, 0, 0 );
	}

	self playsound( "zmb_perks_packa_upgrade" );

	perk_machine SetAnimKnob(%zmb_papa_machine_close, 1, 0, 1);

	wait( 0.35 );

	worldgun delete();
	if ( isdefined( worldgundw ) )
	{
		worldgundw delete();
	}

	PlayFX(level._effect[ "fx_pap_smoke_left" ], perk_machine GetTagOrigin( "tag_fx" ) );
	PlayFX(level._effect[ "fx_pap_smoke_up" ], perk_machine GetTagOrigin( "tag_fx2" ) );

	perk_machine SetAnimKnob(%zmb_papa_machine_running, 1, 0, 1);

	wait( 3 );

	perk_machine SetAnimKnob(%zmb_papa_machine_open, 1, 0, 1);

	self playsound( "zmb_perks_packa_ready" );

	worldgun = spawn( "script_model", origin );
	worldgun.angles  = angles+(0,90,0);
	worldgun setModel( GetWeaponModel( level.zombie_weapons[current_weapon].upgrade_name ) );
	worldgun useweaponhidetags( level.zombie_weapons[current_weapon].upgrade_name );
	worldgun moveto( interact_pos, 0.5, 0, 0 );

	worldgundw = undefined;
	if ( maps\_zombiemode_weapons::weapon_is_dual_wield( level.zombie_weapons[current_weapon].upgrade_name ) )
	{
		worldgundw = spawn( "script_model", origin + offsetdw );
		worldgundw.angles  = angles+(0,90,0);

		worldgundw setModel( maps\_zombiemode_weapons::get_left_hand_weapon_model_name( level.zombie_weapons[current_weapon].upgrade_name ) );
		worldgundw useweaponhidetags( level.zombie_weapons[current_weapon].upgrade_name );
		worldgundw moveto( interact_pos + offsetdw, 0.5, 0, 0 );
	}

	wait( 0.5 );

	worldgun moveto( origin, level.packapunch_timeout, 0, 0);
	if ( isdefined( worldgundw ) )
	{
		worldgundw moveto( origin + offsetdw, level.packapunch_timeout, 0, 0);
	}

	worldgun.worldgundw = worldgundw;
	return worldgun;
}

vending_weapon_upgrade()
{
	perk_machine_sound = GetEntarray ( "perksacola", "targetname");
	packa_rollers = spawn("script_origin", self.origin);
	packa_timer = spawn("script_origin", self.origin);
	packa_rollers LinkTo( self );
	packa_timer LinkTo( self );

	self UseTriggerRequireLookAt();
	self SetHintString( &"ZOMBIE_NEED_POWER" );
	self SetCursorHint( "HINT_NOICON" );
	
	level waittill("Pack_A_Punch_on");

	self thread maps\_zombiemode_perks::vending_machine_trigger_think();
	self thread maps\_zombiemode_weapons::decide_hide_show_hint();

	self.perk_machine playloopsound("zmb_perks_packa_loop");

	self thread maps\_zombiemode_perks::vending_weapon_upgrade_cost();

	for( ;; )
	{
		self waittill( "trigger", player );		
				
		index = maps\_zombiemode_weapons::get_player_index(player);	
		plr = "zmb_vox_plr_" + index + "_";
		current_weapon = player getCurrentWeapon();

		if ( "microwavegun_zm" == current_weapon )
		{
			current_weapon = "microwavegundw_zm";
		}

		if( !player maps\_zombiemode_weapons::can_buy_weapon() ||
			player maps\_laststand::player_is_in_laststand() ||
			is_true( player.intermission ) ||
			player isThrowingGrenade() ||
			player maps\_zombiemode_weapons::is_weapon_upgraded( current_weapon ) )
		{
			wait( 0.1 );
			continue;
		}

		if( is_true(level.pap_moving))
		{
			continue;
		}
		
 		if( player isSwitchingWeapons() )
 		{
 			wait(0.1);
 			continue;
 		}

		if ( !IsDefined( level.zombie_include_weapons[current_weapon] ) )
		{
			continue;
		}

		if ( player.score < self.cost )
		{
			self playsound("deny");
			player maps\_zombiemode_audio::create_and_play_dialog( "general", "perk_deny", undefined, 0 );
			continue;
		}

		flag_set("pack_machine_in_use");
		
		player maps\_zombiemode_score::minus_to_player_score( self.cost ); 
		sound = "evt_bottle_dispense";
		playsoundatposition(sound, self.origin);

		self thread maps\_zombiemode_audio::play_jingle_or_stinger("mus_perks_packa_sting");
		player maps\_zombiemode_audio::create_and_play_dialog( "weapon_pickup", "upgrade_wait" );

		origin = self.origin;
		angles = self.angles;
		
		if( isDefined(self.perk_machine))
		{
			origin = self.perk_machine.origin+(0,0,55);
			angles = self.perk_machine.angles+(0,90,0)+(0,-180,0);
		}

		self disable_trigger();
		
		player thread maps\_zombiemode_perks::do_knuckle_crack();

		self.current_weapon = current_weapon;
											
		weaponmodel = player third_person_weapon_upgrade( current_weapon, origin, angles, packa_rollers, self.perk_machine );

		self enable_trigger();
		self SetHintString( &"ZOMBIE_GET_UPGRADED" );
		self setvisibletoplayer( player );

		self thread maps\_zombiemode_perks::wait_for_player_to_take( player, current_weapon, packa_timer );
		self thread maps\_zombiemode_perks::wait_for_timeout( current_weapon, packa_timer );
		
		self waittill_either( "pap_timeout", "pap_taken" );
		
		self.current_weapon = "";
		if ( isdefined( weaponmodel.worldgundw ) )
		{
			weaponmodel.worldgundw delete();
		}
		weaponmodel delete();
		self SetHintString( &"ZOMBIE_PERK_PACKAPUNCH", self.cost );
		self setvisibletoall();
		flag_clear("pack_machine_in_use");
	}
}

turn_PackAPunch_on()
{
	level waittill("Pack_A_Punch_on");

	vending_weapon_upgrade_trigger = GetEntArray("zombie_vending_upgrade_iw", "targetname");
	for( i = 0; i < vending_weapon_upgrade_trigger.size; i++ )
	{
		if( IsDefined( vending_weapon_upgrade_trigger[i].perk_machine ) )
		{
			vending_weapon_upgrade_trigger[i].perk_machine thread activate_PackAPunch();
		}
	}
}

activate_PackAPunch()
{
	self playsound("zmb_perks_power_on");
	self vibrate((0,-100,0), 0.3, 0.4, 3);
	self SetModel( "iw_pap_machine" );

	level notify( "Carpenter_On" );
}