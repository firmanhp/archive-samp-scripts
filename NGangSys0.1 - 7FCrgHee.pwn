// Noobist Gang System v0.1
// By Noobist | Credits: YLess, Double-o-Seven, DracoBlue, Zeex, sheen
// DO NOT REMOVE THE CREDITS!
// DON'T FORGET TO CREATE FOLDER NAMED "NGangSys" INSIDE THE SCRIPTFILES FOLDER AND CREATE FOLDER NAMED "Gangs" AND "Players" INSIDE THE "NGangSys" FOLDER !

// Includes

#include <a_samp>
#include <sscanf2>
#include <Double-o-Files_2> // set it to convert dini.
#include <zcmd>

// Defines

#define FILTERSCRIPT
#define MAX_GANG_NAME 64 // Max gang name digit.
#define MAX_GANG_TAG 6
#define MAX_STRING 128
#define GANG_NAME_ID 1212 // Gang name input dialog ID, change if you have a dialog with this ID.
#define GANG_TAG_ID 1213 // Gang tag input dialog ID, change if you have a dialog with this ID.
#define GangChat // Gang chat using GangChatKey. Comment this to disable it.
#define GangChatKey '!' // Gang chat key.
#define SFile "NGangSys\\Server.ngs" // Server file path.
#define GDir "NGangSys\\Gangs" // Gang file path.
#define GTDir "NGangSys\\Tags" // GangTag file path.
#define PDir "NGangSys\\Players" // Player file path.
#define COLOR_GANGCHAT 0x0090FFFF // Gang chat color.
#define COLOR_ERROR 0xFF0000FF // Error color.
#define COLOR_USAGE 0x00FF00FF // USAGE color.
#define COLOR_SUCCESS 0xFFFF00FF // Command Success color.

// Enums

enum pInfo
{
	HasGang,
	GangName[MAX_STRING],
	GangLeader,
	InviterGangName[MAX_STRING]
}

// Global variables

new PGangInfo[MAX_PLAYERS][pInfo];
new GangCount;

// Stocks

stock NameEx(playerid) // by sheen, edited by me
{
	new Str[MAX_STRING], pos;
	strmid(Str, Name(playerid), 0, MAX_PLAYER_NAME, sizeof(Str));
	for(new i = 0; i < MAX_PLAYER_NAME; i++)
	{
		if (Str[i] == ']') pos = i+1;
	}
	strmid(Str, Name(playerid), pos, MAX_PLAYER_NAME, sizeof(Str));
	return Str;
}

stock Name(playerid)
{
	new Str[MAX_PLAYER_NAME];
	GetPlayerName(playerid, Str, sizeof(Str));
	return Str;
}

stock PFile(playerid)
{
	new Str[MAX_STRING];
	format(Str, sizeof(Str), "%s\\%s.ngs", PDir, NameEx(playerid));
	return Str;
}
	
stock GFile(playerid)
{
	new Str[MAX_STRING];
	format(Str, sizeof(Str), "%s\\%s.ngs", GDir, dini_Get(PFile(playerid), "GangName"));
	return Str;
}

stock GTFile(playerid)
{
	new Str[MAX_STRING];
	format(Str, sizeof(Str), "%s\\%s.ngs", GTDir, dini_Get(GFile(playerid), "Tag"));
	return Str;
}

stock GT(playerid)
{
	new Str[MAX_STRING];
	format(Str, sizeof(Str), "%s", dini_Get(GFile(playerid), "Tag"));
	return Str;
}

stock GFileEx(const filename[])
{
	new Str[MAX_STRING];
	format(Str, sizeof(Str), "%s\\%s.ngs", GDir, filename);
	return Str;
}

stock GTFileEx(const filename[])
{
	new Str[MAX_STRING];
	format(Str, sizeof(Str), "%s\\%s.ngs", GTDir, filename);
	return Str;
}

stock NGS_IsPlayerAdmin(playerid)
{
	if(IsPlayerAdmin(playerid)) return 1;
	else return 0;
}

// Forwards

forward CallConnect();
forward CallDisconnect();
forward AddGangTag(playerid);
forward AddGangTagEx(playerid, const tag[]);
forward SendClientMessageToGang(playerid, const color, const text[]);

// Functions

public CallConnect()
{
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected(i)) CallLocalFunction("OnPlayerConnect", "i", i);
	}
	return true;
}

