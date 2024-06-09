// Noobist Airstrike System.
// Credits: Kye (SA-MP, MapAndreas), ZeeX (ZCMD), Y_Less (foreach), sheen (Concept)
// You need MapAndreas plugin from Kye to run this filterscript
// MapAndreas: http://forum.sa-mp.com/showthread.php?t=120013
// You can edit and share this filterscript, but don't remove any credits.

#define FILTERSCRIPT

#include <a_samp>
#include <zcmd>
#include <foreach>
#include <mapandreas>

forward CallAirstrike(playerid);
forward AirstrikeCheck(playerid, AS1, AS2, AS3, AS4, AS5, Float:AZ1, Float:AZ2, Float:AZ3, Float:AZ4, Float:AZ5);
forward PlaneCheck(playerid);

new A1[MAX_PLAYERS];
new A2[MAX_PLAYERS];
new A3[MAX_PLAYERS];
new A4[MAX_PLAYERS];
new A5[MAX_PLAYERS];
new ATimer[MAX_PLAYERS];
new ACheck[MAX_PLAYERS];
new APlane[MAX_PLAYERS];
new PCheck[MAX_PLAYERS];

public OnFilterScriptInit()
{
    MapAndreas_Init(MAP_ANDREAS_MODE_FULL);
    foreach(Player, p) OnPlayerConnect(p);
	print("\n--------------------------------------");
	print(" Noobist Airstrike System Loaded");
	print("--------------------------------------\n");
	return 1;
}

public OnFilterScriptExit()
{
	foreach(Player, p)
	{
	    DeletePVar(p, "AX");
	    DeletePVar(p, "AY");
        DeletePVar(p, "HasA");
        DeletePVar(p, "MapClicked");
        DeletePVar(p, "ADestroyed");
        if(IsValidObject(A1[p])) DestroyObject(A1[p]);
        if(IsValidObject(A2[p])) DestroyObject(A2[p]);
        if(IsValidObject(A3[p])) DestroyObject(A3[p]);
        if(IsValidObject(A4[p])) DestroyObject(A4[p]);
        if(IsValidObject(A5[p])) DestroyObject(A5[p]);
        if(IsValidObject(APlane[p])) DestroyObject(APlane[p]);
        KillTimer(ATimer[p]);
        KillTimer(ACheck[p]);
        KillTimer(PCheck[p]);
	}
    print("\n--------------------------------------");
	print(" Noobist Airstrike System Unloaded");
	print("--------------------------------------\n");
	return 1;
}

public OnPlayerConnect(playerid)
{
	SendClientMessage(playerid, 0x00FF00, "This server Airstrike System is powered by Noobist Airstrike System, /strikehelp for more information.");
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    if(IsValidObject(A1[playerid])) DestroyObject(A1[playerid]);
    if(IsValidObject(A2[playerid])) DestroyObject(A2[playerid]);
    if(IsValidObject(A3[playerid])) DestroyObject(A3[playerid]);
    if(IsValidObject(A4[playerid])) DestroyObject(A4[playerid]);
    if(IsValidObject(A5[playerid])) DestroyObject(A5[playerid]);
    if(IsValidObject(APlane[playerid])) DestroyObject(APlane[playerid]);
    KillTimer(ATimer[playerid]);
    KillTimer(ACheck[playerid]);
    KillTimer(PCheck[playerid]);
    return 1;
}

public OnPlayerClickMap(playerid, Float:fX, Float:fY, Float:fZ)
{
	SetPVarFloat(playerid, "AX", fX);
	SetPVarFloat(playerid, "AY", fY);
	SetPVarInt(playerid, "MapClicked", 1);
	return 1;
}

