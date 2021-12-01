
public class PlayerStatsListener extends ScriptStatsListener {

  public let m_owner: wref<GameObject>;

  public func OnStatChanged(ownerID: StatsObjectID, statType: gamedataStatType, diff: Float, total: Float) -> Void {
    this.m_owner.SetScannerDirty(true);
  }
}

public class NPCGodModeListener extends ScriptStatsListener {

  public let m_owner: wref<NPCPuppet>;

  public func OnGodModeChanged(ownerID: EntityID, newType: gameGodModeType) -> Void {
    this.m_owner.OnGodModeChanged();
  }
}

public class NPCDeathListener extends ScriptStatPoolsListener {

  public let npc: wref<NPCPuppet>;

  protected cb func OnStatPoolAdded() -> Bool {
    if this.npc.IsDefeatMechanicActive() {
      GameInstance.GetStatPoolsSystem(this.npc.GetGame()).RequestSettingStatPoolValueCustomLimit(Cast(this.npc.GetEntityID()), gamedataStatPoolType.Health, 0.10, null);
    } else {
      GameInstance.GetStatPoolsSystem(this.npc.GetGame()).RequestSettingStatPoolValueCustomLimit(Cast(this.npc.GetEntityID()), gamedataStatPoolType.Health, 0.00, null);
    };
  }

  protected cb func OnStatPoolCustomLimitReached(value: Float) -> Bool {
    if StatusEffectSystem.ObjectHasStatusEffect(this.npc, t"BaseStatusEffect.ForceKill") || StatusEffectSystem.ObjectHasStatusEffect(this.npc, t"WorkspotStatus.Death") {
      this.npc.MarkForDeath();
    } else {
      this.npc.MarkForDefeat();
    };
    this.SendPotentialDeathEvent();
    this.npc.m_wasJustKilledOrDefeated = true;
  }

  protected cb func OnStatPoolMinValueReached(value: Float) -> Bool {
    this.npc.m_wasJustKilledOrDefeated = true;
    if Equals(this.npc.GetNPCType(), gamedataNPCType.Drone) {
      this.npc.MarkForDeath();
      this.SendPotentialDeathEvent();
    };
  }

  protected final func SendPotentialDeathEvent() -> Void {
    let potentialDeathEvt: ref<gamePotentialDeathEvent> = new gamePotentialDeathEvent();
    potentialDeathEvt.instigator = this.npc.GetLastHitInstigator();
    this.npc.QueueEvent(potentialDeathEvt);
  }
}

public class NPCPuppet extends ScriptedPuppet {

  private let m_lastHitEvent: ref<gameHitEvent>;

  private let m_totalFrameReactionDamageReceived: Float;

  private let m_totalFrameWoundsDamageReceived: Float;

  private let m_totalFrameDismembermentDamageReceived: Float;

  private let m_hitEventLock: RWLock;

  private let m_NPCManager: ref<NPCManager>;

  private let m_customDeathDirection: Int32;

  private let m_deathOverrideState: Bool;

  private let m_agonyState: Bool;

  private let m_defensiveState: Bool;

  private let m_lastSetupWorkspotActionEvent: ref<SetupWorkspotActionEvent>;

  public let m_wasJustKilledOrDefeated: Bool;

  private let m_shouldDie: Bool;

  private let m_shouldBeDefeated: Bool;

  private let m_sentDownedEvent: Bool;

  private let m_isRagdolling: Bool;

  private let m_hasAnimatedRagdoll: Bool;

  private let m_disableCollisionRequested: Bool;

  private let m_ragdollInstigator: wref<GameObject>;

  private let m_ragdollSplattersSpawned: Int32;

  private let m_ragdollFloorSplashSpawned: Bool;

  private let m_ragdollImpactData: RagdollImpactPointData;

  private let m_ragdollDamageData: RagdollDamagePollData;

  private let m_ragdollInitialPosition: Vector4;

  private let m_ragdollActivationTimestamp: Float;

  private let m_ragdolledEntities: array<wref<Entity>>;

  private let m_disableRagdollAfterRecovery: Bool;

  private let m_isNotVisible: Bool;

  private let m_deathListener: ref<NPCDeathListener>;

  private let m_godModeStatListener: ref<NPCGodModeListener>;

  private let m_npcCollisionComponent: ref<SimpleColliderComponent>;

  private let m_npcRagdollComponent: ref<IComponent>;

  private let m_npcTraceObstacleComponent: ref<SimpleColliderComponent>;

  private let m_npcMountedToPlayerComponents: array<ref<IComponent>>;

  private let m_scavengeComponent: ref<ScavengeComponent>;

  private let m_influenceComponent: ref<InfluenceComponent>;

  private let m_comfortZoneComponent: ref<IComponent>;

  public let m_isTargetingPlayer: Bool;

  private let m_playerStatsListener: ref<ScriptStatsListener>;

  private let m_upperBodyStateCallbackID: ref<CallbackHandle>;

  private let m_leftCyberwareStateCallbackID: ref<CallbackHandle>;

  private let m_meleeStateCallbackID: ref<CallbackHandle>;

  private let m_combatGadgetStateCallbackID: ref<CallbackHandle>;

  private let m_wasAimedAtLast: Bool;

  private let m_wasCWChargedAtLast: Bool;

  private let m_wasMeleeChargedAtLast: Bool;

  private let m_wasChargingGadgetAtLast: Bool;

  private let m_isLookedAt: Bool;

  private let m_cachedPlayerID: EntityID;

  private let m_canGoThroughDoors: Bool;

  private let m_lastStatusEffectSignalSent: wref<StatusEffect_Record>;

  private let m_cachedStatusEffectAnim: wref<StatusEffect_Record>;

  private let m_resendStatusEffectSignalDelayID: DelayID;

  private let m_lastSEAppliedByPlayer: ref<StatusEffect>;

  private let m_pendingSEEvent: ref<ApplyStatusEffectEvent>;

  private let m_bounty: Bounty;

  private let m_cachedVFXList: array<wref<StatusEffectFX_Record>>;

  private let m_cachedSFXList: array<wref<StatusEffectFX_Record>>;

  private let m_isThrowingGrenadeToPlayer: Bool;

  private let m_throwingGrenadeDelayEventID: DelayID;

  private let m_myKiller: wref<GameObject>;

  private let m_primaryThreatCalculationType: EAIThreatCalculationType;

  private let m_temporaryThreatCalculationType: EAIThreatCalculationType;

  private let m_isPlayerCompanionCached: Bool;

  private let m_isPlayerCompanionCachedTimeStamp: Float;

  private let quickHackEffectsApplied: Uint32;

  private let hackingResistanceMod: ref<gameConstantStatModifierData>;

  private let m_delayNonStealthQuickHackVictimEventID: DelayID;

  private let m_cachedIsPaperdoll: Int32;

  private let smartDespawnDelayID: DelayID;

  private let despawnTicks: Uint32;

  public const func IsNPC() -> Bool {
    return true;
  }

  public final const func IsReplicable() -> Bool {
    return true;
  }

  public final const func GetReplicatedStateClass() -> CName {
    return n"gameNpcPuppetReplicatedState";
  }

  protected final func PrepareVendor() -> Void {
    GameInstance.GetDelaySystem(this.GetGame()).QueueTask(this, null, n"PrepareVendorTask", gameScriptTaskExecutionStage.Any);
  }

  protected final func PrepareVendorTask(data: ref<ScriptTaskData>) -> Void {
    let request: ref<AttachVendorRequest>;
    let vendorID: TweakDBID;
    let record: ref<Character_Record> = TweakDBInterface.GetCharacterRecord(this.GetRecordID());
    if IsDefined(record) && IsDefined(record.VendorID()) {
      vendorID = record.VendorID().GetID();
    };
    if TDBID.IsValid(vendorID) {
      request = new AttachVendorRequest();
      request.owner = this;
      request.vendorID = vendorID;
      MarketSystem.GetInstance(this.GetGame()).QueueRequest(request);
    };
  }

  protected final func InitializeNPCManager() -> Void {
    this.m_NPCManager = new NPCManager();
    this.m_NPCManager.Init(this);
  }

  protected final func IsPaperdoll() -> Bool {
    if this.m_cachedIsPaperdoll == 0 {
      if NPCManager.HasTag(this.GetRecordID(), n"TPP_Player") {
        this.m_cachedIsPaperdoll = 1;
      } else {
        this.m_cachedIsPaperdoll = -1;
      };
    };
    return this.m_cachedIsPaperdoll > 0;
  }

  public final func ResetCompanionRoleCacheTimeStamp() -> Void {
    this.m_isPlayerCompanionCachedTimeStamp = 0.00;
  }

  protected cb func OnPlayerCompanionCacheData(evt: ref<PlayerCompanionCacheDataEvent>) -> Bool {
    this.m_isPlayerCompanionCached = evt.m_isPlayerCompanionCached;
    this.m_isPlayerCompanionCachedTimeStamp = evt.m_isPlayerCompanionCachedTimeStamp;
  }

  private final const func GetPlayerID() -> EntityID {
    if EntityID.IsDefined(this.m_cachedPlayerID) {
      return this.m_cachedPlayerID;
    };
    return GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerMainGameObject().GetEntityID();
  }

  public const func IsPlayerCompanion() -> Bool {
    let evt: ref<PlayerCompanionCacheDataEvent>;
    let isPlayerCompanionCached: Bool;
    let currTime: Float = EngineTime.ToFloat(GameInstance.GetSimTime(this.GetGame()));
    if this.m_isPlayerCompanionCachedTimeStamp == 0.00 || currTime - this.m_isPlayerCompanionCachedTimeStamp > 10.00 {
      evt = new PlayerCompanionCacheDataEvent();
      isPlayerCompanionCached = this.IsPlayerCompanion();
      evt.m_isPlayerCompanionCached = isPlayerCompanionCached;
      evt.m_isPlayerCompanionCachedTimeStamp = currTime;
      GameInstance.GetPersistencySystem(this.GetGame()).QueueEntityEvent(this.GetEntityID(), evt);
    } else {
      isPlayerCompanionCached = this.m_isPlayerCompanionCached;
    };
    return isPlayerCompanionCached;
  }

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    super.OnRequestComponents(ri);
    EntityRequestComponentsInterface.RequestComponent(ri, n"scanning", n"gameScanningComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"npcCollision", n"SimpleColliderComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"npcTraceObstacle", n"SimpleColliderComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"ethnicity", n"EthnicityComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"VisibleObject", n"VisibleObjectComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"ScavengeComponent", n"ScavengeComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"HitPhysicalQueryMesh", n"entColliderComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"HitRepresentation", n"gameHitRepresentationComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"VisualOffset", n"visualOffsetTransformComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"RagdollComponent", n"entRagdollComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"InfluenceComponent", n"gameinfluenceComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"ComfortZone", n"entTriggerComponent", false);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    super.OnTakeControl(ri);
    this.m_npcCollisionComponent = EntityResolveComponentsInterface.GetComponent(ri, n"npcCollision") as SimpleColliderComponent;
    this.m_npcTraceObstacleComponent = EntityResolveComponentsInterface.GetComponent(ri, n"npcTraceObstacle") as SimpleColliderComponent;
    this.m_visibleObjectComponent = EntityResolveComponentsInterface.GetComponent(ri, n"VisibleObject") as VisibleObjectComponent;
    this.m_scavengeComponent = EntityResolveComponentsInterface.GetComponent(ri, n"ScavengeComponent") as ScavengeComponent;
    ArrayPush(this.m_npcMountedToPlayerComponents, EntityResolveComponentsInterface.GetComponent(ri, n"HitPhysicalQueryMesh"));
    ArrayPush(this.m_npcMountedToPlayerComponents, EntityResolveComponentsInterface.GetComponent(ri, n"HitRepresentation"));
    ArrayPush(this.m_npcMountedToPlayerComponents, EntityResolveComponentsInterface.GetComponent(ri, n"VisualOffset"));
    this.m_npcRagdollComponent = EntityResolveComponentsInterface.GetComponent(ri, n"RagdollComponent");
    this.m_influenceComponent = EntityResolveComponentsInterface.GetComponent(ri, n"InfluenceComponent") as InfluenceComponent;
    this.m_comfortZoneComponent = EntityResolveComponentsInterface.GetComponent(ri, n"ComfortZone");
  }

  protected cb func OnPostInitialize(evt: ref<entPostInitializeEvent>) -> Bool {
    super.OnPostInitialize(evt);
    if IsDefined(this.m_comfortZoneComponent) {
      this.m_comfortZoneComponent.Toggle(false);
    };
    if IsDefined(this.m_visibleObjectComponent) {
      this.m_visibleObjectComponent.Toggle(false);
    };
    this.InitializeNPCManager();
  }

  protected cb func OnPreUninitialize(evt: ref<entPreUninitializeEvent>) -> Bool {
    super.OnPreUninitialize(evt);
    if IsDefined(this.m_NPCManager) {
      this.m_NPCManager.UnInit(this);
    };
  }

  protected cb func OnGameAttached() -> Bool {
    let hasCrowdLOD: Bool;
    let isCrowd: Bool;
    let setScannerTime: ref<SetScanningTimeEvent>;
    super.OnGameAttached();
    isCrowd = this.IsCrowd();
    hasCrowdLOD = this.HasCrowdStaticLOD();
    if hasCrowdLOD {
      AnimationControllerComponent.SetAnimWrapperWeight(this, n"crowd", 1.00);
    };
    this.SetAnimWrapperWeightBasedOnFaction();
    this.SetRandomAnimWrappersForLocomotion();
    AnimationControllerComponent.ApplyFeature(this, n"ProceduralLean", new AnimFeature_ProceduralLean());
    this.InitThreatsCurves();
    if !isCrowd && !(this.GetPS() as ScriptedPuppetPS).WasAttached() {
      this.ApplyRarityMods();
    };
    if !isCrowd {
      setScannerTime = new SetScanningTimeEvent();
      setScannerTime.time = 0.50;
      this.QueueEvent(setScannerTime);
      this.PrepareVendor();
    };
    if !IsDefined(this.m_deathListener) {
      this.m_deathListener = new NPCDeathListener();
      this.m_deathListener.npc = this;
      GameInstance.GetStatPoolsSystem(this.GetGame()).RequestRegisteringListener(Cast(this.GetEntityID()), gamedataStatPoolType.Health, this.m_deathListener);
    };
    this.SetSenseObjectType(gamedataSenseObjectType.Npc);
    if (this.GetPS() as ScriptedPuppetPS).GetWasIncapacitated() {
      if !isCrowd {
        this.GenerateLoot();
        this.EvaluateLootQualityByTask();
      };
      this.SetIsDefeatMechanicActive(false, true);
    } else {
      this.SetIsDefeatMechanicActive(Equals(this.GetNPCType(), gamedataNPCType.Human), true);
    };
  }

  protected cb func OnDetach() -> Bool {
    super.OnDetach();
    if !this.IsCrowd() {
      StatusEffectHelper.RemoveStatusEffect(this, t"BaseStatusEffect.Grappled");
    };
    if IsDefined(this.m_deathListener) {
      GameInstance.GetStatPoolsSystem(this.GetGame()).RequestUnregisteringListener(Cast(this.GetEntityID()), gamedataStatPoolType.Health, this.m_deathListener);
      this.m_deathListener = null;
    };
    if EntityID.IsDefined(this.m_cachedPlayerID) {
      this.UnregisterCallbacksForReactions();
      this.m_cachedPlayerID = new EntityID();
    };
  }

  protected cb func OnPreloadAnimationsEvent(evt: ref<PreloadAnimationsEvent>) -> Bool {
    AIActionHelper.PreloadAnimations(this, evt.m_streamingContextName, evt.m_highPriority);
  }

  protected cb func OnDeviceLinkRequest(evt: ref<DeviceLinkRequest>) -> Bool {
    let link: ref<PuppetDeviceLinkPS>;
    if this.IsCrowd() || this.IsCharacterCivilian() {
      return false;
    };
    link = PuppetDeviceLinkPS.CreateAndAcquirePuppetDeviceLinkPS(this.GetGame(), this.GetEntityID());
    if IsDefined(link) {
      GameInstance.GetPersistencySystem(this.GetGame()).QueuePSEvent(link.GetID(), link.GetClassName(), evt);
    };
  }

  protected func CreateListeners() -> Void {
    let statSys: ref<StatsSystem> = GameInstance.GetStatsSystem(GetGameInstance());
    let puppetID: EntityID = this.GetEntityID();
    if !IsDefined(this.m_godModeStatListener) {
      this.m_godModeStatListener = new NPCGodModeListener();
      this.m_godModeStatListener.m_owner = this;
      statSys.RegisterListener(Cast(puppetID), this.m_godModeStatListener);
    };
    this.CreateListeners();
  }

  protected func RemoveListeners() -> Void {
    let statSys: ref<StatsSystem> = GameInstance.GetStatsSystem(GetGameInstance());
    let puppetID: EntityID = this.GetEntityID();
    if IsDefined(this.m_godModeStatListener) {
      statSys.UnregisterListener(Cast(puppetID), this.m_godModeStatListener);
      this.m_godModeStatListener = null;
    };
    this.RemoveListeners();
  }

  protected cb func OnDeviceLinkEstablished(evt: ref<DeviceLinkEstablished>) -> Bool {
    GameInstance.GetPersistencySystem(this.GetGame()).QueuePSEvent(this.GetPS().GetID(), this.GetPS().GetClassName(), evt);
  }

  private final func ApplyRarityMods() -> Void {
    let constMod: wref<ConstantStatModifier_Record>;
    let i: Int32;
    let mod: ref<gameStatModifierData>;
    let statMods: array<wref<StatModifier_Record>>;
    let ownerID: EntityID = this.GetEntityID();
    let puppet: wref<NPCPuppet> = this;
    let statSys: ref<StatsSystem> = GameInstance.GetStatsSystem(GetGameInstance());
    puppet.GetPuppetRarity().StatModifiers(statMods);
    i = 0;
    while i < ArraySize(statMods) {
      constMod = statMods[i] as ConstantStatModifier_Record;
      if IsDefined(constMod) {
        mod = RPGManager.CreateStatModifier(constMod.StatType().StatType(), IntEnum(Cast(EnumValueFromName(n"gameStatModifierType", constMod.ModifierType()))), constMod.Value());
      } else {
        mod = RPGManager.CreateCurveModifier(statMods[i] as CurveStatModifier_Record);
      };
      statSys.AddSavedModifier(Cast(ownerID), mod);
      i += 1;
    };
  }

  protected const func GetPS() -> ref<GameObjectPS> {
    return this.GetBasePS();
  }

  public final const func GetBounty() -> Bounty {
    return this.m_bounty;
  }

  public final func SetBountyAwarded(awarded: Bool) -> Void {
    let evt: ref<SetBountyAwardedEvent> = new SetBountyAwardedEvent();
    evt.awarded = awarded;
    this.QueueEvent(evt);
  }

  protected cb func OnSetBountyAwardedEvent(evt: ref<SetBountyAwardedEvent>) -> Bool {
    this.m_bounty.m_awarded = evt.awarded;
  }

  public final static func SetBountyObject(target: ref<GameObject>, bounty: Bounty) -> Void {
    let evt: ref<SetBountyObjectEvent>;
    if IsDefined(target) {
      evt = new SetBountyObjectEvent();
      evt.bounty = bounty;
      target.QueueEvent(evt);
    };
  }

  protected cb func OnSetBountyObjectEvent(evt: ref<SetBountyObjectEvent>) -> Bool {
    this.SetBounty(evt.bounty);
  }

  protected final func SetBounty(bounty: Bounty) -> Void {
    this.m_bounty = bounty;
  }

  protected cb func OnSetBounty(evt: ref<SetBountyEvent>) -> Bool {
    BountyManager.SetBountyFromID(evt.bountyID, this);
  }

  public final static func SetNPCDisposedFact(npcBody: wref<NPCPuppet>) -> Void {
    let factName: CName;
    if !IsDefined(npcBody) {
      return;
    };
    factName = TweakDBInterface.GetCName(npcBody.GetRecordID() + t".BodyDisposalFact", n"someNpcDisposed");
    SetFactValue(npcBody.GetGame(), factName, 1);
  }

  protected cb func OnSecuritySystemAgentTrackingPlayer(evt: ref<SecuritySystemSupport>) -> Bool {
    let ttc: ref<TargetTrackerComponent>;
    let playerPuppet: wref<ScriptedPuppet> = GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerMainGameObject() as ScriptedPuppet;
    if !IsDefined(playerPuppet) {
      return false;
    };
    ttc = this.GetTargetTrackerComponent();
    if !IsDefined(ttc) {
      return false;
    };
    if evt.supportGranted {
      if !StatusEffectSystem.ObjectHasStatusEffectWithTag(this, n"Blind") && !StatusEffectSystem.ObjectHasStatusEffectWithTag(this, n"CommsNoiseJam") {
        this.SwitchTargetPlayerTrackedAccuracy(true);
      };
    } else {
      this.SwitchTargetPlayerTrackedAccuracy(false);
    };
  }

  protected final func SwitchTargetPlayerTrackedAccuracy(freeze: Bool) -> Bool {
    let ttc: ref<TargetTrackerComponent>;
    let playerPuppet: wref<ScriptedPuppet> = GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerMainGameObject() as ScriptedPuppet;
    if !IsDefined(playerPuppet) {
      return false;
    };
    ttc = this.GetTargetTrackerComponent();
    if !IsDefined(ttc) {
      return false;
    };
    if freeze {
      ttc.SetThreatBeliefAccuracy(playerPuppet, 1.00);
      ttc.RequestThreatBeliefAccuracyMinValue(playerPuppet, n"TrackedBySecuritySystemAgent", 1.00);
      TargetTrackingExtension.SetThreatPersistence(playerPuppet, this, true, EnumInt(PersistenceSource.TrackedBySecuritySystemAgent));
    } else {
      ttc.RemoveThreatBeliefAccuracyMinValue(playerPuppet, n"TrackedBySecuritySystemAgent");
      TargetTrackingExtension.SetThreatPersistence(playerPuppet, this, false, EnumInt(PersistenceSource.TrackedBySecuritySystemAgent));
    };
    return true;
  }

  protected final func SwitchTargetPlayerTrackedAccuracy(ttc: ref<TargetTrackerComponent>, freeze: Bool) -> Bool {
    let playerPuppet: wref<ScriptedPuppet>;
    if !IsDefined(ttc) {
      return false;
    };
    playerPuppet = GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerMainGameObject() as ScriptedPuppet;
    if !IsDefined(playerPuppet) {
      return false;
    };
    if freeze {
      ttc.SetThreatBeliefAccuracy(playerPuppet, 1.00);
      ttc.RequestThreatBeliefAccuracyMinValue(playerPuppet, n"TrackedBySecuritySystemAgent", 1.00);
      TargetTrackingExtension.SetThreatPersistence(playerPuppet, this, true, EnumInt(PersistenceSource.TrackedBySecuritySystemAgent));
    } else {
      ttc.RemoveThreatBeliefAccuracyMinValue(playerPuppet, n"TrackedBySecuritySystemAgent");
      TargetTrackingExtension.SetThreatPersistence(playerPuppet, this, false, EnumInt(PersistenceSource.TrackedBySecuritySystemAgent));
    };
    return true;
  }

  protected cb func OnPlayerDetectionChangedEvent(evt: ref<PlayerDetectionChangedEvent>) -> Bool {
    this.SetDetectionPercentage(evt.newDetectionValue);
  }

  public final func SetDetectionPercentage(percent: Float) -> Void {
    let bb: ref<IBlackboard> = this.GetPuppetStateBlackboard();
    bb.SetFloat(GetAllBlackboardDefs().PuppetState.DetectionPercentage, percent);
  }

