
public abstract class AIAutonomousConditions extends AIbehaviorconditionScript {

  public final static func HasHostileThreats(context: ScriptExecutionContext) -> Bool {
    let puppet: ref<ScriptedPuppet> = AIBehaviorScriptBase.GetPuppet(context);
    let trackerComponent: ref<TargetTrackerComponent> = puppet.GetTargetTrackerComponent();
    if trackerComponent == null {
      return false;
    };
    if puppet.IsCharacterCivilian() {
      return false;
    };
    return trackerComponent.HasHostileThreat(false);
  }

  public final static func HasCombatAICommand(context: ScriptExecutionContext) -> Bool {
    let commandTarget: wref<GameObject> = ScriptExecutionContext.GetArgumentObject(context, n"CommandCombatTarget");
    if IsDefined(commandTarget) && ScriptedPuppet.IsActive(commandTarget) {
      return true;
    };
    if AIActionHelper.HasCombatAICommand(AIBehaviorScriptBase.GetPuppet(context)) {
      return true;
    };
    return false;
  }

  protected final func HasUnknownThreats(context: ScriptExecutionContext) -> Bool {
    return false;
  }

  public final static func IsPlayerInCombat(context: ScriptExecutionContext) -> Bool {
    let player: wref<PlayerPuppet>;
    let aiComp: ref<AIHumanComponent> = AIBehaviorScriptBase.GetAIComponent(context);
    if aiComp.GetFriendlyTargetAsPlayer(player) && Equals(IntEnum(AIActionChecks.GetPSMBlackbordInt(player, GetAllBlackboardDefs().PlayerStateMachine.Combat)), gamePSMCombat.InCombat) {
      return true;
    };
    return false;
  }

  public final static func WaitForAnimationToFinish(context: ScriptExecutionContext) -> Bool {
    let puppet: ref<ScriptedPuppet> = AIBehaviorScriptBase.GetPuppet(context);
    if puppet.GetMovePolicesComponent().IsOnOffMeshLink() {
      AIAutonomousConditions.SchedulePassiveConditionEvaluation(puppet, 0.25);
      return true;
    };
    if GameInstance.GetCoverManager(puppet.GetGame()).IsEnteringOrLeavingCover(puppet) {
      AIAutonomousConditions.SchedulePassiveConditionEvaluation(puppet, 0.25);
      return true;
    };
    return false;
  }

  public final static func SchedulePassiveConditionEvaluation(puppet: wref<ScriptedPuppet>, delay: Float) -> Void {
    GameInstance.GetDelaySystem(puppet.GetGame()).DelayEvent(puppet, new DelayPassiveConditionEvaluationEvent(), delay, false);
  }

  public final static func IsPlayerRecentlyDroppedThreat(owner: wref<GameObject>) -> Bool {
    let threatData: DroppedThreatData;
    let threatObject: wref<GameObject>;
    let tte: wref<TargetTrackingExtension>;
    if TargetTrackingExtension.Get(owner as ScriptedPuppet, tte) && tte.GetDroppedThreat(owner.GetGame(), threatData) {
      threatObject = threatData.threat as GameObject;
      if IsDefined(threatObject) && threatObject.IsPlayer() {
        return true;
      };
    };
    return false;
  }

  public final static func AlertedCondition(context: ScriptExecutionContext) -> Bool {
    let highLevelState: gamedataNPCHighLevelState;
    let puppet: ref<ScriptedPuppet> = AIBehaviorScriptBase.GetPuppet(context);
    if ScriptedPuppet.IsPlayerCompanion(puppet) {
      return false;
    };
    if !puppet.IsAggressive() {
      return false;
    };
    if puppet.IsPrevention() && !PreventionSystem.ShouldReactionBeAgressive(puppet.GetGame()) {
      return false;
    };
    if AIAutonomousConditions.WaitForAnimationToFinish(context) {
      if NPCPuppet.IsInAlerted(AIBehaviorScriptBase.GetPuppet(context)) {
        return true;
      };
      return false;
    };
    highLevelState = puppet.GetHighLevelStateFromBlackboard();
    if Equals(highLevelState, gamedataNPCHighLevelState.Alerted) {
      return true;
    };
    if VehicleComponent.IsMountedToVehicle(ScriptExecutionContext.GetOwner(context).GetGame(), ScriptExecutionContext.GetOwner(context)) {
      return false;
    };
    if Equals(highLevelState, gamedataNPCHighLevelState.Combat) && AIAutonomousConditions.IsPlayerRecentlyDroppedThreat(puppet) {
      return true;
    };
    return false;
  }

