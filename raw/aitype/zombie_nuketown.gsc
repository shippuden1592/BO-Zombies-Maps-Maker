// THIS FILE IS AUTOGENERATED, DO NOT MODIFY
/*QUAKED actor_zombie_nuketown (1.0 0.25 0.0) (-16 -16 0) (16 16 72) SPAWNER MAKEROOM UNDELETABLE ENEMYINFO SCRIPT_FORCESPAWN SM_PRIORITY
defaultmdl="c_zom_dlc0_zom_haz_body2"
"count" -- max AI to ever spawn from this spawner
SPAWNER -- makes this a spawner instead of a guy
MAKEROOM -- will try to delete an AI if spawning fails from too many AI
UNDELETABLE -- this AI (or AI spawned from here) cannot be deleted to make room for MAKEROOM guys
ENEMYINFO -- this AI when spawned will get a snapshot of perfect info about all enemies
SCRIPT_FORCESPAWN -- this AI will spawned even if players can see him spawning.
SM_PRIORITY -- Make the Spawn Manager spawn from this spawner before other spawners.
*/
main()
{
	self.animTree = "";
	self.team = "axis";
	self.type = "zombie";
	self.accuracy = 0.2;
	self.health = 150;
	self.weapon = "defaultweapon";
	self.secondaryweapon = "";
	self.sidearm = "defaultweapon";
	self.grenadeWeapon = "";
	self.grenadeAmmo = 0;
	self.csvInclude = "";

	self setEngagementMinDist( 256.000000, 0.000000 );
	self setEngagementMaxDist( 768.000000, 1024.000000 );
	
	switch( codescripts\character::get_random_character(4) )
	{
	case 0:
		character\c_zom_dlc0_hazmat_1::main();
		break;
	case 1:
		character\c_zom_dlc0_hazmat_2::main();
		break;
	case 2:
		character\c_zom_dlc0_soldier_1::main();
		break;
	case 3:
		character\c_zom_dlc0_soldier_2::main();
		break;
	}
}

spawner()
{
	self setspawnerteam("axis");
}

precache()
{
	character\c_zom_dlc0_hazmat_1::precache();
	character\c_zom_dlc0_hazmat_2::precache();
	character\c_zom_dlc0_soldier_1::precache();
	character\c_zom_dlc0_soldier_2::precache();

	precacheItem("defaultweapon");
	precacheItem("defaultweapon");
}
