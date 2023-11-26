#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdkhooks>
#include <cstrike>
#include <multicolors>

#define PLUGIN_VERSION	"1.0.2"

ConVar h_enable_plugin;
ConVar h_enable_regen_stop;
ConVar h_enable_godmode;
ConVar h_godmode_team;
ConVar h_godmode_time;
ConVar h_enable_regen;
ConVar h_enable_regen_per;
ConVar h_health_give;
ConVar h_Regen_time;
ConVar h_enable_notify;
ConVar h_enable_notify_god;
ConVar g_transparent;
ConVar g_ctransparent;
ConVar g_cbodyR;
ConVar g_cbodyG;
ConVar g_cbodyB;
ConVar gcv_force = null;

Handle g_bTimerRegen[MAXPLAYERS + 1];
Handle g_bTimerGodModeEnable[MAXPLAYERS + 1];
Handle g_bTimerGodModeDisable[MAXPLAYERS + 1];

bool RoundEnd;
bool g_bIsCSGO;
bool h_benable_plugin = false;
bool h_benable_regen = false;
bool h_bgodmode_team = false;
bool h_benable_notify_god = false;
bool g_btransparent = false;
bool g_bLateLoaded = false;
bool h_benable_regen_stop = false;

int h_benable_notify;
int GetHealthBackFallDamage[MAXPLAYERS + 1];
int AfterDamageHealth[MAXPLAYERS + 1];
int GetHealthAfterFallDamage[MAXPLAYERS + 1];
int h_benable_godmode;
int h_bhealth_give;
int h_benable_regen_per;
int g_bctransparent;
int g_bcbodyR;
int g_bcbodyG;
int g_bcbodyB;

float h_bRegen_time;
float h_bgodmode_time;

public Plugin myinfo =
{
	name = "[CSGO-CSS] HNS Fall Damage",
	author = "Gold KingZ ",
	description = "Fall Damage Print + Health Regeneration Fall Damage + God Mode Timer",
	version = PLUGIN_VERSION,
	url = "https://github.com/oqyh"
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int length)
{
	if(GetEngineVersion() == Engine_CSGO)
	{
		g_bIsCSGO = true;
	}else if(GetEngineVersion() == Engine_CSS)
	{
		g_bIsCSGO = false;
	}
	
	g_bLateLoaded = late;
	return APLRes_Success;
}

