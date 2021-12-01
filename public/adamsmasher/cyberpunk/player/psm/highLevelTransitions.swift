
public abstract class HighLevelTransition extends DefaultTransition {

  public final func BlockMovement(const scriptInterface: ref<StateGameScriptInterface>, val: Bool) -> Void {
    if Equals(val, true) {
      StatusEffectHelper.ApplyStatusEffect(scriptInterface.executionOwner, t"GameplayRestriction.NoMovement");
    } else {
      StatusEffectHelper.RemoveStatusEffect(scriptInterface.executionOwner, t"GameplayRestriction.NoMovement");
    };
  }

  public final func ForceEmptyHands(stateContext: ref<StateContext>, val: Bool) -> Void {
    stateContext.SetPermanentBoolParameter(n"ForceEmptyHands", val, true);
  }

  public final func IsForceEmptyHands(stateContext: ref<StateContext>) -> Bool {
    return stateContext.GetBoolParameter(n"ForceEmptyHands", true);
  }

  public final func ForceTemporaryUnequip(stateContext: ref<StateContext>, val: Bool) -> Void {
    stateContext.SetPermanentBoolParameter(n"forcedTemporaryUnequip", val, true);
  }

  public final func ForceSafeState(stateContext: ref<StateContext>) -> Void {
    stateContext.SetPermanentBoolParameter(n"ForceSafeState", true, true);
  }

  public final func ForceReadyState(stateContext: ref<StateContext>) -> Void {
    stateContext.SetPermanentBoolParameter(n"ForceReadyState", true, true);
  }

  public final func ForceExitToStand(stateContext: ref<StateContext>) -> Void {
    if stateContext.GetConditionBool(n"CrouchToggled") {
      stateContext.SetConditionBoolParameter(n"CrouchToggled", false, true);
    };
  }

  public final func ResetForceWalkSpeed(stateContext: ref<StateContext>) -> Void {
    stateContext.SetPermanentFloatParameter(n"ForceWalkSpeed", -1.00, true);
  }

  public final func SetTier2LocomotionSlow(scriptInterface: ref<StateGameScriptInterface>) -> Void {
    if !StatusEffectSystem.ObjectHasStatusEffect(scriptInterface.executionOwner, t"GameplayRestriction.Tier2LocomotionSlow") {
      StatusEffectHelper.ApplyStatusEffect(scriptInterface.executionOwner, t"GameplayRestriction.Tier2LocomotionSlow");
    };
  }

  public final func SetTier2Locomotion(scriptInterface: ref<StateGameScriptInterface>) -> Void {
    if !StatusEffectSystem.ObjectHasStatusEffect(scriptInterface.executionOwner, t"GameplayRestriction.Tier2Locomotion") {
      StatusEffectHelper.ApplyStatusEffect(scriptInterface.executionOwner, t"GameplayRestriction.Tier2Locomotion");
    };
  }

  public final func SetTier2LocomotionFast(scriptInterface: ref<StateGameScriptInterface>) -> Void {
    if !StatusEffectSystem.ObjectHasStatusEffect(scriptInterface.executionOwner, t"GameplayRestriction.Tier2LocomotionFast") {
      StatusEffectHelper.ApplyStatusEffect(scriptInterface.executionOwner, t"GameplayRestriction.Tier2LocomotionFast");
    };
  }

  public final func RemoveTier2LocomotionSlow(scriptInterface: ref<StateGameScriptInterface>) -> Void {
    StatusEffectHelper.RemoveStatusEffect(scriptInterface.executionOwner, t"GameplayRestriction.Tier2LocomotionSlow");
  }

  public final func RemoveTier2Locomotion(scriptInterface: ref<StateGameScriptInterface>) -> Void {
    StatusEffectHelper.RemoveStatusEffect(scriptInterface.executionOwner, t"GameplayRestriction.Tier2Locomotion");
  }

  public final func RemoveTier2LocomotionFast(scriptInterface: ref<StateGameScriptInterface>) -> Void {
    StatusEffectHelper.RemoveStatusEffect(scriptInterface.executionOwner, t"GameplayRestriction.Tier2LocomotionFast");
  }

  public final func RemoveAllTierLocomotions(scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.RemoveTier2LocomotionSlow(scriptInterface);
    this.RemoveTier2Locomotion(scriptInterface);
    this.RemoveTier2LocomotionFast(scriptInterface);
  }

  public final func ActivateTier3Locomotion(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let swapEvent: ref<PSMAddOnDemandStateMachine> = new PSMAddOnDemandStateMachine();
    let player: ref<PlayerPuppet> = DefaultTransition.GetPlayerPuppet(scriptInterface);
    swapEvent.stateMachineName = n"LocomotionTier3";
    player.QueueEvent(swapEvent);
  }

  public final func ActivateTier4Locomotion(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let swapEvent: ref<PSMAddOnDemandStateMachine> = new PSMAddOnDemandStateMachine();
    let player: ref<PlayerPuppet> = DefaultTransition.GetPlayerPuppet(scriptInterface);
    swapEvent.stateMachineName = n"LocomotionTier4";
    player.QueueEvent(swapEvent);
  }

