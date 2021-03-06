/*
	defs.qc

	global definitions

	Copyright (C) 1996-1997  Id Software, Inc.

	This program is free software; you can redistribute it and/or
	modify it under the terms of the GNU General Public License
	as published by the Free Software Foundation; either version 2
	of the License, or (at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

	See the GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program; if not, write to:

		Free Software Foundation, Inc.
		59 Temple Place - Suite 330
		Boston, MA  02111-1307, USA

*/

/*
==============================================================================

			SOURCE FOR GLOBALVARS_T C STRUCTURE

==============================================================================
*/

//
// system globals
//
entity          self;
entity          other;
entity          world;
float           time;
float           frametime;

entity          newmis;                         // if this is set, the entity that just
								// run created a new missile that should
								// be simulated immediately


float           force_retouch;          // force all entities to touch triggers
								// next frame.  this is needed because
								// non-moving things don't normally scan
								// for triggers, and when a trigger is
								// created (like a teleport trigger), it
								// needs to catch everything.
								// decremented each frame, so set to 2
								// to guarantee everything is touched
string          mapname;

float           serverflags;            // propagated from level to level, used to
								// keep track of completed episodes

float           total_secrets;
float           total_monsters;

float           found_secrets;          // number of secrets found
float           killed_monsters;        // number of monsters killed


// spawnparms are used to encode information about clients across server
// level changes
float           parm1, parm2, parm3, parm4, parm5, parm6, parm7, parm8, parm9, parm10, parm11, parm12, parm13, parm14, parm15, parm16;

//
// global variables set by built in functions
//      
vector          v_forward, v_up, v_right;       // set by makevectors()
	
// set by traceline / tracebox
float           trace_allsolid;
float           trace_startsolid;
float           trace_fraction;
vector          trace_endpos;
vector          trace_plane_normal;
float           trace_plane_dist;
entity          trace_ent;
float           trace_inopen;
float           trace_inwater;

entity          msg_entity;                             // destination of single entity writes

//
// required prog functions
//
void()          main;                                           // only for testing

void()          StartFrame;

void()          PlayerPreThink;
void()          PlayerPostThink;

void()          ClientKill;
void()          ClientConnect;
void()          PutClientInServer;              // call after setting the parm1... parms
void()          ClientDisconnect;

void()          SetNewParms;                    // called when a client first connects to
									// a server. sets parms so they can be
									// saved off for restarts

void()          SetChangeParms;                 // call to set parms for self so they can
									// be saved for a level transition


//================================================
void            end_sys_globals;                // flag for structure dumping
//================================================

/*
==============================================================================

			SOURCE FOR ENTVARS_T C STRUCTURE

==============================================================================
*/

//
// system fields (*** = do not set in prog code, maintained by C code)
//
.float          modelindex;             // *** model index in the precached list
.vector         absmin, absmax; // *** origin + mins / maxs

.float          ltime;                  // local time for entity
.float          lastruntime;    // *** to allow entities to run out of sequence

.float          movetype;
.float          solid;

.vector         origin;                 // ***
.vector         oldorigin;              // ***
.vector         velocity;
.vector         angles;
.vector         avelocity;

.string         classname;              // spawn function
.string         model;
.float          frame;
.float          skin;
.float          effects;

.vector         mins, maxs;             // bounding box extents reletive to origin
.vector         size;                   // maxs - mins

.void()         touch;
.void()         use;
.void()         think;
.void()         blocked;                // for doors or plats, called when can't push other

.float          nextthink;
.entity         groundentity;



// stats
.float          health;
.float          frags;
.float          weapon;                 // one of the IT_SHOTGUN, etc flags
.string         weaponmodel;
.float          weaponframe;
.float          currentammo;
.float          ammo_shells, ammo_nails, ammo_rockets, ammo_cells;

.float          items;                  // bit flags

.float          takedamage;
.entity         chain;
.float          deadflag;

.vector         view_ofs;                       // add to origin to get eye point


.float          button0;                // fire
.float          button1;                // use
.float          button2;                // jump

.float          impulse;                // weapon changes

.float          fixangle;
.vector         v_angle;                // view / targeting angle for players

.string         netname;

.entity         enemy;

.float          flags;

.float          colormap;
.float          team;

.float          max_health;             // players maximum health is stored here

.float          teleport_time;  // don't back up

.float          armortype;              // save this fraction of incoming damage
.float          armorvalue;

.float          waterlevel;             // 0 = not in, 1 = feet, 2 = wast, 3 = eyes
.float          watertype;              // a contents value

.float          ideal_yaw;
.float          yaw_speed;

.entity         aiment;

.entity         goalentity;             // a movetarget or an enemy

.float          spawnflags;

.string         target;
.string         targetname;