public void OnPluginStart()
{
	LoadTranslations( "[CSGO-CSS]HNS-Fall-Damage.phrases" );
	
	CreateConVar("hns_d_version", PLUGIN_VERSION, "[CSGO-CSS] HNS Fall Damage Plugin Version", FCVAR_NOTIFY|FCVAR_DONTRECORD);

	h_enable_plugin = CreateConVar("hns_d_enable_plugin", "1", "Enable [CSGO-CSS] HNS Fall Damage Plugin?\n1= Yes\n0= No", _, true, 0.0, true, 1.0);
	
	h_enable_godmode = CreateConVar("hns_d_enable_godmode", "1", "Enable God Mode For (T) Team\n2= Yes On Every Spawn Only\n1= Yes On Every Round Start Only\n0= No");
	h_godmode_team = CreateConVar("hns_d_godmode_ct", "0", "if [hns_d_enable_godmode 1 or 2] Give God Mode To (CT) Team Also?\n1= Yes\n0= No", _, true, 0.0, true, 1.0);
	h_godmode_time = CreateConVar("hns_d_godmode_time", "10.0", "if [hns_d_enable_godmode 1 or 2] For How Many (in Secs) God Mode Should Be On");
	
	g_transparent = CreateConVar("hns_d_enable_transparent", "1", "Enable Transparent Who God Mode On?\n1= Yes\n0= No", _, true, 0.0, true, 1.0);
	g_ctransparent = CreateConVar("hns_d_transparent", "120", "if [hns_d_enable_transparent 1] How Much Transparent On God Mode\n0= Invisible\n120= Transparent\n255=None");
	g_cbodyR = CreateConVar("hns_d_color_r", "255", "Body *Red* Code Color Pick Here https://www.rapidtables.com/web/color/RGB_Color.html");
	g_cbodyG = CreateConVar("hns_d_color_g", "0", "Body *Green* Code Color  Pick Here https://www.rapidtables.com/web/color/RGB_Color.html");
	g_cbodyB = CreateConVar("hns_d_color_b", "0", "Body *Blue* Code Color  Pick Here https://www.rapidtables.com/web/color/RGB_Color.html");
	
	h_enable_regen = CreateConVar("hns_d_enable_regen", "1", "Enable Regenerate Fall Damage Only\n1= Yes\n0= No", _, true, 0.0, true, 1.0);
	h_enable_regen_stop = CreateConVar("hns_d_regen_stop", "1", "if [hns_d_enable_regen 1] Stop Regenerate Fall Damage If Player Got Stabbed?\n1= Yes\n0= No (Means Regenerate Health Until Hit Old Health + Knife Damage Ignored)", _, true, 0.0, true, 1.0);
	h_health_give = CreateConVar("hns_d_regen_hp", "1", "if [hns_d_enable_regen 1] How Much HP To Give");
	h_Regen_time = CreateConVar("hns_d_regen_time", "2.0", "if [hns_d_regen_hp x] How Many (in sec) To Give HP");
	h_enable_regen_per = CreateConVar("hns_d_regen_per", "1", "How Much Percent Give HP Regenerate Back\n3= 1/3 Means One third\n2= 1/2 Means Half Of it\n1= Means All Of it");
	
	h_enable_notify_god = CreateConVar("hns_d_enable_notify_god", "1", "Send Private Message To Players Who Got GodMode?\n1= Yes\n0= No", _, true, 0.0, true, 1.0);
	h_enable_notify = CreateConVar("hns_d_enable_notify", "1", "Send Announced Message To All Who Got Fall Damage\n2= Yes Without Hp Left\n1= Yes With Hp Left\n0= No Disable Announcer");
	
	
	if(GetEngineVersion() == Engine_CSGO)
	{
		g_bIsCSGO = true;
	}else if(GetEngineVersion() == Engine_CSS)
	{
		g_bIsCSGO = false;
	}else
	{
		SetFailState("Plugin Only Support CS:GO or CS:S!");
		return;
	}
	
	if(g_bIsCSGO == true)
	{
		gcv_force = FindConVar("sv_disable_immunity_alpha");
		gcv_force.AddChangeHook(Onchanged);
	}
	
	HookEvent("round_start", Event_RoundStart);
	HookEvent("round_end", Event_RoundEnd);
	HookEvent("player_spawn", Event_PlayerSpawn);
	HookEvent("player_death",  Event_PlayerDeath);
	
	HookConVarChange(h_enable_plugin, OnSettingsChanged);
	HookConVarChange(h_enable_godmode, OnSettingsChanged);
	HookConVarChange(h_godmode_team, OnSettingsChanged);
	HookConVarChange(h_godmode_time, OnSettingsChanged);
	HookConVarChange(h_enable_regen, OnSettingsChanged);
	HookConVarChange(h_enable_regen_per, OnSettingsChanged);
	HookConVarChange(h_health_give, OnSettingsChanged);
	HookConVarChange(h_Regen_time, OnSettingsChanged);
	HookConVarChange(h_enable_notify, OnSettingsChanged);
	HookConVarChange(h_enable_notify_god, OnSettingsChanged);
	HookConVarChange(g_transparent, OnSettingsChanged);
	HookConVarChange(g_ctransparent, OnSettingsChanged);
	HookConVarChange(g_cbodyR, OnSettingsChanged);
	HookConVarChange(g_cbodyG, OnSettingsChanged);
	HookConVarChange(g_cbodyB, OnSettingsChanged);
	HookConVarChange(h_enable_regen_stop, OnSettingsChanged);
	
	if (g_bLateLoaded) 
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i)) 
			{
				OnClientPutInServer(i);
			}
		}
	}
	
	AutoExecConfig(true, "[CSGO-CSS]HNS-Fall-Damage");
}

public void OnClientPutInServer(int client)
{
    SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}



public void OnClientDisconnect(int client)
{
	GetHealthBackFallDamage[client] = 0;
	AfterDamageHealth[client] = 0;
	GetHealthAfterFallDamage[client] = 0;

	SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}



public void OnConfigsExecuted()
{
	h_benable_plugin = GetConVarBool(h_enable_plugin);
	h_benable_regen_stop = GetConVarBool(h_enable_regen_stop);
	h_benable_godmode = GetConVarInt(h_enable_godmode);
	h_bgodmode_team = GetConVarBool(h_godmode_team);
	h_bgodmode_time = GetConVarFloat(h_godmode_time);
	h_benable_regen = GetConVarBool(h_enable_regen);
	h_benable_regen_per = GetConVarInt(h_enable_regen_per);
	h_bhealth_give = GetConVarInt(h_health_give);
	h_bRegen_time = GetConVarFloat(h_Regen_time);
	h_benable_notify = GetConVarInt(h_enable_notify);
	h_benable_notify_god = GetConVarBool(h_enable_notify_god);
	g_btransparent = GetConVarBool(g_transparent);
	g_bctransparent = GetConVarInt(g_ctransparent);
	g_bcbodyR = GetConVarInt(g_cbodyR);
	g_bcbodyG = GetConVarInt(g_cbodyG);
	g_bcbodyB = GetConVarInt(g_cbodyB);
}