  public final func ActivateTier5Locomotion(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let swapEvent: ref<PSMAddOnDemandStateMachine> = new PSMAddOnDemandStateMachine();
    let player: ref<PlayerPuppet> = DefaultTransition.GetPlayerPuppet(scriptInterface);
    swapEvent.stateMachineName = n"LocomotionTier5";
    player.QueueEvent(swapEvent);
  }

  public final func ActivateWorkspotLocomotion(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let swapEvent: ref<PSMAddOnDemandStateMachine> = new PSMAddOnDemandStateMachine();
    let player: ref<PlayerPuppet> = DefaultTransition.GetPlayerPuppet(scriptInterface);
    swapEvent.stateMachineName = n"LocomotionWorkspot";
    player.QueueEvent(swapEvent);
  }

  public final func ForceDefaultLocomotion(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let swapEvent: ref<PSMAddOnDemandStateMachine> = new PSMAddOnDemandStateMachine();
    let player: ref<PlayerPuppet> = DefaultTransition.GetPlayerPuppet(scriptInterface);
    swapEvent.stateMachineName = n"Locomotion";
    swapEvent.tryHotSwap = true;
    player.QueueEvent(swapEvent);
  }

  protected final func GetCurrentHealthPerc(scriptInterface: ref<StateGameScriptInterface>) -> Float {
    let ownerID: StatsObjectID = Cast(scriptInterface.ownerEntityID);
    let gameInstance: GameInstance = scriptInterface.owner.GetGame();
    let health: Float = GameInstance.GetStatPoolsSystem(gameInstance).GetStatPoolValue(ownerID, gamedataStatPoolType.Health);
    return health;
  }

  protected final func SetPlayerVitalsAnimFeatureData(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>, val: Int32, stateDuration: Float) -> Void {
    let animFeature: ref<AnimFeature_PlayerVitals> = new AnimFeature_PlayerVitals();
    animFeature.state = val;
    animFeature.stateDuration = stateDuration;
    scriptInterface.SetAnimationParameterFeature(n"PlayerVitals", animFeature);
  }

  protected final const func GetDeathType(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> EDeathType {
    let deathType: EDeathType;
    let isSwimming: Bool = stateContext.IsStateMachineActive(n"LocomotionSwimming");
    if !scriptInterface.IsOnGround() && !isSwimming {
      deathType = EDeathType.Air;
    } else {
      if isSwimming {
        deathType = EDeathType.Swimming;
      } else {
        deathType = EDeathType.Ground;
      };
    };
    return deathType;
  }

  protected final const func IsDeathMenuBlocked(scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return GameInstance.GetQuestsSystem(scriptInterface.owner.GetGame()).GetFact(n"block_death_menu") == 1;
  }

  protected final func SetIsResurrectionAllowedBasedOnState(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let locomotionState: gamePSMDetailedLocomotionStates;
    let wasPlayerForceKilled: Bool;
    if this.HasSecondHeart(scriptInterface) && !scriptInterface.GetStatPoolsSystem().HasStatPoolValueReachedMin(Cast(scriptInterface.ownerEntityID), gamedataStatPoolType.Health) {
      locomotionState = IntEnum(scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.LocomotionDetailed));
      wasPlayerForceKilled = StatusEffectSystem.ObjectHasStatusEffect(scriptInterface.owner, t"BaseStatusEffect.ForceKill");
      if NotEquals(locomotionState, gamePSMDetailedLocomotionStates.DeathLand) && !wasPlayerForceKilled {
        stateContext.SetPermanentBoolParameter(n"isResurrectionAllowed", true, true);
        return;
      };
    };
    stateContext.SetPermanentBoolParameter(n"isResurrectionAllowed", false, true);
    if !this.IsDeathMenuBlocked(scriptInterface) {
      this.SetBlackboardBoolVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.DisplayDeathMenu, true);
      scriptInterface.GetStatPoolsSystem().RequestSettingStatPoolValueIgnoreChangeMode(Cast(scriptInterface.ownerEntityID), gamedataStatPoolType.Health, 0.00, null);
    };
  }

  protected final func SetPlayerDeathAnimFeatureData(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>, val: Int32) -> Void {
    let animFeature: ref<AnimFeature_PlayerDeathAnimation> = new AnimFeature_PlayerDeathAnimation();
    animFeature.animation = val;
    scriptInterface.SetAnimationParameterFeature(n"DeathAnimation", animFeature);
  }

  protected final func EvaluateSettingCustomDeathAnimation(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let setAnimInt: Int32;
    if this.GetStaticIntParameterDefault("DEBUG_forceSetDeathAnimation", -1) > 0 {
      setAnimInt = this.GetStaticIntParameterDefault("DEBUG_forceSetDeathAnimation", -1);
    } else {
      if StatusEffectSystem.ObjectHasStatusEffect(scriptInterface.executionOwner, t"BaseStatusEffect.NetwatcherGeneral") {
        setAnimInt = 1;
      } else {
        setAnimInt = 0;
      };
    };
    this.SetPlayerDeathAnimFeatureData(stateContext, scriptInterface, setAnimInt);
  }

  protected final const func IsResurrectionAllowed(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return stateContext.GetBoolParameter(n"isResurrectionAllowed", true);
  }

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let glpID: TweakDBID;
    let glpSys: ref<GameplayLogicPackageSystem>;
    if this.GetGLP(glpID) {
      glpSys = scriptInterface.GetGameplayLogicPackageSystem();
      if IsDefined(glpSys) {
        glpSys.ApplyPackage(scriptInterface.executionOwner, scriptInterface.executionOwner, glpID);
      };
    };
  }

  public func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let glpID: TweakDBID;
    let glpSys: ref<GameplayLogicPackageSystem>;
    if this.GetGLP(glpID) {
      glpSys = scriptInterface.GetGameplayLogicPackageSystem();
      if IsDefined(glpSys) {
        glpSys.RemovePackage(scriptInterface.executionOwner, glpID);
      };
    };
  }

  private final func GetGLP(out glpID: TweakDBID) -> Bool {
    glpID = TDBID.Create(this.GetStaticStringParameterDefault("gameplayLogicPackageID", ""));
    return TDBID.IsValid(glpID);
  }

  protected final const func HasSecondHeart(scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return scriptInterface.GetStatsSystem().GetStatValue(Cast(scriptInterface.ownerEntityID), gamedataStatType.HasSecondHeart) > 0.00;
  }
}

