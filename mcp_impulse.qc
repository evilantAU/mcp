
float() crandom =
{
	return 2*(random() - 0.5);
};



//============================================================================


vector() wall_velocity =
{
	local vector    vel;
	
	vel = normalize (self.velocity);
	vel = normalize(vel + v_up*(random()- 0.5) + v_right*(random()- 0.5));
	vel = vel + 2*trace_plane_normal;
	vel = vel * 200;
	
	return vel;
};


/*
================
SpawnMeatSpray
================
*/
void(vector org, vector vel) SpawnMeatSpray =
{
	local   entity missile;
	local   vector  org;

	missile = spawn ();
	missile.owner = self;
	missile.movetype = MOVETYPE_BOUNCE;
	missile.solid = SOLID_NOT;

	makevectors (self.angles);

	missile.velocity = vel;
	missile.velocity_z = missile.velocity_z + 250 + 50*random();

	missile.avelocity = '3000 1000 2000';
	
// set missile duration
	missile.nextthink = time + 1;
	missile.think = SUB_Remove;

	FO_SetModel (missile, "progs/zom_gib.mdl", DIM_WORLD);
	setsize (missile, '0 0 0', '0 0 0');            
	setorigin (missile, org);
};

/*
================
SpawnBlood
================
*/
void(vector org, float damage) SpawnBlood =
{
	WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
	WriteByte (MSG_MULTICAST, TE_BLOOD);
	WriteByte (MSG_MULTICAST, 1);
	WriteCoord (MSG_MULTICAST, org_x);
	WriteCoord (MSG_MULTICAST, org_y);
	WriteCoord (MSG_MULTICAST, org_z);
	multicast (org, MULTICAST_PVS);
};

/*
================
spawn_touchblood
================
*/
void(float damage) spawn_touchblood =
{
	local vector    vel;

	vel = wall_velocity () * 0.2;
	SpawnBlood (self.origin + vel*0.01, damage);
};

/*
==============================================================================

MULTI-DAMAGE

Collects multiple small damages into a single damage

==============================================================================
*/

entity  multi_ent;
float   multi_damage;

vector  blood_org;
float   blood_count;

vector  puff_org;
float   puff_count;

void() ClearMultiDamage =
{
	multi_ent = world;
	multi_damage = 0;
	blood_count = 0;
	puff_count = 0;
};

void() ApplyMultiDamage =
{
	if (!multi_ent)
		return;
	T_Damage (multi_ent, self, self, multi_damage);
};

void(entity hit, float damage) AddMultiDamage =
{
	if (!hit)
		return;
	
	if (hit != multi_ent)
	{
		ApplyMultiDamage ();
		multi_damage = damage;
		multi_ent = hit;
	}
	else
		multi_damage = multi_damage + damage;
};

void() Multi_Finish =
{
	if (puff_count)
	{
		WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
		WriteByte (MSG_MULTICAST, TE_GUNSHOT);
		WriteByte (MSG_MULTICAST, puff_count);
		WriteCoord (MSG_MULTICAST, puff_org_x);
		WriteCoord (MSG_MULTICAST, puff_org_y);
		WriteCoord (MSG_MULTICAST, puff_org_z);
		multicast (puff_org, MULTICAST_PVS);
	}

	if (blood_count)
	{
		WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
		WriteByte (MSG_MULTICAST, TE_BLOOD);
		WriteByte (MSG_MULTICAST, blood_count);
		WriteCoord (MSG_MULTICAST, blood_org_x);
		WriteCoord (MSG_MULTICAST, blood_org_y);
		WriteCoord (MSG_MULTICAST, blood_org_z);
		multicast (puff_org, MULTICAST_PVS);
	}
};

/*
==============================================================================
BULLETS
==============================================================================
*/

/*
================
TraceAttack
================
*/
void(float damage, vector dir) TraceAttack =
{
	local   vector  vel, org;
	
	vel = normalize(dir + v_up*crandom() + v_right*crandom());
	vel = vel + 2*trace_plane_normal;
	vel = vel * 200;

	org = trace_endpos - dir*4;
	if (trace_ent.takedamage)
	{


		blood_count = blood_count + 1;
		blood_org = org;
		AddMultiDamage (trace_ent, damage);
	}
	else
	{
		puff_count = puff_count + 1;
	}
};