public CallDisconnect()
{
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected(i)) CallLocalFunction("OnPlayerDisconnect", "i", i);
	}
	return true;
}

public AddGangTag(playerid)
{
	new Str[MAX_PLAYER_NAME];
	format(Str, sizeof(Str), "[%s]%s", GT(playerid), NameEx(playerid));
	SetPlayerName(playerid, Str);
	return true;
}

public AddGangTagEx(playerid, const tag[])
{
	new Str[MAX_PLAYER_NAME];
	format(Str, sizeof(Str), "[%s]%s", tag, NameEx(playerid));
	SetPlayerName(playerid, Str);
	return true;
}

public SendClientMessageToGang(playerid, const color, const text[])
{
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected(i) && PGangInfo[i][GangName] == PGangInfo[playerid][GangName])
		{
			SendClientMessage(i, color, text);
		}
	}
}

// Here we go!

#if defined FILTERSCRIPT

public OnFilterScriptInit()
{
	if(!dini_Exists(SFile))
	{
		dini_Create(SFile)
		dini_IntSet(SFile, "GangCount", 0);
		GangCount = 0;
	}
	else GangCount = dini_Int(SFile, "GangCount");
	CallConnect();
	print("\n--------------------------------------");
	print(" NGangSys 0.1 Loaded!");
	printf(" %i gangs are in scriptfiles folder.", dini_Int(SFile, "GangCount"));
	print("--------------------------------------\n");
	return 1;
}

public OnFilterScriptExit()
{
	dini_IntSet(SFile, "GangCount", GangCount);
	CallDisconnect();
	DOF2_Exit();
	print("\n--------------------------------------");
	print(" NGangSys 0.1 Unloaded!");
	print("--------------------------------------\n");
	return 1;
}

#endif

public OnPlayerConnect(playerid)
{
	if(strfind(Name(playerid), "]", false) != -1 ||
	strfind(Name(playerid), "[", false) != -1)
	{
		SendClientMessage(playerid, COLOR_ERROR, "ERROR: Please remove your nick from '[' and ']' to enter this server!");
		return Kick(playerid);
	}
	if(dini_Exists(PFile(playerid)))
	{
		if(dini_Int(PFile(playerid), "HasGang") == 1)
		{
			if(!dini_Exists(GFile(playerid)))
			{
				PGangInfo[playerid][HasGang] = 0;
				PGangInfo[playerid][GangName] = 0;
				PGangInfo[playerid][GangLeader] = 0;
			}
			else
			{
				AddGangTag(playerid);
				PGangInfo[playerid][HasGang] = 1;
				PGangInfo[playerid][GangName] = dini_Get(PFile(playerid), "GangName")
				PGangInfo[playerid][GangLeader] = dini_Int(PFile(playerid), "GangLeader");
			}
		}
	}
	else
	{
		PGangInfo[playerid][HasGang] = 0;
		PGangInfo[playerid][GangName] = 0;
		PGangInfo[playerid][GangLeader] = 0;
	}
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	#pragma unused reason
	SetPlayerName(playerid, NameEx(playerid));
	dini_IntSet(PFile(playerid), "HasGang", PGangInfo[playerid][HasGang]);
	dini_Set(PFile(playerid), "GangName", PGangInfo[playerid][GangName]);
	dini_IntSet(PFile(playerid), "GangLeader", PGangInfo[playerid][GangLeader]);
	return 1;
}