public class ExplorationDecisions extends HighLevelTransition {

  protected final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return true;
  }
}

public class ExplorationEvents extends HighLevelTransition {

  public final func OnEnterFromSwimming(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.StopStatPoolDecayAndRegenerate(scriptInterface, gamedataStatPoolType.Oxygen);
    this.DisableCameraBobbing(stateContext, scriptInterface, false);
    this.OnEnter(stateContext, scriptInterface);
  }

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let animFeature: ref<AnimFeature_SceneSystem>;
    PlayerPuppet.ReevaluateAllBreathingEffects(scriptInterface.owner as PlayerPuppet);
    this.BlockMovement(scriptInterface, false);
    this.ResetForceFlags(stateContext);
    this.ResetForceWalkSpeed(stateContext);
    this.RemoveAllTierLocomotions(scriptInterface);
    this.ForceDefaultLocomotion(stateContext, scriptInterface);
    GameObject.PlaySoundEvent(scriptInterface.owner, n"ST_Health_Status_Hi_Set_State");
    this.ClearSceneGameplayOverrides(scriptInterface);
    animFeature = new AnimFeature_SceneSystem();
    animFeature.tier = 0;
    scriptInterface.SetAnimationParameterFeature(n"Scene", animFeature);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.HighLevel, EnumInt(gamePSMHighLevel.SceneTier1));
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Vitals, EnumInt(gamePSMVitals.Alive));
    this.SetPlayerVitalsAnimFeatureData(stateContext, scriptInterface, 0, 0.00);
    this.SetPlayerDeathAnimFeatureData(stateContext, scriptInterface, 0);
    scriptInterface.GetAudioSystem().Play(n"global_death_exit");
    this.OnEnter(stateContext, scriptInterface);
  }

  protected final func ClearSceneGameplayOverrides(scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let animFeature: ref<AnimFeature_SceneGameplayOverrides> = new AnimFeature_SceneGameplayOverrides();
    scriptInterface.localBlackboard.SetBool(GetAllBlackboardDefs().PlayerStateMachine.SceneAimForced, false);
    scriptInterface.localBlackboard.SetBool(GetAllBlackboardDefs().PlayerStateMachine.SceneSafeForced, false);
    animFeature.aimForced = false;
    animFeature.safeForced = false;
    animFeature.isAimOutTimeOverridden = false;
    animFeature.aimOutTimeOverride = 0.00;
    scriptInterface.SetAnimationParameterFeature(n"SceneGameplayOverrides", animFeature);
  }

  protected final func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void;
}

public class SwimmingDecisions extends HighLevelTransition {