/*
================
FireBullets

Used by shotgun, super shotgun, and enemy soldier firing
Go to the trouble of combining multiple pellets into a single damage call.
================
*/
void(float shotcount, vector dir, vector spread) FireBullets =
{
	local   vector direction;
	local   vector  src;
	local float playershit;
	
	makevectors(self.v_angle);

	src = self.origin + v_forward*10;
	src_z = self.absmin_z + self.size_z * 0.7;

	ClearMultiDamage ();

	traceline (src, src + dir*3000, FALSE, self);	//2048
	
	puff_org = trace_endpos - dir*4;
	
	while (shotcount > 0)
	{
		
		direction = dir + crandom()*spread_x*v_right + crandom()*spread_y*v_up;
		traceline (src, src + direction*2048, FALSE, self); //false

		if (trace_fraction != 1.0)
		{
			//TraceAttack (4, direction);
			local   vector  vel, org;
	
			vel = normalize(dir + v_up*crandom() + v_right*crandom());
			vel = vel + 2*trace_plane_normal;
			vel = vel * 200;

			org = trace_endpos - dir*4;
			if (trace_ent.takedamage)
			{


				blood_count = blood_count + 1;
				blood_org = org;
				AddMultiDamage (trace_ent, 4);
				
				if(trace_ent.classname == "player" && trace_ent.team_no != self.team_no)
					playershit++;
			}
			else
			{
				puff_count = puff_count + 1;
			}
		}

		shotcount = shotcount - 1;
	}
	ApplyMultiDamage ();
	Multi_Finish ();
	if(playershit > 0)
		AddStat(self, STAT_WEAPONHIT, self.weapon);
};


/*
==============================================================================

ROCKETS

==============================================================================
*/


void MidAir(entity attacker, entity targ, float dist) =
{
	local entity te;
	local float rng = MyRNG(3);

	
	if(targ.hasbeenmidaired)
	{
			
		te = find(world, classname, "consecmidaircounter");
		while (te) 
		{
			if (te.owner == targ && te.gren == attacker && te != world) 
			{
				te.cnt++;
				AddStat(attacker, STAT_ROCKETMIDAIR, te.cnt);
				sprint(attacker,PRINT_HIGH,strcat("you midaired ",targ.classname, "x",ftos(te.cnt), " (",ftos(dist),")\n"));
				if(te.cnt == 2)
				{
					if(rng == 1)
					{
						SoundTeam(TEAM_BLUE, world,"beta1/voice_midair1.wav");
						SoundTeam(TEAM_RED, world,"beta1/voice_midair1.wav");
					}
					else if (rng == 2)
					{
						SoundTeam(TEAM_BLUE, world,"beta1/voice_midair2.wav");
						SoundTeam(TEAM_RED, world,"beta1/voice_midair2.wav");
					}
					else
					{
						SoundTeam(TEAM_BLUE, world,"beta1/voice_midair3.wav");
						SoundTeam(TEAM_RED, world,"beta1/voice_midair3.wav");
					}
				}
				if(te.cnt >= 3)
				{
					SoundTeam(TEAM_BLUE, world,"beta1/mlg.wav");
					SoundTeam(TEAM_RED, world,"beta1/mlg.wav");
				}
			}
			te = find(te, classname, "consecmidaircounter");
		}
	}
	else
	{
		if(dist > 64)		//trying to weed out initial baby middys
			return;
		te = spawn();
		te.classname = "consecmidaircounter";
		te.owner = targ;
		te.gren = attacker;
		te.nextthink = time + 60;
		te.think = SUB_Remove;
		te.cnt = 1;
		AddStat(attacker, STAT_ROCKETMIDAIR, 1);
		
		sprint(attacker,PRINT_HIGH,strcat("you midaired ",targ.classname, " x",ftos(1), " (",ftos(dist),"dist)\n"));

			if(rng == 1)
			{
				SoundTeam(TEAM_BLUE, world,"beta1/voice_midair1.wav");
				SoundTeam(TEAM_RED, world,"beta1/voice_midair1.wav");
			}
			else if (rng == 2)
			{
				SoundTeam(TEAM_BLUE, world,"beta1/voice_midair2.wav");
				SoundTeam(TEAM_RED, world,"beta1/voice_midair2.wav");
			}
			else
			{
				SoundTeam(TEAM_BLUE, world,"beta1/voice_midair3.wav");
				SoundTeam(TEAM_RED, world,"beta1/voice_midair3.wav");
			}
			
	}
	targ.hasbeenmidaired = 1;
	AddStat(attacker, STAT_ROCKETMIDAIRDIST, dist);
};