public int OnSettingsChanged(Handle convar, const char[] oldValue, const char[] newValue)
{
	if(convar == h_enable_plugin)
	{
		h_benable_plugin = h_enable_plugin.BoolValue;
	}
	
	if(convar == h_enable_regen_stop)
	{
		h_benable_regen_stop = h_enable_regen_stop.BoolValue;
	}
	
	if(convar == h_enable_godmode)
	{
		h_benable_godmode = h_enable_godmode.IntValue;
	}

	if(convar == h_godmode_team)
	{
		h_bgodmode_team = h_godmode_team.BoolValue;
	}
	
	if(convar == h_godmode_time)
	{
		h_bgodmode_time = h_godmode_time.FloatValue;
	}
	
	if(convar == h_enable_regen)
	{
		h_benable_regen = h_enable_regen.BoolValue;
	}
	
	if(convar == h_enable_regen_per)
	{
		h_benable_regen_per = h_enable_regen_per.IntValue;
	}
	
	if(convar == h_health_give)
	{
		h_bhealth_give = h_health_give.IntValue;
	}
	
	if(convar == h_Regen_time)
	{
		h_bRegen_time = h_Regen_time.FloatValue;
	}
	
	if(convar == h_enable_notify)
	{
		h_benable_notify = h_enable_notify.IntValue;
	}
	
	if(convar == h_enable_notify_god)
	{
		h_benable_notify_god = h_enable_notify_god.BoolValue;
	}
	
	if(convar == g_transparent)
	{
		if(g_bIsCSGO == true)
		{
			ServerCommand("sv_disable_immunity_alpha 1");
		}
		
		g_btransparent = g_transparent.BoolValue;
	}
	
	if(convar == g_ctransparent)
	{
		g_bctransparent = g_ctransparent.IntValue;
	}
	
	if(convar == g_cbodyR)
	{
		g_bcbodyR = g_cbodyR.IntValue;
	}
	
	if(convar == g_cbodyG)
	{
		g_bcbodyG = g_cbodyG.IntValue;
	}
	
	if(convar == g_cbodyB)
	{
		g_bcbodyB = g_cbodyB.IntValue;
	}
	
	return 0;
}

public void Onchanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
	if(g_bIsCSGO == true)
	{
		if(g_btransparent == true)
		{
			if(StrEqual (newValue, "0")){
			gcv_force.BoolValue = true;
			}
		}
	}
}


//vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv[Hooks]vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv//

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (!h_benable_plugin || !IsValidClient(victim))return Plugin_Continue;
	
	if(IsValidClient(attacker))
	{
		if(h_benable_regen_stop && g_bTimerRegen[victim] != null && GetClientTeam(victim) != GetClientTeam(attacker))
		{
			KillTimer(g_bTimerRegen[victim]);
			g_bTimerRegen[victim] = INVALID_HANDLE;
		}
	}
	
	AfterDamageHealth[victim] = GetClientHealth(victim);
	
	if((damagetype & DMG_FALL || damagetype & DMG_VEHICLE) && RoundToFloor(damage) > 0 && GetEntProp(victim, Prop_Data, "m_takedamage", 2))
    {
		if(!h_benable_regen_stop && g_bTimerRegen[victim] != null)
		{
			KillTimer(g_bTimerRegen[victim]);
			g_bTimerRegen[victim] = INVALID_HANDLE;
		}
	
		GetHealthAfterFallDamage[victim] = AfterDamageHealth[victim] - RoundToFloor(damage);
		GetHealthBackFallDamage[victim] = RoundToFloor(damage) / h_benable_regen_per  + GetHealthAfterFallDamage[victim];
		
		if(h_benable_notify == 1)
		{
			if(GetHealthAfterFallDamage[victim] > 0)
			{
				CPrintToChatAll(" %t", "FallDamagewithhp",victim, RoundToFloor(damage), GetHealthAfterFallDamage[victim]);
			}else
			{
				CPrintToChatAll(" %t", "FallDamageDeathwithhp",victim, RoundToFloor(damage));
			}
		}else if(h_benable_notify == 2)
		{
			if(GetHealthAfterFallDamage[victim] > 0)
			{
				CPrintToChatAll(" %t", "FallDamagewithouthp",victim, RoundToFloor(damage));
			}else
			{
				CPrintToChatAll(" %t", "FallDamageDeathwithouthp",victim, RoundToFloor(damage));
			}
		}
		
		if(h_benable_regen && RoundEnd == false)
		{
			g_bTimerRegen[victim] = CreateTimer(h_bRegen_time, Regen_Timer, victim, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		}
	}
	return Plugin_Continue;
}

//vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv[EVENT]vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv//

public void Event_RoundStart(Event event, const char[] name, bool dontBroadcast) 
{
	RoundEnd = false;
	
	if(!h_benable_plugin || h_benable_godmode != 1) return;
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if(IsValidClient(i))
		{
			SetEntProp(i, Prop_Data, "m_takedamage", 2, 1);
			SetEntityRenderMode(i, RENDER_NORMAL);
			SetEntityRenderColor(i, 255, 255, 255, 255);

			if(h_bgodmode_team)
			{
				if(GetClientTeam(i) == CS_TEAM_T || GetClientTeam(i) == CS_TEAM_CT)
				{
					if (g_bTimerGodModeEnable[i] != INVALID_HANDLE)
					{
						g_bTimerGodModeEnable[i] = INVALID_HANDLE;
					}
					
					if (g_bTimerGodModeDisable[i] != INVALID_HANDLE)
					{
						KillTimer(g_bTimerGodModeDisable[i]);
						g_bTimerGodModeDisable[i] = INVALID_HANDLE;
					}
					
					g_bTimerGodModeEnable[i] = CreateTimer(0.1, T_EnableGodMode, i, TIMER_FLAG_NO_MAPCHANGE);
				}
			}else if(!h_bgodmode_team)
			{
				if(GetClientTeam(i) == CS_TEAM_T)
				{
					if (g_bTimerGodModeEnable[i] != INVALID_HANDLE)
					{
						g_bTimerGodModeEnable[i] = INVALID_HANDLE;
					}
					
					if (g_bTimerGodModeDisable[i] != INVALID_HANDLE)
					{
						KillTimer(g_bTimerGodModeDisable[i]);
						g_bTimerGodModeDisable[i] = INVALID_HANDLE;
					}
					
					g_bTimerGodModeEnable[i] = CreateTimer(0.1, T_EnableGodMode, i, TIMER_FLAG_NO_MAPCHANGE);
					
				}
			}
		}
	}
}

public void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast) 
{
	if(!h_benable_plugin || h_benable_godmode != 2) return;

	
	int i = GetClientOfUserId(GetEventInt(event, "userid"));

	if (IsValidClient(i))
	{
		if (g_bTimerRegen[i] != INVALID_HANDLE)
		{
			KillTimer(g_bTimerRegen[i]);
			g_bTimerRegen[i] = INVALID_HANDLE;
		}
		
		SetEntProp(i, Prop_Data, "m_takedamage", 2, 1);
		SetEntityRenderMode(i, RENDER_NORMAL);
		SetEntityRenderColor(i, 255, 255, 255, 255);

		if(h_bgodmode_team)
		{
			if(GetClientTeam(i) == CS_TEAM_T || GetClientTeam(i) == CS_TEAM_CT)
			{
				if (g_bTimerGodModeEnable[i] != INVALID_HANDLE)
				{
					g_bTimerGodModeEnable[i] = INVALID_HANDLE;
				}
				
				if (g_bTimerGodModeDisable[i] != INVALID_HANDLE)
				{
					KillTimer(g_bTimerGodModeDisable[i]);
					g_bTimerGodModeDisable[i] = INVALID_HANDLE;
				}
				
				g_bTimerGodModeEnable[i] = CreateTimer(0.1, T_EnableGodMode, i, TIMER_FLAG_NO_MAPCHANGE);
			}
		}else if(!h_bgodmode_team)
		{
			if(GetClientTeam(i) == CS_TEAM_T)
			{
				if (g_bTimerGodModeEnable[i] != INVALID_HANDLE)
				{
					g_bTimerGodModeEnable[i] = INVALID_HANDLE;
				}
				
				if (g_bTimerGodModeDisable[i] != INVALID_HANDLE)
				{
					KillTimer(g_bTimerGodModeDisable[i]);
					g_bTimerGodModeDisable[i] = INVALID_HANDLE;
				}
				
				g_bTimerGodModeEnable[i] = CreateTimer(0.1, T_EnableGodMode, i, TIMER_FLAG_NO_MAPCHANGE);
				
			}
		}
	}
	
}

