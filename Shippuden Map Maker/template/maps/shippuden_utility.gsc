//================================================================================================
// Nombre del Archivo 	: shippuden_utility.gsc
// Version		: 1.4
// Autor     		: Shippuden1592
// Foro			: CCM(http://customcodmapping.foroactivo.com/)
// YouTube		: https://www.youtube.com/user/shippuden1592
//================================================================================================
#include maps\_utility; 
#include common_scripts\utility;
#include maps\_zombiemode_utility;
#include maps\_hud_util;

#using_animtree( "generic_human" );

client_check_for_dw_fire()
{
	self endon("disconnect");
	oldweapon = self GetCurrentWeapon();
	oldammo = self GetWeaponAmmoClip( oldweapon );
	oldammolh = self GetWeaponAmmoLhClip( oldweapon );
	while( 1 )
	{
		wait 0.05;
		weapon = self GetCurrentWeapon();
		ammo = self GetWeaponAmmoClip( weapon );
		ammolh = self GetWeaponAmmoLhClip( weapon );

		if( oldammolh != ammolh || oldammo != ammo || oldweapon != weapon )
	    {
			if( weapon == "mk3_zm" || weapon == "mk3_upgraded_zm" )
            {
				if( oldammo == ( ammo + 1 ) && oldweapon == weapon )
				{
					if(weapon == "mk3_zm")
						setclientsysstate( "levelNotify", "dw_mk3_rh_fired", self );
					else
						setclientsysstate( "levelNotify", "dw_mk3_rh_fired_ug", self );
				}
				if( oldammolh == ( ammolh + 1 ) && oldweapon == weapon )
		        {
                    setclientsysstate( "levelNotify", "dw_mk3_lh_fired", self );
				}
			}
			oldweapon = weapon;
			oldammo = ammo;
			oldammolh = ammolh;
		}
	}
}

GetWeaponAmmoLhClip( weapon )
{
	dw_weapon = WeaponDualWieldWeaponName( weapon );
	if( dw_weapon != "none" )
	{
		return self GetWeaponAmmoClip( dw_weapon );
	}
	return -1;
}

Is_Boss(zombie)
{
	if( IsDefined( zombie.is_hazmat ) && zombie.is_hazmat )
		return true;

	if( IsDefined( zombie.is_exo ) && zombie.is_exo )
		return true;

	switch(zombie.animname)
	{
		case "alien_zombie":
		case "avogadro_zombie":
		case "brute_zombie":
		case "brutecrab_zombie":
		case "brutus_zombie":
		case "clown_zombie":
		case "destroyer_zombie":
		case "fireman_zombie":
		case "goliath_zombie":
		case "mangler_zombie":
		case "margwa_zombie":
		case "mech_zombie":
		case "megaton_zombie":
		case "radz_left_zombie":
		case "radz_right_zombie":
		case "minicrab_zombie":
		case "slasher_zombie":
		case "spider_zombie":
		case "napalm_zombie":
		case "ape_zombie":
			return true;
		default:
			return false;
	}
}

get_boss_point( targetBoss )
{
	chosen_spot = undefined;
	boss_points = GetEntArray( targetBoss, "targetname" );

	boss_points = array_randomize( boss_points );

	for( i = 0; i < boss_points.size; i++ )
	{
		if( check_point_in_active_zone( boss_points[i].origin ) )
		{
			chosen_spot = boss_points[i];
			break;
		}
	}

	return chosen_spot;
}

get_boss_struct_point( boss_struct_points )
{
	chosen_spot = undefined;

	boss_struct_points = array_randomize( boss_struct_points );

	for( i = 0; i < boss_struct_points.size; i++ )
	{
		if( check_point_in_active_zone( boss_struct_points[i] ) )
		{
			chosen_spot = boss_struct_points[i];
			break;
		}
	}
	
	return chosen_spot;
}

get_round_enemy_array()
{
	ai_enemies = GetAiSpeciesArray( "axis", "all" );
	ai_valid_enemies = [];

	for(i = 0; i < ai_enemies.size; i++)
	{
		if(is_true(ai_enemies[i].ignore_enemy_count))
			continue;

		ai_valid_enemies[ai_valid_enemies.size] = ai_enemies[i];
	}
	return ai_valid_enemies;
}