void() T_MissileTouch =
{
	local float     damg;
	local float 	hitplayer = 0;
	
	if (other == self.owner)
		return;         // don't explode on owner

	if (self.voided) {
		return;
	}
	self.voided = 1;

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}
	

	damg = 90 + random()*20;
	
	if (other.health)
	{
		local float isharp = 0 ;
			
		local entity te = find(world, classname, "harpoontimer");
		while (te) 
		{
			if (te.owner == other && te != world) 
			{
				te.nextthink = time;
				isharp = 1;
			}
			
			te = find(te, classname, "harpoontimer");
		}
		if(other.classname == "player" && other.team_no != self.owner.team_no)
		{
			hitplayer = 1;
			AddStat(self.owner, STAT_ROCKETDIRECT, 1);
			
			if (!(other.flags & FL_ONGROUND) && !(other.flags & FL_INWATER))
			{
				
				traceline(other.origin, other.origin + '0 0 -10000', 1, self);
				local float dist = ceil(vlen(other.origin - trace_endpos));
		
				
				
				MidAir(self.owner, other, dist);
				//sprint(self.owner,PRINT_HIGH,strcat("you midaired ",self.wpnstats[1].name, "(",ftos(dist),")height\n"));
			}

		}
		if(isharp)
		{	
			//bprint(2,"isharped\n");
			other.deathtype = "rocket_directharp";
			
			T_Damage (other, self, self.owner, damg * 4 );
			
		}
		else
		{	
			
			other.deathtype = "rocket_direct";
			T_Damage (other, self, self.owner, damg );
	
		}
	}

	// don't do radius damage to the other, because all the damage
	// was done in the impact

		if(hitplayer == 0)
			MCP_RadiusDamage (self, self.owner, 90, other, "rocket", 1);
		else
		{
			MCP_RadiusDamage (self, self.owner, 90, other, "rocket", 0);
			AddStat(self.owner, STAT_WEAPONHIT, WPN_ROCKETLAUNCHER);
		}
		


//  FO_Sound (self, CHAN_WEAPON, "weapons/r_exp3.wav", 1, ATTN_NORM);
	self.origin = self.origin - 8 * normalize(self.velocity);

	WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
	WriteByte (MSG_MULTICAST, TE_EXPLOSION);
	WriteCoord (MSG_MULTICAST, self.origin_x);
	WriteCoord (MSG_MULTICAST, self.origin_y);
	WriteCoord (MSG_MULTICAST, self.origin_z);
	multicast (self.origin, MULTICAST_PHS);

	remove(self);
};


/*
===============================================================================
LIGHTNING
===============================================================================
*/
void HealTarget(entity targ, entity owner, float dmg) =
{
	if(targ.health < 100)
	{
		targ.health = targ.health + dmg;
		FO_Sound(targ, CHAN_ITEM, "beta1/shaft_heal.wav", 1, ATTN_NORM);
	}
};