// damage is accumulated through a frame. and sent as one single
// message, so the super shotgun doesn't generate huge messages
.float          dmg_take;
.float          dmg_save;
.entity         dmg_inflictor;

.entity         owner;          // who launched a missile
.vector         movedir;        // mostly for doors, but also used for waterjump

.string         message;                // trigger messages

.float          sounds;         // either a cd track number or sound number

.string         noise, noise1, noise2, noise3;  // contains names of wavs to play

//================================================
void            end_sys_fields;                 // flag for structure dumping
//================================================

/*
==============================================================================

				VARS NOT REFERENCED BY C CODE

==============================================================================
*/


//
// constants
//



float   FALSE                                   = 0;
float   TRUE                                    = 1;

// edict.flags
float   FL_FLY                                  = 1;
float   FL_SWIM                                 = 2;
float   FL_CLIENT                               = 8;    // set for all client edicts
float   FL_INWATER                              = 16;   // for enter / leave water splash
float   FL_MONSTER                              = 32;
float   FL_GODMODE                              = 64;   // player cheat
float   FL_NOTARGET                             = 128;  // player cheat
float   FL_ITEM                                 = 256;  // extra wide size for bonus items
float   FL_ONGROUND                             = 512;  // standing on something
float   FL_PARTIALGROUND                = 1024; // not all corners are valid
float   FL_WATERJUMP                    = 2048; // player jumping out of water
float   FL_JUMPRELEASED                 = 4096; // for jump debouncing

// edict.movetype values
float   MOVETYPE_NONE                   = 0;    // never moves
//float MOVETYPE_ANGLENOCLIP    = 1;
//float MOVETYPE_ANGLECLIP              = 2;
float   MOVETYPE_WALK                   = 3;    // players only
float   MOVETYPE_STEP                   = 4;    // discrete, not real time unless fall
float   MOVETYPE_FLY                    = 5;
float   MOVETYPE_TOSS                   = 6;    // gravity
float   MOVETYPE_PUSH                   = 7;    // no clip to world, push and crush
float   MOVETYPE_NOCLIP                 = 8;
float   MOVETYPE_FLYMISSILE             = 9;    // fly with extra size against monsters
float   MOVETYPE_BOUNCE                 = 10;
float   MOVETYPE_BOUNCEMISSILE  = 11;   // bounce with extra size

// edict.solid values
float   SOLID_NOT                               = 0;    // no interaction with other objects
float   SOLID_TRIGGER                   = 1;    // touch on edge, but not blocking
float   SOLID_BBOX                              = 2;    // touch on edge, block
float   SOLID_SLIDEBOX                  = 3;    // touch on edge, but not an onground
float   SOLID_BSP                               = 4;    // bsp clip, touch on edge, block

// range values
float   RANGE_MELEE                             = 0;
float   RANGE_NEAR                              = 1;
float   RANGE_MID                               = 2;
float   RANGE_FAR                               = 3;

// deadflag values

float   DEAD_NO                                 = 0;
float   DEAD_DYING                              = 1;
float   DEAD_DEAD                               = 2;
float   DEAD_RESPAWNABLE                	= 3;

// takedamage values

float   DAMAGE_NO                               = 0;
float   DAMAGE_YES                              = 1;
float   DAMAGE_AIM                              = 2;

// items
float   IT_AXE                           = 4096;
float   IT_SHOTGUN                       = 1;
float   IT_SUPER_SHOTGUN                = 2;
float   IT_NAILGUN                              = 4;
float   IT_SUPER_NAILGUN                = 8;
float   IT_GRENADE_LAUNCHER             = 16;
float   IT_ROCKET_LAUNCHER              = 32;
float   IT_LIGHTNING                    = 64;
float   IT_EXTRA_WEAPON                 = 128;

float   IT_SHELLS                               = 256;
float   IT_NAILS                                = 512;
float   IT_ROCKETS                              = 1024;
float   IT_CELLS                                = 2048;

float   IT_ARMOR1                               = 8192;
float   IT_ARMOR2                               = 16384;
float   IT_ARMOR3                               = 32768;
float   IT_SUPERHEALTH                  = 65536;

float   IT_KEY1                                 = 131072;
float   IT_KEY2                                 = 262144;

float   IT_INVISIBILITY                 = 524288;
float   IT_INVULNERABILITY              = 1048576;
float   IT_SUIT                                 = 2097152;
float   IT_QUAD                                 = 4194304;

// point content values

float   CONTENT_EMPTY                   = -1;
float   CONTENT_SOLID                   = -2;
float   CONTENT_WATER                   = -3;
float   CONTENT_SLIME                   = -4;
float   CONTENT_LAVA                    = -5;
float   CONTENT_SKY                             = -6;