CMD:callstrike(playerid)
{
	if(GetPVarInt(playerid, "HasA") == 0) return SendClientMessage(playerid, 0xFF0000, "You don't have permission to call an airstrike.");
	if(GetPVarInt(playerid, "HasA") >= 2) return SendClientMessage(playerid, 0xFF0000, "You can't call airstrike twice.");
	if(GetPVarInt(playerid, "MapClicked") == 0) return SendClientMessage(playerid, 0xFF0000, "Please specify the target. (Menu -> Map -> Target)");
	SendClientMessage(playerid, 0x00FF00, "Calling the airstrike, you can abort it with /abortstrike.");
	SetPVarInt(playerid, "HasA", 2);
	SetPlayerSpecialAction(playerid, SPECIAL_ACTION_USECELLPHONE);
	SetPlayerAttachedObject(playerid, 4, 330, 6);
	ATimer[playerid] = SetTimerEx("CallAirstrike", 10000, false, "i", playerid);
	return 1;
}

CMD:abortstrike(playerid)
{
	if(GetPVarInt(playerid, "HasA") == 0) return SendClientMessage(playerid, 0xFF0000, "You don't have permission to call an airstrike.");
	if(GetPVarInt(playerid, "HasA") == 3) return SendClientMessage(playerid, 0xFF0000, "Airstrike already called, cannot abort.");
	SendClientMessage(playerid, 0x00FF00, "Airstrike aborted.");
	SetPlayerSpecialAction(playerid, SPECIAL_ACTION_STOPUSECELLPHONE);
	RemovePlayerAttachedObject(playerid, 4);
	KillTimer(ATimer[playerid]);
	SetPVarInt(playerid, "HasA", 1);
	return 1;
}

public CallAirstrike(playerid)
{
	if(GetPlayerSpecialAction(playerid) != SPECIAL_ACTION_USECELLPHONE)
	{
		SendClientMessage(playerid, 0xFF0000, "Airstrike call failed.");
		RemovePlayerAttachedObject(playerid, 4);
		SetPVarInt(playerid, "HasA", 1);
		return 1;
	}
	new Float:AZP;
	SetPlayerSpecialAction(playerid, SPECIAL_ACTION_STOPUSECELLPHONE);
    SendClientMessage(playerid, 0x00FF00, "Airstrike has been successfully called.");
    RemovePlayerAttachedObject(playerid, 4);
    SetPVarInt(playerid, "HasA", 3);
    MapAndreas_FindZ_For2DCoord(floatsub(GetPVarFloat(playerid, "AX"), 100.0), GetPVarFloat(playerid, "AY"), AZP);
	APlane[playerid] = CreateObject(1683, floatsub(GetPVarFloat(playerid, "AX"), 100.0), GetPVarFloat(playerid, "AY"), floatadd(AZP, 110.0), 0.0, 0.0, 0.0);
	MoveObject(APlane[playerid], floatadd(GetPVarFloat(playerid, "AX"), 200.0), GetPVarFloat(playerid, "AY"), floatadd(AZP, 110.0), 20.0);
	PCheck[playerid] = SetTimerEx("PlaneCheck", 100, true, "i", playerid);
    return 1;
}