public OnPlayerText(playerid, text[])
{
	if(text[0] == GangChatKey && PGangInfo[playerid][HasGang] == 1)
	{
		for(new i = 0; i < MAX_PLAYERS; i++)
		{
			if(PGangInfo[playerid][GangName] == PGangInfo[i][GangName])
			{
				new Str[MAX_STRING];
				format(Str, sizeof(Str), "[GANG] %s:{FFFFFF} %s", NameEx(i), text[1]);
				SendClientMessage(i, COLOR_GANGCHAT, Str);
			}
		}
		return 0;
	}
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == GANG_NAME_ID && response)
	{
		if(strlen(inputtext) > MAX_GANG_NAME)
		{
			SendClientMessage(playerid, COLOR_ERROR, "ERROR: Input length is too long!");
			return ShowPlayerDialog(playerid, GANG_NAME_ID, DIALOG_STYLE_INPUT, "Noobist Gang System", "Please input your new gang name.", "OK", "Cancel");
		}
		if(strlen(inputtext) < 5)
		{
			SendClientMessage(playerid, COLOR_ERROR, "ERROR: Input length is too short!");
			return ShowPlayerDialog(playerid, GANG_NAME_ID, DIALOG_STYLE_INPUT, "Noobist Gang System", "Please input your new gang name.", "OK", "Cancel");
		}
		if(dini_Exists(GFileEx(inputtext)))
		{
			SendClientMessage(playerid, COLOR_ERROR, "ERROR: Gang name is already used by another gang!");
			return ShowPlayerDialog(playerid, GANG_NAME_ID, DIALOG_STYLE_INPUT, "Noobist Gang System", "Please input your new gang name.", "OK", "Cancel");
		}
		else
		{
			SetPVarString(playerid, "TempGName", inputtext);
			return ShowPlayerDialog(playerid, GANG_TAG_ID, DIALOG_STYLE_INPUT, "Noobist Gang System", "Please input your new gang tag without numbers and symbols.", "OK", "Cancel");
		}
	}
	if(dialogid == GANG_TAG_ID)
	{
		if(!response) return ShowPlayerDialog(playerid, GANG_NAME_ID, DIALOG_STYLE_INPUT, "Noobist Gang System", "Please input your new gang tag without numbers and symbols.", "OK", "Cancel");
		if(response)
		{
			if(strlen(inputtext) > MAX_GANG_TAG)
			{
				SendClientMessage(playerid, COLOR_ERROR, "ERROR: Input length is too long!");
				return ShowPlayerDialog(playerid, GANG_TAG_ID, DIALOG_STYLE_INPUT, "Noobist Gang System", "Please input your new gang tag without numbers and symbols.", "OK", "Back");
			}
			if(strlen(inputtext) < 1)
			{
				SendClientMessage(playerid, COLOR_ERROR, "ERROR: Input length is too short!");
				return ShowPlayerDialog(playerid, GANG_TAG_ID, DIALOG_STYLE_INPUT, "Noobist Gang System", "Please input your new gang tag without numbers and symbols.", "OK", "Back");
			}
			if(dini_Exists(GTFileEx(inputtext)))
			{
				SendClientMessage(playerid, COLOR_ERROR, "ERROR: Tag is already used by another gang!");
				return ShowPlayerDialog(playerid, GANG_TAG_ID, DIALOG_STYLE_INPUT, "Noobist Gang System", "Please input your new gang tag without numbers and symbols.", "OK", "Back");
			}
			if(strfind(inputtext, "=", false) != -1 ||
			strfind(inputtext, "[", false) != -1 ||
			strfind(inputtext, "$", false) != -1 ||
			strfind(inputtext, "]", false) != -1 ||
			strfind(inputtext, "_", false) != -1 ||
			strfind(inputtext, "@", false) != -1 ||
			strfind(inputtext, "(", false) != -1 ||
			strfind(inputtext, ")", false) != -1 ||
			strfind(inputtext, "'", false) != -1 ||
			strfind(inputtext, ".", false) != -1 ||
			strfind(inputtext, "1", false) != -1 ||
			strfind(inputtext, "2", false) != -1 ||
			strfind(inputtext, "3", false) != -1 ||
			strfind(inputtext, "4", false) != -1 ||
			strfind(inputtext, "5", false) != -1 ||
			strfind(inputtext, "6", false) != -1 ||
			strfind(inputtext, "7", false) != -1 ||
			strfind(inputtext, "8", false) != -1 ||
			strfind(inputtext, "9", false) != -1 ||
			strfind(inputtext, "0", false) != -1)
			{
				SendClientMessage(playerid, 0xFF0000FF, "Gang tag contains number/symbols!");
				return ShowPlayerDialog(playerid, GANG_TAG_ID, DIALOG_STYLE_INPUT, "Noobist Gang System", "Please input your new gang tag without numbers and symbols.", "OK", "Back");
			}
			else
			{
				new TempPName[MAX_PLAYER_NAME], TempPName2[MAX_PLAYER_NAME];
				GetPlayerName(playerid, TempPName, sizeof(TempPName));
				AddGangTagEx(playerid, inputtext);
				GetPlayerName(playerid, TempPName2, sizeof(TempPName2));
				if(TempPName2[playerid] == TempPName[playerid])
				{
					SendClientMessage(playerid, 0xFF0000FF, "Gang tag contains number/symbols!");
					return ShowPlayerDialog(playerid, GANG_TAG_ID, DIALOG_STYLE_INPUT, "Noobist Gang System", "Please input your new gang tag without numbers and symbols.", "OK", "Back");
				}
				else
				{
					new GName[MAX_STRING];
					GetPVarString(playerid, "TempGName", GName, sizeof(GName));
					dini_Create(GFileEx(GName));
					dini_Create(GTFileEx(inputtext));
					dini_Set(GFileEx(GName), "Tag", inputtext);
					PGangInfo[playerid][HasGang] = 1;
					PGangInfo[playerid][GangName] = GName;
					PGangInfo[playerid][GangLeader] = 1;
					SendClientMessage(playerid, COLOR_SUCCESS, "You have successfully created your gang, you can try inviting people by using /invite or /ganghelp for more information.");
					GangCount = GangCount+1
					return 1;
				}
			}
		}
	}
	return 0;
}