float   STATE_TOP               = 0;
float   STATE_BOTTOM    = 1;
float   STATE_UP                = 2;
float   STATE_DOWN              = 3;

vector  VEC_ORIGIN = '0 0 0';
vector  VEC_HULL_MIN = '-16 -16 -24';
vector  VEC_HULL_MAX = '16 16 32';

vector  VEC_HULL2_MIN = '-32 -32 -24';
vector  VEC_HULL2_MAX = '32 32 64';

// protocol bytes
float   SVC_TEMPENTITY          = 23;
float   SVC_KILLEDMONSTER       = 27;
float   SVC_FOUNDSECRET         = 28;
float   SVC_INTERMISSION        = 30;
float   SVC_FINALE                      = 31;
float   SVC_CDTRACK                     = 32;
float   SVC_SELLSCREEN          = 33;
float   SVC_SMALLKICK           = 34;
float   SVC_BIGKICK                     = 35;
float   SVC_MUZZLEFLASH         = 39;


float   TE_SPIKE                = 0;
float   TE_SUPERSPIKE   = 1;
float   TE_GUNSHOT              = 2;
float   TE_EXPLOSION    = 3;
float   TE_TAREXPLOSION = 4;
float   TE_LIGHTNING1   = 5;
float   TE_LIGHTNING2   = 6;
float   TE_WIZSPIKE             = 7;
float   TE_KNIGHTSPIKE  = 8;
float   TE_LIGHTNING3   = 9;
float   TE_LAVASPLASH   = 10;
float   TE_TELEPORT             = 11;
float   TE_BLOOD                = 12;
float   TE_LIGHTNINGBLOOD = 13;

// sound channels
// channel 0 never willingly overrides
// other channels (1-7) allways override a playing sound on that channel
float   CHAN_AUTO               = 0;
float   CHAN_WEAPON             = 1;
float   CHAN_VOICE              = 2;
float   CHAN_ITEM               = 3;
float   CHAN_BODY               = 4;
float   CHAN_NO_PHS_ADD = 8;    // ie: CHAN_BODY+CHAN_NO_PHS_ADD

float   ATTN_NONE               = 0;
float   ATTN_NORM               = 1;
float   ATTN_IDLE               = 2;
float   ATTN_STATIC             = 3;

// update types

float   UPDATE_GENERAL  = 0;
float   UPDATE_STATIC   = 1;
float   UPDATE_BINARY   = 2;
float   UPDATE_TEMP             = 3;

// entity effects

//float EF_BRIGHTFIELD  = 1;
//float EF_MUZZLEFLASH  = 2;
float   EF_BRIGHTLIGHT  = 4;
float   EF_DIMLIGHT     = 8;
float   EF_FLAG1                = 16;
float   EF_FLAG2                = 32;
// GLQuakeWorld Stuff
float 	EF_BLUE		=	64;	// Blue Globe effect for Quad
float	EF_RED		=	128;	// Red Globe effect for Pentagram
// messages
float   MSG_BROADCAST   = 0;            // unreliable to all
float   MSG_ONE                 = 1;            // reliable to one (msg_entity)
float   MSG_ALL                 = 2;            // reliable to all
float   MSG_INIT                = 3;            // write to the init string
float   MSG_MULTICAST   = 4;            // for multicast() call

// message levels
float   PRINT_LOW               = 0;            // pickup messages
float   PRINT_MEDIUM    	= 1;            // death messages
float   PRINT_HIGH              = 2;            // critical messages
float   PRINT_CHAT              = 3;            // also goes to chat console

// multicast sets
float   MULTICAST_ALL   = 0;            // every client
float   MULTICAST_PHS   = 1;            // within hearing
float   MULTICAST_PVS   = 2;            // within sight
float   MULTICAST_ALL_R = 3;            // every client, reliable
float   MULTICAST_PHS_R = 4;            // within hearing, reliable
float   MULTICAST_PVS_R = 5;            // within sight, reliable




//================================================

//
// globals
//
float   movedist;

string  string_null;    // null string, nothing should be held here
float   empty_float;

entity  activator;              // the entity that activated a trigger or brush

entity  damage_attacker;        // set by T_Damage
entity  damage_inflictor;
float   framecount;

//
// cvars checked each frame
//
float           teamplay;
float           timelimit;
float           fraglimit;
float           deathmatch;
float           rj;

//================================================

//
// world fields (FIXME: make globals)
//
.string         wad;
.string         map;
.float          worldtype;      // 0=medieval 1=metal 2=base

//================================================

.string         killtarget;

//
// quakeed fields
//
.float          light_lev;              // not used by game, but parsed by light util
.float          style;


//
// monster ai
//
.void()         th_stand;
.void()         th_walk;
.void()         th_run;
.void()         th_missile;
.void()         th_melee;
.void(entity attacker, float damage)            th_pain;
.void()         th_die;

