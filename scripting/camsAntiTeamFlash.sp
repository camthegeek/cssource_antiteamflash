/**
 * Anti-teamflash Plugin
 * Prevents team mates from being blinded by own team mate flashes. (todo verify team mate flashes do not wipe enemy flashes) 
 */

#include <sourcemod>
#include <sdktools>

#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_NAME "Anti Team Flash"
#define PLUGIN_VERSION "1.0.0"

public Plugin myinfo = {
    name = PLUGIN_NAME,
    author = "camthegeek",
    description = "Prevents teammates from being flashed by friendly flashbangs",
    version = PLUGIN_VERSION,
    url = "https://github.com/camthegeek/cssource_antiteamflash"
};

ConVar g_hLogTeamFlash;
ConVar g_hDebugTeamFlash;

public void OnPluginStart()
{
    g_hLogTeamFlash = CreateConVar("sm_log_teamflash", "1", "Log team flash incidents to SourceMod logs", FCVAR_NOTIFY);
    g_hDebugTeamFlash = CreateConVar("sm_debug_teamflash", "0", "Enable debug logging for team flashes", FCVAR_NOTIFY);
    
    HookEvent("flashbang_detonate", Event_FlashbangDetonate, EventHookMode_Pre);
    HookEvent("player_blind", Event_PlayerBlind, EventHookMode_Pre);
    HookEvent("player_blind", Event_PlayerBlindPost, EventHookMode_Post);
    
    LoadTranslations("common.phrases");
    
    // Log plugin start
    LogMessage("Plugin %s v%s loaded", PLUGIN_NAME, PLUGIN_VERSION);
    
}

public Action Event_FlashbangDetonate(Event event, const char[] name, bool dontBroadcast)
{
    int userid = event.GetInt("userid");
    int thrower = GetClientOfUserId(userid);
    
    if (!thrower || !IsClientInGame(thrower))
        return Plugin_Continue;
        
    if (g_hDebugTeamFlash.BoolValue)
    {
        LogMessage("Flashbang detonated by %N (Team: %d)", thrower, GetClientTeam(thrower));
    }
    
    CreateTimer(0.1, Timer_CheckTeamFlash, userid);
    return Plugin_Continue;
}

public Action Timer_CheckTeamFlash(Handle timer, any userid)
{
    int thrower = GetClientOfUserId(userid);
    if (!thrower || !IsClientInGame(thrower))
        return Plugin_Stop;
        
    int throwerTeam = GetClientTeam(thrower);
    
    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i) || !IsPlayerAlive(i) || i == thrower)
            continue;
            
        if (GetClientTeam(i) == throwerTeam)
        {
            float flashDuration = GetEntPropFloat(i, Prop_Send, "m_flFlashDuration");
            float flashAlpha = GetEntPropFloat(i, Prop_Send, "m_flFlashMaxAlpha");
            
            if (flashDuration > 0.0 || flashAlpha > 0.0)
            {
                if (g_hDebugTeamFlash.BoolValue)
                {
                    LogMessage("Preventing team flash: %N -> %N (Duration: %.2f, Alpha: %.2f)", 
                        thrower, i, flashDuration, flashAlpha);
                }
                
                // Log and notify
                if (g_hLogTeamFlash.BoolValue)
                {
                    LogAction(thrower, i, "\"%L\" attempted to flash teammate \"%L\"", thrower, i);
                }
                
                PrintToChat(thrower, "\x04[Anti-TeamFlash]\x01 You flashed teammate %N!", i);
                PrintToChat(i, "\x04[Anti-TeamFlash]\x01 Protected from %N's flashbang", thrower);
                
                // Notify admins
                for (int admin = 1; admin <= MaxClients; admin++)
                {
                    if (IsClientInGame(admin) && (GetUserFlagBits(admin) & ADMFLAG_GENERIC))
                    {
                        PrintToChat(admin, "\x04[Anti-TeamFlash]\x01 %N flashed teammate %N", thrower, i);
                    }
                }
                
                // Remove flash effect
                SetEntPropFloat(i, Prop_Send, "m_flFlashDuration", 0.0);
                SetEntPropFloat(i, Prop_Send, "m_flFlashMaxAlpha", 0.0);
            }
        }
    }
    
    return Plugin_Stop;
}

public Action Event_PlayerBlind(Event event, const char[] name, bool dontBroadcast)
{
    int userid = event.GetInt("userid");
    int victim = GetClientOfUserId(userid);
    int attacker = GetClientOfUserId(event.GetInt("attacker"));
    
    if (!victim || !attacker || !IsClientInGame(victim) || !IsClientInGame(attacker))
        return Plugin_Continue;
        
    if (GetClientTeam(victim) == GetClientTeam(attacker) && victim != attacker)
    {
        if (g_hDebugTeamFlash.BoolValue)
        {
            LogMessage("Team flash detected (Pre): %N -> %N", attacker, victim);
        }
        return Plugin_Handled;
    }
    
    return Plugin_Continue;
}

public void Event_PlayerBlindPost(Event event, const char[] name, bool dontBroadcast)
{
    int userid = event.GetInt("userid");
    int victim = GetClientOfUserId(userid);
    
    if (!victim || !IsClientInGame(victim))
        return;
        
    if (g_hDebugTeamFlash.BoolValue)
    {
        float duration = GetEntPropFloat(victim, Prop_Send, "m_flFlashDuration");
        float alpha = GetEntPropFloat(victim, Prop_Send, "m_flFlashMaxAlpha");
        LogMessage("Flash values (Post) for %N - Duration: %.2f, Alpha: %.2f", 
            victim, duration, alpha);
    }
}