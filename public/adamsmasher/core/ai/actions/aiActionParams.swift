
public class AIActionParams extends IScriptable {

  public final static func CreateActionID(context: ScriptExecutionContext, puppet: ref<ScriptedPuppet>, actionStringName: String, actionPackageType: AIactionParamsPackageTypes, out actionName: CName) -> TweakDBID {
    actionName = StringToName(actionStringName);
    return ScriptExecutionContext.CreateActionID(context, actionStringName, actionPackageType);
  }

  public final static func TempGetIsValid(actionID: TweakDBID) -> Bool {
    return AITweakParams.GetBoolFromTweak(actionID, "tempIsValid");
  }

  public final static func GetOwnerStatesFromArray(ownerStates: array<CName>) -> AIActionNPCStates {
    let result: AIActionNPCStates;
    let i: Int32 = 0;
    while i < ArraySize(ownerStates) {
      AIActionParams.PushBackNPCState(result, ownerStates[i]);
      i += 1;
    };
    return result;
  }

  public final static func GetTargetStatesFromArray(targetStates: array<CName>) -> AIActionTargetStates {
    let result: AIActionTargetStates;
    let i: Int32 = 0;
    while i < ArraySize(targetStates) {
      AIActionParams.PushBackNPCState(result.npcStates, targetStates[i]);
      AIActionParams.PushBackPlayerState(result.playerStates, targetStates[i]);
      i += 1;
    };
    return result;
  }

  public final static func GetTargetStatesFromArray(targetStates: array<CName>, target: wref<GameObject>) -> AIActionTargetStates {
    let i: Int32;
    let result: AIActionTargetStates;
    if target.IsPlayer() {
      i = 0;
      while i < ArraySize(targetStates) {
        AIActionParams.PushBackPlayerState(result.playerStates, targetStates[i]);
        i += 1;
      };
    } else {
      if target.IsNPC() {
        AIActionParams.PushBackNPCState(result.npcStates, targetStates[i]);
      };
    };
    return result;
  }

  public final static func PushBackNPCState(out npcStates: AIActionNPCStates, stateName: CName) -> Void {
    let behaviorState: gamedataNPCBehaviorState;
    let defenseMode: gamedataDefenseMode;
    let locomotionMode: gamedataLocomotionMode;
    let stanceState: gamedataNPCStanceState;
    let upperBodyState: gamedataNPCUpperBodyState;
    let highLevelState: gamedataNPCHighLevelState = AIActionParams.GetHighLevelStateFromName(stateName);
    if NotEquals(highLevelState, gamedataNPCHighLevelState.Invalid) {
      ArrayPush(npcStates.highLevelStates, highLevelState);
      return;
    };
    upperBodyState = AIActionParams.GetUpperBodyStateFromName(stateName);
    if NotEquals(upperBodyState, gamedataNPCUpperBodyState.Invalid) {
      ArrayPush(npcStates.upperBodyStates, upperBodyState);
      return;
    };
    stanceState = AIActionParams.GetStanceStateFromName(stateName);
    if NotEquals(stanceState, gamedataNPCStanceState.Invalid) {
      ArrayPush(npcStates.stanceStates, stanceState);
      return;
    };
    behaviorState = AIActionParams.GetBehaviorStateFromName(stateName);
    if NotEquals(behaviorState, gamedataNPCBehaviorState.Invalid) {
      ArrayPush(npcStates.behaviorStates, behaviorState);
      return;
    };
    locomotionMode = AIActionParams.GetLocomotionModeFromName(stateName);
    if NotEquals(locomotionMode, gamedataLocomotionMode.Invalid) {
      ArrayPush(npcStates.locomotionMode, locomotionMode);
      return;
    };
    defenseMode = AIActionParams.GetDefenseModeFromName(stateName);
    if NotEquals(defenseMode, gamedataDefenseMode.Invalid) {
      ArrayPush(npcStates.defenseMode, defenseMode);
      return;
    };
  }

  public final static func PushBackPlayerState(out playerStates: AIActionPlayerStates, stateName: CName) -> Void {
    let bodyCarryState: gamePSMBodyCarrying;
    let combatState: gamePSMCombat;
    let locomotionState: gamePSMLocomotionStates;
    let meleeState: gamePSMMelee;
    let upperBodyState: gamePSMUpperBodyStates;
    let zoneState: gamePSMZones;
    if AIActionParams.GetPSMLocomotionStateFromName(stateName, locomotionState) {
      ArrayPush(playerStates.locomotionStates, locomotionState);
    };
    if AIActionParams.GetPSMUpperBodyStateFromName(stateName, upperBodyState) {
      ArrayPush(playerStates.upperBodyStates, upperBodyState);
    };
    if AIActionParams.GetPSMMeleeStateFromName(stateName, meleeState) {
      ArrayPush(playerStates.meleeStates, meleeState);
    };
    if AIActionParams.GetPSMZoneStateFromName(stateName, zoneState) {
      ArrayPush(playerStates.zoneStates, zoneState);
    };
    if AIActionParams.GetPSMBodyCarryStateFromName(stateName, bodyCarryState) {
      ArrayPush(playerStates.bodyCarryStates, bodyCarryState);
    };
    if AIActionParams.GetPSMCombatStateFromName(stateName, combatState) {
      ArrayPush(playerStates.combatStates, combatState);
    };
  }