.entity         oldenemy;               // mad at this player before taking damage

.float          speed;

.float  lefty;

.float  search_time;
.float  attack_state;

float   AS_STRAIGHT             = 1;
float   AS_SLIDING              = 2;
float   AS_MELEE                = 3;
float   AS_MISSILE              = 4;

//
// player only fields
//
.float          voided;
.float          walkframe;

// Zoid Additions
.float		maxspeed;		// Used to set Maxspeed on a player
.float		gravity;		// Gravity Multiplier (0 to 1.0)



.float          attack_finished;
.float          pain_finished;

.float          invincible_finished;
.float          invisible_finished;
.float          super_damage_finished;
.float          radsuit_finished;

.float          invincible_time, invincible_sound;
.float          invisible_time, invisible_sound;
.float          super_time, super_sound;
.float          rad_time;
.float          fly_sound;

.float          axhitme;

.float          show_hostile;   // set to time+0.2 whenever a client fires a
							// weapon or takes damage.  Used to alert
							// monsters that otherwise would let the player go
.float          jump_flag;              // player jump flag
.float          swim_flag;              // player swimming sound flag
.float          air_finished;   // when time > air_finished, start drowning
.float          bubble_count;   // keeps track of the number of bubbles
.string         deathtype;              // keeps track of how the player died

//
// object stuff
//
.string         mdl;
.vector         mangle;                 // angle at start

.vector         oldorigin;              // only used by secret door

.float          t_length, t_width;


//
// doors, etc
//
.vector         dest, dest1, dest2;
.float          wait;                   // time from firing to restarting
.float          delay;                  // time from activation to firing
.entity         trigger_field;  // door's trigger entity
.string         noise4;

//
// monsters
//
.float          pausetime;
.entity         movetarget;


//
// doors
//
.float          aflag;
.float          dmg;                    // damage done by door when hit
	
//
// misc
//
.float          cnt;                    // misc flag
	
//
// subs
//
.void()         think1;
.vector         finaldest, finalangle;

//
// triggers
//
.float          count;                  // for counting triggers


//
// plats / doors / buttons
//
.float          lip;
.float          state;
.vector         pos1, pos2;             // top and bottom positions
.float          height;

//
// sounds
//
.float          waitmin, waitmax;
.float          distance;
.float          volume;




//===========================================================================
	

//
// builtin functions
//

void(vector ang)        makevectors             = #1;           // sets v_forward, etc globals
void(entity e, vector o) setorigin      = #2;
void(entity e, string m) setmodel       = #3;           // set movetype and solid first
void(entity e, vector min, vector max) setsize = #4;
// #5 was removed
void() break                                            = #6;
float() random                                          = #7;           // returns 0 - 1
void(entity e, float chan, string samp, float vol, float atten) sound = #8;
vector(vector v) normalize                      = #9;
void(string e) error                            = #10;
void(string e) objerror                         = #11;
float(vector v) vlen                            = #12;
float(vector v) vectoyaw                        = #13;
entity() spawn                                          = #14;
void(entity e) remove                           = #15;

// sets trace_* globals
// nomonsters can be:
// An entity will also be ignored for testing if forent == test,
// forent->owner == test, or test->owner == forent
// a forent of world is ignored
void(vector v1, vector v2, float nomonsters, entity forent) traceline = #16;    

entity() checkclient                            = #17;  // returns a client to look for
entity(entity start, .string fld, string match) find = #18;
string(string s) precache_sound         = #19;
string(string s) precache_model         = #20;
void(entity client, string s)stuffcmd = #21;
entity(vector org, float rad) findradius = #22;
void(float level, string s) bprint                              = #23;
void(entity client, float level, string s) sprint = #24;
void(string s) dprint                           = #25;
string(float f) ftos                            = #26;
string(vector v) vtos                           = #27;
void() coredump                                         = #28;          // prints all edicts
void() traceon                                          = #29;          // turns statment trace on
void() traceoff                                         = #30;
void(entity e) eprint                           = #31;          // prints an entire edict
float(float yaw, float dist) walkmove   = #32;  // returns TRUE or FALSE
// #33 was removed
//float(float yaw, float dist) droptofloor= #34;  // TRUE if landed on floor
float() droptofloor = #34;
void(float style, string value) lightstyle = #35;
float(float v) rint                                     = #36;          // round to nearest int
float(float v) floor                            = #37;          // largest integer <= v
float(float v) ceil                                     = #38;          // smallest integer >= v
// #39 was removed
float(entity e) checkbottom                     = #40;          // true if self is on ground
float(vector v) pointcontents           = #41;          // returns a CONTENT_*
// #42 was removed
float(float f) fabs = #43;
vector(entity e, float speed) aim = #44;                // returns the shooting vector
float(string s) cvar = #45;                                             // return cvar.value
void(string s) localcmd = #46;                                  // put string into local que
entity(entity e) nextent = #47;                                 // for looping through all ents
// #48 was removed
void() ChangeYaw = #49;                                         // turn towards self.ideal_yaw
											// at self.yaw_speed