  public final static func CombatCondition(context: ScriptExecutionContext) -> Bool {
    if AIAutonomousConditions.WaitForAnimationToFinish(context) {
      if NPCPuppet.IsInCombat(AIBehaviorScriptBase.GetPuppet(context)) {
        return true;
      };
      return false;
    };
    if AIAutonomousConditions.HasCombatAICommand(context) {
      return true;
    };
    if ScriptedPuppet.IsPlayerCompanion(ScriptExecutionContext.GetOwner(context)) {
      if AIActionHelper.HasFollowerCombatAICommand(AIBehaviorScriptBase.GetPuppet(context)) {
        return true;
      };
      if !AIAutonomousConditions.IsPlayerInCombat(context) {
        return false;
      };
    } else {
      if !AIBehaviorScriptBase.GetPuppet(context).IsAggressive() {
        return false;
      };
    };
    if AIAutonomousConditions.HasHostileThreats(context) {
      return true;
    };
    return false;
  }

  public final static func NoWeaponCombatConditions(context: ScriptExecutionContext) -> Bool {
    if NotEquals(AIBehaviorScriptBase.GetPuppet(context).GetNPCType(), gamedataNPCType.Human) {
      return false;
    };
    if !AIAutonomousConditions.HasWeaponInInventory(context) {
      if AIAutonomousConditions.WaitForAnimationToFinish(context) {
        if NPCPuppet.IsInCombat(AIBehaviorScriptBase.GetPuppet(context)) {
          return true;
        };
        return false;
      };
      return true;
    };
    return false;
  }

  public final static func HasWeaponInInventory(context: ScriptExecutionContext) -> Bool {
    let itemID: ItemID;
    let weaponCategory: wref<ItemCategory_Record> = TweakDBInterface.GetItemCategoryRecord(t"ItemCategory.Weapon");
    if IsDefined(weaponCategory) && AIActionTransactionSystem.GetFirstItemID(ScriptExecutionContext.GetOwner(context), weaponCategory, n"", itemID) {
      return true;
    };
    return false;
  }
}

public class NoWeaponCombatConditions extends AIAutonomousConditions {

  protected func Check(context: ScriptExecutionContext) -> AIbehaviorConditionOutcomes {
    if AIAutonomousConditions.NoWeaponCombatConditions(context) {
      return Cast(true);
    };
    return Cast(false);
  }
}

public class CombatConditions extends AIAutonomousConditions {

  protected func Check(context: ScriptExecutionContext) -> AIbehaviorConditionOutcomes {
    if AIAutonomousConditions.CombatCondition(context) {
      return Cast(true);
    };
    AIComponent.InvokeBehaviorCallback(AIBehaviorScriptBase.GetPuppet(context), n"OnActiveCombatConditionFailed");
    return Cast(false);
  }
}

public class AlertedConditions extends AIAutonomousConditions {

  protected func Check(context: ScriptExecutionContext) -> AIbehaviorConditionOutcomes {
    return Cast(AIAutonomousConditions.AlertedCondition(context));
  }
}

public class PassiveNoWeaponCombatConditions extends PassiveAutonomousCondition {

  protected let m_delayEvaluationCbId: Uint32;

  protected let m_onItemAddedToSlotCbId: Uint32;

  protected final func Activate(context: ScriptExecutionContext) -> Void {
    this.m_delayEvaluationCbId = ScriptExecutionContext.AddBehaviorCallback(context, n"OnDelayPassiveConditionEvaluation", this);
    this.m_onItemAddedToSlotCbId = ScriptExecutionContext.AddBehaviorCallback(context, n"OnItemAddedToSlotConditionEvaluation", this);
  }

  protected final func Deactivate(context: ScriptExecutionContext) -> Void {
    ScriptExecutionContext.RemoveBehaviorCallback(context, this.m_delayEvaluationCbId);
    ScriptExecutionContext.RemoveBehaviorCallback(context, this.m_onItemAddedToSlotCbId);
  }

