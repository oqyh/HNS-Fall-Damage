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
ConVar h_health_give;
ConVar h_Regen_time;
ConVar h_enable_notify;
ConVar h_enable_notify_god;

Handle g_bTimer[MAXPLAYERS + 1];

bool h_benable_plugin = false;
bool h_benable_regen = false;
bool h_bgodmode_team = false;
bool h_benable_notify = false;
bool h_benable_notify_god = false;

int GetHealthBackFallDamage[MAXPLAYERS + 1];
int AfterDamageHealth[MAXPLAYERS + 1];
int GetHealthAfterFallDamage[MAXPLAYERS + 1];
int BeforeDamageHealth[MAXPLAYERS + 1];
int h_benable_godmode;
int h_bhealth_give;

float h_bRegen_time;
float h_bgodmode_time;

public Plugin myinfo =
{
	name = "[HNS] Fall-Damage",
	author = "Gold KingZ ",
	description = "Fall Damage Print + Health Regeneration Fall Damage + God Mode Timer",
	version = "1.0.0",
	url = "https://github.com/oqyh"
}

public void OnPluginStart()
{
	LoadTranslations( "HNS-Fall-Damage.phrases" );
	
	h_enable_plugin = CreateConVar("hns_d_enable_plugin", "1", "Enable Fall Damage Plugin || 1= Yes || 0= No", _, true, 0.0, true, 1.0);
	
	h_enable_godmode = CreateConVar("hns_d_enable_godmode", "0", "Enable God Mode For Ts || 2= On Spawn Only || 1= On Round Start Only || 0= No");
	h_godmode_team = CreateConVar("hns_d_godmode_ct", "0", "if hns_d_enable_godmode 1 or 2 Give God Mode To CTs Also? || 1= Yes || 0= No", _, true, 0.0, true, 1.0);
	h_godmode_time = CreateConVar("hns_d_godmode_time", "5.0", "For How Many (in sec) if hns_d_enable_godmode 1 or 2 God Mode Should Be On");
	
	h_enable_regen = CreateConVar("hns_d_enable_regen", "0", "Enable Regenerate Fall Damage Only  || 1= Yes || 0= No", _, true, 0.0, true, 1.0);
	h_health_give = CreateConVar("hns_d_regen_hp", "5", "How Much HP To Give if hns_d_enable_regen 1");
	h_Regen_time = CreateConVar("hns_d_regen_time", "5.0", "How Many (in sec) hns_d_regen_hp Give Hp");
	
	h_enable_notify = CreateConVar("hns_d_enable_notify", "0", "Enable Notification Message To All Who Got Fall Damage  || 1= Yes || 0= No", _, true, 0.0, true, 1.0);
	h_enable_notify_god = CreateConVar("hns_d_enable_notify_god", "0", "Enable Notification God Mode  || 1= Yes || 0= No", _, true, 0.0, true, 1.0);

	HookEvent("round_start", Event_RoundStart);
	HookEvent("player_spawn", Event_PlayerSpawn);

	HookConVarChange(h_enable_plugin, OnSettingsChanged);
	HookConVarChange(h_enable_godmode, OnSettingsChanged);
	HookConVarChange(h_godmode_team, OnSettingsChanged);
	HookConVarChange(h_godmode_time, OnSettingsChanged);
	HookConVarChange(h_enable_regen, OnSettingsChanged);
	HookConVarChange(h_health_give, OnSettingsChanged);
	HookConVarChange(h_Regen_time, OnSettingsChanged);
	HookConVarChange(h_enable_notify, OnSettingsChanged);
	HookConVarChange(h_enable_notify_god, OnSettingsChanged);
	
	for (int i = 1; i < MaxClients; ++i)
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
	h_bhealth_give = GetConVarInt(h_health_give);
	h_bRegen_time = GetConVarFloat(h_Regen_time);
	h_benable_notify = GetConVarBool(h_enable_notify);
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
		h_benable_notify = h_enable_notify.BoolValue;
	}
	
	if(convar == h_enable_notify_god)
	{
		h_benable_notify_god = h_enable_notify_god.BoolValue;
	}
	return 0;
}

public Action Event_RoundStart(Handle event, const char[] name, bool dontBroadcast)
{
	if(!h_benable_plugin || h_benable_godmode != 1) return Plugin_Continue;
	
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
	return Plugin_Continue;
}

public void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast) 
{
	if(!h_benable_plugin || h_benable_godmode != 2) return;
	
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(IsValidClientt(client))
	{
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
	if(IsClientInGame(client) && IsClientSpawnProtected(client) && GetEntProp(client, Prop_Send, "m_lifeState") == 0) 
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
	g_bTimer[client] = INVALID_HANDLE;
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
	return Plugin_Handled;
	
	AfterDamageHealth[victim] = GetClientHealth(victim);
	BeforeDamageHealth[victim] = GetClientHealth(victim);
	
	if(IsValidClient(victim))
	{
		if( (damagetype & DMG_FALL || damagetype & DMG_VEHICLE) && RoundToFloor(damage) > 0.0)
		{
			GetHealthAfterFallDamage[victim] = AfterDamageHealth[victim] - RoundToFloor(damage);
			GetHealthBackFallDamage[victim] = GetHealthAfterFallDamage[victim] + RoundToFloor(damage);
			
			if(GetHealthAfterFallDamage[victim] > 1)
			{
				if(g_bTimer[victim] == INVALID_HANDLE && h_benable_regen)
				{
					g_bTimer[victim] = CreateTimer(h_bRegen_time, Regen_Timer, victim, TIMER_REPEAT);
				}
				if(h_benable_notify)
				{
					CPrintToChatAll(" %t %t", "Tag", "FallDamage",victim, RoundToFloor(damage), GetHealthAfterFallDamage[victim]);
				}
				return Plugin_Changed;
			}else
			{
				CPrintToChatAll(" %t %t", "Tag", "FallDamageDeath",victim, RoundToFloor(damage));
			}
		}
	}
	return Plugin_Continue;
}

public Action Regen_Timer(Handle timer, any victim)
{
	int currenthealth = GetClientHealth(victim);
	int rollbackhealth = (currenthealth - GetHealthBackFallDamage[victim]);
	
	if(IsValidClient(victim))
	{
		if(currenthealth < GetHealthBackFallDamage[victim])
		{
			SetEntityHealth(victim, GetClientHealth(victim) + h_bhealth_give);
		}else if(currenthealth > GetHealthBackFallDamage[victim] )
		{
			SetEntityHealth(victim, GetClientHealth(victim) - rollbackhealth);
			g_bTimer[victim] = INVALID_HANDLE;
			KillTimer(timer);
		}else if(currenthealth == GetHealthBackFallDamage[victim] )
		{
			g_bTimer[victim] = INVALID_HANDLE;
			KillTimer(timer);
		}
	}
	return Plugin_Continue;
}

public bool IsClientSpawnProtected(int client)
{
	return (GetEntProp(client, Prop_Data, "m_takedamage") == 0);
}

static bool IsValidClientt( int client ) 
{
    if ( !( 1 <= client <= MaxClients ) || !IsClientInGame(client) ) 
        return false; 
     
    return true; 
}

bool IsValidClient(int client) {
    return (client > 0 && client <= MaxClients && IsClientInGame(client) && !IsFakeClient(client) && IsPlayerAlive(client));
}