void () W_FireLightning2 = 
{
	if (self.t_width < time)
	{
		FO_Sound(self, CHAN_WEAPON, "weapons/lhit.wav", 1, ATTN_NORM);
		self.t_width = time + 0.6;
	}
	msg_entity = self;
	WriteByte (MSG_ONE, SVC_SMALLKICK);
	local vector org = self.origin + '0 0 16';
    traceline(org, org + v_forward * 600, 0, self);

if(self.team_no == TEAM_RED){
    WriteByte(MSG_MULTICAST, SVC_TEMPENTITY);
    WriteByte(MSG_MULTICAST, TE_LIGHTNING2);
    WriteEntity(MSG_MULTICAST, self);
    WriteCoord(MSG_MULTICAST, org_x);
    WriteCoord(MSG_MULTICAST, org_y);
    WriteCoord(MSG_MULTICAST, org_z);
    WriteCoord(MSG_MULTICAST, trace_endpos_x);
    WriteCoord(MSG_MULTICAST, trace_endpos_y);
    WriteCoord(MSG_MULTICAST, trace_endpos_z);
    multicast(org, MULTICAST_PHS);
}
else
{
    WriteByte(MSG_MULTICAST, SVC_TEMPENTITY);
    WriteByte(MSG_MULTICAST, TE_LIGHTNING1);
    WriteEntity(MSG_MULTICAST, self);
    WriteCoord(MSG_MULTICAST, org_x);
    WriteCoord(MSG_MULTICAST, org_y);
    WriteCoord(MSG_MULTICAST, org_z);
    WriteCoord(MSG_MULTICAST, trace_endpos_x);
    WriteCoord(MSG_MULTICAST, trace_endpos_y);
    WriteCoord(MSG_MULTICAST, trace_endpos_z);
    multicast(org, MULTICAST_PHS);


}
	AddStat(self, STAT_WEAPONFIRED, WPN_SHAFT);
	if (trace_ent.takedamage)
	{
	
		WriteByte(MSG_MULTICAST, SVC_TEMPENTITY);
		WriteByte(MSG_MULTICAST, TE_LIGHTNINGBLOOD);
		WriteCoord(MSG_MULTICAST, trace_endpos_x);
		WriteCoord(MSG_MULTICAST, trace_endpos_y);
		WriteCoord(MSG_MULTICAST, trace_endpos_z);
		multicast(trace_endpos, MULTICAST_PVS);
    

		if (trace_ent.classname == "player" && trace_ent.team_no != self.team_no)
		{
			//trace_ent.velocity_z = trace_ent.velocity_z + 400;
			AddStat(self, STAT_WEAPONHIT, WPN_SHAFT);
			
			if(infokey(self, "healsound") != "0")
				stuffcmd(self, "play beta1/healsound.wav\n");
				
			self.health = self.health + SHAFT_SELFHEAL;
			
			if(self.health > 150)
				self.health = 150;
		}
		
		if(trace_ent.team_no == self.team_no && trace_ent.classname == "player")
		{
			WriteByte(MSG_MULTICAST, SVC_TEMPENTITY);
			WriteByte(MSG_MULTICAST, TE_LIGHTNING3);
			WriteEntity(MSG_MULTICAST, self);
			WriteCoord(MSG_MULTICAST, org_x);
			WriteCoord(MSG_MULTICAST, org_y);
			WriteCoord(MSG_MULTICAST, org_z);
			WriteCoord(MSG_MULTICAST, trace_endpos_x);
			WriteCoord(MSG_MULTICAST, trace_endpos_y);
			WriteCoord(MSG_MULTICAST, trace_endpos_z);
			multicast(org, MULTICAST_PHS);
			

			
			if(trace_ent.health < 100)
			{
				local float heal = 0;
				if(trace_ent.health + SHAFT_HEAL > 100)
				{
					heal = 100 - trace_ent.health;
				}
				else
				{
					heal = SHAFT_HEAL;
				}
				
				trace_ent.health = trace_ent.health + heal;
				FO_Sound(trace_ent, CHAN_ITEM, "beta1/shaft_heal.wav", 1, ATTN_NORM);
				
				if(infokey(self, "healsound") != "0")
					stuffcmd(self, "play beta1/healsound.wav\n");
					
				self.health = self.health + SHAFT_SELFHEAL;
			
				if(self.health > 150)
					self.health = 150;
			}

		}
		else
		{
			if(self.team_no == TEAM_RED)
			{
			WriteByte(MSG_MULTICAST, SVC_TEMPENTITY);
			WriteByte(MSG_MULTICAST, TE_LIGHTNING2);
			WriteEntity(MSG_MULTICAST, self);
			WriteCoord(MSG_MULTICAST, org_x);
			WriteCoord(MSG_MULTICAST, org_y);
			WriteCoord(MSG_MULTICAST, org_z);
			WriteCoord(MSG_MULTICAST, trace_endpos_x);
			WriteCoord(MSG_MULTICAST, trace_endpos_y);
			WriteCoord(MSG_MULTICAST, trace_endpos_z);
			multicast(org, MULTICAST_PHS);
			}
			else
			{
			WriteByte(MSG_MULTICAST, SVC_TEMPENTITY);
			WriteByte(MSG_MULTICAST, TE_LIGHTNING1);
			WriteEntity(MSG_MULTICAST, self);
			WriteCoord(MSG_MULTICAST, org_x);
			WriteCoord(MSG_MULTICAST, org_y);
			WriteCoord(MSG_MULTICAST, org_z);
			WriteCoord(MSG_MULTICAST, trace_endpos_x);
			WriteCoord(MSG_MULTICAST, trace_endpos_y);
			WriteCoord(MSG_MULTICAST, trace_endpos_z);
			multicast(org, MULTICAST_PHS);
			}
			
			T_Damage (trace_ent, self, self, SHAFT_DAMAGE);


		}
	//deathmsg = DMSG_GREN_NAIL;
	//TF_T_Damage(trace_ent, self, self.real_owner, lasergren_damage, TF_TD_NOTTEAM, TF_TD_ELECTRICITY);
	}
	else
	{
		if(self.team_no == TEAM_RED)
		{
			WriteByte(MSG_MULTICAST, SVC_TEMPENTITY);
			WriteByte(MSG_MULTICAST, TE_LIGHTNING2);
			WriteEntity(MSG_MULTICAST, self);
			WriteCoord(MSG_MULTICAST, org_x);
			WriteCoord(MSG_MULTICAST, org_y);
			WriteCoord(MSG_MULTICAST, org_z);
			WriteCoord(MSG_MULTICAST, trace_endpos_x);
			WriteCoord(MSG_MULTICAST, trace_endpos_y);
			WriteCoord(MSG_MULTICAST, trace_endpos_z);
			multicast(org, MULTICAST_PHS);
		}
		else
		{
			WriteByte(MSG_MULTICAST, SVC_TEMPENTITY);
			WriteByte(MSG_MULTICAST, TE_LIGHTNING1);
			WriteEntity(MSG_MULTICAST, self);
			WriteCoord(MSG_MULTICAST, org_x);
			WriteCoord(MSG_MULTICAST, org_y);
			WriteCoord(MSG_MULTICAST, org_z);
			WriteCoord(MSG_MULTICAST, trace_endpos_x);
			WriteCoord(MSG_MULTICAST, trace_endpos_y);
			WriteCoord(MSG_MULTICAST, trace_endpos_z);
			multicast(org, MULTICAST_PHS);

		}
	}

};