CMD:creategang(playerid)
{
	if(PGangInfo[playerid][HasGang] == 1) return SendClientMessage(playerid, COLOR_ERROR, "ERROR: You already have a gang!");
	else return ShowPlayerDialog(playerid, GANG_NAME_ID, DIALOG_STYLE_INPUT, "Noobist Gang System", "Please input your gang name.", "OK", "Cancel");
}

CMD:invite(playerid, params[])
{
	if(PGangInfo[playerid][HasGang] == 0) return SendClientMessage(playerid, COLOR_ERROR, "ERROR: You don't have a gang! Type /creategang to create a gang.");
	if(PGangInfo[playerid][GangLeader] == 0) return SendClientMessage(playerid, COLOR_ERROR, "ERROR: You are not the gang leader!");
	new targetid;
	if(sscanf(params, "u", targetid)) return SendClientMessage(playerid, COLOR_USAGE, "USAGE: /invite <id>");
	if(PGangInfo[targetid][HasGang] == 1) return SendClientMessage(playerid, COLOR_ERROR, "ERROR: Player is already have a gang!");
	if(targetid == playerid) return SendClientMessage(playerid, COLOR_ERROR, "ERROR: You cannot invite yourself!");
	if(targetid == INVALID_PLAYER_ID) return SendClientMessage(playerid, COLOR_ERROR, "ERROR: Player not connected!");
	if(PGangInfo[targetid][InviterGangName] != 0 && PGangInfo[targetid][InviterGangName] != PGangInfo[playerid][GangName]) return SendClientMessage(playerid, COLOR_ERROR, "ERROR: Player is already been invited by another gang, please stand by for input.");
	if(PGangInfo[targetid][InviterGangName] == PGangInfo[playerid][GangName]) return SendClientMessage(playerid, COLOR_ERROR, "ERROR: You have invited this player, please stand by for input.");
	else
	{
		new PStr[MAX_STRING], TStr[MAX_STRING];
		PGangInfo[targetid][InviterGangName] = PGangInfo[playerid][GangName];
		format(PStr, sizeof(PStr), "You have invited %s to your gang, please stand by for input.", Name(targetid));
		format(TStr, sizeof(TStr), "You have been invited to %s. Use /accept to accept the invitation or /decline to decline the invitation.", PGangInfo[playerid][GangName]);
		SendClientMessage(playerid, COLOR_SUCCESS, PStr);
		SendClientMessage(targetid, COLOR_SUCCESS, TStr);
		return 1;
	}
}

CMD:accept(playerid)
{
	if(PGangInfo[playerid][InviterGangName] == 0) return SendClientMessage(playerid, COLOR_ERROR, "ERROR: You are not invited by any gang!");
	else
	{
		new PStr[MAX_STRING];
		PGangInfo[playerid][GangName] = PGangInfo[playerid][InviterGangName];
		PGangInfo[playerid][InviterGangName] = 0;
		format(PStr, sizeof(PStr), "You have accepted the invitation, welcome to %s!", PGangInfo[playerid][GangName]);
		SendClientMessage(playerid, COLOR_SUCCESS, PStr);
		AddGangTag(playerid)
		return 1;
	}
}

CMD:decline(playerid)
{
	if(PGangInfo[playerid][InviterGangName] == 0) return SendClientMessage(playerid, COLOR_ERROR, "ERROR: You are not invited by any gang!");
	else
	{
		PGangInfo[playerid][InviterGangName] = 0;
		SendClientMessage(playerid, COLOR_SUCCESS, "You have declined the invitation.");
		return 1;
	}
}

