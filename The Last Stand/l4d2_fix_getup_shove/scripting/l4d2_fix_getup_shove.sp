#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <dhooks>
#include <left4dhooks>

#include <@Forgetest/gamedatawrapper>

#define PLUGIN_VERSION "1.0"

public Plugin myinfo = 
{
	name = "[L4D2] Fix Shove On Getting Up",
	author = "Forgetest",
	description = "Fix edge case(s) where survivor can shove for a blink of time when cleared from domination.",
	version = PLUGIN_VERSION,
	url = "https://github.com/Target5150/MoYu_Server_Stupid_Plugins",
}

public void OnPluginStart()
{
	GameDataWrapper gd = new GameDataWrapper("l4d2_fix_getup_shove");
	delete gd.CreateDetourOrFail("l4d2_fix_getup_shove::CTerrorWeapon::CanDeployFor", _, DTR_CanDeployFor_Post);
	delete gd;
}

MRESReturn DTR_CanDeployFor_Post(int weapon, DHookReturn hReturn, DHookParam hParams)
{
	int client = hParams.IsNull(1) ? -1 : hParams.Get(1);
	if (client == -1 || !IsClientInGame(client))
		return MRES_Ignored;
	
	if (hReturn.Value == true && !CheckWeaponCanDeployFor(client))
	{
		hReturn.Value = false;
		return MRES_Override;
	}
	return MRES_Ignored;
}

// L4D2 only
bool CheckWeaponCanDeployFor(int client)
{
	int activity = PlayerAnimState.FromPlayer(client).GetMainActivity();
	switch (activity)
	{
		case L4D2_ACT_IDLE_POUNCED,
			L4D2_ACT_TERROR_CHARGER_POUNDED_NORTH,
			L4D2_ACT_TERROR_CHARGER_POUNDED_UP,
			L4D2_ACT_TERROR_CHARGER_POUNDED_DOWN:
		{
			return false;
		}
	}

	return true;
}