void() ClusterMiniExplode =
{
	if (self.voided) {
		return;
	}
	self.voided = 1;

		MCP_RadiusDamage (self, self.owner, CLUSTERMINIDAMAGE_AOE, world, "clustermini_aoe", 1);


	WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
	WriteByte (MSG_MULTICAST, TE_EXPLOSION);
	WriteCoord (MSG_MULTICAST, self.origin_x);
	WriteCoord (MSG_MULTICAST, self.origin_y);
	WriteCoord (MSG_MULTICAST, self.origin_z);
	multicast (self.origin, MULTICAST_PHS);

	remove (self);
};

void() ClusterBigDirectExplode =
{
	if (self.voided) {
		return;
	}
	self.voided = 1;

	if(other.classname == "player" && other.team_no != self.owner.team_no)
	{
		MCP_RadiusDamage (self, self.owner, CLUSTERBIGDAMAGE_DIRECT, world, "clusterbig_direct", 0);
		AddStat(self.owner, STAT_DIRECTPINEAPPLE, 1);
	}
	else
		MCP_RadiusDamage (self, self.owner, CLUSTERBIGDAMAGE_DIRECT, world, "clusterbig_direct", 1);

	WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
	WriteByte (MSG_MULTICAST, TE_EXPLOSION);
	WriteCoord (MSG_MULTICAST, self.origin_x);
	WriteCoord (MSG_MULTICAST, self.origin_y);
	WriteCoord (MSG_MULTICAST, self.origin_z);
	multicast (self.origin, MULTICAST_PHS);

	remove (self);
};