  protected final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let deepEnough: Bool;
    let depthRaycastDestination: Vector4;
    let depthTreshold: Float;
    let playerFeetPosition: Vector4;
    let tolerance: Float;
    let waterLevel: Float;
    if stateContext.IsStateMachineActive(n"Vehicle") {
      return false;
    };
    if stateContext.IsStateMachineActive(n"LocomotionTakedown") {
      return false;
    };
    playerFeetPosition = DefaultTransition.GetPlayerPosition(scriptInterface);
    depthRaycastDestination = playerFeetPosition;
    depthRaycastDestination.Z = depthRaycastDestination.Z - 2.00;
    deepEnough = false;
    if scriptInterface.GetWaterLevel(playerFeetPosition, depthRaycastDestination, waterLevel) {
      depthTreshold = this.GetStaticFloatParameterDefault("depthTreshold", 1.20);
      tolerance = this.GetStaticFloatParameterDefault("tolerance", 0.10);
      deepEnough = playerFeetPosition.Z - waterLevel <= depthTreshold + tolerance;
    };
    return deepEnough;
  }

  protected final const func ToExploration(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let depthTreshold: Float;
    let findSeabedDestination: Vector4;
    let findSeabedResult: TraceResult;
    let findSeabedSource: Vector4;
    let playerDistanceFromFloor: Float;
    let queryFilter: QueryFilter;
    let tolerance: Float;
    let tooShallow: Bool;
    let validFloorPosition: Bool;
    let waterLevel: Float;
    let maxDepth: Float = 100.00;
    let playerFeetPosition: Vector4 = DefaultTransition.GetPlayerPosition(scriptInterface);
    let findWaterDestination: Vector4 = playerFeetPosition;
    findWaterDestination.Z = findWaterDestination.Z + maxDepth;
    let foundWater: Bool = scriptInterface.GetWaterLevel(playerFeetPosition, findWaterDestination, waterLevel);
    if foundWater {
      depthTreshold = this.GetStaticFloatParameterDefault("depthTreshold", -1.20);
      tolerance = this.GetStaticFloatParameterDefault("tolerance", -0.10);
      findSeabedSource = playerFeetPosition;
      findSeabedSource.Z = waterLevel;
      findSeabedDestination = playerFeetPosition;
      findSeabedDestination.Z = findSeabedDestination.Z + depthTreshold + tolerance;
      QueryFilter.AddGroup(queryFilter, n"Static");
      QueryFilter.AddGroup(queryFilter, n"Terrain");
      QueryFilter.AddGroup(queryFilter, n"PlayerBlocker");
      findSeabedResult = scriptInterface.RayCastWithCollisionFilter(findSeabedSource, findSeabedDestination, queryFilter);
      if TraceResult.IsValid(findSeabedResult) {
        playerDistanceFromFloor = playerFeetPosition.Z - findSeabedResult.position.Z;
        validFloorPosition = playerDistanceFromFloor > 0.00 && playerDistanceFromFloor < AbsF(tolerance);
        tooShallow = validFloorPosition && findSeabedResult.position.Z - waterLevel > depthTreshold - tolerance;
      };
    };
    return !foundWater || tooShallow;
  }

  protected final const func ToDeath(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let player: ref<PlayerPuppet> = DefaultTransition.GetPlayerPuppet(scriptInterface);
    let playerID: StatsObjectID = Cast(player.GetEntityID());
    let gi: GameInstance = scriptInterface.owner.GetGame();
    let isDead: Bool = GameInstance.GetStatPoolsSystem(gi).HasStatPoolValueReachedMin(playerID, gamedataStatPoolType.Health);
    if isDead {
      return true;
    };
    return false;
  }
}

public class SwimmingEvents extends HighLevelTransition {

  public final func OnEnterFromSceneTierII(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    stateContext.SetPermanentBoolParameter(n"enteredWaterFromSceneTierII", true, true);
    this.OnEnter(stateContext, scriptInterface);
  }

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let swapEvent: ref<PSMAddOnDemandStateMachine> = new PSMAddOnDemandStateMachine();
    swapEvent.stateMachineName = n"LocomotionSwimming";
    swapEvent.tryHotSwap = true;
    scriptInterface.owner.QueueEvent(swapEvent);
    this.PlaySound(n"lcm_falling_wind_loop_end", scriptInterface);
    this.DisableCameraBobbing(stateContext, scriptInterface, true);
    StatusEffectHelper.ApplyStatusEffect(scriptInterface.executionOwner, t"GameplayRestriction.VehicleNoInteraction");
    this.OnEnter(stateContext, scriptInterface);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.HighLevel, EnumInt(gamePSMHighLevel.Swimming));
  }

  protected func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    if stateContext.GetBoolParameter(n"enteredWaterFromSceneTierII", true) {
      stateContext.RemovePermanentBoolParameter(n"enteredWaterFromSceneTierII");
      stateContext.SetTemporaryBoolParameter(n"requestReEnteringScene", true, true);
    };
    StatusEffectHelper.RemoveStatusEffect(scriptInterface.executionOwner, t"GameplayRestriction.VehicleNoInteraction");
    scriptInterface.PushAnimationEvent(n"SwimExit");
    this.OnExit(stateContext, scriptInterface);
  }
}

public class AiControlledDecisions extends HighLevelTransition {

  public final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let isPlayerControlled: StateResultBool;
    let playerPuppet: ref<PlayerPuppet> = DefaultTransition.GetPlayerPuppet(scriptInterface);
    let aiComponent: ref<AIComponent> = playerPuppet.GetAIControllerComponent();
    if aiComponent == null {
      return false;
    };
    isPlayerControlled = stateContext.GetTemporaryBoolParameter(n"playerControlled");
    return isPlayerControlled.valid && !isPlayerControlled.value;
  }

  public final const func ExitCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let isPlayerControlled: StateResultBool = stateContext.GetTemporaryBoolParameter(n"playerControlled");
    return isPlayerControlled.valid && isPlayerControlled.value;
  }
}

public class AiControlledEvents extends HighLevelTransition {

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.ForceIdle(stateContext);
    this.OnEnter(stateContext, scriptInterface);
  }
}

public class DeathDecisions extends HighLevelTransition {

