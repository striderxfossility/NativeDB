
public class SimpleCombatConditon extends AIbehaviorconditionScript {

  public let m_firstCoverEvaluationDone: Bool;

  public let m_takeCoverAbility: ref<GameplayAbility_Record>;

  public let m_quickhackAbility: ref<GameplayAbility_Record>;

  protected func Activate(context: ScriptExecutionContext) -> Void {
    this.m_takeCoverAbility = TweakDBInterface.GetGameplayAbilityRecord(t"Ability.CanUseCovers");
    this.m_quickhackAbility = TweakDBInterface.GetGameplayAbilityRecord(t"Ability.CanQuickhack");
  }

  protected func Check(context: ScriptExecutionContext) -> AIbehaviorConditionOutcomes {
    let activeCommandCount: Int32;
    let aiComponent: ref<AIHumanComponent>;
    let distanceSqr: Float;
    let i: Int32;
    let membersCount: Int32;
    let playerPos: Vector4;
    let squadInterface: wref<SquadScriptInterface>;
    let squadMatesInSimpleCombat: Int32;
    let squadMember: ref<ScriptedPuppet>;
    let squadMembers: array<wref<Entity>>;
    let puppet: ref<ScriptedPuppet> = AIBehaviorScriptBase.GetPuppet(context);
    let minDistSqr1: Float = 999999.00;
    let minDistSqr2: Float = 999999.00;
    let minDist1Index: Int32 = -1;
    let minDist2Index: Int32 = -1;
    let player: ref<GameObject> = GameInstance.GetPlayerSystem(ScriptExecutionContext.GetOwner(context).GetGame()).GetLocalPlayerControlledGameObject();
    if !IsDefined(player) {
      return Cast(true);
    };
    if !puppet.IsActive() {
      return Cast(false);
    };
    if ScriptedPuppet.IsPlayerCompanion(puppet) {
      return Cast(false);
    };
    if this.AnimationInProgress(puppet) {
      return Cast(false);
    };
    if AIActionHelper.CheckAbility(puppet, this.m_takeCoverAbility) {
      if !this.m_firstCoverEvaluationDone && AICoverHelper.GetCoverBlackboard(puppet).GetBool(GetAllBlackboardDefs().AICover.firstCoverEvaluationDone) {
        this.m_firstCoverEvaluationDone = true;
      };
      if !this.m_firstCoverEvaluationDone {
        return Cast(false);
      };
      if SimpleCombatConditon.HasAvailableCover(context) && !AICoverHelper.IsCurrentlyInSmartObject(puppet) {
        return Cast(false);
      };
      if AIActionHelper.IsCurrentlyInCoverAttackAction(puppet) {
        return Cast(false);
      };
    };
    if AIActionHelper.CheckAbility(puppet, this.m_quickhackAbility) {
      return Cast(false);
    };
    aiComponent = puppet.GetAIControllerComponent();
    if IsDefined(aiComponent) {
      if aiComponent.IsCommandActive(n"AICommand") {
        activeCommandCount = aiComponent.GetActiveCommandsCount();
        if aiComponent.IsCommandActive(n"AIInjectCombatTargetCommand") {
          activeCommandCount -= 1;
        };
        if aiComponent.IsCommandActive(n"AIInjectCombatThreatCommand") {
          activeCommandCount -= 1;
        };
        if activeCommandCount > 0 {
          return Cast(false);
        };
      };
    };
    squadInterface = puppet.GetSquadMemberComponent().MySquad(AISquadType.Combat);
    if !IsDefined(squadInterface) {
      return Cast(true);
    };
    squadMembers = squadInterface.ListMembersWeak();
    playerPos = player.GetWorldPosition();
    membersCount = ArraySize(squadMembers);
    i = 0;
    while i < membersCount {
      squadMember = squadMembers[i] as ScriptedPuppet;
      if !IsDefined(squadMember) {
      } else {
        if AIScriptSquad.HasOrder(squadMember, n"SimpleCombat") {
          squadMatesInSimpleCombat += 1;
        };
        distanceSqr = Vector4.DistanceSquared(squadMembers[i].GetWorldPosition(), playerPos);
        if distanceSqr < minDistSqr2 {
          if distanceSqr < minDistSqr1 {
            minDistSqr1 = distanceSqr;
            minDist1Index = i;
          } else {
            minDistSqr2 = distanceSqr;
            minDist2Index = i;
          };
        };
      };
      i += 1;
    };
    if minDist1Index >= 0 && squadMembers[minDist1Index] == puppet || minDist2Index >= 0 && squadMembers[minDist2Index] == puppet {
      return Cast(false);
    };
    if membersCount - squadMatesInSimpleCombat < 3 && !AIScriptSquad.HasOrder(puppet, n"SimpleCombat") {
      return Cast(false);
    };
    return Cast(true);
  }

  private final func AnimationInProgress(puppet: wref<ScriptedPuppet>) -> Bool {
    if puppet.GetMovePolicesComponent().IsOnOffMeshLink() {
      return true;
    };
    if GameInstance.GetCoverManager(puppet.GetGame()).IsEnteringOrLeavingCover(puppet) {
      return true;
    };
    return false;
  }

  public final static func HasAvailableCover(const context: ScriptExecutionContext) -> Bool {
    let currentRing: gamedataAIRingType;
    let i: Int32;
    let msc: wref<MultiSelectCovers>;
    let puppet: wref<ScriptedPuppet> = ScriptExecutionContext.GetOwner(context) as ScriptedPuppet;
    if !IsDefined(puppet) {
      return false;
    };
    msc = ScriptExecutionContext.GetArgumentScriptable(context, n"MultiCoverID") as MultiSelectCovers;
    if !IsDefined(msc) {
      return false;
    };
    currentRing = AISquadHelper.GetCurrentSquadRing(ScriptExecutionContext.GetOwner(context) as ScriptedPuppet);
    if Equals(currentRing, gamedataAIRingType.Invalid) {
      return true;
    };
    i = 0;
    while i < ArraySize(msc.selectedCovers) {
      if !msc.coversUseLOS[i] {
      } else {
        if NotEquals(currentRing, msc.coverRingTypes[i]) {
        } else {
          if msc.selectedCovers[i] > 0u {
            return true;
          };
        };
      };
      i += 1;
    };
    return false;
  }
}