// #50 was removed
vector(vector v) vectoangles                    = #51;

//
// direct client message generation
//
void(float to, float f) WriteByte               = #52;
void(float to, float f) WriteChar               = #53;
void(float to, float f) WriteShort              = #54;
void(float to, float f) WriteLong               = #55;
void(float to, float f) WriteCoord              = #56;
void(float to, float f) WriteAngle              = #57;
void(float to, string s) WriteString    = #58;
void(float to, entity s) WriteEntity    = #59;

// several removed

void(float step) movetogoal                             = #67;

string(string s) precache_file          = #68;  // no effect except for -copy
void(entity e) makestatic               = #69;
void(string s) changelevel = #70;

//#71 was removed

void(string var, string val) cvar_set = #72;    // sets cvar.value

void(entity client, string s) centerprint = #73;        // sprint, but in middle

void(vector pos, string samp, float vol, float atten) ambientsound = #74;

string(string s) precache_model2        = #75;          // registered version only
string(string s) precache_sound2        = #76;          // registered version only
string(string s) precache_file2         = #77;          // registered version only

void(entity e) setspawnparms            = #78;          // set parm1... to the
												// values at level start
												// for coop respawn
void(entity killer, entity killee) logfrag = #79;       // add to stats

string(entity e, string key) infokey    = #80;  // get a key value (world = serverinfo)
float(string s) stof                            = #81;          // convert string to float
void(vector where, float set) multicast = #82;  // sends the temp message to a set
												// of clients, possibly in PVS or PHS

//============================================================================

//
// subs.qc
//
void(vector tdest, float tspeed, void() func) SUB_CalcMove;
void(entity ent, vector tdest, float tspeed, void() func) SUB_CalcMoveEnt;
void(vector destangle, float tspeed, void() func) SUB_CalcAngleMove;
void()  SUB_CalcMoveDone;
void() SUB_CalcAngleMoveDone;
void() SUB_Null;
void() SUB_UseTargets;
void() SUB_Remove;

//
//      combat.qc
//
void(entity targ, entity inflictor, entity attacker, float damage) T_Damage;


//float (entity e, float healamount, float ignore) T_Heal; // health function

float(entity targ, entity inflictor) CanDamage;


// flash stuff
float FO_FlashDimension;

//zut fields
float bluescore;
float redscore;

float role_recon_max;
float role_assassin_max;
float role_fighter_max;
float role_bomber_max;
float role_support_max;
float role_mgunner_max;

float matchstate;
entity lastspawn_blue;
entity lastspawn_red;

entity gm;
entity mcpflag;
entity mcpflagspawn;

float playerdims;	//used player dimensions
.float pdim;

.float playerstate;
.float isconnected;
.float ismoving;
.float hasbeenmidaired;
.float nextrespawn;
.float nextpingpoint;
.float killstreakcount;
.float mgunnerspeed;  //using for mgunner shouldercharge

.float heat;

.float qshot1;
.float qshot2;
.float qshot3;
.float qshot4;
.float qsweapon;
.float reloadingweapon;
.float mgun_spinup_finish;
.float mgun_spindown_finish;
.float mgun_queuereload;
.float minigunstate;

.float team_no;
.float role;
.float nextrole;
.float menu;
.float lastweapon;

.float clip_curr_tertiary;
.float clip_curr_secondary;
.float clip_curr_primary;
.float grencount;
.float next_cellregen;
.float next_healtharmourregen;
.float maxarmour;

string cprint_waitingforplayers;
.string cprint_obj;
.string cprint_id;
.float cprint_time;
.string awardstring;
.float votemap;
//.float hasstomped;
//.float isleaping;
typedef struct {
	float primaryshots;
	float primaryhits;
	float primarykills;

	float secondaryshots;
	float secondaryhits;
	float secondarykills;

	float tertiaryshots;
	float tertiaryhits;
	float tertiarykills;

	float meleeshots;
	float meleehits;
	float meleekills;
	
	float specialshots;
	float specialhits;
	float specialkills;
	
	float grenprimes;
	float grenhits;
	float grenkills;
	float grensticky;
} WeapStatStruct;



