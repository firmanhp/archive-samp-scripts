// Noobist LandMine System (NLM)
// Created by Noobist, Credits to ZeeX (ZCMD), Y_Less (foreach), Incognito (Streamer), sheen (Concept), Kye (SA-MP)
// You need ZCMD include from ZeeX, Streamer from Incognito, and foreach from Y_Less.


#define FILTERSCRIPT
#include <a_samp>
#include <zcmd>
#include <streamer>
#include <foreach>

new LMCP[MAX_PLAYERS];

forward Plant(playerid);

public OnFilterScriptInit()
{
	foreach(Player, p) OnPlayerConnect(p);
	print("\n--------------------------------------");
	print(" Noobist LandMine System Loaded");
	print("--------------------------------------\n");
	return 1;
}

public OnFilterScriptExit()
{
	foreach(Player, p)
	{
		DeletePVar(p, "HasLM");
		DeletePVar(p, "LMX");
		DeletePVar(p, "LMY");
		DeletePVar(p, "LMZ");
		DeletePVar(p, "LMID");
	}
	for(new cp = 0; cp < MAX_PLAYERS; cp++) DestroyDynamicCP(LMCP[cp]);
	print("\n--------------------------------------");
	print(" Noobist LandMine System Unloaded");
	print("--------------------------------------\n");
	return 1;
}

public OnPlayerConnect(playerid)
{
	SendClientMessage(playerid, 0x00FF00, "This server landmine system is powered by Noobist LandMine System. Use /minehelp for more information.");
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	if(GetPVarInt(playerid, "HasLM") == 2) DestroyDynamicCP(LMCP[playerid]);
	return 1;
}

public OnPlayerEnterDynamicCP(playerid, checkpointid)
{
	foreach(Player, p)
	{
	    if(GetPVarInt(p, "HasLM") == 2 && GetPVarInt(p, "LMID") == checkpointid)
	    {
	        if(p == playerid) return 1;
	        CreateExplosion(GetPVarFloat(p, "LMX"), GetPVarFloat(p, "LMY"), GetPVarFloat(p, "LMZ"), 0, 10.0);
	        SetPVarInt(p, "HasLM", 0);
			DeletePVar(p, "LMID");
	        SendClientMessage(playerid, 0xFF0000, "You stepped on a landmine!");
	        SendClientMessage(p, 0x00FF00, "Your landmine has exploded.");
			DestroyDynamicCP(checkpointid);
			DeletePVar(p, "LMX");
			DeletePVar(p, "LMY");
			DeletePVar(p, "LMZ");
	        return 1;
		}
	}
	return 1;
}

CMD:plant(playerid)
{
	if(GetPVarInt(playerid, "HasLM") == 0) return SendClientMessage(playerid, 0xFF0000, "You don't have any landmine. Buy it in Emmet's Place");
	if(GetPVarInt(playerid, "HasLM") == 2) return SendClientMessage(playerid, 0xFF0000, "You already planted your landmine.");
	if(GetPlayerSpecialAction(playerid) != SPECIAL_ACTION_DUCK) return SendClientMessage(playerid, 0xFF0000, "You must be crouching to plant a landmine.");
	SetTimerEx("Plant", 5000, false, "i", playerid);
	SendClientMessage(playerid, 0x00FF00, "Hold your position in 5 seconds to plant the landmine.");
	new Float:x, Float:y, Float:z;
	GetPlayerPos(playerid, x, y, z);
	SetPVarFloat(playerid, "LMX", x);
	SetPVarFloat(playerid, "LMY", y);
	SetPVarFloat(playerid, "LMZ", z);
	return 1;
}



public Plant(playerid)
{
	new Float:x, Float:y, Float:z;
	GetPlayerPos(playerid, x, y, z);
	if(x != GetPVarFloat(playerid, "LMX") || y != GetPVarFloat(playerid, "LMY")) return SendClientMessage(playerid, 0xFF0000, "You must hold your position in 5 seconds to plant the landmine.");
	if(GetPlayerSpecialAction(playerid) != SPECIAL_ACTION_DUCK) return SendClientMessage(playerid, 0xFF0000, "You must be crouching to plant a landmine.");
	LMCP[playerid] = CreateDynamicCP(x, y, z, 3.5, -1, -1, -1, 4.0);
	SetPVarInt(playerid, "HasLM", 2);
	SetPVarInt(playerid, "LMID", LMCP[playerid]);
	SendClientMessage(playerid, 0x00FF00, "Landmine planted.");
	return 1;
}

CMD:defusemine(playerid)
{
	if(GetPVarInt(playerid, "HasLM") == 0) return SendClientMessage(playerid, 0xFF0000, "You don't have any landmine. Buy it in Emmet's Place.");
	if(GetPVarInt(playerid, "HasLM") == 1) return SendClientMessage(playerid, 0xFF0000, "You don't have any planted landmine.");
	SetPVarInt(playerid, "HasLM", 0);
	DeletePVar(playerid, "LMID");
	DeletePVar(playerid, "LMX");
	DeletePVar(playerid, "LMY");
	DeletePVar(playerid, "LMZ");
	DestroyDynamicCP(LMCP[playerid]);
	SendClientMessage(playerid, 0x00FF00, "Landmine defused.");
	return 1;
}

CMD:buymine(playerid)
{
	if(!IsPlayerInRangeOfPoint(playerid, 20, 2447.1755, -1972.8712, 13.5469)) return SendClientMessage(playerid, 0xFF0000, "You must in Emmet's Place to buy a landmine.");
	if(GetPVarInt(playerid, "HasLM") >= 1) return SendClientMessage(playerid, 0xFF0000, "You already have a landmine.");
	if(GetPlayerMoney(playerid) < 25000) return SendClientMessage(playerid, 0xFF0000, "You need $25000 to buy a landmine.");
	SetPVarInt(playerid, "HasLM", 1);
	GivePlayerMoney(playerid, -25000);
    SendClientMessage(playerid, 0x00FF00, "You have purchased landmine, use /plant to plant the landmine.");
    return 1;
}

CMD:minehelp(playerid)
{
	SendClientMessage(playerid, 0x00FF00, "Noobist LandMine System, Credits: ZeeX (ZCMD), Y_Less (foreach), Incognito (Streamer), sheen (Concept), Kye (SA-MP)");
	SendClientMessage(playerid, 0x00FF00, "Available Commands");
	SendClientMessage(playerid, 0x00FF00, "/buymine -> purchase a landmine in Emmet's Place");
	SendClientMessage(playerid, 0x00FF00, "/plant -> plant a landmine");
	SendClientMessage(playerid, 0x00FF00, "/defusemine -> deactivate your landmine");
	return 1;
}