  protected final func CalculateValue(context: ScriptExecutionContext) -> Variant {
    if AIAutonomousConditions.NoWeaponCombatConditions(context) {
      return ToVariant(true);
    };
    return ToVariant(false);
  }
}

public class PassiveCombatConditions extends PassiveAutonomousCondition {

  protected let m_combatCommandCbId: Uint32;

  protected let m_roleCbId: Uint32;

  protected let m_threatCbId: Uint32;

  protected let m_playerCombatCbId: Uint32;

  protected let m_activeCombatConditionCbId: Uint32;

  protected let m_delayEvaluationCbId: Uint32;

  protected final func Activate(context: ScriptExecutionContext) -> Void {
    this.m_combatCommandCbId = ScriptExecutionContext.AddBehaviorCallback(context, n"OnCombatCommandChanged", this);
    this.m_roleCbId = ScriptExecutionContext.AddBehaviorCallback(context, n"OnAIRoleChanged", this);
    this.m_threatCbId = ScriptExecutionContext.AddBehaviorCallback(context, n"OnThreatsChanged", this);
    this.m_playerCombatCbId = ScriptExecutionContext.AddBehaviorCallback(context, n"OnPlayerCombatChanged", this);
    this.m_activeCombatConditionCbId = ScriptExecutionContext.AddBehaviorCallback(context, n"OnActiveCombatConditionFailed", this);
    this.m_delayEvaluationCbId = ScriptExecutionContext.AddBehaviorCallback(context, n"OnDelayPassiveConditionEvaluation", this);
  }

  protected final func Deactivate(context: ScriptExecutionContext) -> Void {
    ScriptExecutionContext.RemoveBehaviorCallback(context, this.m_combatCommandCbId);
    ScriptExecutionContext.RemoveBehaviorCallback(context, this.m_roleCbId);
    ScriptExecutionContext.RemoveBehaviorCallback(context, this.m_threatCbId);
    ScriptExecutionContext.RemoveBehaviorCallback(context, this.m_playerCombatCbId);
    ScriptExecutionContext.RemoveBehaviorCallback(context, this.m_activeCombatConditionCbId);
    ScriptExecutionContext.RemoveBehaviorCallback(context, this.m_delayEvaluationCbId);
  }

  protected final func CalculateValue(context: ScriptExecutionContext) -> Variant {
    return ToVariant(AIAutonomousConditions.CombatCondition(context));
  }
}

public class PassiveAlertedConditions extends PassiveAutonomousCondition {

  protected let m_highLevelCbId: Uint32;

  protected let m_delayEvaluationCbId: Uint32;

  protected final func Activate(context: ScriptExecutionContext) -> Void {
    this.m_highLevelCbId = ScriptExecutionContext.AddBehaviorCallback(context, n"OnHighLevelChanged", this);
    this.m_delayEvaluationCbId = ScriptExecutionContext.AddBehaviorCallback(context, n"OnDelayPassiveConditionEvaluation", this);
  }

  protected final func Deactivate(context: ScriptExecutionContext) -> Void {
    ScriptExecutionContext.RemoveBehaviorCallback(context, this.m_highLevelCbId);
    ScriptExecutionContext.RemoveBehaviorCallback(context, this.m_delayEvaluationCbId);
  }

  protected final func CalculateValue(context: ScriptExecutionContext) -> Variant {
    ScriptExecutionContext.DebugLog(context, n"autocond", "PassiveAlertedConditions calculated.");
    return ToVariant(AIAutonomousConditions.AlertedCondition(context));
  }
}

public class PassiveRoleCondition extends AIbehaviorexpressionScript {

  public edit let m_role: EAIRole;

  private let m_roleCbId: Uint32;

  protected final func Activate(context: ScriptExecutionContext) -> Void {
    this.m_roleCbId = ScriptExecutionContext.AddBehaviorCallback(context, n"OnAIRoleChanged", this);
  }

  protected final func Deactivate(context: ScriptExecutionContext) -> Void {
    ScriptExecutionContext.RemoveBehaviorCallback(context, this.m_roleCbId);
  }