typedef struct {
	float flagtouches;
	float flagcaps;
	float flagsteals;
	float flagsacks;
	float flagtrailtouches;
	float flagthrows;
	float flagdeaths;
	
	float dmgtaken;
	float dmggiven;
	float dmgself;
	float dmgworld;
	
	float kills;
	float deaths;
	float suicides;
	float worlddeaths;
	
	float stompkills;
	float bestkillstreak;
	float ghostsbusted;
	float accuracyawards;
	float harpooncombokills;
	float directrockets;
	float directpineapples;
	float midairrockets;
	float midairpineapples;
	float bestrocketmidairdist;
	float bestrocketmidairconsec;


} PlayerStatStruct;

.WeapStatStruct weapstats[7];
.PlayerStatStruct playerstats;


.float cloak_complete;
.float iscloaked;
.float reload_complete;
.float isreloading;
.entity gren;
.float FlashTime;









#define STAT_DMGGIVEN		1
#define STAT_DMGTAKEN		2
#define STAT_DMGSELF		3
#define STAT_DMGWORLD		4

#define STAT_MELEEKILL		5	
#define STAT_SECONDARYKILL	6
#define STAT_PRIMARYKILL	7
#define STAT_TERTIARYKILL	8
#define STAT_SPECIALKILL	9
#define STAT_GRENKILL		10

#define STAT_DEATH		11
#define STAT_SUICIDE		12
#define STAT_KILL		13
#define STAT_WORLDDEATH		14

#define STAT_FLAGTOUCH		15
#define STAT_FLAGCAP		16
#define STAT_FLAGSTEAL		17
#define STAT_FLAGCARRIERKILLED	18
#define STAT_FLAGTHROW		19
#define STAT_FLAGDIEDWITH	20
#define STAT_FLAGTRAILTOUCH	21

#define STAT_KILLSTREAK		22
#define STAT_GHOSTBUST		23
#define STAT_STOMPKILL		24


#define STAT_HARPOONCOMBOKILL	25
#define STAT_WEAPONHIT		26
#define STAT_WEAPONFIRED	27
#define STAT_GRENPRIMED		28
#define STAT_GRENHIT		29
#define STAT_DIRECTPINEAPPLE	30

#define STAT_ACCURACYAWARD	31
#define STAT_ROCKETDIRECT	32
#define STAT_ROCKETMIDAIR	33
#define STAT_ROCKETMIDAIRDIST	34









// Dimensions
#define DMN_FLASH 1 // when flashed, we set dimension see to this
#define DMN_NOFLASH	256	// see all the things

#define DIM_WORLD		1
#define DIM_BLUETEAM		2
#define DIM_REDTEAM		4
#define DIM_FLAG		8
#define DIM_PLAYER1		16
#define DIM_PLAYER2		32
#define DIM_PLAYER3		64
#define DIM_PLAYER4		128
#define DIM_PLAYER5		256
#define DIM_PLAYER6		512
#define DIM_PLAYER7		1028
#define DIM_PLAYER8		2048
#define DIM_PLAYER9		4096
#define DIM_PLAYER10		8192
#define DIM_PLAYER11		16384
#define DIM_PLAYER12		32768
#define DIM_PLAYER13		65536
#define DIM_PLAYER14		131072
#define DIM_PLAYER15		262144
#define DIM_PLAYER16		524288
#define DIM_PLAYER17		1048576
#define DIM_PLAYER18		2097152
#define DIM_PLAYER19		4194304
#define DIM_PLAYER20		8388608
//#define DIM_FLAG		16777216
//#define DIM_EVERYTHING		16777216

//check if contains	if (self.playerstate & PLAYERSTATE_RELOADING)
//add state		self.playerstate = self.playerstate | PLAYERSTATE_RELOADING
//remove state		self.playerstate = self.playerstate - (self.playerstate & PLAYERSTATE_RELOADING)

#define MCPVERSION				"version \sbeta 1.9\s (18/apr/2021)"

#define FLAG_RESET				15
#define FLAG_TOSSSPEED				600

#define RESPAWNPENALTY_SUICIDE			4
#define RESPAWNPENALTY_INCONTROL		4
#define RESPAWNPENALTY_OUTOFCONTROL		0	

#define WPN_RELOAD				-1
#define WPN_NONE				0
#define WPN_AXE					1
#define WPN_SHOTGUN				2
#define WPN_SUPERSHOTGUN			3
#define WPN_NAILGUN				4
#define WPN_RAILGUN				5
#define WPN_PIPELAUNCHER			6
#define WPN_ROCKETLAUNCHER			7
#define WPN_SHAFT				8
#define WPN_MINIGUN				9



#define MINIGUNSTATE_NONE			0
#define MINIGUNSTATE_SPINNINGUP			1
#define MINIGUNSTATE_SPINNING			2
#define MINIGUNSTATE_SPINNINGDOWN		3

#define MINIGUN_SPINUP_TIME			0.75
#define MINIGUN_SPINDOWN_TIME			0.5