CMD:gangleave(playerid)
{
	if(PGangInfo[playerid][HasGang] == 0) return SendClientMessage(playerid, COLOR_ERROR, "ERROR: You don't have a gang! Use /creategang to create a gang.");
	if(PGangInfo[playerid][GangLeader] == 1) return SendClientMessage(playerid, COLOR_ERROR, "ERROR; You are the gang leader! If you want to disband your gang, use /gangdisband");
	else
	{
		new GStr[MAX_STRING];	
		format(GStr, sizeof(GStr), "%s has left the gang.");
		SendClientMessageToGang(playerid, COLOR_SUCCESS, GStr);	
		PGangInfo[playerid][HasGang] = 0;
		PGangInfo[playerid][GangName] = 0;
		PGangInfo[playerid][GangLeader] = 0;
		SendClientMessage(playerid, COLOR_SUCCESS, "You have left the gang.");
		SetPlayerName(playerid, NameEx(playerid));
		return 1;
	}
}

CMD:gangkick(playerid, params[])
{
	if(PGangInfo[playerid][HasGang] == 0) return SendClientMessage(playerid, COLOR_ERROR, "ERROR: You don't have a gang! Type /creategang to create a gang.");
	if(PGangInfo[playerid][GangLeader] == 0) return SendClientMessage(playerid, COLOR_ERROR, "ERROR: You are not the gang leader!");
	new targetid;
	if(sscanf(params, "u", targetid)) return SendClientMessage(playerid, COLOR_USAGE, "USAGE: /gangkick <id>");
	if(PGangInfo[targetid][GangName] != PGangInfo[playerid][GangName]) return SendClientMessage(playerid, COLOR_ERROR, "ERROR: Player is not in your gang!");
	if(targetid == playerid) return SendClientMessage(playerid, COLOR_ERROR, "ERROR: You cannot kick yourself!");
	if(targetid == INVALID_PLAYER_ID) return SendClientMessage(playerid, COLOR_ERROR, "ERROR: Player not connected!");
	else
	{
		new Str[MAX_STRING], TStr[MAX_STRING];
		PGangInfo[targetid][HasGang] = 0;
		PGangInfo[targetid][GangName] = 0;
		PGangInfo[targetid][GangLeader] = 0;
		format(Str, sizeof(Str), "%s has kicked %s from gang!")
		format(TStr, sizeof(TStr), "%s has kicked you from gang!");
		SendClientMessageToGang(playerid, COLOR_SUCCESS, Str);
		SendClientMessage(targetid, COLOR_ERROR, TStr);
		SetPlayerName(targetid, NameEx(targetid));
		return 1;
	}
}

CMD:gangdisband(playerid)
{
	if(PGangInfo[playerid][HasGang] == 0) return SendClientMessage(playerid, COLOR_ERROR, "ERROR: You don't have a gang! Type /creategang to create a gang.");
	if(PGangInfo[playerid][GangLeader] == 0) return SendClientMessage(playerid, COLOR_ERROR, "ERROR: You are not the gang leader!");
	else
	{
		new Str[MAX_STRING];
		dini_Remove(GTFile(playerid));
		dini_Remove(GFile(playerid));
		format(Str, sizeof(Str), "%s has been disbanded by %s!", PGangInfo[playerid][GangName], Name(playerid));
		SendClientMessageToGang(playerid, COLOR_ERROR, Str);
		GangCount = GangCount-1; 
		for(new i = 0; i < MAX_PLAYERS; i++)
		{
			if(IsPlayerConnected(i) && PGangInfo[playerid][GangName] == PGangInfo[i][GangName])
			{
				PGangInfo[i][HasGang] = 0;
				PGangInfo[i][GangName] = 0;
				PGangInfo[i][GangLeader] = 0;
				SetPlayerName(i, NameEx(i));
			}
		}
		return 1;
	}
}

