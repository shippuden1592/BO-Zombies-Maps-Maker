// THIS FILE IS AUTOGENERATED, DO NOT MODIFY
main()
{
	self setModel("c_zom_zombie3_body03");
	self.headModel = "c_zom_zombie_head_l";
	self attach(self.headModel, "", true);
	self.voice = "american";
	self.skeleton = "base";
	self.torsoDmg1 = "c_zom_zombie3_body03_g_upclean";
	self.torsoDmg2 = "c_zom_zombie3_body03_g_rarmoff";
	self.torsoDmg3 = "c_zom_zombie3_body03_g_larmoff";
	self.torsoDmg5 = "c_zom_zombie2_body01_g_behead";
	self.legDmg1 = "c_zom_zombie3_body03_g_lowclean";
	self.legDmg2 = "c_zom_zombie3_body03_g_rlegoff";
	self.legDmg3 = "c_zom_zombie3_body03_g_llegoff";
	self.legDmg4 = "c_zom_zombie3_body03_g_legsoff";
	self.gibSpawn1 = "c_zom_zombie_g_rarmspawn";
	self.gibSpawnTag1 = "J_ELBOW_RI";
	self.gibSpawn2 = "c_zom_zombie_g_larmspawn";
	self.gibSpawnTag2 = "J_EBLOW_LE";
	self.gibSpawn3 = "c_zom_zombie_g_rlegspawn";
	self.gibSpawnTag3 = "J_KNEE_RI";
	self.gibSpawn4 = "c_zom_zombie_g_llegspawn";
	self.gibSpawnTag4 = "J_KNEE_LE";
}

precache()
{
	precacheModel("c_zom_zombie3_body03");
	precacheModel("c_zom_zombie_head_l");
	precacheModel("c_zom_zombie3_body03_g_upclean");
	precacheModel("c_zom_zombie3_body03_g_rarmoff");
	precacheModel("c_zom_zombie3_body03_g_larmoff");
	precacheModel("c_zom_zombie2_body01_g_behead");
	precacheModel("c_zom_zombie3_body03_g_lowclean");
	precacheModel("c_zom_zombie3_body03_g_rlegoff");
	precacheModel("c_zom_zombie3_body03_g_llegoff");
	precacheModel("c_zom_zombie3_body03_g_legsoff");
	precacheModel("c_zom_zombie_g_rarmspawn");
	precacheModel("c_zom_zombie_g_larmspawn");
	precacheModel("c_zom_zombie_g_rlegspawn");
	precacheModel("c_zom_zombie_g_llegspawn");
	precacheModel("c_zom_zombie3_body03_g_upclean");
	precacheModel("c_zom_zombie3_body03_g_rarmoff");
	precacheModel("c_zom_zombie3_body03_g_larmoff");
	precacheModel("c_zom_zombie2_body01_g_behead");
	precacheModel("c_zom_zombie3_body03_g_lowclean");
	precacheModel("c_zom_zombie3_body03_g_rlegoff");
	precacheModel("c_zom_zombie3_body03_g_llegoff");
	precacheModel("c_zom_zombie3_body03_g_legsoff");
	precacheModel("c_zom_zombie_g_rarmspawn");
	precacheModel("c_zom_zombie_g_larmspawn");
	precacheModel("c_zom_zombie_g_rlegspawn");
	precacheModel("c_zom_zombie_g_llegspawn");
}
