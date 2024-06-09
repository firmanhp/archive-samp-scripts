
#include <a_samp>
#include <sscanf2>
#define dcmd(%1,%2,%3) if ((strcmp((%3)[1], #%1, true, (%2)) == 0) && ((((%3)[(%2) + 1] == 0) && (dcmd_%1(playerid, "")))||(((%3)[(%2) + 1] == 32) && (dcmd_%1(playerid, (%3)[(%2) + 2]))))) return 1 // The dcmd define

public OnPlayerCommandText(playerid, cmdtext[])
{
	dcmd(givescore, 9, cmdtext);
	dcmd(giveallscore, 12, cmdtext);
	return 0;
}

dcmd_givescore(playerid, params[])
{
	new targetid, score;
	if(!sscanf(params, "ui", targetid, score)) return SendClientMessage(playerid, 0xFFFFFF, "USAGE: /givescore [id] [score]");
	else if(targetid == INVALID_PLAYER_ID) return SendClientMessage(playerid, 0xFF0000FF, "ERROR: Player Not Connected");
	else
	{
		new PName[MAX_PLAYER_NAME], TName[MAX_PLAYER_NAME], str1[128 + MAX_PLAYER_NAME], str2[128 + MAX_PLAYER_NAME];
		GetPlayerName(playerid, PName, sizeof(PName));
		GetPlayerName(targetid, TName, sizeof(TName));
		format(str1, sizeof(str1), "You have given %i score to %s.", score, TName);
		format(str2, sizeof(str2), "Administrator %s has given you %i score.", PName, score);
		SendClientMessage(playerid, 0x0000FFFF, str1);
		SendClientMessage(targetid, 0x0000FFFF, str2);
		SetPlayerScore(targetid, GetPlayerScore(targetid) + score);
		return 1;
	}
}

dcmd_giveallscore(playerid, params[])
{
	new score;
	if(!sscanf(params, "i", score)) return SendClientMessage(playerid, 0xFFFFFF, "USAGE: /giveallscore [score]");
	else
	{
		new PName[MAX_PLAYER_NAME], str1[128 + MAX_PLAYER_NAME]
		format(str1, sizeof(str1), "Administrator %s has given all players %i score.", PName, score);
		SendClientMessageToAll(0x0000FFFF, str1);
		for(new i = 0; i < MAX_PLAYERS; i++)
		{
			SetPlayerScore(i, GetPlayerScore(i) + score);
		}
		return 1;
	}
}