  protected final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let player: ref<PlayerPuppet> = scriptInterface.executionOwner as PlayerPuppet;
    if player.GetPuppetPS().GetIsDead() {
      return true;
    };
    if scriptInterface.GetStatPoolsSystem().HasStatPoolValueReachedMin(Cast(scriptInterface.ownerEntityID), gamedataStatPoolType.Health) {
      return true;
    };
    if this.HasSecondHeart(scriptInterface) && scriptInterface.GetStatPoolsSystem().IsStatPoolAdded(Cast(scriptInterface.ownerEntityID), gamedataStatPoolType.Health) {
      if GameInstance.GetGodModeSystem(scriptInterface.GetGame()).HasGodMode(scriptInterface.ownerEntityID, gameGodModeType.Invulnerable) {
        return false;
      };
      return scriptInterface.GetStatPoolsSystem().GetStatPoolValue(Cast(scriptInterface.ownerEntityID), gamedataStatPoolType.Health, true) <= 1.10;
    };
    return false;
  }
}

public class SpecificDeathDecisions extends HighLevelTransition {

  protected final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return Equals(this.GetStaticStringParameterDefault("enterFromState", ""), EnumValueToString("EDeathType", Cast(EnumInt(this.GetDeathType(stateContext, scriptInterface)))));
  }

  protected final const func ToResurrect(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if this.IsResurrectionAllowed(stateContext, scriptInterface) {
      if this.GetInStateTime() >= this.GetStaticFloatParameterDefault("stateDuration", 3.00) {
        return true;
      };
    };
    return false;
  }
}

public class SpecificDeathEvents extends HighLevelTransition {

  private let isDyingEffectPlaying: Bool;

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    if Equals(this.GetDeathType(stateContext, scriptInterface), EDeathType.Ground) {
      this.BlockMovement(scriptInterface, true);
    } else {
      if Equals(this.GetDeathType(stateContext, scriptInterface), EDeathType.Swimming) {
        this.ForceFreeze(stateContext);
      };
    };
    this.EvaluateSettingCustomDeathAnimation(stateContext, scriptInterface);
    this.SetDeathCameraParameters(stateContext, scriptInterface);
    DefaultTransition.RemoveAllBreathingEffects(scriptInterface);
    this.SetIsResurrectionAllowedBasedOnState(stateContext, scriptInterface);
    this.ForceTemporaryUnequip(stateContext, true);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.HighLevel, EnumInt(gamePSMHighLevel.SceneTier1));
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Vitals, EnumInt(gamePSMVitals.Dead));
    this.SetPlayerVitalsAnimFeatureData(stateContext, scriptInterface, 1, TweakDBInterface.GetFloat(t"player.deathMenu.delayToDisplay", 3.00));
    scriptInterface.GetAudioSystem().Play(n"global_death_enter");
    scriptInterface.GetAudioSystem().Play(n"ui_death");
    if !this.IsDeathMenuBlocked(scriptInterface) {
      this.StartEffect(scriptInterface, n"dying");
      this.isDyingEffectPlaying = true;
    };
    this.OnEnter(stateContext, scriptInterface);
  }

  protected func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    if this.isDyingEffectPlaying {
      this.StopEffect(scriptInterface, n"dying");
      this.isDyingEffectPlaying = false;
    };
    this.OnExit(stateContext, scriptInterface);
  }

  protected final func SetDeathCameraParameters(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let param: StateResultCName = this.GetStaticCNameParameter("onEnterCameraParamsName");
    if param.valid {
      stateContext.SetPermanentCNameParameter(n"LocomotionCameraParams", param.value, true);
      this.UpdateCameraContext(stateContext, scriptInterface);
    };
  }
}

public class ResurrectDecisions extends HighLevelTransition {

  protected final const func ToExploration(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if StatusEffectHelper.GetStatusEffectByID(scriptInterface.owner, t"BaseStatusEffect.SecondHeart").GetRemainingDuration() <= 0.00 {
      return true;
    };
    return false;
  }
}

public class ResurrectEvents extends HighLevelTransition {

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    StatusEffectHelper.ApplyStatusEffect(scriptInterface.owner, t"BaseStatusEffect.SecondHeart");
    this.ForceFreeze(stateContext);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.HighLevel, EnumInt(gamePSMHighLevel.SceneTier1));
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Vitals, EnumInt(gamePSMVitals.Resurrecting));
    this.SetPlayerVitalsAnimFeatureData(stateContext, scriptInterface, 2, 2.00);
    scriptInterface.PushAnimationEvent(n"PlayerResurrect");
    this.OnEnter(stateContext, scriptInterface);
  }

  protected func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let playerPuppet: ref<PlayerPuppet>;
    this.SendResurrectEvent(scriptInterface);
    this.ForceTemporaryUnequip(stateContext, false);
    scriptInterface.PushAnimationEvent(n"PlayerResurrected");
    playerPuppet = scriptInterface.executionOwner as PlayerPuppet;
    if playerPuppet.IsControlledByLocalPeer() {
      GameInstance.GetDebugVisualizerSystem(scriptInterface.GetGame()).ClearAll();
    };
    if Equals(this.GetDeathType(stateContext, scriptInterface), EDeathType.Swimming) {
      this.StopStatPoolDecayAndRegenerate(scriptInterface, gamedataStatPoolType.Oxygen);
    };
    this.OnExit(stateContext, scriptInterface);
  }

  private final func SendResurrectEvent(scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let player: ref<PlayerPuppet> = scriptInterface.executionOwner as PlayerPuppet;
    let resurrectEvent: ref<ResurrectEvent> = new ResurrectEvent();
    player.QueueEvent(resurrectEvent);
  }
}