  public final func GetDetectionPercentage() -> Float {
    let bb: ref<IBlackboard> = this.GetPuppetStateBlackboard();
    return bb.GetFloat(GetAllBlackboardDefs().PuppetState.DetectionPercentage);
  }

  private final func InitThreatsCurves() -> Void {
    let targetTrackerComponent: ref<TargetTrackerComponent> = this.GetTargetTrackerComponent();
    if IsDefined(targetTrackerComponent) {
      targetTrackerComponent.SetThreatPriorityDistCurve(n"ThreatValueDistModifier");
      targetTrackerComponent.SetThreatPriorityDmgCurve(n"ThreatValueDmgModifier");
      targetTrackerComponent.SetThreatPriorityHisteresisCurve(n"ThreatValueHisteresisModifier");
      targetTrackerComponent.SetThreatPriorityAttackersCurve(n"ThreatValueAttackersModifier");
    };
  }

  public func Kill(opt instigator: wref<GameObject>, opt skipNPCDeathAnim: Bool, opt disableNPCRagdoll: Bool) -> Void {
    if GameInstance.GetStatsSystem(this.GetOwner().GetGame()).GetStatValue(Cast(this.GetOwner().GetEntityID()), gamedataStatType.IsInvulnerable) > 0.00 {
      return;
    };
    this.MarkForDeath();
    this.SetIsDefeatMechanicActive(false);
    if skipNPCDeathAnim {
      this.SetSkipDeathAnimation(true);
    };
    if disableNPCRagdoll {
      this.SetDisableRagdoll(true);
    };
    this.Kill(instigator, skipNPCDeathAnim, disableNPCRagdoll);
  }

  public const func IsDead() -> Bool {
    return GameInstance.GetStatPoolsSystem(this.GetGame()).HasStatPoolValueReachedMin(Cast(this.GetEntityID()), gamedataStatPoolType.Health);
  }

  public final func MarkForDeath() -> Void {
    this.m_shouldDie = true;
  }

  public final const func IsAboutToDie() -> Bool {
    return this.m_shouldDie;
  }

  public final func MarkForDefeat() -> Void {
    this.m_shouldBeDefeated = true;
  }

  public final const func IsAboutToBeDefeated() -> Bool {
    return this.m_shouldBeDefeated;
  }

  public final const func IsDefeatMechanicActive() -> Bool {
    return (this.GetPS() as ScriptedPuppetPS).IsDefeatMechanicActive();
  }

  public final func SetIsDefeatMechanicActive(isDefeatMechanicActive: Bool, opt isInitialisation: Bool) -> Void {
    (this.GetPS() as ScriptedPuppetPS).SetIsDefeatMechanicActive(isDefeatMechanicActive);
    if !isInitialisation {
      if isDefeatMechanicActive {
        GameInstance.GetStatPoolsSystem(this.GetGame()).RequestSettingStatPoolValueCustomLimit(Cast(this.GetEntityID()), gamedataStatPoolType.Health, 0.10, null);
      } else {
        GameInstance.GetStatPoolsSystem(this.GetGame()).RequestSettingStatPoolValueCustomLimit(Cast(this.GetEntityID()), gamedataStatPoolType.Health, 0.00, null);
      };
    };
  }

  public final func GetAffiliation() -> String {
    let affiliation: wref<Affiliation_Record> = TweakDBInterface.GetCharacterRecord(this.GetRecordID()).Affiliation();
    if !IsDefined(affiliation) {
      return "Unknown";
    };
    return ToString(affiliation.EnumName());
  }

  public final func OnGodModeChanged() -> Void {
    if this.CanEnableRagdollComponent() {
      if IsDefined(this.m_npcRagdollComponent) {
        this.m_npcRagdollComponent.Toggle(true);
      };
    } else {
      if IsDefined(this.m_npcRagdollComponent) {
        this.m_npcRagdollComponent.Toggle(false);
      };
    };
  }

  public final const func CanEnableRagdollComponent() -> Bool {
    if GameInstance.GetGodModeSystem(this.GetGame()).HasGodMode(this.GetEntityID(), gameGodModeType.Invulnerable) {
      return false;
    };
    if GameInstance.GetGodModeSystem(this.GetGame()).HasGodMode(this.GetEntityID(), gameGodModeType.Immortal) {
      return false;
    };
    if StatusEffectSystem.ObjectHasStatusEffectWithTag(this, n"DisableRagdoll") {
      return false;
    };
    if this.IsBoss() {
      return false;
    };
    return true;
  }

  protected cb func OnDisableRagdollComponentEvent(evt: ref<DisableRagdollComponentEvent>) -> Bool {
    if IsDefined(this.m_npcRagdollComponent) {
      this.m_npcRagdollComponent.Toggle(false);
    };
  }

  public final func SetDisableRagdoll(disableRagdoll: Bool, opt force: Bool, opt leaveRagdollEnabled: Bool) -> Void {
    if IsDefined(this.m_npcRagdollComponent) {
      if disableRagdoll {
        this.m_npcRagdollComponent.Toggle(false);
      } else {
        if force {
          if !leaveRagdollEnabled && !this.m_npcRagdollComponent.IsEnabled() {
            this.m_disableRagdollAfterRecovery = true;
          };
          this.m_npcRagdollComponent.Toggle(true);
        } else {
          if this.CanEnableRagdollComponent() {
            this.m_npcRagdollComponent.Toggle(true);
          };
        };
      };
    };
  }

  public final static func SendNPCHitDataTrackingRequest(owner: ref<NPCPuppet>, telemetryData: ENPCTelemetryData, modifyValue: Int32) -> Void {
    let request: ref<ModifyNPCTelemetryVariable> = new ModifyNPCTelemetryVariable();
    request.dataTrackingFact = telemetryData;
    request.value = modifyValue;
    GameInstance.GetScriptableSystemsContainer(owner.GetGame()).Get(n"DataTrackingSystem").QueueRequest(request);
  }

  public final const func CheckStubData(data: NPCstubData) -> Bool {
    let entityStubPSID: PersistentID = CreatePersistentID(this.GetEntityID(), gameEntityStubComponentPS.GetPSComponentName());
    let entityStubPS: ref<gameEntityStubComponentPS> = GameInstance.GetPersistencySystem(this.GetGame()).GetConstAccessToPSObject(entityStubPSID, n"gameEntityStubComponentPS") as gameEntityStubComponentPS;
    let spawnerID: EntityID = entityStubPS.GetSpawnerID();
    let entryID: CName = entityStubPS.GetOwnerCommunityEntryName();
    if spawnerID == data.spawnerID && Equals(entryID, data.entryID) {
      return true;
    };
    return false;
  }

