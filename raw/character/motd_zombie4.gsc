// THIS FILE IS AUTOGENERATED, DO NOT MODIFY
main()
{
	self setModel("c_zom_guard_body");
	self.headModel = codescripts\character::randomElement(xmodelalias\c_zom_prison_guard_head_als::main());
	self attach(self.headModel, "", true);
	self.hatModel = "c_zom_guard_hat";
	self attach(self.hatModel);
	self.voice = "american";
	self.skeleton = "base";
	self.torsoDmg1 = "c_zom_guard_body_g_upclean";
	self.torsoDmg2 = "c_zom_guard_body_g_rarmoff";
	self.torsoDmg3 = "c_zom_guard_body_g_larmoff";
	self.torsoDmg5 = "c_zom_inmate_body2_g_behead";
	self.legDmg1 = "c_zom_guard_body_g_lowclean";
	self.legDmg2 = "c_zom_guard_body_g_rlegoff";
	self.legDmg3 = "c_zom_guard_body_g_llegoff";
	self.legDmg4 = "c_zom_guard_body_g_legsoff";
	self.gibSpawn1 = "c_zom_inmate_g_rarmspawn";
	self.gibSpawnTag1 = "j_elbow_ri";
	self.gibSpawn2 = "c_zom_inmate_g_larmspawn";
	self.gibSpawnTag2 = "j_elbow_le";
	self.gibSpawn3 = "c_zom_inmate_g_rlegspawn";
	self.gibSpawnTag3 = "j_knee_ri";
	self.gibSpawn4 = "c_zom_inmate_g_llegspawn";
	self.gibSpawnTag4 = "j_knee_le";
}

precache()
{
	precacheModel("c_zom_guard_body");
	codescripts\character::precacheModelArray(xmodelalias\c_zom_prison_guard_head_als::main());
	precacheModel("c_zom_guard_hat");
	precacheModel("c_zom_guard_body_g_upclean");
	precacheModel("c_zom_guard_body_g_rarmoff");
	precacheModel("c_zom_guard_body_g_larmoff");
	precacheModel("c_zom_inmate_body2_g_behead");
	precacheModel("c_zom_guard_body_g_lowclean");
	precacheModel("c_zom_guard_body_g_rlegoff");
	precacheModel("c_zom_guard_body_g_llegoff");
	precacheModel("c_zom_guard_body_g_legsoff");
	precacheModel("c_zom_inmate_g_rarmspawn");
	precacheModel("c_zom_inmate_g_larmspawn");
	precacheModel("c_zom_inmate_g_rlegspawn");
	precacheModel("c_zom_inmate_g_llegspawn");
	precacheModel("c_zom_guard_body_g_upclean");
	precacheModel("c_zom_guard_body_g_rarmoff");
	precacheModel("c_zom_guard_body_g_larmoff");
	precacheModel("c_zom_inmate_body2_g_behead");
	precacheModel("c_zom_guard_body_g_lowclean");
	precacheModel("c_zom_guard_body_g_rlegoff");
	precacheModel("c_zom_guard_body_g_llegoff");
	precacheModel("c_zom_guard_body_g_legsoff");
	precacheModel("c_zom_inmate_g_rarmspawn");
	precacheModel("c_zom_inmate_g_larmspawn");
	precacheModel("c_zom_inmate_g_rlegspawn");
	precacheModel("c_zom_inmate_g_llegspawn");
}