void() ClusterMiniDirectExplode =
{
	if (self.voided) {
		return;
	}
	self.voided = 1;

	MCP_RadiusDamage (self, self.owner, CLUSTERMINIDAMAGE_DIRECT, world, "clustermini_direct", 1);
	


	WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
	WriteByte (MSG_MULTICAST, TE_EXPLOSION);
	WriteCoord (MSG_MULTICAST, self.origin_x);
	WriteCoord (MSG_MULTICAST, self.origin_y);
	WriteCoord (MSG_MULTICAST, self.origin_z);
	multicast (self.origin, MULTICAST_PHS);

	remove (self);
};

/*void() StickyDirectExplode =
{
	if (self.voided) {
		return;
	}
	self.voided = 1;

	T_RadiusDamage (self, self.owner, STICKYDAMAGE_DIRECT, world, "sticky_direct");


	WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
	WriteByte (MSG_MULTICAST, TE_EXPLOSION);
	WriteCoord (MSG_MULTICAST, self.origin_x);
	WriteCoord (MSG_MULTICAST, self.origin_y);
	WriteCoord (MSG_MULTICAST, self.origin_z);
	multicast (self.origin, MULTICAST_PHS);

	remove (self);
};

void() StickyTrapAirExplode =
{
	if (self.voided) {
		return;
	}
	self.voided = 1;

	T_RadiusDamage (self, self.owner, STICKYDAMAGE_AIRBURST, world, "sticky_trap");


	WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
	WriteByte (MSG_MULTICAST, TE_EXPLOSION);
	WriteCoord (MSG_MULTICAST, self.origin_x);
	WriteCoord (MSG_MULTICAST, self.origin_y);
	WriteCoord (MSG_MULTICAST, self.origin_z);
	multicast (self.origin, MULTICAST_PHS);

	remove (self);
};

void() StickyTrapGroundExplode =
{
	if (self.voided) {
		return;
	}
	self.voided = 1;

	T_RadiusDamage (self, self.owner, STICKYDAMAGE_GROUND, world, "sticky_trap");


	WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
	WriteByte (MSG_MULTICAST, TE_EXPLOSION);
	WriteCoord (MSG_MULTICAST, self.origin_x);
	WriteCoord (MSG_MULTICAST, self.origin_y);
	WriteCoord (MSG_MULTICAST, self.origin_z);
	multicast (self.origin, MULTICAST_PHS);

	remove (self);
};
*/

//=============================================================================

void() spike_touch;



/*
===============
launch_spike

Used for both the player and the ogre
===============
*/
void(vector org, vector dir) launch_spike =
{
	newmis = spawn ();
	newmis.voided=0;
	newmis.owner = self;
	newmis.movetype = MOVETYPE_FLYMISSILE;
	newmis.solid = SOLID_BBOX;

	newmis.angles = vectoangles(dir);
	
	newmis.touch = spike_touch;
	newmis.classname = "spike";
	newmis.think = SUB_Remove;
	newmis.nextthink = time + 6;
	setmodel (newmis, "progs/spike.mdl");
	setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);               
	setorigin (newmis, org);

	newmis.velocity = dir * NAIL_SPEED;
};

void() W_FireSuperSpikes =
{
	local vector    dir;
	local entity    old;
	
	FO_Sound(self, CHAN_WEAPON, "weapons/spike2.wav", 1, ATTN_NORM);
	self.attack_finished = time + 0.2;
	if (deathmatch != 4) 
		self.currentammo = self.ammo_nails = self.ammo_nails - 2;
	dir = aim (self, 1000);
	launch_spike (self.origin + '0 0 16', dir);
	newmis.touch = superspike_touch;
	setmodel (newmis, "progs/s_spike.mdl");
	setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);               
	msg_entity = self;
	WriteByte (MSG_ONE, SVC_SMALLKICK);
};