public class InspectionDecisions extends HighLevelTransition {

  protected final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let inspectionComponent: ref<InspectionComponent> = (scriptInterface.owner as PlayerPuppet).GetInspectionComponent();
    if IsDefined(inspectionComponent) {
      return inspectionComponent.GetIsPlayerInspecting();
    };
    return false;
  }

  protected final const func ToExploration(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if scriptInterface.IsActionJustPressed(n"InspectionClose") {
      return true;
    };
    return !(scriptInterface.owner as PlayerPuppet).GetInspectionComponent().GetIsPlayerInspecting();
  }
}

public class InspectionEvents extends HighLevelTransition {

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.ForceEmptyHands(stateContext, true);
    this.ForceIdle(stateContext);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.HighLevel, EnumInt(gamePSMHighLevel.SceneTier1));
    this.OnEnter(stateContext, scriptInterface);
  }

  protected func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let evt: ref<InspectionEvent> = new InspectionEvent();
    evt.enabled = false;
    (scriptInterface.owner as PlayerPuppet).QueueEvent(evt);
    this.OnExit(stateContext, scriptInterface);
  }
}

public class MinigameDecisions extends HighLevelTransition {

  protected final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.IsInMinigame(scriptInterface) && this.IsInLocomotionState(stateContext, n"workspot");
  }

  protected final const func ExitCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return !this.IsInMinigame(scriptInterface);
  }
}

public class MinigameEvents extends HighLevelTransition {

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.ForceEmptyHands(stateContext, true);
    this.ForceFreeze(stateContext);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.HighLevel, EnumInt(gamePSMHighLevel.Default));
    this.OnEnter(stateContext, scriptInterface);
  }
}

public class SceneTierInitialDecisions extends SceneTierAbstract {

  protected final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if EnumInt(this.GetCurrentSceneTier(stateContext)) > EnumInt(GameplayTier.Tier1_FullGameplay) || stateContext.GetBoolParameter(n"requestReEnteringScene", true) {
      if stateContext.GetBoolParameter(n"enteredWaterFromSceneTierII", true) || stateContext.IsStateMachineActive(n"LocomotionTakedown") {
        return false;
      };
      return true;
    };
    return false;
  }
}

public abstract class SceneTierAbstract extends HighLevelTransition {

  protected final const func GetCurrentSceneTier(const stateContext: ref<StateContext>) -> GameplayTier {
    let requestedSceneTier: GameplayTier = GameplayTier.Undefined;
    let sceneTier: ref<SceneTierData> = this.GetCurrentSceneTierData(stateContext);
    if IsDefined(sceneTier) {
      requestedSceneTier = sceneTier.tier;
    };
    return requestedSceneTier;
  }

  protected const func SceneTierToEnter() -> GameplayTier {
    return GameplayTier.Undefined;
  }
}

public abstract class SceneTierAbstractDecisions extends SceneTierAbstract {

  protected final const func ToExploration(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if Equals(this.GetCurrentSceneTier(stateContext), GameplayTier.Tier1_FullGameplay) {
      return true;
    };
    return false;
  }
}

public abstract class SceneTierAbstractEvents extends SceneTierAbstract {

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let sceneTier: ref<SceneTierData>;
    let animFeature: ref<AnimFeature_SceneSystem> = new AnimFeature_SceneSystem();
    animFeature.tier = EnumInt(this.SceneTierToEnter());
    scriptInterface.SetAnimationParameterFeature(n"Scene", animFeature);
    this.ResetForceFlags(stateContext);
    sceneTier = this.GetCurrentSceneTierData(stateContext);
    if IsDefined(sceneTier) {
      if IsClient() {
        stateContext.SetPermanentBoolParameter(n"EmptyHandsForcedByTierChange", sceneTier.emptyHands, true);
      };
      this.ForceEmptyHands(stateContext, sceneTier.emptyHands);
    };
    this.ForceDefaultLocomotion(stateContext, scriptInterface);
    this.UpdateCameraContext(stateContext, scriptInterface);
    this.OnEnter(stateContext, scriptInterface);
  }

  protected func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let currentHighLevelState: Int32;
    let desiredHighLevelState: Int32;
    let sceneTier: ref<SceneTierData>;
    this.SetAudioParameter(n"g_player_health", this.GetCurrentHealthPerc(scriptInterface), scriptInterface);
    sceneTier = this.GetCurrentSceneTierData(stateContext);
    if IsDefined(sceneTier) {
      if NotEquals(sceneTier.emptyHands, this.IsForceEmptyHands(stateContext)) {
        if IsClient() {
          stateContext.SetPermanentBoolParameter(n"EmptyHandsForcedByTierChange", sceneTier.emptyHands, true);
        };
        this.ForceEmptyHands(stateContext, sceneTier.emptyHands);
      };
      currentHighLevelState = scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.HighLevel);
      desiredHighLevelState = EnumInt(this.SceneTierToEnter());
      if currentHighLevelState != desiredHighLevelState {
        this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.HighLevel, desiredHighLevelState);
      };
    };
  }
}

