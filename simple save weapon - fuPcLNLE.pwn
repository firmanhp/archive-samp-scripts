// Simple Weapon saving system by Noobist

// Includes
#include <a_samp>
#include <dini>

// Defines
#define FILTERSCRIPT

// Callbacks
forward SaveWeapon(playerid);
forward LoadWeapon(playerid);
forward SaveWeaponToDini(playerid);

public OnFilterScriptInit()
{
	print("\n--------------------------------------");
	print(" Simple Weapon Autosave System by Noobist Loaded");
	print("--------------------------------------\n");
	return 1;
}

public OnFilterScriptExit()
{
	print("\n--------------------------------------");
	print(" Simple Weapon Autosave System by Noobist Unloaded");
	print("--------------------------------------\n");
	return 1;
}

stock GetPName(playerid)
{
	new PName[MAX_PLAYER_NAME];
	GetPlayerName(playerid, PName, sizeof(PName));
	return PName;
}

public SaveWeapon(playerid)
{
	new Slot[MAX_STRING], SlotAmmo[MAX_STRING], weapon, ammo;
	for(new i = 0; i < 13; i++)
	{
		format(Slot, sizeof(Slot), "PSlot%i", i);
		format(SlotAmmo, sizeof(SlotAmmo), "PSlotAmmo%i", i);
		GetPlayerWeaponData(playerid, i, weapon, ammo);
		SetPVarInt(playerid, Slot, weapon);
		SetPVarInt(playerid, SlotAmmo, ammo);
	}
	return 1;
}

public LoadWeapon(playerid)
{
	if(GetPVarInt(playerid, "HasFile") == 0) return 0;
	new Slot[MAX_STRING], SlotAmmo[MAX_STRING];
	for(new i = 0; i < 13; i++)
	{
		format(Slot, sizeof(Slot), "PSlot%i", i);
		format(SlotAmmo, sizeof(SlotAmmo), "PSlotAmmo%i", i);
		GivePlayerWeapon(playerid, GetPVarInt(playerid, Slot), GetPVarInt(playerid, SlotAmmo));
	}
	return 1;
}

public SaveWeaponToDini(playerid)
{
	new PFile[MAX_STRING], Slot[MAX_STRING], SlotAmmo[MAX_STRING];
	format(PFile, sizeof(PFile), "Weaps\\%s.ini", GetPName(playerid));
	if(!dini_Exists(PFile)) dini_Create(PFile);
	for(new i = 0; i < 13; i++)
	{
	    format(Slot, sizeof(Slot), "PSlot%i", i);
	    format(SlotAmmo, sizeof(SlotAmmo), "PSlotAmmo%i", i);
	    dini_IntSet(PFile, Slot, GetPVarInt(playerid, Slot));
	    dini_IntSet(PFile, SlotAmmo, GetPVarInt(playerid, SlotAmmo));
	}
	return 1;
}

public OnPlayerConnect(playerid)
{
	new PFile[MAX_STRING];
	format(PFile, sizeof(PFile), "Weaps\\%s.ini", GetPName(playerid));
	if(dini_Exists(PFile))
	{
		SetPVarInt(playerid, "HasFile", 1);
		new Slot[MAX_STRING], SlotAmmo[MAX_STRING];
		for(new i = 0; i < 13; i++)
		{
	    		format(Slot, sizeof(Slot), "PSlot%i", i);
	    		format(SlotAmmo, sizeof(SlotAmmo), "PSlotAmmo%i", i);
	    		SetPVarInt(playerid, Slot, dini_Int(PFile, Slot));
	    		SetPVarInt(playerid, SlotAmmo, dini_Int(PFile, SlotAmmo));
		}
	}
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason) { SaveWeapon(playerid); }
public OnPlayerSpawn(playerid) { LoadWeapon(playerid); }
public OnPlayerDisconnect(playerid, reason) { SaveWeaponToDini(playerid); }