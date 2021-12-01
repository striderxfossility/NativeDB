
public native class AIRole extends IScriptable {

  public final native func GetRoleTweakRecord() -> ref<AIRole_Record>;

  public const func GetRoleEnum() -> EAIRole {
    return IntEnum(0l);
  }

  public const func GetTweakRecordId() -> TweakDBID {
    return TDBID.undefined();
  }

  public func OnRoleSet(owner: wref<GameObject>) -> Void;

  public func OnRoleCleared(owner: wref<GameObject>) -> Void;

  public func OnHighLevelStateEnter(owner: wref<GameObject>, newState: gamedataNPCHighLevelState, previousState: gamedataNPCHighLevelState) -> Void;

  public func OnHighLevelStateExit(owner: wref<GameObject>, leftState: gamedataNPCHighLevelState, nextState: gamedataNPCHighLevelState) -> Void;
}

public native class AIPatrolRole extends AIRole {

  protected inline edit persistent let pathParams: ref<AIPatrolPathParameters>;

  protected inline edit persistent let alertedPathParams: ref<AIPatrolPathParameters>;

  protected inline edit persistent let alertedRadius: Float;

  protected inline edit persistent let alertedSpots: ref<WorkspotList>;

  protected inline edit persistent let forceAlerted: Bool;

  public final const func GetPathParams() -> ref<AIPatrolPathParameters> {
    return this.pathParams;
  }

  public final const func GetAlertedPathParams() -> ref<AIPatrolPathParameters> {
    return this.alertedPathParams;
  }

  public final const func GetAlertedRadius() -> Float {
    return this.alertedRadius;
  }

  public final const func IsForceAlerted() -> Bool {
    return this.forceAlerted;
  }

  public final const func GetAlertedSpots() -> ref<WorkspotList> {
    return this.alertedSpots;
  }

  public const func GetRoleEnum() -> EAIRole {
    return EAIRole.Patrol;
  }

  public const func GetTweakRecordId() -> TweakDBID {
    return t"AIRole.Patrol";
  }

  public func OnRoleSet(owner: wref<GameObject>) -> Void {
    (owner as ScriptedPuppet).GetAIControllerComponent().GetAIPatrolBlackboard().SetBool(GetAllBlackboardDefs().AIPatrol.forceAlerted, this.forceAlerted);
  }
}

public class PatrolRoleCommandDelegate extends ScriptBehaviorDelegate {

  public let patrolWithWeapon: Bool;

  public let forceAlerted: Bool;

  public final func ResetVariables(context: ScriptExecutionContext) -> Bool {
    this.patrolWithWeapon = false;
    this.forceAlerted = false;
    return true;
  }

  public final func IsPatrolWithWeapon(context: ScriptExecutionContext) -> Bool {
    return (ScriptExecutionContext.GetOwner(context) as ScriptedPuppet).GetAIControllerComponent().GetAIPatrolBlackboard().GetBool(GetAllBlackboardDefs().AIPatrol.patrolWithWeapon);
  }

  public final func IsForceAlerted(context: ScriptExecutionContext) -> Bool {
    return (ScriptExecutionContext.GetOwner(context) as ScriptedPuppet).GetAIControllerComponent().GetAIPatrolBlackboard().GetBool(GetAllBlackboardDefs().AIPatrol.forceAlerted);
  }
}

public class FriendlyTargetWeaponChangeCallback extends AttachmentSlotsScriptCallback {

  public let m_followerRole: ref<AIFollowerRole>;

  public func OnItemEquipped(slotIDArg: TweakDBID, itemIDArg: ItemID) -> Void {
    this.slotID = slotIDArg;
    this.m_followerRole.OnFriendlyTargetWeaponChange(itemIDArg);
  }
}

public class OwnerWeaponChangeCallback extends AttachmentSlotsScriptCallback {

  public let m_followerRole: ref<AIFollowerRole>;

  public func OnItemEquipped(slotIDArg: TweakDBID, itemIDArg: ItemID) -> Void {
    this.slotID = slotIDArg;
  }
}

public class AIFollowerRole extends AIRole {

  @attrib(customEditor, "scnbPerformerSelector")
  protected edit persistent let followerRef: EntityReference;

  private let m_followTarget: wref<GameObject>;

  private let m_owner: wref<GameObject>;

  private persistent let attitudeGroupName: CName;

  private persistent let m_followTargetSquads: array<CName>;