public PlaneCheck(playerid)
{
	new Float:APX, Float:APY, Float:APZ;
	GetObjectPos(APlane[playerid], APX, APY, APZ);
	if(floatsub(floatadd(GetPVarFloat(playerid, "AX"), 200.0), APX) < 2)
	{
	    DestroyObject(APlane[playerid]);
	    KillTimer(PCheck[playerid]);
	    return 1;
	}
	if(floatsub(GetPVarFloat(playerid, "AX"), APX) < 1 && GetPVarInt(playerid, "HasA") != 4)
	{
		new Float:AZ1, Float:AZ2, Float:AZ3, Float:AZ4, Float:AZ5;
	 	MapAndreas_FindZ_For2DCoord(GetPVarFloat(playerid, "AX"), GetPVarFloat(playerid, "AY"), AZ1);
	    MapAndreas_FindZ_For2DCoord(GetPVarFloat(playerid, "AX")+5.0, GetPVarFloat(playerid, "AY"), AZ2);
	    MapAndreas_FindZ_For2DCoord(GetPVarFloat(playerid, "AX")-5.0, GetPVarFloat(playerid, "AY"), AZ3);
	    MapAndreas_FindZ_For2DCoord(GetPVarFloat(playerid, "AX"), GetPVarFloat(playerid, "AY")+5.0, AZ4);
	    MapAndreas_FindZ_For2DCoord(GetPVarFloat(playerid, "AX"), GetPVarFloat(playerid, "AY")-5.0, AZ5);
		A1[playerid] = CreateObject(354, GetPVarFloat(playerid, "AX"), GetPVarFloat(playerid, "AY"), floatadd(AZ1, 100.0), 0.0, 0.0, 0.0);
	    A2[playerid] = CreateObject(354, floatadd(GetPVarFloat(playerid, "AX"), 5.0), GetPVarFloat(playerid, "AY"), floatadd(AZ1, 100.0), 0.0, 0.0, 0.0);
	    A3[playerid] = CreateObject(354, floatsub(GetPVarFloat(playerid, "AX"), 5.0), GetPVarFloat(playerid, "AY"), floatadd(AZ1, 100.0), 0.0, 0.0, 0.0);
	    A4[playerid] = CreateObject(354, GetPVarFloat(playerid, "AX"), floatadd(GetPVarFloat(playerid, "AY"), 5.0), floatadd(AZ1, 100.0), 0.0, 0.0, 0.0);
	    A5[playerid] = CreateObject(354, GetPVarFloat(playerid, "AX"), floatsub(GetPVarFloat(playerid, "AY"), 5.0), floatadd(AZ1, 100.0), 0.0, 0.0, 0.0);
	    MoveObject(A1[playerid], GetPVarFloat(playerid, "AX"), GetPVarFloat(playerid, "AY"), AZ1, 10.0);
	    MoveObject(A2[playerid], floatadd(GetPVarFloat(playerid, "AX"), 5.0), GetPVarFloat(playerid, "AY"), AZ2, 10.0);
	    MoveObject(A3[playerid], floatsub(GetPVarFloat(playerid, "AX"), 5.0), GetPVarFloat(playerid, "AY"), AZ3, 10.0);
	    MoveObject(A4[playerid], GetPVarFloat(playerid, "AX"), floatadd(GetPVarFloat(playerid, "AY"), 5.0), AZ4, 10.0);
	    MoveObject(A5[playerid], GetPVarFloat(playerid, "AX"), floatsub(GetPVarFloat(playerid, "AY"), 5.0), AZ5, 10.0);
	    ACheck[playerid] = SetTimerEx("AirstrikeCheck", 100, true, "iiiiiifffff", playerid, A1[playerid], A2[playerid], A3[playerid], A4[playerid], A5[playerid], AZ1, AZ2, AZ3, AZ4, AZ5);
	    SetPVarInt(playerid, "HasA", 4);
		return 1;
	}
	return 1;
}