  public final static func GetUpperBodyStateFromName(nameParam: CName) -> gamedataNPCUpperBodyState {
    let result: Int32 = Cast(EnumValueFromName(n"gamedataNPCUpperBodyState", nameParam));
    if result >= 0 {
      return IntEnum(result);
    };
    return gamedataNPCUpperBodyState.Invalid;
  }

  public final static func GetBehaviorStateFromName(nameParam: CName) -> gamedataNPCBehaviorState {
    let result: Int32 = Cast(EnumValueFromName(n"gamedataNPCBehaviorState", nameParam));
    if result >= 0 {
      return IntEnum(result);
    };
    return gamedataNPCBehaviorState.Invalid;
  }

  public final static func GetStanceStateFromName(nameParam: CName) -> gamedataNPCStanceState {
    let result: Int32 = Cast(EnumValueFromName(n"gamedataNPCStanceState", nameParam));
    if result >= 0 {
      return IntEnum(result);
    };
    return gamedataNPCStanceState.Invalid;
  }

  public final static func GetHighLevelStateFromName(nameParam: CName) -> gamedataNPCHighLevelState {
    let result: Int32 = Cast(EnumValueFromName(n"gamedataNPCHighLevelState", nameParam));
    if result >= 0 {
      return IntEnum(result);
    };
    return gamedataNPCHighLevelState.Invalid;
  }

  public final static func GetDefenseModeFromName(nameParam: CName) -> gamedataDefenseMode {
    let result: Int32 = Cast(EnumValueFromName(n"gamedataDefenseMode", nameParam));
    if result >= 0 {
      return IntEnum(result);
    };
    return gamedataDefenseMode.Invalid;
  }

  public final static func GetLocomotionModeFromName(nameParam: CName) -> gamedataLocomotionMode {
    let result: Int32 = Cast(EnumValueFromName(n"gamedataLocomotionMode", nameParam));
    if result >= 0 {
      return IntEnum(result);
    };
    return gamedataLocomotionMode.Invalid;
  }

  public final static func GetPSMLocomotionStateFromName(nameParam: CName, out locomotionState: gamePSMLocomotionStates) -> Bool {
    let result: Int32 = Cast(EnumValueFromName(n"gamePSMLocomotionStates", nameParam));
    if result >= 0 {
      locomotionState = IntEnum(result);
      return true;
    };
    return false;
  }

  public final static func GetPSMUpperBodyStateFromName(nameParam: CName, out upperBodyState: gamePSMUpperBodyStates) -> Bool {
    let result: Int32 = Cast(EnumValueFromName(n"gamePSMUpperBodyStates", nameParam));
    if result >= 0 {
      upperBodyState = IntEnum(result);
      return true;
    };
    return false;
  }

  public final static func GetPSMMeleeStateFromName(nameParam: CName, out meleeState: gamePSMMelee) -> Bool {
    let result: Int32 = Cast(EnumValueFromName(n"gamePSMMelee", nameParam));
    if result >= 0 {
      meleeState = IntEnum(result);
      return true;
    };
    return false;
  }

  public final static func GetPSMZoneStateFromName(nameParam: CName, out zoneState: gamePSMZones) -> Bool {
    let result: Int32 = Cast(EnumValueFromName(n"gamePSMZones", nameParam));
    if result >= 0 {
      zoneState = IntEnum(result);
      return true;
    };
    return false;
  }

  public final static func GetPSMBodyCarryStateFromName(nameParam: CName, out bodyCarryState: gamePSMBodyCarrying) -> Bool {
    let result: Int32 = Cast(EnumValueFromName(n"gamePSMBodyCarrying", nameParam));
    if result >= 0 {
      bodyCarryState = IntEnum(result);
      return true;
    };
    return false;
  }

  public final static func GetPSMCombatStateFromName(nameParam: CName, out combatState: gamePSMCombat) -> Bool {
    let result: Int32 = Cast(EnumValueFromName(n"gamePSMCombat", nameParam));
    if result >= 0 {
      combatState = IntEnum(result);
      return true;
    };
    return false;
  }
}
