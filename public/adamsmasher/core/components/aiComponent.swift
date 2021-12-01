
public native class AIComponent extends GameComponent {

  public final native func SetBehaviorArgument(n: CName, nv: Variant) -> Void;

  public final native const func GetBehaviorArgument(n: CName) -> Variant;

  public final native const func GetFriendlyFireSystem() -> ref<IFriendlyFireSystem>;

  public final native const func GetLoSFinderSystem() -> ref<ILoSFinderSystem>;

  public final native const func GetSignals() -> ref<gameBoolSignalTable>;

  public final native func SendCommand(cmd: ref<AICommand>) -> Bool;

  public final native func CancelCommand(cmd: ref<AICommand>) -> Bool;

  public final native func CancelCommandById(cmdId: Uint32, opt doNotRepeat: Bool) -> Bool;

  public final native func StartExecutingCommand(cmd: ref<AICommand>) -> Bool;

  public final native func StopExecutingCommand(cmd: ref<AICommand>, success: Bool) -> Bool;

  public final native const func IsCommandExecuting(commandName: CName, useInheritance: Bool) -> Bool;

  public final native const func IsCommandWaiting(commandName: CName, useInheritance: Bool) -> Bool;

  public final native const func GetCommandState(cmd: ref<AICommand>) -> AICommandState;

  public final native const func DebugLog(category: CName, message: String) -> Void;

  public final native const func GetHighLevelState() -> gamedataNPCHighLevelState;

  public final native const func GetAIRole() -> ref<AIRole>;

  public final native const func SetAIRole(role: ref<AIRole>) -> Void;

  public final native const func InvokeBehaviorCallback(cbName: CName) -> Void;

  public final native const func GetLOD() -> Int32;

  public final native const func GetStoryTier() -> gameStoryTier;

  public final native func SetCombatSpaceSize(combatSpaceSize: AICombatSpaceSize) -> Void;

  public final native const func GetCombatSpaceSize() -> AICombatSpaceSize;

  public final native func SetCombatSpaceSizeMultiplier(multiplier: Float) -> Void;

  public final native const func GetCombatSpaceSizeMultiplier() -> Float;

  public final native const func GetUpdateTickCount() -> Uint32;

  public final native func ForceTickNextFrame() -> Void;

  public final native func EnableCollider() -> Void;

  public final native func DisableCollider() -> Void;

  public final native func GetOrCreateBlackboard(definition: ref<BlackboardDefinition>, cache: script_ref<wref<IBlackboard>>) -> ref<IBlackboard>;

  public final func GetCurrentReactionPreset() -> wref<ReactionPreset_Record> {
    return (this.GetEntity() as ScriptedPuppet).GetStimReactionComponent().GetReactionPreset();
  }

  public final static func InvokeBehaviorCallback(obj: wref<ScriptedPuppet>, cbName: CName) -> Void {
    let aiComponent: ref<AIHumanComponent>;
    if AIHumanComponent.Get(obj, aiComponent) {
      aiComponent.InvokeBehaviorCallback(cbName);
    };
  }

  public final static func SendCommand(obj: wref<ScriptedPuppet>, cmd: ref<AICommand>) -> Void {
    let aiComponent: ref<AIHumanComponent>;
    if !IsDefined(obj) || !IsDefined(cmd) {
      return;
    };
    if AIHumanComponent.Get(obj, aiComponent) {
      aiComponent.SendCommand(cmd);
    };
  }

  public final static func CancelCommand(obj: wref<ScriptedPuppet>, cmd: ref<AICommand>) -> Void {
    let aiComponent: ref<AIHumanComponent>;
    if !IsDefined(obj) || !IsDefined(cmd) {
      return;
    };
    if AIHumanComponent.Get(obj, aiComponent) {
      aiComponent.CancelCommand(cmd);
    };
  }
}