CMD:forcegangdisband(playerid, params[])
{
	if(!NGS_IsPlayerAdmin(playerid)) return 0;
	new targetid;
	if(sscanf(params, "u", targetid)) return SendClientMessage(playerid, COLOR_USAGE, "USAGE: /forcegangdisband <player-id-that-has-a gang-that-you-want-to-disband>") // Too long..
	if(PGangInfo[targetid][HasGang] == 0) return SendClientMessage(playerid, COLOR_ERROR, "ERROR: Player has no gang.");
	if(targetid == INVALID_PLAYER_ID) return SendClientMessage(playerid, COLOR_ERROR, "ERROR: Player not connected.");
	else
	{
		new Str[MAX_STRING];
		dini_Remove(GTFile(targetid));
		dini_Remove(GFile(targetid));
		format(Str, sizeof(Str), "%s has been force disbanded by Administrator %s!", PGangInfo[playerid][GangName], Name(playerid));
		SendClientMessageToGang(targetid, COLOR_ERROR, Str);
		GangCount = GangCount-1; 
		for(new i = 0; i < MAX_PLAYERS; i++)
		{
			if(IsPlayerConnected(i) && PGangInfo[targetid][GangName] == PGangInfo[i][GangName])
			{
				PGangInfo[i][HasGang] = 0;
				PGangInfo[i][GangName] = 0;
				PGangInfo[i][GangLeader] = 0;
				SetPlayerName(i, NameEx(i));
			}
		}
		return 1;
	}
}

CMD:forcegangleave(playerid, params[])
{
	if(!NGS_IsPlayerAdmin(playerid)) return 0;
	new targetid;
	if(sscanf(params, "u", targetid)) return SendClientMessage(playerid, COLOR_USAGE, "USAGE: /forcegangleave <id>") // Too long..
	if(PGangInfo[targetid][HasGang] == 0) return SendClientMessage(playerid, COLOR_ERROR, "ERROR: Player has no gang.");
	if(targetid == INVALID_PLAYER_ID) return SendClientMessage(playerid, COLOR_ERROR, "ERROR: Player not connected.");
	else
	{
		new GStr[MAX_STRING], TStr[MAX_STRING];
		format(GStr, sizeof(GStr), "%s has been forced to leave the gang by Administrator %s.", Name(targetid), Name(playerid));
		SendClientMessageToGang(targetid, COLOR_SUCCESS, GStr);	
		format(TStr, sizeof(TStr), "You have been forced to leave the gang by Administrator %s.", Name(playerid));
		SendClientMessage(targetid, COLOR_ERROR, TStr);
		PGangInfo[targetid][HasGang] = 0;
		PGangInfo[targetid][GangName] = 0;
		PGangInfo[targetid][GangLeader] = 0;
		SetPlayerName(targetid, NameEx(targetid));
		return 1;
	}
}

CMD:ganghelp(playerid)
{
	SendClientMessage(playerid, COLOR_USAGE, "Noobist Gang System v0.1 - Help");
	SendClientMessage(playerid, COLOR_USAGE, "By Noobist | Credits: YLess, Double-o-Seven, DracoBlue, Zeex, sheen");
	SendClientMessage(playerid, COLOR_USAGE, "/creategang --> Create a gang.");
	SendClientMessage(playerid, COLOR_USAGE, "/invite <id> --> Invite a player to your gang.");
	SendClientMessage(playerid, COLOR_USAGE, "/accept --> Accept gang invitation.");
	SendClientMessage(playerid, COLOR_USAGE, "/decline --> Decline gang invitation.");
	SendClientMessage(playerid, COLOR_USAGE, "/gangleave --> Leave a gang.");
	SendClientMessage(playerid, COLOR_USAGE, "/gangkick <id> --> Kick player from gang.");
	if(NGS_IsPlayerAdmin(playerid)) SendClientMessage(playerid, COLOR_USAGE, "Administrator Commands --> /admganghelp");
	return 1;
}

CMD:admganghelp(playerid)
{
	if(!NGS_IsPlayerAdmin(playerid)) return 0;
	else
	{
		SendClientMessage(playerid, COLOR_USAGE, "Noobist Gang System v0.1 - Administrator commands");
		SendClientMessage(playerid, COLOR_USAGE, "By Noobist | Credits: YLess, Double-o-Seven, DracoBlue, Zeex, sheen");
		SendClientMessage(playerid, COLOR_USAGE, "/forcegangdisband <id-that-has-a-gang-that-you-want-to-disband> --> Force gang to disband.");
		SendClientMessage(playerid, COLOR_USAGE, "/forcegangleave <id> --> Force player to leave a gang");
		return 1;
	}
}

// The end.