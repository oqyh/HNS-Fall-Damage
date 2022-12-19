#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdkhooks>
#include <cstrike>
#include <multicolors>

ConVar h_enable_plugin;
ConVar h_enable_godmode;
ConVar h_godmode_team;
ConVar h_godmode_time;
ConVar h_enable_regen;
ConVar h_enable_regen_per;
ConVar h_health_give;
ConVar h_Regen_time;
ConVar h_enable_notify;
ConVar h_enable_notify_god;

Handle g_bTimer[MAXPLAYERS + 1];

bool RoundEnd;
bool h_benable_plugin = false;
bool h_benable_regen = false;
bool h_bgodmode_team = false;
bool h_benable_notify_god = false;

int  h_benable_notify;
int GetHealthBackFallDamage[MAXPLAYERS + 1];
int AfterDamageHealth[MAXPLAYERS + 1];
int GetHealthAfterFallDamage[MAXPLAYERS + 1];
int h_benable_godmode;
int h_bhealth_give;
int h_benable_regen_per;

float h_bRegen_time;
float h_bgodmode_time;

public Plugin myinfo =
{
	name = "[HNS] Fall-Damage",
	author = "Gold KingZ ",
	description = "Fall Damage Print + Health Regeneration Fall Damage + God Mode Timer",
	version = "1.0.1",
	url = "https://github.com/oqyh"
}

public void OnPluginStart()
{
	LoadTranslations( "HNS-Fall-Damage.phrases" );
	
	h_enable_plugin = CreateConVar("hns_d_enable_plugin", "1", "Enable [HNS] Fall-Damage Plugin || 1= Yes || 0= No", _, true, 0.0, true, 1.0);
	
	h_enable_godmode = CreateConVar("hns_d_enable_godmode", "1", "Enable God Mode For Ts || 2= On Spawn Only || 1= On Round Start Only || 0= No");
	h_godmode_team = CreateConVar("hns_d_godmode_ct", "0", "if hns_d_enable_godmode 1 or 2 Give God Mode To CTs Also? || 1= Yes || 0= No", _, true, 0.0, true, 1.0);
	h_godmode_time = CreateConVar("hns_d_godmode_time", "10.0", "For How Many (in sec) if hns_d_enable_godmode 1 or 2 God Mode Should Be On");
	
	h_enable_regen = CreateConVar("hns_d_enable_regen", "1", "Enable Regenerate Fall Damage Only  || 1= Yes || 0= No", _, true, 0.0, true, 1.0);
	h_enable_regen_per = CreateConVar("hns_d_regen_per", "1", "How Much Percent Give HP Regenerate Back example 2= 2% Means Half Of it || 1= 0% Means All Of it");
	h_health_give = CreateConVar("hns_d_regen_hp", "1", "How Much HP To Give if hns_d_enable_regen 1");
	h_Regen_time = CreateConVar("hns_d_regen_time", "2.0", "How Many (in sec) hns_d_regen_hp Give Hp");
	
	h_enable_notify = CreateConVar("hns_d_enable_notify", "1", "Enable Notification Message To All Who Got Fall Damage || 2= Without HP || 1= With Hp || 0= No");
	
	h_enable_notify_god = CreateConVar("hns_d_enable_notify_god", "1", "Enable Notification God Mode  || 1= Yes || 0= No", _, true, 0.0, true, 1.0);

	HookEvent("round_start", Event_RoundStart);
	HookEvent("round_end", Event_RoundEnd);
	HookEvent("player_spawn", Event_PlayerSpawn);
	
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
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i))
		{
			SDKHook(i, SDKHook_OnTakeDamage, OneHitDamage);
		}
	}
	AutoExecConfig(true, "HNS-Fall-Damage");
	
}


public void OnConfigsExecuted()
{
	h_benable_plugin = GetConVarBool(h_enable_plugin);
	h_benable_godmode = GetConVarInt(h_enable_godmode);
	h_bgodmode_team = GetConVarBool(h_godmode_team);
	h_bgodmode_time = GetConVarFloat(h_godmode_time);
	h_benable_regen = GetConVarBool(h_enable_regen);
	h_benable_regen_per = GetConVarInt(h_enable_regen_per);
	h_bhealth_give = GetConVarInt(h_health_give);
	h_bRegen_time = GetConVarFloat(h_Regen_time);
	h_benable_notify = GetConVarInt(h_enable_notify);
	h_benable_notify_god = GetConVarBool(h_enable_notify_god);
}

public int OnSettingsChanged(Handle convar, const char[] oldValue, const char[] newValue)
{
	if(convar == h_enable_plugin)
	{
		h_benable_plugin = h_enable_plugin.BoolValue;
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
	return 0;
}

public void Event_RoundStart(Event event, const char[] name, bool dontBroadcast) 
{
	RoundEnd = false;
	
	if(!h_benable_plugin || h_benable_godmode != 1) return;
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if(IsValidClient(i))
		{
			if(h_bgodmode_team)
			{
				if(GetEntProp(i, Prop_Send, "m_lifeState") == 0)
				{
					CreateTimer(h_bgodmode_time, RemoveGodMode, i);
					SetEntProp(i, Prop_Data, "m_takedamage", 0, 1);
					if(h_benable_notify_god)
					{
						CPrintToChat(i, " %t %t", "Tag", "GodModeOn", h_bgodmode_time);
					}
				}
			}else 
			{
				if(GetEntProp(i, Prop_Send, "m_lifeState") == 0 && GetClientTeam(i) == CS_TEAM_T)
				{
					CreateTimer(h_bgodmode_time, RemoveGodMode, i);
					SetEntProp(i, Prop_Data, "m_takedamage", 0, 1);
					if(h_benable_notify_god)
					{
						CPrintToChat(i, " %t %t", "Tag", "GodModeOn", h_bgodmode_time);
					}
				}
			}
		}
	}
}