get_boss_count( animname )
{
	count = 0;
	ai_enemies = GetAiSpeciesArray( "axis", "all" );
	for(i = 0; i < ai_enemies.size; i++)
	{
		if(is_true(ai_enemies[i].animname) && ai_enemies[i].animname == animname)
			count++;
	}
	return count;
}

create_progressbar( player, color, color2, width, height )
{
	barElem = create_simple_hud(player);
	barElem.x = 0;
	barElem.y = 0;
	barElem.frac = 0;
	barElem.color = color;
	barElem.sort = -2;
	barElem.shader = "white";
	barElem setShader("white", width, height);
	
	barElemBG = create_simple_hud(player);
	barElemBG.elemType = "bar";
	barElemBG.x = -2;
	barElemBG.y = -2;
	barElemBG.width = width;
	barElemBG.height = height;
	barElemBG.xOffset = 0;
	barElemBG.yOffset = 0;
	barElemBG.bar = barElem;
	barElemBG.children = [];
	barElemBG.sort = -3;
	barElemBG.color = color2;//(0,0,0);
	barElemBG.alpha = 0.5;
	barElemBG.shader = "white";
	barElemBG setShader( "white", width + 4, height + 4 );

	barElemBG setPoint("TOP", undefined, 0, 10);
	
	barElem.y += 2; // Must do this after	
	barElemBG progressbar_setvalue(0, 100);

	progressbar = [];
	progressbar["background"] = barElem;
	progressbar["backgroundPercentage"] = barElemBG;

	return progressbar;
}

progressbar_setvalue(value, total)
{
	if(total < 1 || value > total || value < 0)
		return;
	
	self.bar.frac = value;
	
	if(value == 0)
	{
		self.bar setShader("black", 1, self.height);
		self.bar.alpha = 0;
		return;
	}
	else
	{
		self.bar setShader("white", 1, self.height);
		self.bar.alpha = 1;
	}	
	
	width = int((value / total) * self.width);
	
	if(width == 0)
		width = 1;
	
	self.bar setShader(self.bar.shader, width, self.height);
}

create_gib_ref()
{
	if( !self.gibbed )
	{
		refs = [];
		refs[refs.size] = "guts";
		refs[refs.size] = "right_arm"; 
		refs[refs.size] = "left_arm"; 
		refs[refs.size] = "right_leg"; 
		refs[refs.size] = "left_leg"; 
		refs[refs.size] = "no_legs";

		self.a.gib_ref = animscripts\zombie_death::get_random( refs );
		if( ( self.a.gib_ref == "no_legs" || self.a.gib_ref == "right_leg" || self.a.gib_ref == "left_leg" ) && self.health > 0 )
		{
			self.has_legs = false; 
			self AllowedStances( "crouch" );
			self setPhysParams( 15, 0, 24 );
			
			if(self.a.gib_ref == "no_legs")
			{
				hand_attack = 1; 
				if(randomint(100) > 50)
					hand_attack = 2;

				self.deathanim = %ai_zombie_crawl_death_v1;
				self set_run_anim( "death3" );
				self.run_combatanim = level.scr_anim[self.animname]["crawl_hand_" + hand_attack];
				self.crouchRunAnim = level.scr_anim[self.animname]["crawl_hand_" + hand_attack];
				self.crouchrun_combatanim = level.scr_anim[self.animname]["crawl_hand_" + hand_attack];
			}
			else
			{
				which_anim = RandomIntRange(1, 5);
				death_anim = %ai_zombie_crawl_death_v1;
				if( which_anim == 1 || which_anim == 3)
					death_anim = %ai_zombie_crawl_death_v2;

				self.deathanim = death_anim;
				self set_run_anim( "death3" );
				self.run_combatanim = level.scr_anim[self.animname]["crawl" + which_anim];
				self.crouchRunAnim = level.scr_anim[self.animname]["crawl" + which_anim];
				self.crouchrun_combatanim = level.scr_anim[self.animname]["crawl" + which_anim];
			}
		}

		if( self.health > 0 )
		{
			self thread animscripts\zombie_death::do_gib();
		}
	}
}