public class SceneTierIIDecisions extends SceneTierAbstractDecisions {

  protected const func SceneTierToEnter() -> GameplayTier {
    return GameplayTier.Tier2_StagedGameplay;
  }

  protected final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return Equals(this.GetCurrentSceneTier(stateContext), GameplayTier.Tier2_StagedGameplay);
  }
}

public class SceneTierIIEvents extends SceneTierAbstractEvents {

  public let m_cachedSpeedValue: Float;

  public let m_maxSpeedStat: ref<gameStatModifierData>;

  public let m_currentSpeedMovementPreset: Tier2WalkType;

  public let m_currentSpeedValue: Float;

  public let m_currentLocomotionState: CName;

  protected const func SceneTierToEnter() -> GameplayTier {
    return GameplayTier.Tier2_StagedGameplay;
  }

  protected final const func GetSceneTier2Data(const stateContext: ref<StateContext>) -> ref<SceneTier2Data> {
    let tier2Data: ref<SceneTier2Data> = this.GetCurrentSceneTierData(stateContext) as SceneTier2Data;
    return tier2Data;
  }

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let statSystem: ref<StatsSystem>;
    let ownerID: StatsObjectID = Cast(scriptInterface.executionOwnerEntityID);
    this.OnEnter(stateContext, scriptInterface);
    this.SetTier2Locomotion(scriptInterface);
    this.ForceSafeState(stateContext);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.HighLevel, EnumInt(gamePSMHighLevel.SceneTier2));
    this.m_cachedSpeedValue = this.UpdateSpeedValue(stateContext, scriptInterface);
    this.m_maxSpeedStat = RPGManager.CreateStatModifier(gamedataStatType.MaxSpeed, gameStatModifierType.Additive, this.m_cachedSpeedValue);
    statSystem = scriptInterface.GetStatsSystem();
    statSystem.AddModifier(ownerID, this.m_maxSpeedStat);
  }

  protected func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let ownerID: StatsObjectID = Cast(scriptInterface.executionOwnerEntityID);
    this.OnExit(stateContext, scriptInterface);
    scriptInterface.GetStatsSystem().RemoveModifier(ownerID, this.m_maxSpeedStat);
    this.RemoveAllTierLocomotions(scriptInterface);
  }

  protected func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnUpdate(timeDelta, stateContext, scriptInterface);
    this.UpdateLocomotionStatsBasedOnMovementType(stateContext, scriptInterface);
  }

  protected final func UpdateLocomotionStatsBasedOnMovementType(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let statSystem: ref<StatsSystem> = scriptInterface.GetStatsSystem();
    let ownerID: StatsObjectID = Cast(scriptInterface.executionOwnerEntityID);
    let speedValue: Float = this.UpdateSpeedValue(stateContext, scriptInterface);
    if speedValue != this.m_cachedSpeedValue {
      this.m_cachedSpeedValue = speedValue;
      scriptInterface.GetStatsSystem().RemoveModifier(ownerID, this.m_maxSpeedStat);
      this.m_maxSpeedStat = RPGManager.CreateStatModifier(gamedataStatType.MaxSpeed, gameStatModifierType.Additive, this.m_cachedSpeedValue);
      statSystem.AddModifier(ownerID, this.m_maxSpeedStat);
    };
  }

  protected final func UpdateSpeedValue(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Float {
    let speedValue: Float;
    let currentMovementPreset: Tier2WalkType = this.GetCurrentTier2MovementPreset(stateContext);
    let currentLocomotionState: CName = stateContext.GetStateMachineCurrentState(n"Locomotion");
    if Equals(currentMovementPreset, this.m_currentSpeedMovementPreset) && Equals(currentLocomotionState, this.m_currentLocomotionState) {
      return this.m_currentSpeedValue;
    };
    switch currentMovementPreset {
      case Tier2WalkType.Slow:
        this.RemoveTier2Locomotion(scriptInterface);
        this.RemoveTier2LocomotionFast(scriptInterface);
        this.SetTier2LocomotionSlow(scriptInterface);
        this.UpdateMaxSpeedBasedOnPlayerState(currentLocomotionState, currentMovementPreset, speedValue);
        break;
      case Tier2WalkType.Normal:
        this.RemoveTier2LocomotionSlow(scriptInterface);
        this.RemoveTier2LocomotionFast(scriptInterface);
        this.SetTier2Locomotion(scriptInterface);
        this.UpdateMaxSpeedBasedOnPlayerState(currentLocomotionState, currentMovementPreset, speedValue);
        break;
      case Tier2WalkType.Fast:
        this.RemoveTier2LocomotionSlow(scriptInterface);
        this.RemoveTier2Locomotion(scriptInterface);
        this.SetTier2LocomotionFast(scriptInterface);
        this.UpdateMaxSpeedBasedOnPlayerState(currentLocomotionState, currentMovementPreset, speedValue);
        break;
      default:
        this.RemoveAllTierLocomotions(scriptInterface);
    };
    this.SetTier2Locomotion(scriptInterface);
    speedValue = 0.00;
    this.m_currentSpeedValue = speedValue;
    this.m_currentSpeedMovementPreset = currentMovementPreset;
    this.m_currentLocomotionState = currentLocomotionState;
    return speedValue;
  }

  protected final func UpdateMaxSpeedBasedOnPlayerState(locomotionStateName: CName, movementPreset: Tier2WalkType, out speedValue: Float) -> Void {
    switch movementPreset {
      case Tier2WalkType.Slow:
        if Equals(locomotionStateName, n"stand") {
          speedValue = this.GetStaticFloatParameterDefault("slowWalkSpeed", -1.30);
        } else {
          if Equals(locomotionStateName, n"sprint") {
            speedValue = this.GetStaticFloatParameterDefault("slowJogSpeed", -2.50);
          } else {
            if Equals(locomotionStateName, n"crouch") {
              speedValue = this.GetStaticFloatParameterDefault("slowCrouchSpeed", 0.00);
            };
          };
        };
        break;
      case Tier2WalkType.Normal:
        if Equals(locomotionStateName, n"stand") {
          speedValue = this.GetStaticFloatParameterDefault("normalWalkSpeed", 0.00);
        } else {
          if Equals(locomotionStateName, n"sprint") {
            speedValue = this.GetStaticFloatParameterDefault("normalJogSpeed", 0.00);
          } else {
            if Equals(locomotionStateName, n"crouch") {
              speedValue = this.GetStaticFloatParameterDefault("normalCrouchSpeed", 0.00);
            };
          };
        };
        break;
      case Tier2WalkType.Fast:
        if Equals(locomotionStateName, n"stand") {
          speedValue = this.GetStaticFloatParameterDefault("fastWalkSpeed", 0.00);
        } else {
          if Equals(locomotionStateName, n"sprint") {
            speedValue = this.GetStaticFloatParameterDefault("fastJogSpeed", 0.00);
          } else {
            if Equals(locomotionStateName, n"crouch") {
              speedValue = this.GetStaticFloatParameterDefault("fastCrouchSpeed", 0.00);
            };
          };
        };
        break;
      default:
        speedValue = 0.00;
    };
  }

  protected final const func GetCurrentTier2MovementPreset(stateContext: ref<StateContext>) -> Tier2WalkType {
    let sceneTier2Data: ref<SceneTier2Data> = this.GetSceneTier2Data(stateContext);
    return sceneTier2Data.walkType;
  }
}