public native class AIHumanComponent extends AIComponent {

  private let m_shootingBlackboard: wref<IBlackboard>;

  private let m_gadgetBlackboard: wref<IBlackboard>;

  private let m_coverBlackboard: wref<IBlackboard>;

  private let m_actionBlackboard: wref<IBlackboard>;

  private let m_patrolBlackboard: wref<IBlackboard>;

  private let m_alertedPatrolBlackboard: wref<IBlackboard>;

  private let m_friendlyFireCheckID: Uint32;

  private let m_ffs: ref<IFriendlyFireSystem>;

  private let m_LoSFinderCheckID: Uint32;

  private let m_loSFinderSystem: ref<ILoSFinderSystem>;

  private let m_LoSFinderVisibleObject: wref<VisibleObject>;

  private let m_actionAnimationScriptProxy: ref<ActionAnimationScriptProxy>;

  private let m_lastOwnerBlockedAttackEventID: DelayID;

  private let m_lastOwnerParriedAttackEventID: DelayID;

  private let m_lastOwnerDodgedAttackEventID: DelayID;

  private let m_grenadeThrowQueryTarget: wref<GameObject>;

  @default(AIHumanComponent, -1)
  private let m_grenadeThrowQueryId: Int32;

  private let m_scriptContext: ScriptExecutionContext;

  private let m_scriptContextInitialized: Bool;

  private let m_kerenzikovAbilityRecord: ref<GameplayAbility_Record>;

  private let m_highLevelCb: Uint32;

  private let m_activeCommands: AIActiveCommandList;

  public final native func SetMovementParams(params: MovementParameters) -> Void;

  public final native func GetMovementParams(type: moveMovementType) -> MovementParameters;

  public final native func SetTDBMovementParams(paramsID: TweakDBID) -> Bool;

  public final func GetFriendlyFireCheckID() -> Uint32 {
    return this.m_friendlyFireCheckID;
  }

  public final static func Get(owner: wref<ScriptedPuppet>, out aiComponent: ref<AIHumanComponent>) -> Bool {
    if !IsDefined(owner) {
      return false;
    };
    aiComponent = owner.GetAIControllerComponent();
    return aiComponent != null;
  }

  private final func GetGame() -> GameInstance {
    return (this.GetEntity() as GameObject).GetGame();
  }

  private final func OnAttach() -> Void {
    let spawnAIRole: ref<AIRole> = this.GetAIRole();
    if IsDefined(spawnAIRole) && NotEquals(spawnAIRole.GetRoleEnum(), IntEnum(0l)) {
      this.OnAIRoleChanged(spawnAIRole, null);
    };
    this.ResetBehaviorCoverArguments();
    this.m_kerenzikovAbilityRecord = TweakDBInterface.GetGameplayAbilityRecord(t"Ability.HasKerenzikov");
  }

  private final func ResetBehaviorCoverArguments() -> Void {
    let cm: ref<CoverManager> = GameInstance.GetCoverManager(this.GetGame());
    cm.NotifyBehaviourCoverArgumentChanged(this.GetEntity() as GameObject, n"DesiredCoverID", ScriptExecutionContext.GetArgumentUint64(this.m_scriptContext, n"DesiredCoverID"), 0u);
    ScriptExecutionContext.SetArgumentUint64(this.m_scriptContext, n"DesiredCoverID", 0u);
    cm.NotifyBehaviourCoverArgumentChanged(this.GetEntity() as GameObject, n"CoverID", ScriptExecutionContext.GetArgumentUint64(this.m_scriptContext, n"CoverID"), 0u);
    ScriptExecutionContext.SetArgumentUint64(this.m_scriptContext, n"CoverID", 0u);
    cm.NotifyBehaviourCoverArgumentChanged(this.GetEntity() as GameObject, n"CommandCoverID", ScriptExecutionContext.GetArgumentUint64(this.m_scriptContext, n"CommandCoverID"), 0u);
    ScriptExecutionContext.SetArgumentUint64(this.m_scriptContext, n"CommandCoverID", 0u);
  }

  private final func OnDetach() -> Void {
    this.m_actionAnimationScriptProxy = null;
    this.ResetBehaviorCoverArguments();
  }

  protected cb func OnDeath(evt: ref<gameDeathEvent>) -> Bool {
    this.ResetBehaviorCoverArguments();
  }

  protected cb func OnDefeated(evt: ref<DefeatedEvent>) -> Bool {
    this.ResetBehaviorCoverArguments();
  }

  protected cb func OnPlayerCombatChanged(value: Int32) -> Bool {
    this.InvokeBehaviorCallback(n"OnPlayerCombatChanged");
  }

  protected cb func OnDelayPassiveConditionEvaluationEvent(evt: ref<DelayPassiveConditionEvaluationEvent>) -> Bool {
    this.InvokeBehaviorCallback(n"OnDelayPassiveConditionEvaluation");
  }

  public final native const func GetNPCRarity() -> gamedataNPCRarity;

  public final native const func IsOfficer() -> Bool;

  public final func GetCoverBlackboard() -> ref<IBlackboard> {
    return this.GetOrCreateBlackboard(GetAllBlackboardDefs().AICover, this.m_coverBlackboard);
  }

  public final func GetShootingBlackboard() -> ref<IBlackboard> {
    return this.GetOrCreateBlackboard(GetAllBlackboardDefs().AIShooting, this.m_shootingBlackboard);
  }

  public final func GetCombatGadgetBlackboard() -> ref<IBlackboard> {
    return this.GetOrCreateBlackboard(GetAllBlackboardDefs().CombatGadget, this.m_gadgetBlackboard);
  }

  public final func GetActionBlackboard() -> ref<IBlackboard> {
    return this.GetOrCreateBlackboard(GetAllBlackboardDefs().AIAction, this.m_actionBlackboard);
  }

  public final func GetAIPatrolBlackboard() -> ref<IBlackboard> {
    return this.GetOrCreateBlackboard(GetAllBlackboardDefs().AIPatrol, this.m_patrolBlackboard);
  }

  public final func GetAIAlertedPatrolBlackboard() -> ref<IBlackboard> {
    return this.GetOrCreateBlackboard(GetAllBlackboardDefs().AIAlertedPatrol, this.m_alertedPatrolBlackboard);
  }

  public final const func GetCurrentRole() -> ref<AIRole> {
    return this.GetAIRole();
  }

  public final native const func GetAssignedVehicleId() -> EntityID;

  public final native const func GetAssignedVehicleSlot() -> MountingSlotId;

  public final native const func HasVehicleAssigned() -> Bool;

  protected cb func OnVehicleAssign(evt: ref<MountAIEvent>) -> Bool {
    if Equals(evt.name, n"Mount") {
      VehicleComponent.SetAnimsetOverrideForPassenger(this.GetEntity() as GameObject, evt.data.mountParentEntityId, evt.data.slotName, 1.00);
    };
  }

  public final const func GetAssignedVehicleData(out vehicleID: EntityID, out vehicleSlot: MountingSlotId) -> Bool {
    if !this.HasVehicleAssigned() {
      return false;
    };
    vehicleID = this.GetAssignedVehicleId();
    vehicleSlot = this.GetAssignedVehicleSlot();
    return true;
  }

  public final const func GetAssignedVehicle(gi: GameInstance, out vehicle: wref<GameObject>) -> Bool {
    if !this.HasVehicleAssigned() {
      return false;
    };
    vehicle = GameInstance.FindEntityByID(gi, this.GetAssignedVehicleId()) as VehicleObject;
    return vehicle != null;
  }

  public final static func GetLastUsedVehicleSlot(owner: wref<ScriptedPuppet>, out vehicleSlotName: CName) -> Bool {
    let vehicleSlot: MountingSlotId;
    if !AIHumanComponent.GetLastUsedVehicleSlot(owner, vehicleSlot) {
      return false;
    };
    vehicleSlotName = vehicleSlot.id;
    return IsNameValid(vehicleSlotName);
  }

  public final static func GetLastUsedVehicleSlot(owner: wref<ScriptedPuppet>, out vehicleSlot: MountingSlotId) -> Bool {
    let vehicleID: EntityID;
    if !IsDefined(owner) || !IsDefined(owner.GetAIControllerComponent()) {
      return false;
    };
    if !owner.GetAIControllerComponent().GetAssignedVehicleData(vehicleID, vehicleSlot) {
      return false;
    };
    return true;
  }

  public final static func GetAssignedVehicle(owner: wref<ScriptedPuppet>, out vehicle: wref<GameObject>) -> Bool {
    if !IsDefined(owner) || !IsDefined(owner.GetAIControllerComponent()) {
      return false;
    };
    return owner.GetAIControllerComponent().GetAssignedVehicle(owner.GetGame(), vehicle);
  }

  private final func OnAIRoleChanged(newRole: ref<AIRole>, oldRole: ref<AIRole>) -> Void {
    let gameObject: ref<GameObject> = this.GetEntity() as GameObject;
    let glpSystem: ref<GameplayLogicPackageSystem> = GameInstance.GetGameplayLogicPackageSystem(this.GetGame());
    if IsDefined(oldRole) && NotEquals(oldRole.GetRoleEnum(), IntEnum(0l)) {
      glpSystem.RemovePackage(gameObject, oldRole.GetRoleTweakRecord().RolePackage().GetID());
      oldRole.OnRoleCleared(gameObject);
    };
    newRole.OnRoleSet(gameObject);
    if IsDefined(newRole) && NotEquals(newRole.GetRoleEnum(), IntEnum(0l)) {
      glpSystem.ApplyPackage(gameObject, gameObject, newRole.GetRoleTweakRecord().RolePackage().GetID());
    };
  }

  public final static func SetCurrentRole(owner: ref<GameObject>, newRole: ref<AIRole>) -> Void {
    let ai: ref<AIHumanComponent>;
    let evt: ref<NPCRoleChangeEvent>;
    let puppet: ref<ScriptedPuppet> = owner as ScriptedPuppet;
    if IsDefined(puppet) {
      ai = puppet.GetAIControllerComponent();
      if IsDefined(ai) {
        ai.SetAIRole(newRole);
        if Equals(newRole.GetRoleEnum(), EAIRole.Follower) {
          puppet.SetSenseObjectType(gamedataSenseObjectType.Follower);
          if IsDefined(puppet as NPCPuppet) {
            (puppet as NPCPuppet).ResetCompanionRoleCacheTimeStamp();
          };
        } else {
          puppet.SetSenseObjectType(gamedataSenseObjectType.Npc);
        };
      };
    };
    evt = new NPCRoleChangeEvent();
    evt.m_newRole = newRole;
    if IsDefined(owner) {
      owner.QueueEvent(evt);
    };
  }

  public final const func IsPlayerCompanion() -> Bool {
    let friendlyTarget: wref<GameObject>;
    if !IsDefined(this.GetAIRole()) || NotEquals(this.GetAIRole().GetRoleEnum(), EAIRole.Follower) {
      return false;
    };
    friendlyTarget = FromVariant(this.GetBehaviorArgument(n"FriendlyTarget"));
    if !IsDefined(friendlyTarget) {
      return false;
    };
    if friendlyTarget.IsPlayer() {
      return true;
    };
    return false;
  }

  public final const func GetFriendlyTargetAsPlayer(out player: wref<PlayerPuppet>) -> Bool {
    let friendlyTarget: wref<GameObject>;
    if !this.GetFriendlyTarget(friendlyTarget) {
      return false;
    };
    player = friendlyTarget as PlayerPuppet;
    if IsDefined(player) {
      return true;
    };
    return false;
  }

  public final const func GetFriendlyTarget(out friendlyTarget: wref<GameObject>) -> Bool {
    if !IsDefined(this.GetAIRole()) || NotEquals(this.GetAIRole().GetRoleEnum(), EAIRole.Follower) {
      return false;
    };
    friendlyTarget = FromVariant(this.GetBehaviorArgument(n"FriendlyTarget"));
    if !IsDefined(friendlyTarget) {
      return false;
    };
    return true;
  }

  public final func GetActionAnimationScriptProxy() -> ref<ActionAnimationScriptProxy> {
    if !IsDefined(this.m_actionAnimationScriptProxy) {
      this.m_actionAnimationScriptProxy = new ActionAnimationScriptProxy();
      this.m_actionAnimationScriptProxy.Bind(this.GetEntity() as GameObject);
    };
    return this.m_actionAnimationScriptProxy;
  }

  public final func OnSignalCombatQueriesRequest(signalId: Uint16, newValue: Bool) -> Void {
    if newValue {
      this.FriendlyFireCheckInit();
      this.CombatQueriesSystemInit();
      this.FriendlyFireTargetUpdateInit();
      this.LoSFinderCheckInit();
    };
  }

  public final const func IsFriendlyFiring() -> Bool {
    if !IsDefined(this.m_ffs) {
      return false;
    };
    if this.m_friendlyFireCheckID == 0u {
      return false;
    };
    return !this.m_ffs.Check(this.m_friendlyFireCheckID);
  }

  public final const func FriendlyFireCheck() -> Bool {
    let puppet: ref<ScriptedPuppet>;
    if this.m_friendlyFireCheckID == 0u {
      return false;
    };
    puppet = this.GetEntity() as ScriptedPuppet;
    if !IsDefined(puppet) {
      return false;
    };
    if NotEquals(puppet.GetHighLevelStateFromBlackboard(), gamedataNPCHighLevelState.Combat) {
      return false;
    };
    return !this.m_ffs.Check(this.m_friendlyFireCheckID);
  }

  private final func FriendlyFireCheckInit() -> Bool {
    let ffp: ref<FriendlyFireParams>;
    let puppet: ref<ScriptedPuppet>;
    if !IsDefined(this.m_ffs) {
      this.m_ffs = this.GetFriendlyFireSystem();
    };
    puppet = this.GetEntity() as ScriptedPuppet;
    if !ScriptedPuppet.IsActive(puppet) || NotEquals(puppet.GetHighLevelStateFromBlackboard(), gamedataNPCHighLevelState.Combat) {
      if this.m_friendlyFireCheckID != 0u {
        this.m_ffs.StopChecking(this.m_friendlyFireCheckID);
        this.m_friendlyFireCheckID = 0u;
      };
      return false;
    };
    if this.m_friendlyFireCheckID == 0u {
      ffp = new FriendlyFireParams();
      ffp.SetShooter(puppet.GetAttitudeAgent(), n"RightHand", n"AttachmentSlots.WeaponRight");
      ffp.SetGeometry(0.20, 50.00);
      this.m_friendlyFireCheckID = this.m_ffs.StartChecking(ffp);
    };
    return true;
  }

  private final func FriendlyFireTargetUpdateInit() -> Void {
    let friendlyFireCheckID: Uint32;
    let ownerWeaponSlotTransform: WorldTransform;
    let shotForward: Vector4;
    let shotOriginPosition: Vector4;
    let slotComponent: ref<SlotComponent>;
    let bestTargetingComponent: wref<TargetingComponent> = null;
    let owner: ref<ScriptedPuppet> = this.GetEntity() as ScriptedPuppet;
    let target: wref<GameObject> = FromVariant(this.GetBehaviorArgument(n"CombatTarget"));
    if !IsDefined(owner) || !IsDefined(target) {
      return;
    };
    friendlyFireCheckID = this.GetFriendlyFireCheckID();
    if friendlyFireCheckID != 0u {
      if target.IsPlayer() {
        bestTargetingComponent = (target as PlayerPuppet).GetPrimaryTargetingComponent();
      } else {
        slotComponent = owner.GetSlotComponent();
        if IsDefined(slotComponent) && slotComponent.GetSlotTransform(n"RightHand", ownerWeaponSlotTransform) {
          shotOriginPosition = WorldPosition.ToVector4(WorldTransform.GetWorldPosition(ownerWeaponSlotTransform));
          if !AIActionHelper.GetTargetSlotPosition(target, n"Head", shotForward) {
            shotForward = target.GetWorldPosition();
          };
          shotForward -= shotOriginPosition;
          Vector4.Normalize(shotForward);
          bestTargetingComponent = GameInstance.GetTargetingSystem(owner.GetGame()).GetBestComponentOnTargetObject(shotOriginPosition, shotForward, target, TargetComponentFilterType.Shooting);
        };
      };
      if bestTargetingComponent != null {
        this.GetFriendlyFireSystem().UpdateCurrentTargetComponent(friendlyFireCheckID, bestTargetingComponent);
      } else {
        this.GetFriendlyFireSystem().UpdateCurrentTargetObject(friendlyFireCheckID, target);
      };
    };
  }

  private final func LoSFinderCheckInit() -> Bool {
    let params: ref<LoSFinderParams>;
    let puppet: ref<ScriptedPuppet>;
    let sensesComponent: ref<SenseComponent>;
    let target: ref<ScriptedPuppet>;
    let targetGO: wref<GameObject>;
    let visibleObject: ref<VisibleObject>;
    let visibleObjectComponent: ref<VisibleObjectComponent>;
    if !IsDefined(this.m_loSFinderSystem) {
      this.m_loSFinderSystem = this.GetLoSFinderSystem();
    };
    puppet = this.GetEntity() as ScriptedPuppet;
    targetGO = FromVariant(this.GetBehaviorArgument(n"CombatTarget"));
    target = targetGO as ScriptedPuppet;
    if IsDefined(target) {
      sensesComponent = target.GetSensesComponent();
      if IsDefined(sensesComponent) {
        visibleObject = sensesComponent.visibleObject;
      };
      if !IsDefined(visibleObject) {
        visibleObjectComponent = target.GetVisibleObjectComponent();
        if IsDefined(visibleObjectComponent) {
          visibleObject = visibleObjectComponent.visibleObject;
        };
      };
    };
    if !ScriptedPuppet.IsActive(puppet) || NotEquals(puppet.GetHighLevelStateFromBlackboard(), gamedataNPCHighLevelState.Combat) || !IsDefined(target) || !IsDefined(visibleObject) {
      if this.m_LoSFinderCheckID != 0u {
        this.m_loSFinderSystem.StopChecking(this.m_LoSFinderCheckID);
        this.m_LoSFinderCheckID = 0u;
        this.m_LoSFinderVisibleObject = null;
      };
      return false;
    };
    if this.m_LoSFinderCheckID == 0u || this.m_LoSFinderVisibleObject != visibleObject {
      this.m_LoSFinderVisibleObject = visibleObject;
      params = new LoSFinderParams();
      params.SetSeeker(puppet);
      params.SetTarget(visibleObject);
      params.SetTracesAmountMultiplier(ScriptedPuppet.IsPlayerCompanion(puppet) ? 2u : 1u);
      if IsDefined(puppet) && Equals(puppet.GetNPCType(), gamedataNPCType.Drone) {
        params.SetOverrideCheckHeight(2.00);
      };
      if this.m_LoSFinderCheckID == 0u {
        this.m_LoSFinderCheckID = this.m_loSFinderSystem.StartChecking(params);
      } else {
        this.m_loSFinderSystem.UpdateParams(this.m_LoSFinderCheckID, params);
      };
    };
    return true;
  }

  private final func CombatQueriesSystemInit() -> Bool {
    let puppet: ref<ScriptedPuppet> = this.GetEntity() as ScriptedPuppet;
    let target: wref<GameObject> = FromVariant(this.GetBehaviorArgument(n"CombatTarget"));
    let grenadeAbility: ref<GameplayAbility_Record> = TweakDBInterface.GetGameplayAbilityRecord(t"Ability.CanUseGrenades");
    if !IsDefined(target) || !this.m_scriptContextInitialized || !AICondition.CheckAbility(this.m_scriptContext, grenadeAbility) {
      if this.m_grenadeThrowQueryId >= 0 {
        GameInstance.GetCombatQueriesSystem(this.GetGame()).StopGrenadeThrowQueries(puppet);
        this.m_grenadeThrowQueryId = -1;
        this.m_grenadeThrowQueryTarget = null;
      };
      return false;
    };
    this.StartGrenadeThrowQuery(target);
    return this.m_grenadeThrowQueryId >= 0;
  }

  protected cb func OnStartGrenadeThrowQueryEvent(evt: ref<StartGrenadeThrowQueryEvent>) -> Bool {
    if this.m_grenadeThrowQueryId >= 0 {
      GameInstance.GetCombatQueriesSystem(this.GetGame()).StopGrenadeThrowQuery(this.GetEntity() as GameObject, this.m_grenadeThrowQueryId);
      this.m_grenadeThrowQueryId = -1;
      this.m_grenadeThrowQueryTarget = null;
    };
    if IsDefined(evt.queryParams.target) {
      this.m_grenadeThrowQueryId = GameInstance.GetCombatQueriesSystem(this.GetGame()).StartGrenadeThrowQuery(evt.queryParams);
      this.m_grenadeThrowQueryTarget = evt.queryParams.target;
    };
  }

  private final const func StartGrenadeThrowQuery(target: wref<GameObject>) -> Void {
    let evt: ref<StartGrenadeThrowQueryEvent>;
    let targetTrackerComponent: ref<TargetTrackerComponent>;
    if !IsDefined(target) {
      return;
    };
    evt = new StartGrenadeThrowQueryEvent();
    evt.queryParams.requester = this.GetEntity() as GameObject;
    evt.queryParams.target = target;
    evt.queryParams.minRadius = 1.00;
    evt.queryParams.maxRadius = 2.00;
    evt.queryParams.friendlyAvoidanceRadius = 9.00;
    targetTrackerComponent = evt.queryParams.requester.GetTargetTrackerComponent();
    if IsDefined(targetTrackerComponent) {
      evt.queryParams.targetPositionProvider = targetTrackerComponent.GetThreatLastKnownPositionProvider(target);
    };
    this.GetEntity().QueueEvent(evt);
  }

  public final const func CanThrowGrenadeAtTarget(target: wref<GameObject>, out throwPositions: Vector4, out throwAngle: Float, out throwStartType: gameGrenadeThrowStartType) -> Bool {
    if !IsDefined(target) {
      return false;
    };
    if this.m_grenadeThrowQueryId < 0 || target != this.m_grenadeThrowQueryTarget {
      this.StartGrenadeThrowQuery(target);
      return false;
    };
    if GameInstance.GetCombatQueriesSystem(target.GetGame()).CheckGrenadeThrowQuery(this.GetEntity() as GameObject, this.m_grenadeThrowQueryId, throwPositions, throwAngle, throwStartType) {
      return true;
    };
    return false;
  }

  public final func CacheThrowGrenadeAtTargetQuery(target: wref<GameObject>) -> Bool {
    let throwAngle: Float;
    let throwPositions: Vector4;
    let throwStartType: gameGrenadeThrowStartType = gameGrenadeThrowStartType.Invalid;
    if !IsDefined(target) {
      this.GetCombatGadgetBlackboard().SetFloat(GetAllBlackboardDefs().CombatGadget.lastThrowAngle, throwAngle);
      this.GetCombatGadgetBlackboard().SetVector4(GetAllBlackboardDefs().CombatGadget.lastThrowPosition, throwPositions);
      this.GetCombatGadgetBlackboard().SetVariant(GetAllBlackboardDefs().CombatGadget.lastThrowStartType, ToVariant(throwStartType));
      return false;
    };
    if this.m_grenadeThrowQueryId < 0 || target != this.m_grenadeThrowQueryTarget {
      this.GetCombatGadgetBlackboard().SetFloat(GetAllBlackboardDefs().CombatGadget.lastThrowAngle, throwAngle);
      this.GetCombatGadgetBlackboard().SetVector4(GetAllBlackboardDefs().CombatGadget.lastThrowPosition, throwPositions);
      this.GetCombatGadgetBlackboard().SetVariant(GetAllBlackboardDefs().CombatGadget.lastThrowStartType, ToVariant(throwStartType));
      this.StartGrenadeThrowQuery(target);
      return false;
    };
    if GameInstance.GetCombatQueriesSystem(target.GetGame()).CheckGrenadeThrowQuery(this.GetEntity() as GameObject, this.m_grenadeThrowQueryId, throwPositions, throwAngle, throwStartType) {
      this.GetCombatGadgetBlackboard().SetFloat(GetAllBlackboardDefs().CombatGadget.lastThrowAngle, throwAngle);
      this.GetCombatGadgetBlackboard().SetVector4(GetAllBlackboardDefs().CombatGadget.lastThrowPosition, throwPositions);
      this.GetCombatGadgetBlackboard().SetVariant(GetAllBlackboardDefs().CombatGadget.lastThrowStartType, ToVariant(throwStartType));
      return true;
    };
    return false;
  }

  public final func NULLCachedThrowGrenadeAtTargetQuery() -> Void {
    let throwAngle: Float;
    let throwPositions: Vector4;
    let throwStartType: gameGrenadeThrowStartType = gameGrenadeThrowStartType.Invalid;
    this.GetCombatGadgetBlackboard().SetFloat(GetAllBlackboardDefs().CombatGadget.lastThrowAngle, throwAngle);
    this.GetCombatGadgetBlackboard().SetVector4(GetAllBlackboardDefs().CombatGadget.lastThrowPosition, throwPositions);
    this.GetCombatGadgetBlackboard().SetVariant(GetAllBlackboardDefs().CombatGadget.lastThrowStartType, ToVariant(throwStartType));
  }

  protected cb func OnSetScriptExecutionContext(evt: ref<SetScriptExecutionContextEvent>) -> Bool {
    this.m_scriptContext = evt.scriptExecutionContext;
    this.m_scriptContextInitialized = true;
  }

  public final static func GetScriptContext(const puppet: wref<ScriptedPuppet>, out context: ScriptExecutionContext) -> Bool {
    if !IsDefined(puppet) {
      return false;
    };
    return puppet.GetAIControllerComponent().GetScriptContext(context);
  }

  public final const func GetScriptContext(out context: ScriptExecutionContext) -> Bool {
    if !this.m_scriptContextInitialized {
      return false;
    };
    context = this.m_scriptContext;
    return true;
  }

  public final const func CheckTweakCondition(ActionConditionName: String) -> Bool {
    let TDBRecord: TweakDBID;
    let actionRecord: wref<AIAction_Record>;
    let actionStringName: String;
    if !this.m_scriptContextInitialized {
      return false;
    };
    TDBRecord = ScriptExecutionContext.CreateActionID(this.m_scriptContext, ActionConditionName, AIScriptActionDelegate.GetActionPackageType(this.m_scriptContext));
    if TweakAIActionRecord.GetActionRecord(this.m_scriptContext, TDBRecord, actionStringName, actionRecord) {
      return AICondition.ActivationCheck(this.m_scriptContext, actionRecord);
    };
    return false;
  }

  public final func TryBulletDodgeOpportunity() -> Bool {
    let aiEvent: ref<StimuliEvent>;
    let dodge: Bool = false;
    let owner: ref<ScriptedPuppet> = this.GetEntity() as ScriptedPuppet;
    if IsDefined(owner) {
      dodge = owner.HasIndividualTimeDilation(TimeDilationHelper.GetSandevistanKey());
    };
    if !dodge && AIActionHelper.CheckAbility(owner, this.m_kerenzikovAbilityRecord) && this.CheckTweakCondition("DodgeBulletSelectorCondition") {
      aiEvent = new StimuliEvent();
      aiEvent.name = n"BulletDodgeOpportunity";
      this.GetEntity().QueueEvent(aiEvent);
      dodge = true;
    };
    return dodge;
  }

  protected cb func OnHitAiEventReceived(hitAIEvent: ref<AIEvent>) -> Bool {
    if Equals(hitAIEvent.name, n"MyAttackBlocked") {
      this.UpdateMyAttackBlockedCount(false);
    } else {
      if Equals(hitAIEvent.name, n"MyAttackParried") {
        this.UpdateMyAttackParriedCount(false);
      } else {
        if Equals(hitAIEvent.name, n"MyAttackDodged") {
          this.UpdateMyAttackDodgedCount(false);
        } else {
          if Equals(hitAIEvent.name, n"ResetmyAttackBlockedCount") {
            this.UpdateMyAttackBlockedCount(true);
          } else {
            if Equals(hitAIEvent.name, n"ResetmyAttackParriedCount") {
              this.UpdateMyAttackParriedCount(true);
            } else {
              if Equals(hitAIEvent.name, n"ResetmyAttackDodgedCount") {
                this.UpdateMyAttackDodgedCount(true);
              };
            };
          };
        };
      };
    };
  }

  private final func UpdateMyAttackBlockedCount(resetBB: Bool) -> Void {
    let request: ref<StimuliEvent> = new StimuliEvent();
    let blackBoardVarID: BlackboardID_Int = GetAllBlackboardDefs().AIAction.ownerMeleeAttackBlockedCount;
    if resetBB {
      this.GetActionBlackboard().SetInt(blackBoardVarID, 0);
    } else {
      this.GetActionBlackboard().SetInt(blackBoardVarID, this.GetActionBlackboard().GetInt(blackBoardVarID) + 1);
      request.name = n"ResetmyAttackBlockedCount";
      GameInstance.GetDelaySystem(this.GetGame()).CancelDelay(this.m_lastOwnerBlockedAttackEventID);
      this.m_lastOwnerBlockedAttackEventID = GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this.GetEntity(), request, 5.00);
    };
  }

  private final func UpdateMyAttackParriedCount(resetBB: Bool) -> Void {
    let request: ref<StimuliEvent> = new StimuliEvent();
    let blackBoardVarID: BlackboardID_Int = GetAllBlackboardDefs().AIAction.ownerMeleeAttackParriedCount;
    if resetBB {
      this.GetActionBlackboard().SetInt(blackBoardVarID, 0);
    } else {
      this.GetActionBlackboard().SetInt(blackBoardVarID, this.GetActionBlackboard().GetInt(blackBoardVarID) + 1);
      request.name = n"ResetmyAttackParriedCount";
      GameInstance.GetDelaySystem(this.GetGame()).CancelDelay(this.m_lastOwnerParriedAttackEventID);
      this.m_lastOwnerParriedAttackEventID = GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this.GetEntity(), request, 5.00);
    };
  }

  private final func UpdateMyAttackDodgedCount(resetBB: Bool) -> Void {
    let request: ref<StimuliEvent> = new StimuliEvent();
    let blackBoardVarID: BlackboardID_Int = GetAllBlackboardDefs().AIAction.ownerMeleeAttackDodgedCount;
    if resetBB {
      this.GetActionBlackboard().SetInt(blackBoardVarID, 0);
    } else {
      this.GetActionBlackboard().SetInt(blackBoardVarID, this.GetActionBlackboard().GetInt(blackBoardVarID) + 1);
      request.name = n"ResetmyAttackDodgedCount";
      GameInstance.GetDelaySystem(this.GetGame()).CancelDelay(this.m_lastOwnerDodgedAttackEventID);
      this.m_lastOwnerDodgedAttackEventID = GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this.GetEntity(), request, 5.00);
    };
  }

  public final func OnCommandStateChanged(command: ref<AICommand>, oldState: AICommandState, newState: AICommandState) -> Void {
    if Equals(newState, AICommandState.Executing) || Equals(newState, AICommandState.Enqueued) || Equals(newState, AICommandState.NotExecuting) {
      AIActiveCommandList.Add(this.m_activeCommands, command);
    } else {
      AIActiveCommandList.Remove(this.m_activeCommands, command.GetClassName());
    };
    if IsDefined(command as AICombatRelatedCommand) {
      this.InvokeBehaviorCallback(n"OnCombatCommandChanged");
    } else {
      if IsDefined(command as AIMeleeAttackCommand) || IsDefined(command as AIForceShootCommand) {
        this.InvokeBehaviorCallback(n"OnCombatCommandChanged");
      };
    };
    this.InvokeBehaviorCallback(n"OnCommandStateChanged");
  }

  public final func OnSignalCommandSignal(signalId: Uint16, newValue: Bool) -> Void {
    let signalData: ref<CommandSignal>;
    if newValue {
      signalData = this.GetSignals().GetCurrentData(signalId) as CommandSignal;
      if IsDefined(signalData) {
        if signalData.track {
          this.TrackActionCommandID(signalData.commandClassNames);
        } else {
          this.ClearActionCommandID(signalData.commandClassNames);
        };
      };
    };
  }

  private final func TrackActionCommandID(commandClassNames: script_ref<array<CName>>) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(Deref(commandClassNames)) {
      AIActiveCommandList.TrackActionCommand(this.m_activeCommands, Deref(commandClassNames)[i]);
      i += 1;
    };
  }

  private final func ClearActionCommandID(commandClassNames: script_ref<array<CName>>) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(Deref(commandClassNames)) {
      AIActiveCommandList.ClearActionCommand(this.m_activeCommands, Deref(commandClassNames)[i]);
      i += 1;
    };
  }

  public final const func IsCommandReceivedOrOverriden(const commandClassName: CName) -> Bool {
    return AIActiveCommandList.IsActionCommandByName(this.m_activeCommands, commandClassName);
  }

  public final const func IsCommandReceivedOrOverriden(const commandID: Uint32) -> Bool {
    return AIActiveCommandList.IsActionCommandById(this.m_activeCommands, commandID);
  }

  public final const func IsCommandActive(const commandClassName: CName) -> Bool {
    return AIActiveCommandList.Contains(this.m_activeCommands, commandClassName);
  }

  public final const func GetActiveCommandsCount() -> Int32 {
    return AIActiveCommandList.Size(this.m_activeCommands);
  }

  public final const func IsCommandActive(const commandID: Uint32) -> Bool {
    return AIActiveCommandList.ContainsById(this.m_activeCommands, commandID);
  }

  public final const func GetActiveCommandID(const commandClassName: CName) -> Int32 {
    let id: Uint32;
    if AIActiveCommandList.GetId(this.m_activeCommands, commandClassName, id) {
      return Cast(id);
    };
    return -1;
  }

  protected cb func OnStatusEffectApplied(evt: ref<ApplyStatusEffectEvent>) -> Bool;

  protected cb func OnStatusEffectRemoved(evt: ref<ApplyStatusEffectEvent>) -> Bool {
    this.InvokeBehaviorCallback(n"OnStatusEffectRemoved");
  }

  protected cb func OnNewThreat(evt: ref<NewThreat>) -> Bool {
    this.InvokeBehaviorCallback(n"OnThreatsChanged");
  }

  protected cb func OnHostileThreatDetected(evt: ref<HostileThreatDetected>) -> Bool {
    this.InvokeBehaviorCallback(n"OnThreatsChanged");
  }

  protected cb func OnEnemyThreatDetected(evt: ref<EnemyThreatDetected>) -> Bool {
    this.InvokeBehaviorCallback(n"OnThreatsChanged");
  }

  protected cb func OnThreatRemoved(evt: ref<ThreatRemoved>) -> Bool {
    this.InvokeBehaviorCallback(n"OnThreatsChanged");
  }

  protected cb func OnAnimParamsEvent(evt: ref<AnimParamsEvent>) -> Bool {
    let status: Bool;
    let value: Float;
    if evt.GetParameterValue(n"rightArmLookAtStatus", value) {
      status = GetLookAtStatus(animLookAtStatus.LimitReached, value);
      if status {
        this.GetShootingBlackboard().SetInt(GetAllBlackboardDefs().AIShooting.rightArmLookAtLimitReached, 0);
        return true;
      };
      status = GetLookAtStatus(animLookAtStatus.TransitionInProgress, value);
      if status {
        this.GetShootingBlackboard().SetInt(GetAllBlackboardDefs().AIShooting.rightArmLookAtLimitReached, 1);
        return true;
      };
      status = GetLookAtStatus(animLookAtStatus.Active, value);
      if status {
        this.GetShootingBlackboard().SetInt(GetAllBlackboardDefs().AIShooting.rightArmLookAtLimitReached, 2);
        return true;
      };
      this.GetShootingBlackboard().SetInt(GetAllBlackboardDefs().AIShooting.rightArmLookAtLimitReached, 0);
    };
  }
}