  protected cb func OnItemAddedToSlot(evt: ref<ItemAddedToSlot>) -> Bool {
    let equippedItemType: gamedataItemType;
    let itemRecord: ref<Item_Record>;
    let weaponRecord: ref<WeaponItem_Record>;
    let hasTechWeapon: Bool = false;
    super.OnItemAddedToSlot(evt);
    NPCPuppet.SetAnimWrapperBasedOnEquippedItem(this, evt.GetSlotID(), evt.GetItemID(), 1.00);
    this.SetAnimWrappersOnItem(GameInstance.GetTransactionSystem(this.GetGame()).GetItemInSlotByItemID(this, evt.GetItemID()), evt.GetSlotID());
    this.SetWeaponFx();
    AIActionHelper.QueuePreloadCoreAnimationsEvent(this);
    AIActionHelper.QueuePreloadBaseAnimationsEvent(this);
    itemRecord = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(evt.GetItemID()));
    equippedItemType = itemRecord.ItemType().Type();
    if Equals(equippedItemType, gamedataItemType.Gad_Grenade) {
      BaseGrenade.SendGrenadeAnimFeatureChangeEvent(this, evt.GetItemID());
    };
    if !IsFinal() {
      GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerMainGameObject() as PlayerPuppet.DEBUG_Visualizer.ShowEquipEndText(this, evt.GetSlotID(), evt.GetItemID());
    };
    if WeaponObject.IsRanged(evt.GetItemID()) {
      weaponRecord = itemRecord as WeaponItem_Record;
      if IsDefined(weaponRecord) && IsDefined(weaponRecord.Evolution()) && Equals(weaponRecord.Evolution().Type(), gamedataWeaponEvolution.Tech) {
        hasTechWeapon = true;
      };
    };
    if IsDefined(this.GetSensorObjectComponent()) {
      this.GetSensorObjectComponent().SetHasPierceableWapon(hasTechWeapon);
    };
    if IsDefined(this.GetSensesComponent()) {
      this.GetSensesComponent().SetHasPierceableWapon(hasTechWeapon);
    };
    AIComponent.InvokeBehaviorCallback(this, n"OnItemAddedToSlotConditionEvaluation");
  }

  private final func SetWeaponFx() -> Void {
    let evt: ref<UpdateMeleeTrailEffectEvent> = new UpdateMeleeTrailEffectEvent();
    evt.instigator = this;
    let item: ref<ItemObject> = GameInstance.GetTransactionSystem(this.GetGame()).GetItemInSlot(this, t"AttachmentSlots.WeaponRight");
    if IsDefined(item) {
      item.QueueEvent(evt);
    };
    item = GameInstance.GetTransactionSystem(this.GetGame()).GetItemInSlot(this, t"AttachmentSlots.WeaponLeft");
    if IsDefined(item) {
      item.QueueEvent(evt);
    };
  }

  protected cb func OnItemRemovedFromSlot(evt: ref<ItemRemovedFromSlot>) -> Bool {
    let weaponTag: CName;
    super.OnItemRemovedFromSlot(evt);
    if this.IsPaperdoll() {
      NPCPuppet.SetAnimWrapperBasedOnEquippedItem(this, evt.GetSlotID(), evt.GetItemID(), 0.00);
    } else {
      if ScriptedPuppet.IsActive(this) {
        weaponTag = AIActionHelper.GetAnimWrapperNameBasedOnItemTag(evt.GetItemID());
        if !AIScriptSquad.HasOrder(this, n"Equip") || !IsNameValid(weaponTag) {
          NPCPuppet.SetAnimWrapperBasedOnEquippedItem(this, evt.GetSlotID(), evt.GetItemID(), 0.00);
        };
      };
    };
  }

  private final func SetAnimWrapperWeightBasedOnFaction() -> Void {
    let animWrappers: array<CName>;
    let i: Int32;
    let affiliation: wref<Affiliation_Record> = TweakDBInterface.GetCharacterRecord(this.GetRecordID()).Affiliation();
    if !IsDefined(affiliation) {
      return;
    };
    animWrappers = affiliation.AnimWrappers();
    i = 0;
    while i < ArraySize(animWrappers) {
      if IsNameValid(animWrappers[i]) {
        AnimationControllerComponent.SetAnimWrapperWeight(this, animWrappers[i], 1.00);
      };
      i += 1;
    };
  }

  private final func SetAnimWrappersOnItem(item: wref<ItemObject>, slotID: TweakDBID) -> Void {
    let affiliation: wref<Affiliation_Record>;
    let animWrappers: array<CName>;
    let i: Int32;
    if !IsDefined(item) {
      return;
    };
    AnimationControllerComponent.SetAnimWrapperWeight(item, NPCStatesComponent.GetAnimWrapperNameBasedOnStanceState(IntEnum(this.GetPuppetStateBlackboard().GetInt(GetAllBlackboardDefs().PuppetState.Stance))), 1.00);
    AnimationControllerComponent.SetAnimWrapperWeight(item, NPCStatesComponent.GetAnimWrapperNameBasedOnHighLevelState(IntEnum(this.GetPuppetStateBlackboard().GetInt(GetAllBlackboardDefs().PuppetState.HighLevel))), 1.00);
    affiliation = TweakDBInterface.GetCharacterRecord(this.GetRecordID()).Affiliation();
    if !IsDefined(affiliation) {
      return;
    };
    animWrappers = affiliation.AnimWrappers();
    i = 0;
    while i < ArraySize(animWrappers) {
      if IsNameValid(animWrappers[i]) {
        AnimationControllerComponent.SetAnimWrapperWeight(item, animWrappers[i], 1.00);
      };
      i += 1;
    };
  }

  public final static func SetAnimWrapperBasedOnEquippedItem(npc: wref<NPCPuppet>, const slotID: TweakDBID, const itemID: ItemID, const value: Float) -> Void {
    if slotID == t"AttachmentSlots.WeaponRight" {
      AnimationControllerComponent.SetAnimWrapperWeightOnOwnerAndItems(npc, n"WeaponRight", value);
      AnimationControllerComponent.SetAnimWrapperWeight(npc, AIActionHelper.GetAnimWrapperNameBasedOnItemID(itemID), value);
      AnimationControllerComponent.SetAnimWrapperWeight(npc, AIActionHelper.GetAnimWrapperNameBasedOnItemTag(itemID), value);
      AIActionHelper.SendItemHandling(npc, TweakDBInterface.GetItemRecord(ItemID.GetTDBID(itemID)), n"rightHandItemHandling", value > 0.00 ? true : false);
      if Equals(AIActionHelper.GetAnimWrapperNameBasedOnItemID(itemID), n"Wea_Fists") {
        AnimationControllerComponent.SetAnimWrapperWeight(npc, n"Wea_Hammer", 0.00);
      };
    } else {
      if slotID == t"AttachmentSlots.WeaponLeft" {
        if NotEquals(AIActionHelper.GetAnimWrapperNameBasedOnItemID(itemID), n"Gad_Grenade") {
          AnimationControllerComponent.SetAnimWrapperWeightOnOwnerAndItems(npc, n"WeaponLeft", value);
        };
        AnimationControllerComponent.SetAnimWrapperWeight(npc, AIActionHelper.GetAnimWrapperNameBasedOnItemID(itemID), value);
        AnimationControllerComponent.SetAnimWrapperWeight(npc, AIActionHelper.GetAnimWrapperNameBasedOnItemTag(itemID), value);
        AIActionHelper.SendItemHandling(npc, TweakDBInterface.GetItemRecord(ItemID.GetTDBID(itemID)), n"leftHandItemHandling", value > 0.00 ? true : false);
      };
    };
  }

  private final func SetRandomAnimWrappersForLocomotion() -> Void {
    switch RandRange(1, 15) {
      case 1:
        AnimationControllerComponent.SetAnimWrapperWeight(this, n"LocomotionCycle01", 1.00);
        break;
      case 2:
        AnimationControllerComponent.SetAnimWrapperWeight(this, n"LocomotionCycle02", 1.00);
        break;
      case 3:
        AnimationControllerComponent.SetAnimWrapperWeight(this, n"LocomotionCycle03", 1.00);
        break;
      case 4:
        AnimationControllerComponent.SetAnimWrapperWeight(this, n"LocomotionCycle04", 1.00);
        break;
      case 5:
        AnimationControllerComponent.SetAnimWrapperWeight(this, n"LocomotionCycle05", 1.00);
        break;
      case 6:
        AnimationControllerComponent.SetAnimWrapperWeight(this, n"LocomotionCycle06", 1.00);
        break;
      case 7:
        AnimationControllerComponent.SetAnimWrapperWeight(this, n"LocomotionCycle07", 1.00);
        break;
      case 8:
        AnimationControllerComponent.SetAnimWrapperWeight(this, n"LocomotionCycle08", 1.00);
        break;
      case 9:
        AnimationControllerComponent.SetAnimWrapperWeight(this, n"LocomotionCycle09", 1.00);
        break;
      case 10:
        AnimationControllerComponent.SetAnimWrapperWeight(this, n"LocomotionCycle10", 1.00);
        break;
      case 11:
        AnimationControllerComponent.SetAnimWrapperWeight(this, n"LocomotionCycle11", 1.00);
        break;
      case 12:
        AnimationControllerComponent.SetAnimWrapperWeight(this, n"LocomotionCycle12", 1.00);
        break;
      case 13:
        AnimationControllerComponent.SetAnimWrapperWeight(this, n"LocomotionCycle13", 1.00);
        break;
      case 14:
        AnimationControllerComponent.SetAnimWrapperWeight(this, n"LocomotionCycle14", 1.00);
        break;
      default:
    };
    if this.MatchVisualTag(n"anim_Lowlife") {
      AnimationControllerComponent.SetAnimWrapperWeight(this, n"LowlifeLocomotion", 1.00);
    };
    if this.MatchVisualTag(n"anim_MidCorp") {
      AnimationControllerComponent.SetAnimWrapperWeight(this, n"MidCorpLocomotion", 1.00);
    };
    if this.MatchVisualTag(n"anim_Posh") {
      AnimationControllerComponent.SetAnimWrapperWeight(this, n"PoshLocomotion", 1.00);
    };
    if this.MatchVisualTag(n"anim_DirtGirl") {
      AnimationControllerComponent.SetAnimWrapperWeight(this, n"DirtGirlLocomotion", 1.00);
    };
    if this.MatchVisualTag(n"anim_Homeless") {
      AnimationControllerComponent.SetAnimWrapperWeight(this, n"HomelessLocomotion", 1.00);
    };
    if this.MatchVisualTag(n"anim_Freak") {
      AnimationControllerComponent.SetAnimWrapperWeight(this, n"FreakLocomotion", 1.00);
    };
    if this.MatchVisualTag(n"anim_Junkie") {
      AnimationControllerComponent.SetAnimWrapperWeight(this, n"JunkieLocomotion", 1.00);
    };
    if this.MatchVisualTag(n"anim_Mallrat") {
      AnimationControllerComponent.SetAnimWrapperWeight(this, n"MallratLocomotion", 1.00);
    };
    if this.MatchVisualTag(n"anim_Worker") {
      AnimationControllerComponent.SetAnimWrapperWeight(this, n"WorkerLocomotion", 1.00);
    };
    if this.MatchVisualTag(n"anim_Borg") {
      AnimationControllerComponent.SetAnimWrapperWeight(this, n"BorgLocomotion", 1.00);
    };
    if this.MatchVisualTag(n"anim_Fam") {
      AnimationControllerComponent.SetAnimWrapperWeight(this, n"FamLocomotion", 1.00);
    };
    if this.MatchVisualTag(n"anim_Cowboy") {
      AnimationControllerComponent.SetAnimWrapperWeight(this, n"CowboyLocomotion", 1.00);
    };
    if this.MatchVisualTag(n"anim_Tomboy") {
      AnimationControllerComponent.SetAnimWrapperWeight(this, n"TomboyLocomotion", 1.00);
    };
    if this.MatchVisualTag(n"anim_Redneck") {
      AnimationControllerComponent.SetAnimWrapperWeight(this, n"RedneckLocomotion", 1.00);
    };
    if this.MatchVisualTag(n"anim_Tennant") {
      AnimationControllerComponent.SetAnimWrapperWeight(this, n"TennantLocomotion", 1.00);
    };
    if this.MatchVisualTag(n"anim_Youngster") {
      AnimationControllerComponent.SetAnimWrapperWeight(this, n"YoungsterLocomotion", 1.00);
    };
    if this.MatchVisualTag(n"anim_LowCorp") {
      AnimationControllerComponent.SetAnimWrapperWeight(this, n"LowCorpLocomotion", 1.00);
    };
    if this.MatchVisualTag(n"anim_Elder") {
      AnimationControllerComponent.SetAnimWrapperWeight(this, n"ElderLocomotion", 1.00);
    };
    if this.MatchVisualTag(n"anim_Nightlife") {
      AnimationControllerComponent.SetAnimWrapperWeight(this, n"NightlifeLocomotion", 1.00);
    };
    if this.MatchVisualTag(n"Anim_Monk") {
      AnimationControllerComponent.SetAnimWrapperWeight(this, n"MonkLocomotion", 1.00);
    };
    if this.MatchVisualTag(n"anim_Drunk") {
      AnimationControllerComponent.SetAnimWrapperWeight(this, n"DrunkLocomotion", 1.00);
    };
    if this.MatchVisualTag(n"anim_Beaten") {
      AnimationControllerComponent.SetAnimWrapperWeight(this, n"BeatenLocomotion", 1.00);
    };
  }

  protected cb func OnSetPuppetTargetingPlayer(evt: ref<OnBeingTarget>) -> Bool {
    if IsDefined(evt.objectThatTargets as NPCPuppet) {
      this.SetPuppetTargetingPlayer(true);
    } else {
      if IsDefined(evt.objectThatTargets as NPCPuppet) && evt.noLongerTarget {
        this.SetPuppetTargetingPlayer(false);
      };
    };
  }

  private final func SetPuppetTargetingPlayer(isTargeting: Bool) -> Void {
    this.m_isTargetingPlayer = isTargeting;
    let i: Int32 = 0;
    while i < ArraySize(this.m_listeners) {
      this.m_listeners[i].OnIsTrackingPlayerChanged(isTargeting);
      i += 1;
    };
  }

  public final const func IsPuppetTargetingPlayer() -> Bool {
    return this.m_isTargetingPlayer;
  }

  public final static func ChangeHighLevelState(obj: ref<GameObject>, newState: gamedataNPCHighLevelState) -> Void {
    let signal: ref<NPCStateChangeSignal>;
    let signalId: Uint16;
    let signalTable: ref<gameBoolSignalTable>;
    let owner: ref<NPCPuppet> = obj as NPCPuppet;
    if !IsDefined(owner) {
      return;
    };
    if Equals(owner.GetHighLevelStateFromBlackboard(), newState) {
      return;
    };
    signalTable = owner.GetSignalTable();
    signal = new NPCStateChangeSignal();
    signalId = signalTable.GetOrCreateSignal(n"NPCStateChangeSignal");
    signal.m_highLevelState = newState;
    signal.m_highLevelStateValid = true;
    signalTable.Set(signalId, false);
    signalTable.SetWithData(signalId, signal);
    signalTable.Set(signalId, true);
  }

  public final static func ChangeUpperBodyState(obj: ref<GameObject>, newState: gamedataNPCUpperBodyState) -> Void {
    let signal: ref<NPCStateChangeSignal>;
    let signalId: Uint16;
    let signalTable: ref<gameBoolSignalTable>;
    let owner: ref<NPCPuppet> = obj as NPCPuppet;
    if !IsDefined(owner) {
      return;
    };
    if Equals(owner.GetUpperBodyStateFromBlackboard(), newState) {
      return;
    };
    signalTable = owner.GetSignalTable();
    signal = new NPCStateChangeSignal();
    signalId = signalTable.GetOrCreateSignal(n"NPCStateChangeSignal");
    signal.m_upperBodyState = newState;
    signal.m_upperBodyStateValid = true;
    signalTable.Set(signalId, false);
    signalTable.SetWithData(signalId, signal);
    signalTable.Set(signalId, true);
  }

  public final static func ChangeStanceState(obj: ref<GameObject>, newState: gamedataNPCStanceState) -> Void {
    let signal: ref<NPCStateChangeSignal>;
    let signalId: Uint16;
    let signalTable: ref<gameBoolSignalTable>;
    let owner: ref<NPCPuppet> = obj as NPCPuppet;
    if !IsDefined(owner) {
      return;
    };
    if Equals(owner.GetStanceStateFromBlackboard(), newState) {
      return;
    };
    signalTable = owner.GetSignalTable();
    signal = new NPCStateChangeSignal();
    signalId = signalTable.GetOrCreateSignal(n"NPCStateChangeSignal");
    signal.m_stanceState = newState;
    signal.m_stanceStateValid = true;
    signalTable.Set(signalId, false);
    signalTable.SetWithData(signalId, signal);
    signalTable.Set(signalId, true);
  }

  public final static func ChangeHitReactionModeState(obj: ref<GameObject>, newState: EHitReactionMode) -> Void {
    let signal: ref<NPCStateChangeSignal>;
    let signalId: Uint16;
    let signalTable: ref<gameBoolSignalTable>;
    let owner: ref<NPCPuppet> = obj as NPCPuppet;
    if !IsDefined(owner) {
      return;
    };
    if Equals(owner.GetHitReactionModeFromBlackboard(), newState) {
      return;
    };
    signalTable = owner.GetSignalTable();
    signal = new NPCStateChangeSignal();
    signalId = signalTable.GetOrCreateSignal(n"NPCStateChangeSignal");
    signal.m_hitReactionModeState = newState;
    signal.m_hitReactionModeStateValid = true;
    signalTable.Set(signalId, false);
    signalTable.SetWithData(signalId, signal);
    signalTable.Set(signalId, true);
  }

  public final static func ChangeDefenseModeState(obj: ref<GameObject>, newState: gamedataDefenseMode) -> Void {
    let signal: ref<NPCStateChangeSignal>;
    let signalId: Uint16;
    let signalTable: ref<gameBoolSignalTable>;
    let owner: ref<NPCPuppet> = obj as NPCPuppet;
    if !IsDefined(owner) {
      return;
    };
    if Equals(owner.GetDefenseModeStateFromBlackboard(), newState) {
      return;
    };
    signalTable = owner.GetSignalTable();
    signal = new NPCStateChangeSignal();
    signalId = signalTable.GetOrCreateSignal(n"NPCStateChangeSignal");
    signal.m_defenseMode = newState;
    signal.m_defenseModeValid = true;
    signalTable.Set(signalId, false);
    signalTable.SetWithData(signalId, signal);
    signalTable.Set(signalId, true);
  }

  public final static func ChangeLocomotionMode(obj: ref<GameObject>, newState: gamedataLocomotionMode) -> Void {
    let signalTable: ref<gameBoolSignalTable> = (obj as NPCPuppet).GetSignalTable();
    let signal: ref<NPCStateChangeSignal> = new NPCStateChangeSignal();
    let signalId: Uint16 = signalTable.GetOrCreateSignal(n"NPCStateChangeSignal");
    signal.m_locomotionMode = newState;
    signal.m_locomotionModeValid = true;
    signalTable.Set(signalId, false);
    signalTable.SetWithData(signalId, signal);
    signalTable.Set(signalId, true);
  }

  public final static func ChangeBehaviorState(obj: ref<GameObject>, newState: gamedataNPCBehaviorState) -> Void {
    let signalTable: ref<gameBoolSignalTable> = (obj as NPCPuppet).GetSignalTable();
    let signal: ref<NPCStateChangeSignal> = new NPCStateChangeSignal();
    let signalId: Uint16 = signalTable.GetOrCreateSignal(n"NPCStateChangeSignal");
    signal.m_behaviorState = newState;
    signal.m_behaviorStateValid = true;
    signalTable.Set(signalId, false);
    signalTable.SetWithData(signalId, signal);
    signalTable.Set(signalId, true);
  }

  public final static func ChangePhaseState(obj: ref<GameObject>, newState: ENPCPhaseState) -> Void {
    let signalTable: ref<gameBoolSignalTable> = (obj as NPCPuppet).GetSignalTable();
    let signal: ref<NPCStateChangeSignal> = new NPCStateChangeSignal();
    let signalId: Uint16 = signalTable.GetOrCreateSignal(n"NPCStateChangeSignal");
    signal.m_phaseState = newState;
    signal.m_phaseStateValid = true;
    signalTable.Set(signalId, false);
    signalTable.SetWithData(signalId, signal);
    signalTable.Set(signalId, true);
  }

  public final static func ChangeForceRagdollOnDeath(obj: ref<GameObject>, value: Bool) -> Void {
    let signalTable: ref<gameBoolSignalTable> = (obj as NPCPuppet).GetSignalTable();
    let signal: ref<ForcedRagdollDeathSignal> = new ForcedRagdollDeathSignal();
    let signalId: Uint16 = signalTable.GetOrCreateSignal(n"ForcedRagdollDeathSignal");
    signal.m_value = value;
    signalTable.Set(signalId, false);
    signalTable.SetWithData(signalId, signal);
    signalTable.Set(signalId, true);
  }

  protected cb func OnStatusEffectApplied(evt: ref<ApplyStatusEffectEvent>) -> Bool {
    let si: ref<SquadScriptInterface>;
    let ttc: ref<TargetTrackerComponent>;
    let gmplTags: array<CName> = evt.staticData.GameplayTags();
    if ArrayContains(gmplTags, n"Quickhack") {
      this.OnQuickHackEffectApplied(evt);
    };
    if ArrayContains(gmplTags, n"Blind") {
      SenseComponent.RequestSecondaryPresetChange(this, t"Senses.Blind");
      ttc = this.GetTargetTrackerComponent();
      if IsDefined(ttc) {
        this.SwitchTargetPlayerTrackedAccuracy(ttc, false);
        ttc.SetThreatBeliefAccuracy(this, 0.00);
      };
    };
    if ArrayContains(gmplTags, n"ClearThreats") {
      ttc = this.GetTargetTrackerComponent();
      if IsDefined(ttc) {
        ttc.ClearThreats();
      };
    };
    if ArrayContains(gmplTags, n"ResetSquadSync") {
      if AISquadHelper.GetSquadMemberInterface(this, si) {
        si.Leave(this);
        si.Join(this);
      };
    };
    if ArrayContains(gmplTags, n"DisableRagdoll") {
      this.SetDisableRagdoll(true);
    };
    if ArrayContains(gmplTags, n"Defeated") {
      this.SetIsDefeatMechanicActive(false);
      StatusEffectHelper.ApplyStatusEffect(this, t"BaseStatusEffect.InvulnerableAfterDefeated");
    };
    switch evt.staticData.StatusEffectType().Type() {
      case gamedataStatusEffectType.DefeatedWithRecover:
        this.OnDefeatedWithRecoverStatusEffectApplied();
        break;
      default:
    };
    if this.ShouldDelayStatusEffectApplication(evt) {
      this.DelayStatusEffectApplication(evt);
    } else {
      this.ProcessStatusEffectApplication(evt);
    };
  }

  private final func ShouldDelayStatusEffectApplication(evt: ref<ApplyStatusEffectEvent>) -> Bool {
    if TDBID.IsValid(evt.staticData.AIData().GetID()) {
      if evt.staticData.AIData().ShouldDelayStatusEffectApplication() {
        return true;
      };
    };
    return false;
  }

  private final func ProcessStatusEffectApplication(evt: ref<ApplyStatusEffectEvent>) -> Void {
    let newStatusEffectPrio: Float;
    let topPrioStatusEffectPrio: Float;
    let topProEffect: ref<StatusEffect>;
    this.OnStatusEffectApplied(evt);
    if StatusEffectSystem.ObjectHasStatusEffectWithTag(this, n"Braindance") || StatusEffectSystem.ObjectHasStatusEffect(this, t"BaseStatusEffect.Drunk") {
      return;
    };
    if evt.staticData.AIData().ShouldProcessAIDataOnReapplication() && evt.staticData.GetID() == this.m_cachedStatusEffectAnim.GetID() {
      return;
    };
    if !evt.isNewApplication && !evt.staticData.AIData().ShouldProcessAIDataOnReapplication() {
      return;
    };
    if IsDefined(evt.staticData) && IsDefined(evt.staticData.AIData()) {
      newStatusEffectPrio = evt.staticData.AIData().Priority();
      topProEffect = StatusEffectHelper.GetTopPriorityEffect(this, evt.staticData.StatusEffectType().Type(), true);
      if IsDefined(topProEffect) {
        topPrioStatusEffectPrio = topProEffect.GetRecord().AIData().Priority();
      };
    };
    if Equals(evt.staticData.StatusEffectType().Type(), gamedataStatusEffectType.Defeated) {
      if ScriptedPuppet.CanRagdoll(this) {
        this.QueueEvent(new UncontrolledMovementStartEvent());
      };
      this.TriggerDefeatedBehavior(evt);
    } else {
      if Equals(evt.staticData.StatusEffectType().Type(), gamedataStatusEffectType.DefeatedWithRecover) {
        this.TriggerStatusEffectBehavior(evt, true);
      } else {
        if Equals(evt.staticData.StatusEffectType().Type(), gamedataStatusEffectType.UncontrolledMovement) {
          this.OnUncontrolledMovementStatusEffectAdded(evt);
        } else {
          if (newStatusEffectPrio > topPrioStatusEffectPrio || newStatusEffectPrio == topPrioStatusEffectPrio && !IsDefined(this.m_cachedStatusEffectAnim)) && StatusEffectHelper.CheckStatusEffectBehaviorPrereqs(this, evt.staticData) {
            if this.IsCrowd() && Equals(this.GetHighLevelStateFromBlackboard(), gamedataNPCHighLevelState.Fear) {
              return;
            };
            this.TriggerStatusEffectBehavior(evt);
          };
        };
      };
    };
    this.CacheStatusEffectAppliedByPlayer(evt);
  }

  private final func OnQuickHackEffectApplied(evt: ref<ApplyStatusEffectEvent>) -> Void {
    let i: Int32;
    let squadMate: ref<ScriptedPuppet>;
    let squadMates: array<wref<Entity>>;
    let value: Float;
    let gmplTags: array<CName> = evt.staticData.GameplayTags();
    this.quickHackEffectsApplied += 1u;
    if this.quickHackEffectsApplied == 1u {
      value = GameInstance.GetStatsSystem(this.GetGame()).GetStatValue(Cast(evt.instigatorEntityID), gamedataStatType.LowerHackingResistanceOnHack);
      if value > 0.00 {
        this.hackingResistanceMod = new gameConstantStatModifierData();
        this.hackingResistanceMod.statType = gamedataStatType.HackingResistance;
        this.hackingResistanceMod.modifierType = gameStatModifierType.Additive;
        this.hackingResistanceMod.value = value * -1.00;
        GameInstance.GetStatsSystem(this.GetGame()).AddModifier(Cast(this.GetEntityID()), this.hackingResistanceMod);
      };
      if GameInstance.GetStatsSystem(this.GetGame()).GetStatValue(Cast(evt.instigatorEntityID), gamedataStatType.HasMadnessLvl4Passive) == 1.00 {
        StatusEffectHelper.ApplyStatusEffect(this, t"BaseStatusEffect.DoNotBlockShootingOnFriendlyFire", evt.instigatorEntityID);
      };
      if GameInstance.GetStatsSystem(this.GetGame()).GetStatValue(Cast(evt.instigatorEntityID), gamedataStatType.RemoveSprintOnQuickhack) == 1.00 {
        StatusEffectHelper.ApplyStatusEffect(this, t"BaseStatusEffect.LocomotionMalfunctionLevel4Passive", evt.instigatorEntityID);
      };
      if GameInstance.GetStatsSystem(this.GetGame()).GetStatValue(Cast(evt.instigatorEntityID), gamedataStatType.CommsNoiseJamOnQuickhack) == 1.00 {
        StatusEffectHelper.ApplyStatusEffect(this, t"BaseStatusEffect.CommsNoisePassiveEffect", evt.instigatorEntityID);
      };
    };
    if ArrayContains(gmplTags, n"SquadMemoryWipe") {
      AISquadHelper.GetSquadmates(this, squadMates);
      i = 0;
      while i < ArraySize(squadMates) {
        squadMate = squadMates[i] as ScriptedPuppet;
        if !IsDefined(squadMate) {
        } else {
          StatusEffectHelper.ApplyStatusEffect(squadMate, t"BaseStatusEffect.MemoryWipeLevel2", evt.instigatorEntityID);
        };
        i += 1;
      };
    };
    if ArrayContains(gmplTags, n"CommsNoiseJam") {
      this.SwitchTargetPlayerTrackedAccuracy(false);
    };
    if evt.instigatorEntityID == this.GetPlayerID() && !ArrayContains(gmplTags, n"Stealth") {
      GameInstance.GetDelaySystem(this.GetGame()).CancelDelay(this.m_delayNonStealthQuickHackVictimEventID);
      this.m_delayNonStealthQuickHackVictimEventID = GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, NonStealthQuickHackVictimEvent.Create(evt.instigatorEntityID), 0.10);
    };
  }

  protected cb func OnNonStealthQuickHackVictimEvent(evt: ref<NonStealthQuickHackVictimEvent>) -> Bool {
    if !NPCPuppet.RevealPlayerPositionIfNeeded(this, evt.instigatorID) {
      NPCStatesComponent.AlertPuppet(this);
    };
  }

  public final static func RevealPlayerPositionIfNeeded(ownerPuppet: wref<ScriptedPuppet>, playerID: EntityID) -> Bool {
    let evt: ref<HackPlayerEvent>;
    let player: wref<PlayerPuppet>;
    let securitySystem: ref<SecuritySystemControllerPS>;
    let securitySystemState: ESecuritySystemState;
    if !IsDefined(ownerPuppet) || !EntityID.IsDefined(playerID) {
      return false;
    };
    if StatusEffectSystem.ObjectHasStatusEffectWithTag(ownerPuppet, n"CommsNoiseJam") {
      return false;
    };
    player = GameInstance.FindEntityByID(ownerPuppet.GetGame(), playerID) as PlayerPuppet;
    if !IsDefined(player) || player.IsInCombat() {
      return false;
    };
    securitySystem = ownerPuppet.GetSecuritySystem();
    if !IsDefined(securitySystem) || ScriptedPuppet.IsBoss(ownerPuppet) {
      if NotEquals(ownerPuppet.GetHighLevelStateFromBlackboard(), gamedataNPCHighLevelState.Alerted) {
        return false;
      };
    } else {
      securitySystemState = securitySystem.GetSecurityState();
      if NotEquals(securitySystemState, ESecuritySystemState.ALERTED) && NotEquals(securitySystemState, ESecuritySystemState.COMBAT) && NotEquals(ownerPuppet.GetHighLevelStateFromBlackboard(), gamedataNPCHighLevelState.Alerted) && NotEquals(ownerPuppet.GetHighLevelStateFromBlackboard(), gamedataNPCHighLevelState.Combat) {
        return false;
      };
    };
    evt = new HackPlayerEvent();
    evt.targetID = player.GetEntityID();
    evt.netrunnerID = ownerPuppet.GetEntityID();
    evt.objectRecord = TweakDBInterface.GetObjectActionRecord(t"AIQuickHack.HackRevealPosition");
    evt.showDirectionalIndicator = false;
    evt.revealPositionAction = true;
    if IsDefined(evt.objectRecord) {
      player.QueueEvent(evt);
      return true;
    };
    return false;
  }

  protected final func TriggerDefeatedBehavior(evt: ref<ApplyStatusEffectEvent>) -> Void {
    let flags: array<EAIGateSignalFlags>;
    let repeatSignalDelay: Float;
    let repeatSignalStatModifiers: array<wref<StatModifier_Record>>;
    let tags: array<CName>;
    let priority: Float = evt.staticData.AIData().Priority();
    let statusEffectDuration: Float = StatusEffectHelper.GetStatusEffectByID(this, evt.staticData.GetID()).GetRemainingDuration();
    if statusEffectDuration < 0.00 {
      statusEffectDuration = RPGManager.GetStatRecord(gamedataStatType.MaxDuration).Max();
    };
    ArrayResize(tags, 3);
    tags[0] = n"downed";
    tags[1] = EnumValueToName(n"gamedataStatusEffectType", Cast(EnumInt(evt.staticData.StatusEffectType().Type())));
    ArrayResize(flags, 1);
    flags[0] = IntEnum(Cast(EnumValueFromString("EAIGateSignalFlags", "AIGSF_" + EnumValueToString("gamedataStatusEffectAIBehaviorFlag", Cast(EnumInt(evt.staticData.AIData().BehaviorEventFlag().Type()))))));
    evt.staticData.AIData().BehaviorSignalResendDelay(repeatSignalStatModifiers);
    repeatSignalDelay = RPGManager.CalculateStatModifiers(repeatSignalStatModifiers, this.GetGame(), this, Cast(this.GetEntityID()));
    this.SendStatusEffectSignal(priority, tags, flags, evt.staticData.GetID(), repeatSignalDelay, statusEffectDuration);
  }

  protected final func DelayStatusEffectApplication(evt: ref<ApplyStatusEffectEvent>) -> Void {
    let delayStatusEffectTimes: Vector2 = TweakDBInterface.GetVector2(t"AIGeneralSettings.delayStatusEffectApplicationTime", new Vector2(0.10, 0.40));
    let finalDelayTime: Float = RandRangeF(delayStatusEffectTimes.X, delayStatusEffectTimes.Y);
    let delayedSEReactionEvent: ref<DelayedStatusEffectApplicationEvent> = new DelayedStatusEffectApplicationEvent();
    delayedSEReactionEvent.statusEffectEvent = evt;
    GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, delayedSEReactionEvent, finalDelayTime);
  }

  protected final func TriggerStatusEffectBehavior(evt: ref<ApplyStatusEffectEvent>, opt alwaysTrigger: Bool) -> Void {
    let flags: array<EAIGateSignalFlags>;
    let priority: Float;
    let repeatSignalDelay: Float;
    let repeatSignalStatModifiers: array<wref<StatModifier_Record>>;
    let statusEffectDuration: Float;
    let tags: array<CName>;
    if !IsDefined(evt.staticData) || !IsDefined(evt.staticData.AIData()) {
      return;
    };
    priority = evt.staticData.AIData().Priority();
    statusEffectDuration = StatusEffectHelper.GetStatusEffectByID(this, evt.staticData.GetID()).GetRemainingDuration();
    if statusEffectDuration < 0.00 {
      statusEffectDuration = RPGManager.GetStatRecord(gamedataStatType.MaxDuration).Max();
    };
    ArrayResize(tags, 3);
    tags[0] = n"reactive";
    tags[1] = n"statusEffects";
    tags[2] = EnumValueToName(n"gamedataStatusEffectType", Cast(EnumInt(evt.staticData.StatusEffectType().Type())));
    evt.staticData.AIData().BehaviorSignalResendDelay(repeatSignalStatModifiers);
    repeatSignalDelay = RPGManager.CalculateStatModifiers(repeatSignalStatModifiers, this.GetGame(), this, Cast(this.GetEntityID()));
    if alwaysTrigger {
      this.SendStatusEffectSignal(priority, tags, flags, evt.staticData.GetID(), repeatSignalDelay, statusEffectDuration);
    } else {
      if !ScriptedPuppet.IsOnOffMeshLink(this) && !NPCPuppet.IsUnstoppable(this) {
        this.SendStatusEffectSignal(priority, tags, flags, evt.staticData.GetID(), repeatSignalDelay, statusEffectDuration);
        if IsDefined(this.m_pendingSEEvent) {
          this.m_pendingSEEvent = null;
        };
      } else {
        this.m_pendingSEEvent = evt;
      };
    };
  }

  protected final func SendStatusEffectSignal(priority: Float, tags: array<CName>, flags: array<EAIGateSignalFlags>, statusEffectID: TweakDBID, repeatSignalDelay: Float, remainingStatusEffectDuration: Float) -> Void {
    let signal: AIGateSignal;
    signal.priority = priority;
    signal.lifeTime = remainingStatusEffectDuration;
    let i: Int32 = 0;
    while i < ArraySize(tags) {
      AIGateSignal.AddTag(signal, tags[i]);
      i += 1;
    };
    i = 0;
    while i < ArraySize(flags) {
      AIGateSignal.AddFlag(signal, Cast(flags[i]));
      i += 1;
    };
    this.GetSignalHandlerComponent().AddSignal(signal, false);
    this.m_lastStatusEffectSignalSent = TweakDBInterface.GetStatusEffectRecord(statusEffectID);
    this.TryRepeatStatusEffectSignal(priority, tags, flags, statusEffectID, repeatSignalDelay, remainingStatusEffectDuration);
  }

  protected final func TryRepeatStatusEffectSignal(priority: Float, tags: array<CName>, flags: array<EAIGateSignalFlags>, statusEffectID: TweakDBID, repeatSignalDelay: Float, remainingStatusEffectDuration: Float) -> Void {
    let emptyDelayID: DelayID;
    let repeatSignalEvent: ref<StatusEffectSignalEvent>;
    if repeatSignalDelay <= 0.00 || remainingStatusEffectDuration < repeatSignalDelay {
      return;
    };
    repeatSignalEvent = new StatusEffectSignalEvent();
    repeatSignalEvent.priority = priority;
    repeatSignalEvent.tags = tags;
    repeatSignalEvent.flags = flags;
    repeatSignalEvent.statusEffectID = statusEffectID;
    repeatSignalEvent.repeatSignalDelay = repeatSignalDelay;
    if this.m_resendStatusEffectSignalDelayID != emptyDelayID {
      GameInstance.GetDelaySystem(this.GetGame()).CancelDelay(this.m_resendStatusEffectSignalDelayID);
      this.m_resendStatusEffectSignalDelayID = emptyDelayID;
    };
    this.m_resendStatusEffectSignalDelayID = GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, repeatSignalEvent, repeatSignalDelay);
  }

  protected cb func OnStatusEffectSignal(evt: ref<StatusEffectSignalEvent>) -> Bool {
    let statusEffect: ref<StatusEffect> = StatusEffectHelper.GetStatusEffectByID(this, evt.statusEffectID);
    if IsDefined(statusEffect) {
      if !ArrayContains(evt.tags, n"reapplication") {
        ArrayPush(evt.tags, n"reapplication");
      };
      if !ScriptedPuppet.IsOnOffMeshLink(this) {
        this.SendStatusEffectSignal(evt.priority, evt.tags, evt.flags, evt.statusEffectID, evt.repeatSignalDelay, statusEffect.GetRemainingDuration());
      };
    };
  }

  protected cb func OnStatusEffectRemoved(evt: ref<RemoveStatusEffect>) -> Bool {
    let gmplTags: array<CName>;
    let secSys: ref<SecuritySystemControllerPS>;
    let ttc: ref<TargetTrackerComponent>;
    super.OnStatusEffectRemoved(evt);
    gmplTags = evt.staticData.GameplayTags();
    if ArrayContains(gmplTags, n"Quickhack") {
      this.OnQuickHackEffectRemoved(evt);
    };
    if ArrayContains(gmplTags, n"Blind") && !StatusEffectSystem.ObjectHasStatusEffectWithTag(this, n"Blind") {
      SenseComponent.ResetPreset(this);
      if !StatusEffectSystem.ObjectHasStatusEffectWithTag(this, n"CommsNoiseJam") {
        secSys = this.GetSecuritySystem();
        if IsDefined(secSys) && secSys.HasSupport(Cast(this.GetEntityID())) {
          this.SwitchTargetPlayerTrackedAccuracy(true);
        };
      };
    };
    if ArrayContains(gmplTags, n"ResetSquadSync") {
      ttc = this.GetTargetTrackerComponent();
      if IsDefined(ttc) {
        ttc.PushSquadSync(AISquadType.Combat);
        AISquadHelper.PullSquadSync(this, AISquadType.Combat);
      };
      AIActionHelper.QueuePullSquadSync(this);
    };
    if ArrayContains(gmplTags, n"DisableRagdoll") {
      this.SetDisableRagdoll(false);
    };
    if ArrayContains(gmplTags, n"Defeated") && ScriptedPuppet.IsActive(this) {
      this.SetIsDefeatMechanicActive(Equals(this.GetNPCType(), gamedataNPCType.Human));
    };
    if evt.staticData == this.m_lastStatusEffectSignalSent {
      this.m_lastStatusEffectSignalSent = null;
    };
    switch evt.staticData.StatusEffectType().Type() {
      case gamedataStatusEffectType.UncontrolledMovement:
        this.OnUncontrolledMovementStatusEffectRemoved();
        break;
      case gamedataStatusEffectType.DefeatedWithRecover:
        this.OnDefeatedWithRecoverStatusEffectRemoved();
        break;
      default:
    };
  }

  private final func OnQuickHackEffectRemoved(evt: ref<RemoveStatusEffect>) -> Void {
    let deadBodyEvent: ref<DeadBodyEvent>;
    let secSys: ref<SecuritySystemControllerPS>;
    let gmplTags: array<CName> = evt.staticData.GameplayTags();
    this.quickHackEffectsApplied -= 1u;
    if this.quickHackEffectsApplied == 0u {
      StatusEffectHelper.RemoveStatusEffect(this, t"AIQuickHackStatusEffect.LocomotionMalfunctionLevel4Passive");
      StatusEffectHelper.RemoveStatusEffect(this, t"BaseStatusEffect.DoNotBlockShootingOnFriendlyFire");
      StatusEffectHelper.RemoveStatusEffect(this, t"AIQuickHackStatusEffect.CommsNoisePassiveEffect");
      if IsDefined(this.hackingResistanceMod) {
        GameInstance.GetStatsSystem(this.GetGame()).RemoveModifier(Cast(this.GetEntityID()), this.hackingResistanceMod);
      };
    };
    if ArrayContains(gmplTags, n"CommsNoiseJam") && this.IsConnectedToSecuritySystem() {
      AIActionHelper.QueueSecuritySystemCombatNotification(this);
      if !StatusEffectSystem.ObjectHasStatusEffectWithTag(this, n"Blind") {
        secSys = this.GetSecuritySystem();
        if IsDefined(secSys) && secSys.HasSupport(Cast(this.GetEntityID())) {
          this.SwitchTargetPlayerTrackedAccuracy(true);
        };
      };
    };
    if ArrayContains(gmplTags, n"CommsNoiseIgnore") && (this.GetPS() as ScriptedPuppetPS).GetWasIncapacitated() {
      deadBodyEvent = new DeadBodyEvent();
      GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, deadBodyEvent, 1.00);
    };
  }

  protected cb func OnCacheStatusEffectAnim(evt: ref<CacheStatusEffectAnimEvent>) -> Bool {
    if evt.removeCachedStatusEffect {
      this.m_cachedStatusEffectAnim = null;
    } else {
      this.m_cachedStatusEffectAnim = this.m_lastStatusEffectSignalSent;
    };
  }

  protected cb func OnApplyNewStatusEffect(evt: ref<ApplyNewStatusEffectEvent>) -> Bool {
    StatusEffectHelper.ApplyStatusEffect(this, evt.effectID, evt.instigatorID);
  }

  protected cb func OnRemoveStatusEffect(evt: ref<RemoveStatusEffectEvent>) -> Bool {
    GameInstance.GetStatusEffectSystem(this.GetGame()).RemoveStatusEffect(this.GetEntityID(), evt.effectID, evt.removeCount);
  }

  protected cb func OnRemoveAllStatusEffectOfTypeEvent(evt: ref<RemoveAllStatusEffectOfTypeEvent>) -> Bool {
    GameInstance.GetStatusEffectSystem(this.GetGame()).RemoveAllStatusEffectOfType(this.GetEntityID(), evt.statusEffectType);
  }

  protected func StopStatusEffectVFX(evt: ref<RemoveStatusEffect>) -> Void {
    if ArraySize(this.m_cachedVFXList) == 0 {
      this.StopStatusEffectVFX(evt);
    };
  }

  protected func StopStatusEffectSFX(evt: ref<RemoveStatusEffect>) -> Void {
    if ArraySize(this.m_cachedSFXList) == 0 {
      this.StopStatusEffectSFX(evt);
    };
  }

  protected cb func OnCacheStatusEffectFX(evt: ref<CacheStatusEffectFXEvent>) -> Bool {
    this.m_cachedVFXList = evt.vfxToCache;
    this.m_cachedSFXList = evt.sfxToCache;
  }

  protected cb func OnRemoveCachedStatusEffectFX(evt: ref<RemoveCachedStatusEffectFXEvent>) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(this.m_cachedVFXList) {
      GameObjectEffectHelper.BreakEffectLoopEvent(this, this.m_cachedVFXList[i].Name());
      i += 1;
    };
    i = 0;
    while i < ArraySize(this.m_cachedSFXList) {
      GameObjectEffectHelper.BreakEffectLoopEvent(this, this.m_cachedSFXList[i].Name());
      i += 1;
    };
    ArrayClear(this.m_cachedVFXList);
    ArrayClear(this.m_cachedSFXList);
  }

  protected cb func OnExplorationLeftEvent(evt: ref<ExplorationLeftEvent>) -> Bool {
    this.TriggerPendingSEEvent();
  }

  public final func OnSignalOnUnstoppableStateSignal(signalId: Uint16, newValue: Bool, userData: ref<OnUnstoppableStateSignal>) -> Void {
    if !newValue {
      this.TriggerPendingSEEvent();
    };
  }

  protected cb func OnDelayedSEReactionEvent(evt: ref<DelayedStatusEffectApplicationEvent>) -> Bool {
    if StatusEffectSystem.ObjectHasStatusEffect(this, evt.statusEffectEvent.staticData.GetID()) {
      this.ProcessStatusEffectApplication(evt.statusEffectEvent);
    };
  }

  private final func TriggerPendingSEEvent() -> Void {
    let statusEffectDuration: Float;
    if IsDefined(this.m_pendingSEEvent) {
      statusEffectDuration = StatusEffectHelper.GetStatusEffectByID(this, this.m_pendingSEEvent.staticData.GetID()).GetRemainingDuration();
      if statusEffectDuration <= 0.00 {
        this.m_pendingSEEvent = null;
      } else {
        this.TriggerStatusEffectBehavior(this.m_pendingSEEvent);
      };
    };
  }

  private final func CacheStatusEffectAppliedByPlayer(evt: ref<ApplyStatusEffectEvent>) -> Void {
    if evt.instigatorEntityID == this.GetPlayerID() {
      this.m_lastSEAppliedByPlayer = StatusEffectHelper.GetStatusEffectByID(this, evt.staticData.GetID());
    };
  }

  public final func GetLastSEAppliedByPlayer() -> ref<StatusEffect> {
    return this.m_lastSEAppliedByPlayer;
  }

  protected final func OnUncontrolledMovementStatusEffectAdded(evt: ref<ApplyStatusEffectEvent>) -> Void {
    let ragdollInstigator: wref<GameObject> = GameInstance.FindEntityByID(this.GetGame(), evt.instigatorEntityID) as GameObject;
    if IsDefined(ragdollInstigator) {
      this.m_ragdollInstigator = ragdollInstigator;
    };
    GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, new CheckUncontrolledMovementStatusEffectEvent(), 1.50, true);
  }

  protected final func OnUncontrolledMovementStatusEffectRemoved() -> Void {
    this.QueueEvent(new UncontrolledMovementEndEvent());
    if !this.m_isRagdolling {
      if this.IsOutsideOfNavmeshWithTolerance(this.GetWorldPosition(), new Vector4(0.50, 0.50, 0.75, 1.00)) {
        this.QueueEvent(CreateForceRagdollEvent(n"OffNavmesh_UncontrolledStatusEffectRemoved"));
      } else {
        this.m_ragdollInstigator = null;
      };
    };
  }

  protected cb func OnCheckUncontrolledMovementStatusEffectEvent(evt: ref<CheckUncontrolledMovementStatusEffectEvent>) -> Bool {
    let removeAllStatusEffectEvent: ref<RemoveAllStatusEffectOfTypeEvent>;
    let hasStatusEffect: Bool = StatusEffectSystem.ObjectHasStatusEffectOfType(this, gamedataStatusEffectType.UncontrolledMovement);
    if hasStatusEffect {
      if this.m_isRagdolling || Vector4.Length(this.GetVelocity()) < 0.01 {
        removeAllStatusEffectEvent = new RemoveAllStatusEffectOfTypeEvent();
        removeAllStatusEffectEvent.statusEffectType = gamedataStatusEffectType.UncontrolledMovement;
        this.QueueEvent(removeAllStatusEffectEvent);
        hasStatusEffect = false;
      };
    };
    if hasStatusEffect {
      GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, new CheckUncontrolledMovementStatusEffectEvent(), 0.20, true);
    };
  }

  protected cb func OnCheckRagdollStateEvent(evt: ref<CheckPuppetRagdollStateEvent>) -> Bool {
    let checkRagdollEvent: ref<CheckPuppetRagdollStateEvent>;
    let moveSpeed: Float;
    let navmeshPos: Vector4;
    let needToCheckStateAgain: Bool = false;
    if this.m_isRagdolling {
      navmeshPos = this.GetWorldPosition();
      moveSpeed = Vector4.Length(this.GetVelocity());
      if moveSpeed < TweakDBInterface.GetFloat(t"AIGeneralSettings.ragdollRecoveryVelocityThreshold", 0.10) && this.m_ragdollActivationTimestamp <= 0.00 {
        this.m_ragdollActivationTimestamp = EngineTime.ToFloat(GameInstance.GetSimTime(this.GetGame()));
      };
      if moveSpeed >= TweakDBInterface.GetFloat(t"AIGeneralSettings.ragdollRecoveryVelocityThreshold", 0.10) || !this.CanStandUpFromRagdoll(navmeshPos) {
        needToCheckStateAgain = true;
      };
    };
    if needToCheckStateAgain {
      checkRagdollEvent = new CheckPuppetRagdollStateEvent();
      GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, checkRagdollEvent, 0.20, true);
    } else {
      this.TriggerRagdollBehaviorEnd();
    };
  }

  protected cb func OnAnimVisibilityChangedEvent(evt: ref<AnimVisibilityChangedEvent>) -> Bool {
    this.m_isNotVisible = !evt.isVisible;
  }

  protected final func CanStandUpFromRagdoll(currentPosition: Vector4) -> Bool {
    let influenceMapScorePercentage: Float;
    let player: wref<GameObject>;
    if Equals(this.GetHighLevelStateFromBlackboard(), gamedataNPCHighLevelState.Unconscious) || StatusEffectSystem.ObjectHasStatusEffect(this, t"BaseStatusEffect.Unconscious") {
      if this.m_isNotVisible {
        return true;
      };
      if !GameObject.IsCooldownActive(this, n"UnconsciousRagdollFrustumCheck") {
        if Vector4.Distance(this.GetWorldPosition(), GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerControlledGameObject().GetWorldPosition()) < 5.00 && !CameraSystemHelper.IsInCameraFrustum(this, 0.60, 1.50) {
          return true;
        };
        GameObject.StartCooldown(this, n"UnconsciousRagdollFrustumCheck", 0.30);
      };
      return false;
    };
    player = GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerControlledGameObject();
    this.GetInfluenceMapScoreInRange(currentPosition, TweakDBInterface.GetFloat(t"AIGeneralSettings.influenceMapCheckRange", 0.60), influenceMapScorePercentage);
    if influenceMapScorePercentage <= TweakDBInterface.GetFloat(t"AIGeneralSettings.allowedInfluenceMapPercentage", 0.30) {
      return true;
    };
    if Equals(this.GetAttitudeTowards(player), EAIAttitude.AIA_Friendly) || Equals(this.GetRecord().Priority().Type(), gamedataSpawnableObjectPriority.Quest) {
      if influenceMapScorePercentage <= TweakDBInterface.GetFloat(t"AIGeneralSettings.allowedInfluenceMapPercentageFriendly", 0.50) || EngineTime.ToFloat(GameInstance.GetSimTime(this.GetGame())) - this.m_ragdollActivationTimestamp >= TweakDBInterface.GetFloat(t"AIGeneralSettings.recoveryDespiteInfluenceMapTimeout", 3.00) {
        return true;
      };
    };
    if !this.IsUnderneathVehicle() {
      return true;
    };
    return false;
  }

  protected final func IsUnderneathVehicle() -> Bool {
    let fitTestOvelap: TraceResult;
    let hipsWorldTransform: WorldTransform;
    let overlapSuccessVehicle: Bool;
    let queryOrientation: EulerAngles;
    let queryPosition: Vector4;
    let sqs: ref<SpatialQueriesSystem>;
    let queryDimensions: array<Float> = TDB.GetFloatArray(t"AIGeneralSettings.ragdollRecoveryVehicleCheckProbeDimensions");
    let queryExtents: Vector4 = new Vector4(queryDimensions[0] * 0.50, queryDimensions[1] * 0.50, queryDimensions[2] * 0.50, queryDimensions[3]);
    this.GetSlotComponent().GetSlotTransform(n"Hips", hipsWorldTransform);
    sqs = GameInstance.GetSpatialQueriesSystem(this.GetGame());
    queryPosition = WorldPosition.ToVector4(WorldTransform.GetWorldPosition(hipsWorldTransform));
    queryOrientation = Quaternion.ToEulerAngles(this.GetWorldOrientation());
    queryPosition.Z += queryExtents.Z + 0.10;
    overlapSuccessVehicle = sqs.Overlap(queryExtents, queryPosition, queryOrientation, n"Vehicle", fitTestOvelap);
    return overlapSuccessVehicle;
  }

  protected final func GetInfluenceMapScoreInRange(currentPosition: Vector4, range: Float, out scorePercentage: Float) -> Int32 {
    let score: Int32;
    if this.IsAnOccupiedInfluenceMapNode(currentPosition) {
      score += 1;
    };
    if this.IsAnOccupiedInfluenceMapNode(currentPosition + new Vector4(range, 0.00, 0.00, 0.00)) {
      score += 1;
    };
    if this.IsAnOccupiedInfluenceMapNode(currentPosition + new Vector4(-range, 0.00, 0.00, 0.00)) {
      score += 1;
    };
    if this.IsAnOccupiedInfluenceMapNode(currentPosition + new Vector4(0.00, range, 0.00, 0.00)) {
      score += 1;
    };
    if this.IsAnOccupiedInfluenceMapNode(currentPosition + new Vector4(0.00, -range, 0.00, 0.00)) {
      score += 1;
    };
    if this.IsAnOccupiedInfluenceMapNode(currentPosition + new Vector4(range / 1.50, range / 1.50, 0.00, 0.00)) {
      score += 1;
    };
    if this.IsAnOccupiedInfluenceMapNode(currentPosition + new Vector4(-range / 1.50, -range / 1.50, 0.00, 0.00)) {
      score += 1;
    };
    if this.IsAnOccupiedInfluenceMapNode(currentPosition + new Vector4(-range / 1.50, range / 1.50, 0.00, 0.00)) {
      score += 1;
    };
    if this.IsAnOccupiedInfluenceMapNode(currentPosition + new Vector4(range / 1.50, -range / 1.50, 0.00, 0.00)) {
      score += 1;
    };
    scorePercentage = Cast(score) / 9.00;
    return score;
  }

  protected cb func OnRagdollEnabledEvent(evt: ref<RagdollNotifyEnabledEvent>) -> Bool {
    let checkRagdollEvent: ref<CheckPuppetRagdollStateEvent>;
    let navmeshProbeResults: NavigationFindPointResult;
    let topThreatTrackedLocation: TrackedLocation;
    this.m_isRagdolling = true;
    this.UpdateCollisionState();
    this.UpdateAnimgraphRagdollState(this.m_isRagdolling);
    navmeshProbeResults = GameInstance.GetAINavigationSystem(this.GetGame()).FindPointInBoxForCharacter(this.GetWorldPosition(), new Vector4(0.20, 0.20, 0.75, 1.00), this);
    if Equals(navmeshProbeResults.status, worldNavigationRequestStatus.OK) {
      this.m_ragdollInitialPosition = navmeshProbeResults.point;
    } else {
      this.m_ragdollInitialPosition = this.GetWorldPosition();
    };
    if this.IsCrowd() {
      this.GetCrowdMemberComponent().TryStopTrafficMovement();
    };
    if !IsDefined(this.m_ragdollInstigator) {
      if EntityID.IsDefined(evt.instigator) {
        this.m_ragdollInstigator = GameInstance.FindEntityByID(this.GetGame(), evt.instigator) as GameObject;
      } else {
        if AIActionHelper.GetActiveTopHostilePuppetThreat(this, topThreatTrackedLocation) {
          this.m_ragdollInstigator = topThreatTrackedLocation.entity as GameObject;
        };
      };
    };
    if ScriptedPuppet.IsAlive(this) {
      checkRagdollEvent = new CheckPuppetRagdollStateEvent();
      GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, checkRagdollEvent, 1.50, true);
      GameInstance.GetStatusEffectSystem(this.GetGame()).ApplyStatusEffect(this.GetEntityID(), t"BaseStatusEffect.NonInteractable");
      this.TriggerRagdollBehavior();
    } else {
      if this.IsUnderwater(0.50) {
        NPCPuppet.SetNPCDisposedFact(this);
      } else {
        GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, new CheckDeadPuppetDisposedEvent(), 1.50, true);
      };
    };
  }

  protected final func UpdateAnimgraphRagdollState(isActive: Bool) -> Void {
    let headTransform: WorldTransform;
    let hipsForward: Vector4;
    let hipsLeft: Vector4;
    let hipsPolePitch: Float;
    let hipsToHead: Vector4;
    let hipsTransform: WorldTransform;
    let ragdollStateFeature: ref<AnimFeature_RagdollState> = new AnimFeature_RagdollState();
    this.GetSlotComponent().GetSlotTransform(n"Hips", hipsTransform);
    this.GetSlotComponent().GetSlotTransform(n"Head", headTransform);
    hipsToHead = WorldPosition.ToVector4(WorldTransform.GetWorldPosition(headTransform)) - WorldPosition.ToVector4(WorldTransform.GetWorldPosition(hipsTransform));
    hipsLeft = Vector4.Cross(Quaternion.GetForward(WorldTransform.GetOrientation(hipsTransform)), hipsToHead);
    hipsForward = Vector4.Cross(hipsLeft, hipsToHead);
    hipsPolePitch = Vector4.GetAngleDegAroundAxis(Vector4.Normalize(hipsForward), new Vector4(0.00, 0.00, 1.00, 0.00), Vector4.Normalize(hipsLeft)) + 90.00;
    ragdollStateFeature.isActive = isActive;
    ragdollStateFeature.hipsPolePitch = isActive ? hipsPolePitch : 0.00;
    ragdollStateFeature.speed = isActive ? Vector4.Length(this.GetVelocity()) : 0.00;
    AnimationControllerComponent.ApplyFeatureToReplicate(this, n"ragdollState", ragdollStateFeature);
  }

  protected cb func OnCheckDeadPuppetDisposedEvent(evt: ref<CheckDeadPuppetDisposedEvent>) -> Bool {
    if this.IsUnderwater(0.50) {
      NPCPuppet.SetNPCDisposedFact(this);
    } else {
      if this.m_isRagdolling && Vector4.Length(this.GetVelocity()) >= TweakDBInterface.GetFloat(t"AIGeneralSettings.ragdollRecoveryVelocityThreshold", 0.10) {
        GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, new CheckDeadPuppetDisposedEvent(), 1.50, true);
      };
    };
  }

  protected cb func OnRagdollImpactEvent(evt: ref<RagdollImpactEvent>) -> Bool {
    let attackInstigator: ref<GameObject>;
    let currentPosition: Vector4;
    let damageEvent: ref<StartRagdollDamageEvent>;
    let i: Int32;
    let impactData: RagdollImpactPointData;
    let isDead: Bool;
    let isDefeated: Bool;
    let isHighFall: Bool;
    let isHitByPlayerVehicle: Bool;
    let terminalVelocityReached: Bool;
    let vehicleHitEvent: ref<gameVehicleHitEvent>;
    let vehicleObj: ref<VehicleObject>;
    if evt.triggeredSimulation {
      vehicleObj = evt.otherEntity as VehicleObject;
      if IsDefined(vehicleObj) {
        vehicleHitEvent = new gameVehicleHitEvent();
        vehicleHitEvent.vehicleVelocity = vehicleObj.GetLinearVelocity();
        vehicleHitEvent.preyVelocity = this.GetVelocity();
        vehicleHitEvent.target = this;
        vehicleHitEvent.hitPosition = WorldPosition.ToVector4(evt.impactPoints[0].worldPosition);
        vehicleHitEvent.hitDirection = evt.impactPoints[0].worldNormal;
        vehicleHitEvent.attackData = new AttackData();
        attackInstigator = VehicleComponent.GetDriver(this.GetGame(), vehicleObj.GetEntityID());
        vehicleHitEvent.attackData.SetInstigator(attackInstigator);
        vehicleHitEvent.attackData.SetSource(vehicleObj);
        this.QueueEvent(vehicleHitEvent);
        if IsDefined(attackInstigator) {
          this.m_ragdollInstigator = attackInstigator;
        };
      };
    };
    isDead = this.IsDead() || StatusEffectSystem.ObjectHasStatusEffect(this, t"BaseStatusEffect.ForceKill");
    isDefeated = ScriptedPuppet.IsDefeated(this);
    isHitByPlayerVehicle = VehicleComponent.IsMountedToVehicle(this.GetGame(), GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerControlledGameObject());
    i = 0;
    while i < ArraySize(evt.impactPoints) {
      impactData = evt.impactPoints[i];
      currentPosition = this.GetWorldPosition();
      terminalVelocityReached = impactData.velocityChange >= TweakDBInterface.GetFloat(t"AIGeneralSettings.ragdollImpactKillVelocityThreshold", 11.00);
      isHighFall = impactData.velocityChange >= TweakDBInterface.GetFloat(t"AIGeneralSettings.ragdollHighFallVelocityThreshold", 8.00) && AbsF(this.m_ragdollInitialPosition.Z - currentPosition.Z) >= TweakDBInterface.GetFloat(t"AIGeneralSettings.ragdollHighFallHeightThreshold", 6.00);
      if IsDefined(evt.otherEntity as NPCPuppet) && !(evt.otherEntity as NPCPuppet).IsRagdolling() && !ArrayContains(this.m_ragdolledEntities, evt.otherEntity) {
        if Vector4.Length(this.GetVelocity()) <= TweakDBInterface.GetFloat(t"AIGeneralSettings.ragdollTripNPCInstigatorVelThreshold", 0.20) {
          if !GameObject.IsCooldownActive(GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerControlledGameObject(), n"RagdollTripGlobalCooldown") && ScriptedPuppet.CanTripOverRagdolls(evt.otherEntity as NPCPuppet) && this.ShouldTripVictim(evt.otherEntity as NPCPuppet) {
            evt.otherEntity.QueueEvent(CreateForceRagdollEvent(n"Tripped over a ragdoll"));
            GameObject.StartCooldown(GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerControlledGameObject(), n"RagdollTripGlobalCooldown", TweakDBInterface.GetFloat(t"AIGeneralSettings.ragdollTripGlobalCooldownDuration", 0.00));
          };
        } else {
          if impactData.velocityChange >= TweakDBInterface.GetFloat(t"AIGeneralSettings.ragdollAnotherNPCVelocityThreshold", 1.00) && Equals((evt.otherEntity as NPCPuppet).GetNPCType(), gamedataNPCType.Human) && ScriptedPuppet.CanRagdoll(evt.otherEntity as NPCPuppet) {
            evt.otherEntity.QueueEvent(CreateForceRagdollEvent(n"Hit by a ragdolling NPC"));
          } else {
            this.SpawnRagdollBumpAttack(WorldPosition.ToVector4(impactData.worldPosition) + Vector4.Normalize(impactData.worldNormal) * 0.05);
          };
        };
        ArrayPush(this.m_ragdolledEntities, evt.otherEntity);
      };
      if this.CanReceiveDamageFromRagdollImpacts(isDead, isDefeated, terminalVelocityReached, isHighFall) {
        if impactData.velocityChange >= TweakDBInterface.GetFloat(t"AIGeneralSettings.ragdollDamageMinimumVelocity", 2.00) {
          if this.m_ragdollDamageData.maxVelocityChange == 0.00 {
            damageEvent = new StartRagdollDamageEvent();
            GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, damageEvent, 0.30);
          };
          if impactData.velocityChange > this.m_ragdollDamageData.maxVelocityChange {
            this.m_ragdollDamageData.worldPosition = impactData.worldPosition;
            this.m_ragdollDamageData.worldNormal = impactData.worldNormal;
            this.m_ragdollDamageData.maxVelocityChange = impactData.velocityChange;
            this.m_ragdollDamageData.maxImpulseMagnitude = impactData.maxImpulseMagnitude;
            this.m_ragdollDamageData.maxForceMagnitude = impactData.maxForceMagnitude;
            this.m_ragdollDamageData.maxZDiff = AbsF(this.m_ragdollInitialPosition.Z - currentPosition.Z);
          };
        };
      } else {
        if isHitByPlayerVehicle && (isDefeated || isDead) {
          this.SpawnRagdollSplatter(impactData, isDead);
        };
      };
      if !this.m_ragdollFloorSplashSpawned && (terminalVelocityReached || isHighFall) {
        this.SpawnRagdollFloorSplash(impactData);
      };
      i += 1;
    };
  }

  protected final func ShouldTripVictim(victim: ref<NPCPuppet>) -> Bool {
    let angle: Float = Vector4.GetAngleDegAroundAxis(victim.GetWorldForward(), victim.GetVelocity(), this.GetWorldUp());
    if AbsF(angle) <= TweakDBInterface.GetFloat(t"AIGeneralSettings.ragdollTripForwardAngle", 90.00) {
      if Vector4.Length(victim.GetVelocity()) >= TweakDBInterface.GetFloat(t"AIGeneralSettings.ragdollTripVictimForwardVelMin", 4.00) && RandRangeF(0.00, 100.00) <= TweakDBInterface.GetFloat(t"AIGeneralSettings.ragdollTripVictimForwardChance", 0.00) {
        return true;
      };
    } else {
      if Vector4.Length(victim.GetVelocity()) >= TweakDBInterface.GetFloat(t"AIGeneralSettings.ragdollTripVictimBackwardVelMin", 0.10) && RandRangeF(0.00, 100.00) <= TweakDBInterface.GetFloat(t"AIGeneralSettings.ragdollTripVictimBackwardChance", 100.00) {
        return true;
      };
    };
    return false;
  }

  protected final func CanReceiveDamageFromRagdollImpacts(isDead: Bool, isDefeated: Bool, terminalVelocityReached: Bool, isHighFall: Bool) -> Bool {
    if !isDead && !isDefeated && !this.IsCrowd() && !this.IsBoss() {
      return true;
    };
    if (this.IsCrowd() || Equals(this.GetHighLevelStateFromBlackboard(), gamedataNPCHighLevelState.Unconscious)) && (terminalVelocityReached || isHighFall) {
      return true;
    };
    return false;
  }

  protected final func SpawnRagdollBumpAttack(position: Vector4) -> Void {
    let attackContext: AttackInitContext;
    let effect: ref<EffectInstance>;
    let statMods: array<ref<gameStatModifierData>>;
    attackContext.record = TweakDBInterface.GetAttackRecord(t"Attacks.RagdollBump");
    attackContext.instigator = this;
    attackContext.source = this;
    let attack: ref<Attack_GameEffect> = IAttack.Create(attackContext) as Attack_GameEffect;
    attack.GetStatModList(statMods);
    effect = attack.PrepareAttack(this);
    EffectData.SetFloat(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.range, attackContext.record.Range());
    EffectData.SetFloat(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.radius, attackContext.record.Range());
    EffectData.SetVector(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.position, position);
    EffectData.SetVariant(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.attack, ToVariant(attack));
    GameInstance.GetDebugVisualizerSystem(this.GetGame()).DrawWireSphere(position, attackContext.record.Range(), new Color(255u, 0u, 0u, 255u), 3.00);
    attack.StartAttack();
  }

  protected final func SpawnRagdollFloorSplash(evt: RagdollImpactPointData) -> Void {
    let spawnedEffect: ref<FxInstance>;
    let splashTransform: WorldTransform;
    let transformMatrix: Matrix;
    let transformQuaternion: Quaternion;
    let splashResource: FxResource = this.GetFxResourceByKey(n"ragdollFloorSplash");
    let puppetPosition: Vector4 = this.GetWorldPosition();
    let orientation: Quaternion = Quaternion.BuildFromDirectionVector(evt.worldNormal, this.GetWorldUp());
    Quaternion.SetAxisAngle(transformQuaternion, new Vector4(1.00, 0.00, 0.00, 0.00), Deg2Rad(-90.00));
    orientation *= transformQuaternion;
    transformMatrix = Quaternion.ToMatrix(orientation);
    transformMatrix *= Matrix.BuiltTranslation(puppetPosition);
    WorldTransform.SetPosition(splashTransform, Matrix.GetTranslation(transformMatrix));
    WorldTransform.SetOrientation(splashTransform, Matrix.ToQuat(transformMatrix));
    spawnedEffect = GameInstance.GetFxSystem(this.GetGame()).SpawnEffectOnGround(splashResource, splashTransform);
    if !IsDefined(spawnedEffect) {
      GameInstance.GetFxSystem(this.GetGame()).SpawnEffect(splashResource, splashTransform, true);
    };
    GameObject.PlaySoundEvent(this, n"gmp_ragdoll_floor_splash");
    this.m_ragdollFloorSplashSpawned = true;
  }

  protected final func SpawnRagdollSplatter(impactData: RagdollImpactPointData, isDead: Bool) -> Void {
    let allowedActors: array<Int32>;
    let orientation: Quaternion;
    let splatterChance: Float;
    let splatterResource: FxResource;
    let splatterTransform: WorldTransform;
    let transformMatrix: Matrix;
    let transformQuaternion: Quaternion;
    let allowedAmountOfSplatters: Int32 = TweakDBInterface.GetInt(t"AIGeneralSettings.maximumRagdollSplattersPerNPC", -1);
    if allowedAmountOfSplatters >= 0 && this.m_ragdollSplattersSpawned >= allowedAmountOfSplatters {
      return;
    };
    if impactData.forceMagnitude < TweakDBInterface.GetFloat(t"AIGeneralSettings.vehicleHitBloodSplatterThreshold", 500.00) {
      return;
    };
    allowedActors = TDB.GetIntArray(t"AIGeneralSettings.vehicleHitBloodSplatterAllowedActors");
    if ArraySize(allowedActors) > 0 && !ArrayContains(allowedActors, Cast(impactData.ragdollProxyActorIndex)) {
      return;
    };
    if !this.IsPointOnStaticMesh(WorldPosition.ToVector4(impactData.worldPosition), impactData.worldNormal) {
      return;
    };
    if isDead {
      splatterChance = GameInstance.GetStatsDataSystem(this.GetGame()).GetValueFromCurve(n"vehicle_collision_damage", Cast(this.m_ragdollSplattersSpawned), n"dead_puppet_blood_splatter_chance");
    } else {
      splatterChance = GameInstance.GetStatsDataSystem(this.GetGame()).GetValueFromCurve(n"vehicle_collision_damage", Cast(this.m_ragdollSplattersSpawned), n"defeated_puppet_blood_splatter_chance");
    };
    if RandF() >= splatterChance {
      return;
    };
    splatterResource = this.GetFxResourceByKey(n"ragdollWallSplatter");
    orientation = Quaternion.BuildFromDirectionVector(impactData.worldNormal, this.GetWorldUp());
    Quaternion.SetAxisAngle(transformQuaternion, new Vector4(1.00, 0.00, 0.00, 0.00), Deg2Rad(-90.00));
    orientation *= transformQuaternion;
    transformMatrix = Quaternion.ToMatrix(orientation);
    transformMatrix *= Matrix.BuiltTranslation(WorldPosition.ToVector4(impactData.worldPosition));
    WorldTransform.SetPosition(splatterTransform, Matrix.GetTranslation(transformMatrix));
    WorldTransform.SetOrientation(splatterTransform, Matrix.ToQuat(transformMatrix));
    GameInstance.GetFxSystem(this.GetGame()).SpawnEffect(splatterResource, splatterTransform, true);
    this.m_ragdollSplattersSpawned += 1;
    if !IsFinal() {
      this.Debug_Ragdoll();
    };
  }

  protected final func IsPointOnStaticMesh(position: Vector4, normal: Vector4) -> Bool {
    let geometryDescription: ref<GeometryDescriptionQuery>;
    let geometryDescriptionResult: ref<GeometryDescriptionResult>;
    let staticQueryFilter: QueryFilter;
    QueryFilter.AddGroup(staticQueryFilter, n"Static");
    geometryDescription = new GeometryDescriptionQuery();
    geometryDescription.refPosition = position + Vector4.Normalize(normal) * 0.10;
    geometryDescription.refDirection = -normal;
    geometryDescription.filter = staticQueryFilter;
    geometryDescription.primitiveDimension = new Vector4(0.10, 0.10, 0.10, 0.00);
    geometryDescription.maxDistance = 0.50;
    geometryDescription.maxExtent = 0.50;
    geometryDescription.probingPrecision = 0.05;
    geometryDescription.probingMaxDistanceDiff = 0.50;
    geometryDescriptionResult = GameInstance.GetSpatialQueriesSystem(this.GetGame()).GetGeometryDescriptionSystem().QueryExtents(geometryDescription);
    return Equals(geometryDescriptionResult.queryStatus, worldgeometryDescriptionQueryStatus.OK);
  }

  protected final func Debug_Ragdoll() -> Void {
    let sink: SDOSink = GameInstance.GetScriptsDebugOverlaySystem(this.GetGame()).CreateSink();
    SDOSink.SetRoot(sink, "NPCRagdolls/[NPC: " + ToString(this.GetEntityID()) + "]");
    SDOSink.PushInt32(sink, "Total splatters spawned", this.m_ragdollSplattersSpawned);
  }

  protected cb func OnStartRagdollDamageEvent(evt: ref<StartRagdollDamageEvent>) -> Bool {
    this.StartRagdollImpactAttack(this.m_ragdollDamageData);
    this.m_ragdollDamageData.worldNormal = new Vector4();
    this.m_ragdollDamageData.maxForceMagnitude = 0.00;
    this.m_ragdollDamageData.maxImpulseMagnitude = 0.00;
    this.m_ragdollDamageData.maxVelocityChange = 0.00;
    this.m_ragdollDamageData.maxZDiff = 0.00;
  }

  protected final func StartRagdollImpactAttack(impactData: RagdollDamagePollData) -> Void {
    let attackContext: AttackInitContext;
    let ragdollInstigator: wref<GameObject>;
    attackContext.record = TweakDBInterface.GetAttackRecord(t"Attacks.RagdollImpact");
    attackContext.instigator = GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerControlledGameObject();
    attackContext.source = GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerControlledGameObject();
    let attack: ref<IAttack> = IAttack.Create(attackContext);
    let evt: ref<gameRagdollHitEvent> = new gameRagdollHitEvent();
    evt.target = this;
    evt.hitPosition = WorldPosition.ToVector4(impactData.worldPosition);
    evt.hitDirection = impactData.worldNormal;
    evt.attackData = new AttackData();
    evt.attackData.AddFlag(hitFlag.RagdollImpact, n"Ragdoll impact");
    evt.attackData.AddFlag(hitFlag.CanDamageSelf, n"Ragdoll impact");
    evt.attackData.AddFlag(hitFlag.DeterministicDamage, n"Ragdoll impact");
    evt.attackData.AddFlag(hitFlag.CannotModifyDamage, n"Ragdoll impact");
    if this.GetRagdollInstigator(ragdollInstigator) {
      evt.attackData.SetInstigator(ragdollInstigator);
    } else {
      evt.attackData.SetInstigator(this);
    };
    evt.attackData.SetSource(this);
    evt.attackData.SetAttackDefinition(attack);
    evt.impactForce = impactData.maxForceMagnitude;
    evt.speedDelta = impactData.maxVelocityChange;
    evt.heightDelta = impactData.maxZDiff;
    GameInstance.GetDamageSystem(this.GetGame()).StartPipeline(evt);
  }

  public final func GetRagdollInstigator(out ragdollInstigator: wref<GameObject>) -> Bool {
    let ragdollSE: ref<StatusEffect>;
    ragdollInstigator = this.m_ragdollInstigator;
    if IsDefined(ragdollInstigator) {
      return true;
    };
    ragdollSE = StatusEffectHelper.GetTopPriorityEffect(this, gamedataStatusEffectType.UncontrolledMovement);
    if IsDefined(ragdollSE) {
      ragdollInstigator = GameInstance.FindEntityByID(this.GetGame(), ragdollSE.GetInstigatorEntityID()) as GameObject;
      if IsDefined(ragdollInstigator) {
        return true;
      };
    };
    return false;
  }

  protected cb func OnRagdollDisabledEvent(evt: ref<RagdollNotifyDisabledEvent>) -> Bool {
    this.m_isRagdolling = false;
    this.m_ragdollActivationTimestamp = -1.00;
    ArrayClear(this.m_ragdolledEntities);
    this.UpdateCollisionState();
    this.UpdateAnimgraphRagdollState(this.m_isRagdolling);
    this.m_ragdollInstigator = null;
    if this.m_disableRagdollAfterRecovery {
      this.SetDisableRagdoll(true);
      this.m_disableRagdollAfterRecovery = false;
    };
  }

  protected cb func OnAnimatedRagdollEnabledEvent(evt: ref<AnimatedRagdollNotifyEnabledEvent>) -> Bool {
    let distanceVector: Vector4;
    let hitAngle: Float;
    let hitDirection: Int32;
    let npcOrientation: Vector4;
    let player: ref<ScriptedPuppet>;
    let playerVehicle: wref<VehicleObject>;
    let turnOnRagdollEvent: ref<RagdollToggleDelayEvent>;
    this.m_hasAnimatedRagdoll = true;
    this.UpdateCollisionState();
    if NotEquals(this.GetNPCType(), gamedataNPCType.Human) || this.IsRagdolling() || GameObject.IsCooldownActive(this, n"bumpStaggerCooldown") {
      return IsDefined(null);
    };
    player = GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerControlledGameObject() as ScriptedPuppet;
    if !this.IsCrowd() && VehicleComponent.IsMountedToVehicle(this.GetGame(), player) && player.GetEntityID() == evt.instigator {
      VehicleComponent.GetVehicle(this.GetGame(), player.GetEntityID(), playerVehicle);
      if playerVehicle.GetBlackboard().GetFloat(GetAllBlackboardDefs().Vehicle.SpeedValue) < TDB.GetFloat(t"AIGeneralSettings.vehicleStaggerSpeedThreshold") && !this.IsRagdolling() && !GameObject.IsCooldownActive(this, n"bumpStaggerCooldown") {
        GameObject.StartCooldown(this, n"bumpStaggerCooldown", 1.00);
        npcOrientation = this.GetWorldForward();
        distanceVector = playerVehicle.GetWorldPosition() - this.GetWorldPosition();
        hitAngle = Vector4.GetAngleDegAroundAxis(npcOrientation, distanceVector, this.GetWorldUp());
        if AbsF(hitAngle) <= 45.00 {
          hitDirection = EnumInt(EAIHitDirection.Front);
          hitDirection = 4;
        } else {
          if AbsF(hitAngle) >= 135.00 {
            hitDirection = EnumInt(EAIHitDirection.Back);
            hitDirection = 2;
          } else {
            if hitAngle > 45.00 && hitAngle < 135.00 {
              hitDirection = EnumInt(EAIHitDirection.Left);
              hitDirection = 1;
            } else {
              hitDirection = EnumInt(EAIHitDirection.Right);
              hitDirection = 3;
            };
          };
        };
        AISubActionForceHitReaction_Record_Implementation.SendForcedHitDataToAIBehavior(this, hitDirection, EnumInt(EAIHitIntensity.Medium), EnumInt(animHitReactionType.Stagger), EnumInt(EAIHitBodyPart.LeftLeg), 0, 0, EnumInt(EAIHitSource.MeleeBlunt));
        this.SpawnVehicleBumpAttack(playerVehicle, player);
        turnOnRagdollEvent = new RagdollToggleDelayEvent();
        turnOnRagdollEvent.target = this;
        turnOnRagdollEvent.enable = true;
        if this.m_npcRagdollComponent.IsEnabled() && !this.CanEnableRagdollComponent() {
          turnOnRagdollEvent.force = true;
          turnOnRagdollEvent.leaveRagdollEnabled = true;
        };
        this.SetDisableRagdoll(true);
        GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, turnOnRagdollEvent, TweakDBInterface.GetFloat(t"AIGeneralSettings.vehicleStaggerRagdollImmunity", 0.15), true);
      };
    };
  }

  protected final func SpawnVehicleBumpAttack(vehicle: wref<VehicleObject>, instigator: wref<GameObject>) -> Void {
    let hipsTransform: WorldTransform;
    let vehicleHitEvent: ref<gameVehicleHitEvent> = new gameVehicleHitEvent();
    vehicleHitEvent.vehicleVelocity = vehicle.GetLinearVelocity();
    vehicleHitEvent.preyVelocity = this.GetVelocity();
    this.GetSlotComponent().GetSlotTransform(n"Hips", hipsTransform);
    vehicleHitEvent.target = this;
    vehicleHitEvent.hitPosition = WorldPosition.ToVector4(WorldTransform.GetWorldPosition(hipsTransform));
    vehicleHitEvent.hitDirection = this.GetWorldPosition() - vehicle.GetWorldPosition();
    vehicleHitEvent.attackData = new AttackData();
    vehicleHitEvent.attackData.SetInstigator(instigator);
    vehicleHitEvent.attackData.SetSource(vehicle);
    this.QueueEvent(vehicleHitEvent);
  }

  protected cb func OnAnimatedRagdollDisabledEvent(evt: ref<AnimatedRagdollNotifyDisabledEvent>) -> Bool {
    this.m_hasAnimatedRagdoll = false;
    this.UpdateCollisionState();
  }

  protected final func IsOutsideOfNavmesh(currentPosition: Vector4) -> Bool {
    return !GameInstance.GetAINavigationSystem(this.GetGame()).IsPointOnNavmesh(this, currentPosition, new Vector4(0.20, 0.20, 0.75, 1.00));
  }

  protected final func IsOutsideOfNavmeshWithTolerance(currentPosition: Vector4, tolerance: Vector4) -> Bool {
    return !GameInstance.GetAINavigationSystem(this.GetGame()).IsPointOnNavmesh(this, currentPosition, tolerance);
  }

  protected final func IsOutsideOfNavmesh(currentPosition: Vector4, out navmeshPoint: Vector4) -> Bool {
    return !GameInstance.GetAINavigationSystem(this.GetGame()).IsPointOnNavmesh(this, currentPosition, new Vector4(0.20, 0.20, 0.75, 1.00), navmeshPoint);
  }

  protected final func IsAnOccupiedInfluenceMapNode(currentPosition: Vector4) -> Bool {
    return Equals(this.GetInfluenceComponent().IsPositionEmpty(currentPosition), gameinfluenceCollisionTestOutcome.Full);
  }

  protected final func TriggerRagdollBehavior() -> Void {
    let signal: AIGateSignal;
    signal.priority = 10.00;
    signal.lifeTime = 100.00;
    AIGateSignal.AddTag(signal, n"Ragdoll");
    this.GetSignalHandlerComponent().AddSignal(signal, false);
  }

  protected final func TriggerRagdollBehaviorEnd() -> Void {
    let signal: AIGateSignal;
    signal.priority = 100.00;
    signal.lifeTime = 100.00;
    AIGateSignal.AddTag(signal, n"RagdollEnd");
    AIGateSignal.AddFlag(signal, Cast(EAIGateSignalFlags.AIGSF_InterruptsSamePriorityTask));
    this.GetSignalHandlerComponent().AddSignal(signal, false);
  }

  public final const func IsRagdolling() -> Bool {
    return this.m_isRagdolling;
  }

  public final const func IsRagdollEnabled() -> Bool {
    return this.m_isRagdolling || this.m_hasAnimatedRagdoll;
  }

  public final const func GetInitialRagdollPosition() -> Vector4 {
    return this.m_ragdollInitialPosition;
  }

  public final const func KillIfUnderwater() -> Bool {
    if this.HasHeadUnderwater() {
      this.PuppetSubmergedRequestRemovingStatusEffects(this);
      if StatusEffectHelper.HasStatusEffectFromInstigator(this, t"BaseStatusEffect.Unconscious", this.GetPlayerID()) || StatusEffectHelper.HasStatusEffectFromInstigator(this, t"BaseStatusEffect.Defeated", this.GetPlayerID()) {
        StatusEffectHelper.ApplyStatusEffect(this, t"BaseStatusEffect.ForceKill", this.GetPlayerID());
      } else {
        StatusEffectHelper.ApplyStatusEffect(this, t"BaseStatusEffect.ForceKill");
      };
      NPCPuppet.SetNPCDisposedFact(this);
    };
    return false;
  }

  public const func HasHeadUnderwater() -> Bool {
    let checkPosition: Vector4;
    let headTransform: WorldTransform;
    let waterLevel: Float;
    let slotComponent: ref<SlotComponent> = this.GetSlotComponent();
    if IsDefined(slotComponent) && slotComponent.GetSlotTransform(n"Head", headTransform) {
      checkPosition = WorldPosition.ToVector4(WorldTransform.GetWorldPosition(headTransform));
    } else {
      checkPosition = this.GetWorldPosition();
    };
    if AIScriptUtils.GetWaterLevel(this.GetGame(), Vector4.Vector4To3(checkPosition), waterLevel) {
      if checkPosition.Z - waterLevel <= TDB.GetFloat(t"AIGeneralSettings.underwaterDepthKillThreshold") {
        return true;
      };
    };
    return false;
  }

  protected cb func OnAttitudeChanged(evt: ref<AttitudeChangedEvent>) -> Bool {
    let threat: wref<GameObject>;
    if this.IsPrevention() && NotEquals(evt.attitude, EAIAttitude.AIA_Hostile) {
      threat = evt.otherAgent.GetEntity() as GameObject;
      if IsDefined(threat) {
        this.TriggerSecuritySystemNotification(threat.GetWorldPosition(), threat, ESecurityNotificationType.DEESCALATE);
      };
    };
  }

  protected cb func OnHit(evt: ref<gameHitEvent>) -> Bool {
    super.OnHit(evt);
  }

  protected cb func OnScanningLookedAt(evt: ref<ScanningLookAtEvent>) -> Bool {
    super.OnScanningLookedAt(evt);
    if evt.state {
      this.m_playerStatsListener = new PlayerStatsListener();
      GameInstance.GetStatsSystem(this.GetGame()).RegisterListener(Cast(GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerControlledGameObject().GetEntityID()), this.m_playerStatsListener);
    } else {
      GameInstance.GetStatsSystem(this.GetGame()).UnregisterListener(Cast(GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerControlledGameObject().GetEntityID()), this.m_playerStatsListener);
      this.m_playerStatsListener = null;
    };
  }

  protected cb func OnRevealStateChanged(evt: ref<RevealStateChangedEvent>) -> Bool {
    super.OnRevealStateChanged(evt);
    this.SendRevealStateToAllWeakspots(evt.state);
  }

  protected final func SendRevealStateToAllWeakspots(revealState: ERevealState) -> Void {
    let evt: ref<RevealStateChangedEvent>;
    let i: Int32;
    let weakspots: array<wref<WeakspotObject>>;
    this.GetWeakspotComponent().GetWeakspots(weakspots);
    i = 0;
    while i < ArraySize(weakspots) {
      evt = new RevealStateChangedEvent();
      evt.state = revealState;
      weakspots[i].QueueEvent(evt);
      i += 1;
    };
  }

  protected cb func OnSetupWorkspotActionEvent(evt: ref<SetupWorkspotActionEvent>) -> Bool {
    this.m_lastSetupWorkspotActionEvent = evt;
  }

  private final func SetHitEventData(hitEvent: ref<gameHitEvent>, hitReactionFactor: Float, hitWoundsFactor: Float, hitDismembermentFactor: Float) -> Void {
    RWLock.Acquire(this.m_hitEventLock);
    this.m_lastHitEvent = hitEvent;
    if !hitEvent.attackData.HasFlag(hitFlag.DealNoDamage) || !ScriptedPuppet.IsAlive(this) || ScriptedPuppet.IsDefeated(this) {
      if ScriptedPuppet.IsAlive(this) {
        this.m_totalFrameReactionDamageReceived = hitEvent.attackComputed.GetTotalAttackValue(gamedataStatPoolType.Health) * hitReactionFactor;
        this.m_totalFrameWoundsDamageReceived = hitEvent.attackComputed.GetTotalAttackValue(gamedataStatPoolType.Health) * hitWoundsFactor;
      };
      this.m_totalFrameDismembermentDamageReceived = hitEvent.attackComputed.GetTotalAttackValue(gamedataStatPoolType.Health) * hitDismembermentFactor;
    } else {
      this.m_totalFrameReactionDamageReceived = 0.00;
      this.m_totalFrameWoundsDamageReceived = 0.00;
      this.m_totalFrameDismembermentDamageReceived = 0.00;
    };
    RWLock.Release(this.m_hitEventLock);
  }

  private final func OnHitAnimation(hitEvent: ref<gameHitEvent>) -> Void {
    let attackWeaponID: StatsObjectID;
    let hitDismembermentFactor: Float;
    let hitWoundsFactor: Float;
    let statsSystem: ref<StatsSystem>;
    let attackWeapon: wref<GameObject> = hitEvent.attackData.GetWeapon();
    let hitReactionFactor: Float = 1.00;
    if IsDefined(attackWeapon) {
      statsSystem = GameInstance.GetStatsSystem(attackWeapon.GetGame());
      attackWeaponID = Cast(attackWeapon.GetEntityID());
      hitReactionFactor = statsSystem.GetStatValue(attackWeaponID, gamedataStatType.HitReactionFactor);
      hitWoundsFactor = statsSystem.GetStatValue(attackWeaponID, gamedataStatType.HitWoundsFactor);
      hitDismembermentFactor = statsSystem.GetStatValue(attackWeaponID, gamedataStatType.HitDismembermentFactor);
    };
    if Equals(hitEvent.attackData.GetAttackType(), gamedataAttackType.Explosion) {
      hitReactionFactor = 2.00;
    };
    if !this.ShouldRequestHitReaction(hitEvent) {
      return;
    };
    this.SetHitEventData(hitEvent, hitReactionFactor, hitWoundsFactor, hitDismembermentFactor);
    this.RequestHitReaction(hitEvent);
    this.OnHitAnimation(hitEvent);
  }

  private final const func ShouldRequestHitReaction(hitEvent: ref<gameHitEvent>) -> Bool {
    if AttackData.IsEffect(hitEvent.attackData.GetAttackType()) && !hitEvent.attackData.HasFlag(hitFlag.VehicleDamage) {
      return false;
    };
    if hitEvent.attackData.HasFlag(hitFlag.WasBlocked) || hitEvent.attackData.HasFlag(hitFlag.WasDeflected) {
      return true;
    };
    if hitEvent.attackComputed.GetTotalAttackValue(gamedataStatPoolType.Health) >= 0.00 {
      return true;
    };
    if Equals(this.GetHighLevelStateFromBlackboard(), gamedataNPCHighLevelState.Dead) {
      return true;
    };
    return false;
  }

  private final func RequestHitReaction(hitEvent: ref<gameHitEvent>) -> Void {
    let evt: ref<HitReactionRequest> = new HitReactionRequest();
    evt.hitEvent = hitEvent;
    this.QueueEvent(evt);
  }

  private final func OnHitSounds(hitEvent: ref<gameHitEvent>) -> Void {
    let criticalDamageThreshold: Float;
    let highDamageThreshold: Float;
    let medDamageThreshold: Float;
    let metadataEvent: ref<AudioEvent>;
    let target: ref<GameObject>;
    let totalAttackValue: Float;
    let weakDamageThreshold: Float;
    this.OnHitSounds(hitEvent);
    if IsDefined(hitEvent.attackData.GetWeapon()) && IsDefined(hitEvent.attackData.GetWeapon().GetItemData()) && hitEvent.attackData.GetWeapon().GetItemData().HasTag(WeaponObject.GetMeleeWeaponTag()) {
      return;
    };
    metadataEvent = new AudioEvent();
    metadataEvent.eventFlags = audioAudioEventFlags.Metadata;
    target = hitEvent.target;
    criticalDamageThreshold = TweakDBInterface.GetFloat(t"GlobalStats.DefaultKnockdownDamageThreshold.value", 60.00);
    highDamageThreshold = TweakDBInterface.GetFloat(t"GlobalStats.DefaultStaggerDamageThreshold.value", 40.00);
    medDamageThreshold = TweakDBInterface.GetFloat(t"GlobalStats.DefaultImpactDamageThreshold.value", 20.00);
    weakDamageThreshold = TweakDBInterface.GetFloat(t"GlobalStats.DefaultTwitchDamageThreshold.value", 1.00);
    metadataEvent.floatData = Vector4.Distance(hitEvent.attackData.GetAttackPosition(), target.GetWorldPosition());
    if false {
      metadataEvent.eventName = n"npcImpact";
    } else {
      totalAttackValue = hitEvent.attackComputed.GetTotalAttackValue(gamedataStatPoolType.Health);
      if totalAttackValue >= criticalDamageThreshold {
        metadataEvent.eventName = n"critImpact";
      } else {
        if totalAttackValue >= highDamageThreshold {
          metadataEvent.eventName = n"hiImpact";
        } else {
          if totalAttackValue >= medDamageThreshold {
            metadataEvent.eventName = n"medImpact";
          } else {
            if totalAttackValue >= weakDamageThreshold {
              metadataEvent.eventName = n"lowImpact";
            };
          };
        };
      };
    };
    target.QueueEvent(metadataEvent);
  }

  public final const func GetTotalFrameDamage() -> Float {
    let totalFrameReactionDamageReceived: Float;
    RWLock.AcquireShared(this.m_hitEventLock);
    totalFrameReactionDamageReceived = this.m_totalFrameReactionDamageReceived;
    RWLock.ReleaseShared(this.m_hitEventLock);
    return totalFrameReactionDamageReceived;
  }

  public final const func GetTotalFrameWoundsDamage() -> Float {
    let totalFrameWoundsDamageReceived: Float;
    RWLock.AcquireShared(this.m_hitEventLock);
    totalFrameWoundsDamageReceived = this.m_totalFrameWoundsDamageReceived;
    RWLock.ReleaseShared(this.m_hitEventLock);
    return totalFrameWoundsDamageReceived;
  }

  public final const func GetTotalFrameDismembermentDamage() -> Float {
    let totalFrameDismembermentDamageReceived: Float;
    RWLock.AcquireShared(this.m_hitEventLock);
    totalFrameDismembermentDamageReceived = this.m_totalFrameDismembermentDamageReceived;
    RWLock.ReleaseShared(this.m_hitEventLock);
    return totalFrameDismembermentDamageReceived;
  }

  protected cb func OnResetTotalFrameDamage(evt: ref<ResetFrameDamage>) -> Bool {
    RWLock.Acquire(this.m_hitEventLock);
    this.m_totalFrameReactionDamageReceived = 0.00;
    this.m_totalFrameDismembermentDamageReceived = 0.00;
    RWLock.Release(this.m_hitEventLock);
  }

  private final const func GetLastHitAttackType() -> gamedataAttackType {
    let attackType: gamedataAttackType;
    RWLock.AcquireShared(this.m_hitEventLock);
    attackType = this.m_lastHitEvent.attackData.GetAttackType();
    RWLock.ReleaseShared(this.m_hitEventLock);
    return attackType;
  }

  public final const func GetLastHitInstigator() -> wref<GameObject> {
    let instigator: wref<GameObject>;
    RWLock.AcquireShared(this.m_hitEventLock);
    instigator = this.m_lastHitEvent.attackData.GetInstigator();
    RWLock.ReleaseShared(this.m_hitEventLock);
    return instigator;
  }

  private final const func GetLastHitAttackRecord() -> ref<Attack_GameEffect_Record> {
    let attackRecord: ref<Attack_GameEffect_Record>;
    RWLock.AcquireShared(this.m_hitEventLock);
    attackRecord = this.m_lastHitEvent.attackData.GetAttackDefinition().GetRecord() as Attack_GameEffect_Record;
    RWLock.ReleaseShared(this.m_hitEventLock);
    return attackRecord;
  }

  private final const func HasLastHitFlag(flag: hitFlag) -> Bool {
    let hasFlag: Bool;
    RWLock.AcquireShared(this.m_hitEventLock);
    hasFlag = this.m_lastHitEvent.attackData.HasFlag(flag);
    RWLock.ReleaseShared(this.m_hitEventLock);
    return hasFlag;
  }

  private final const func GetLastHitAttackValues() -> array<Float> {
    let attackValues: array<Float>;
    RWLock.AcquireShared(this.m_hitEventLock);
    attackValues = this.m_lastHitEvent.attackComputed.GetAttackValues();
    RWLock.ReleaseShared(this.m_hitEventLock);
    return attackValues;
  }

  public final const func GetLastHitAttackDirection() -> Vector4 {
    let hitDirection: Vector4;
    RWLock.AcquireShared(this.m_hitEventLock);
    hitDirection = this.m_lastHitEvent.hitDirection;
    RWLock.ReleaseShared(this.m_hitEventLock);
    return hitDirection;
  }

  private final func OnHitUI(hitEvent: ref<gameHitEvent>) -> Void {
    if !ScriptedPuppet.IsAlive(this) {
      return;
    };
    this.OnHitUI(hitEvent);
  }

  public final func WasJustKilledOrDefeated() -> Bool {
    return this.m_wasJustKilledOrDefeated;
  }

  private final func SendAfterDeathOrDefeatEvent() -> Void {
    let afterDeathOrDefeatEvt: ref<NPCAfterDeathOrDefeatEvent> = new NPCAfterDeathOrDefeatEvent();
    this.QueueEvent(afterDeathOrDefeatEvt);
  }

  private final func SendDataTrackingEvent(defeated: Bool, nonLethal: Bool) -> Void {
    let damageHistory: DamageHistoryEntry;
    let dataTrackingEvent: ref<NPCKillDataTrackingRequest> = new NPCKillDataTrackingRequest();
    if this.IsCharacterCivilian() {
      return;
    };
    if this.IsCrowd() {
      return;
    };
    if !this.GetValidAttackFromDamageHistory(damageHistory) {
      return;
    };
    if !IsDefined(damageHistory.source) {
      return;
    };
    dataTrackingEvent.damageEntry = damageHistory;
    dataTrackingEvent.isDownedRecorded = this.m_sentDownedEvent;
    if defeated && nonLethal {
      dataTrackingEvent.eventType = EDownedType.Unconscious;
    } else {
      if defeated {
        dataTrackingEvent.eventType = EDownedType.Defeated;
      } else {
        if ScriptedPuppet.IsDefeated(this) {
          dataTrackingEvent.eventType = EDownedType.Finished;
        } else {
          dataTrackingEvent.eventType = EDownedType.Killed;
        };
      };
    };
    GameInstance.GetScriptableSystemsContainer(this.GetGame()).Get(n"DataTrackingSystem").QueueRequest(dataTrackingEvent);
    this.m_sentDownedEvent = true;
  }

  protected cb func OnAfterDeathOrDefeat(evt: ref<NPCAfterDeathOrDefeatEvent>) -> Bool {
    this.m_wasJustKilledOrDefeated = false;
    this.m_shouldDie = false;
    this.m_shouldBeDefeated = false;
  }

  public final func ClearDefeatAndImmortality() -> Void {
    StatusEffectHelper.RemoveStatusEffect(this, t"BaseStatusEffect.Defeated");
    StatusEffectHelper.RemoveStatusEffect(this, t"BaseStatusEffect.Unconscious");
    StatusEffectHelper.RemoveStatusEffect(this, t"BaseStatusEffect.CombatStim");
    StatusEffectHelper.RemoveStatusEffect(this, t"BaseStatusEffect.Invulnerable");
  }

  protected cb func OnDeath(evt: ref<gameDeathEvent>) -> Bool {
    super.OnDeath(evt);
    if IsDefined(this.m_npcRagdollComponent) {
      this.m_npcRagdollComponent.Toggle(true);
    };
    this.TriggerEvent(n"RequestDeathAnimation");
    this.SendDataTrackingEvent(false, false);
    this.CheckNPCKilledThrowingGrenade(evt.instigator);
    this.ClearDefeatAndImmortality();
    GameInstance.GetStatPoolsSystem(this.GetGame()).RequestUnregisteringListener(Cast(this.GetEntityID()), gamedataStatPoolType.Health, this.m_deathListener);
    this.SendAfterDeathOrDefeatEvent();
    AISquadHelper.NotifySquadOnIncapacitated(this);
    AIComponent.InvokeBehaviorCallback(this, n"OnDeath");
    if IsDefined(evt.instigator) {
      this.m_myKiller = evt.instigator;
    };
  }

  private final func EvaluateQuickHackPassivesIncapacitated() -> Void {
    let attackRecord: ref<Attack_GameEffect_Record>;
    let hitFlags: array<String>;
    let i: Int32;
    let player: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerControlledGameObject() as PlayerPuppet;
    i;
    while i < ArraySize(this.m_receivedDamageHistory) {
      if AttackData.IsExplosion(this.m_receivedDamageHistory[i].hitEvent.attackData.GetAttackType()) && GameInstance.GetStatsSystem(this.GetGame()).GetStatValue(Cast(player.GetEntityID()), gamedataStatType.ExplosionKillsRecudeUltimateHacksCost) == 1.00 {
        StatusEffectHelper.ApplyStatusEffect(player, t"BaseStatusEffect.ReduceUltimateHackCostBy2");
        return;
      };
      i += 1;
    };
    if GameInstance.GetStatsSystem(this.GetGame()).GetStatValue(Cast(player.GetEntityID()), gamedataStatType.DefeatingEnemiesReduceHacksCost) == 1.00 {
      StatusEffectHelper.ApplyStatusEffect(player, t"BaseStatusEffect.ReduceNextHackCostBy1");
    };
    if Equals(this.GetNPCType(), gamedataNPCType.Human) {
      if Equals(this.GetLastHitAttackType(), gamedataAttackType.Hack) || this.HasLastHitFlag(hitFlag.QuickHack) {
        attackRecord = this.GetLastHitAttackRecord();
        hitFlags = attackRecord.HitFlags();
        if ArrayContains(hitFlags, "BrainMeltBurningHead") || GameInstance.GetStatsSystem(this.GetGame()).GetStatValue(Cast(this.GetPlayerID()), gamedataStatType.FearOnQuickHackKill) == 1.00 {
          this.GetStimBroadcasterComponent().TriggerSingleBroadcast(this, gamedataStimType.Terror, 10.00);
          return;
        };
      };
    };
  }

  protected cb func OnPotentialDeath(evt: ref<gamePotentialDeathEvent>) -> Bool {
    let nonLethalFlag: Bool;
    this.SetMyKiller(evt.instigator);
    this.PlayVOOnSquadMembers(evt.instigator.IsPlayer());
    this.PlayVOOnPlayerOrPlayerCompanion(evt.instigator);
    if this.IsDefeatMechanicActive() {
      if this.IsAboutToDie() {
        this.Kill();
      } else {
        if !this.IsCrowd() && (StatusEffectSystem.ObjectHasStatusEffect(evt.instigator, t"GameplayRestriction.FistFight") || StatusEffectSystem.ObjectHasStatusEffect(this, t"GameplayRestriction.FistFight")) {
          StatusEffectHelper.ApplyStatusEffect(this, t"BaseStatusEffect.DefeatedWithRecover");
          nonLethalFlag = true;
        } else {
          nonLethalFlag = this.SearchForNonlethalFlag();
          if nonLethalFlag && GameInstance.GetStatsSystem(this.GetGame()).GetStatValue(Cast(this.GetEntityID()), gamedataStatType.UnconsciousImmunity) == 0.00 {
            StatusEffectHelper.ApplyStatusEffect(this, t"BaseStatusEffect.Unconscious");
          } else {
            StatusEffectHelper.ApplyStatusEffect(this, t"BaseStatusEffect.Defeated");
          };
          StatusEffectHelper.ApplyStatusEffect(this, t"BaseStatusEffect.InvulnerableAfterDefeated");
        };
        this.SendDataTrackingEvent(true, nonLethalFlag);
        this.CheckNPCKilledThrowingGrenade(evt.instigator);
        this.ProcessDoTAttackData();
        this.SendAfterDeathOrDefeatEvent();
        AISquadHelper.NotifySquadOnIncapacitated(this);
      };
    };
  }

  public final static func FinisherEffectorActionOn(npc: wref<NPCPuppet>, instigator: wref<GameObject>) -> Void {
    let evt: ref<FinisherEffectorActionOn>;
    if !IsDefined(npc) || !IsDefined(instigator) {
      return;
    };
    evt = new FinisherEffectorActionOn();
    evt.instigator = instigator;
    GameInstance.GetDelaySystem(npc.GetGame()).DelayEvent(npc, evt, 0.10, false);
  }

  protected cb func OnFinisherEffectorActionOn(evt: ref<FinisherEffectorActionOn>) -> Bool {
    if ScriptedPuppet.IsActive(this) && IsDefined(evt.instigator) {
      if AIActionHelper.TryChangingAttitudeToHostile(this, evt.instigator) {
        TargetTrackingExtension.InjectThreat(this, evt.instigator, 1.00, 10.00);
        NPCPuppet.ChangeHighLevelState(this, gamedataNPCHighLevelState.Combat);
      };
    };
  }

  private final func SearchForNonlethalFlag() -> Bool {
    let i: Int32;
    if ArraySize(this.m_receivedDamageHistory) > 0 {
      i = 0;
      while i < ArraySize(this.m_receivedDamageHistory) {
        if IsDefined(this.m_receivedDamageHistory[i].hitEvent) {
          if this.m_receivedDamageHistory[i].hitEvent.attackData.HasFlag(hitFlag.Nonlethal) {
            return true;
          };
        };
        i += 1;
      };
    };
    return false;
  }

  private final func GetValidAttackFromDamageHistory(out entry: DamageHistoryEntry) -> Bool {
    let i: Int32 = 0;
    if ArraySize(this.m_receivedDamageHistory) > 0 {
      i;
      while i < ArraySize(this.m_receivedDamageHistory) {
        if IsDefined(this.m_receivedDamageHistory[i].hitEvent) {
          entry = this.m_receivedDamageHistory[i];
          return true;
        };
        i += 1;
      };
    };
    return false;
  }

  private final func ProcessDoTAttackData() -> Void {
    let gameEffectAttack: ref<Attack_GameEffect_Record>;
    let i: Int32;
    let statusEffectAttack: ref<Attack_Record>;
    if IsDefined(this.m_cachedStatusEffectAnim) {
      StatusEffectHelper.HasStatusEffectAttack(this.m_cachedStatusEffectAnim, statusEffectAttack);
      if IsDefined(statusEffectAttack) {
        gameEffectAttack = statusEffectAttack as Attack_GameEffect_Record;
        if IsDefined(gameEffectAttack) {
          ScriptedPuppet.SendActionSignal(this, gameEffectAttack.AttackTag(), 1.00);
        };
      };
      return;
    };
    if ArraySize(this.m_receivedDamageHistory) > 0 {
      i = 0;
      while i < ArraySize(this.m_receivedDamageHistory) {
        if IsDefined(this.m_receivedDamageHistory[i].hitEvent) {
          if AttackData.IsDoT(this.m_receivedDamageHistory[i].hitEvent.attackData.GetAttackType()) {
            gameEffectAttack = this.m_receivedDamageHistory[i].hitEvent.attackData.GetAttackDefinition().GetRecord() as Attack_GameEffect_Record;
            if IsDefined(gameEffectAttack) {
              ScriptedPuppet.SendActionSignal(this, gameEffectAttack.AttackTag(), 1.00);
            };
            return;
          };
        };
        i += 1;
      };
    };
  }

  public final func UpdateCollisionState() -> Void {
    if IsDefined(this.m_npcCollisionComponent) {
      if StatusEffectSystem.ObjectHasStatusEffectOfType(this, gamedataStatusEffectType.SystemCollapse) && Equals(this.GetNPCType(), gamedataNPCType.Android) && !this.IsRagdolling() {
        return;
      };
      if this.m_disableCollisionRequested || this.IsIncapacitated() || this.IsRagdolling() || this.m_hasAnimatedRagdoll || ScriptedPuppet.IsDefeated(this) {
        this.GetAIControllerComponent().DisableCollider();
        if this.m_npcTraceObstacleComponent != null {
          this.m_npcTraceObstacleComponent.Toggle(false);
        };
      } else {
        this.GetAIControllerComponent().EnableCollider();
        if this.m_npcTraceObstacleComponent != null {
          this.m_npcTraceObstacleComponent.Toggle(true);
        };
      };
    };
  }

  public final func DisableCollision() -> Void {
    this.m_disableCollisionRequested = true;
    this.UpdateCollisionState();
  }

  public final func EnableCollision() -> Void {
    this.m_disableCollisionRequested = false;
    this.UpdateCollisionState();
  }

  protected final func OnDefeatedWithRecoverStatusEffectApplied() -> Void {
    this.UpdateCollisionState();
    NPCPuppet.ChangeHighLevelState(this, gamedataNPCHighLevelState.Unconscious);
  }

  protected final func OnDefeatedWithRecoverStatusEffectRemoved() -> Void {
    this.SetSenseObjectType(gamedataSenseObjectType.Npc);
    this.UpdateCollisionState();
    NPCPuppet.ChangeHighLevelState(this, gamedataNPCHighLevelState.Relaxed);
  }

  protected func OnResurrected() -> Void {
    this.OnResurrected();
    this.m_disableCollisionRequested = false;
    this.UpdateCollisionState();
    GameInstance.GetStatPoolsSystem(this.GetGame()).RequestSettingStatPoolValue(Cast(this.GetEntityID()), gamedataStatPoolType.Health, 100.00, null, true);
    this.ClearDefeatAndImmortality();
    this.SetSenseObjectType(gamedataSenseObjectType.Npc);
  }

  protected func OnIncapacitated() -> Void {
    if IsDefined(this.m_npcRagdollComponent) {
      this.m_npcRagdollComponent.Toggle(true);
    };
    if ScriptedPuppet.CanRagdoll(this) && !this.WasIncapacitatedOnAttach() {
      this.HandleRagdollOnDeath(true);
    };
    if this.IsIncapacitated() {
      this.UpdateCollisionState();
      return;
    };
    this.QueueEvent(new TerminateReactionLookatEvent());
    this.ReevaluateQuickHackPerkRewardsForPlayer();
    this.EvaluateQuickHackPassivesIncapacitated();
    if Equals(this.GetNPCType(), gamedataNPCType.Android) {
      this.ProcessAndroidIncapacitated();
    };
    this.OnIncapacitated();
    ScriptedPuppet.ProcessLoot(this);
    AIActionHelper.CombatQueriesInit(this);
    this.SetPuppetTargetingPlayer(false);
    this.UpdateCollisionState();
    this.SetSenseObjectType(gamedataSenseObjectType.Deadbody);
    this.HandleRagdollOnDeath(false);
  }

  protected final func HandleRagdollOnDeathByEvent(handleUncontrolledMovement: Bool) -> Void {
    let evt: ref<HandleRagdollOnDeathEvent> = new HandleRagdollOnDeathEvent();
    evt.handleUncontrolledMovement = handleUncontrolledMovement;
    this.QueueEvent(evt);
  }

  protected cb func OnHandleRagdollOnDeath(evt: ref<HandleRagdollOnDeathEvent>) -> Bool {
    this.HandleRagdollOnDeath(evt.handleUncontrolledMovement);
  }

  protected final func HandleRagdollOnDeath(handleUncontrolledMovement: Bool) -> Void {
    let uncontrolledMovementEvent: ref<UncontrolledMovementStartEvent>;
    if handleUncontrolledMovement {
      uncontrolledMovementEvent = new UncontrolledMovementStartEvent();
      uncontrolledMovementEvent.DebugSetSourceName(n"NPCPuppet - OnIncapacitated()");
      if Equals(this.GetNPCType(), gamedataNPCType.Human) && VehicleComponent.IsMountedToVehicle(this.GetGame(), this) {
        uncontrolledMovementEvent.ragdollOnCollision = false;
      } else {
        uncontrolledMovementEvent.ragdollOnCollision = true;
      };
      if Equals(this.GetNPCType(), gamedataNPCType.Drone) && !GameInstance.GetNavigationSystem(this.GetGame()).IsOnGround(this) {
        uncontrolledMovementEvent.ragdollNoGroundThreshold = -1.00;
        GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, CreateForceRagdollEvent(n"Drone aerial death fallback event"), TweakDBInterface.GetFloat(this.GetRecordID() + t".airDeathRagdollDelay", 1.00), true);
      };
      GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, uncontrolledMovementEvent, 0.20, true);
    } else {
      if (Equals(this.GetNPCType(), gamedataNPCType.Human) || Equals(this.GetNPCType(), gamedataNPCType.Android)) && this.IsFloorSteepEnoughToRagdoll() {
        GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, CreateForceRagdollEvent(n"NPC died on sloped terrain"), TDB.GetFloat(t"AIGeneralSettings.ragdollFloorAngleActivationDelay"), true);
      };
    };
  }

  protected final func IsFloorSteepEnoughToRagdoll() -> Bool {
    let floorAngle: Float;
    if SpatialQueriesHelper.GetFloorAngle(this, floorAngle) && floorAngle >= TDB.GetFloat(t"AIGeneralSettings.maxAllowedIncapacitatedFloorAngle") {
      return true;
    };
    return false;
  }

  private final func ProcessAndroidIncapacitated() -> Void {
    let attackValues: array<Float> = this.GetLastHitAttackValues();
    if attackValues[EnumInt(gamedataDamageType.Electric)] > 0.00 {
      GameInstance.GetEffectorSystem(this.GetGame()).ApplyEffector(this.GetEntityID(), GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerControlledGameObject(), t"Effectors.Android_ExplodeOnElectricDeathEffector");
      GameInstance.GetEffectorSystem(this.GetGame()).ApplyEffector(this.GetEntityID(), GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerControlledGameObject(), t"Effectors.Android_ExplodeOnElectricDeathEffectorVFX");
    };
  }

  public const func IsIncapacitated() -> Bool {
    return (this.GetPS() as ScriptedPuppetPS).GetWasIncapacitated();
  }

  private final func ReevaluateQuickHackPerkRewardsForPlayer() -> Void {
    let appliedStatusEffects: array<ref<StatusEffect>>;
    let i: Int32;
    let remainingDuration: Float;
    let value: Float;
    let player: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerControlledGameObject() as PlayerPuppet;
    if IsDefined(player) && this.quickHackEffectsApplied > 0u {
      value = GameInstance.GetStatsSystem(this.GetGame()).GetStatValue(Cast(player.GetEntityID()), gamedataStatType.RestoreMemoryOnDefeat);
      if value > 0.00 {
        GameInstance.GetStatPoolsSystem(this.GetGame()).RequestChangingStatPoolValue(Cast(player.GetEntityID()), gamedataStatPoolType.Memory, value, player, true, false);
      };
      value = GameInstance.GetStatsSystem(this.GetGame()).GetStatValue(Cast(player.GetEntityID()), gamedataStatType.LowerActiveCooldownOnDefeat);
      if value > 0.00 {
        if StatusEffectHelper.GetAppliedEffectsWithTag(player, n"QuickHackCooldown", appliedStatusEffects) {
          i = 0;
          while i < ArraySize(appliedStatusEffects) {
            remainingDuration = appliedStatusEffects[i].GetRemainingDuration();
            GameInstance.GetStatusEffectSystem(this.GetGame()).SetStatusEffectRemainingDuration(player.GetEntityID(), appliedStatusEffects[i].GetRecord().GetID(), remainingDuration * (1.00 - value));
            i += 1;
          };
        };
      };
    };
  }

  protected cb func OnCoverHit(evt: ref<gameCoverHitEvent>) -> Bool {
    this.TriggerEvent(n"RequestCoverHitReaction");
  }

  protected func OnHitVFX(hitEvent: ref<gameHitEvent>) -> Void {
    let isNPCMounted: Bool;
    let mountingInfo: MountingInfo;
    let mountingSlotName: CName;
    this.OnHitVFX(hitEvent);
    mountingInfo = GameInstance.GetMountingFacility(hitEvent.target.GetGame()).GetMountingInfoSingleWithObjects(hitEvent.target);
    isNPCMounted = EntityID.IsDefined(mountingInfo.childId);
    mountingSlotName = mountingInfo.slotId.id;
    if isNPCMounted && Equals(mountingSlotName, n"grapple") {
      GameObjectEffectHelper.StartEffectEvent(this, n"human_shield");
    };
  }

  private final func PlayImpactSound() -> Void {
    let voEvent: ref<SoundPlayVo> = new SoundPlayVo();
    voEvent.voContext = n"battlecry_01";
    voEvent.debugInitialContext = n"Scripts:PlayImpactSound()";
    this.QueueEvent(voEvent);
  }

  private final func SpawnHitVisualEffect(n: CName) -> Void {
    let spawnEffectEvent: ref<entSpawnEffectEvent> = new entSpawnEffectEvent();
    spawnEffectEvent.effectName = n;
    this.QueueEvent(spawnEffectEvent);
  }

  public const func CompileScannerChunks() -> Bool {
    let NPCName: String;
    let abilities: array<wref<GameplayAbility_Record>>;
    let abilityChunk: ref<ScannerAbilities>;
    let abilityGroups: array<wref<GameplayAbilityGroup_Record>>;
    let ap: ref<AccessPointControllerPS>;
    let archetypeData: wref<ArchetypeData_Record>;
    let archetypeName: CName;
    let archtypeChunk: ref<ScannerArchetype>;
    let attitudeChunk: ref<ScannerAttitude>;
    let availablePlayerActions: array<TweakDBID>;
    let basicWeaponChunk: ref<ScannerWeaponBasic>;
    let bountyChunk: ref<ScannerBountySystem>;
    let bountyUI: BountyUI;
    let choices: array<InteractionChoice>;
    let context: GetActionsContext;
    let detailedWeaponChunk: ref<ScannerWeaponDetailed>;
    let enemyDifficulty: EPowerDifferential;
    let factionChunk: ref<ScannerFaction>;
    let hasLinkToDB: Bool;
    let healthChunk: ref<ScannerHealth>;
    let i: Int32;
    let items: array<wref<NPCEquipmentItem_Record>>;
    let k: Int32;
    let levelChunk: ref<ScannerLevel>;
    let nameChunk: ref<ScannerName>;
    let nameParams: ref<inkTextParams>;
    let networkStatusChunk: ref<ScannerNetworkStatus>;
    let puppetQuickHack: wref<ObjectAction_Record>;
    let quickHackActionRecords: array<wref<ObjectAction_Record>>;
    let rarityChunk: ref<ScannerRarity>;
    let resistancesChunk: ref<ScannerResistances>;
    let resists: array<ScannerStatDetails>;
    let statPoolSystem: ref<StatPoolsSystem>;
    let vulnerabilitiesChunk: ref<ScannerVulnerabilities>;
    let vulnerability: Vulnerability;
    let z: Int32;
    let characterRecord: ref<Character_Record> = TweakDBInterface.GetCharacterRecord(this.GetRecordID());
    let scannerPreset: ref<ScannerModuleVisibilityPreset_Record> = characterRecord.ScannerModulePreset();
    let thisEntity: ref<GameObject> = EntityGameInterface.GetEntity(this.GetEntity()) as GameObject;
    let scannerBlackboard: wref<IBlackboard> = GameInstance.GetBlackboardSystem(this.GetGame()).Get(GetAllBlackboardDefs().UI_ScannerModules);
    if !IsDefined(characterRecord) || !IsDefined(scannerPreset) || !IsDefined(scannerBlackboard) {
      return false;
    };
    scannerBlackboard.SetInt(GetAllBlackboardDefs().UI_ScannerModules.ObjectType, EnumInt(ScannerObjectType.PUPPET), true);
    if scannerPreset.ShoulShowName() {
      nameChunk = new ScannerName();
      archetypeName = characterRecord.ArchetypeData().Type().LocalizedName();
      if NotEquals(archetypeName, n"") && !characterRecord.SkipDisplayArchetype() {
        nameChunk.SetArchetype(true);
      };
      nameParams = new inkTextParams();
      if (this.GetPS() as ScriptedPuppetPS).HasAlternativeName() {
        if IsNameValid(characterRecord.AlternativeFullDisplayName()) {
          NPCName = LocKeyToString(characterRecord.AlternativeFullDisplayName());
        } else {
          NPCName = LocKeyToString(characterRecord.AlternativeDisplayName());
        };
      } else {
        if this.IsCharacterCivilian() || Equals(characterRecord.BaseAttitudeGroup(), n"child_ow") {
          if IsNameValid(characterRecord.DisplayName()) {
            NPCName = LocKeyToString(characterRecord.DisplayName());
          } else {
            NPCName = this.GetDisplayName();
          };
        } else {
          if IsNameValid(characterRecord.FullDisplayName()) {
            NPCName = LocKeyToString(characterRecord.FullDisplayName());
          } else {
            if IsNameValid(characterRecord.DisplayName()) {
              NPCName = LocKeyToString(characterRecord.DisplayName());
            } else {
              NPCName = this.GetDisplayName();
            };
          };
        };
      };
      if nameChunk.HasArchetype() {
        nameParams = new inkTextParams();
        if Equals(NPCName, ToString(archetypeName)) || !IsNameValid(characterRecord.FullDisplayName()) && !IsNameValid(characterRecord.DisplayName()) {
          NPCName = "";
        };
        nameParams.AddLocalizedString("TEXT_PRIMARY", NPCName);
        nameParams.AddLocalizedString("TEXT_SECONDARY", ToString(archetypeName));
        nameChunk.SetTextParams(nameParams);
        archtypeChunk = new ScannerArchetype();
        archtypeChunk.Set(characterRecord.ArchetypeData().Type().Type());
        scannerBlackboard.SetVariant(GetAllBlackboardDefs().UI_ScannerModules.ScannerArchetype, ToVariant(archtypeChunk));
      } else {
        nameChunk.Set(NPCName);
      };
      scannerBlackboard.SetVariant(GetAllBlackboardDefs().UI_ScannerModules.ScannerName, ToVariant(nameChunk));
    };
    if scannerPreset.ShouldShowLevel() {
      levelChunk = new ScannerLevel();
      levelChunk.Set(0);
      levelChunk.SetIndicator(NPCPuppet.ShouldShowIndicator(thisEntity));
      scannerBlackboard.SetVariant(GetAllBlackboardDefs().UI_ScannerModules.ScannerLevel, ToVariant(levelChunk));
    };
    if scannerPreset.ShouldShowRarity() {
      rarityChunk = new ScannerRarity();
      hasLinkToDB = GameInstance.GetStatsSystem(this.GetGame()).GetStatValue(Cast(GetPlayer(this.GetGame()).GetEntityID()), gamedataStatType.HasLinkToBountySystem) > 0.00;
      rarityChunk.Set(this.GetPuppetRarity().Type(), this.IsCharacterCivilian() && hasLinkToDB);
      scannerBlackboard.SetVariant(GetAllBlackboardDefs().UI_ScannerModules.ScannerRarity, ToVariant(rarityChunk));
    };
    if scannerPreset.ShouldShowFaction() {
      factionChunk = new ScannerFaction();
      factionChunk.Set(LocKeyToString(characterRecord.Affiliation().LocalizedName()));
      scannerBlackboard.SetVariant(GetAllBlackboardDefs().UI_ScannerModules.ScannerFaction, ToVariant(factionChunk));
    };
    if !this.IsDead() && !ScriptedPuppet.IsDefeated(this) && scannerPreset.ShouldShowAttitude() {
      attitudeChunk = new ScannerAttitude();
      attitudeChunk.Set(this.GetAttitudeTowards(GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerControlledGameObject()));
      scannerBlackboard.SetVariant(GetAllBlackboardDefs().UI_ScannerModules.ScannerAttitude, ToVariant(attitudeChunk));
    };
    if scannerPreset.ShouldShowHealth() {
      healthChunk = new ScannerHealth();
      statPoolSystem = GameInstance.GetStatPoolsSystem(this.GetGame());
      if IsDefined(statPoolSystem) {
        healthChunk.Set(Cast(statPoolSystem.GetStatPoolValue(Cast(this.GetEntityID()), gamedataStatPoolType.Health, false)), Cast(GameInstance.GetStatPoolsSystem(this.GetGame()).GetStatPoolMaxPointValue(Cast(this.GetEntityID()), gamedataStatPoolType.Health)));
        scannerBlackboard.SetVariant(GetAllBlackboardDefs().UI_ScannerModules.ScannerHealth, ToVariant(healthChunk));
      };
    };
    if scannerPreset.ShouldShowBounty() && TDBID.IsValid(this.GetRecord().BountyDrawTable().GetID()) {
      if ArraySize(this.m_bounty.m_transgressions) <= 0 {
        BountyManager.GenerateBounty(this);
      };
      bountyChunk = new ScannerBountySystem();
      bountyUI.issuedBy = LocKeyToString(TweakDBInterface.GetAffiliationRecord(this.m_bounty.m_bountySetter).LocalizedName());
      bountyUI.moneyReward = this.m_bounty.m_moneyAmount;
      bountyUI.streetCredReward = this.m_bounty.m_streetCredAmount;
      enemyDifficulty = RPGManager.CalculatePowerDifferential(thisEntity);
      switch enemyDifficulty {
        case EPowerDifferential.TRASH:
          bountyUI.level = 1;
          break;
        case EPowerDifferential.EASY:
          bountyUI.level = 2;
          break;
        case EPowerDifferential.NORMAL:
          bountyUI.level = 3;
          break;
        case EPowerDifferential.HARD:
          bountyUI.level = 4;
          break;
        case EPowerDifferential.IMPOSSIBLE:
          bountyUI.level = 5;
          break;
        default:
      };
      bountyUI.hasAccess = GameInstance.GetStatsSystem(this.GetGame()).GetStatValue(Cast(GetPlayer(this.GetGame()).GetEntityID()), gamedataStatType.HasLinkToBountySystem) > 0.00;
      i = 0;
      while i < ArraySize(this.m_bounty.m_transgressions) {
        ArrayPush(bountyUI.transgressions, TweakDBInterface.GetTransgressionRecord(this.m_bounty.m_transgressions[i]).LocalizedDescription());
        i += 1;
      };
      bountyChunk.Set(bountyUI);
      scannerBlackboard.SetVariant(GetAllBlackboardDefs().UI_ScannerModules.ScannerBountySystem, ToVariant(bountyChunk));
    };
    if !this.IsDead() && !ScriptedPuppet.IsDefeated(this) && scannerPreset.ShouldShowWeaponData() {
      AIActionTransactionSystem.CalculateEquipmentItems(this, this.GetRecord().PrimaryEquipment(), items, -1);
      if false {
        detailedWeaponChunk = new ScannerWeaponDetailed();
        detailedWeaponChunk.Set(items[0].Item().DisplayName());
        scannerBlackboard.SetVariant(GetAllBlackboardDefs().UI_ScannerModules.ScannerWeaponDetailed, ToVariant(detailedWeaponChunk));
      } else {
        basicWeaponChunk = new ScannerWeaponBasic();
        basicWeaponChunk.Set(items[0].Item().DisplayName());
        scannerBlackboard.SetVariant(GetAllBlackboardDefs().UI_ScannerModules.ScannerWeaponBasic, ToVariant(basicWeaponChunk));
      };
    };
    if !this.IsDead() && !ScriptedPuppet.IsDefeated(this) && scannerPreset.ShouldShowVulnerabilities() {
      vulnerabilitiesChunk = new ScannerVulnerabilities();
      availablePlayerActions = RPGManager.GetPlayerQuickHackList(GetPlayer(this.GetGame()));
      context = (this.GetPS() as ScriptedPuppetPS).GenerateContext(gamedeviceRequestType.Remote, Device.GetInteractionClearance(), Device.GetPlayerMainObjectStatic(this.GetGame()), this.GetEntityID());
      ArrayResize(quickHackActionRecords, ArraySize(availablePlayerActions));
      i = 0;
      while i < ArraySize(availablePlayerActions) {
        quickHackActionRecords[i] = TweakDBInterface.GetObjectActionRecord(availablePlayerActions[i]);
        i += 1;
      };
      (this.GetPS() as ScriptedPuppetPS).GetValidChoices(quickHackActionRecords, context, null, false, choices);
      i = 0;
      while i < ArraySize(choices) {
        k = 0;
        while k < ArraySize(choices[i].data) {
          puppetQuickHack = FromVariant(choices[i].data[k]).GetObjectActionRecord();
          if IsDefined(puppetQuickHack) {
            vulnerability.vulnerabilityName = puppetQuickHack.ObjectActionUI().Caption();
            vulnerability.icon = puppetQuickHack.ObjectActionUI().CaptionIcon().EnumName();
            z = 0;
            while z < ArraySize(quickHackActionRecords) {
              if quickHackActionRecords[z].GameplayCategory().GetID() == puppetQuickHack.GetID() {
                vulnerability.isActive = true;
              };
              z += 1;
            };
            vulnerabilitiesChunk.PushBack(vulnerability);
          };
          k += 1;
        };
        i += 1;
      };
      if vulnerabilitiesChunk.IsValid() {
        scannerBlackboard.SetVariant(GetAllBlackboardDefs().UI_ScannerModules.ScannerVulnerabilities, ToVariant(vulnerabilitiesChunk));
      };
    };
    if scannerPreset.ShouldShowNetworkStatus() {
      networkStatusChunk = new ScannerNetworkStatus();
      ap = (this.GetPS() as ScriptedPuppetPS).GetAccessPoint();
      if IsDefined(ap) {
        if ap.IsBreached() {
          networkStatusChunk.Set(ScannerNetworkState.BREACHED);
        } else {
          networkStatusChunk.Set(ScannerNetworkState.NOT_BREACHED);
        };
      } else {
        networkStatusChunk.Set(ScannerNetworkState.NOT_CONNECTED);
      };
    };
    if !this.IsDead() && !ScriptedPuppet.IsDefeated(this) && scannerPreset.ShouldShowResistances() {
      resistancesChunk = new ScannerResistances();
      ArrayPush(resists, RPGManager.GetScannerResistanceDetails(thisEntity, gamedataStatType.PhysicalResistance));
      ArrayPush(resists, RPGManager.GetScannerResistanceDetails(thisEntity, gamedataStatType.ThermalResistance));
      ArrayPush(resists, RPGManager.GetScannerResistanceDetails(thisEntity, gamedataStatType.ElectricResistance));
      ArrayPush(resists, RPGManager.GetScannerResistanceDetails(thisEntity, gamedataStatType.ChemicalResistance));
      ArrayPush(resists, RPGManager.GetScannerResistanceDetails(thisEntity, gamedataStatType.HackingResistance, GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerMainGameObject()));
      resistancesChunk.Set(resists);
      scannerBlackboard.SetVariant(GetAllBlackboardDefs().UI_ScannerModules.ScannerResistances, ToVariant(resistancesChunk));
    };
    if !this.IsDead() && !ScriptedPuppet.IsDefeated(this) {
      abilityChunk = new ScannerAbilities();
      archetypeData = characterRecord.ArchetypeData();
      if !IsDefined(archetypeData) {
        return false;
      };
      if archetypeData.GetAbilityGroupsCount() > 0 {
        archetypeData.AbilityGroups(abilityGroups);
        i = 0;
        while i < ArraySize(abilityGroups) {
          abilityGroups[i].Abilities(abilities);
          abilityChunk.Set(abilities);
          scannerBlackboard.SetVariant(GetAllBlackboardDefs().UI_ScannerModules.ScannerAbilities, ToVariant(abilityChunk));
          i += 1;
        };
      };
    };
    return true;
  }

  private final static func ShouldShowIndicator(npc: ref<GameObject>) -> Bool {
    let enemyDifficulty: EPowerDifferential = RPGManager.CalculatePowerDifferential(npc);
    if Equals(enemyDifficulty, EPowerDifferential.IMPOSSIBLE) {
      return true;
    };
    if NPCManager.HasVisualTag(npc as ScriptedPuppet, n"Sumo") || NPCManager.HasVisualTag(npc as ScriptedPuppet, n"Police") {
      return true;
    };
    return false;
  }

  protected cb func OnSetExposeQuickHacks(evt: ref<SetExposeQuickHacks>) -> Bool {
    super.OnSetExposeQuickHacks(evt);
    this.SetScannerDirty(true);
  }

  protected cb func OnSmartBulletDeflectedEvent(evt: ref<SmartBulletDeflectedEvent>) -> Bool {
    GameObject.StartReplicatedEffectEvent(this, n"glow_tattoo_promixity");
  }

  public func UpdateAdditionalScanningData() -> Void {
    let bb: ref<IBlackboard>;
    let stats: GameObjectScanStats;
    let weapon: ItemID;
    stats.scannerData.entityName = this.GetTweakDBFullDisplayName(true);
    AIActionTransactionSystem.GetFirstItemID(this, TweakDBInterface.GetItemCategoryRecord(t"ItemCategory.Weapon"), n"", weapon);
    bb = GameInstance.GetBlackboardSystem(this.GetGame()).Get(GetAllBlackboardDefs().UI_Scanner);
    if IsDefined(bb) {
      bb.SetVariant(GetAllBlackboardDefs().UI_Scanner.scannerObjectStats, ToVariant(stats));
      bb.Signal(GetAllBlackboardDefs().UI_Scanner.scannerObjectStats);
    };
  }

  private final const func GetHighestDamageStat(item: ref<gameItemData>) -> gamedataDamageType {
    let cachedThreshold: Float = item.GetStatValueByType(gamedataStatType.PhysicalDamage);
    let returnType: gamedataDamageType = gamedataDamageType.Physical;
    if item.GetStatValueByType(gamedataStatType.ThermalDamage) > cachedThreshold {
      cachedThreshold = item.GetStatValueByType(gamedataStatType.ThermalDamage);
      returnType = gamedataDamageType.Thermal;
    };
    if item.GetStatValueByType(gamedataStatType.ElectricDamage) > cachedThreshold {
      cachedThreshold = item.GetStatValueByType(gamedataStatType.ElectricDamage);
      returnType = gamedataDamageType.Electric;
    };
    if item.GetStatValueByType(gamedataStatType.ChemicalDamage) > cachedThreshold {
      cachedThreshold = item.GetStatValueByType(gamedataStatType.ChemicalDamage);
      returnType = gamedataDamageType.Chemical;
    };
    return returnType;
  }

  public final func MountingStartDisableComponents() -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_npcMountedToPlayerComponents) {
      if IsDefined(this.m_npcMountedToPlayerComponents[i]) && this.IsIncapacitated() {
        this.m_npcMountedToPlayerComponents[i].Toggle(false);
      };
      i += 1;
    };
    this.DisableCollision();
    if !this.IsIncapacitated() {
      GameInstance.GetStatusEffectSystem(this.GetGame()).ApplyStatusEffect(this.GetEntityID(), t"BaseStatusEffect.Grappled");
    };
  }

  public final func MountingEndEnableComponents() -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_npcMountedToPlayerComponents) {
      if IsDefined(this.m_npcMountedToPlayerComponents[i]) {
        this.m_npcMountedToPlayerComponents[i].Toggle(true);
      };
      i += 1;
    };
    this.EnableCollision();
    if !this.IsIncapacitated() {
      GameInstance.GetStatusEffectSystem(this.GetGame()).RemoveStatusEffect(this.GetEntityID(), t"BaseStatusEffect.Grappled");
    };
  }

  public final func GrappleTargetDeadEnableRagdollComponent(b: Bool) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_npcMountedToPlayerComponents) {
      if IsDefined(this.m_npcMountedToPlayerComponents[i]) {
        this.m_npcMountedToPlayerComponents[i].Toggle(false);
      };
      i += 1;
    };
    this.SetDisableRagdoll(!b);
  }

  public final func SetMyKiller(killer: ref<GameObject>) -> Void {
    if IsDefined(killer) {
      this.m_myKiller = killer;
    };
  }

  protected cb func OnGrappleTargetDeadEnableRagdollWithDelay(evt: ref<RagdollToggleDelayEvent>) -> Bool {
    if IsDefined(evt.target) {
      this.SetDisableRagdoll(!evt.enable, evt.force, evt.leaveRagdollEnabled);
    };
  }

  protected cb func OnHidePuppetDelayEvent(evt: ref<HidePuppetDelayEvent>) -> Bool {
    if IsDefined(evt.m_target) {
      evt.m_target.HideIrreversibly();
    };
  }

  protected cb func On_TEMP_TestNPCOutsideNavmeshEvent(evt: ref<TestNPCOutsideNavmeshEvent>) -> Bool {
    let DelayedGameEffectEvt: ref<DelayedGameEffectEvent>;
    let currentPosition: Vector4 = evt.target.GetWorldPosition();
    let navigationPath: ref<NavigationPath> = GameInstance.GetAINavigationSystem(this.GetGame()).CalculatePathForCharacter(currentPosition, currentPosition, 0.20, this);
    if IsDefined(evt.target) && navigationPath == null {
      DelayedGameEffectEvt = new DelayedGameEffectEvent();
      DelayedGameEffectEvt.m_activator = evt.activator;
      DelayedGameEffectEvt.m_target = evt.target;
      DelayedGameEffectEvt.m_effectName = n"takedowns";
      DelayedGameEffectEvt.m_effectTag = n"kill";
      GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(evt.activator, DelayedGameEffectEvt, 0.10);
    };
  }

  public final const func GetScavengeComponent() -> ref<ScavengeComponent> {
    return this.m_scavengeComponent;
  }

  public final const func GetInfluenceComponent() -> ref<InfluenceComponent> {
    return this.m_influenceComponent;
  }

  public final const func GetComfortZoneComponent() -> ref<IComponent> {
    return this.m_comfortZoneComponent;
  }

  protected cb func OnSetDeathParams(evt: ref<gameDeathParamsEvent>) -> Bool {
    this.SetSkipDeathAnimation(evt.noAnimation);
    this.SetDisableRagdoll(evt.noRagdoll);
  }

  protected cb func OnSetDeathDirection(evt: ref<gameDeathDirectionEvent>) -> Bool {
    this.m_customDeathDirection = EnumInt(evt.direction);
  }

  public final const func IsRipperdoc() -> Bool {
    if this.IsVendor() {
      return Equals(TweakDBInterface.GetCharacterRecord(this.GetRecordID()).VendorID().VendorType().Type(), gamedataVendorType.RipperDoc);
    };
    return false;
  }

  protected final func RegisterCallbacks() -> Void {
    let playerPuppet: ref<PlayerPuppet> = GetPlayer(this.GetGame());
    let blackBoard: ref<IBlackboard> = GameInstance.GetBlackboardSystem(this.GetGame()).GetLocalInstanced(playerPuppet.GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
    if !IsDefined(this.m_upperBodyStateCallbackID) {
      this.m_upperBodyStateCallbackID = blackBoard.RegisterListenerInt(GetAllBlackboardDefs().PlayerStateMachine.UpperBody, this, n"OnAimedAt");
    };
    if !IsDefined(this.m_leftCyberwareStateCallbackID) {
      this.m_leftCyberwareStateCallbackID = blackBoard.RegisterListenerInt(GetAllBlackboardDefs().PlayerStateMachine.LeftHandCyberware, this, n"OnCyberware");
    };
    if !IsDefined(this.m_meleeStateCallbackID) {
      this.m_meleeStateCallbackID = blackBoard.RegisterListenerInt(GetAllBlackboardDefs().PlayerStateMachine.MeleeWeapon, this, n"OnMelee");
    };
  }

  protected final func RegisterCallbacksForReactions() -> Void {
    let blackBoard: ref<IBlackboard>;
    let newPlayerID: EntityID;
    let playerPuppet: ref<PlayerPuppet> = GetPlayer(this.GetGame());
    if playerPuppet == null {
      if EntityID.IsDefined(this.m_cachedPlayerID) {
        this.UnregisterCallbacksForReactions();
      };
      this.m_cachedPlayerID = newPlayerID;
      return;
    };
    newPlayerID = playerPuppet.GetEntityID();
    if EntityID.IsDefined(this.m_cachedPlayerID) && newPlayerID != this.m_cachedPlayerID {
      this.UnregisterCallbacksForReactions();
    };
    this.m_cachedPlayerID = newPlayerID;
    blackBoard = GameInstance.GetBlackboardSystem(this.GetGame()).GetLocalInstanced(this.m_cachedPlayerID, GetAllBlackboardDefs().PlayerStateMachine);
    if blackBoard == null {
      return;
    };
    if !IsDefined(this.m_upperBodyStateCallbackID) {
      this.m_upperBodyStateCallbackID = blackBoard.RegisterListenerInt(GetAllBlackboardDefs().PlayerStateMachine.UpperBody, this, n"OnAimedAt");
      blackBoard.SignalInt(GetAllBlackboardDefs().PlayerStateMachine.UpperBody);
    };
    if !IsDefined(this.m_leftCyberwareStateCallbackID) {
      this.m_leftCyberwareStateCallbackID = blackBoard.RegisterListenerInt(GetAllBlackboardDefs().PlayerStateMachine.LeftHandCyberware, this, n"OnCyberware");
      blackBoard.SignalInt(GetAllBlackboardDefs().PlayerStateMachine.LeftHandCyberware);
    };
    if !IsDefined(this.m_meleeStateCallbackID) {
      this.m_meleeStateCallbackID = blackBoard.RegisterListenerInt(GetAllBlackboardDefs().PlayerStateMachine.MeleeWeapon, this, n"OnMelee");
      blackBoard.SignalInt(GetAllBlackboardDefs().PlayerStateMachine.MeleeWeapon);
    };
    if !IsDefined(this.m_combatGadgetStateCallbackID) {
      this.m_combatGadgetStateCallbackID = blackBoard.RegisterListenerInt(GetAllBlackboardDefs().PlayerStateMachine.CombatGadget, this, n"OnCombatGadget");
      blackBoard.SignalInt(GetAllBlackboardDefs().PlayerStateMachine.CombatGadget);
    };
  }

  protected final func UnregisterCallbacksForReactions() -> Void {
    let blackBoard: ref<IBlackboard> = GameInstance.GetBlackboardSystem(this.GetGame()).GetLocalInstanced(this.m_cachedPlayerID, GetAllBlackboardDefs().PlayerStateMachine);
    if IsDefined(blackBoard) {
      if IsDefined(this.m_upperBodyStateCallbackID) {
        blackBoard.UnregisterListenerInt(GetAllBlackboardDefs().PlayerStateMachine.UpperBody, this.m_upperBodyStateCallbackID);
      };
      if IsDefined(this.m_leftCyberwareStateCallbackID) {
        blackBoard.UnregisterListenerInt(GetAllBlackboardDefs().PlayerStateMachine.LeftHandCyberware, this.m_leftCyberwareStateCallbackID);
      };
      if IsDefined(this.m_meleeStateCallbackID) {
        blackBoard.UnregisterListenerInt(GetAllBlackboardDefs().PlayerStateMachine.MeleeWeapon, this.m_meleeStateCallbackID);
      };
      if IsDefined(this.m_combatGadgetStateCallbackID) {
        blackBoard.UnregisterListenerInt(GetAllBlackboardDefs().PlayerStateMachine.CombatGadget, this.m_combatGadgetStateCallbackID);
      };
    };
    this.m_upperBodyStateCallbackID = null;
    this.m_leftCyberwareStateCallbackID = null;
    this.m_meleeStateCallbackID = null;
    this.m_combatGadgetStateCallbackID = null;
  }

  protected cb func OnLookedAtEvent(evt: ref<LookedAtEvent>) -> Bool {
    super.OnLookedAtEvent(evt);
    this.m_isLookedAt = evt.isLookedAt;
    this.ResolveReactiOnLookedAt(evt.isLookedAt);
  }

  private final func ResolveReactiOnLookedAt(isLookedAt: Bool) -> Void {
    let broadcaster: ref<StimBroadcasterComponent>;
    if isLookedAt {
      this.RegisterCallbacksForReactions();
    } else {
      this.UnregisterCallbacksForReactions();
      if this.m_wasAimedAtLast || this.m_wasCWChargedAtLast || this.m_wasMeleeChargedAtLast || this.m_wasChargingGadgetAtLast {
        broadcaster = GetPlayer(this.GetGame()).GetStimBroadcasterComponent();
        if IsDefined(broadcaster) {
          broadcaster.SendDrirectStimuliToTarget(this, gamedataStimType.StopedAiming, this);
        };
      };
      this.m_wasAimedAtLast = false;
      this.m_wasCWChargedAtLast = false;
      this.m_wasMeleeChargedAtLast = false;
      this.m_wasChargingGadgetAtLast = false;
    };
  }

  private final func TutorialAddIllegalActionFact() -> Void {
    let questSystem: ref<QuestsSystem> = GameInstance.GetQuestsSystem(this.GetGame());
    if questSystem.GetFact(n"illegal_action_tutorial") == 0 && questSystem.GetFact(n"disable_tutorials") == 0 {
      questSystem.SetFact(n"illegal_action_tutorial", 1);
    };
  }

  protected cb func OnAimedAt(value: Int32) -> Bool {
    let weapon: ref<WeaponObject> = GameObject.GetActiveWeapon(GetPlayer(this.GetGame()));
    let broadcaster: ref<StimBroadcasterComponent> = GetPlayer(this.GetGame()).GetStimBroadcasterComponent();
    if EnumInt(gamePSMUpperBodyStates.Aim) == value && weapon.IsRanged() {
      if this.m_isLookedAt {
        if IsDefined(broadcaster) {
          broadcaster.SendDrirectStimuliToTarget(this, gamedataStimType.AimingAt, this);
        };
        this.m_wasAimedAtLast = true;
        if this.IsCharacterCivilian() {
          this.TutorialAddIllegalActionFact();
        };
      };
    } else {
      if this.m_wasAimedAtLast && weapon.IsRanged() {
        if IsDefined(broadcaster) {
          broadcaster.SendDrirectStimuliToTarget(this, gamedataStimType.StopedAiming, this);
        };
        this.m_wasAimedAtLast = false;
      };
    };
  }

  protected cb func OnCyberware(value: Int32) -> Bool {
    let broadcaster: ref<StimBroadcasterComponent> = GetPlayer(this.GetGame()).GetStimBroadcasterComponent();
    if EnumInt(gamePSMLeftHandCyberware.Charge) == value {
      if this.m_isLookedAt {
        if IsDefined(broadcaster) {
          broadcaster.SendDrirectStimuliToTarget(this, gamedataStimType.AimingAt, this);
        };
        this.m_wasCWChargedAtLast = true;
      };
    } else {
      if this.m_wasCWChargedAtLast {
        if IsDefined(broadcaster) {
          broadcaster.SendDrirectStimuliToTarget(this, gamedataStimType.StopedAiming, this);
        };
        this.m_wasCWChargedAtLast = false;
      };
    };
  }

  protected cb func OnMelee(value: Int32) -> Bool {
    let broadcaster: ref<StimBroadcasterComponent> = GetPlayer(this.GetGame()).GetStimBroadcasterComponent();
    if EnumInt(gamePSMMeleeWeapon.ChargedHold) == value || EnumInt(gamePSMMeleeWeapon.Targeting) == value {
      if this.m_isLookedAt {
        if IsDefined(broadcaster) {
          broadcaster.SendDrirectStimuliToTarget(this, gamedataStimType.AimingAt, this);
        };
        this.m_wasMeleeChargedAtLast = true;
      };
    } else {
      if this.m_wasMeleeChargedAtLast {
        if IsDefined(broadcaster) {
          broadcaster.SendDrirectStimuliToTarget(this, gamedataStimType.StopedAiming, this);
        };
        this.m_wasMeleeChargedAtLast = false;
      };
    };
  }

  protected cb func OnCombatGadget(value: Int32) -> Bool {
    let broadcaster: ref<StimBroadcasterComponent> = GetPlayer(this.GetGame()).GetStimBroadcasterComponent();
    if EnumInt(gamePSMCombatGadget.Charging) == value {
      if this.m_isLookedAt {
        if IsDefined(broadcaster) {
          broadcaster.SendDrirectStimuliToTarget(this, gamedataStimType.AimingAt, this);
        };
        this.m_wasChargingGadgetAtLast = true;
      };
    } else {
      if this.m_wasChargingGadgetAtLast {
        if IsDefined(broadcaster) {
          broadcaster.SendDrirectStimuliToTarget(this, gamedataStimType.StopedAiming, this);
        };
        this.m_wasChargingGadgetAtLast = false;
      };
    };
  }

  protected cb func OnNPCStartThrowingGrenadeEvent(evt: ref<NPCThrowingGrenadeEvent>) -> Bool {
    if IsDefined(evt.target) {
      if evt.target.IsPlayer() {
        this.m_isThrowingGrenadeToPlayer = true;
        ReactionManagerComponent.SendVOEventToSquad(evt.target, n"grenade_enemy");
        GameInstance.GetDelaySystem(this.GetGame()).CancelDelay(this.m_throwingGrenadeDelayEventID);
        this.m_throwingGrenadeDelayEventID = GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, new NPCThrowingGrenadeEvent(), 5.00);
      };
    } else {
      this.m_isThrowingGrenadeToPlayer = false;
    };
  }

  protected final const func PlayVOOnSquadMembers(isPlayer: Bool) -> Void {
    let smi: ref<SquadScriptInterface>;
    let squadMembersCount: Uint32;
    let shouldPlayBattlecrySingleEnemy: Bool = false;
    if isPlayer && Equals(this.GetHighLevelStateFromBlackboard(), gamedataNPCHighLevelState.Combat) {
      if AISquadHelper.GetSquadMemberInterface(this, smi) {
        squadMembersCount = smi.GetMembersCount();
        if squadMembersCount == 2u {
          shouldPlayBattlecrySingleEnemy = true;
        };
      };
      if !shouldPlayBattlecrySingleEnemy {
        ReactionManagerComponent.SendVOEventToSquad(this, n"squad_member_died");
      } else {
        ReactionManagerComponent.SendVOEventToSquad(this, n"battlecry_single_enemy");
      };
    };
  }

  protected final const func PlayVOOnPlayerOrPlayerCompanion(instigator: ref<GameObject>) -> Void {
    if !IsDefined(instigator) {
      return;
    };
    if ScriptedPuppet.IsPlayerCompanion(instigator) {
      GameObject.PlayVoiceOver(instigator, n"coop_reports_kill", n"Scripts:CheckIfKilledByPlayerCompanion");
    } else {
      if instigator.IsPlayer() && (instigator as PlayerPuppet).IsInCombat() {
        if AttackData.IsBullet(this.GetLastHitAttackType()) {
          ReactionManagerComponent.SendVOEventToSquad(instigator, n"coop_praise");
        };
      };
    };
  }

  protected final const func CheckNPCKilledThrowingGrenade(instigator: ref<GameObject>) -> Void {
    let achievementRequest: ref<AddAchievementRequest>;
    let dataTrackingSystem: ref<DataTrackingSystem>;
    let achievement: gamedataAchievement = gamedataAchievement.Denied;
    if !IsDefined(instigator) || !this.m_isThrowingGrenadeToPlayer {
      return;
    };
    if !instigator.IsPlayer() && !instigator.IsPlayerControlled() {
      return;
    };
    achievementRequest = new AddAchievementRequest();
    achievementRequest.achievement = achievement;
    dataTrackingSystem = GameInstance.GetScriptableSystemsContainer(this.GetGame()).Get(n"DataTrackingSystem") as DataTrackingSystem;
    dataTrackingSystem.QueueRequest(achievementRequest);
  }

  public final func CanGoThroughDoors() -> Bool {
    return this.m_canGoThroughDoors;
  }

  protected cb func OnEnteredPathWithDoors(evt: ref<EnteredPathWithDoors>) -> Bool {
    this.m_canGoThroughDoors = true;
  }

  protected cb func OnFinishedPathWithDoors(evt: ref<FinishedPathWithDoors>) -> Bool {
    this.m_canGoThroughDoors = false;
  }

  protected cb func OnEnteredSplineEvent(evt: ref<EnteredSplineEvent>) -> Bool {
    if evt.useDoors {
      this.m_canGoThroughDoors = true;
    };
  }

  protected cb func OnExitedSplineEvent(evt: ref<ExitedSplineEvent>) -> Bool {
    this.m_canGoThroughDoors = false;
  }

  public final func GetMyKiller() -> wref<GameObject> {
    return this.m_myKiller;
  }

  public final func GetThreatCalculationType() -> EAIThreatCalculationType {
    if NotEquals(this.m_temporaryThreatCalculationType, EAIThreatCalculationType.Regular) {
      return this.m_temporaryThreatCalculationType;
    };
    return this.m_primaryThreatCalculationType;
  }

  public final func ReevaluatEAIThreatCalculationType() -> Void {
    if this.IsBoss() {
      this.m_primaryThreatCalculationType = EAIThreatCalculationType.Boss;
    } else {
      this.m_primaryThreatCalculationType = EAIThreatCalculationType.Regular;
    };
  }

  public final static func SetTemporaryThreatCalculationType(npc: wref<GameObject>, newType: EAIThreatCalculationType) -> Void {
    let evt: ref<AIThreatCalculationEvent>;
    if !IsDefined(npc) {
      return;
    };
    evt = new AIThreatCalculationEvent();
    evt.set = true;
    evt.temporaryThreatCalculationType = newType;
    npc.QueueEvent(evt);
  }

  public final static func RemoveTemporaryThreatCalculationType(npc: wref<GameObject>) -> Void {
    let evt: ref<AIThreatCalculationEvent>;
    if !IsDefined(npc) {
      return;
    };
    evt = new AIThreatCalculationEvent();
    evt.set = false;
    npc.QueueEvent(evt);
  }

  public final static func IsInCombat(npc: wref<ScriptedPuppet>) -> Bool {
    let currentHighLevelState: gamedataNPCHighLevelState = IntEnum(npc.GetPuppetStateBlackboard().GetInt(GetAllBlackboardDefs().PuppetState.HighLevel));
    if Equals(currentHighLevelState, gamedataNPCHighLevelState.Combat) {
      return true;
    };
    return false;
  }

  public final static func IsInAlerted(npc: wref<ScriptedPuppet>) -> Bool {
    let currentHighLevelState: gamedataNPCHighLevelState = IntEnum(npc.GetPuppetStateBlackboard().GetInt(GetAllBlackboardDefs().PuppetState.HighLevel));
    if Equals(currentHighLevelState, gamedataNPCHighLevelState.Alerted) {
      return true;
    };
    return false;
  }

  public final static func IsUnstoppable(npc: wref<ScriptedPuppet>) -> Bool {
    let currentHitReactionMode: EHitReactionMode = IntEnum(npc.GetPuppetStateBlackboard().GetInt(GetAllBlackboardDefs().PuppetState.HitReactionMode));
    if Equals(currentHitReactionMode, EHitReactionMode.Unstoppable) {
      return true;
    };
    return false;
  }

  protected cb func OnAIThreatCalculationEvent(evt: ref<AIThreatCalculationEvent>) -> Bool {
    if evt.set {
      this.m_temporaryThreatCalculationType = evt.temporaryThreatCalculationType;
    } else {
      this.m_temporaryThreatCalculationType = EAIThreatCalculationType.Regular;
    };
  }

  public final func OnHittingPlayer(playerPuppet: wref<GameObject>, damageInflicted: Float) -> Void {
    let damageInflictedPercent: Float;
    let playerCurrentHealthPercent: Float;
    let playerPuppetID: EntityID;
    let squadmates: array<wref<Entity>>;
    let statPoolSys: ref<StatPoolsSystem>;
    if playerPuppet == null || playerPuppet != GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerMainGameObject() || !AISquadHelper.GetSquadmates(this, squadmates) {
      return;
    };
    playerPuppetID = playerPuppet.GetEntityID();
    statPoolSys = GameInstance.GetStatPoolsSystem(this.GetGame());
    damageInflictedPercent = 100.00 * damageInflicted / statPoolSys.GetStatPoolMaxPointValue(Cast(playerPuppetID), gamedataStatPoolType.Health);
    playerCurrentHealthPercent = statPoolSys.GetStatPoolValue(Cast(playerPuppetID), gamedataStatPoolType.Health);
    if playerCurrentHealthPercent <= 50.00 {
      GameObject.PlayVoiceOver(this, n"attack_fragile_player_order", n"Scripts:NPCPuppet:OnHittingPlayer", 0.50);
    };
    if damageInflictedPercent >= 3.00 || GameInstance.GetGodModeSystem(this.GetGame()).HasGodMode(playerPuppetID, gameGodModeType.Invulnerable) {
      GameObject.PlayVoiceOver(this, n"combat_target_hit", n"Scripts:NPCPuppet:OnHittingPlayer");
    };
  }

  protected cb func OnSmartDespawnRequest(evt: ref<SmartDespawnRequest>) -> Bool {
    GameInstance.GetDelaySystem(this.GetGame()).CancelDelay(this.smartDespawnDelayID);
    if !CameraSystemHelper.IsInCameraFrustum(this, 2.00, 0.75) {
      this.despawnTicks += 1u;
    } else {
      this.despawnTicks = 0u;
    };
    if this.despawnTicks >= 5u {
      GameInstance.GetCompanionSystem(this.GetGame()).DespawnSubcharacter(this.GetRecordID());
    } else {
      this.smartDespawnDelayID = GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, evt, 1.00);
    };
  }

  protected cb func OnCancelSmartDespawnRequest(evt: ref<CancelSmartDespawnRequest>) -> Bool {
    GameInstance.GetDelaySystem(this.GetGame()).CancelDelay(this.smartDespawnDelayID);
  }
}

public static exec func SetAnimFloatOnTarget(gameInstance: GameInstance, floatValue: String) -> Void {
  let angleDist: EulerAngles;
  let targetNPC: ref<NPCPuppet> = GameInstance.GetTargetingSystem(gameInstance).GetObjectClosestToCrosshair(GameInstance.GetPlayerSystem(gameInstance).GetLocalPlayerMainGameObject(), angleDist, TSQ_ALL()) as NPCPuppet;
  if IsDefined(targetNPC) {
    AnimationControllerComponent.SetInputFloat(targetNPC, n"debug_float_a", StringToFloat(floatValue, 0.00));
  } else {
    Log("execSetAnimGraphFloat::: NPC NOT FOUND!!");
  };
}

public class NonStealthQuickHackVictimEvent extends Event {

  public let instigatorID: EntityID;

  public final static func Create(instigatorID: EntityID) -> ref<NonStealthQuickHackVictimEvent> {
    let evt: ref<NonStealthQuickHackVictimEvent> = new NonStealthQuickHackVictimEvent();
    evt.instigatorID = instigatorID;
    return evt;
  }
}
