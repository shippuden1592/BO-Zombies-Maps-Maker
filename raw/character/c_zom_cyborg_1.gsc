// THIS FILE IS AUTOGENERATED, DO NOT MODIFY
main()
{
	self setModel("c_zom_garbageman_body");
	self.headModel = "c_zom_garbageman_head";
	self attach(self.headModel, "", true);
	self.voice = "american";
	self.skeleton = "base";
	self.torsoDmg1 = "c_zom_garbageman_body_upclean";
	self.torsoDmg2 = "c_zom_garbageman_body_rarmoff_1";
	self.torsoDmg3 = "c_zom_garbageman_body_larmoff_1";
	self.torsoDmg5 = "c_zom_garbageman_body_behead";
	self.legDmg1 = "c_zom_garbageman_body_lowclean";
	self.legDmg2 = "c_zom_garbageman_body_rlegoff_1";
	self.legDmg3 = "c_zom_garbageman_body_llegoff_1";
	self.legDmg4 = "c_zom_garbageman_body_legsoff_1";
	self.gibSpawn1 = "c_zom_garbageman_body_rarmspawn";
	self.gibSpawnTag1 = "J_ELBOW_RI";
	self.gibSpawn2 = "c_zom_garbageman_body_larmspawn";
	self.gibSpawnTag2 = "J_ELBOW_LE";
	self.gibSpawn3 = "c_zom_garbageman_body_rlegspawn";
	self.gibSpawnTag3 = "J_KNEE_RI";
	self.gibSpawn4 = "c_zom_garbageman_body_llegspawn";
	self.gibSpawnTag4 = "J_KNEE_LE";
}

precache()
{
	precacheModel("c_zom_garbageman_body");
	precacheModel("c_zom_garbageman_head");
	precacheModel("c_zom_garbageman_body_upclean");
	precacheModel("c_zom_garbageman_body_rarmoff_1");
	precacheModel("c_zom_garbageman_body_larmoff_1");
	precacheModel("c_zom_garbageman_body_behead");
	precacheModel("c_zom_garbageman_body_lowclean");
	precacheModel("c_zom_garbageman_body_rlegoff_1");
	precacheModel("c_zom_garbageman_body_llegoff_1");
	precacheModel("c_zom_garbageman_body_legsoff_1");
	precacheModel("c_zom_garbageman_body_rarmspawn");
	precacheModel("c_zom_garbageman_body_larmspawn");
	precacheModel("c_zom_garbageman_body_rlegspawn");
	precacheModel("c_zom_garbageman_body_llegspawn");
	precacheModel("c_zom_garbageman_body_upclean");
	precacheModel("c_zom_garbageman_body_rarmoff_1");
	precacheModel("c_zom_garbageman_body_larmoff_1");
	precacheModel("c_zom_garbageman_body_behead");
	precacheModel("c_zom_garbageman_body_lowclean");
	precacheModel("c_zom_garbageman_body_rlegoff_1");
	precacheModel("c_zom_garbageman_body_llegoff_1");
	precacheModel("c_zom_garbageman_body_legsoff_1");
	precacheModel("c_zom_garbageman_body_rarmspawn");
	precacheModel("c_zom_garbageman_body_larmspawn");
	precacheModel("c_zom_garbageman_body_rlegspawn");
	precacheModel("c_zom_garbageman_body_llegspawn");
}