  protected final func CalculateValue(context: ScriptExecutionContext) -> Variant {
    let role: ref<AIRole> = AIBehaviorScriptBase.GetAIComponent(context).GetAIRole();
    if IsDefined(role) && Equals(role.GetRoleEnum(), this.m_role) {
      return ToVariant(true);
    };
    return ToVariant(false);
  }

  public final func GetEditorSubCaption() -> String {
    return "Role " + ToString(this.m_role);
  }
}

public class PassiveCommandCondition extends AIbehaviorexpressionScript {

  public edit let m_commandName: CName;

  @default(PassiveCommandCondition, true)
  public edit let m_useInheritance: Bool;

  private let m_cmdCbId: Uint32;

  protected final func Activate(context: ScriptExecutionContext) -> Void {
    this.m_cmdCbId = ScriptExecutionContext.AddBehaviorCallback(context, n"OnCommandStateChanged", this);
  }

  protected final func Deactivate(context: ScriptExecutionContext) -> Void {
    ScriptExecutionContext.RemoveBehaviorCallback(context, this.m_cmdCbId);
  }

  protected final func CalculateValue(context: ScriptExecutionContext) -> Variant {
    let aiComp: ref<AIHumanComponent> = AIBehaviorScriptBase.GetAIComponent(context);
    return ToVariant(aiComp.IsCommandWaiting(this.m_commandName, this.m_useInheritance) || aiComp.IsCommandExecuting(this.m_commandName, this.m_useInheritance));
  }

  public final func GetEditorSubCaption() -> String {
    return "CMD " + ToString(this.m_commandName);
  }
}

public class PassivePatrolConditions extends PassiveAutonomousCondition {

  private let m_roleCbId: Uint32;

  private let m_cmdCbId: Uint32;

  protected final func Activate(context: ScriptExecutionContext) -> Void {
    this.m_roleCbId = ScriptExecutionContext.AddBehaviorCallback(context, n"OnAIRoleChanged", this);
    this.m_cmdCbId = ScriptExecutionContext.AddBehaviorCallback(context, n"OnCommandStateChanged", this);
  }

  protected final func Deactivate(context: ScriptExecutionContext) -> Void {
    ScriptExecutionContext.RemoveBehaviorCallback(context, this.m_roleCbId);
    ScriptExecutionContext.RemoveBehaviorCallback(context, this.m_cmdCbId);
  }

  protected final func CalculateValue(context: ScriptExecutionContext) -> Variant {
    let role: ref<AIRole>;
    let aiComp: ref<AIHumanComponent> = AIBehaviorScriptBase.GetAIComponent(context);
    if aiComp.IsCommandExecuting(n"AIPatrolCommand", true) || aiComp.IsCommandWaiting(n"AIPatrolCommand", true) {
      return ToVariant(true);
    };
    role = aiComp.GetAIRole();
    if IsDefined(role) && Equals(role.GetRoleEnum(), EAIRole.Patrol) {
      return ToVariant(true);
    };
    return ToVariant(false);
  }
}

public class PassiveCoverSelectionConditions extends PassiveAutonomousCondition {

  private let m_statsChangedCbId: Uint32;

  private let m_ability: wref<GameplayAbility_Record>;

  private let m_statListener: ref<AIStatListener>;

  protected final func Activate(context: ScriptExecutionContext) -> Void {
    this.m_ability = TweakDBInterface.GetGameplayAbilityRecord(t"Ability.CanUseCovers");
    this.m_statsChangedCbId = ScriptExecutionContext.AddBehaviorCallback(context, n"OnUseCoverStatChanged", this);
    this.m_statListener = new AIStatListener();
    this.m_statListener.SetInitData(AIBehaviorScriptBase.GetPuppet(context), n"OnUseCoverStatChanged");
    this.m_statListener.SetStatType(gamedataStatType.CanUseCovers);
    GameInstance.GetStatsSystem(ScriptExecutionContext.GetOwner(context).GetGame()).RegisterListener(Cast(ScriptExecutionContext.GetOwner(context).GetEntityID()), this.m_statListener);
  }

  protected final func Deactivate(context: ScriptExecutionContext) -> Void {
    if IsDefined(this.m_statListener) {
      GameInstance.GetStatsSystem(ScriptExecutionContext.GetOwner(context).GetGame()).UnregisterListener(Cast(ScriptExecutionContext.GetOwner(context).GetEntityID()), this.m_statListener);
      this.m_statListener = null;
    };
    ScriptExecutionContext.RemoveBehaviorCallback(context, this.m_statsChangedCbId);
  }

