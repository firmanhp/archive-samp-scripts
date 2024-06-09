stock GetNameEx(playerid)
{
	new str[24],name[32],pos;
	name = GetName(playerid);
	strmid(str, name, 0, strlen(name), 24);
	for(new i = 0; i < MAX_PLAYER_NAME; i++)
	{
		if (str[i] == ']') pos = i+1;
	}
	strmid(str, name, pos, strlen(name), 24);
	return str;
}

stock GetName(playerid)
{
	new name[MAX_PLAYER_NAME];
	if(IsPlayerConnected(playerid)) GetPlayerName(playerid, name, sizeof(name));
	else name = "Unknown";
	return name;
}