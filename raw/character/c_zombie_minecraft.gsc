// THIS FILE IS AUTOGENERATED, DO NOT MODIFY
main()
{
	self setModel("c_zom_minecraft_body");
	self.headModel = "c_zom_minecraft_head";
	self attach(self.headModel, "", true);
	self.voice = "german";
	self.skeleton = "base";
	self.torsoDmg5 = "char_ger_honorgd_body1_g_behead";
}

precache()
{
	precacheModel("c_zom_minecraft_body");
	precacheModel("c_zom_minecraft_head");
	precacheModel("char_ger_honorgd_body1_g_behead");
}