  protected final func CalculateValue(context: ScriptExecutionContext) -> Variant {
    if !IsDefined(this.m_ability) {
      return ToVariant(false);
    };
    if !AICondition.CheckAbility(context, this.m_ability) {
      return ToVariant(false);
    };
    return ToVariant(true);
  }
}

public class AIStatListener extends ScriptStatsListener {

  private let m_owner: wref<ScriptedPuppet>;

  private let m_behaviorCallbackName: CName;

  public final func SetInitData(owner: wref<ScriptedPuppet>, behaviorCallbackName: CName) -> Void {
    this.m_owner = owner;
  }

  public func OnStatChanged(ownerID: StatsObjectID, statType: gamedataStatType, diff: Float, total: Float) -> Void {
    AIComponent.InvokeBehaviorCallback(this.m_owner, n"OnUseCoverStatChanged");
  }
}

public class IsConnectedToSecuritySystem extends AIAutonomousConditions {

  protected func Check(context: ScriptExecutionContext) -> AIbehaviorConditionOutcomes {
    if AIBehaviorScriptBase.GetPuppet(context).IsConnectedToSecuritySystem() {
      return Cast(true);
    };
    return Cast(false);
  }
}

public class IsReprimandOngoing extends AIAutonomousConditions {

  protected func Check(context: ScriptExecutionContext) -> AIbehaviorConditionOutcomes {
    let puppet: ref<ScriptedPuppet> = AIBehaviorScriptBase.GetPuppet(context);
    let secSys: ref<SecuritySystemControllerPS> = puppet.GetSecuritySystem();
    if !secSys.IsReprimandOngoing() {
      return Cast(false);
    };
    if puppet.GetSecuritySystem().GetReprimandPerformer() == puppet.GetDeviceLink() {
      return Cast(false);
    };
    if NotEquals((puppet.GetSecuritySystem().GetReprimandPerformer() as ScriptedPuppet).GetHighLevelStateFromBlackboard(), gamedataNPCHighLevelState.Relaxed) {
      return Cast(false);
    };
    return Cast(true);
  }
}

public class IsTargetObjectPlayer extends AIbehaviorconditionScript {

  protected inline edit let m_targetObject: ref<AIArgumentMapping>;

  protected func Check(context: ScriptExecutionContext) -> AIbehaviorConditionOutcomes {
    let targetObject: wref<GameObject> = FromVariant(ScriptExecutionContext.GetMappingValue(context, this.m_targetObject));
    if IsDefined(targetObject) && targetObject.IsPlayer() {
      return Cast(true);
    };
    return Cast(false);
  }
}

public class IsBoss extends AIbehaviorconditionScript {

  protected func Check(context: ScriptExecutionContext) -> AIbehaviorConditionOutcomes {
    if AIBehaviorScriptBase.GetPuppet(context).IsBoss() {
      return Cast(true);
    };
    return Cast(false);
  }
}

public class IsAggressive extends AIbehaviorconditionScript {

  protected func Check(context: ScriptExecutionContext) -> AIbehaviorConditionOutcomes {
    if AIBehaviorScriptBase.GetPuppet(context).IsAggressive() {
      return Cast(true);
    };
    return Cast(false);
  }
}

public class PassiveCannotMoveConditions extends PassiveAutonomousCondition {

  protected let m_statusEffectRemovedId: Uint32;

  protected final func Activate(context: ScriptExecutionContext) -> Void {
    this.m_statusEffectRemovedId = ScriptExecutionContext.AddBehaviorCallback(context, n"OnStatusEffectRemoved", this);
  }

  protected final func Deactivate(context: ScriptExecutionContext) -> Void {
    ScriptExecutionContext.RemoveBehaviorCallback(context, this.m_statusEffectRemovedId);
  }

  protected final func CalculateValue(context: ScriptExecutionContext) -> Variant {
    if StatusEffectSystem.ObjectHasStatusEffectWithTag(ScriptExecutionContext.GetOwner(context), n"LocomotionMalfunction") {
      return ToVariant(true);
    };
    return ToVariant(false);
  }
}