.float hit_z;
void() spike_touch =
{
local float rand;
	if (other == self.owner)
		return;

	if (self.voided) {
		return;
	}
	self.voided = 1;

	if (other.solid == SOLID_TRIGGER)
		return; // trigger field, do nothing

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}
	
// hit something that bleeds
	if (other.takedamage)
	{
		spawn_touchblood (9);

			other.deathtype = "nail";
			T_Damage (other, self, self.owner, 9);
		
	}
	else
	{
		WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
		if (self.classname == "wizspike")
			WriteByte (MSG_MULTICAST, TE_WIZSPIKE);
		else if (self.classname == "knightspike")
			WriteByte (MSG_MULTICAST, TE_KNIGHTSPIKE);
		else
			WriteByte (MSG_MULTICAST, TE_SPIKE);
		WriteCoord (MSG_MULTICAST, self.origin_x);
		WriteCoord (MSG_MULTICAST, self.origin_y);
		WriteCoord (MSG_MULTICAST, self.origin_z);
		multicast (self.origin, MULTICAST_PHS);
	}

	remove(self);

};






/*
============
ServerflagsCommand

Just for development
============
*/
void() ServerflagsCommand =
{
	bprint(2,"ServerflagsCommand()\n");
//	serverflags = serverflags * 2 + 1;
};


/*
============
ImpulseCommands

============
*/

void() MenuInputImpulses =
{	

	//bprint(2,strcat(ftos(self.impulse"notrchd\n");
	if(self.menu == MENU_NONE)
	{
		return;
	}
	if (self.impulse >= 1 && self.impulse <= 8)
	{
		MenuInput(self.impulse);
	}
	
};





void() DeadOrAliveImpulses = 
{	

	if(self.impulse == IMP_GM1 || self.impulse == IMP_GM2 ||  self.impulse == IMP_GM3)
	{
		DownloadShit(self.impulse);
	}
	if(self.impulse == IMP_GETMISSING)
	{
		MCPHelp(IMP_GETMISSING);
	}
	if(self.impulse == IMP_MCPHELP)
	{
		MCPHelp(IMP_MCPHELP);
	}
	if(self.impulse == IMP_BINDS)
	{
		MCPHelp(IMP_BINDS);
	}
	if(self.impulse == IMP_SETINFOS)
	{
		MCPHelp(IMP_SETINFOS);
	}
	if(self.impulse == IMP_COMMANDS)
	{
		MCPHelp(IMP_COMMANDS);
	}
	if(self.impulse == IMP_CLASSES)
	{
		MCPHelp(IMP_CLASSES);
	}
	if(self.impulse == IMP_GOAL)
	{
		MCPHelp(IMP_GOAL);
	}
	if(self.impulse == IMP_PLAYER_FORCESTART)
		TogglePlayerReady(PLAYERSTATE_FORCESTART);
	if(self.impulse == IMP_PLAYER_READY)
		TogglePlayerReady(PLAYERSTATE_READY);

	if (self.impulse == IMP_CHANGETEAM)
		ChangeTeam();
		
	if (self.impulse == IMP_SWAPTEAM)
		SwapTeam();
	if (self.impulse == IMP_VERSION)
	{
		self.impulse = 0;
		stuffcmd(self, "play beta1/notice.wav\n");
		bprint(2, strcat("\n", MCPVERSION, "\n\n"));
	}
	if (self.impulse == IMP_CHANGEROLE)
		ChangeRoleMenu();
	
	if(self.impulse == IMP_CREATEPING)
	{
		self.impulse = 0;
	
			bprint(2,strcat(self.classname, " hullo\n"));
		
		return;
		CreatePingPoint();
	}
	
	if (self.impulse == IMP_NULL)	//using this for tf aliases to stop unknown command spam ie. discard, flaginfo
	{
		self.impulse = 0;
		SUB_Null();
		 
	}
	
	if(self.impulse == IMP_JOINRED)
		JoinTeam(TEAM_RED);
		
	if(self.impulse == IMP_JOINBLUE)
		JoinTeam(TEAM_BLUE);
	
	
	if(self.impulse == IMP_FLAGINFO)

		FlagInfo();

	if(self.impulse == IMP_INV)
		InvInfo();
		
	if(self.impulse == IMP_GORECON)
		ChangeRole(ROLE_RECON);
		
	if(self.impulse == IMP_GOASSASSIN)
		ChangeRole(ROLE_ASSASSIN);
	
	if(self.impulse == IMP_GOFIGHTER)
		ChangeRole(ROLE_FIGHTER);
	
	if(self.impulse == IMP_GOBOMBER)
		ChangeRole(ROLE_BOMBER);
		
	if(self.impulse == IMP_GOSUPPORT)
		ChangeRole(ROLE_SUPPORT);
		
	if(self.impulse == IMP_GOMGUNNER)
		ChangeRole(ROLE_MGUNNER);
		
	if(self.impulse == IMP_QSHOT1_START)
		StartQuickShot(1);
	if(self.impulse == IMP_QSHOT2_START)
		StartQuickShot(2);
	if(self.impulse == IMP_QSHOT3_START)
		StartQuickShot(3);
	if(self.impulse == IMP_QSHOT4_START)
		StartQuickShot(4);
		
	if(self.impulse == IMP_QSHOT1_STOP)
		StopQuickShot(1);
	if(self.impulse == IMP_QSHOT2_STOP)
		StopQuickShot(2);
	if(self.impulse == IMP_QSHOT3_STOP)
		StopQuickShot(3);
	if(self.impulse == IMP_QSHOT4_STOP)
		StopQuickShot(4);
		
	if(self.impulse == IMP_PRINTSTATS)
	{
		PrintStats(self);
		self.impulse = 0;
	}	
	
};