public class SceneTierIIIDecisions extends SceneTierAbstractDecisions {

  protected const func SceneTierToEnter() -> GameplayTier {
    return GameplayTier.Tier3_LimitedGameplay;
  }

  protected final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return Equals(this.GetCurrentSceneTier(stateContext), GameplayTier.Tier3_LimitedGameplay);
  }
}

public class SceneTierIIIEvents extends SceneTierAbstractEvents {

  protected const func SceneTierToEnter() -> GameplayTier {
    return GameplayTier.Tier3_LimitedGameplay;
  }

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnEnter(stateContext, scriptInterface);
    this.ActivateTier3Locomotion(stateContext, scriptInterface);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.HighLevel, EnumInt(gamePSMHighLevel.SceneTier3));
  }

  protected func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnUpdate(timeDelta, stateContext, scriptInterface);
  }
}

public class SceneTierIVDecisions extends SceneTierAbstractDecisions {

  protected const func SceneTierToEnter() -> GameplayTier {
    return GameplayTier.Tier4_FPPCinematic;
  }

  protected final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return Equals(this.GetCurrentSceneTier(stateContext), GameplayTier.Tier4_FPPCinematic);
  }
}

public class SceneTierIVEvents extends SceneTierAbstractEvents {

  protected const func SceneTierToEnter() -> GameplayTier {
    return GameplayTier.Tier4_FPPCinematic;
  }

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnEnter(stateContext, scriptInterface);
    this.ActivateTier4Locomotion(stateContext, scriptInterface);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.HighLevel, EnumInt(gamePSMHighLevel.SceneTier4));
  }
}

public class SceneTierVDecisions extends SceneTierAbstractDecisions {

  protected const func SceneTierToEnter() -> GameplayTier {
    return GameplayTier.Tier5_Cinematic;
  }

  protected final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return Equals(this.GetCurrentSceneTier(stateContext), GameplayTier.Tier5_Cinematic);
  }
}

public class SceneTierVEvents extends SceneTierAbstractEvents {

  protected const func SceneTierToEnter() -> GameplayTier {
    return GameplayTier.Tier5_Cinematic;
  }

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnEnter(stateContext, scriptInterface);
    if StatusEffectSystem.ObjectHasStatusEffect(scriptInterface.executionOwner, t"BaseStatusEffect.BreathingLow") {
      DefaultTransition.RemoveAllBreathingEffects(scriptInterface);
    };
    this.ActivateTier5Locomotion(stateContext, scriptInterface);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.HighLevel, EnumInt(gamePSMHighLevel.SceneTier5));
  }
}
