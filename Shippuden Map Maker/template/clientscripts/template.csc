#include clientscripts\_utility;
#include clientscripts\_music;
#include clientscripts\_zombiemode_weapons;
main()
{
	level._uses_crossbow = true;
	
	// ww: thundergun init happens in _zombiemode.csc so the weapons need to be setup before _zombiemode::main is
	include_weapons();
	// _load!
	clientscripts\_zombiemode::main();
	clientscripts\template_fx::main();
	thread clientscripts\template_amb::main();

	clientscripts\_zombiemode_deathcard::init();
	
	// This needs to be called after all systems have been registered.
	thread waitforclient(0);	
	
	level._power_on = false;
	
	
	register_zombie_types();
}
register_zombie_types()
{
	character\clientscripts\c_ger_honorguard_zt::register_gibs();	
	character\clientscripts\c_zom_quad::register_gibs();
	//REGISTER_ZOMBIES_GIBS_0
	//REGISTER_ZOMBIES_GIBS_1
	character\clientscripts\c_usa_pent_zombie_scientist::register_gibs();
	character\clientscripts\c_usa_pent_zombie_officeworker::register_gibs();
	character\clientscripts\c_usa_pent_zombie_militarypolice::register_gibs();
	//REGISTER_ZOMBIES_GIBS_2
	character\clientscripts\c_zom_cosmo_cosmonaut::register_gibs();
	character\clientscripts\c_zom_cosmo_scientist::register_gibs();
	character\clientscripts\c_zom_cosmo_spetznaz::register_gibs();
	//REGISTER_ZOMBIES_GIBS_3
	character\clientscripts\c_zom_barechest::register_gibs();
	character\clientscripts\c_zom_scuba::register_gibs();
	character\clientscripts\c_zom_soldier::register_gibs();
	//REGISTER_ZOMBIES_GIBS_4
	character\clientscripts\c_viet_zombie_female_body::register_gibs();
	character\clientscripts\c_viet_zombie_female_body_alt::register_gibs();
	character\clientscripts\c_viet_zombie_nva1::register_gibs();
	character\clientscripts\c_viet_zombie_nva1_alt::register_gibs();
	//REGISTER_ZOMBIES_GIBS_5
	character\clientscripts\c_zom_zombie_1::register_gibs();
	character\clientscripts\c_zom_zombie_2::register_gibs();
	character\clientscripts\c_zom_zombie_2_2::register_gibs();
	character\clientscripts\c_zom_zombie_3::register_gibs();
	character\clientscripts\c_zom_zombie_3_2::register_gibs();
	character\clientscripts\c_zom_zombie_3_3::register_gibs();
	character\clientscripts\c_zom_zombie_3_4::register_gibs();
	character\clientscripts\c_zom_zombie_3_5::register_gibs();
	//REGISTER_ZOMBIES_GIBS_6
	character\clientscripts\c_zom_dlc0_hazmat_1::register_gibs();
	character\clientscripts\c_zom_dlc0_hazmat_2::register_gibs();
	character\clientscripts\c_zom_dlc0_soldier_1::register_gibs();
	character\clientscripts\c_zom_dlc0_soldier_2::register_gibs();
	//REGISTER_ZOMBIES_GIBS_7
	character\clientscripts\motd_zombie1::register_gibs();
	character\clientscripts\motd_zombie2::register_gibs();
	character\clientscripts\motd_zombie3::register_gibs();
	character\clientscripts\motd_zombie4::register_gibs();
	//REGISTER_ZOMBIES_GIBS_8
	character\clientscripts\c_zom_pirate_male_a::register_gibs();
	character\clientscripts\c_zom_pirate_male_b::register_gibs();
	character\clientscripts\c_zom_tourist_female_a::register_gibs();
	character\clientscripts\c_zom_tourist_female_b::register_gibs();
	character\clientscripts\c_zom_tourist_male_a::register_gibs();
	character\clientscripts\c_zom_tourist_male_b::register_gibs();
	//REGISTER_ZOMBIES_GIBS_9
	character\clientscripts\c_zom_cyborg_1::register_gibs();
	character\clientscripts\c_zom_cyborg_2::register_gibs();
	character\clientscripts\c_zom_cyborg_3::register_gibs();
	character\clientscripts\c_zom_cyborg_4::register_gibs();
	//REGISTER_ZOMBIES_GIBS_10

	// Register gibs for zombie_pentagon zombies (Enable if used)
	//character\clientscripts\c_usa_pent_zombie_scientist::register_gibs();
	//character\clientscripts\c_usa_pent_zombie_officeworker::register_gibs();
	//character\clientscripts\c_usa_pent_zombie_militarypolice::register_gibs();
}	
/*****************************************************************************
// WEAPON FUNCTIONS
//
// Include the weapons that are only in your level so that the cost/hints are accurate
// Also adds these weapons to the random treasure chest.
//***************************************************************************** */
include_weapons()
{
	//POWER_UP_MINIGUN
	include_weapon( "minigun_zm", false );
	include_weapon( "minigun_upgraded_zm", false );
	
	include_weapon( "frag_grenade_zm", false );
	include_weapon( "claymore_zm", false );
	//	Weapons - Pistols
	include_weapon( "m1911_zm", false );						// colt
	include_weapon( "m1911_upgraded_zm", false );
	include_weapon( "python_zm" );						// 357
	include_weapon( "python_upgraded_zm", false );
  	include_weapon( "cz75_zm" );
  	include_weapon( "cz75_upgraded_zm", false );
	//	Weapons - Semi-Auto Rifles
	include_weapon( "m14_zm", false );							// gewehr43
	include_weapon( "m14_upgraded_zm", false );
	//	Weapons - Burst Rifles
	include_weapon( "m16_zm", false );						
	include_weapon( "m16_gl_upgraded_zm", false );
	include_weapon( "g11_lps_zm" );
	include_weapon( "g11_lps_upgraded_zm", false );
	include_weapon( "famas_zm" );
	include_weapon( "famas_upgraded_zm", false );
	//	Weapons - SMGs
	include_weapon( "ak74u_zm", false );						// thompson, mp40, bar
	include_weapon( "ak74u_upgraded_zm", false );
	include_weapon( "mp5k_zm", false );
	include_weapon( "mp5k_upgraded_zm", false );
	include_weapon( "mp40_zm", false );
	include_weapon( "mp40_upgraded_zm", false );
	include_weapon( "mpl_zm", false );
	include_weapon( "mpl_upgraded_zm", false );
	include_weapon( "pm63_zm", false );
	include_weapon( "pm63_upgraded_zm", false );
	include_weapon( "spectre_zm" );
	include_weapon( "spectre_upgraded_zm", false );
	//	Weapons - Dual Wield
  	include_weapon( "cz75dw_zm" );
  	include_weapon( "cz75dw_upgraded_zm", false );
	//	Weapons - Shotguns
	include_weapon( "ithaca_zm", false );						// shotgun
	include_weapon( "ithaca_upgraded_zm", false );
	include_weapon( "rottweil72_zm", false );
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
}