#define MGUNNER_DAMAGEREDUCTION			0.5	//damage is multiplied by this
#define MGUNNER_BOUNCEREDUCTION			0.25    //damage is multiplied by this
#define MGUNNER_BOUNCETHRESHOLD			10	//if damage is less than this 0 bounce applied

#define BACKPACK_HEAL				20
#define BACKPACK_ARMOUR				20

#define MCPFLAGSTATE_NONE			0
#define MCPFLAGSTATE_RESET			1
#define MCPFLAGSTATE_CARRIED			2
#define MCPFLAGSTATE_DROPPED			3
#define MCPFLAGSTATE_CAPPED			4
#define MCPFLAGSTATE_THROWN			5
#define MCPFLAGSTATE_LIMBO			6

#define POINTINTERVAL				2		//seconds between awarding a point to team

#define LOOT_DURATION				15		//time before backpacks/health/grens drops from death etc expire

#define PLAYERSTATE_NOTREADY			0
#define PLAYERSTATE_READY			1
#define PLAYERSTATE_FORCESTART			2

#define MATCHSTATE_WAITINGFORPLAYERS		1
#define MATCHSTATE_COUNTDOWN			2
#define MATCHSTATE_LIVE				3
#define MATCHSTATE_FINISH			4

#define MAXSCORE				100	//scorelimit

#define	NAIL_SPEED				1500
#define ROCKET_SPEED				1000

#define RELOADTIME_SHOTGUN			0.25
//#define RELOADTIME_SUPERSHOTGUN		0.375
#define RELOADTIME_SUPERSHOTGUN			0.8
#define FIRERATE_SUPERSHOTGUN			0.6
#define RELOADTIME_NAILGUN			0.1
#define RELOADTIME_RAILGUN			1.5
#define RELOADTIME_ROCKETLAUNCHER		1.25
#define RELOADTIME_PIPELAUNCHER			0.7
#define RELOADTIME_SHAFT			0.1
#define RELOADTIME_MINIGUN			0.05



#define FLASH_DURATION				2.5
//#define SPECIAL_COOLDOWN_RECON			1
//#define SPECIAL_COOLDOWN_ASSASSIN		20
//#define SPECIAL_COOLDOWN_FIGHTER		3

#define SPECIAL_DURATION_ASSASSIN		6
#define TELEBALL_DURATION			10
#define TELEBALL_SPEED				600

#define PUSHUPGREN_RADIUS			240 
#define PUSHUPGREN_MAXPLAYERPUSH		1200
#define PUSHUPGREN_MINPLAYERPUSH		600

#define AIRBLAST_RADIUS				150
#define AIRBLAST_MAXPLAYERPUSH			1100
#define AIRBLAST_MINPLAYERPUSH			500

#define LEAP_FORWARD				500	//leaptype 1 (more vertical)
#define LEAP_HEIGHT				600	//leaptype 1 (more vertical)

#define LEAP_HEIGHTSCALE			1.5	//leaptype 2 (more of a charge)
#define CHARGE_VELOCITY				800	//leaptype 2 (more of a charge)


#define HARPOON_SPEED				1750 //1750
#define HARPOON_DAMAGE				25
#define HARPOON_QUADWINDOW			2

#define GSTOMP_DAMAGE				999

#define SHAFT_DAMAGE				8
#define SHAFT_HEAL				5
#define SHAFT_SELFHEAL				5

#define CLIMBINGNAIL_DURATION			3
#define CLIMBINGNAIL_BOOST			350

#define MENU_NONE				0
#define	MENU_SELECTTEAM				1
#define	MENU_SELECTROLE				2
#define MENU_VOTEMAP				3

#define C4DAMAGE_EXPLODE			200
#define C4_ARMTIME				1.5

#define CLUSTERBIGDAMAGE_DIRECT			150
#define CLUSTERMINIDAMAGE_DIRECT		60
#define CLUSTERMINIDAMAGE_AOE			60

#define STICKYDAMAGE_DIRECT			120	
#define STICKYDAMAGE_GROUND			120
#define STICKYDAMAGE_AIRBURST			60

#define TEAM_NONE				0
#define TEAM_BLUE				1
#define TEAM_RED				2

#define ROLE_NONE				0
#define ROLE_RECON				1
#define ROLE_ASSASSIN				2
#define ROLE_FIGHTER				3
#define ROLE_BOMBER				4
#define ROLE_SUPPORT				5
#define ROLE_MGUNNER				6

#define MAX_GRENCOUNT				2
#define DMG_MELEE_ASSASSIN			200
#define CLIP_MAX_SHOTGUN			8
#define CLIP_MAX_SUPERSHOTGUN			2
#define CLIP_MAX_NAILGUN			30
#define CLIP_MAX_RAILGUN			1
#define CLIP_MAX_ROCKETLAUNCHER			4
#define CLIP_MAX_PIPELAUNCHER			6
#define CLIP_MAX_SHAFT				50
#define CLIP_MAX_MINIGUN			100

