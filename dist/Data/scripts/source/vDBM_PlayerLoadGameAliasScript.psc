Scriptname vDBM_PlayerLoadGameAliasScript extends ReferenceAlias
{Attach to Player alias. Enables the quest to receive the OnGameReload event.}

;=== Events ===--

Event OnPlayerLoadGame()
{Send OnGameReload event to the owning quest.}
	(GetOwningQuest() as vDBM__MetaQuestScript).OnGameReload()
EndEvent
