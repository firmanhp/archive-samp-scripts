/* NGangSys include, by Noobist.
INCLUDE THIS TO YOUR FILTERSCRIPTS, GAMEMODE, AND YOUR INCLUDES THAT HAVE GetPlayerName IN IT AND ADD THIS LINE UNDER THE #include LINE IN YOUR FILTERSCRIPTS, GAMEMODE, AND YOUR INCLUDES THAT HAVE GetPlayerName!

#define GetPlayerName NGangSys_GetPlayerName

*/

#include <a_samp>
forward NGangSys_GetPlayerName(playerid, str[], len);

stock GetPlayerNameEx(playerid) // made by sheen
{
	new Str[MAX_STRING], PName[MAX_PLAYER_NAME], pos;
	GetPlayerName(playerid, PName, sizeof(PName));
	strmid(Str, PName, 0, sizeof(PName), sizeof(Str));
	for(new i = 0; i < MAX_PLAYER_NAME; i++)
	{
		if (Str[i] == ']') pos = i+1;
	}
	strmid(Str, PName, pos, sizeof(PName), sizeof(Str));
	return Str;
}

public NGangSys_GetPlayerName(playerid, str[], len)
{
	return format(str, len, GetPlayerNameEx(playerid));
}