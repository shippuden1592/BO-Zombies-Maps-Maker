// THIS FILE IS AUTOGENERATED, DO NOT MODIFY
main()
{
	self setModel("c_tourist_female_a_fullbody");
	self.headModel = "c_tourist_female_a_fullbody_head";
	self attach(self.headModel, "", true);
	self.voice = "american";
	self.skeleton = "base";
	self.torsoDmg5 = "c_civ_female_a_behead";
	self.gibSpawn1 = "c_zom_zombie_g_rarmspawn";
	self.gibSpawnTag1 = "J_ELBOW_RI";
	self.gibSpawn2 = "c_zom_zombie_g_larmspawn";
	self.gibSpawnTag2 = "J_ELBOW_LE";
	self.gibSpawn3 = "c_zom_zombie_g_rlegspawn";
	self.gibSpawnTag3 = "J_KNEE_RI";
	self.gibSpawn4 = "c_zom_zombie_g_llegspawn";
	self.gibSpawnTag4 = "J_KNEE_LE";
}

precache()
{
	precacheModel("c_tourist_female_a_fullbody");
	precacheModel("c_tourist_female_a_fullbody_head");
	precacheModel("c_civ_female_a_behead");
	precacheModel("c_zom_zombie_g_rarmspawn");
	precacheModel("c_zom_zombie_g_larmspawn");
	precacheModel("c_zom_zombie_g_rlegspawn");
	precacheModel("c_zom_zombie_g_llegspawn");
	precacheModel("c_civ_female_a_behead");
	precacheModel("c_zom_zombie_g_rarmspawn");
	precacheModel("c_zom_zombie_g_larmspawn");
	precacheModel("c_zom_zombie_g_rlegspawn");
	precacheModel("c_zom_zombie_g_llegspawn");
}