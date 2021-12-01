
public final native class DamageSystem extends IDamageSystem {

  public let m_previewTarget: previewTargetStruct;

  public let m_previewLock: Bool;

  public let m_previewRWLockTemp: RWLock;

  public final native func StartPipeline(evt: ref<gameHitEvent>) -> Void;

  public final native func StartProjectionPipeline(evt: ref<gameProjectedHitEvent>) -> Void;

  public final static native func GetDamageModFromCurve(curve: CName, value: Float) -> Float;

  private final func ProcessPipeline(hitEvent: ref<gameHitEvent>, cache: ref<CacheData>) -> Void {
    this.ProcessSyncStageCallbacks(gameDamagePipelineStage.PreProcess, hitEvent, DMGPipelineType.Damage);
    if this.PreProcess(hitEvent, cache) {
      this.ProcessSyncStageCallbacks(gameDamagePipelineStage.Process, hitEvent, DMGPipelineType.Damage);
      this.Process(hitEvent, cache);
      this.ProcessHitReaction(hitEvent);
      this.ProcessSyncStageCallbacks(gameDamagePipelineStage.PostProcess, hitEvent, DMGPipelineType.Damage);
      this.PostProcess(hitEvent);
    };
  }

  private final func ProcessProjectionPipeline(hitEvent: ref<gameProjectedHitEvent>, cache: ref<CacheData>) -> Void {
    if this.CheckProjectionPipelineTargetConditions(hitEvent) {
      hitEvent.projectionPipeline = true;
      this.ProcessSyncStageCallbacks(gameDamagePipelineStage.PreProcess, hitEvent, DMGPipelineType.ProjectedDamage);
      if this.PreProcess(hitEvent, cache) {
        this.ProcessSyncStageCallbacks(gameDamagePipelineStage.Process, hitEvent, DMGPipelineType.ProjectedDamage);
        this.Process(hitEvent, cache);
        this.ProcessSyncStageCallbacks(gameDamagePipelineStage.PostProcess, hitEvent, DMGPipelineType.ProjectedDamage);
        this.FillInDamageBlackboard(hitEvent);
      };
    };
  }

  private final func CheckProjectionPipelineTargetConditions(hitEvent: ref<gameProjectedHitEvent>) -> Bool {
    let hitZone: EHitReactionZone;
    let previewLockLocal: Bool;
    let previewTargetLocal: previewTargetStruct;
    RWLock.AcquireShared(this.m_previewRWLockTemp);
    previewLockLocal = this.m_previewLock;
    previewTargetLocal.currentlyTrackedTarget = this.m_previewTarget.currentlyTrackedTarget;
    previewTargetLocal.currentBodyPart = this.m_previewTarget.currentBodyPart;
    RWLock.ReleaseShared(this.m_previewRWLockTemp);
    Log("Checking pipeline");
    if previewLockLocal {
      return false;
    };
    if !IsDefined(previewTargetLocal.currentlyTrackedTarget) || previewTargetLocal.currentlyTrackedTarget != hitEvent.target {
      this.SetPreviewTargetStruct(hitEvent.target, this.GetHitReactionZone(hitEvent));
      return true;
    };
    if previewTargetLocal.currentlyTrackedTarget == hitEvent.target {
      hitZone = this.GetHitReactionZone(hitEvent);
      if Equals(hitZone, previewTargetLocal.currentBodyPart) {
        return false;
      };
      if NotEquals(previewTargetLocal.currentBodyPart, EHitReactionZone.Head) && NotEquals(hitZone, EHitReactionZone.Head) {
        return false;
      };
      this.SetPreviewTargetStruct(previewTargetLocal.currentlyTrackedTarget, hitZone);
      return true;
    };
    return false;
  }

  private final func SetPreviewTargetStruct(trackedTarget: wref<GameObject>, bodyPart: EHitReactionZone) -> Void {
    RWLock.Acquire(this.m_previewRWLockTemp);
    this.m_previewTarget.currentlyTrackedTarget = trackedTarget;
    this.m_previewTarget.currentBodyPart = bodyPart;
    RWLock.Release(this.m_previewRWLockTemp);
  }

  public final func ClearPreviewTargetStruct() -> Void {
    this.SetPreviewTargetStruct(null, EHitReactionZone.Special);
  }

  public final func SetPreviewLock(newState: Bool) -> Void {
    RWLock.Acquire(this.m_previewRWLockTemp);
    this.m_previewLock = newState;
    RWLock.Release(this.m_previewRWLockTemp);
  }

  private final func GetHitReactionZone(hitEvent: ref<gameProjectedHitEvent>) -> EHitReactionZone {
    let hitShapes: array<HitShapeData> = hitEvent.hitRepresentationResult.hitShapes;
    let hitUserData: ref<HitShapeUserDataBase> = DamageSystemHelper.GetHitShapeUserDataBase(hitShapes[0]);
    return HitShapeUserDataBase.GetHitReactionZone(hitUserData);
  }

  private final func GatherDebugData(hitEvent: ref<gameHitEvent>, cache: ref<CacheData>, out hitDebugData: ref<HitDebugData>) -> Void {
    let appliedDamage: ref<DamageDebugData>;
    let calculatedDamage: ref<DamageDebugData>;
    let damageType: gamedataDamageType;
    let hitFlagEnums: String;
    let i: Int32;
    let attackData: ref<AttackData> = hitEvent.attackData;
    let flags: array<SHitFlag> = attackData.GetFlags();
    let appliedDamages: array<Float> = hitEvent.attackComputed.GetAttackValues();
    let calculatedDamages: array<Float> = hitEvent.attackComputed.GetOriginalAttackValues();
    hitDebugData.instigator = attackData.GetInstigator();
    hitDebugData.source = attackData.GetSource();
    hitDebugData.target = hitEvent.target;
    hitDebugData.sourceHitPosition = attackData.GetSource().GetWorldPosition();
    hitDebugData.targetHitPosition = hitEvent.target.GetWorldPosition();
    if IsDefined(hitDebugData.instigator) {
      hitDebugData.instigatorName = StringToName(hitDebugData.instigator.GetDisplayName());
      if Equals(hitDebugData.instigatorName, n"") {
        hitDebugData.instigatorName = n"[MISSING NAME]";
      };
    };
    if IsDefined(hitDebugData.source) {
      hitDebugData.sourceName = StringToName(hitDebugData.source.GetDisplayName());
      if Equals(hitDebugData.sourceName, n"") {
        hitDebugData.sourceName = n"[MISSING NAME]";
      };
    };
    if IsDefined(hitDebugData.target) {
      hitDebugData.targetName = StringToName(hitDebugData.target.GetDisplayName());
      if Equals(hitDebugData.targetName, n"") {
        hitDebugData.targetName = n"[MISSING NAME]";
      };
    };
    hitDebugData.sourceAttackDebugData = attackData.GetAttackDefinition().GetDebugData();
    if IsDefined(attackData.GetWeapon()) {
      hitDebugData.sourceWeaponName = StringToName(TDBID.ToStringDEBUG(ItemID.GetTDBID(attackData.GetWeapon().GetItemID())));
      if Equals(hitDebugData.sourceWeaponName, n"") {
        hitDebugData.sourceWeaponName = n"[MISSING NAME]";
      };
    };
    hitDebugData.sourceAttackName = StringToName(TDBID.ToStringDEBUG(attackData.GetAttackDefinition().GetRecord().GetID()));
    i = 0;
    while i < ArraySize(appliedDamages) {
      damageType = IntEnum(i);
      appliedDamage = new DamageDebugData();
      appliedDamage.statPoolType = gamedataStatPoolType.Health;
      appliedDamage.damageType = damageType;
      appliedDamage.value = appliedDamages[i];
      ArrayPush(hitDebugData.appliedDamages, appliedDamage);
      calculatedDamage = new DamageDebugData();
      calculatedDamage.statPoolType = gamedataStatPoolType.Health;
      calculatedDamage.damageType = damageType;
      calculatedDamage.value = calculatedDamages[i];
      ArrayPush(hitDebugData.calculatedDamages, calculatedDamage);
      i += 1;
    };
    hitDebugData.hitType = StringToName(EnumValueToString("gameeventsHitEventType", EnumInt(attackData.GetAttackType())));
    i = 0;
    while i < ArraySize(flags) {
      hitFlagEnums += EnumValueToString("hitFlag", EnumInt(flags[i].flag));
      hitFlagEnums += "," + ToString(flags[i].source);
      hitFlagEnums += "|";
      i += 1;
    };
    hitDebugData.hitFlags = StringToName(hitFlagEnums);
  }

  private final func FillInDamageBlackboard(hitEvent: ref<gameHitEvent>) -> Void {
    let damage: Int32;
    let player: wref<PlayerPuppet> = hitEvent.attackData.GetInstigator() as PlayerPuppet;
    let blackboard: ref<IBlackboard> = GameInstance.GetBlackboardSystem(player.GetGame()).Get(GetAllBlackboardDefs().UI_NameplateData);
    if IsDefined(player) && IsDefined(blackboard) {
      damage = Cast(hitEvent.attackComputed.GetTotalAttackValue(gamedataStatPoolType.Health));
      if damage != blackboard.GetInt(GetAllBlackboardDefs().UI_NameplateData.DamageProjection) {
        blackboard.SetInt(GetAllBlackboardDefs().UI_NameplateData.DamageProjection, damage, true);
      };
    };
  }

  private final func GatherServerData(hitEvent: ref<gameHitEvent>, cache: ref<CacheData>, out serverHitData: ref<ServerHitData>) -> Void {
    LogAssert(IsServer(), "GatherServerData was called on a client");
    if hitEvent.attackData.HasFlag(hitFlag.DealNoDamage) {
      return;
    };
    serverHitData.damageInfos = this.ConvertHitDataToDamageInfo(hitEvent);
    serverHitData.instigator = hitEvent.attackData.GetInstigator();
  }

  public final func ConvertHitDataToDamageInfo(hitEvent: ref<gameHitEvent>) -> array<DamageInfo> {
    let attackValues: array<Float>;
    let dmgInfo: DamageInfo;
    let dmgPosition: Vector4;
    let finalDmgValue: Float;
    let i: Int32;
    let result: array<DamageInfo>;
    let hitShapes: array<HitShapeData> = hitEvent.hitRepresentationResult.hitShapes;
    dmgInfo.userData = new DamageInfoUserData();
    dmgInfo.userData.flags = hitEvent.attackData.GetFlags();
    if ArraySize(hitShapes) != 0 {
      dmgPosition = hitShapes[0].result.hitPositionEnter;
      dmgInfo.userData.hitShapeType = DamageSystemHelper.GetHitShapeTypeFromData(hitShapes[0]);
    } else {
      dmgPosition = hitEvent.hitPosition;
    };
    dmgInfo.hitPosition = dmgPosition;
    dmgInfo.hitType = hitEvent.attackData.GetHitType();
    if IsDefined(hitEvent.target) {
      if !IsMultiplayer() || hitEvent.target.IsReplicated() || EntityID.IsStatic(hitEvent.target.GetEntityID()) {
        dmgInfo.entityHit = hitEvent.target;
      };
    };
    if IsDefined(hitEvent.attackData.GetInstigator()) {
      if !IsMultiplayer() || hitEvent.attackData.GetInstigator().IsReplicated() || EntityID.IsStatic(hitEvent.attackData.GetInstigator().GetEntityID()) {
        dmgInfo.instigator = hitEvent.attackData.GetInstigator();
      };
    };
    if !hitEvent.attackData.HasFlag(hitFlag.DamageNullified) {
      attackValues = hitEvent.attackComputed.GetAttackValues();
      i = 0;
      while i < ArraySize(attackValues) {
        finalDmgValue += attackValues[i];
        i += 1;
      };
    } else {
      finalDmgValue = 0.00;
    };
    if AttackData.IsDoT(hitEvent.attackData.GetAttackType()) {
      dmgInfo.damageType = hitEvent.attackComputed.GetDominatingDamageType();
    } else {
      dmgInfo.damageType = gamedataDamageType.Physical;
    };
    dmgInfo.damageValue = finalDmgValue;
    ArrayPush(result, dmgInfo);
    return result;
  }

  private final func ProcessClientHit(serverHitData: ref<ServerHitData>) -> Void {
    LogAssert(!IsServer(), "ProcessClientHit called on server");
    if IsDefined(serverHitData.instigator) && serverHitData.instigator.IsControlledByLocalPeer() {
      serverHitData.instigator.DisplayHitUI(serverHitData.damageInfos);
    };
  }

  private final func ProcessClientKill(serverKillData: ref<ServerKillData>) -> Void {
    LogAssert(!IsServer(), "ProcessClientKill called on server");
    if IsDefined(serverKillData.killInfo.killerEntity) && serverKillData.killInfo.killerEntity.IsControlledByLocalPeer() {
      serverKillData.killInfo.killerEntity.DisplayKillUI(serverKillData.killInfo);
    };
  }

  private final func PreProcess(hitEvent: ref<gameHitEvent>, cache: ref<CacheData>) -> Bool {
    this.ConvertDPSToHitDamage(hitEvent);
    this.CalculateDamageVariants(hitEvent);
    this.CacheLocalVars(hitEvent, cache);
    if Cast(GetDamageSystemLogFlags() & damageSystemLogFlags.GENERAL) {
      LogDamage("");
      LogDamage("  --== Starting damage processing from " + hitEvent.attackData.GetSource().GetDisplayName() + " to " + hitEvent.target.GetDisplayName() + " ==--");
    };
    this.ModifyHitFlagsForPlayer(hitEvent, cache);
    if this.CheckForQuickExit(hitEvent, cache) {
      return false;
    };
    this.InvulnerabilityCheck(hitEvent, cache);
    this.ImmortalityCheck(hitEvent, cache);
    this.DeathCheck(hitEvent);
    this.ModifyHitData(hitEvent);
    return true;
  }

  private final func ConvertDPSToHitDamage(hitEvent: ref<gameHitEvent>) -> Void {
    let projectilesPerShot: Float;
    let statsSystem: ref<StatsSystem> = GameInstance.GetStatsSystem(hitEvent.attackData.GetSource().GetGame());
    let weaponObject: ref<WeaponObject> = hitEvent.attackData.GetWeapon();
    if !IsDefined(weaponObject) {
      return;
    };
    if !hitEvent.attackData.GetInstigator().IsPlayer() {
      if weaponObject.IsRanged() && !AttackData.IsMelee(hitEvent.attackData.GetAttackType()) {
        projectilesPerShot = statsSystem.GetStatValue(Cast(hitEvent.attackData.GetInstigator().GetEntityID()), gamedataStatType.ProjectilesPerShot);
        if projectilesPerShot > 0.00 {
          hitEvent.attackComputed.MultAttackValue(1.00 / projectilesPerShot);
        };
      };
    };
  }

  private final func CalculateDamageVariants(hitEvent: ref<gameHitEvent>) -> Void {
    let rand: Float;
    if hitEvent.projectionPipeline {
      return;
    };
    if hitEvent.attackData.GetInstigator().IsPlayer() && !hitEvent.target.IsPlayer() {
      rand = RandRangeF(0.90, 1.10);
      hitEvent.attackComputed.MultAttackValue(rand);
    };
  }

  private final func ModifyHitData(hitEvent: ref<gameHitEvent>) -> Void {
    DamageManager.ModifyHitData(hitEvent);
    if hitEvent.attackComputed.GetTotalAttackValue(gamedataStatPoolType.Health) == 0.00 {
      hitEvent.attackData.AddFlag(hitFlag.DealNoDamage, n"no_valid_damage");
    };
    this.ProcessDamageReduction(hitEvent);
    this.ProcessLocalizedDamage(hitEvent);
    this.ProcessFinisher(hitEvent);
    this.ProcessInstantKill(hitEvent);
    this.ProcessDodge(hitEvent);
    this.ProcessPlayerIncomingDamageMultiplier(hitEvent);
  }

  private final func ProcessDamageReduction(hitEvent: ref<gameHitEvent>) -> Void {
    if hitEvent.attackData.HasFlag(hitFlag.ReduceDamage) {
      hitEvent.attackComputed.MultAttackValue(0.10);
    };
  }

  private final func ProcessLocalizedDamage(hitEvent: ref<gameHitEvent>) -> Void {
    let hitShapeDamageMod: Float;
    let hitUserData: ref<HitShapeUserDataBase>;
    let immunity: Int32;
    let multValue: Float;
    let hitShapes: array<HitShapeData> = hitEvent.hitRepresentationResult.hitShapes;
    if !hitEvent.attackData.GetInstigator().IsPlayer() {
      return;
    };
    if AttackData.IsAreaOfEffect(hitEvent.attackData.GetAttackType()) {
      return;
    };
    if ArraySize(hitShapes) > 0 {
      hitUserData = DamageSystemHelper.GetHitShapeUserDataBase(hitShapes[0]);
    };
    if !IsDefined(hitUserData) {
      return;
    };
    if hitEvent.attackData.HasFlag(hitFlag.DamageNullified) {
      hitEvent.attackComputed.MultAttackValue(0.00);
    };
    if HitShapeUserDataBase.IsInternalWeakspot(hitUserData) || IsDefined(hitEvent.target as WeakspotObject) {
      hitEvent.attackData.AddFlag(hitFlag.WeakspotHit, n"ProcessLocalizedDamage");
    };
    if AttackData.IsBullet(hitEvent.attackData.GetAttackType()) && HitShapeUserDataBase.IsHitReactionZoneHead(hitUserData) {
      multValue = 1.00 + GameInstance.GetStatsSystem(hitEvent.target.GetGame()).GetStatValue(Cast(hitEvent.attackData.GetInstigator().GetEntityID()), gamedataStatType.HeadshotDamageMultiplier);
      immunity = Cast(GameInstance.GetStatsSystem(hitEvent.target.GetGame()).GetStatValue(Cast(hitEvent.target.GetEntityID()), gamedataStatType.HeadshotImmunity));
      if !FloatIsEqual(multValue, 0.00) && immunity == 0 {
        hitEvent.attackData.AddFlag(hitFlag.Headshot, n"ProcessLocalizedDamage");
        hitEvent.attackComputed.MultAttackValue(1.00 + multValue);
      };
    };
    hitShapeDamageMod = HitShapeUserDataBase.GetHitShapeDamageMod(hitUserData);
    if hitShapeDamageMod != 0.00 {
      hitEvent.attackComputed.MultAttackValue(hitShapeDamageMod);
    };
    multValue = DamageSystemHelper.GetLocalizedDamageMultiplier(hitUserData.m_hitShapeType);
    hitEvent.attackComputed.MultAttackValue(multValue);
  }

  private final func ProcessFinisher(hitEvent: ref<gameHitEvent>) -> Void {
    let broadcaster: ref<StimBroadcasterComponent>;
    let choiceData: DialogChoiceHubs;
    let interactionData: ref<UIInteractionsDef>;
    let interactonsBlackboard: ref<IBlackboard>;
    let tags: array<CName>;
    let targetPuppet: wref<ScriptedPuppet>;
    let weaponRecord: ref<Item_Record>;
    let attackData: ref<AttackData> = hitEvent.attackData;
    let weapon: ref<WeaponObject> = attackData.GetWeapon();
    let gameInstance: GameInstance = GetGameInstance();
    if hitEvent.projectionPipeline {
      return;
    };
    if !IsDefined(weapon) {
      return;
    };
    weaponRecord = TweakDBInterface.GetWeaponItemRecord(ItemID.GetTDBID(weapon.GetItemID()));
    if attackData.HasFlag(hitFlag.DoNotTriggerFinisher) || attackData.HasFlag(hitFlag.Nonlethal) {
      return;
    };
    if !attackData.GetInstigator().IsPlayer() {
      return;
    };
    if StatusEffectSystem.ObjectHasStatusEffect(attackData.GetInstigator(), t"GameplayRestriction.FistFight") {
      return;
    };
    if Equals(attackData.GetInstigator().GetAttitudeTowards(hitEvent.target), EAIAttitude.AIA_Friendly) {
      return;
    };
    tags = weaponRecord.Tags();
    if !ArrayContains(tags, n"FinisherFront") && !ArrayContains(tags, n"FinisherBack") {
      return;
    };
    targetPuppet = hitEvent.target as ScriptedPuppet;
    if !IsDefined(targetPuppet) {
      return;
    };
    if targetPuppet.IsCrowd() || targetPuppet.IsCharacterCivilian() {
      return;
    };
    if !ScriptedPuppet.IsActive(targetPuppet) {
      return;
    };
    if StatusEffectSystem.ObjectHasStatusEffect(targetPuppet, t"GameplayRestriction.FistFight") {
      return;
    };
    if GameInstance.GetGodModeSystem(gameInstance).HasGodMode(targetPuppet.GetEntityID(), gameGodModeType.Immortal) {
      return;
    };
    if GameInstance.GetGodModeSystem(gameInstance).HasGodMode(targetPuppet.GetEntityID(), gameGodModeType.Invulnerable) {
      return;
    };
    if targetPuppet.IsMassive() {
      return;
    };
    if Equals(targetPuppet.GetPuppetRarity().Type(), gamedataNPCRarity.Boss) && !targetPuppet.IsCharacterCyberpsycho() {
      return;
    };
    if NotEquals(targetPuppet.GetNPCType(), gamedataNPCType.Human) {
      return;
    };
    if attackData.WasBlocked() || attackData.WasDeflected() {
      return;
    };
    if !AttackData.IsStrongMelee(attackData.GetAttackType()) {
      return;
    };
    interactonsBlackboard = GameInstance.GetBlackboardSystem(gameInstance).Get(GetAllBlackboardDefs().UIInteractions);
    interactionData = GetAllBlackboardDefs().UIInteractions;
    choiceData = FromVariant(interactonsBlackboard.GetVariant(interactionData.DialogChoiceHubs));
    if ArraySize(choiceData.choiceHubs) > 0 {
      return;
    };
    if (StatPoolsManager.SimulateDamageDeal(hitEvent) || this.CanTriggerMeleeLeapFinisher(attackData, hitEvent)) && this.PlayFinisherGameEffect(hitEvent, ArrayContains(tags, n"FinisherFront"), ArrayContains(tags, n"FinisherBack")) {
      attackData.AddFlag(hitFlag.DealNoDamage, n"Finisher");
      broadcaster = targetPuppet.GetStimBroadcasterComponent();
      if IsDefined(broadcaster) {
        broadcaster.TriggerSingleBroadcast(targetPuppet, gamedataStimType.Scream, 10.00);
      };
      RPGManager.GiveReward(gameInstance, t"RPGActionRewards.ColdBlood", Cast(hitEvent.target.GetEntityID()));
    };
  }

  private final func CanTriggerMeleeLeapFinisher(attackData: ref<AttackData>, hitEvent: ref<gameHitEvent>) -> Bool {
    let isMeleeLeap: Bool;
    let psmBlackBoard: ref<IBlackboard>;
    let targetPuppet: wref<NPCPuppet>;
    if !RPGManager.HasStatFlag(attackData.GetInstigator(), gamedataStatType.CanMeleeLeapTakedown) {
      return false;
    };
    if !this.IsPowerLevelDifferentialAcceptable(hitEvent) {
      return false;
    };
    targetPuppet = hitEvent.target as NPCPuppet;
    if targetPuppet.IsPuppetTargetingPlayer() {
      return false;
    };
    psmBlackBoard = GameInstance.GetBlackboardSystem(GetGameInstance()).GetLocalInstanced(attackData.GetInstigator().GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
    isMeleeLeap = psmBlackBoard.GetBool(GetAllBlackboardDefs().PlayerStateMachine.MeleeLeap);
    if isMeleeLeap {
      return true;
    };
    return false;
  }

  private final func IsPowerLevelDifferentialAcceptable(hitEvent: ref<gameHitEvent>) -> Bool {
    let powDifference: EPowerDifferential = RPGManager.CalculatePowerDifferential(hitEvent.target);
    if Equals(powDifference, EPowerDifferential.IMPOSSIBLE) {
      return false;
    };
    return true;
  }

  private final func ProcessInstantKill(hitEvent: ref<gameHitEvent>) -> Void {
    let attackData: ref<AttackData> = hitEvent.attackData;
    let targetID: StatsObjectID = Cast(hitEvent.target.GetEntityID());
    if hitEvent.projectionPipeline {
      return;
    };
    if attackData.HasFlag(hitFlag.Kill) {
      attackData.AddFlag(hitFlag.DealNoDamage, n"instant_kill");
      attackData.AddFlag(hitFlag.DontShowDamageFloater, n"instant_kill");
      GameInstance.GetStatPoolsSystem(GetGameInstance()).RequestSettingStatPoolMinValue(targetID, gamedataStatPoolType.Health, attackData.GetInstigator());
    };
  }

  private final func ProcessDodge(hitEvent: ref<gameHitEvent>) -> Void {
    if GameInstance.GetStatsSystem(GetGameInstance()).GetStatBoolValue(Cast(hitEvent.target.GetEntityID()), gamedataStatType.IsDodging) {
      hitEvent.attackData.AddFlag(hitFlag.DealNoDamage, n"ProcessDodge");
      if hitEvent.target.IsPlayer() {
        this.SetTutorialFact(n"gmpl_player_dodged_attack");
      };
    };
  }

  private final func ProcessPlayerIncomingDamageMultiplier(hitEvent: ref<gameHitEvent>) -> Void {
    let playerIncomingDamageMultiplier: Float = hitEvent.attackData.GetAttackDefinition().GetRecord().PlayerIncomingDamageMultiplier();
    if IsDefined(hitEvent.target as PlayerPuppet) || ScriptedPuppet.IsPlayerCompanion(hitEvent.target) {
      if playerIncomingDamageMultiplier != 1.00 {
        Log("");
      };
      hitEvent.attackComputed.MultAttackValue(playerIncomingDamageMultiplier);
    } else {
      if ScriptedPuppet.IsPlayerCompanion(hitEvent.attackData.GetInstigator()) && !hitEvent.target.IsPlayer() {
        hitEvent.attackComputed.MultAttackValue(playerIncomingDamageMultiplier);
      };
    };
  }

  private final func InvulnerabilityCheck(hitEvent: ref<gameHitEvent>, cache: ref<CacheData>) -> Void {
    if hitEvent.attackData.HasFlag(hitFlag.IgnoreImmortalityModes) {
      return;
    };
    if this.IsTargetInvulnerable(cache) {
      hitEvent.attackData.AddFlag(hitFlag.DealNoDamage, n"invulnerable");
      if Cast(cache.logFlags & damageSystemLogFlags.GENERAL) {
        LogDamage("DamageSystem.InvulnerabilityCheck(): " + hitEvent.target.GetDisplayName() + "\'s invulnerability reduces damage received to 0");
      };
    };
    if GameInstance.GetStatsSystem(hitEvent.target.GetGame()).GetStatValue(Cast(hitEvent.target.GetEntityID()), gamedataStatType.IsInvulnerable) > 0.00 {
      hitEvent.attackData.AddFlag(hitFlag.DealNoDamage, n"invulnerable stat flag");
    };
  }

  private final func ImmortalityCheck(hitEvent: ref<gameHitEvent>, cache: ref<CacheData>) -> Void {
    if hitEvent.attackData.HasFlag(hitFlag.IgnoreImmortalityModes) {
      return;
    };
    if this.IsTargetImmortal(cache) {
      hitEvent.attackData.AddFlag(hitFlag.ImmortalTarget, n"immortal");
      if Cast(cache.logFlags & damageSystemLogFlags.GENERAL) {
        LogDamage("DamageSystem.ImmortalityCheck(): " + hitEvent.target.GetDisplayName() + "\'s immortality modifies damage (if drops to 0, it\'s restored");
      };
    };
  }

  private final func DeathCheck(hitEvent: ref<gameHitEvent>) -> Void {
    let deviceTarget: ref<Device> = hitEvent.target as Device;
    let gameObjectTarget: ref<GameObject> = hitEvent.target;
    if IsDefined(deviceTarget) && deviceTarget.GetDevicePS().IsBroken() || IsDefined(gameObjectTarget) && gameObjectTarget.IsDead() {
      hitEvent.attackData.AddFlag(hitFlag.DealNoDamage, n"dead");
    };
  }

  private final func Process(hitEvent: ref<gameHitEvent>, cache: ref<CacheData>) -> Void {
    if hitEvent.attackData.HasFlag(hitFlag.DealNoDamage) {
      return;
    };
    this.CalculateSourceModifiers(hitEvent);
    this.CalculateTargetModifiers(hitEvent);
    this.CalculateSourceVsTargetModifiers(hitEvent);
    this.CalculateGlobalModifiers(hitEvent, cache);
    this.ProcessCrowdTarget(hitEvent);
    this.ProcessVehicleTarget(hitEvent);
    this.ProcessVehicleHit(hitEvent);
    this.ProcessRagdollHit(hitEvent);
    this.ProcessTurretAttack(hitEvent);
    this.ProcessDeviceTarget(hitEvent);
    this.ProcessQuickHackModifiers(hitEvent);
    this.ProcessOneShotProtection(hitEvent);
    if !hitEvent.projectionPipeline {
      this.DealDamages(hitEvent);
    };
  }

  private final func ProcessHitReaction(hitEvent: ref<gameHitEvent>) -> Void {
    hitEvent.target.ReactToHitProcess(hitEvent);
  }

  private final func ProcessRagdollHit(hitEvent: ref<gameHitEvent>) -> Void {
    let curveDamagePercentage: Float;
    let heightDeltaMultiplier: Float;
    let isHighFall: Bool;
    let targetIsFriendly: Bool;
    let targetMaxHealth: Float;
    let terminalVelocityReached: Bool;
    let ragdollHitEvent: ref<gameRagdollHitEvent> = hitEvent as gameRagdollHitEvent;
    let targetPuppet: ref<ScriptedPuppet> = hitEvent.target as ScriptedPuppet;
    if !IsDefined(ragdollHitEvent) || !IsDefined(targetPuppet) {
      return;
    };
    targetIsFriendly = Equals(GameObject.GetAttitudeTowards(targetPuppet, GameInstance.GetPlayerSystem(targetPuppet.GetGame()).GetLocalPlayerControlledGameObject()), EAIAttitude.AIA_Friendly);
    if targetIsFriendly {
      hitEvent.attackComputed.SetAttackValue(0.00);
      return;
    };
    terminalVelocityReached = ragdollHitEvent.speedDelta >= TweakDBInterface.GetFloat(t"AIGeneralSettings.ragdollImpactKillVelocityThreshold", 11.00);
    isHighFall = ragdollHitEvent.speedDelta >= TweakDBInterface.GetFloat(t"AIGeneralSettings.ragdollHighFallVelocityThreshold", 8.00) && ragdollHitEvent.heightDelta >= TweakDBInterface.GetFloat(t"AIGeneralSettings.ragdollHighFallHeightThreshold", 6.00);
    targetMaxHealth = GameInstance.GetStatsSystem(targetPuppet.GetGame()).GetStatValue(Cast(targetPuppet.GetEntityID()), gamedataStatType.Health);
    if terminalVelocityReached || isHighFall {
      if IsDefined(targetPuppet as NPCPuppet) {
        (targetPuppet as NPCPuppet).SetMyKiller(hitEvent.attackData.GetInstigator());
        (targetPuppet as NPCPuppet).MarkForDeath();
      };
      hitEvent.attackComputed.SetAttackValue(targetMaxHealth, gamedataDamageType.Physical);
      hitEvent.attackData.AddFlag(hitFlag.DeterministicDamage, n"ragdoll_collision");
    } else {
      if NotEquals(RPGManager.CalculatePowerDifferential(targetPuppet), EPowerDifferential.IMPOSSIBLE) {
        curveDamagePercentage = GameInstance.GetStatsDataSystem(targetPuppet.GetGame()).GetValueFromCurve(n"puppet_ragdoll_force_to_damage", ragdollHitEvent.speedDelta, n"ragdoll_speed_to_damage");
        heightDeltaMultiplier = GameInstance.GetStatsDataSystem(targetPuppet.GetGame()).GetValueFromCurve(n"puppet_ragdoll_force_to_damage", ragdollHitEvent.heightDelta, n"ragdoll_altitude_difference_multiplier");
        hitEvent.attackComputed.SetAttackValue(curveDamagePercentage * heightDeltaMultiplier * targetMaxHealth, gamedataDamageType.Physical);
      };
    };
  }

  private final func ProcessCrowdTarget(hitEvent: ref<gameHitEvent>) -> Void {
    let attackDistance: Float;
    let currentHealth: Float;
    let damage: Float;
    let inCombat: Bool;
    let numHitsToDefeat: Float;
    let playerIsZooming: Bool;
    let targetCurrentHealth: Float;
    let targetHealth: Float;
    let thresholdDistance: Float;
    let weapon: wref<WeaponObject>;
    let weaponType: gamedataItemType;
    let weaponZoom: Float;
    let targetPuppet: ref<NPCPuppet> = hitEvent.target as NPCPuppet;
    let instigator: wref<GameObject> = hitEvent.attackData.GetInstigator();
    if !IsDefined(targetPuppet) || !targetPuppet.IsCrowd() || IsDefined(hitEvent as gameRagdollHitEvent) || IsDefined(hitEvent as gameVehicleHitEvent) {
      return;
    };
    if hitEvent.projectionPipeline {
      return;
    };
    hitEvent.attackData.AddFlag(hitFlag.DontShowDamageFloater, n"target is crowd");
    targetHealth = GameInstance.GetStatsSystem(targetPuppet.GetGame()).GetStatValue(Cast(targetPuppet.GetEntityID()), gamedataStatType.Health);
    targetCurrentHealth = GameInstance.GetStatPoolsSystem(targetPuppet.GetGame()).GetStatPoolValue(Cast(targetPuppet.GetEntityID()), gamedataStatPoolType.Health, false);
    weapon = hitEvent.attackData.GetWeapon();
    if IsDefined(weapon) {
      weaponType = WeaponObject.GetWeaponType(weapon.GetItemID());
    };
    if IsDefined(hitEvent.attackData.GetSource() as BaseGrenade) && Equals(hitEvent.attackData.GetAttackType(), gamedataAttackType.Direct) {
      hitEvent.attackComputed.SetAttackValue(0.00);
      if FloorF(targetCurrentHealth) > 2 {
        hitEvent.attackComputed.SetAttackValue(1.00, gamedataDamageType.Physical);
      };
    } else {
      if Equals(weaponType, gamedataItemType.Wea_Fists) || Equals(hitEvent.attackData.GetAttackType(), gamedataAttackType.QuickMelee) {
        numHitsToDefeat = Cast(TweakDBInterface.GetInt(t"Constants.DamageSystem.maxShotsToDefeatCrowd", 2)) + 1.00;
        damage = targetHealth / numHitsToDefeat;
        hitEvent.attackComputed.SetAttackValue(damage, gamedataDamageType.Physical);
      } else {
        if instigator.IsPlayer() {
          hitEvent.attackComputed.SetAttackValue(0.00);
          if (instigator as PlayerPuppet).IsInCombat() {
            numHitsToDefeat = Cast(TweakDBInterface.GetInt(t"Constants.DamageSystem.inCombatMaxShotsToDefeatCrowd", 1));
            thresholdDistance = TweakDBInterface.GetFloat(t"Constants.DamageSystem.inCombatMaxDistanceForCrowdOneShot", 10.00);
            inCombat = true;
          } else {
            numHitsToDefeat = Cast(TweakDBInterface.GetInt(t"Constants.DamageSystem.maxShotsToDefeatCrowd", 1));
            thresholdDistance = TweakDBInterface.GetFloat(t"Constants.DamageSystem.maxDistanceForCrowdOneShot", 10.00);
          };
          playerIsZooming = Cast(GameInstance.GetBlackboardSystem(targetPuppet.GetGame()).GetLocalInstanced(instigator.GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine).GetInt(GetAllBlackboardDefs().PlayerStateMachine.UpperBody));
          weaponZoom = GameInstance.GetStatsSystem(targetPuppet.GetGame()).GetStatValue(Cast(weapon.GetEntityID()), gamedataStatType.ZoomLevel);
          attackDistance = Vector4.Length(hitEvent.attackData.GetAttackPosition() - hitEvent.hitPosition);
          if playerIsZooming {
            thresholdDistance *= weaponZoom;
          };
          if Equals(weaponType, gamedataItemType.Wea_HeavyMachineGun) || Equals(weaponType, gamedataItemType.Wea_Shotgun) || Equals(weaponType, gamedataItemType.Wea_ShotgunDual) || Equals(weaponType, gamedataItemType.Wea_Revolver) {
            thresholdDistance *= 1.50;
            if inCombat {
              numHitsToDefeat -= 1.00;
            };
          };
          if attackDistance <= thresholdDistance && (inCombat && IsDefined(weapon) || !inCombat) || Equals(weaponType, gamedataItemType.Wea_SniperRifle) {
            hitEvent.attackComputed.SetAttackValue(targetHealth, gamedataDamageType.Physical);
          } else {
            if !GameObject.IsCooldownActive(targetPuppet, n"crowdDamage") {
              GameObject.StartCooldown(targetPuppet, n"crowdDamage", 1.00);
              damage = targetHealth / numHitsToDefeat;
              if !IsDefined(weapon) {
                damage += damage;
              };
              hitEvent.attackComputed.SetAttackValue(damage, gamedataDamageType.Physical);
              this.TutorialAddIllegalActionFact(targetPuppet);
            };
          };
        };
      };
    };
    if instigator.IsPrevention() {
      currentHealth = GameInstance.GetStatPoolsSystem(targetPuppet.GetGame()).GetStatPoolValue(Cast(targetPuppet.GetEntityID()), gamedataStatPoolType.Health, false);
      if hitEvent.attackComputed.GetTotalAttackValue(gamedataStatPoolType.Health) > currentHealth {
        hitEvent.attackComputed.SetAttackValue(MaxF(currentHealth - 2.00, 0.00), gamedataDamageType.Physical);
      };
    };
  }

  private final func TutorialAddIllegalActionFact(targetPuppet: ref<NPCPuppet>) -> Void {
    let questSystem: ref<QuestsSystem> = GameInstance.GetQuestsSystem(targetPuppet.GetGame());
    if questSystem.GetFact(n"illegal_action_tutorial") == 0 && questSystem.GetFact(n"disable_tutorials") == 0 {
      questSystem.SetFact(n"illegal_action_tutorial", 1);
    };
  }

  private final func ProcessTurretAttack(hitEvent: ref<gameHitEvent>) -> Void {
    let instigatorTurret: ref<SecurityTurret> = hitEvent.attackData.GetInstigator() as SecurityTurret;
    let isTurretFriendlyToPlayer: Bool = Equals(GameObject.GetAttitudeTowards(instigatorTurret, GameInstance.GetPlayerSystem(GetGameInstance()).GetLocalPlayerControlledGameObject()), EAIAttitude.AIA_Friendly);
    if IsDefined(instigatorTurret) && isTurretFriendlyToPlayer {
      hitEvent.attackComputed.MultAttackValue(15.00);
    };
  }

  private final func ProcessDeviceTarget(hitEvent: ref<gameHitEvent>) -> Void {
    let targetDevice: ref<Device> = hitEvent.target as Device;
    if IsDefined(targetDevice) && !targetDevice.ShouldShowDamageNumber() {
      hitEvent.attackData.AddFlag(hitFlag.DontShowDamageFloater, n"device");
    };
  }

  private final func ProcessOneShotProtection(hitEvent: ref<gameHitEvent>) -> Void {
    let damageCap: Float;
    let damages: array<Float>;
    let i: Int32;
    let playerMaxHealth: Float;
    let reductionProportion: Float;
    if hitEvent.target.IsPlayer() && !hitEvent.attackData.GetInstigator().IsPlayer() && IsDefined(hitEvent.attackData.GetWeapon()) {
      playerMaxHealth = GameInstance.GetStatsSystem(hitEvent.target.GetGame()).GetStatValue(Cast(hitEvent.target.GetEntityID()), gamedataStatType.Health);
      damageCap = (playerMaxHealth * TweakDBInterface.GetFloat(t"Constants.DamageSystem.maxPercentDamagePerHitPlayer", 0.00)) / 100.00;
      if hitEvent.attackComputed.GetTotalAttackValue(gamedataStatPoolType.Health) > damageCap {
        reductionProportion = damageCap / hitEvent.attackComputed.GetTotalAttackValue(gamedataStatPoolType.Health);
        damages = hitEvent.attackComputed.GetAttackValues();
        i = 0;
        while i < ArraySize(damages) {
          damages[i] *= reductionProportion;
          i += 1;
        };
        hitEvent.attackComputed.SetAttackValues(damages);
      };
    };
  }

  private final func ProcessQuickHackModifiers(hitEvent: ref<gameHitEvent>) -> Void {
    let attackRecord: ref<Attack_GameEffect_Record>;
    let attackType: gamedataAttackType;
    let currentHealthPercentage: Float;
    let damageMultiplier: Float;
    let hitFlags: array<String>;
    let i: Int32;
    let statValue: Float;
    let targetNpcRarity: gamedataNPCRarity;
    let targetNpcType: gamedataNPCType;
    let statusEffectSystem: ref<StatusEffectSystem> = GameInstance.GetStatusEffectSystem(GetGameInstance());
    let player: wref<PlayerPuppet> = hitEvent.attackData.GetInstigator() as PlayerPuppet;
    if !IsDefined(player) {
      return;
    };
    if !hitEvent.target.IsPuppet() {
      return;
    };
    if Equals(hitEvent.attackData.GetHitType(), gameuiHitType.CriticalHit) {
      attackType = hitEvent.attackData.GetAttackType();
      if GameInstance.GetStatsSystem(player.GetGame()).GetStatValue(Cast(player.GetEntityID()), gamedataStatType.ShortCircuitOnCriticalHit) == 1.00 && !statusEffectSystem.HasStatusEffectWithTag(hitEvent.target.GetEntityID(), n"Overload") && (Equals(attackType, gamedataAttackType.ChargedWhipAttack) || Equals(attackType, gamedataAttackType.Melee) || Equals(attackType, gamedataAttackType.QuickMelee) || Equals(attackType, gamedataAttackType.Ranged) || Equals(attackType, gamedataAttackType.StrongMelee) || Equals(attackType, gamedataAttackType.Thrown) || Equals(attackType, gamedataAttackType.WhipAttack)) {
        statusEffectSystem.ApplyStatusEffect(hitEvent.target.GetEntityID(), t"BaseStatusEffect.Overload", GameObject.GetTDBID(player), player.GetEntityID(), 1u, hitEvent.hitDirection);
      };
    };
    if NotEquals(hitEvent.attackData.GetAttackType(), gamedataAttackType.Hack) {
      return;
    };
    damageMultiplier = 1.00;
    attackRecord = hitEvent.attackData.GetAttackDefinition().GetRecord() as Attack_GameEffect_Record;
    hitFlags = attackRecord.HitFlags();
    targetNpcType = (hitEvent.target as ScriptedPuppet).GetNPCType();
    targetNpcRarity = (hitEvent.target as ScriptedPuppet).GetPuppetRarity().Type();
    i = 0;
    while i < ArraySize(hitFlags) {
      if Equals(hitFlags[i], "MechanicalDamageBonus") {
        if Equals(targetNpcType, gamedataNPCType.Drone) || Equals(targetNpcType, gamedataNPCType.Android) || Equals(targetNpcType, gamedataNPCType.Mech) {
          damageMultiplier += TweakDBInterface.GetFloat(attackRecord.GetID() + t".mechanicalDamageBonusMultiplier", 1.00);
        };
      };
      if Equals(hitFlags[i], "FleshDamageBonus") {
        if Equals(targetNpcType, gamedataNPCType.Human) {
          damageMultiplier += TweakDBInterface.GetFloat(attackRecord.GetID() + t".fleshDamageBonusMultiplier", 1.00);
        };
      };
      if Equals(hitFlags[i], "DamageBasedOnMissingHealthBonus") {
        currentHealthPercentage = GameInstance.GetStatPoolsSystem(hitEvent.target.GetGame()).GetStatPoolValue(Cast(hitEvent.target.GetEntityID()), gamedataStatPoolType.Health, true);
        currentHealthPercentage = currentHealthPercentage / 100.00;
        if currentHealthPercentage < 1.00 {
          damageMultiplier += (1.00 - currentHealthPercentage) * TweakDBInterface.GetFloat(attackRecord.GetID() + t".damageBasedOnMissingHealthBonusMultiplier", 2.00);
        };
      };
      if Equals(hitFlags[i], "NonEliteDamageBonus") {
        if Equals(targetNpcRarity, gamedataNPCRarity.Normal) || Equals(targetNpcRarity, gamedataNPCRarity.Trash) || Equals(targetNpcRarity, gamedataNPCRarity.Weak) {
          damageMultiplier += TweakDBInterface.GetFloat(attackRecord.GetID() + t".nonEliteDamageBonusMultiplier", 0.50);
        };
      };
      i += 1;
    };
    if StatusEffectSystem.ObjectHasStatusEffect(hitEvent.target, t"MinigameAction.VulnerabilityMinigame") {
      statValue = GameInstance.GetStatsSystem(player.GetGame()).GetStatValue(Cast(player.GetEntityID()), gamedataStatType.QuickhackExtraDamageMultiplier);
      if statValue > 0.00 {
        damageMultiplier += statValue;
      };
    };
    if damageMultiplier != 1.00 {
      hitEvent.attackComputed.MultAttackValue(damageMultiplier);
    };
  }

  private final func ProcessVehicleTarget(hitEvent: ref<gameHitEvent>) -> Void {
    let currentHealth: Float;
    let godModeSystem: ref<GodModeSystem>;
    let impactForce: Float;
    let maxDamage: Float;
    let maxHealth: Float;
    let statPoolMod: ref<PoolValueModifier_Record>;
    let targetVehicle: ref<VehicleObject>;
    let threshold: Float;
    let weaponType: gamedataItemType;
    let multiplier: Float = 1.00;
    if hitEvent.projectionPipeline {
      return;
    };
    godModeSystem = GameInstance.GetGodModeSystem(hitEvent.target.GetGame());
    targetVehicle = hitEvent.target as VehicleObject;
    if IsDefined(targetVehicle) {
      hitEvent.attackData.AddFlag(hitFlag.DontShowDamageFloater, n"target is vehicle");
      if hitEvent.attackData.HasFlag(hitFlag.VehicleImpact) {
        impactForce = hitEvent.attackData.GetVehicleImpactForce();
        multiplier = impactForce * 1.30;
      } else {
        hitEvent.attackComputed.MultAttackValue(0.00);
        if AttackData.IsExplosion(hitEvent.attackData.GetAttackType()) {
          hitEvent.attackComputed.SetAttackValue(50.00, gamedataDamageType.Physical);
        } else {
          hitEvent.attackComputed.SetAttackValue(1.00, gamedataDamageType.Physical);
          weaponType = RPGManager.GetItemRecord(hitEvent.attackData.GetWeapon().GetItemID()).ItemType().Type();
          switch weaponType {
            case gamedataItemType.Wea_HeavyMachineGun:
              multiplier = 2.00;
              break;
            case gamedataItemType.Wea_Fists:
              multiplier = 0.10;
              break;
            case gamedataItemType.Wea_TwoHandedClub:
            case gamedataItemType.Wea_ShortBlade:
            case gamedataItemType.Wea_OneHandedClub:
            case gamedataItemType.Wea_LongBlade:
            case gamedataItemType.Wea_Katana:
            case gamedataItemType.Wea_Hammer:
            case gamedataItemType.Wea_Melee:
            case gamedataItemType.Wea_Knife:
              multiplier = 0.30;
              break;
            default:
          };
        };
      };
      hitEvent.attackComputed.MultAttackValue(multiplier, gamedataDamageType.Physical);
      if godModeSystem.HasGodMode(hitEvent.target.GetEntityID(), gameGodModeType.Immortal) {
        maxHealth = GameInstance.GetStatPoolsSystem(hitEvent.target.GetGame()).GetStatPoolMaxPointValue(Cast(hitEvent.target.GetEntityID()), gamedataStatPoolType.Health);
        currentHealth = GameInstance.GetStatPoolsSystem(hitEvent.target.GetGame()).GetStatPoolValue(Cast(hitEvent.target.GetEntityID()), gamedataStatPoolType.Health, false);
        statPoolMod = TweakDBInterface.GetPoolValueModifierRecord(t"BaseStatPools.VehicleHealthDecay");
        threshold = (statPoolMod.RangeEnd() + 1.00) / 100.00;
        maxDamage = currentHealth - maxHealth * threshold;
        if hitEvent.attackComputed.GetAttackValue(gamedataDamageType.Physical) > maxDamage {
          hitEvent.attackComputed.SetAttackValue(maxDamage, gamedataDamageType.Physical);
        };
      };
    };
  }

  private final func ProcessVehicleHit(hitEvent: ref<gameHitEvent>) -> Void {
    let curveDamagePercentage: Float;
    let magnitude: Float;
    let targetIsFriendly: Bool;
    let targetMaxHealth: Float;
    let velocityDiff: Vector4;
    let vehicleHitEvent: ref<gameVehicleHitEvent> = hitEvent as gameVehicleHitEvent;
    let targetPuppet: ref<ScriptedPuppet> = hitEvent.target as ScriptedPuppet;
    if !IsDefined(vehicleHitEvent) || !IsDefined(targetPuppet) {
      return;
    };
    targetIsFriendly = Equals(GameObject.GetAttitudeTowards(targetPuppet, GameInstance.GetPlayerSystem(targetPuppet.GetGame()).GetLocalPlayerControlledGameObject()), EAIAttitude.AIA_Friendly);
    if targetIsFriendly {
      hitEvent.attackComputed.SetAttackValue(0.00);
      return;
    };
    hitEvent.attackData.AddFlag(hitFlag.DontShowDamageFloater, n"vehicle_collision");
    velocityDiff = vehicleHitEvent.vehicleVelocity - vehicleHitEvent.preyVelocity;
    magnitude = Vector4.Length(velocityDiff);
    targetMaxHealth = GameInstance.GetStatsSystem(targetPuppet.GetGame()).GetStatValue(Cast(targetPuppet.GetEntityID()), gamedataStatType.Health);
    if magnitude >= TweakDBInterface.GetFloat(t"AIGeneralSettings.vehicleHitKillThreshold", 20.00) || (targetPuppet.IsCrowd() || targetPuppet.IsCharacterCivilian()) && magnitude >= TweakDBInterface.GetFloat(t"AIGeneralSettings.vehicleHitCrowdKillThreshold", 10.00) {
      if IsDefined(targetPuppet as NPCPuppet) {
        (targetPuppet as NPCPuppet).SetMyKiller(hitEvent.attackData.GetInstigator());
        (targetPuppet as NPCPuppet).MarkForDeath();
      };
      hitEvent.attackComputed.SetAttackValue(targetMaxHealth, gamedataDamageType.Physical);
      hitEvent.attackData.AddFlag(hitFlag.DeterministicDamage, n"vehicle_collision");
    } else {
      if targetPuppet.IsCrowd() || targetPuppet.IsCharacterCivilian() {
        curveDamagePercentage = GameInstance.GetStatsDataSystem(targetPuppet.GetGame()).GetValueFromCurve(n"vehicle_collision_damage", magnitude, n"crowd_hit_damage");
      } else {
        curveDamagePercentage = GameInstance.GetStatsDataSystem(targetPuppet.GetGame()).GetValueFromCurve(n"vehicle_collision_damage", magnitude, n"npc_hit_damage");
      };
      hitEvent.attackComputed.SetAttackValue(curveDamagePercentage * targetMaxHealth, gamedataDamageType.Physical);
      if Equals(RPGManager.CalculatePowerDifferential(targetPuppet), EPowerDifferential.IMPOSSIBLE) {
        hitEvent.attackComputed.MultAttackValue(0.50);
      };
    };
    GameInstance.GetTelemetrySystem(targetPuppet.GetGame()).LogDamageByVehicle(hitEvent);
  }

  private final func DealDamages(hitEvent: ref<gameHitEvent>) -> Void {
    let resourcesLost: array<SDamageDealt>;
    let forReal: Bool = !GameInstance.GetRuntimeInfo(GetGameInstance()).IsClient();
    StatPoolsManager.ApplyDamage(hitEvent, forReal, resourcesLost);
    this.SendDamageEvents(hitEvent, resourcesLost);
  }

  private final func SendDamageEvents(hitEvent: ref<gameHitEvent>, resourcesLost: array<SDamageDealt>) -> Void {
    let damageDealtEvent: ref<gameTargetDamageEvent> = new gameTargetDamageEvent();
    let damageReceivedEvent: ref<gameDamageReceivedEvent> = new gameDamageReceivedEvent();
    let totalDamage: Float = 0.00;
    let i: Int32 = 0;
    while i < ArraySize(resourcesLost) {
      totalDamage += resourcesLost[i].value;
      i += 1;
    };
    damageDealtEvent.target = hitEvent.target;
    damageDealtEvent.attackData = hitEvent.attackData;
    damageDealtEvent.hitPosition = hitEvent.hitPosition;
    damageDealtEvent.hitDirection = hitEvent.hitDirection;
    damageDealtEvent.hitRepresentationResult = hitEvent.hitRepresentationResult;
    damageDealtEvent.damage = totalDamage;
    damageReceivedEvent.totalDamageReceived = totalDamage;
    damageReceivedEvent.hitEvent = hitEvent;
    hitEvent.attackData.GetInstigator().QueueEvent(damageDealtEvent);
    if totalDamage > 0.00 {
      hitEvent.target.QueueEvent(damageReceivedEvent);
    };
  }

  private final func PostProcess(hitEvent: ref<gameHitEvent>) -> Void {
    this.ProcessStatusEffects(hitEvent);
    this.ProcessReturnedDamage(hitEvent);
    DamageManager.PostProcess(hitEvent);
  }

  private final func ProcessStatusEffects(hitEvent: ref<gameHitEvent>) -> Void {
    let effectDamages: array<wref<StatusEffectAttackData_Record>>;
    let i: Int32;
    let instantApply: Bool;
    let instantEffects: array<SHitStatusEffect>;
    let statusEffectID: TweakDBID;
    let attackData: ref<AttackData> = hitEvent.attackData;
    let target: ref<GameObject> = hitEvent.target;
    let targetId: EntityID = target.GetEntityID();
    let statusEffectSystem: ref<StatusEffectSystem> = GameInstance.GetStatusEffectSystem(GetGameInstance());
    let instigator: ref<GameObject> = hitEvent.attackData.GetInstigator();
    if attackData.HasFlag(hitFlag.WasBlocked) || attackData.HasFlag(hitFlag.WasDeflected) || attackData.HasFlag(hitFlag.FriendlyFireIgnored) {
      return;
    };
    if GameObject.IsVehicle(hitEvent.target) {
      return;
    };
    if !target.IsPlayer() && attackData.GetInstigator().IsPlayer() && Equals(GameObject.GetAttitudeTowards(target, attackData.GetInstigator()), EAIAttitude.AIA_Friendly) {
      return;
    };
    instantEffects = hitEvent.attackData.GetStatusEffects();
    i = 0;
    while i < ArraySize(instantEffects) {
      statusEffectID = instantEffects[i].id;
      if !this.IsImmune(target, statusEffectID) {
        statusEffectSystem.ApplyStatusEffect(targetId, statusEffectID, GameObject.GetTDBID(instigator), instigator.GetEntityID(), Cast(instantEffects[i].stacks), hitEvent.hitDirection);
      };
      i += 1;
    };
    attackData.GetAttackDefinition().GetRecord().StatusEffects(effectDamages);
    i = 0;
    while i < ArraySize(effectDamages) {
      statusEffectID = effectDamages[i].StatusEffect().GetID();
      if !this.IsImmune(target, statusEffectID) {
        instantApply = effectDamages[i].ApplyImmediately();
        if instantApply {
          statusEffectSystem.ApplyStatusEffect(targetId, statusEffectID, GameObject.GetTDBID(instigator), instigator.GetEntityID(), 1u, hitEvent.hitDirection);
        } else {
          StatPoolsManager.ApplyStatusEffectDamage(hitEvent, effectDamages[i].ResistPool(), statusEffectID);
        };
      };
      i += 1;
    };
    this.ProcessStatusEffectApplicationStats(hitEvent);
  }

  private final func ProcessStatusEffectApplicationStats(hitEvent: ref<gameHitEvent>) -> Void {
    let bleedingID: TweakDBID;
    let burningID: TweakDBID;
    let electrocutedID: TweakDBID;
    let poisonedID: TweakDBID;
    let attackType: gamedataAttackType = hitEvent.attackData.GetAttackType();
    if hitEvent.target.IsPuppet() && (AttackData.IsMelee(attackType) || AttackData.IsBullet(attackType)) {
      if hitEvent.target.IsPlayer() {
        bleedingID = t"BaseStatusEffect.PlayerBleeding";
        burningID = t"BaseStatusEffect.PlayerBurning";
        poisonedID = t"BaseStatusEffect.PlayerPoisoned";
        electrocutedID = t"BaseStatusEffect.PlayerElectrocuted";
      } else {
        if Equals(TweakDBInterface.GetWeaponItemRecord(ItemID.GetTDBID(hitEvent.attackData.GetWeapon().GetItemID())).Evolution().Type(), gamedataWeaponEvolution.Blade) {
          bleedingID = t"BaseStatusEffect.KenjutsuBleeding";
        } else {
          bleedingID = t"BaseStatusEffect.Bleeding";
        };
        burningID = t"BaseStatusEffect.Burning";
        poisonedID = t"BaseStatusEffect.Poisoned";
        electrocutedID = t"BaseStatusEffect.Electrocuted";
      };
      this.ApplyStatusEffectByApplicationRate(hitEvent, gamedataStatType.BleedingApplicationRate, bleedingID);
      this.ApplyStatusEffectByApplicationRate(hitEvent, gamedataStatType.BurningApplicationRate, burningID);
      this.ApplyStatusEffectByApplicationRate(hitEvent, gamedataStatType.PoisonedApplicationRate, poisonedID);
      this.ApplyStatusEffectByApplicationRate(hitEvent, gamedataStatType.ElectrocutedApplicationRate, electrocutedID);
    };
  }

  private final func ApplyStatusEffectByApplicationRate(hitEvent: ref<gameHitEvent>, statType: gamedataStatType, effect: TweakDBID) -> Void {
    let rand: Float;
    let ss: ref<StatsSystem> = GameInstance.GetStatsSystem(hitEvent.target.GetGame());
    let ses: ref<StatusEffectSystem> = GameInstance.GetStatusEffectSystem(hitEvent.target.GetGame());
    let weapon: wref<WeaponObject> = hitEvent.attackData.GetWeapon();
    let value: Float = ss.GetStatValue(Cast(weapon.GetEntityID()), statType) / 100.00;
    if !FloatIsEqual(value, 0.00) {
      rand = RandRangeF(0.00, 1.00);
      if rand <= value {
        ses.ApplyStatusEffect(hitEvent.target.GetEntityID(), effect, hitEvent.attackData.GetInstigator().GetEntityID());
      };
    };
  }

  private final func IsImmune(target: ref<GameObject>, statusEffectID: TweakDBID) -> Bool {
    let i: Int32;
    let immunityStats: array<wref<Stat_Record>>;
    let statsSystem: ref<StatsSystem>;
    let tags: array<CName>;
    let statusEffect: wref<StatusEffect_Record> = TweakDBInterface.GetStatusEffectRecord(statusEffectID);
    if !IsDefined(statusEffect) {
      return true;
    };
    tags = statusEffect.GameplayTags();
    if target.IsPlayer() {
      if ArrayContains(tags, n"DoNotApplyOnPlayer") {
        return true;
      };
      if Equals(statusEffect.StatusEffectType().Type(), gamedataStatusEffectType.Defeated) {
        return true;
      };
      if Equals(statusEffect.StatusEffectType().Type(), gamedataStatusEffectType.UncontrolledMovement) {
        return true;
      };
    } else {
      if target.IsPuppet() && Equals(statusEffect.StatusEffectType().Type(), gamedataStatusEffectType.UncontrolledMovement) {
        if !ScriptedPuppet.CanRagdoll(target) {
          return true;
        };
      };
    };
    if GameInstance.GetGodModeSystem(target.GetGame()).HasGodMode(target.GetEntityID(), gameGodModeType.Invulnerable) {
      if ArrayContains(tags, n"Debuff") {
        return true;
      };
    };
    statusEffect.ImmunityStats(immunityStats);
    statsSystem = GameInstance.GetStatsSystem(target.GetGame());
    i = 0;
    while i < ArraySize(immunityStats) {
      if statsSystem.GetStatValue(Cast(target.GetEntityID()), immunityStats[i].StatType()) > 0.00 {
        return true;
      };
      i += 1;
    };
    return false;
  }

  private final func ProcessReturnedDamage(hitEvent: ref<gameHitEvent>) -> Void {
    if hitEvent.attackData.HasFlag(hitFlag.CannotReturnDamage) {
      return;
    };
  }

  private final func CalculateGlobalModifiers(hitEvent: ref<gameHitEvent>, cache: ref<CacheData>) -> Void {
    let attackData: ref<AttackData> = hitEvent.attackData;
    let targetID: StatsObjectID = Cast(hitEvent.target.GetEntityID());
    let factVal: Int32 = GetFact(GetGameInstance(), n"cheat_weak");
    if factVal > 0 {
      attackData.ClearDamage();
      hitEvent.attackComputed.AddAttackValue(0.01, gamedataDamageType.Physical);
      attackData.AddFlag(hitFlag.CannotModifyDamage, n"cheat_weak");
      if Cast(cache.logFlags & damageSystemLogFlags.GENERAL) {
        LogDamage("DamageSystem.CalculateGlobalModifiers(): Weak cheat modified damage to 0.01");
      };
    };
    if attackData.GetInstigator().IsPlayer() {
      factVal = GetFact(GetGameInstance(), n"cheat_op");
      if factVal > 0 {
        hitEvent.attackComputed.SetAttackValue(GameInstance.GetStatPoolsSystem(GetGameInstance()).GetStatPoolMaxPointValue(targetID, gamedataStatPoolType.Health) * 0.60, gamedataDamageType.Physical);
        attackData.ClearDamage();
        attackData.AddFlag(hitFlag.CannotModifyDamage, n"cheat_op");
        if Cast(cache.logFlags & damageSystemLogFlags.GENERAL) {
          LogDamage("DamageSystem.CalculateGlobalModifiers(): OP cheat modified damage to 60% of " + hitEvent.target.GetDisplayName() + "\'s max health");
        };
      };
    };
    DamageManager.CalculateGlobalModifiers(hitEvent);
  }

  private final func CalculateTargetModifiers(hitEvent: ref<gameHitEvent>) -> Void {
    DamageManager.CalculateTargetModifiers(hitEvent);
    this.ProcessArmor(hitEvent);
    this.ProcessResistances(hitEvent);
  }

  private final func CalculateSourceModifiers(hitEvent: ref<gameHitEvent>) -> Void {
    DamageManager.CalculateSourceModifiers(hitEvent);
    this.ProcessChargeAttack(hitEvent);
    this.ProcessCriticalHit(hitEvent);
    this.ProcessStealthAttack(hitEvent);
    this.ProcessRicochetBonus(hitEvent);
  }

  private final func ProcessChargeAttack(hitEvent: ref<gameHitEvent>) -> Void {
    let attacksPerSecond: Float;
    let bonusChargeMult: Float;
    let burstCycleModifier: Float;
    let chargeAdjustedCycleTime: Float;
    let chargeBurstCycleTime: Float;
    let chargeBurstShots: Float;
    let chargeDamageMult: Float;
    let chargeNormalized: Float;
    let chargeTime: Float;
    let cycleTime: Float;
    let damagePerChargeAttack: Float;
    let magCapacity: Float;
    let projectilesPerShot: Float;
    let statsOwner: EntityID;
    let attackData: ref<AttackData> = hitEvent.attackData;
    let statsSystem: ref<StatsSystem> = GameInstance.GetStatsSystem(hitEvent.target.GetGame());
    let weaponObject: ref<WeaponObject> = attackData.GetWeapon();
    if !IsDefined(weaponObject) {
      return;
    };
    chargeNormalized = attackData.GetWeaponCharge();
    if attackData.GetInstigator().IsPlayer() {
      statsOwner = weaponObject.GetEntityID();
      if chargeNormalized > 0.00 {
        magCapacity = statsSystem.GetStatValue(Cast(statsOwner), gamedataStatType.MagazineCapacity);
        chargeTime = statsSystem.GetStatValue(Cast(statsOwner), gamedataStatType.BaseChargeTime);
        cycleTime = statsSystem.GetStatValue(Cast(statsOwner), gamedataStatType.CycleTime);
        projectilesPerShot = statsSystem.GetStatValue(Cast(statsOwner), gamedataStatType.ProjectilesPerShot);
        chargeBurstShots = statsSystem.GetStatValue(Cast(statsOwner), gamedataStatType.NumShotsInBurstMaxCharge);
        chargeBurstCycleTime = statsSystem.GetStatValue(Cast(statsOwner), gamedataStatType.CycleTime_BurstMaxCharge);
        if chargeBurstCycleTime > 0.00 && chargeBurstShots > 1.00 {
          burstCycleModifier = chargeBurstCycleTime * (chargeBurstShots - 1.00);
          chargeAdjustedCycleTime = (cycleTime + chargeTime * chargeNormalized + burstCycleModifier) / chargeBurstShots;
        } else {
          chargeAdjustedCycleTime = cycleTime + chargeTime * chargeNormalized;
        };
        attacksPerSecond = (magCapacity * projectilesPerShot) / (magCapacity * chargeAdjustedCycleTime + statsSystem.GetStatValue(Cast(statsOwner), gamedataStatType.ReloadTime));
        damagePerChargeAttack = statsSystem.GetStatValue(Cast(statsOwner), gamedataStatType.EffectiveDPS) * 1.00 / attacksPerSecond;
        chargeDamageMult = damagePerChargeAttack / statsSystem.GetStatValue(Cast(statsOwner), gamedataStatType.EffectiveDamagePerHit);
        if chargeNormalized >= 1.00 {
          bonusChargeMult = statsSystem.GetStatValue(Cast(statsOwner), gamedataStatType.ChargeFullMultiplier);
        } else {
          bonusChargeMult = statsSystem.GetStatValue(Cast(statsOwner), gamedataStatType.ChargeMultiplier);
        };
        if bonusChargeMult >= 1.00 {
          chargeDamageMult *= bonusChargeMult;
        };
        chargeDamageMult -= 1.00;
        chargeDamageMult *= TweakDBInterface.GetFloat(t"Constants.DamageSystem.chargeMultiplierReduction", 1.00);
        chargeDamageMult += 1.00;
        hitEvent.attackComputed.MultAttackValue(chargeDamageMult);
      };
    };
  }

  private final func ProcessRicochetBonus(hitEvent: ref<gameHitEvent>) -> Void {
    let statVal: Float;
    if hitEvent.attackData.GetInstigator().IsPlayer() {
      if hitEvent.attackData.GetNumRicochetBounces() > 0 {
        statVal = GameInstance.GetStatsSystem(hitEvent.target.GetGame()).GetStatValue(Cast(ScriptedPuppet.GetActiveWeapon(hitEvent.attackData.GetInstigator()).GetEntityID()), gamedataStatType.BonusRicochetDamage);
        if !FloatIsEqual(statVal, 0.00) {
          hitEvent.attackComputed.MultAttackValue(1.00 + statVal / 100.00);
        };
      };
    };
  }

  private final func ProcessStealthAttack(hitEvent: ref<gameHitEvent>) -> Void {
    let canStealthHit: Bool;
    let powerDifferential: EPowerDifferential;
    let stealthHitMult: Float;
    let player: wref<PlayerPuppet> = hitEvent.attackData.GetInstigator() as PlayerPuppet;
    if IsDefined(player) && IsDefined(hitEvent.target as ScriptedPuppet) {
      powerDifferential = RPGManager.CalculatePowerDifferential(hitEvent.target);
      if IsDefined(hitEvent.attackData.GetWeapon()) {
        canStealthHit = GameInstance.GetStatsSystem(GetGameInstance()).GetStatValue(Cast(hitEvent.attackData.GetWeapon().GetEntityID()), gamedataStatType.CanSilentKill) > 0.00;
        if canStealthHit && NotEquals(powerDifferential, EPowerDifferential.IMPOSSIBLE) {
          if !AttackData.IsPlayerInCombat(hitEvent.attackData) {
            stealthHitMult = GameInstance.GetStatsSystem(GetGameInstance()).GetStatValue(Cast(hitEvent.attackData.GetInstigator().GetEntityID()), gamedataStatType.StealthHitDamageMultiplier);
            if stealthHitMult > 1.00 {
              hitEvent.attackComputed.MultAttackValue(stealthHitMult);
            };
          };
        };
      };
    };
  }

  private final func CalculateSourceVsTargetModifiers(hitEvent: ref<gameHitEvent>) -> Void {
    this.ProcessEffectiveRange(hitEvent);
    this.ProcessBlockAndDeflect(hitEvent);
    if Cast(GetFact(GetGameInstance(), n"story_mode")) {
      this.ScalePlayerDamage(hitEvent);
    } else {
      this.ProcessLevelDifference(hitEvent);
    };
  }

  private final func CacheLocalVars(hitEvent: ref<gameHitEvent>, cache: ref<CacheData>) -> Void {
    let target: ref<GameObject> = hitEvent.target;
    cache.logFlags = GetDamageSystemLogFlags();
    if IsDefined(target) {
      cache.TEMP_ImmortalityCached = GetImmortality(target, cache.targetImmortalityMode);
    };
  }

  private final func ModifyHitFlagsForPlayer(hitEvent: ref<gameHitEvent>, cache: ref<CacheData>) -> Void {
    let attackData: ref<AttackData> = hitEvent.attackData;
    if !attackData.GetInstigator().IsPlayer() {
      return;
    };
    attackData.RemoveFlag(hitFlag.FriendlyFire, n"PreAttack");
  }

  private final func CheckForQuickExit(hitEvent: ref<gameHitEvent>, cache: ref<CacheData>) -> Bool {
    let mountingInfo: MountingInfo;
    let targetAttitudeOwner: wref<GameObject>;
    let vehicle: wref<VehicleObject>;
    let attackData: ref<AttackData> = hitEvent.attackData;
    if !IsDefined(attackData) {
      if Cast(cache.logFlags & damageSystemLogFlags.ASSERT) {
        LogDamage("DamageSystem.CheckForQuickExit(): no data object passed, aborting!");
      };
      return true;
    };
    if !IsDefined(hitEvent.target) {
      if Cast(cache.logFlags & damageSystemLogFlags.ASSERT) {
        LogDamage("DamageSystem.CheckForQuickExit(): no target passed, aborting!");
      };
      return true;
    };
    if !IsDefined(attackData.GetSource()) {
      if Cast(cache.logFlags & damageSystemLogFlags.ASSERT) {
        LogDamage("DamageSystem.CheckForQuickExit(): there is no root source set, aborting!");
      };
      return true;
    };
    if !GameInstance.IsValid(GetGameInstance()) {
      if Cast(cache.logFlags & damageSystemLogFlags.ASSERT) {
        LogDamage("DamageSystem.CheckForQuickExit(): game instance is not valid, aborting!");
      };
      return true;
    };
    if IsDefined(hitEvent.target as VehicleObject) && VehicleComponent.GetVehicle(GetGameInstance(), attackData.GetSource().GetEntityID(), vehicle) {
      if vehicle == hitEvent.target {
        if Cast(cache.logFlags & damageSystemLogFlags.ASSERT) {
          LogDamage("DamageSystem.CheckForQuickExit(): instigator is trying to damage vehicle it\'s attached to. Aborting!");
        };
        return true;
      };
    };
    if IsDefined(attackData.GetInstigator() as VehicleObject) && VehicleComponent.GetVehicle(GetGameInstance(), hitEvent.target, vehicle) {
      if vehicle == attackData.GetInstigator() {
        if Cast(cache.logFlags & damageSystemLogFlags.ASSERT) {
          LogDamage("DamageSystem.CheckForQuickExit(): instigator is trying to damage vehicle it\'s attached to. Aborting!");
        };
        return true;
      };
    };
    if hitEvent.target == attackData.GetInstigator() {
      if !attackData.HasFlag(hitFlag.CanDamageSelf) {
        attackData.AddFlag(hitFlag.DealNoDamage, n"SelfDamageIgnored");
        if Cast(cache.logFlags & damageSystemLogFlags.ASSERT) {
          LogDamage("DamageSystem.CheckForQuickExit(): trying to damage self, but CanDamageSelf is not set. Aborting!");
        };
        return true;
      };
    } else {
      if !attackData.HasFlag(hitFlag.FriendlyFire) {
        mountingInfo = GameInstance.GetMountingFacility(hitEvent.target.GetGame()).GetMountingInfoSingleWithObjects(hitEvent.target);
        if EntityID.IsDefined(mountingInfo.parentId) {
          targetAttitudeOwner = GameInstance.FindEntityByID(hitEvent.target.GetGame(), mountingInfo.parentId) as GameObject;
        };
        if (targetAttitudeOwner as ScriptedPuppet) == null {
          targetAttitudeOwner = hitEvent.target;
        };
        if Equals(GameObject.GetAttitudeBetween(targetAttitudeOwner, attackData.GetInstigator()), EAIAttitude.AIA_Friendly) && !StatusEffectSystem.ObjectHasStatusEffect(attackData.GetInstigator(), t"BaseStatusEffect.DoNotBlockShootingOnFriendlyFire") {
          attackData.AddFlag(hitFlag.DealNoDamage, n"FriendlyFireIgnored");
          attackData.AddFlag(hitFlag.DontShowDamageFloater, n"FriendlyFireIgnored");
          attackData.AddFlag(hitFlag.FriendlyFireIgnored, n"FriendlyFireIgnored");
        };
      };
    };
    if AttackData.IsDoT(hitEvent.attackData.GetAttackType()) && StatusEffectSystem.ObjectHasStatusEffectWithTag(hitEvent.target, n"Defeated") {
      return true;
    };
    return false;
  }

  private final func IsTargetImmortal(cache: ref<CacheData>) -> Bool {
    if !cache.TEMP_ImmortalityCached {
      return false;
    };
    return Equals(cache.targetImmortalityMode, gameGodModeType.Immortal);
  }

  private final func IsTargetInvulnerable(cache: ref<CacheData>) -> Bool {
    if !cache.TEMP_ImmortalityCached {
      return false;
    };
    return Equals(cache.targetImmortalityMode, gameGodModeType.Invulnerable);
  }

  public final func ProcessEffectiveRange(hitEvent: ref<gameHitEvent>) -> Void {
    let attackSource: ref<ItemObject>;
    let attackWeapon: ref<WeaponObject>;
    let damageMod: Float;
    let effectiveRange: Float;
    let grenadeRecord: ref<Grenade_Record>;
    let percentOfRange: Float;
    let attackData: ref<AttackData> = hitEvent.attackData;
    let attackDistance: Float = Vector4.Length(attackData.GetAttackPosition() - hitEvent.hitPosition);
    if AttackData.IsExplosion(attackData.GetAttackType()) {
      attackSource = attackData.GetSource() as ItemObject;
      if IsDefined(attackSource) {
        grenadeRecord = TweakDBInterface.GetGrenadeRecord(ItemID.GetTDBID(attackSource.GetItemID()));
      };
      if IsDefined(grenadeRecord) {
        effectiveRange = grenadeRecord.AttackRadius();
      } else {
        effectiveRange = attackData.GetAttackDefinition().GetRecord().Range();
      };
      percentOfRange = ClampF(attackDistance / effectiveRange, 0.00, 1.00);
      damageMod = GameInstance.GetStatsDataSystem(GetGameInstance()).GetValueFromCurve(n"explosions", percentOfRange, n"distance_to_damage_reduction");
      hitEvent.attackComputed.MultAttackValue(damageMod);
      return;
    };
    attackWeapon = attackData.GetWeapon();
    if !IsDefined(attackWeapon) {
      LogError("[DamageSystem] Attack with no weapon!");
      return;
    };
    damageMod = DamageSystem.GetEffectiveRangeModifierForWeapon(attackData, hitEvent.hitPosition, GameInstance.GetStatsSystem(GetGameInstance()));
    if damageMod != 1.00 {
      hitEvent.attackComputed.MultAttackValue(damageMod);
    };
  }

  public final static func GetEffectiveRangeModifierForWeapon(attackData: ref<AttackData>, hitPosition: Vector4, statsSystem: ref<StatsSystem>) -> Float {
    let effectiveRange: Float;
    let itemRecord: ref<WeaponItem_Record>;
    let result: Float = 1.00;
    let attackDistance: Float = Vector4.Length(attackData.GetAttackPosition() - hitPosition);
    if attackData.GetInstigator().IsPlayer() {
      effectiveRange = statsSystem.GetStatValue(Cast(attackData.GetWeapon().GetEntityID()), gamedataStatType.EffectiveRange);
      itemRecord = TweakDBInterface.GetWeaponItemRecord(ItemID.GetTDBID(attackData.GetWeapon().GetItemID()));
      if attackDistance < effectiveRange {
        if IsNameValid(itemRecord.EffectiveRangeCurve()) {
          result = DamageSystem.GetDamageModFromCurve(itemRecord.EffectiveRangeCurve(), attackDistance);
        };
      } else {
        if IsNameValid(itemRecord.EffectiveRangeFalloffCurve()) {
          if IsDefined(attackData.GetWeapon()) && statsSystem.GetStatValue(Cast(attackData.GetWeapon().GetEntityID()), gamedataStatType.DamageFalloffDisabled) <= 0.00 {
            attackDistance = attackDistance - effectiveRange;
            result = DamageSystem.GetDamageModFromCurve(itemRecord.EffectiveRangeFalloffCurve(), attackDistance);
          };
        };
      };
    };
    return result;
  }

  public final func ProcessArmor(hitEvent: ref<gameHitEvent>) -> Void {
    let armorPoints: Float;
    let attackValues: array<Float>;
    let attacksPerSec: Float;
    let i: Int32;
    let instigator: wref<GameObject>;
    let reducedValue: Float;
    let statsSystem: ref<StatsSystem>;
    let weapon: wref<WeaponObject> = hitEvent.attackData.GetWeapon();
    if IsDefined(weapon) && WeaponObject.CanIgnoreArmor(weapon) {
      return;
    };
    if instigator.IsPlayer() || !IsDefined(weapon) {
      return;
    };
    statsSystem = GameInstance.GetStatsSystem(hitEvent.target.GetGame());
    instigator = hitEvent.attackData.GetInstigator();
    if instigator.IsPlayer() && IsDefined(weapon) {
      attacksPerSec = statsSystem.GetStatValue(Cast(weapon.GetEntityID()), gamedataStatType.AttacksPerSecond);
    } else {
      if IsDefined(instigator) {
        attacksPerSec = statsSystem.GetStatValue(Cast(instigator.GetEntityID()), gamedataStatType.TBHsBaseSourceMultiplierCoefficient);
      };
    };
    armorPoints = statsSystem.GetStatValue(Cast(hitEvent.target.GetEntityID()), gamedataStatType.Armor);
    attackValues = hitEvent.attackComputed.GetAttackValues();
    i = 0;
    while i < ArraySize(attackValues) {
      if attackValues[i] > 0.00 {
        reducedValue = attackValues[i] - TweakDBInterface.GetFloat(t"Constants.DamageSystem.dpsReductionPerArmorPoint", 1.00) * armorPoints * attacksPerSec;
        if reducedValue < 1.00 {
          reducedValue = 1.00;
        };
        attackValues[i] = reducedValue;
      };
      i += 1;
    };
    hitEvent.attackComputed.SetAttackValues(attackValues);
  }

  public final func ProcessResistances(hitEvent: ref<gameHitEvent>) -> Void {
    let attackValues: array<Float>;
    let damageType: gamedataDamageType;
    let i: Int32;
    let resistType: gamedataStatType;
    let resistValue: Float;
    let statsSystem: ref<StatsSystem>;
    let target: ref<GameObject> = hitEvent.target;
    if hitEvent.attackData.HasFlag(hitFlag.CannotModifyDamage) {
      return;
    };
    statsSystem = GameInstance.GetStatsSystem(hitEvent.attackData.GetSource().GetGame());
    attackValues = hitEvent.attackComputed.GetAttackValues();
    i = 0;
    while i < ArraySize(attackValues) {
      damageType = IntEnum(i);
      if Equals(damageType, gamedataDamageType.Physical) {
      } else {
        if attackValues[i] <= 0.00 {
        } else {
          resistType = RPGManager.GetResistanceTypeFromDamageType(damageType);
          resistValue = statsSystem.GetStatValue(Cast(target.GetEntityID()), resistType);
          resistValue /= 100.00;
          hitEvent.attackComputed.MultAttackValue(1.00 - resistValue, damageType);
        };
      };
      i += 1;
    };
  }

  public final func ProcessCriticalHit(hitEvent: ref<gameHitEvent>) -> Void {
    let accumulatedCritChance: Float;
    let accumulatedCritDamage: Float;
    let hitType: gameuiHitType;
    let playerCritChance: Float;
    let playerCritDamage: Float;
    let randomDraw: Float;
    let weaponCritChance: Float;
    let weaponCritDamage: Float;
    let attackType: gamedataAttackType = hitEvent.attackData.GetAttackType();
    let attackData: ref<AttackData> = hitEvent.attackData;
    let allowWeaponCrit: Bool = false;
    let statsSystem: ref<StatsSystem> = GameInstance.GetStatsSystem(GetGameInstance());
    if attackData.HasFlag(hitFlag.CannotModifyDamage) || attackData.HasFlag(hitFlag.DeterministicDamage) || attackData.HasFlag(hitFlag.ForceNoCrit) || hitEvent.target.IsPlayer() || !attackData.GetInstigator().IsPlayer() {
      return;
    };
    if hitEvent.projectionPipeline {
      return;
    };
    hitType = gameuiHitType.Hit;
    if Equals(attackType, gamedataAttackType.Hack) || attackData.HasFlag(hitFlag.QuickHack) {
      if statsSystem.GetStatValue(Cast(attackData.GetInstigator().GetEntityID()), gamedataStatType.CanQuickHackCriticallyHit) <= 0.00 {
        return;
      };
    } else {
      if AttackData.IsEffect(attackType) && !AttackData.CanEffectCriticallyHit(attackData, statsSystem) {
        return;
      };
      if IsDefined(hitEvent.attackData.GetSource() as WeaponGrenade) && !AttackData.CanGrenadeCriticallyHit(attackData, statsSystem) {
        return;
      };
    };
    if IsDefined(attackData.GetInstigator()) {
      playerCritChance = statsSystem.GetStatValue(Cast(attackData.GetInstigator().GetEntityID()), gamedataStatType.CritChance) / 100.00;
    };
    if IsDefined(attackData.GetWeapon()) {
      allowWeaponCrit = !AttackData.IsDoT(attackType) && (attackData.GetWeapon().IsRanged() || attackData.GetWeapon().IsMelee());
      if allowWeaponCrit {
        weaponCritChance = statsSystem.GetStatValue(Cast(attackData.GetWeapon().GetEntityID()), gamedataStatType.CritChance) / 100.00;
      };
    };
    accumulatedCritChance = playerCritChance + weaponCritChance + hitEvent.attackData.GetAdditionalCritChance();
    randomDraw = RandF();
    if randomDraw <= accumulatedCritChance || attackData.HasFlag(hitFlag.CriticalHit) {
      if IsDefined(attackData.GetInstigator()) {
        playerCritDamage = statsSystem.GetStatValue(Cast(attackData.GetInstigator().GetEntityID()), gamedataStatType.CritDamage) / 100.00;
      };
      if allowWeaponCrit {
        weaponCritDamage = statsSystem.GetStatValue(Cast(attackData.GetWeapon().GetEntityID()), gamedataStatType.CritDamage) / 100.00;
      };
      accumulatedCritDamage = playerCritDamage + weaponCritDamage;
      if accumulatedCritDamage > 0.00 {
        attackData.AddFlag(hitFlag.CriticalHit, n"critical_hit");
        hitEvent.attackComputed.MultAttackValue(1.00 + accumulatedCritDamage);
        hitType = gameuiHitType.CriticalHit;
      };
    };
    hitEvent.attackData.SetHitType(hitType);
  }

  private final func ProcessBlockAndDeflect(hitEvent: ref<gameHitEvent>) -> Void {
    let attackingItem: wref<ItemObject>;
    let blockFactor: Float;
    let blockingItem: wref<ItemObject>;
    let currentStamina: Float;
    let meleeAttackRecord: ref<Attack_Melee_Record>;
    let meleeCostToBlock: Float;
    let newStamina: Float;
    let playerTarget: ref<PlayerPuppet>;
    let staminaReduction: Float;
    let statPoolsSystem: ref<StatPoolsSystem>;
    let statsSystem: ref<StatsSystem>;
    let targetID: EntityID;
    let blockBreakTDBID: TweakDBID = t"BaseStatusEffect.BlockBroken";
    let computedDamageFactor: Float = 1.00;
    if AttackData.IsMelee(hitEvent.attackData.GetAttackType()) {
      statsSystem = GameInstance.GetStatsSystem(hitEvent.target.GetGame());
      blockingItem = GameInstance.GetTransactionSystem(hitEvent.target.GetGame()).GetItemInSlot(hitEvent.target, t"AttachmentSlots.WeaponRight");
      attackingItem = hitEvent.attackData.GetWeapon();
      if IsDefined(blockingItem) && IsDefined(attackingItem) {
        if hitEvent.attackData.WasBlocked() || hitEvent.attackData.WasDeflected() {
          if !(Equals(RPGManager.GetItemRecord(blockingItem.GetItemID()).ItemType().Type(), gamedataItemType.Wea_Fists) && NotEquals(RPGManager.GetItemRecord(attackingItem.GetItemID()).ItemType().Type(), gamedataItemType.Wea_Fists)) {
            computedDamageFactor = 0.00;
          };
          if hitEvent.attackData.WasBlocked() {
            targetID = hitEvent.target.GetEntityID();
            statPoolsSystem = GameInstance.GetStatPoolsSystem(hitEvent.target.GetGame());
            currentStamina = statPoolsSystem.GetStatPoolValue(Cast(hitEvent.target.GetEntityID()), gamedataStatPoolType.Stamina, false);
            playerTarget = hitEvent.target as PlayerPuppet;
            blockFactor = statsSystem.GetStatValue(Cast(targetID), gamedataStatType.BlockFactor);
            if IsDefined(playerTarget) {
              if StatusEffectSystem.ObjectHasStatusEffect(hitEvent.target, PlayerStaminaHelpers.GetExhaustedStatusEffectID()) {
                StatusEffectHelper.ApplyStatusEffect(hitEvent.target, blockBreakTDBID);
                hitEvent.attackData.RemoveFlag(hitFlag.WasBlocked, n"BlockBreak");
                computedDamageFactor = TweakDBInterface.GetFloat(t"Constants.DamageSystem.blockBreakPlayerDamageFactor", 0.50);
              } else {
                meleeAttackRecord = hitEvent.attackData.GetAttackDefinition().GetRecord() as Attack_Melee_Record;
                meleeCostToBlock = statsSystem.GetStatValue(Cast(attackingItem.GetEntityID()), gamedataStatType.StaminaCostToBlock);
                if IsDefined(meleeAttackRecord) {
                  meleeCostToBlock = meleeCostToBlock * meleeAttackRecord.BlockCostFactor();
                };
                staminaReduction = meleeCostToBlock / blockFactor;
                newStamina = MaxF(currentStamina - staminaReduction, 0.00);
                if newStamina <= 0.00 {
                  StatusEffectHelper.ApplyStatusEffect(hitEvent.target, blockBreakTDBID);
                  hitEvent.attackData.RemoveFlag(hitFlag.WasBlocked, n"BlockBreak");
                  computedDamageFactor = TweakDBInterface.GetFloat(t"Constants.DamageSystem.blockBreakPlayerDamageFactor", 0.50);
                };
                PlayerStaminaHelpers.ModifyStamina(playerTarget, -staminaReduction);
                PlayerStaminaHelpers.OnPlayerBlock(playerTarget);
              };
              this.SetTutorialFact(n"gmpl_player_blocked_attack");
            } else {
              staminaReduction = statsSystem.GetStatValue(Cast(targetID), gamedataStatType.Stamina) / blockFactor;
              newStamina = MaxF(currentStamina - staminaReduction, 0.00);
              if newStamina <= 0.00 {
                StatusEffectHelper.ApplyStatusEffect(hitEvent.target, blockBreakTDBID);
                newStamina = 0.00;
              };
              statPoolsSystem.RequestSettingStatPoolValue(Cast(targetID), gamedataStatPoolType.Stamina, newStamina, hitEvent.attackData.GetInstigator(), false);
            };
          };
          if computedDamageFactor != 1.00 {
            hitEvent.attackComputed.MultAttackValue(computedDamageFactor);
          };
        };
      };
    };
  }

  private final func ProcessLevelDifference(const hitEvent: ref<gameHitEvent>) -> Void {
    let curveName: CName;
    let instigatorLevel: Float;
    let levelDiff: Float;
    let multiplier: Float;
    let statsSystem: ref<StatsSystem>;
    let targetLevel: Float;
    if hitEvent.target == (hitEvent.target as VehicleObject) {
      return;
    };
    if hitEvent.target.IsPlayer() || hitEvent.attackData.GetInstigator().IsPlayer() {
      statsSystem = GameInstance.GetStatsSystem(hitEvent.target.GetGame());
      instigatorLevel = statsSystem.GetStatValue(Cast(hitEvent.attackData.GetInstigator().GetEntityID()), gamedataStatType.PowerLevel);
      targetLevel = statsSystem.GetStatValue(Cast(hitEvent.target.GetEntityID()), gamedataStatType.PowerLevel);
      levelDiff = instigatorLevel - targetLevel;
      if hitEvent.target.IsPlayer() {
        curveName = n"pl_diff_to_npc_damage_multiplier";
      } else {
        if Equals(hitEvent.attackData.GetAttackType(), gamedataAttackType.Hack) || hitEvent.attackData.HasFlag(hitFlag.QuickHack) {
          curveName = n"pl_diff_to_hackdamage_multiplier";
        } else {
          curveName = n"pl_diff_to_damage_multiplier";
        };
      };
      multiplier = GameInstance.GetStatsDataSystem(hitEvent.target.GetGame()).GetValueFromCurve(n"puppet_dynamic_scaling", levelDiff, curveName);
      hitEvent.attackComputed.MultAttackValue(multiplier);
    };
  }

  private final func ScalePlayerDamage(const hitEvent: ref<gameHitEvent>) -> Void {
    let baseNPCHealth: Float;
    let multiplier: Float;
    let playerLevel: Float;
    let statsSystem: ref<StatsSystem>;
    let targetLevel: Float;
    let weaponLevel: Float;
    let targetPuppet: wref<NPCPuppet> = hitEvent.target as NPCPuppet;
    let targetHealth: Float = GameInstance.GetStatsSystem(hitEvent.target.GetGame()).GetStatValue(Cast(hitEvent.target.GetEntityID()), gamedataStatType.Health);
    if NotEquals(targetPuppet.GetPuppetRarity().Type(), gamedataNPCRarity.Boss) {
      statsSystem = GameInstance.GetStatsSystem(targetPuppet.GetGame());
      baseNPCHealth = GameInstance.GetStatsDataSystem(hitEvent.target.GetGame()).GetValueFromCurve(n"puppet_powerLevelToHealth", 1.00, n"puppet_powerLevelToHealth");
      baseNPCHealth *= RPGManager.GetRarityMultiplier(targetPuppet, n"power_level_to_health_mod");
      multiplier = targetHealth / baseNPCHealth;
      if hitEvent.attackData.GetInstigator().IsPlayer() {
        playerLevel = statsSystem.GetStatValue(Cast(hitEvent.attackData.GetInstigator().GetEntityID()), gamedataStatType.PowerLevel);
        targetLevel = statsSystem.GetStatValue(Cast(targetPuppet.GetEntityID()), gamedataStatType.PowerLevel);
        if playerLevel < targetLevel {
          weaponLevel = GameInstance.GetStatsSystem(hitEvent.target.GetGame()).GetStatValue(Cast(hitEvent.attackData.GetWeapon().GetEntityID()), gamedataStatType.PowerLevel);
          multiplier *= GameInstance.GetStatsDataSystem(hitEvent.target.GetGame()).GetValueFromCurve(n"puppet_dynamic_scaling", weaponLevel, n"story_mode_weapon_multiplier");
        };
      };
      hitEvent.attackComputed.MultAttackValue(multiplier);
    };
    if hitEvent.target.IsPlayer() && targetHealth > hitEvent.attackComputed.GetTotalAttackValue(gamedataStatPoolType.Health) && !hitEvent.attackData.GetInstigator().IsPrevention() && !hitEvent.attackData.HasFlag(hitFlag.IgnoreDifficulty) {
      hitEvent.attackComputed.MultAttackValue(0.00);
    };
  }

  private final func PlayFinisherGameEffect(const hitEvent: ref<gameHitEvent>, const hasFromFront: Bool, const hasFromBack: Bool) -> Bool {
    let bodyType: CName;
    let bodyTypeVarSetter: ref<AnimWrapperWeightSetter>;
    let finisherName: CName;
    let gameEffectInstance: ref<EffectInstance>;
    let instigator: ref<GameObject>;
    let targetPuppet: ref<gamePuppet>;
    let attackData: ref<AttackData> = hitEvent.attackData;
    if !this.GetFinisherNameBasedOnWeapon(hitEvent, hasFromFront, hasFromBack, finisherName) {
      return false;
    };
    instigator = attackData.GetInstigator();
    gameEffectInstance = GameInstance.GetGameEffectSystem(GetGameInstance()).CreateEffectStatic(n"playFinisher", finisherName, instigator);
    if !IsDefined(gameEffectInstance) {
      return false;
    };
    AnimationControllerComponent.PushEventToObjAndHeldItems(instigator, n"ForceReady");
    targetPuppet = hitEvent.target as gamePuppet;
    bodyType = targetPuppet.GetBodyType();
    bodyTypeVarSetter = new AnimWrapperWeightSetter();
    bodyTypeVarSetter.key = bodyType;
    bodyTypeVarSetter.value = 1.00;
    instigator.QueueEvent(bodyTypeVarSetter);
    EffectData.SetVector(gameEffectInstance.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.position, hitEvent.target.GetWorldPosition());
    EffectData.SetEntity(gameEffectInstance.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.entity, hitEvent.target);
    gameEffectInstance.Run();
    AnimationControllerComponent.PushEventToObjAndHeldItems(instigator, n"ForceReady");
    return true;
  }

  private final func GetFinisherNameBasedOnWeapon(const hitEvent: ref<gameHitEvent>, const hasFromFront: Bool, const hasFromBack: Bool, out finisherName: CName) -> Bool {
    let angle: Float;
    let finisher: String;
    let weaponRecord: ref<Item_Record>;
    let attackData: ref<AttackData> = hitEvent.attackData;
    finisherName = n"finisher_default";
    let weapon: ref<WeaponObject> = attackData.GetWeapon();
    if !IsDefined(weapon) {
      return false;
    };
    weaponRecord = TweakDBInterface.GetWeaponItemRecord(ItemID.GetTDBID(weapon.GetItemID()));
    if !IsDefined(weaponRecord) {
      return true;
    };
    finisherName = weaponRecord.ItemType().Name();
    if Equals(finisherName, n"Wea_OneHandedClub") || Equals(finisherName, n"Wea_TwoHandedClub") || Equals(finisherName, n"Wea_Fists") || Equals(finisherName, n"Wea_Hammer") {
      finisherName = n"Wea_Katana";
    };
    if IsNameValid(finisherName) {
      angle = Vector4.GetAngleBetween(attackData.GetInstigator().GetWorldForward(), hitEvent.target.GetWorldForward());
      if hasFromBack && AbsF(angle) < 90.00 {
        finisher = NameToString(finisherName);
        finisher += "_Back";
        finisherName = StringToName(finisher);
        return true;
      };
      if hasFromFront && AbsF(angle) >= 90.00 {
        return true;
      };
    };
    return false;
  }

  public final native func RegisterListener(damageListener: ref<ScriptedDamageSystemListener>, registereeID: EntityID, callbackType: gameDamageCallbackType, opt damagePipelineType: DMGPipelineType) -> Void;

  public final native func UnregisterListener(damageListener: ref<ScriptedDamageSystemListener>, registereeID: EntityID, callbackType: gameDamageCallbackType, opt damagePipelineType: DMGPipelineType) -> Void;

  public final native func RegisterSyncListener(damageListener: ref<ScriptedDamageSystemListener>, registereeID: EntityID, callbackType: gameDamageCallbackType, stage: gameDamagePipelineStage, opt damagePipelineType: DMGPipelineType) -> Void;

  public final native func UnregisterSyncListener(damageListener: ref<ScriptedDamageSystemListener>, registereeID: EntityID, callbackType: gameDamageCallbackType, stage: gameDamagePipelineStage, opt damagePipelineType: DMGPipelineType) -> Void;

  public final native func ProcessSyncStageCallbacks(stage: gameDamagePipelineStage, hitEvent: ref<gameHitEvent>, damagePipelineType: DMGPipelineType) -> Void;

  private final func SetTutorialFact(factName: CName) -> Void {
    let questSystem: ref<QuestsSystem> = GameInstance.GetQuestsSystem(GetGameInstance());
    questSystem.SetFact(factName, questSystem.GetFact(factName) + 1);
  }
}

public native class ScriptedDamageSystemListener extends IDamageSystemListener {

  protected func OnHitTriggered(hitEvent: ref<gameHitEvent>) -> Void;

  protected func OnHitReceived(hitEvent: ref<gameHitEvent>) -> Void;

  protected func OnPipelineProcessed(hitEvent: ref<gameHitEvent>) -> Void;
}