  private let m_playerCombatListener: ref<CallbackHandle>;

  private let m_lastStealthLeaveTimeStamp: EngineTime;

  private let m_friendlyTargetSlotListener: ref<AttachmentSlotsScriptListener>;

  private let m_ownerTargetSlotListener: ref<AttachmentSlotsScriptListener>;

  private let m_isFriendMelee: Bool;

  private let m_isOwnerSniper: Bool;

  public final func OnFriendlyTargetWeaponChange(itemID: ItemID) -> Void {
    let itemRecord: ref<Item_Record> = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(itemID));
    this.m_isFriendMelee = itemRecord.TagsContains(WeaponObject.GetMeleeWeaponTag());
    this.UpdateSpatialsMultiplier();
  }

  public final func OnOwnerWeaponChange(itemID: ItemID) -> Void {
    let itemRecord: ref<Item_Record> = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(itemID));
    this.m_isOwnerSniper = Equals(itemRecord.ItemType().Type(), gamedataItemType.Wea_SniperRifle);
    this.UpdateSpatialsMultiplier();
  }

  private final func UpdateSpatialsMultiplier() -> Void {
    if Equals((this.m_owner as NPCPuppet).GetHighLevelStateFromBlackboard(), gamedataNPCHighLevelState.Combat) && (this.m_isFriendMelee || this.m_isOwnerSniper) {
      (this.m_owner as NPCPuppet).GetAIControllerComponent().SetCombatSpaceSizeMultiplier(2.00);
    } else {
      (this.m_owner as NPCPuppet).GetAIControllerComponent().SetCombatSpaceSizeMultiplier(1.00);
    };
  }

  public final const func GetFollowerRef() -> EntityReference {
    return this.followerRef;
  }

  private final const func FindFollowTarget(owner: wref<GameObject>, out followTarget: wref<GameObject>) -> Bool {
    if !GetGameObjectFromEntityReference(this.GetFollowerRef(), owner.GetGame(), followTarget) {
      return false;
    };
    return true;
  }

  public const func GetRoleEnum() -> EAIRole {
    return EAIRole.Follower;
  }

  public const func GetTweakRecordId() -> TweakDBID {
    return t"AIRole.Follower";
  }

  public func OnRoleSet(owner: wref<GameObject>) -> Void {
    let currentHighLevelState: gamedataNPCHighLevelState;
    let friendlyTargetweaponChangeListener: ref<FriendlyTargetWeaponChangeCallback>;
    let ownAttitudeAgent: ref<AttitudeAgent>;
    let ownerWeaponChangeListener: ref<OwnerWeaponChangeCallback>;
    let potentialTarget: wref<GameObject>;
    this.m_owner = owner;
    let ownerNPC: ref<NPCPuppet> = owner as NPCPuppet;
    if !IsDefined(ownerNPC) {
      return;
    };
    ownAttitudeAgent = owner.GetAttitudeAgent();
    if !IsDefined(ownAttitudeAgent) {
      return;
    };
    ownAttitudeAgent = owner.GetAttitudeAgent();
    this.attitudeGroupName = ownAttitudeAgent.GetAttitudeGroup();
    if NotEquals(ownerNPC.GetHighLevelStateFromBlackboard(), gamedataNPCHighLevelState.Combat) {
      SenseComponent.RequestMainPresetChange(owner, "Follower");
    };
    this.FindFollowTarget(owner, potentialTarget);
    if !IsDefined(potentialTarget) {
      return;
    };
    this.m_followTarget = potentialTarget;
    (owner as ScriptedPuppet).GetAIControllerComponent().SetBehaviorArgument(n"FriendlyTarget", ToVariant(this.m_followTarget));
    this.ChangeAttitude(owner, ownAttitudeAgent, this.m_followTarget);
    this.JoinFollowTargetSquads(owner as ScriptedPuppet);
    this.RegisterToPlayerCombat(owner as ScriptedPuppet, this.m_followTarget as PlayerPuppet);
    (owner as ScriptedPuppet).GetTargetTrackerComponent().SetCurrentPreset(t"TargetTracking.FollowerPreset");
    currentHighLevelState = IntEnum((owner as ScriptedPuppet).GetPuppetStateBlackboard().GetInt(GetAllBlackboardDefs().PuppetState.HighLevel));
    if Equals(currentHighLevelState, gamedataNPCHighLevelState.Combat) {
      ((owner as ScriptedPuppet).GetTargetTrackerComponent() as TargetTrackingExtension).RemoveHostileCamerasFromThreats();
      (owner as ScriptedPuppet).GetSensesComponent().RemoveForcedSensesTracing(gamedataSenseObjectType.Camera, EAIAttitude.AIA_Hostile);
    } else {
      (owner as ScriptedPuppet).GetSensesComponent().SetForcedSensesTracing(gamedataSenseObjectType.Camera, EAIAttitude.AIA_Hostile);
    };
    friendlyTargetweaponChangeListener = new FriendlyTargetWeaponChangeCallback();
    friendlyTargetweaponChangeListener.slotID = t"AttachmentSlots.WeaponRight";
    friendlyTargetweaponChangeListener.m_followerRole = this;
    this.m_friendlyTargetSlotListener = GameInstance.GetTransactionSystem((owner as ScriptedPuppet).GetGame()).RegisterAttachmentSlotListener(this.m_followTarget, friendlyTargetweaponChangeListener);
    ownerWeaponChangeListener = new OwnerWeaponChangeCallback();
    ownerWeaponChangeListener.slotID = t"AttachmentSlots.WeaponRight";
    ownerWeaponChangeListener.m_followerRole = this;
    this.m_ownerTargetSlotListener = GameInstance.GetTransactionSystem((owner as ScriptedPuppet).GetGame()).RegisterAttachmentSlotListener(this.m_owner, ownerWeaponChangeListener);
    this.OnFriendlyTargetWeaponChange(GameInstance.GetTransactionSystem((owner as ScriptedPuppet).GetGame()).GetItemInSlot(this.m_followTarget, t"AttachmentSlots.WeaponRight").GetItemID());
    this.OnOwnerWeaponChange(GameInstance.GetTransactionSystem((owner as ScriptedPuppet).GetGame()).GetItemInSlot(owner, t"AttachmentSlots.WeaponRight").GetItemID());
  }

  public func OnRoleCleared(owner: wref<GameObject>) -> Void {
    let characterRecord: wref<Character_Record>;
    let currentHighLevelState: gamedataNPCHighLevelState;
    let ownAttitudeAgent: ref<AttitudeAgent>;
    if !IsDefined(owner) {
      return;
    };
    (owner as ScriptedPuppet).GetAIControllerComponent().SetBehaviorArgument(n"FriendlyTarget", ToVariant(null));
    ownAttitudeAgent = owner.GetAttitudeAgent();
    if IsDefined(ownAttitudeAgent) && IsNameValid(this.attitudeGroupName) {
      ownAttitudeAgent.SetAttitudeGroup(this.attitudeGroupName);
    };
    if !IsDefined(this.GetFollowTarget()) {
      if !this.FindFollowTarget(owner, this.m_followTarget) {
        return;
      };
    };
    this.LeaveFollowTargetSquads(owner as ScriptedPuppet);
    this.UnregisterToPlayerCombat(owner as ScriptedPuppet, this.m_followTarget as PlayerPuppet);
    characterRecord = TweakDBInterface.GetCharacterRecord((owner as ScriptedPuppet).GetRecordID());
    if IsDefined(characterRecord) {
      (owner as ScriptedPuppet).GetTargetTrackerComponent().SetCurrentPreset(characterRecord.ThreatTrackingPreset().GetID());
    };
    if Equals(currentHighLevelState, gamedataNPCHighLevelState.Combat) {
      (owner as ScriptedPuppet).GetSensesComponent().SetForcedSensesTracing(gamedataSenseObjectType.Camera, EAIAttitude.AIA_Hostile);
    } else {
      ((owner as ScriptedPuppet).GetTargetTrackerComponent() as TargetTrackingExtension).RemoveHostileCamerasFromThreats();
      (owner as ScriptedPuppet).GetSensesComponent().RemoveForcedSensesTracing(gamedataSenseObjectType.Camera, EAIAttitude.AIA_Hostile);
    };
    GameInstance.GetTransactionSystem((owner as ScriptedPuppet).GetGame()).UnregisterAttachmentSlotListener(this.m_owner, this.m_ownerTargetSlotListener);
    GameInstance.GetTransactionSystem((owner as ScriptedPuppet).GetGame()).UnregisterAttachmentSlotListener(this.m_followTarget, this.m_friendlyTargetSlotListener);
    (this.m_owner as NPCPuppet).GetAIControllerComponent().SetCombatSpaceSizeMultiplier(1.00);
    StatusEffectHelper.RemoveStatusEffect(this.m_owner, t"BaseStatusEffect.FollowerDefeated");
    this.m_followTarget = null;
    this.m_owner = null;
  }

  private final func ChangeAttitude(owner: wref<GameObject>, ownAttitudeAgent: ref<AttitudeAgent>, followTarget: wref<GameObject>) -> Bool {
    let targetAttitudeAgent: ref<AttitudeAgent>;
    if !IsDefined(owner) || !IsDefined(ownAttitudeAgent) || !IsDefined(followTarget) {
      return false;
    };
    targetAttitudeAgent = followTarget.GetAttitudeAgent();
    if !IsDefined(targetAttitudeAgent) {
      return false;
    };
    ownAttitudeAgent.SetAttitudeGroup(targetAttitudeAgent.GetAttitudeGroup());
    return true;
  }

  private final func RegisterToPlayerCombat(owner: wref<ScriptedPuppet>, player: wref<PlayerPuppet>) -> Void {
    let bb: ref<IBlackboard>;
    if !IsDefined(owner) || !IsDefined(player) || !IsDefined(owner.GetAIControllerComponent()) {
      return;
    };
    bb = GameInstance.GetBlackboardSystem(owner.GetGame()).GetLocalInstanced(player.GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
    this.m_playerCombatListener = bb.RegisterListenerInt(GetAllBlackboardDefs().PlayerStateMachine.Combat, owner.GetAIControllerComponent(), n"OnPlayerCombatChanged");
  }

  private final func UnregisterToPlayerCombat(owner: wref<ScriptedPuppet>, player: wref<PlayerPuppet>) -> Void {
    let bb: ref<IBlackboard>;
    if !IsDefined(owner) || !IsDefined(player) || !IsDefined(this.m_playerCombatListener) {
      return;
    };
    bb = GameInstance.GetBlackboardSystem(owner.GetGame()).GetLocalInstanced(player.GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
    bb.UnregisterListenerInt(GetAllBlackboardDefs().PlayerStateMachine.Combat, this.m_playerCombatListener);
  }

  private final func JoinFollowTargetSquads(owner: wref<ScriptedPuppet>) -> Void {
    let squadsToJoin: array<ref<SquadScriptInterface>> = AISquadHelper.GetAllSquadMemberInterfaces(this.m_followTarget as ScriptedPuppet);
    let mySquads: array<CName> = owner.GetSquadMemberComponent().MySquadsNames();
    let i: Int32 = 0;
    while i < ArraySize(squadsToJoin) {
      if !ArrayContains(mySquads, squadsToJoin[i].GetName()) {
        ArrayPush(this.m_followTargetSquads, squadsToJoin[i].GetName());
        squadsToJoin[i].Join(owner);
      };
      i += 1;
    };
  }

  private final func LeaveFollowTargetSquads(owner: wref<ScriptedPuppet>) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_followTargetSquads) {
      owner.GetSquadMemberComponent().FindSquad(this.m_followTargetSquads[i]).Leave(owner);
      i += 1;
    };
    ArrayClear(this.m_followTargetSquads);
  }

  public final func SetFollowTarget(followTarget: wref<GameObject>) -> Void {
    this.m_followTarget = followTarget;
  }

  public final func GetFollowTarget() -> wref<GameObject> {
    return this.m_followTarget;
  }

  public func OnHighLevelStateEnter(owner: wref<GameObject>, newState: gamedataNPCHighLevelState, previousState: gamedataNPCHighLevelState) -> Void {
    switch newState {
      case gamedataNPCHighLevelState.Relaxed:
        break;
      case gamedataNPCHighLevelState.Alerted:
        break;
      case gamedataNPCHighLevelState.Combat:
        GameObject.PlayVoiceOver(owner, n"danger", n"Scripts:OnHighLevelStateEnter");
        ((owner as ScriptedPuppet).GetTargetTrackerComponent() as TargetTrackingExtension).RemoveHostileCamerasFromThreats();
        (owner as ScriptedPuppet).GetSensesComponent().RemoveForcedSensesTracing(gamedataSenseObjectType.Camera, EAIAttitude.AIA_Hostile);
        break;
      case gamedataNPCHighLevelState.Stealth:
        if !TargetTrackingExtension.HasHostileThreat(owner as ScriptedPuppet) {
        } else {
          if Equals(previousState, gamedataNPCHighLevelState.Combat) {
            GameObject.PlayVoiceOver(owner, n"stealth_restored", n"Scripts:OnHighLevelStateEnter");
          } else {
            if GameInstance.GetTimeSystem(owner.GetGame()).GetSimTime() > (this.m_followTarget as PlayerPuppet).GetCombatExitTimestamp() + 45.00 {
              GameObject.PlayVoiceOver(owner, n"enemy_warning", n"Scripts:OnHighLevelStateEnter");
            };
          };
          goto 719;
        };
      case gamedataNPCHighLevelState.Dead:
        break;
      case gamedataNPCHighLevelState.Fear:
        break;
      default:
    };
    if Equals(previousState, gamedataNPCHighLevelState.Stealth) {
      this.m_lastStealthLeaveTimeStamp = GameInstance.GetTimeSystem(owner.GetGame()).GetSimTime();
    };
    this.UpdateSpatialsMultiplier();
  }

  public func OnHighLevelStateExit(owner: wref<GameObject>, leftState: gamedataNPCHighLevelState, nextState: gamedataNPCHighLevelState) -> Void {
    let VODelay: Float;
    let distanceToFriend: Float;
    let maxDistance: Float = 30.00;
    switch leftState {
      case gamedataNPCHighLevelState.Relaxed:
        break;
      case gamedataNPCHighLevelState.Alerted:
        break;
      case gamedataNPCHighLevelState.Combat:
        distanceToFriend = Vector4.Distance(this.GetFollowTarget().GetWorldPosition(), owner.GetWorldPosition());
        VODelay = 1.00 + ClampF(distanceToFriend / maxDistance, 0.00, 1.00) * 4.00;
        GameObject.PlayVoiceOver(owner, n"combat_ended", n"Scripts:OnHighLevelStateExit", VODelay);
        (owner as ScriptedPuppet).GetSensesComponent().SetForcedSensesTracing(gamedataSenseObjectType.Camera, EAIAttitude.AIA_Hostile);
        break;
      case gamedataNPCHighLevelState.Stealth:
        break;
      case gamedataNPCHighLevelState.Dead:
        break;
      case gamedataNPCHighLevelState.Fear:
        break;
      default:
    };
  }
}