public Action Event_RoundEnd(Event event, const char[] name, bool dontBroadcast)
{	
	RoundEnd = true;
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if(IsValidClient(i))
		{
			if (g_bTimerRegen[i] != INVALID_HANDLE)
			{
				KillTimer(g_bTimerRegen[i]);
				g_bTimerRegen[i] = INVALID_HANDLE;
			}
			
			SetEntProp(i, Prop_Data, "m_takedamage", 2, 1);

			SetEntityRenderMode(i, RENDER_NORMAL);
			SetEntityRenderColor(i, 255, 255, 255, 255);
		}
	}
	return Plugin_Continue;
}

public void Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast) 
{
	if(!h_benable_plugin) return;

	if(h_benable_godmode == 1 || h_benable_godmode == 2)
	{
		int client = GetClientOfUserId(GetEventInt(event, "userid"));

		if (IsValidClient(client))
		{
			if (g_bTimerRegen[client] != INVALID_HANDLE)
			{
				KillTimer(g_bTimerRegen[client]);
				g_bTimerRegen[client] = INVALID_HANDLE;
			}
			
			SetEntProp(client, Prop_Data, "m_takedamage", 2, 1);

			SetEntityRenderMode(client, RENDER_NORMAL);
			SetEntityRenderColor(client, 255, 255, 255, 255);
		}
	}
}

//vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv[Timers]vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv//

public Action T_EnableGodMode(Handle timer, any i)
{
	if(IsValidClient(i))
	{
		SetEntProp(i, Prop_Data, "m_takedamage", 0, 1);
		
		if(g_btransparent){
		SetEntityRenderMode(i, RENDER_TRANSALPHA);
		SetEntityRenderColor(i, g_bcbodyR, g_bcbodyG, g_bcbodyB, g_bctransparent);
		}else if(!g_btransparent){
		SetEntityRenderMode(i, RENDER_TRANSALPHA);
		SetEntityRenderColor(i, g_bcbodyR, g_bcbodyG, g_bcbodyB, 255);
		}
	
		if(h_benable_notify_god)
		{
			CPrintToChat(i, " %t", "GodModeOn", h_bgodmode_time);
		}

		
		g_bTimerGodModeDisable[i] = CreateTimer(h_bgodmode_time, T_DisableGodMode, i, TIMER_FLAG_NO_MAPCHANGE);
	}
	return Plugin_Continue;
}

public Action T_DisableGodMode(Handle timer, any i)
{
	if(IsValidClient(i))
	{
		SetEntProp(i, Prop_Data, "m_takedamage", 2, 1);
		
		SetEntityRenderMode(i, RENDER_NORMAL);
		SetEntityRenderColor(i, 255, 255, 255, 255);
		
		if(h_benable_notify_god)
		{
			CPrintToChat(i, " %t", "GodModeOff");
		}
		
		if (g_bTimerGodModeDisable[i] != INVALID_HANDLE)
		{
			KillTimer(g_bTimerGodModeDisable[i]);
			g_bTimerGodModeDisable[i] = INVALID_HANDLE;
		}
		
	}
	return Plugin_Continue;
}

public Action Regen_Timer(Handle timer, any victim)
{
	if(IsValidClient(victim) && RoundEnd == false)
	{
		int currenthealth = GetClientHealth(victim);
		int rollbackhealth = (currenthealth - GetHealthBackFallDamage[victim]);
		
		if(currenthealth < GetHealthBackFallDamage[victim])
		{
			SetEntityHealth(victim, GetClientHealth(victim) + h_bhealth_give);
		}else if(currenthealth > GetHealthBackFallDamage[victim])
		{
			SetEntityHealth(victim, GetClientHealth(victim) - rollbackhealth);
			g_bTimerRegen[victim] = INVALID_HANDLE;
			KillTimer(timer);
		}else if(currenthealth == GetHealthBackFallDamage[victim])
		{
			g_bTimerRegen[victim] = INVALID_HANDLE;
			KillTimer(timer);
		}
	}
	return Plugin_Continue;
}

//vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv[Bools]vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv//

bool IsValidClient(int client) {
    return (client > 0 && client <= MaxClients && IsClientInGame(client));
}