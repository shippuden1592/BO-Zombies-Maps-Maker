#include maps\_hud_util;
precache()
{
	precacheShader( "damage_feedback" );
}
init()
{	
	//precacheShader( "damage_feedback" );
	
	//if ( getDvar( "scr_damagefeedback" ) == "" )
	//	setDvar( "scr_damagefeedback", "0" );

	//if ( !getDvarInt( "scr_damagefeedback" ) )
	//	return;

	self.hud_damagefeedback = newClientHUDElem( self );
	self.hud_damagefeedback.horzAlign = "center";
	self.hud_damagefeedback.vertAlign = "middle";
	self.hud_damagefeedback.x = -12;
	self.hud_damagefeedback.y = -12;
	self.hud_damagefeedback.alpha = 0;
	self.hud_damagefeedback.archived = true;
	self.hud_damagefeedback SetShader( "bo4_hitmarker_white", 24, 24 );

	self.hud_damagefeedback_death = newClientHUDElem( self );
	self.hud_damagefeedback_death.horzAlign = "center";
	self.hud_damagefeedback_death.vertAlign = "middle";
	self.hud_damagefeedback_death.x = -12;
	self.hud_damagefeedback_death.y = -12;
	self.hud_damagefeedback_death.alpha = 0;
	self.hud_damagefeedback_death.archived = true;
	self.hud_damagefeedback_death SetShader( "bo4_hitmarker_red", 24, 24 );
}
doDamageFeedback( sWeapon, eInflictor )
{
	switch(sWeapon)
	{
		case "artillery_mp":
		case "airstrike_mp":
		case "napalm_mp":
		case "mortar_mp":
			return false;
	}
		
	if ( IsDefined( eInflictor ) )
	{
		if ( IsAI(eInflictor) )
		{
			return false;
		}
		if ( IsDefined(level.chopper) && level.chopper == eInflictor )
		{
			return false;
		}
	}
	
	return true;
}
monitorDamage()
{
	//if ( !getDvarInt( "scr_damagefeedback" ) )
	//	return;
	
}

updateDamageFeedback( Zomb )
{
	self notify( "updatefeedback" );
	self endon( "updatefeedback" );
	
	if( IsDefined( Zomb ) && Zomb animscripts\utility::damageLocationIsAny( "head", "helmet", "neck" ) )
		self playlocalsound( "prj_bullet_impact_headshot_helmet_nodie" );
	else	
		self playlocalsound( "MP_hit_alert" );
	
	self.hud_damagefeedback.alpha = 1;
	self.hud_damagefeedback fadeOverTime( 1 );
	self.hud_damagefeedback.alpha = 0;
}

updateDamageFeedbackDeath( Zomb )
{
	self notify( "updatefeedback" );
	self endon( "updatefeedback" );
	
	if( IsDefined( Zomb ) && Zomb animscripts\utility::damageLocationIsAny( "head", "helmet", "neck" ) )
		self playlocalsound( "prj_bullet_impact_headshot_helmet_nodie" );
	else	
		self playlocalsound( "MP_hit_alert" );
	
	self.hud_damagefeedback_death.alpha = 1;
	self.hud_damagefeedback_death fadeOverTime( 1 );
	self.hud_damagefeedback_death.alpha = 0;
}