public class AIRoleCondition extends AIbehaviorconditionScript {

  public edit let m_role: EAIRole;

  protected func Check(context: ScriptExecutionContext) -> AIbehaviorConditionOutcomes {
    let currentRole: EAIRole;
    let roleClass: ref<AIRole>;
    let aiComponent: ref<AIHumanComponent> = AIBehaviorScriptBase.GetAIComponent(context);
    if !IsDefined(aiComponent) {
      return Cast(false);
    };
    roleClass = aiComponent.GetCurrentRole();
    if !IsDefined(roleClass) {
      return Cast(false);
    };
    currentRole = roleClass.GetRoleEnum();
    if NotEquals(currentRole, this.m_role) {
      return Cast(false);
    };
    return Cast(true);
  }
}

public class AIAssignRoleTask extends AIbehaviortaskScript {

  public inline edit let m_inCommand: ref<AIArgumentMapping>;

  protected func Update(context: ScriptExecutionContext) -> AIbehaviorUpdateOutcome {
    let aiComponent: ref<AIHumanComponent>;
    let assignRoleCommand: ref<AIAssignRoleCommand>;
    let rawCommand: ref<IScriptable>;
    if !IsDefined(this.m_inCommand) {
      return AIbehaviorUpdateOutcome.FAILURE;
    };
    rawCommand = ScriptExecutionContext.GetScriptableMappingValue(context, this.m_inCommand);
    assignRoleCommand = rawCommand as AIAssignRoleCommand;
    if !IsDefined(assignRoleCommand) {
      return AIbehaviorUpdateOutcome.FAILURE;
    };
    if !IsDefined(assignRoleCommand.role) {
      return AIbehaviorUpdateOutcome.FAILURE;
    };
    aiComponent = AIBehaviorScriptBase.GetAIComponent(context);
    if !IsDefined(aiComponent) {
      return AIbehaviorUpdateOutcome.FAILURE;
    };
    AIHumanComponent.SetCurrentRole(ScriptExecutionContext.GetOwner(context), assignRoleCommand.role);
    return AIbehaviorUpdateOutcome.SUCCESS;
  }
}