public AirstrikeCheck(playerid, AS1, AS2, AS3, AS4, AS5, Float:AZ1, Float:AZ2, Float:AZ3, Float:AZ4, Float:AZ5)
{
	new Float:AX, Float:AY, Float:AZ;
	if(IsValidObject(AS1))
	{
	    GetObjectPos(AS1, AX, AY, AZ);
		foreach(Player, p)
		{
		    if(GetPlayerDistanceFromPoint(p, AX, AY, AZ) < 4)
		    {
		        CreateExplosion(AX+1, AY, AZ, 0, 10.0);
		        CreateExplosion(AX-1, AY, AZ, 0, 10.0);
		        CreateExplosion(AX, AY+1, AZ, 0, 10.0);
		        CreateExplosion(AX, AY-1, AZ, 0, 10.0);
		        DestroyObject(AS1);
		        SetPVarInt(playerid, "ADestroyed", GetPVarInt(playerid, "ADestroyed")+1);
			}
		}
		if(floatsub(AZ, AZ1) < 1)
		{
			CreateExplosion(AX+1, AY, AZ, 0, 10.0);
			CreateExplosion(AX-1, AY, AZ, 0, 10.0);
		    CreateExplosion(AX, AY+1, AZ, 0, 10.0);
	        CreateExplosion(AX, AY-1, AZ, 0, 10.0);
			DestroyObject(AS1);
			SetPVarInt(playerid, "ADestroyed", GetPVarInt(playerid, "ADestroyed")+1);
		}
	}
	if(IsValidObject(AS2))
	{
	    GetObjectPos(AS2, AX, AY, AZ);
		foreach(Player, p)
		{
		    if(GetPlayerDistanceFromPoint(p, AX, AY, AZ) < 4)
		    {
		        CreateExplosion(AX+1, AY, AZ, 0, 10.0);
		        CreateExplosion(AX-1, AY, AZ, 0, 10.0);
		        CreateExplosion(AX, AY+1, AZ, 0, 10.0);
		        CreateExplosion(AX, AY-1, AZ, 0, 10.0);
		        DestroyObject(AS2);
		        SetPVarInt(playerid, "ADestroyed", GetPVarInt(playerid, "ADestroyed")+1);
			}
		}
		if(floatsub(AZ, AZ2) < 1)
		{
			CreateExplosion(AX+1, AY, AZ, 0, 10.0);
			CreateExplosion(AX-1, AY, AZ, 0, 10.0);
			CreateExplosion(AX, AY+1, AZ, 0, 10.0);
			CreateExplosion(AX, AY-1, AZ, 0, 10.0);
			DestroyObject(AS2);
			SetPVarInt(playerid, "ADestroyed", GetPVarInt(playerid, "ADestroyed")+1);
		}
	}
	if(IsValidObject(AS3))
	{
	    GetObjectPos(AS3, AX, AY, AZ);
		foreach(Player, p)
		{
		    if(GetPlayerDistanceFromPoint(p, AX, AY, AZ) < 4)
		    {
		        CreateExplosion(AX+1, AY, AZ, 0, 10.0);
		        CreateExplosion(AX-1, AY, AZ, 0, 10.0);
		        CreateExplosion(AX, AY+1, AZ, 0, 10.0);
		        CreateExplosion(AX, AY-1, AZ, 0, 10.0);
		        DestroyObject(AS3);
		        SetPVarInt(playerid, "ADestroyed", GetPVarInt(playerid, "ADestroyed")+1);
			}
		}
		if(floatsub(AZ, AZ3) < 1)
		{
			CreateExplosion(AX+1, AY, AZ, 0, 10.0);
   			CreateExplosion(AX-1, AY, AZ, 0, 10.0);
      		CreateExplosion(AX, AY+1, AZ, 0, 10.0);
        	CreateExplosion(AX, AY-1, AZ, 0, 10.0);
			DestroyObject(AS3);
			SetPVarInt(playerid, "ADestroyed", GetPVarInt(playerid, "ADestroyed")+1);
		}
	}
	if(IsValidObject(AS4))
	{
	    GetObjectPos(AS4, AX, AY, AZ);
		foreach(Player, p)
		{
		    if(GetPlayerDistanceFromPoint(p, AX, AY, AZ) < 4)
		    {
		        CreateExplosion(AX+1, AY, AZ, 0, 10.0);
		        CreateExplosion(AX-1, AY, AZ, 0, 10.0);
		        CreateExplosion(AX, AY+1, AZ, 0, 10.0);
		        CreateExplosion(AX, AY-1, AZ, 0, 10.0);
		        DestroyObject(AS4);
		        SetPVarInt(playerid, "ADestroyed", GetPVarInt(playerid, "ADestroyed")+1);
			}
		}
		if(floatsub(AZ, AZ4) < 1)
		{
			CreateExplosion(AX+1, AY, AZ, 0, 10.0);
   			CreateExplosion(AX-1, AY, AZ, 0, 10.0);
   			CreateExplosion(AX, AY+1, AZ, 0, 10.0);
   			CreateExplosion(AX, AY-1, AZ, 0, 10.0);
			DestroyObject(AS4);
			SetPVarInt(playerid, "ADestroyed", GetPVarInt(playerid, "ADestroyed")+1);
		}
	}
	if(IsValidObject(AS5))
	{
	    GetObjectPos(AS5, AX, AY, AZ);
		foreach(Player, p)
		{
		    if(GetPlayerDistanceFromPoint(p, AX, AY, AZ) < 4)
		    {
		        CreateExplosion(AX+1, AY, AZ, 0, 10.0);
		        CreateExplosion(AX-1, AY, AZ, 0, 10.0);
		        CreateExplosion(AX, AY+1, AZ, 0, 10.0);
		        CreateExplosion(AX, AY-1, AZ, 0, 10.0);
		        DestroyObject(AS5);
		        SetPVarInt(playerid, "ADestroyed", GetPVarInt(playerid, "ADestroyed")+1);
			}
		}
		if(floatsub(AZ, AZ5) < 1)
		{
            CreateExplosion(AX+1, AY, AZ, 0, 10.0);
  			CreateExplosion(AX-1, AY, AZ, 0, 10.0);
  			CreateExplosion(AX, AY+1, AZ, 0, 10.0);
  			CreateExplosion(AX, AY-1, AZ, 0, 10.0);
			DestroyObject(AS5);
			SetPVarInt(playerid, "ADestroyed", GetPVarInt(playerid, "ADestroyed")+1);
		}
	}
	if(GetPVarInt(playerid, "ADestroyed") == 5)
	{
	    SetPVarInt(playerid, "HasA", 0);
		DeletePVar(playerid, "ADestroyed");
		KillTimer(ACheck[playerid]);
		return 1;
	}
	return 1;
}

