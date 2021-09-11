Scriptname UDActivationScript extends Quest  

GlobalVariable Property UDDodgeSpeedMethod Auto
GlobalVariable Property UDStaminaCostR Auto
GlobalVariable Property UDStaminaCostS Auto
GlobalVariable Property UDIFrameR Auto
GlobalVariable Property UDIFrameS Auto
GlobalVariable Property UDArmorWeight Auto
GlobalVariable Property UDDodgeStyle Auto
GlobalVariable Property UDMaxSpeedPenalty Auto

Form Property UDLargeEnemyCount Auto
Form Property UDAllEnemyCount Auto

Idle Property SneakStartPlayer Auto
Idle Property SneakStopPlayer Auto

Keyword Property ArmorHeavy Auto
Keyword Property ActorTypeNPC Auto

Actor Property PlayerRef Auto

Quest Property MQ101 Auto

Spell Property UDRollZeroStaminaDamage Auto

actor player

string eventID

float MaxSpeedPenalty = 0.4
float SpeedPenalty
float DodgeSpeed
float IFrameR = 0.4
float IFrameS = 0.25

int Stamina
int StaminaCostR = 20
int StaminaCostS = 10
int SneakKey
int DodgeSpeedMethod = 0
int DDodgeStyle = 0

bool rightRace = false
race werewolfBeastRace
race vampireBeastRace


;------------------------------------------------------------- Events -------------------------------------------------------------

event OnInit()
	player = PlayerRef
	Utility.Wait(1.0)
	onload()
endEvent

function OnLoad()
	rightRace = checkValidRace()
	registerForAnimationEvent(player, "RollTrigger")
	registerForAnimationEvent(player, "SidestepTrigger")
	MaxSpeedPenalty = UDMaxSpeedPenalty.getValue()
	armorCheck()
	weightCheck()
endFunction

bool function checkValidRace()
	if (!werewolfBeastRace)
		werewolfBeastRace = game.GetFormFromFile(0x0CDD84, "Skyrim.esm") as race
		vampireBeastRace = game.GetFormFromFile(0x00283A, "Dawnguard.esm") as race
	endif
	race playerRace = PlayerRef.GetRace()
	if playerRace != werewolfBeastRace && playerRace != werewolfBeastRace
		return true
	Else
		return false
	endif
endFunction

event OnAnimationEvent(ObjectReference akSource, string asEventName)
	ConsoleUtil.PrintMessage(asEventName)
	ConsoleUtil.PrintMessage(DDodgeStyle)
	Thing()
	if(asEventName == "RollTrigger")
		InvincibleFrame(0)
		StaminaDamage(0)
	elseIf(asEventName == "SidestepTrigger")
		InvincibleFrame(1)
		StaminaDamage(1)
	endIf
endEvent

event OnAnimationEventUnregistered(ObjectReference akSource, string asEventName)
	ConsoleUtil.PrintMessage(asEventName)
	if(akSource == PlayerRef && asEventName == "RollTrigger")
		registerForAnimationEvent(player, "RollTrigger")
	elseIf(akSource == PlayerRef && asEventName == "SidestepTrigger")
		registerForAnimationEvent(player, "SidestepTrigger")
	endIf
endEvent


;------------------------------------------------------------- States -------------------------------------------------------------

state nulltwo
	function Thing()
		ConsoleUtil.PrintMessage(1)
	endFunction
	function DefaultDodgeStyle()
	endFunction
	
	function DodgeSpeedCheck(int valueID)
		if(valueID == 0)
			DodgeSpeed = 1
		elseIf(valueID == 1)
			DodgeSpeed = 1.647
		endIf
		player.setAnimationVariablefloat("DodgeSpeed", DodgeSpeed)
	endFunction
endState

state onenull
	function Thing()
		ConsoleUtil.PrintMessage(2)
	endFunction
	function DefaultDodgeStyle()
		player.setAnimationVariableInt("DodgeID", 0)
		dodgeSpeedCheck(0)
	endFunction
	
	function DodgeSpeedCheck(int valueID)
		if(valueID == 0)
			DodgeSpeed = 1 - SpeedPenalty
		elseIf(valueID == 1)
			DodgeSpeed = (1 - SpeedPenalty) * 1.647
		endIf
		player.setAnimationVariablefloat("DodgeSpeed", DodgeSpeed)
	endFunction
endState

state onetwo
	function Thing()
		ConsoleUtil.PrintMessage(3)
	endFunction
	function DefaultDodgeStyle()
		player.setAnimationVariableInt("DodgeID", 0)
		dodgeSpeedCheck(0)
	endFunction
	
	function DodgeSpeedCheck(int valueID)
		if(valueID == 0)
			DodgeSpeed = 1
		elseIf(valueID == 1)
			DodgeSpeed = 1.647
		endIf
		player.setAnimationVariablefloat("DodgeSpeed", DodgeSpeed)
	endFunction
endState

state twonull
	function Thing()
		ConsoleUtil.PrintMessage(4)
	endFunction
	function DefaultDodgeStyle()
		player.setAnimationVariableInt("DodgeID", 1)
		dodgeSpeedCheck(1)
	endFunction
	
	function DodgeSpeedCheck(int valueID)
		if(valueID == 0)
			DodgeSpeed = 1 - SpeedPenalty
		elseIf(valueID == 1)
			DodgeSpeed = (1 - SpeedPenalty) * 1.647
		endIf
		player.setAnimationVariablefloat("DodgeSpeed", DodgeSpeed)
	endFunction
endState

