// Noobist Simple Anti Passenger Abuse.
// FS inspired by Indogamers Anti-Backseat
// IsVehicleHasDriver function inspired by GetVehicleDriver from someone in SA-MP Forums.

#define FILTERSCRIPT

// Defines
#define PassengerAfterDriverLeave // Activates Anti Passenger Abuse After Driver Leave (APAADL), when the driver left the vehicle, the passenger will automatically removed from the vehicle.
//-------------------------------------
// Includes
#include <a_samp>
//-------------------------------------
// Functions
stock IsVehicleHasDriver(vehicleid)
{
	for(new playerid; playerid < MAX_PLAYERS; playerid++)
	{
	    if(IsPlayerConnected(playerid) && GetPlayerState(playerid) == PLAYER_STATE_DRIVER && GetPlayerVehicleID(playerid) == vehicleid) return 1;
	}
	return 0;
}
//------------------------------------
// Forwards
forward Fix(playerid, vehicleid);
//------------------------------------
// Self-made callbacks
public Fix(playerid, vehicleid)
{
    PutPlayerInVehicle(playerid, vehicleid, 0);
    return 1;
}
//------------------------------------
// HERE WE GO!
public OnFilterScriptInit()
{
	print("\n--------------------------------------------------");
	print(" Noobist Simple Anti Passenger Abuse (NSAPA) LOADED!");
    #if defined PassengerAfterDriverLeave
    print("Anti Passenger Abuse After Driver Leave (APAADL) ACTIVATED!");
    #endif
	print("--------------------------------------------------\n");
	return 1;
}

public OnFilterScriptExit()
{
	print("\n----------------------------------------------------");
	print(" Noobist Simple Anti Passenger Abuse (NSAPA) UNLOADED!");
	#if defined PassengerAfterDriverLeave
    print("Anti Passenger Abuse After Driver Leave (APAADL) DEACTIVATED!");
    #endif
	print("----------------------------------------------------\n");
	return 1;
}

#if defined PassengerAfterDriverLeave

public OnPlayerConnect(playerid)
{
	SetPVarInt(playerid, "vehicleid", 0);
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	if(GetPVarInt(playerid, "vehicleid") > 0)
	{
		printf("[NSAPA][APAADL]: Player %i has left the server while driving vehicle %i.", playerid, GetPVarInt(playerid, "vehicleid"));
	    for(new passengerid = 0; passengerid < MAX_PLAYERS; passengerid++)
	    {
	        if(IsPlayerConnected(passengerid) && GetPlayerVehicleID(passengerid) == GetPVarInt(playerid, "vehicleid"))
	        {
	            RemovePlayerFromVehicle(passengerid);
	            SendClientMessage(passengerid, 0xFF0000FF, "The driver is disconnected!");
	            printf("[NSAPA][APAADL]: Player %i has been removed from vehicle %i (Driver %i disconnected).", passengerid, GetPVarInt(playerid, "vehicleid"), playerid);
			}
		}
	}
	return 1;
}

#endif

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	if(newstate == PLAYER_STATE_PASSENGER)
	{
		new vehicleid = GetPlayerVehicleID(playerid);
	    if(!IsVehicleHasDriver(vehicleid))
	    {
	        new Float:vx, Float:vy, Float:vz;
			GetVehiclePos(vehicleid, vx, vy, vz);
			SetPlayerPos(playerid, vx, vy, vz+5);
			SetTimerEx("Fix", 500, false, "ii", playerid, vehicleid);
			SendClientMessage(playerid, 0xFF0000FF, "Do not enter vehicle as passenger without a driver!");
			printf("[NSAPA]: Player %i entered vehicle %i without a driver.", playerid, vehicleid);
			return 1;
		}
	}
	#if defined PassengerAfterDriverLeave
	if(newstate == PLAYER_STATE_DRIVER) return SetPVarInt(playerid, "vehicleid", GetPlayerVehicleID(playerid));
	if(newstate == PLAYER_STATE_ONFOOT && oldstate == PLAYER_STATE_DRIVER)
	{
	    for(new passengerid = 0; passengerid < MAX_PLAYERS; passengerid++)
	    {
	        if(IsPlayerConnected(passengerid) && GetPlayerVehicleID(passengerid) == GetPVarInt(playerid, "vehicleid"))
	        {
	            RemovePlayerFromVehicle(passengerid);
	            SendClientMessage(passengerid, 0xFF0000FF, "The driver is leaving the vehicle!");
	            printf("[NSAPA][APAADL]: Player %i has been removed from vehicle %i (Driver %i left the vehicle).", passengerid, GetPVarInt(playerid, "vehicleid"), playerid);
			}
		}
		SetPVarInt(playerid, "vehicleid", 0);
		return 1;
	}
	#endif
	return 1;
}
// The End.