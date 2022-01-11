Scriptname UDPlayerAlias extends ReferenceAlias

Actor Property PlayerRef Auto

Keyword Property ArmorHeavy Auto

Quest Property MQ101 Auto
Quest Property UDSKSEFunctionsQuest Auto

Spell Property UDPlayerCombatDetectSpell Auto
Spell Property UDPlayerInventoryFlowSpell Auto

GlobalVariable Property UDArmorWeight Auto
GlobalVariable Property UDDodgeStyle Auto
GlobalVariable Property UDSKSEDetect Auto

UDActivationScript Property UDActivationQuest Auto

UDSKSEFunctionsScript funcScript

actorbase playerBase
int playerSex


;------------------------------------------------------------- Events -------------------------------------------------------------

event OnInit()
	playerBase = playerRef.GetActorBase()
	RegisterForMenu("RaceSex Menu")
	SKSECheck()
	playerRef.addSpell(UDPlayerCombatDetectSpell, false)
	if(UDDodgeStyle.getValueInt() == 0)
		playerRef.addSpell(UDPlayerInventoryFlowSpell, false)
	endIf
	utility.wait(2)
	if(safeStartCheck())
		UDArmorWeight.setValueInt(0)
		registerForAnimationEvent(playerRef, "FootLeft")
		goToState("ArmorRemovedDone")
	else
		ArmorRemoved()
	endIf
endEvent

Event OnMenuOpen(String MenuName)
	playerSex = playerBase.GetSex()
EndEvent

Event OnMenuClose(String MenuName)
	if playerSex != playerBase.GetSex()
		UDActivationQuest.OnLoad()
	endif
EndEvent

bool function safeStartCheck()
	if(Game.GetModByName("AlternatePerspective.esp") != 255)
		return AlternatePerspectiveCheck()
	else
		return VanillaCheck()
	endif
endFunction

bool function VanillaCheck()
	if(MQ101.isRunning() && (MQ101.isStageDone(255) == false))
		return true
	Else
		return false
	endif
endfunction

bool function AlternatePerspectiveCheck()
	if(MQ101.GetStage() > 5) && (MQ101.isStageDone(255) == false)
		return true
	Else
		return false
	endif
endfunction

event OnAnimationEvent(ObjectReference akSource, string asEventName)
	if(asEventName == "FootLeft")
		if(safeStartCheck())
			UnregisterForAnimationEvent(playerRef, "FootLeft")
			funcScript = (UDSKSEFunctionsQuest as UDSKSEFunctionsScript)
			funcScript.OnAnimationEvent_Handle()
		endIf
	endIf
endEvent

event OnPlayerLoadGame()
	SKSECheck()
	UDActivationQuest.onLoad()
	funcScript.UDMCMMenu.onLoad()
	playerRef.addSpell(UDPlayerCombatDetectSpell, false)
	if(UDDodgeStyle.getValueInt() == 0)
		playerRef.addSpell(UDPlayerInventoryFlowSpell, false)
	endIf
	ArmorRemoved()
endEvent

event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
	if(akBaseObject.hasKeyword(ArmorHeavy))
		int ArmorWeight = UDArmorWeight.getValueInt()
		ArmorWeight = ArmorWeight + 1
		If(ArmorWeight > 4)
			ArmorWeight = 4
		endIf
		UDArmorWeight.setValueInt(ArmorWeight)
		UDActivationQuest.armorCheck()
		UDActivationQuest.weightCheck()
	endIf
endEvent

event OnObjectUnequipped(Form akBaseObject, ObjectReference akReference)
	if(akBaseObject.hasKeyWord(ArmorHeavy))
		int ArmorWeight = UDArmorWeight.getValueInt()
		ArmorWeight = ArmorWeight - 1
		If(ArmorWeight < 0)
			ArmorWeight = 0
		endIf
		UDArmorWeight.setValueInt(ArmorWeight)
		UDActivationQuest.armorCheck()
		UDActivationQuest.weightCheck()
	endIf
endEvent


;------------------------------------------------------------- States -------------------------------------------------------------

state ArmorRemovedDone
	function ArmorRemoved()

	endFunction
endState


;------------------------------------------------------------- In Functions -------------------------------------------------------------

function SKSECheck()
	int Version = UDSKSEDetect.getValueInt()
	int SKSEVersion = SKSE.getVersionRelease()
	if(Version == 2)
		if(SKSEVersion > 0)
			debug.notification("SKSE detected. TUDM is adapting to new changes...")
			UDSKSEDetect.setValueInt(1)
			utility.wait(2)
			debug.notification("Adaptation is complete. Installing MCM Menu....")
			SKSEStartUp()
		else
			debug.notification("No SKSE detected. TUDM will still continue to function.")
			UDSKSEDetect.setValueInt(0)
			SKSEShutDown()
		endIf
	elseIf(Version == 1)
		if(SKSEVersion > 0)

		else
			debug.notification("Missing SKSE. TUDM is adapting to new changes...")
			UDSKSEDetect.setValueInt(0)
			utility.wait(2)
			debug.notification("Adaptation is complete.")
			SKSEShutDown()
		endIf
	elseIf(Version == 0)
		if(SKSEVersion > 0)
			debug.notification("SKSE detected. TUDM is adapting to new changes...")
			UDSKSEDetect.setValueInt(1)
			utility.wait(2)
			debug.notification("Adaptation is complete. Installing MCM Menu....")
			SKSEStartUp()
		endIf
	endIf
endFunction

function ArmorRemoved()
	playerRef.unequipAll()
	UDArmorWeight.setValueInt(0)
	goToState("ArmorRemovedDone")
	ConsoleUtil.PrintMessage("TUDM: Re-equip all your armor")
endFunction

function SKSEStartUp()
	if(UDSKSEFunctionsQuest.isRunning() == false)
		UDSKSEFunctionsQuest.start()
	endIf
endFunction

function SKSEShutDown()
	if(UDSKSEFunctionsQuest.isRunning() == true)
		UDSKSEFunctionsQuest.stop()
	endIf
endFunction

event OnRaceSwitchComplete()
	UDActivationQuest.OnLoad()
endEvent