CMD:givestrike(playerid)
{
	if(!IsPlayerAdmin(playerid)) return 0;
	SetPVarInt(playerid, "HasA", 1);
	SendClientMessage(playerid, 0x00FF00, "You have got permission to call an airstrike.");
	return 1;
}

CMD:buystrikepermission(playerid)
{
	if(!IsPlayerInRangeOfPoint(playerid, 20.0, 2447.1755, -1972.8712, 13.5469)) return SendClientMessage(playerid, 0xFF0000, "You must be in Emmet's place to buy that!");
	if(GetPlayerMoney(playerid) < 50000) return SendClientMessage(playerid, 0xFF0000, "You need $50000 to buy that!");
	if(GetPVarInt(playerid, "HasA") > 0) return SendClientMessage(playerid, 0xFF0000, "You can't buy it twice!");
	SetPVarInt(playerid, "HasA", 1);
	GivePlayerMoney(playerid, -50000);
	SendClientMessage(playerid, 0x00FF00, "You have bought permission to call an airstrike, use /callstrike to call an airstrike.");
	return 1;
}

CMD:strikehelp(playerid)
{
	SendClientMessage(playerid, 0xFF0000, "Noobist Airstrike System.");
	SendClientMessage(playerid, 0xFF0000, "Credits: Kye (SA-MP, MapAndreas), ZeeX (ZCMD), Y_Less (foreach), sheen (Concept)");
	SendClientMessage(playerid, 0xFF0000, "/buystrikepermission -> Buy an airstrike permission (Must be in Emmet's place)");
	SendClientMessage(playerid, 0xFF0000, "/callstrike -> Call an airstrike");
	SendClientMessage(playerid, 0xFF0000, "/abortstrike -> Abort an airstrike");
	if(IsPlayerAdmin(playerid)) SendClientMessage(playerid, 0xFF0000, "RCON Admin CMD: /givestrike -> Free airstrike permission");
	return 1;
}