state twotwo
	function Thing()
		ConsoleUtil.PrintMessage(5)
	endFunction
	function DefaultDodgeStyle()
		if(player.hasKeyword(ActorTypeNPC) == false)
			return
		endIf

		player.setAnimationVariableInt("DodgeID", 1)
		dodgeSpeedCheck(1)
	endFunction
	
	function DodgeSpeedCheck(int valueID)
		if(valueID == 0)
			DodgeSpeed = 1
		elseIf(valueID == 1)
			DodgeSpeed = 1.647
		endIf
		player.setAnimationVariablefloat("DodgeSpeed", DodgeSpeed)
	endFunction
endState


;------------------------------------------------------------- In functions -------------------------------------------------------------

function DefaultDodgeStyle()
endFunction

function Thing()
	ConsoleUtil.PrintMessage("zero")
endFunction

function ArmorCheck()
	if(rightRace == false)
		return
	endIf

	if(UDDodgeSpeedMethod.getValueInt() == 1)
		float ArmorWeight = UDArmorWeight.getValueInt() as float
		float ArmorWeightPercentage = ArmorWeight / 4
		SpeedPenalty = ArmorWeightPercentage * MaxSpeedPenalty
		int DodgeID = player.getAnimationVariableInt("DodgeID")
		DodgeSpeedCheck(DodgeID)
	endIf
endFunction

function WeightCheck()
	if(rightRace == false)
		return
	endIf

	if(UDDodgeSpeedMethod.getValueInt() == 0)
		float CurrentCarryWeight = playerRef.getActorValue("InventoryWeight")
		float MaxCarryWeight = playerRef.getActorValue("CarryWeight")
		float CarryWeightPercentage = CurrentCarryWeight / MaxCarryWeight
		if(CarryWeightPercentage > 1)
			SpeedPenalty = MaxSpeedPenalty
		elseIf(CarryWeightPercentage <= 0.5)
			SpeedPenalty = 0
		else
			SpeedPenalty = CarryWeightPercentage * MaxSpeedPenalty
		endIf
		int DodgeID = playerRef.getAnimationVariableInt("DodgeID")
		DodgeSpeedCheck(DodgeID)
	endIf
endFunction

function DodgeSpeedCheck(int valueID)
	if(valueID == 0)
		DodgeSpeed = 1 - SpeedPenalty
	elseIf(valueID == 1)
		DodgeSpeed = (1 - SpeedPenalty) * 1.647
	endIf
	playerRef.setAnimationVariablefloat("DodgeSpeed", DodgeSpeed)
endFunction

function InvincibleFrame(string value)
	if(value == 0)
		player.setGhost(true)
		utility.wait(IFrameR)
		player.setGhost(false)
	elseIf(value == 1)
		player.setGhost(true)
		utility.wait(IFrameS)
		player.setGhost(false)
	endIf
endFunction

function StaminaDamage(string value)
	if(value == 0)
		player.DamageActorValue("Stamina", StaminaCostR)
		Stamina = player.GetActorValue("Stamina") as int
	elseIf(value == 1)
		player.DamageActorValue("Stamina", StaminaCostS)
		Stamina = player.GetActorValue("Stamina") as int
	endIf
	if(Stamina == 0)
		player.AddSpell(UDRollZeroStaminaDamage, false)
		utility.Wait(3)
		player.RemoveSpell(UDRollZeroStaminaDamage)
	endIf
endFunction

function ReEnemyCheck(int AllEnemyCount, int LargeEnemyCount)
	if(rightRace == false)
		return
	endIf

	int DodgeID = player.getAnimationVariableInt("DodgeID")
	if(DodgeID == 0) && (LargeEnemyCount == 0) && (AllEnemyCount != 0) && (player.getCombatState() != 0)
		player.setAnimationVariableInt("DodgeID", 1)
		DodgeSpeedCheck(1)
	elseIf(DodgeID == 1) && (AllEnemyCount == LargeEnemyCount) && (player.getCombatState() != 0) && (AllEnemyCount != 0)
		player.setAnimationVariableInt("DodgeID", 0)
		DodgeSpeedCheck(0)
	elseIf(AllEnemyCount == 0) && (LargeEnemyCount == 0) && (player.getCombatState() == 0)
		defaultDodgeStyle()
	endIf
endFunction

function InvincibleFrameRCheck(float InvincibleFrame)
	IFrameR = InvincibleFrame
endFunction

function InvincibleFrameSCheck(float InvincibleFrame)
	IFrameS = InvincibleFrame
endFunction

function StaminaCostRCheck(int StaminaCost)
	StaminaCostR = StaminaCost
endFunction

function StaminaCostSCheck(int StaminaCost)
	StaminaCostS = StaminaCost
endFunction

function MaxSpeedPenaltyCheck(float newMaxSpeedPenalty)
	MaxSpeedPenalty = newMaxSpeedPenalty
endFunction

function DDodgeStyle(int value)
	DDodgeStyle = value
	SpeedAndStyleUpdate()
endFunction

function DodgeSpeedMethod(int value)
	DodgeSpeedMethod = value
	SpeedAndStyleUpdate()
endFunction

function SpeedAndStyleUpdate()
	if(DDodgeStyle == 0) && (DodgeSpeedMethod != 2)
		goToState("nullnull")
	elseIf(DDodgeStyle == 0) && (DodgeSpeedMethod == 2)
		goToState("nulltwo")
	elseIf(DDodgeStyle == 1) && (DodgeSpeedMethod == 2)
		goToState("onetwo")
	elseIf(DDodgeStyle == 2) && (DodgeSpeedMethod == 2)
		goToState("twotwo")
	elseIf(DDodgeStyle == 1) && (DodgeSpeedMethod != 2)
		goToState("onenull")
	elseIf(DDodgeStyle == 2) && (DodgeSpeedMethod != 2)
		goToState("twonull")
	endIf
endFunction


;------------------------------------------------------------- Out functions -------------------------------------------------------------

float function MaxSpeedPenaltyOut()
	return MaxSpeedPenalty
endFunction