#define SPEED_MAX_GHOST				0
#define SPEED_MAX_RECON				450
#define SPEED_MAX_ASSASSIN			280
#define SPEED_MAX_FIGHTER			240
#define SPEED_MAX_BOMBER			280
#define SPEED_MAX_SUPPORT			320

#define SPEED_MAX_MGUNNER			230
#define SPEED_MAX_MGUNNER_SPINNING		80
//#define SPEED_MAX_MGUNNER_FAST			500

#define ARMOUR_MAX_RECON			25
#define ARMOUR_MAX_ASSASSIN			0
#define ARMOUR_MAX_FIGHTER			150
#define ARMOUR_MAX_BOMBER			125
#define ARMOUR_MAX_SUPPORT			50
#define ARMOUR_MAX_MGUNNER			150

#define SPRITE_0				0
#define SPRITE_1				1
#define SPRITE_2				2
#define SPRITE_3				3
#define SPRITE_4				4
#define SPRITE_5				5
#define SPRITE_6				6
#define SPRITE_7				7
#define SPRITE_8				8
#define SPRITE_9				9
#define SPRITE_10				10
#define SPRITE_FLAGSPAWN			11
#define SPRITE_BLUECAP				12
#define SPRITE_REDCAP				13
#define SPRITE_BLUESPAWN			14
#define SPRITE_REDSPAWN				15
#define SPRITE_RECONINFO			16
#define SPRITE_ASSASSININFO			17
#define SPRITE_FIGHTERINFO			18
#define SPRITE_BOMBERINFO			19
#define SPRITE_SUPPORTINFO			20

//IMPULSE -- START
#define IMP_0				0
#define IMP_KEYBOARD1			1
#define IMP_KEYBOARD2			2
#define IMP_KEYBOARD3			3
#define IMP_KEYBOARD4			4
#define IMP_KEYBOARD5			5
#define IMP_KEYBOARD6			6
#define IMP_KEYBOARD7			7
#define IMP_KEYBOARD8			8
#define IMP_KEYBOARD9			9

#define IMP_NEXTWEAPON			11
#define IMP_PREVWEAPON			12
#define IMP_LASTWEAPON			13

#define IMP_PRIMEGREN			14
#define IMP_2TAPGREN			15
#define IMP_THROWGREN			16

#define IMP_QSHOT1_START		20
#define IMP_QSHOT2_START		21
#define IMP_QSHOT3_START		22
#define IMP_QSHOT4_START		23
#define IMP_QSHOT1_STOP			24
#define IMP_QSHOT2_STOP			25
#define IMP_QSHOT3_STOP			26
#define IMP_QSHOT4_STOP			27

#define IMP_RELOAD			28
#define IMP_RELOADNEXT			29
#define IMP_SPECIAL			30
#define IMP_INV				36
#define IMP_FLAGINFO			37

#define IMP_CHANGETEAM			100
#define IMP_JOINBLUE			101
#define IMP_JOINRED			102

#define IMP_CHANGEROLE			110
#define IMP_GORECON			111
#define IMP_GOASSASSIN			112
#define IMP_GOFIGHTER			113
#define IMP_GOBOMBER			114
#define IMP_GOSUPPORT			115
#define IMP_GOMGUNNER			116

#define IMP_VERSION			118

#define IMP_SWAPTEAM			120
#define IMP_PLAYER_READY		135
#define IMP_PLAYER_NOTREADY		136
#define IMP_PLAYER_FORCESTART		137
#define IMP_THROWMCPFLAG		148

#define IMP_MCPHELP			150


#define IMP_GM1				161
#define IMP_GM2				162
#define IMP_GM3				163
#define IMP_GETMISSING			164
#define IMP_BINDS			165
#define IMP_SETINFOS			166
#define IMP_COMMANDS			167
#define IMP_CLASSES			168
#define IMP_GOAL			169


#define IMP_HELP_RECON			171
#define IMP_HELP_ASSASSIN		172
#define IMP_HELP_FIGHTER		173
#define IMP_HELP_BOMBER			174
#define IMP_HELP_SUPPORT		175

#define IMP_1HP				199
#define IMP_CREATEPING			200
#define IMP_PRINTSTATS			201


#define IMP_NULL			666
//IMPULSE -- END

#define MCPFLAG_SKIN_WHITE			0
#define MCPFLAG_SKIN_BLUE			1	
#define MCPFLAG_SKIN_RED			2

#define FPATH_PLAYERMDL		 "progs/beta1/mcp_player3.mdl"


