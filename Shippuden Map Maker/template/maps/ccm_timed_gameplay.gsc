//================================================================================================
// Nombre del Archivo 	: ccm_timed_gameplay.gsc
// Version				: 1
// Autor     			: Shippuden1592
// Foro					: CCM(http://customcodmapping.foroactivo.com/)
// YouTube				: https://www.youtube.com/user/shippuden1592
//================================================================================================
#include maps\_utility; 
#include common_scripts\utility;
#include maps\_zombiemode_utility;
#include maps\_hud_util;

init()
{
	level.ccm_use_timmer = true;
	level.round_wait_func = ::ccm_round_wait;

	flag_wait("all_players_connected");

	//Reestablecer tiempos
	level.zombie_vars["zombie_spawn_delay"] = 1.0;
	level.zombie_vars["zombie_between_round_time"] = 0;

	//Ignore dogs
	level.dogs_enabled = false;
	level.next_dog_round = 9999;

	//Timer HUD
	if(isDefined(level.tgTimer))
		level.tgTimer Destroy();

	level.tgTimer = NewHudElem();
	level.tgTimerTime = SpawnStruct();
	level.tgTimerTime.days = 0;
	level.tgTimerTime.hours = 0;
	level.tgTimerTime.minutes = 0;
	level.tgTimerTime.seconds = 0;
	level.tgTimerTime.toalSec = 0;
	level.tgTimer.foreground = false; 
	level.tgTimer.sort = 2; 
	level.tgTimer.hidewheninmenu = false;
	level.tgTimer.fontScale = 1.5;
	level.tgTimer.alignX = "left"; 
	level.tgTimer.alignY = "bottom";
	level.tgTimer.horzAlign = "left";  
	level.tgTimer.vertAlign = "bottom";
	level.tgTimer.x = 50; 
	level.tgTimer.y = -100;
	level.tgTimer.alpha = 0;

	level.tgTimer setTimerUp(0);
	level thread timed_gameplay_bg_counter();
	level.tgTimer.alpha = 1;
}

ccm_round_wait()
{
	wait( 1 );

	while( level.zombie_total > 0 || level.intermission )
	{
		if( flag( "end_round_wait" ) )
		{
			return;
		}
		wait( 1.0 );
	}
}

timed_gameplay_bg_counter()
{
	level endon("end_game");
		
	while( 1 )
	{	
		if(level.tgTimerTime.seconds >= 59) 
		{
			level.tgTimerTime.seconds = 0;
			level.tgTimerTime.minutes++;
		}
		
		if(level.tgTimerTime.minutes >= 59) 
		{
			level.tgTimerTime.minutes = 0;
			level.tgTimerTime.hours++;
		}
		
		if(level.tgTimerTime.hours >= 23)
		{
			level.tgTimerTime.hours = 0;
			level.tgTimerTime.days++;
		}
		
		level.tgTimerTime.seconds++;
		level.tgTimerTime.toalSec++;

		wait 1;
	}
}