public void Event_RoundEnd(Event event, const char[] name, bool dontBroadcast)
{	
	RoundEnd = true;
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(IsValidClient(client))
	{
		if (g_bTimer[client] != INVALID_HANDLE)
		{
			KillTimer(g_bTimer[client]);
			g_bTimer[client] = INVALID_HANDLE;
		}
	}
}


public void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast) 
{
	if(!h_benable_plugin || h_benable_godmode != 2) return;
	
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if(IsValidClient(client))
	{
		if (g_bTimer[client] != INVALID_HANDLE)
		{
			KillTimer(g_bTimer[client]);
			g_bTimer[client] = INVALID_HANDLE;
		}
		
		if(h_bgodmode_team)
		{
			if(GetEntProp(client, Prop_Send, "m_lifeState") == 0)
			{
				CreateTimer(h_bgodmode_time, RemoveGodMode, client);
				SetEntProp(client, Prop_Data, "m_takedamage", 0, 1);
				if(h_benable_notify_god)
				{
					CPrintToChat(client, " %t %t", "Tag", "GodModeOn", h_bgodmode_time);
				}
			}
		}else
		{
			if(GetEntProp(client, Prop_Send, "m_lifeState") == 0 && GetClientTeam(client) == CS_TEAM_T)
			{
				CreateTimer(h_bgodmode_time, RemoveGodMode, client);
				SetEntProp(client, Prop_Data, "m_takedamage", 0, 1);
				if(h_benable_notify_god)
				{
					CPrintToChat(client, " %t %t", "Tag", "GodModeOn", h_bgodmode_time);
				}
			}
		}
	}
} 

public Action RemoveGodMode(Handle timer6, any client)
{
	if(IsClientInGame(client) && GetEnts(client) && GetEntProp(client, Prop_Send, "m_lifeState") == 0) 
	{
		SetEntProp(client, Prop_Data, "m_takedamage", 2, 1);
		if(h_benable_notify_god)
		{
			CPrintToChat(client, " %t %t", "Tag", "GodModeOff");
		}
  }
	return Plugin_Continue;
}

public void OnClientDisconnect(int client)
{
	if (g_bTimer[client] != INVALID_HANDLE)
    {
        KillTimer(g_bTimer[client]);
        g_bTimer[client] = INVALID_HANDLE;
    }
}

public void OnClientPutInServer(int client)
{
    SDKHook(client, SDKHook_OnTakeDamage, OneHitDamage);
}

public Action OneHitDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (!h_benable_plugin || !victim || victim > MaxClients || !IsClientInGame(victim))
    {
        return Plugin_Continue;
    }
	
	if(g_bTimer[victim] != null)
    {
        delete g_bTimer[victim];
    }
	
	AfterDamageHealth[victim] = GetClientHealth(victim);
	
	
	if(IsValidClient(victim))
	{
		if( (damagetype & DMG_FALL || damagetype & DMG_VEHICLE) && RoundToFloor(damage) > 0.0 && GetEntProp(victim, Prop_Data, "m_takedamage", 2))
		{
			GetHealthAfterFallDamage[victim] = AfterDamageHealth[victim] - RoundToFloor(damage);
			GetHealthBackFallDamage[victim] = RoundToFloor(damage) / h_benable_regen_per + GetHealthAfterFallDamage[victim];
			
			if(GetHealthAfterFallDamage[victim] > 0)
			{
				if(g_bTimer[victim] == INVALID_HANDLE && h_benable_regen && GetEntProp(victim, Prop_Data, "m_takedamage", 2) && RoundEnd == false)
				{
					g_bTimer[victim] = CreateTimer(h_bRegen_time, Regen_Timer, victim, TIMER_REPEAT);
				}
				if(h_benable_notify == 1)
				{
					CPrintToChatAll(" %t %t", "Tag", "FallDamagewithhp",victim, RoundToFloor(damage), GetHealthAfterFallDamage[victim]);
				}else if(h_benable_notify == 2)
				{
					CPrintToChatAll(" %t %t", "Tag", "FallDamagewithouthp",victim, RoundToFloor(damage));
				}else if(h_benable_notify != 1 && h_benable_notify != 2)
				{
					return Plugin_Continue;
				}
				return Plugin_Changed;
			}else
			{
				if(h_benable_notify == 1)
				{
					CPrintToChatAll(" %t %t", "Tag", "FallDamageDeathwithhp",victim, RoundToFloor(damage));
				}else if(h_benable_notify == 2)
				{
					CPrintToChatAll(" %t %t", "Tag", "FallDamageDeathwithouthp",victim, RoundToFloor(damage));
				}else if(h_benable_notify != 1 && h_benable_notify != 2)
				{
					return Plugin_Continue;
				}
			}
		}
	}
	return Plugin_Continue;
}

public Action Regen_Timer(Handle timer, any victim)
{
	if(g_bTimer[victim] != timer)
    {
        return Plugin_Stop;
    }
	
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
			g_bTimer[victim] = INVALID_HANDLE;
			KillTimer(timer);
		}else if(currenthealth == GetHealthBackFallDamage[victim])
		{
			g_bTimer[victim] = INVALID_HANDLE;
			KillTimer(timer);
		}
	}
		
	return Plugin_Continue;
}

public bool GetEnts(int client)
{
	return (GetEntProp(client, Prop_Data, "m_takedamage") == 0);
}

bool IsValidClient(int client) {
    return (client > 0 && client <= MaxClients && IsClientInGame(client) && IsPlayerAlive(client));
}