void() AliveImpulses =
{
	if(self.impulse == IMP_1HP)
	{
		self.health = 1;
		self.impulse = 0;
	}
	if (self.impulse == IMP_THROWMCPFLAG)
		ThrowMCPFlag();
	if (self.impulse == IMP_SPECIAL)
		W_SpecialSkill();
	if(self.impulse == IMP_2TAPGREN)
	{
		if(self.gren != world)
			ThrowGrenade();
		else
			PrimeGrenade();
	}
	if(self.impulse == IMP_THROWGREN)
		ThrowGrenade();
	if(self.impulse == IMP_PRIMEGREN)
		PrimeGrenade();
		
	if (self.impulse == IMP_RELOAD && VisualWeapon() == WPN_MINIGUN)
	{

		self.impulse = 0;
		
		if(self.clip_curr_primary >= CLIP_MAX_MINIGUN)
			return;
			
		if(self.minigunstate != MINIGUNSTATE_NONE)
		{
			self.mgun_queuereload = 1;
			return;
		}
		
		ReloadWeapon(WPN_MINIGUN);
	}
		
};

void() AliveAttackFinishedImpulses = 
{
	if (self.impulse == IMP_KEYBOARD1)
		W_ZutChangeWeapon (self.impulse);
	if (self.impulse == IMP_KEYBOARD2)
		W_ZutChangeWeapon (self.impulse);
	if (self.impulse == IMP_KEYBOARD3)
		W_ZutChangeWeapon (self.impulse);
	if (self.impulse == IMP_KEYBOARD4)
		W_ZutChangeWeapon (self.impulse);
	if (self.impulse == IMP_RELOAD)
	{	
	
		if(VisualWeapon() == WPN_MINIGUN || self.isreloading == 1)
		{
			self.impulse = 0;
			return;
		}
			
		ReloadWeapon(VisualWeapon());
	}
	if(self.impulse == IMP_RELOADNEXT)
		ReloadNext();
	if(self.impulse == IMP_NEXTWEAPON)
		NextWeapon();
	if(self.impulse == IMP_PREVWEAPON)
		PrevWeapon();
	if(self.impulse == IMP_LASTWEAPON)
		LastWeapon();
};
void() ImpulseCommands =
{


	if (self.impulse == 9)
		//CheatCommand ();
	if (self.impulse == 10)
		//CycleWeaponCommand ();
	if (self.impulse == 11)
		//ServerflagsCommand ();
	if (self.impulse == 12)
		//CycleWeaponReverseCommand ();

	self.impulse = 0;

};





