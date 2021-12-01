
public class HitReactionBehaviorData extends IScriptable {

  public let m_hitReactionType: animHitReactionType;

  public let m_hitReactionActivationTimeStamp: Float;

  public let m_hitReactionDuration: Float;

  public final const func GetHitReactionDeactivationTimeStamp() -> Float {
    return this.m_hitReactionActivationTimeStamp + this.m_hitReactionDuration;
  }
}

public class HitReactionComponent extends AIMandatoryComponents {

  @default(HitReactionComponent, 0.2)
  protected let m_impactDamageDuration: Float;

  @default(HitReactionComponent, 0.4)
  protected let m_staggerDamageDuration: Float;

  @default(HitReactionComponent, 0.25)
  protected let m_impactDamageDurationMelee: Float;

  @default(HitReactionComponent, 1.5)
  protected let m_staggerDamageDurationMelee: Float;

  @default(HitReactionComponent, 2.5)
  protected let m_knockdownDamageDuration: Float;

  protected let m_defeatedMinDuration: Float;

  protected let m_previousHitTime: Float;

  protected let m_reactionType: animHitReactionType;

  protected let m_animHitReaction: ref<AnimFeature_HitReactionsData>;

  protected let m_lastAnimHitReaction: ref<AnimFeature_HitReactionsData>;

  protected let m_hitReactionAction: ref<ActionHitReactionScriptProxy>;

  protected let m_previousAnimHitReactionArray: array<ScriptHitData>;

  protected let m_lastHitReactionPlayed: EAILastHitReactionPlayed;

  protected let m_hitShapeData: HitShapeData;

  protected let m_animVariation: Int32;

  protected let m_specificHitTimeout: Float;

  protected let m_quickMeleeCooldown: Float;

  protected let m_dismembermentBodyPartDamageThreshold: array<Float>;

  protected let m_woundedBodyPartDamageThreshold: array<Float>;

  protected let m_defeatedBodyPartDamageThreshold: array<Float>;

  protected let m_impactDamageThreshold: Float;

  protected let m_staggerDamageThreshold: Float;

  protected let m_knockdownDamageThreshold: Float;

  protected let m_knockdownImpulseThreshold: Float;

  protected let m_immuneToKnockDown: Bool;

  @default(HitReactionComponent, 2.0f)
  protected let m_hitComboReset: Float;

  @default(HitReactionComponent, 0.3f)
  protected let m_physicalImpulseReset: Float;

  protected let m_cumulatedDamages: Float;

  protected let m_bodyPartWoundCumulatedDamages: array<Float>;

  protected let m_bodyPartDismemberCumulatedDamages: array<Float>;

  protected let m_overrideHitReactionImpulse: Float;

  protected let m_cumulatedPhysicalImpulse: Float;

  protected let m_comboResetTime: Float;

  protected let m_ragdollImpulse: Float;

  protected let m_hitIntensity: EAIHitIntensity;

  @default(HitReactionComponent, -1.f)
  protected let m_previousMeleeHitTimeStamp: Float;

  @default(HitReactionComponent, -1.f)
  protected let m_previousRangedHitTimeStamp: Float;

  @default(HitReactionComponent, -1.f)
  protected let m_previousBlockTimeStamp: Float;

  @default(HitReactionComponent, -1.f)
  protected let m_previousParryTimeStamp: Float;

  protected let m_previousDodgeTimeStamp: Float;

  protected let m_blockCount: Int32;

  protected let m_parryCount: Int32;

  protected let m_dodgeCount: Int32;

  public let m_hitCount: Uint32;

  protected let m_defeatedHasBeenPlayed: Bool;

  protected let m_deathHasBeenPlayed: Bool;

  protected let m_deathRegisteredTime: Float;

  protected let m_extendedDeathRegisteredTime: Float;

  protected let m_extendedDeathDelayRegisteredTime: Float;

  @default(HitReactionComponent, 10.f)
  protected let m_disableDismembermentAfterDeathDelay: Float;

  protected let m_extendedHitReactionRegisteredTime: Float;

  protected let m_extendedHitReactionDelayRegisteredTime: Float;

  protected let m_scatteredGuts: Bool;

  @default(HitReactionComponent, 0.25f)
  protected const let m_cumulativeDamageUpdateInterval: Float;

  @default(HitReactionComponent, false)
  protected let m_cumulativeDamageUpdateRequested: Bool;

  protected let m_currentStimId: Uint32;

  protected let m_attackData: ref<AttackData>;

  protected let m_hitPosition: Vector4;

  protected let m_hitDirection: Vector4;

  protected let m_lastHitReactionBehaviorData: ref<HitReactionBehaviorData>;

  protected let m_lastStimName: CName;

  protected let m_deathStimName: CName;

  protected let m_meleeHitCount: Int32;

  protected let m_strongMeleeHitCount: Int32;

  @default(HitReactionComponent, 2)
  protected let m_maxHitChainForMelee: Int32;

  @default(HitReactionComponent, 2)
  protected let m_maxHitChainForRanged: Int32;

  protected let m_isAlive: Bool;

  protected let m_frameDamageHealthFactor: Float;

  protected let m_hitCountData: array<Float; 100>;

  @default(HitReactionComponent, 100)
  protected let m_hitCountArrayEnd: Int32;

  protected let m_hitCountArrayCurrent: Int32;

  private let m_indicatorEnabledBlackboardId: ref<CallbackHandle>;

  private let m_hitIndicatorEnabled: Bool;

  private let m_hasBeenWounded: Bool;

  private let m_hitReactionData: ref<AnimFeature_HitReactionsData>;

  public final const func GetMeleeMaxHitChain() -> Int32 {
    return this.m_maxHitChainForMelee;
  }

  public final const func GetRangedMaxHitChain() -> Int32 {
    return this.m_maxHitChainForRanged;
  }

  public final const func GetDeathHasBeenPlayed() -> Bool {
    return this.m_deathHasBeenPlayed;
  }

  public final const func GetHitCountInCombo() -> Int32 {
    return this.m_meleeHitCount;
  }

  public final const func GetStrongHitCountInCombo() -> Int32 {
    return this.m_strongMeleeHitCount;
  }

  public final const func GetLastStimName() -> CName {
    return this.m_lastStimName;
  }

  public final const func GetDeathStimName() -> CName {
    return this.m_deathStimName;
  }

  public final const func GetHitReactionType() -> Int32 {
    return this.m_animHitReaction.hitType;
  }

  public final const func GetAttackTag() -> CName {
    let attackTag: CName;
    let attackRecord: ref<Attack_GameEffect_Record> = this.m_attackData.GetAttackDefinition().GetRecord() as Attack_GameEffect_Record;
    if IsDefined(attackRecord) {
      attackTag = attackRecord.AttackTag();
    };
    return attackTag;
  }

  public final const func GetAttackType() -> gamedataAttackType {
    return this.m_attackData.GetAttackType();
  }

  public final const func GetSubAttackSubType() -> gamedataAttackSubtype {
    let attackSubType: gamedataAttackSubtype;
    let attackRecord: ref<Attack_Melee_Record> = this.m_attackData.GetAttackDefinition().GetRecord() as Attack_Melee_Record;
    if IsDefined(attackRecord) {
      attackSubType = attackRecord.AttackSubtype().Type();
    };
    return attackSubType;
  }

  public final const func GetHitReactionData() -> ref<AnimFeature_HitReactionsData> {
    return this.m_animHitReaction;
  }

  public final const func GetLastHitReactionData() -> ref<AnimFeature_HitReactionsData> {
    return this.m_lastAnimHitReaction;
  }

  public final const func GetBlockCount() -> Int32 {
    if EngineTime.ToFloat(this.GetSimTime()) > this.m_previousBlockTimeStamp + this.GetBlockCountInterval() {
      return 0;
    };
    return this.m_blockCount;
  }

  public final const func GetParryCount() -> Int32 {
    if EngineTime.ToFloat(this.GetSimTime()) > this.m_previousParryTimeStamp + this.GetBlockCountInterval() {
      return 0;
    };
    return this.m_parryCount;
  }

  public final const func GetDodgeCount() -> Int32 {
    if EngineTime.ToFloat(this.GetSimTime()) > this.m_previousDodgeTimeStamp + this.GetDodgeCountInterval() {
      return 0;
    };
    return this.m_dodgeCount;
  }

  public final const func GetCumulatedDamage() -> Float {
    return this.m_cumulatedDamages;
  }

  public final const func GetLastHitReactionBehaviorData() -> ref<HitReactionBehaviorData> {
    return this.m_lastHitReactionBehaviorData;
  }

  public final const func GetHitReactionProxyAction() -> ref<ActionHitReactionScriptProxy> {
    return this.m_hitReactionAction;
  }

  public final const func GetLastStimID() -> Uint32 {
    return this.m_currentStimId;
  }

  public final const func GetHitSource() -> wref<GameObject> {
    return this.m_attackData.GetSource();
  }

  public final const func GetHitInstigator() -> wref<GameObject> {
    return this.m_attackData.GetInstigator();
  }

  public final const func GetHitPosition() -> Vector4 {
    return this.m_hitPosition;
  }

  public final const func GetHitDirection() -> Vector4 {
    return this.m_hitDirection;
  }

  public final func UpdateDeathHasBeenPlayed() -> Void {
    this.m_deathHasBeenPlayed = true;
  }

  public final func UpdateLastStimID() -> Uint32 {
    this.m_currentStimId += 1u;
    return this.m_currentStimId;
  }

  public final func ResetHitCount() -> Void {
    this.m_meleeHitCount = 0;
    this.m_strongMeleeHitCount = 0;
  }

  public final func SetLastStimName(laststimName: CName) -> Void {
    this.m_lastStimName = laststimName;
  }

  public final func SetDeathStimName(laststimName: CName) -> Void {
    this.m_deathStimName = laststimName;
  }

  public final func UpdateBlockCount() -> Void {
    this.m_blockCount += 1;
    if this.GetCurrentTime() > this.m_previousBlockTimeStamp + this.GetBlockCountInterval() {
      this.m_blockCount = 1;
    };
    this.m_previousBlockTimeStamp = this.GetCurrentTime();
  }

  public final func UpdateParryCount() -> Void {
    this.m_parryCount += 1;
    if this.GetCurrentTime() > this.m_previousParryTimeStamp + this.GetBlockCountInterval() {
      this.m_parryCount = 1;
    };
    this.m_previousParryTimeStamp = this.GetCurrentTime();
  }

  public final func UpdateDodgeCount() -> Void {
    this.m_dodgeCount += 1;
    if this.GetCurrentTime() > this.m_previousDodgeTimeStamp + this.GetDodgeCountInterval() {
      this.m_dodgeCount = 1;
    };
    this.m_previousDodgeTimeStamp = this.GetCurrentTime();
  }

  private final func GetOwnerPuppet() -> ref<ScriptedPuppet> {
    return this.GetOwner() as ScriptedPuppet;
  }

  private final func GetOwnerNPC() -> ref<NPCPuppet> {
    return this.GetOwner() as NPCPuppet;
  }

  private final func GetHealthPecentageNormalized() -> Float {
    return this.GetOwnerCurrentHealth() / 100.00;
  }

  private final func GetFrameDamage() -> Float {
    let factor: Float = 1.00;
    let frameDamage: Float = (this.GetOwner() as NPCPuppet).GetTotalFrameDamage();
    if this.m_frameDamageHealthFactor > 0.00 {
      factor = 1.00 + (1.00 - this.GetHealthPecentageNormalized()) * this.m_frameDamageHealthFactor;
    };
    return frameDamage * factor;
  }

  private final func GetPhysicalImpulse(attackData: ref<AttackData>, hitPosition: Vector4) -> Float {
    let attackWeaponID: StatsObjectID;
    let baseValue: Float;
    let finalImpulse: Float;
    let frameImpulse: Float;
    let statsSystem: ref<StatsSystem> = GameInstance.GetStatsSystem(this.GetOwner().GetGame());
    let timeToReachMax: Float = 0.30;
    if IsDefined(attackData.GetWeapon()) {
      attackWeaponID = Cast(attackData.GetWeapon().GetEntityID());
    };
    if this.m_previousHitTime + statsSystem.GetStatValue(attackWeaponID, gamedataStatType.CycleTimeBase) + this.m_physicalImpulseReset < this.GetCurrentTime() {
      this.m_cumulatedPhysicalImpulse = 0.00;
    };
    frameImpulse = statsSystem.GetStatValue(attackWeaponID, gamedataStatType.KnockdownImpulse);
    if AttackData.IsBullet(attackData.GetAttackType()) {
      frameImpulse *= DamageSystem.GetEffectiveRangeModifierForWeapon(attackData, hitPosition, statsSystem);
    };
    if this.m_cumulatedPhysicalImpulse < frameImpulse {
      finalImpulse = frameImpulse;
    } else {
      baseValue = 1.50 * frameImpulse - this.m_cumulatedPhysicalImpulse;
      finalImpulse = baseValue * (this.GetCurrentTime() - this.m_previousHitTime) / timeToReachMax;
      if finalImpulse > baseValue {
        finalImpulse = baseValue;
      };
    };
    this.m_ragdollImpulse = frameImpulse * 0.25;
    return finalImpulse > 0.00 ? finalImpulse : 0.00;
  }

  private final func GetFrameWoundsDamage() -> Float {
    return (this.GetOwner() as NPCPuppet).GetTotalFrameWoundsDamage();
  }

  private final func GetFrameDismembermentDamage() -> Float {
    return (this.GetOwner() as NPCPuppet).GetTotalFrameDismembermentDamage();
  }

  private final func GetOwnerHPPercentage() -> Float {
    let ownerID: StatsObjectID = Cast(this.GetOwner().GetEntityID());
    return GameInstance.GetStatPoolsSystem(this.GetOwner().GetGame()).GetStatPoolValue(ownerID, gamedataStatPoolType.Health);
  }

  protected final func GetHitShapeUserData() -> ref<HitShapeUserDataBase> {
    return this.m_hitShapeData.userData as HitShapeUserDataBase;
  }

  private final func ResetFrameDamage() -> Void {
    let evt: ref<ResetFrameDamage> = new ResetFrameDamage();
    this.GetOwner().QueueEvent(evt);
  }

  private final const func GetBlockCountInterval() -> Float {
    return TweakDBInterface.GetFloat(t"GlobalStats.BlockCountInterval.value", 2.00);
  }

  private final const func GetDodgeCountInterval() -> Float {
    return TweakDBInterface.GetFloat(t"GlobalStats.DodgeCountInterval.value", 2.00);
  }

  protected final func GetCurrentTime() -> Float {
    return EngineTime.ToFloat(this.GetSimTime());
  }

  private final func IsOwnerFacingInstigator() -> Bool {
    let toTarget: Vector4 = this.m_attackData.GetInstigator().GetWorldPosition() - this.GetOwner().GetWorldPosition();
    let angle: Float = Vector4.GetAngleBetween(toTarget, this.GetOwner().GetWorldForward());
    return angle < 80.00;
  }

  private final func NotifyAboutWoundedInstigated(instigator: wref<GameObject>, const bodyPart: EHitReactionZone) -> Void {
    let evt: ref<WoundedInstigated>;
    if !IsDefined(instigator) {
      return;
    };
    evt = new WoundedInstigated();
    evt.bodyPart = bodyPart;
    instigator.QueueEvent(evt);
  }

  private final func NotifyAboutDismembermentInstigated(instigator: wref<GameObject>, const bodyPart: EHitReactionZone) -> Void {
    let evt: ref<DismembermentInstigated>;
    if !IsDefined(instigator) {
      return;
    };
    evt = new DismembermentInstigated();
    evt.bodyPart = bodyPart;
    instigator.QueueEvent(evt);
  }

  private final func GetHitReactionStatThreshold(stat: gamedataStatType) -> Float {
    let ss: ref<StatsSystem> = GameInstance.GetStatsSystem(this.GetOwnerPuppet().GetGame());
    let totalHealth: Float = ss.GetStatValue(Cast(this.GetOwner().GetEntityID()), gamedataStatType.Health);
    return totalHealth * ss.GetStatValue(Cast(this.GetOwner().GetEntityID()), stat) / 100.00;
  }

  private final func GetOwnerTotalHealth() -> Float {
    return GameInstance.GetStatsSystem(this.GetOwnerPuppet().GetGame()).GetStatValue(Cast(this.GetOwner().GetEntityID()), gamedataStatType.Health);
  }

  private final func GetOwnerCurrentHealth() -> Float {
    return GameInstance.GetStatPoolsSystem(this.GetOwner().GetGame()).GetStatPoolValue(Cast(this.GetOwner().GetEntityID()), gamedataStatPoolType.Health, true);
  }

  private final func GetIsOwnerImmuneToExtendedHitReaction() -> Float {
    return GameInstance.GetStatsSystem(this.GetOwnerPuppet().GetGame()).GetStatValue(Cast(this.GetOwner().GetEntityID()), gamedataStatType.HasExtendedHitReactionImmunity);
  }

  private final func GetIsOwnerImmuneToMelee() -> Float {
    return GameInstance.GetStatsSystem(this.GetOwnerPuppet().GetGame()).GetStatValue(Cast(this.GetOwner().GetEntityID()), gamedataStatType.HasMeleeImmunity);
  }

  public func OnGameAttach() -> Void {
    let damageInfoBB: ref<IBlackboard>;
    let enumSize: Int32;
    this.m_animHitReaction = new AnimFeature_HitReactionsData();
    this.m_lastAnimHitReaction = new AnimFeature_HitReactionsData();
    this.m_hitReactionAction = new ActionHitReactionScriptProxy();
    this.m_hitReactionAction.Bind(this.GetOwner());
    enumSize = Cast(EnumGetMax(n"EHitReactionZone")) + 1;
    ArrayResize(this.m_bodyPartWoundCumulatedDamages, enumSize);
    ArrayResize(this.m_bodyPartDismemberCumulatedDamages, enumSize);
    ArrayResize(this.m_woundedBodyPartDamageThreshold, enumSize);
    ArrayResize(this.m_dismembermentBodyPartDamageThreshold, enumSize);
    ArrayResize(this.m_defeatedBodyPartDamageThreshold, enumSize);
    damageInfoBB = GameInstance.GetBlackboardSystem(this.GetOwner().GetGame()).Get(GetAllBlackboardDefs().UI_DamageInfo);
    this.m_indicatorEnabledBlackboardId = damageInfoBB.RegisterListenerBool(GetAllBlackboardDefs().UI_DamageInfo.HitIndicatorEnabled, this, n"OnHitIndicatorEnabledChanged");
    this.m_hitIndicatorEnabled = damageInfoBB.GetBool(GetAllBlackboardDefs().UI_DamageInfo.HitIndicatorEnabled);
  }

  private final func OnGameDetach() -> Void {
    this.m_hitReactionAction = null;
    let damageInfoBB: ref<IBlackboard> = GameInstance.GetBlackboardSystem(this.GetOwner().GetGame()).Get(GetAllBlackboardDefs().UI_DamageInfo);
    if IsDefined(this.m_indicatorEnabledBlackboardId) {
      damageInfoBB.UnregisterListenerBool(GetAllBlackboardDefs().UI_DamageInfo.HitIndicatorEnabled, this.m_indicatorEnabledBlackboardId);
    };
  }

  protected cb func OnDeath(evt: ref<gameDeathEvent>) -> Bool {
    if this.m_isAlive {
      this.m_reactionType = animHitReactionType.Death;
      this.m_isAlive = false;
      this.SendDataToAIBehavior(this.m_reactionType);
    };
  }

  protected cb func OnHitIndicatorEnabledChanged(value: Bool) -> Bool {
    this.m_hitIndicatorEnabled = value;
  }

  protected cb func OnResurrect(evt: ref<ResurrectEvent>) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(this.m_bodyPartDismemberCumulatedDamages) {
      this.m_bodyPartDismemberCumulatedDamages[i] = 0.00;
      i += 1;
    };
    this.m_cumulatedDamages = 0.00;
    this.m_defeatedHasBeenPlayed = false;
  }

  protected cb func OnHitReactionCumulativeDamageUpdate(evt: ref<HitReactionCumulativeDamageUpdate>) -> Bool {
    this.m_cumulativeDamageUpdateRequested = false;
    let deltaTime: Float = this.GetCurrentTime() - evt.m_prevUpdateTime;
    if this.UpdateCumulatedDamages(deltaTime) {
      this.RequestCumulativeDamageUpdate();
    };
  }

  private final func RequestCumulativeDamageUpdate() -> Void {
    let evt: ref<HitReactionCumulativeDamageUpdate>;
    if this.m_cumulativeDamageUpdateRequested {
      return;
    };
    evt = new HitReactionCumulativeDamageUpdate();
    evt.m_prevUpdateTime = this.GetCurrentTime();
    GameInstance.GetDelaySystem(this.GetOwner().GetGame()).DelayEvent(this.GetOwner(), evt, this.m_cumulativeDamageUpdateInterval);
    this.m_cumulativeDamageUpdateRequested = true;
  }

  protected cb func OnHitReactionStopMotionExtraction(evt: ref<HitReactionStopMotionExtraction>) -> Bool {
    if IsDefined(this.m_hitReactionAction) {
      this.m_hitReactionAction.Stop();
    };
  }

  protected cb func OnRequestHitReaction(evt: ref<HitReactionRequest>) -> Bool {
    this.EvaluateHit(evt.hitEvent);
  }

  protected cb func OnForcedHitReaction(forcedHitReaction: ref<ForcedHitReactionEvent>) -> Bool {
    if forcedHitReaction.hitIntensity != EnumInt(IntEnum(-1l)) {
      this.m_animHitReaction.hitIntensity = forcedHitReaction.hitIntensity;
    };
    if forcedHitReaction.hitSource != EnumInt(IntEnum(-1l)) {
      this.SetHitReactionSource(IntEnum(forcedHitReaction.hitSource));
    };
    if forcedHitReaction.hitBodyPart != EnumInt(IntEnum(-1l)) {
      this.m_animHitReaction.hitBodyPart = forcedHitReaction.hitBodyPart;
    };
    if forcedHitReaction.hitNpcMovementSpeed != -1 {
      this.m_animHitReaction.npcMovementSpeed = forcedHitReaction.hitNpcMovementSpeed;
    };
    if forcedHitReaction.hitDirection != EnumInt(IntEnum(-1l)) {
      this.m_animHitReaction.hitDirection = forcedHitReaction.hitDirection;
    };
    if forcedHitReaction.hitNpcMovementDirection != -1 {
      this.m_animHitReaction.npcMovementDirection = forcedHitReaction.hitNpcMovementDirection;
    };
    if forcedHitReaction.hitType != -1 {
      this.SetHitReactionType(IntEnum(forcedHitReaction.hitType));
      this.SendDataToAIBehavior(IntEnum(forcedHitReaction.hitType));
    } else {
      this.SetHitReactionType(animHitReactionType.Pain);
      this.SendDataToAIBehavior(animHitReactionType.Stagger);
    };
  }

  protected cb func OnForcedDeathEvent(forcedDeath: ref<ForcedDeathEvent>) -> Bool {
    if forcedDeath.hitIntensity != EnumInt(IntEnum(-1l)) {
      this.m_animHitReaction.hitIntensity = forcedDeath.hitIntensity;
    };
    if forcedDeath.hitSource != EnumInt(IntEnum(-1l)) {
      this.SetHitReactionSource(IntEnum(forcedDeath.hitSource));
    };
    if forcedDeath.hitBodyPart != EnumInt(IntEnum(-1l)) {
      this.m_animHitReaction.hitBodyPart = forcedDeath.hitBodyPart;
    };
    if forcedDeath.hitNpcMovementSpeed != -1 {
      this.m_animHitReaction.npcMovementSpeed = forcedDeath.hitNpcMovementSpeed;
    };
    if forcedDeath.hitDirection != EnumInt(IntEnum(-1l)) {
      this.m_animHitReaction.hitDirection = forcedDeath.hitDirection;
    };
    if forcedDeath.hitNpcMovementDirection != -1 {
      this.m_animHitReaction.npcMovementDirection = forcedDeath.hitNpcMovementDirection;
    };
    this.SetHitReactionType(animHitReactionType.Death);
    this.GetOwnerPuppet().Kill();
    if forcedDeath.forceRagdoll && ScriptedPuppet.CanRagdoll(this.GetOwnerPuppet()) {
      this.SendDataToAIBehavior(animHitReactionType.Ragdoll);
    } else {
      this.SendDataToAIBehavior(animHitReactionType.Death);
    };
    this.m_isAlive = false;
  }

  protected cb func OnSetLastHitReactionBehaviorData(evt: ref<LastHitDataEvent>) -> Bool {
    this.m_lastHitReactionBehaviorData = evt.hitReactionBehaviorData;
  }

  protected cb func OnSetNewHitReactionBehaviorData(evt: ref<NewHitDataEvent>) -> Bool {
    this.m_animHitReaction.hitDirection = evt.hitDirection;
    this.m_animHitReaction.hitIntensity = evt.hitIntensity;
    this.SetHitReactionType(IntEnum(evt.hitType));
    this.m_animHitReaction.hitBodyPart = evt.hitBodyPart;
    this.m_animHitReaction.npcMovementSpeed = evt.hitNpcMovementSpeed;
    this.m_animHitReaction.npcMovementDirection = evt.hitNpcMovementDirection;
    this.m_animHitReaction.stance = evt.stance;
    this.m_animHitReaction.animVariation = evt.animVariation;
    this.SetHitReactionSource(IntEnum(evt.hitSource));
  }

  private final func IsSoundCriticalHit(hitEvent: ref<gameHitEvent>) -> Bool {
    return IsDefined(hitEvent.target as WeakspotObject) || hitEvent.attackData.HasFlag(hitFlag.Headshot);
  }

  private final func GetKillSoundName(hitEvent: ref<gameHitEvent>) -> CName {
    let isSoundCritical: Bool = this.IsSoundCriticalHit(hitEvent);
    if Equals(this.GetHitShapeUserData().GetShapeType(), EHitShapeType.Cyberware) {
      return isSoundCritical ? n"w_feedback_hit_cyber_head_kill" : n"w_feedback_hit_cyber_body_kill";
    };
    return isSoundCritical ? n"w_feedback_kill_npc_head" : n"w_feedback_kill_npc";
  }

  private final func GetHitSoundName(hitEvent: ref<gameHitEvent>) -> CName {
    let isSoundCritical: Bool = this.IsSoundCriticalHit(hitEvent);
    if Equals(this.GetHitShapeUserData().GetShapeType(), EHitShapeType.Metal) {
      return isSoundCritical ? n"w_feedback_hit_armor_weakpoint" : n"w_feedback_hit_armor";
    };
    if Equals(this.GetHitShapeUserData().GetShapeType(), EHitShapeType.Cyberware) {
      return isSoundCritical ? n"w_feedback_hit_cyber_head" : n"w_feedback_hit_cyber_body";
    };
    return isSoundCritical ? n"w_feedback_hit_npc_crit" : n"w_feedback_hit_npc";
  }

  public func EvaluateHit(newHitEvent: ref<gameHitEvent>) -> Void {
    let broadcaster: ref<StimBroadcasterComponent>;
    let currentCoverId: Uint64;
    let defeatedOverride: Bool;
    let hitFeedbackSound: CName;
    let parentObject: wref<GameObject>;
    let wasNPCAliveBeforeProcessingHit: Bool;
    let npc: ref<NPCPuppet> = this.GetOwner() as NPCPuppet;
    if !IsDefined(npc) {
      return;
    };
    this.IncrementHitCountData();
    this.CacheVars(newHitEvent);
    this.GetDBParameters();
    if !this.GetBodyPart(newHitEvent) {
      return;
    };
    if !this.m_deathHasBeenPlayed {
      defeatedOverride = this.ProcessDefeated(npc);
    };
    if AttackData.IsBullet(newHitEvent.attackData.GetAttackType()) {
      hitFeedbackSound = this.GetHitSoundName(newHitEvent);
      if defeatedOverride {
        hitFeedbackSound = this.GetKillSoundName(newHitEvent);
      } else {
        if this.m_isAlive && npc.IsAboutToBeDefeated() && !ScriptedPuppet.IsDefeated(npc) {
          hitFeedbackSound = n"w_feedback_defeat_npc";
        } else {
          if ScriptedPuppet.IsDefeated(npc) {
            hitFeedbackSound = this.GetKillSoundName(newHitEvent);
          };
        };
      };
    };
    if ScriptedPuppet.IsBeingGrappled(npc) {
      this.m_reactionType = animHitReactionType.Twitch;
      if IsDefined(newHitEvent) {
        this.StoreHitData(GameObject.GetAttackAngleInInt(newHitEvent, this.m_animHitReaction.hitSource), this.m_hitIntensity, this.m_reactionType, HitShapeUserDataBase.GetHitReactionZone(this.GetHitShapeUserData()), this.m_animVariation);
      };
      this.SendTwitchDataToAnimationGraph();
      if IsDefined(newHitEvent) {
        parentObject = ScriptedPuppet.GetGrappleParent(newHitEvent.target);
        if parentObject.IsPlayer() {
          this.SendTwitchDataToPlayerAnimationGraph(parentObject);
        };
      };
      GameObject.PlayVoiceOver(npc, n"hit_grapple", n"Scripts:Grapple");
      return;
    };
    if VehicleComponent.IsMountedToVehicle(npc.GetGame(), npc.GetEntityID()) && (NotEquals(npc.GetNPCType(), gamedataNPCType.Drone) || this.m_isAlive) {
      this.m_reactionType = animHitReactionType.Twitch;
      if IsDefined(newHitEvent) {
        this.StoreHitData(GameObject.GetAttackAngleInInt(newHitEvent, this.m_animHitReaction.hitSource), this.m_hitIntensity, this.m_reactionType, HitShapeUserDataBase.GetHitReactionZone(this.GetHitShapeUserData()), this.m_animVariation);
      };
      this.SendTwitchDataToAnimationGraph();
      return;
    };
    if !IsDefined(newHitEvent) {
      if !this.m_isAlive {
        if npc.ShouldSkipDeathAnimation() {
          this.SetHitReactionType(IntEnum(0l));
        } else {
          this.m_animHitReaction.hitDirection = 0;
          this.m_animHitReaction.hitIntensity = EnumInt(EAIHitIntensity.Medium);
          this.SetHitReactionType(animHitReactionType.Death);
          this.m_animHitReaction.hitBodyPart = EnumInt(EAIHitBodyPart.Belly);
          this.m_animHitReaction.npcMovementSpeed = 0;
          this.m_animHitReaction.npcMovementDirection = 0;
        };
        this.m_hitReactionAction.Stop();
        this.m_hitReactionAction.Setup(this.m_animHitReaction);
        this.m_hitReactionAction.Launch();
        AnimationControllerComponent.ApplyFeatureToReplicate(this.GetOwner(), n"hit", this.m_animHitReaction);
      } else {
        return;
      };
    };
    this.m_hitPosition = newHitEvent.hitPosition;
    this.m_hitDirection = newHitEvent.hitDirection;
    currentCoverId = AICoverHelper.GetCurrentCover(npc);
    if this.m_deathHasBeenPlayed {
      if newHitEvent.attackData.DoesAttackWeaponHaveTag(n"HeavyWeapon") && this.GetIsOwnerImmuneToExtendedHitReaction() == 0.00 && !defeatedOverride && EnumInt(this.m_hitIntensity) <= 1 && this.m_animVariation < 13 {
        this.SetCumulatedDamagesForDeadNPC();
        this.m_previousHitTime = this.GetCurrentTime();
        if this.m_deathRegisteredTime + 0.70 >= this.GetCurrentTime() || this.m_extendedDeathRegisteredTime + 0.70 >= this.GetCurrentTime() {
          this.m_extendedDeathRegisteredTime = this.GetCurrentTime();
          if this.m_extendedDeathDelayRegisteredTime + 0.30 >= this.GetCurrentTime() {
            this.m_extendedDeathDelayRegisteredTime = this.GetCurrentTime();
            this.m_reactionType = animHitReactionType.Death;
            this.ProcessExtendedDeathAnimData(newHitEvent);
            this.StoreHitData(GameObject.GetAttackAngleInInt(newHitEvent, this.m_animHitReaction.hitSource), this.m_hitIntensity, this.m_reactionType, HitShapeUserDataBase.GetHitReactionZone(this.GetHitShapeUserData()), this.m_animVariation);
            this.SendDataToAIBehavior(this.m_reactionType);
          } else {
            this.m_reactionType = animHitReactionType.Twitch;
            this.StoreHitData(GameObject.GetAttackAngleInInt(newHitEvent, this.m_animHitReaction.hitSource), this.m_hitIntensity, this.m_reactionType, HitShapeUserDataBase.GetHitReactionZone(this.GetHitShapeUserData()), this.m_animVariation);
            this.SendTwitchDataToAnimationGraph();
          };
        } else {
          if ScriptedPuppet.CanRagdoll(npc) {
            if this.m_deathRegisteredTime + 1.00 <= this.GetCurrentTime() && this.m_extendedDeathRegisteredTime + 1.00 <= this.GetCurrentTime() {
              npc.QueueEvent(CreateForceRagdollEvent(n"Dead_RecivedHit"));
              npc.QueueEvent(CreateRagdollApplyImpulseEvent(this.GetHitPosition(), this.GetHitDirection() * this.m_ragdollImpulse, 1.00));
            };
          };
          this.SetCumulatedDamagesForDeadNPC();
          this.ProcessWoundsAndDismemberment();
        };
      } else {
        if ScriptedPuppet.CanRagdoll(npc) {
          if this.m_deathRegisteredTime + 1.00 <= this.GetCurrentTime() {
            npc.QueueEvent(CreateForceRagdollEvent(n"Dead_RecivedHit1"));
            npc.QueueEvent(CreateRagdollApplyImpulseEvent(this.GetHitPosition(), this.GetHitDirection() * this.m_ragdollImpulse, 1.00));
          };
        };
        this.SetCumulatedDamagesForDeadNPC();
        this.ProcessWoundsAndDismemberment();
      };
    } else {
      if AttackData.IsBullet(newHitEvent.attackData.GetAttackType()) {
        if !this.GetHitTimerAvailability() && this.m_previousRangedHitTimeStamp != this.GetCurrentTime() && this.m_isAlive {
          return;
        };
      };
      if this.m_isAlive {
        this.SetCumulatedDamages(newHitEvent.target);
      } else {
        this.SetCumulatedDamagesForDeadNPC();
        if this.m_deathHasBeenPlayed && ScriptedPuppet.CanRagdoll(npc) {
          npc.QueueEvent(CreateForceRagdollEvent(n"dead_RecivedHit2"));
          npc.QueueEvent(CreateRagdollApplyImpulseEvent(this.GetHitPosition(), this.GetHitDirection() * this.m_ragdollImpulse, 1.00));
        };
      };
      this.SetHitSource(this.m_attackData.GetAttackType());
      this.SetStance();
      this.SetHitReactionThresholds();
      this.GetHitIntensity(defeatedOverride);
      this.SetHitReactionImmunities();
      if !defeatedOverride {
        this.m_reactionType = this.GetReactionType();
      };
      this.ProcessWoundsAndDismemberment();
      if this.GetCurrentTime() <= this.m_previousHitTime + 0.09 && Equals(this.m_reactionType, animHitReactionType.Twitch) {
        return;
      };
      this.SetAnimVariation();
      this.StoreHitData(GameObject.GetAttackAngleInInt(newHitEvent, this.m_animHitReaction.hitSource), this.m_hitIntensity, this.m_reactionType, HitShapeUserDataBase.GetHitReactionZone(this.GetHitShapeUserData()), this.m_animVariation);
      this.m_previousHitTime = this.GetCurrentTime();
      if npc.IsPlayerCompanion() && this.GetHitCountInCombo() >= 2 {
        if AITweakParams.GetBoolFromTweak(t"AIGeneralSettings.followers", "allowDefeated") {
          StatusEffectHelper.ApplyStatusEffect(npc, t"BaseStatusEffect.FollowerDefeated");
          this.m_reactionType = IntEnum(0l);
        };
      };
      if ScriptedPuppet.CanRagdoll(npc) && Equals(npc.GetHighLevelStateFromBlackboard(), gamedataNPCHighLevelState.Unconscious) || npc.IsRagdolling() {
        npc.QueueEvent(CreateForceRagdollEvent(n"Unconscious_RecivedHit"));
        npc.QueueEvent(CreateRagdollApplyImpulseEvent(this.GetHitPosition(), this.GetHitDirection() * 10.00, 1.00));
      } else {
        if this.m_animHitReaction.hitType == EnumInt(animHitReactionType.Twitch) && npc.IsAboutToBeDefeated() {
          return;
        };
        if Equals(this.m_reactionType, animHitReactionType.Death) && !this.m_isAlive && Equals(npc.GetNPCType(), gamedataNPCType.Drone) {
          this.SendDataToAIBehavior(this.m_reactionType);
        } else {
          if this.m_animHitReaction.hitType == EnumInt(animHitReactionType.Twitch) || (this.GetOwner() as ScriptedPuppet).GetMovePolicesComponent().IsOnOffMeshLink() || this.GetOwnerPuppet().GetMovePolicesComponent().IsOnOffMeshLink() || GameInstance.GetWorkspotSystem(this.GetOwner().GetGame()).IsActorInWorkspot(this.GetOwner()) && currentCoverId == 0u {
            this.SendTwitchDataToAnimationGraph();
            if NotEquals(this.m_attackData.GetHitType(), gameuiHitType.Miss) {
              broadcaster = this.m_attackData.GetSource().GetStimBroadcasterComponent();
              if IsDefined(broadcaster) {
                broadcaster.SendDrirectStimuliToTarget(this.GetOwner(), gamedataStimType.CombatHit, this.GetOwner());
              };
            };
          } else {
            this.SendDataToAIBehavior(this.m_reactionType);
          };
        };
      };
    };
    if AttackData.IsBullet(newHitEvent.attackData.GetAttackType()) {
      wasNPCAliveBeforeProcessingHit = this.m_isAlive;
      if !this.m_isAlive && wasNPCAliveBeforeProcessingHit {
        hitFeedbackSound = this.GetKillSoundName(newHitEvent);
      };
      if newHitEvent.attackData.GetInstigator().IsPlayer() && !newHitEvent.attackData.HasFlag(hitFlag.DealNoDamage) && this.m_hitIndicatorEnabled {
        GameObject.PlaySound(this.GetOwner(), hitFeedbackSound);
      };
    };
    if this.m_isAlive {
      this.UpdateCoverDamage(npc, currentCoverId);
    };
    this.m_hitCount += 1u;
  }

  public func UpdateCoverDamage(npc: ref<NPCPuppet>, coverId: Uint64) -> Void {
    let context: ScriptExecutionContext;
    if coverId > 0u {
      if AIHumanComponent.GetScriptContext(npc, context) {
        AICoverHelper.NotifyGotDamageInCover(npc, coverId, ScriptExecutionContext.GetAITime(context), AICoverHelper.GetCoverNPCCurrentlyExposed(npc));
      };
    };
  }

  protected final func CacheVars(hitEvent: ref<gameHitEvent>) -> Void {
    this.m_isAlive = ScriptedPuppet.IsAlive(this.GetOwner());
    this.m_attackData = hitEvent.attackData;
  }

  protected final func IncrementHitCountData() -> Void {
    this.m_hitCountData[this.m_hitCountArrayCurrent] = this.GetCurrentTime();
    this.m_hitCountArrayCurrent += 1;
    if this.m_hitCountArrayCurrent > this.m_hitCountArrayEnd {
      this.m_hitCountArrayCurrent = 0;
    };
  }

  public final const func GetHitCountData(index: Int32) -> Float {
    let modifiedIndex: Int32;
    if this.m_hitCountArrayCurrent - index < 0 {
      modifiedIndex = this.m_hitCountArrayEnd + this.m_hitCountArrayCurrent - index;
    } else {
      modifiedIndex = this.m_hitCountArrayCurrent - index;
    };
    return this.m_hitCountData[modifiedIndex];
  }

  public final const func GetHitCountDataArrayCurrent() -> Int32 {
    return this.m_hitCountArrayCurrent;
  }

  public final const func GetHitCountDataArrayEnd() -> Int32 {
    return this.m_hitCountArrayEnd;
  }

  protected final func GetDBParameters() -> Void {
    let ownerID: StatsObjectID = Cast(this.GetOwner().GetEntityID());
    let statsSystem: ref<StatsSystem> = GameInstance.GetStatsSystem(this.GetOwner().GetGame());
    let totalHealthAmount: Float = this.GetOwnerTotalHealth();
    this.m_impactDamageDuration = statsSystem.GetStatValue(ownerID, gamedataStatType.HitTimerAfterImpact);
    this.m_staggerDamageDuration = statsSystem.GetStatValue(ownerID, gamedataStatType.HitTimerAfterStagger);
    this.m_knockdownDamageDuration = statsSystem.GetStatValue(ownerID, gamedataStatType.HitTimerAfterKnockdown);
    this.m_impactDamageDurationMelee = statsSystem.GetStatValue(ownerID, gamedataStatType.HitTimerAfterImpactMelee);
    this.m_staggerDamageDurationMelee = statsSystem.GetStatValue(ownerID, gamedataStatType.HitTimerAfterStaggerMelee);
    this.m_defeatedMinDuration = statsSystem.GetStatValue(ownerID, gamedataStatType.HitTimerAfterDefeated);
    this.m_hitComboReset = TweakDBInterface.GetFloat(t"GlobalStats.ReactionHitChainReset.value", 10.00);
    this.m_frameDamageHealthFactor = statsSystem.GetStatValue(ownerID, gamedataStatType.HitReactionDamageHealthFactor);
    this.m_woundedBodyPartDamageThreshold[EnumInt(EHitReactionZone.Head)] = (totalHealthAmount * statsSystem.GetStatValue(ownerID, gamedataStatType.WoundHeadDamageThreshold)) / 100.00;
    this.m_woundedBodyPartDamageThreshold[EnumInt(EHitReactionZone.ChestLeft)] = totalHealthAmount;
    this.m_woundedBodyPartDamageThreshold[EnumInt(EHitReactionZone.ArmLeft)] = (totalHealthAmount * statsSystem.GetStatValue(ownerID, gamedataStatType.WoundLArmDamageThreshold)) / 100.00;
    this.m_woundedBodyPartDamageThreshold[EnumInt(EHitReactionZone.HandLeft)] = (totalHealthAmount * statsSystem.GetStatValue(ownerID, gamedataStatType.WoundLArmDamageThreshold)) / 100.00;
    this.m_woundedBodyPartDamageThreshold[EnumInt(EHitReactionZone.ChestRight)] = totalHealthAmount;
    this.m_woundedBodyPartDamageThreshold[EnumInt(EHitReactionZone.ArmRight)] = (totalHealthAmount * statsSystem.GetStatValue(ownerID, gamedataStatType.WoundRArmDamageThreshold)) / 100.00;
    this.m_woundedBodyPartDamageThreshold[EnumInt(EHitReactionZone.HandRight)] = (totalHealthAmount * statsSystem.GetStatValue(ownerID, gamedataStatType.WoundRArmDamageThreshold)) / 100.00;
    this.m_woundedBodyPartDamageThreshold[EnumInt(EHitReactionZone.Abdomen)] = totalHealthAmount;
    this.m_woundedBodyPartDamageThreshold[EnumInt(EHitReactionZone.LegLeft)] = (totalHealthAmount * statsSystem.GetStatValue(ownerID, gamedataStatType.WoundLLegDamageThreshold)) / 100.00;
    this.m_woundedBodyPartDamageThreshold[EnumInt(EHitReactionZone.LegRight)] = (totalHealthAmount * statsSystem.GetStatValue(ownerID, gamedataStatType.WoundRLegDamageThreshold)) / 100.00;
    this.m_dismembermentBodyPartDamageThreshold[EnumInt(EHitReactionZone.Head)] = (totalHealthAmount * statsSystem.GetStatValue(ownerID, gamedataStatType.DismHeadDamageThreshold)) / 100.00;
    this.m_dismembermentBodyPartDamageThreshold[EnumInt(EHitReactionZone.ChestLeft)] = totalHealthAmount;
    this.m_dismembermentBodyPartDamageThreshold[EnumInt(EHitReactionZone.ArmLeft)] = (totalHealthAmount * statsSystem.GetStatValue(ownerID, gamedataStatType.DismLArmDamageThreshold)) / 100.00;
    this.m_dismembermentBodyPartDamageThreshold[EnumInt(EHitReactionZone.HandLeft)] = (totalHealthAmount * statsSystem.GetStatValue(ownerID, gamedataStatType.DismLArmDamageThreshold)) / 100.00;
    this.m_dismembermentBodyPartDamageThreshold[EnumInt(EHitReactionZone.ChestRight)] = totalHealthAmount;
    this.m_dismembermentBodyPartDamageThreshold[EnumInt(EHitReactionZone.ArmRight)] = (totalHealthAmount * statsSystem.GetStatValue(ownerID, gamedataStatType.DismRArmDamageThreshold)) / 100.00;
    this.m_dismembermentBodyPartDamageThreshold[EnumInt(EHitReactionZone.HandRight)] = (totalHealthAmount * statsSystem.GetStatValue(ownerID, gamedataStatType.DismRArmDamageThreshold)) / 100.00;
    this.m_dismembermentBodyPartDamageThreshold[EnumInt(EHitReactionZone.Abdomen)] = totalHealthAmount;
    this.m_dismembermentBodyPartDamageThreshold[EnumInt(EHitReactionZone.LegLeft)] = (totalHealthAmount * statsSystem.GetStatValue(ownerID, gamedataStatType.DismLLegDamageThreshold)) / 100.00;
    this.m_dismembermentBodyPartDamageThreshold[EnumInt(EHitReactionZone.LegRight)] = (totalHealthAmount * statsSystem.GetStatValue(ownerID, gamedataStatType.DismRLegDamageThreshold)) / 100.00;
    this.m_defeatedBodyPartDamageThreshold[EnumInt(EHitReactionZone.Head)] = (totalHealthAmount * statsSystem.GetStatValue(ownerID, gamedataStatType.DefeatedHeadDamageThreshold)) / 100.00;
    this.m_defeatedBodyPartDamageThreshold[EnumInt(EHitReactionZone.ChestLeft)] = (totalHealthAmount * statsSystem.GetStatValue(ownerID, gamedataStatType.DefeatedLArmDamageThreshold)) / 100.00;
    this.m_defeatedBodyPartDamageThreshold[EnumInt(EHitReactionZone.ArmLeft)] = (totalHealthAmount * statsSystem.GetStatValue(ownerID, gamedataStatType.DefeatedLArmDamageThreshold)) / 100.00;
    this.m_defeatedBodyPartDamageThreshold[EnumInt(EHitReactionZone.HandLeft)] = (totalHealthAmount * statsSystem.GetStatValue(ownerID, gamedataStatType.DefeatedLArmDamageThreshold)) / 100.00;
    this.m_defeatedBodyPartDamageThreshold[EnumInt(EHitReactionZone.ChestRight)] = (totalHealthAmount * statsSystem.GetStatValue(ownerID, gamedataStatType.DefeatedRArmDamageThreshold)) / 100.00;
    this.m_defeatedBodyPartDamageThreshold[EnumInt(EHitReactionZone.ArmRight)] = (totalHealthAmount * statsSystem.GetStatValue(ownerID, gamedataStatType.DefeatedRArmDamageThreshold)) / 100.00;
    this.m_defeatedBodyPartDamageThreshold[EnumInt(EHitReactionZone.HandRight)] = (totalHealthAmount * statsSystem.GetStatValue(ownerID, gamedataStatType.DefeatedRArmDamageThreshold)) / 100.00;
    this.m_defeatedBodyPartDamageThreshold[EnumInt(EHitReactionZone.Abdomen)] = (totalHealthAmount * statsSystem.GetStatValue(ownerID, gamedataStatType.DefeatedLArmDamageThreshold)) / 100.00;
    this.m_defeatedBodyPartDamageThreshold[EnumInt(EHitReactionZone.LegLeft)] = (totalHealthAmount * statsSystem.GetStatValue(ownerID, gamedataStatType.DefeatedLLegDamageThreshold)) / 100.00;
    this.m_defeatedBodyPartDamageThreshold[EnumInt(EHitReactionZone.LegRight)] = (totalHealthAmount * statsSystem.GetStatValue(ownerID, gamedataStatType.DefeatedRLegDamageThreshold)) / 100.00;
  }

  protected final func SetHitReactionType(hitType: animHitReactionType) -> Void {
    let puppet: ref<ScriptedPuppet> = this.GetOwnerPuppet();
    this.m_animHitReaction.hitType = EnumInt(hitType);
    puppet.NotifyHitReactionTypeChanged(this.m_animHitReaction.hitType);
  }

  protected final func SetHitReactionSource(hitSource: EAIHitSource) -> Void {
    let puppet: ref<ScriptedPuppet> = this.GetOwnerPuppet();
    this.m_animHitReaction.hitSource = EnumInt(hitSource);
    puppet.NotifyHitReactionSourceChanged(this.m_animHitReaction.hitSource);
  }

  protected final func SetStance() -> Void {
    if AIActionHelper.IsCurrentlyCrouching(this.GetOwnerPuppet()) {
      this.m_animHitReaction.stance = 1;
    } else {
      this.m_animHitReaction.stance = 0;
    };
  }

  protected final func SetHitReactionThresholds() -> Void {
    this.m_knockdownImpulseThreshold = GameInstance.GetStatsSystem(this.GetOwnerPuppet().GetGame()).GetStatValue(Cast(this.GetOwner().GetEntityID()), gamedataStatType.KnockdownDamageThresholdImpulse);
    let currentCoverId: Uint64 = AICoverHelper.GetCurrentCoverId(this.GetOwnerPuppet());
    if currentCoverId > 0u && GameInstance.GetCoverManager(this.GetOwnerPuppet().GetGame()).IsCoverRegular(currentCoverId) {
      this.m_impactDamageThreshold = this.GetHitReactionStatThreshold(gamedataStatType.ImpactDamageThresholdInCover);
      this.m_staggerDamageThreshold = this.GetHitReactionStatThreshold(gamedataStatType.StaggerDamageThresholdInCover);
      this.m_knockdownDamageThreshold = this.GetHitReactionStatThreshold(gamedataStatType.KnockdownDamageThresholdInCover);
      return;
    };
    this.m_impactDamageThreshold = this.GetHitReactionStatThreshold(gamedataStatType.ImpactDamageThreshold);
    this.m_staggerDamageThreshold = this.GetHitReactionStatThreshold(gamedataStatType.StaggerDamageThreshold);
    this.m_knockdownDamageThreshold = this.GetHitReactionStatThreshold(gamedataStatType.KnockdownDamageThreshold);
  }

  protected final func SetHitReactionImmunities() -> Void {
    let statsSystem: ref<StatsSystem> = GameInstance.GetStatsSystem(this.GetOwner().GetGame());
    if statsSystem.GetStatValue(Cast(this.GetOwner().GetEntityID()), gamedataStatType.KnockdownImmunity) > 0.00 {
      this.m_immuneToKnockDown = true;
    } else {
      if Equals(GameObject.GetAttitudeTowards(this.GetOwner(), GameInstance.GetPlayerSystem(this.GetOwner().GetGame()).GetLocalPlayerControlledGameObject()), EAIAttitude.AIA_Friendly) {
        this.m_immuneToKnockDown = true;
      };
    };
  }

  protected final func GetHitTimerAvailability() -> Bool {
    let currentTime: Float = this.GetCurrentTime();
    let hitReactionMinDuration: Float = TweakDBInterface.GetFloat(t"GlobalStats.GlobalHitTimer.value", 1.00);
    if currentTime != this.m_previousHitTime && currentTime < this.m_previousHitTime + hitReactionMinDuration {
      return false;
    };
    if currentTime <= this.m_previousHitTime + 0.09 {
      return false;
    };
    return true;
  }

  protected func SetCumulatedDamages(target: wref<GameObject>) -> Void {
    let bodyPartDismemberCumulatedDamages: Float;
    let bodyPartWoundCumulatedDamages: Float;
    let hitReactionZoneIndex: Int32;
    let meleeBaseMaxHitChain: Int32;
    let rangedBaseMaxHitChain: Int32;
    if this.m_previousHitTime + this.m_hitComboReset < this.GetCurrentTime() && NotEquals(this.m_lastHitReactionPlayed, EAILastHitReactionPlayed.Knockdown) {
      meleeBaseMaxHitChain = AITweakParams.GetIntFromTweak(t"AIGeneralSettings", "hitChainBeforeBreakingForMelee");
      rangedBaseMaxHitChain = AITweakParams.GetIntFromTweak(t"AIGeneralSettings", "hitChainBeforeBreakingForRanged");
      this.m_maxHitChainForMelee = RandRange(meleeBaseMaxHitChain, meleeBaseMaxHitChain + 1);
      this.m_maxHitChainForRanged = RandRange(rangedBaseMaxHitChain, rangedBaseMaxHitChain + 1);
      this.m_meleeHitCount = 0;
      this.m_strongMeleeHitCount = 0;
      this.m_cumulatedDamages = 0.00;
      this.m_lastHitReactionPlayed = EAILastHitReactionPlayed.Twitch;
    };
    this.m_overrideHitReactionImpulse = 0.00;
    this.m_overrideHitReactionImpulse = TDB.GetFloat(this.m_attackData.GetAttackDefinition().GetRecord().GetID() + t".overrideHitReactionImpulse");
    this.m_cumulatedPhysicalImpulse += this.GetPhysicalImpulse(this.m_attackData, this.m_hitPosition);
    this.m_cumulatedDamages += this.GetFrameDamage();
    if HitShapeUserDataBase.IsHitReactionZoneLeftArm(this.GetHitShapeUserData()) {
      bodyPartWoundCumulatedDamages = this.m_bodyPartWoundCumulatedDamages[EnumInt(EHitReactionZone.ArmLeft)] + this.GetFrameWoundsDamage();
      this.m_bodyPartWoundCumulatedDamages[EnumInt(EHitReactionZone.ArmLeft)] = bodyPartWoundCumulatedDamages;
      this.m_bodyPartWoundCumulatedDamages[EnumInt(EHitReactionZone.HandLeft)] = bodyPartWoundCumulatedDamages;
      bodyPartDismemberCumulatedDamages = this.m_bodyPartDismemberCumulatedDamages[EnumInt(EHitReactionZone.ArmLeft)] + this.GetFrameDismembermentDamage();
      this.m_bodyPartDismemberCumulatedDamages[EnumInt(EHitReactionZone.ArmLeft)] = bodyPartDismemberCumulatedDamages;
      this.m_bodyPartDismemberCumulatedDamages[EnumInt(EHitReactionZone.HandLeft)] = bodyPartDismemberCumulatedDamages;
    } else {
      if HitShapeUserDataBase.IsHitReactionZoneRightArm(this.GetHitShapeUserData()) {
        bodyPartWoundCumulatedDamages = this.m_bodyPartWoundCumulatedDamages[EnumInt(EHitReactionZone.ArmRight)] + this.GetFrameWoundsDamage();
        this.m_bodyPartWoundCumulatedDamages[EnumInt(EHitReactionZone.ArmRight)] = bodyPartWoundCumulatedDamages;
        this.m_bodyPartWoundCumulatedDamages[EnumInt(EHitReactionZone.HandRight)] = bodyPartWoundCumulatedDamages;
        bodyPartDismemberCumulatedDamages = this.m_bodyPartDismemberCumulatedDamages[EnumInt(EHitReactionZone.ArmRight)] + this.GetFrameDismembermentDamage();
        this.m_bodyPartDismemberCumulatedDamages[EnumInt(EHitReactionZone.ArmRight)] = bodyPartDismemberCumulatedDamages;
        this.m_bodyPartDismemberCumulatedDamages[EnumInt(EHitReactionZone.HandRight)] = bodyPartDismemberCumulatedDamages;
      } else {
        hitReactionZoneIndex = EnumInt(HitShapeUserDataBase.GetHitReactionZone(this.GetHitShapeUserData()));
        bodyPartWoundCumulatedDamages = this.m_bodyPartWoundCumulatedDamages[hitReactionZoneIndex] + this.GetFrameWoundsDamage();
        this.m_bodyPartWoundCumulatedDamages[hitReactionZoneIndex] = bodyPartWoundCumulatedDamages;
        bodyPartDismemberCumulatedDamages = this.m_bodyPartDismemberCumulatedDamages[hitReactionZoneIndex] + this.GetFrameDismembermentDamage();
        this.m_bodyPartDismemberCumulatedDamages[hitReactionZoneIndex] = bodyPartDismemberCumulatedDamages;
      };
    };
    this.ResetFrameDamage();
    this.RequestCumulativeDamageUpdate();
  }

  protected final func SetCumulatedDamagesForDeadNPC() -> Void {
    let bodyPartDismemberCumulatedDamages: Float;
    let bodyPartWoundCumulatedDamages: Float;
    let hitReactionZoneIndex: Int32;
    this.m_overrideHitReactionImpulse = 0.00;
    this.m_overrideHitReactionImpulse = TDB.GetFloat(this.m_attackData.GetAttackDefinition().GetRecord().GetID() + t".overrideHitReactionImpulse");
    this.m_cumulatedPhysicalImpulse += this.GetPhysicalImpulse(this.m_attackData, this.m_hitPosition);
    this.m_cumulatedDamages += this.GetFrameDamage();
    if HitShapeUserDataBase.IsHitReactionZoneLeftArm(this.GetHitShapeUserData()) {
      bodyPartWoundCumulatedDamages = this.m_bodyPartWoundCumulatedDamages[EnumInt(EHitReactionZone.ArmLeft)] + this.GetFrameWoundsDamage();
      this.m_bodyPartWoundCumulatedDamages[EnumInt(EHitReactionZone.ArmLeft)] = bodyPartWoundCumulatedDamages;
      this.m_bodyPartWoundCumulatedDamages[EnumInt(EHitReactionZone.HandLeft)] = bodyPartWoundCumulatedDamages;
      bodyPartDismemberCumulatedDamages = this.m_bodyPartDismemberCumulatedDamages[EnumInt(EHitReactionZone.ArmLeft)] + this.GetFrameDismembermentDamage();
      this.m_bodyPartDismemberCumulatedDamages[EnumInt(EHitReactionZone.ArmLeft)] = bodyPartDismemberCumulatedDamages;
      this.m_bodyPartDismemberCumulatedDamages[EnumInt(EHitReactionZone.HandLeft)] = bodyPartDismemberCumulatedDamages;
    } else {
      if HitShapeUserDataBase.IsHitReactionZoneRightArm(this.GetHitShapeUserData()) {
        bodyPartWoundCumulatedDamages = this.m_bodyPartWoundCumulatedDamages[EnumInt(EHitReactionZone.ArmRight)] + this.GetFrameWoundsDamage();
        this.m_bodyPartWoundCumulatedDamages[EnumInt(EHitReactionZone.ArmRight)] = bodyPartWoundCumulatedDamages;
        this.m_bodyPartWoundCumulatedDamages[EnumInt(EHitReactionZone.HandRight)] = bodyPartWoundCumulatedDamages;
        bodyPartDismemberCumulatedDamages = this.m_bodyPartDismemberCumulatedDamages[EnumInt(EHitReactionZone.ArmRight)] + this.GetFrameDismembermentDamage();
        this.m_bodyPartDismemberCumulatedDamages[EnumInt(EHitReactionZone.ArmRight)] = bodyPartDismemberCumulatedDamages;
        this.m_bodyPartDismemberCumulatedDamages[EnumInt(EHitReactionZone.HandRight)] = bodyPartDismemberCumulatedDamages;
      } else {
        hitReactionZoneIndex = EnumInt(HitShapeUserDataBase.GetHitReactionZone(this.GetHitShapeUserData()));
        bodyPartWoundCumulatedDamages = this.m_bodyPartWoundCumulatedDamages[hitReactionZoneIndex] + this.GetFrameWoundsDamage();
        this.m_bodyPartWoundCumulatedDamages[hitReactionZoneIndex] = bodyPartWoundCumulatedDamages;
        bodyPartDismemberCumulatedDamages = this.m_bodyPartDismemberCumulatedDamages[hitReactionZoneIndex] + this.GetFrameDismembermentDamage();
        this.m_bodyPartDismemberCumulatedDamages[hitReactionZoneIndex] = bodyPartDismemberCumulatedDamages;
      };
    };
    this.ResetFrameDamage();
    this.RequestCumulativeDamageUpdate();
  }

  private final func UpdateCumulatedDamages(deltaTime: Float) -> Bool {
    let requiresUpdate: Bool;
    let valueToDecrese: Float;
    let cumulativeDamagesDecreaser: Float = (this.GetOwnerTotalHealth() * TweakDBInterface.GetFloat(t"GlobalStats.CumulativeDmgDecreaser.value", 2.00)) / 100.00;
    if this.m_previousHitTime + this.m_hitComboReset > this.GetCurrentTime() {
      return false;
    };
    valueToDecrese = cumulativeDamagesDecreaser * deltaTime;
    if this.m_cumulatedDamages > 0.00 {
      this.m_cumulatedDamages -= valueToDecrese;
      this.m_cumulatedDamages = MaxF(this.m_cumulatedDamages, 0.00);
      if this.m_cumulatedDamages > 0.00 {
        requiresUpdate = true;
      };
    };
    return requiresUpdate;
  }

  protected final func GetBodyPart(hitEvent: ref<gameHitEvent>) -> Bool {
    let empty: HitShapeData;
    this.m_hitShapeData = empty;
    if ArraySize(hitEvent.hitRepresentationResult.hitShapes) > 0 {
      this.m_hitShapeData = hitEvent.hitRepresentationResult.hitShapes[0];
    };
    return NotEquals(this.m_hitShapeData, empty);
  }

  protected final func CheckInstantDismembermentOnDeath() -> Bool {
    if NotEquals(this.m_reactionType, animHitReactionType.Death) && NotEquals(this.m_reactionType, animHitReactionType.Pain) && NotEquals(this.m_reactionType, animHitReactionType.Ragdoll) && this.m_isAlive {
      return false;
    };
    if this.m_attackData.DoesAttackWeaponHaveTag(n"ForceDismember") {
      return true;
    };
    if AttackData.IsDismembermentCause(this.m_attackData.GetAttackType()) {
      return true;
    };
    return false;
  }

  protected final func GetDismembermentWoundType() -> gameDismWoundType {
    let weapon: ref<WeaponObject> = ScriptedPuppet.GetWeaponRight(this.m_attackData.GetSource());
    let weaponType: gamedataItemType = TweakDBInterface.GetWeaponItemRecord(ItemID.GetTDBID(weapon.GetItemID())).ItemType().Type();
    if Equals(weaponType, gamedataItemType.Cyb_NanoWires) || Equals(weaponType, gamedataItemType.Cyb_MantisBlades) || Equals(weaponType, gamedataItemType.Wea_Katana) || Equals(weaponType, gamedataItemType.Wea_ShortBlade) || Equals(weaponType, gamedataItemType.Wea_LongBlade) {
      return gameDismWoundType.CLEAN;
    };
    if (Equals(HitShapeUserDataBase.GetDismembermentBodyPart(this.GetHitShapeUserData()), gameDismBodyPart.BODY) || HitShapeUserDataBase.IsHitReactionZoneHead(this.GetHitShapeUserData()) && this.m_bodyPartDismemberCumulatedDamages[EnumInt(HitShapeUserDataBase.GetHitReactionZone(this.GetHitShapeUserData()))] < this.GetOwnerTotalHealth() * 2.00) && !this.GetOwnerPuppet().IsAndroid() {
      return gameDismWoundType.HOLE;
    };
    return gameDismWoundType.COARSE;
  }

  protected final func ProcessDefeated(npc: ref<NPCPuppet>) -> Bool {
    if !npc.IsAboutToBeDefeated() && !StatusEffectSystem.ObjectHasStatusEffectWithTag(npc, n"Defeated") && !npc.IsAboutToDie() {
      return false;
    };
    if !this.CanDieCondition() {
      return false;
    };
    if this.DefeatedRemoveConditions(npc) {
      this.GetOwner().Record1DamageInHistory(this.m_attackData.GetInstigator());
      npc.Kill(this.m_attackData.GetInstigator());
      this.m_reactionType = animHitReactionType.Death;
      this.m_isAlive = false;
      return true;
    };
    AnimationControllerComponent.PushEventToReplicate(this.GetOwner(), n"e3_2019_boss_defeated_face");
    return false;
  }

  public final func UpdateDefeated() -> Void {
    if !this.m_defeatedHasBeenPlayed {
      this.m_defeatedHasBeenPlayed = true;
      this.m_specificHitTimeout = this.GetCurrentTime() + this.m_defeatedMinDuration;
    };
  }

  protected final func DefeatedRemoveConditions(npc: ref<NPCPuppet>) -> Bool {
    if npc.IsAboutToDie() {
      return true;
    };
    if ScriptedPuppet.IsOnOffMeshLink(npc) {
      return true;
    };
    if GameInstance.GetWorkspotSystem(this.GetOwner().GetGame()).IsActorInWorkspot(this.GetOwner()) && AICoverHelper.GetCurrentCover(npc) == 0u {
      return true;
    };
    if this.m_attackData.HasFlag(hitFlag.QuickHack) {
      if this.CheckBrainMeltDeath() {
        return true;
      };
    };
    if VehicleComponent.IsMountedToVehicle(this.GetOwner().GetGame(), npc) {
      return true;
    };
    if this.m_specificHitTimeout > this.GetCurrentTime() && Equals(this.m_lastHitReactionPlayed, EAILastHitReactionPlayed.Knockdown) {
      return true;
    };
    if this.m_attackData.HasFlag(hitFlag.VehicleDamage) {
      return true;
    };
    if AttackData.IsExplosion(this.m_attackData.GetAttackType()) {
      return true;
    };
    if this.m_defeatedBodyPartDamageThreshold[EnumInt(HitShapeUserDataBase.GetHitReactionZone(this.GetHitShapeUserData()))] < 0.00 {
      return true;
    };
    if (this.m_attackData.DoesAttackWeaponHaveTag(n"ForceDismember") || this.m_attackData.DoesAttackWeaponHaveTag(n"HeavyWeapon") || this.GetFrameDamage() > this.m_defeatedBodyPartDamageThreshold[EnumInt(HitShapeUserDataBase.GetHitReactionZone(this.GetHitShapeUserData()))] || this.CheckInstantDismembermentOnDeath()) && (!HitShapeUserDataBase.IsHitReactionZoneLimb(this.GetHitShapeUserData()) || this.m_attackData.DoesAttackWeaponHaveTag(n"HeavyWeapon")) && !this.m_defeatedHasBeenPlayed {
      return true;
    };
    if this.GetCurrentTime() > this.m_specificHitTimeout && this.m_defeatedHasBeenPlayed {
      return true;
    };
    this.UpdateDefeated();
    return false;
  }

  private final func CheckBrainMeltDeath() -> Bool {
    let attackRecord: ref<Attack_GameEffect_Record> = this.m_attackData.GetAttackDefinition().GetRecord() as Attack_GameEffect_Record;
    let hitFlags: array<String> = attackRecord.HitFlags();
    if ArrayContains(hitFlags, "BrainMeltSkipDefeated") {
      return true;
    };
    return false;
  }

  protected final func ProcessDropWeaponOnHit(owner: ref<GameObject>, hitBodyPart: EHitReactionZone, hitReaction: animHitReactionType) -> Void {
    let itemInSlotID: ItemID;
    let slotID: TweakDBID;
    if GameInstance.GetStatsSystem(owner.GetGame()).GetStatValue(Cast(owner.GetEntityID()), gamedataStatType.CanDropWeapon) == 0.00 {
      return;
    };
    if Equals(hitReaction, animHitReactionType.Impact) || Equals(hitReaction, animHitReactionType.Twitch) {
      return;
    };
    switch hitBodyPart {
      case EHitReactionZone.HandRight:
        slotID = t"AttachmentSlots.WeaponRight";
        break;
      case EHitReactionZone.HandLeft:
        slotID = t"AttachmentSlots.WeaponLeft";
        break;
      default:
        return;
    };
    if TDBID.IsValid(slotID) {
      itemInSlotID = GameInstance.GetTransactionSystem(owner.GetGame()).GetItemInSlot(owner, slotID).GetItemData().GetID();
      if NotEquals(RPGManager.GetItemType(itemInSlotID), gamedataItemType.Wea_Fists) {
        ScriptedPuppet.DropWeaponFromSlot(owner, slotID);
      };
    };
  }

  protected final func ProcessExtendedDeathAnimData(hitEvent: ref<gameHitEvent>) -> Void {
    if HitShapeUserDataBase.IsHitReactionZoneRightLeg(this.GetHitShapeUserData()) || HitShapeUserDataBase.IsHitReactionZoneLeftLeg(this.GetHitShapeUserData()) {
      DismembermentComponent.RequestDismemberment(this.GetOwner(), HitShapeUserDataBase.GetDismembermentBodyPart(this.GetHitShapeUserData()), gameDismWoundType.COARSE, this.m_hitShapeData.result.hitPositionEnter);
      this.m_hitIntensity = EAIHitIntensity.Heavy;
    } else {
      if this.m_bodyPartDismemberCumulatedDamages[EnumInt(HitShapeUserDataBase.GetHitReactionZone(this.GetHitShapeUserData()))] >= this.GetOwnerTotalHealth() * 0.30 {
        DismembermentComponent.RequestDismemberment(this.GetOwner(), HitShapeUserDataBase.GetDismembermentBodyPart(this.GetHitShapeUserData()), gameDismWoundType.COARSE, this.m_hitShapeData.result.hitPositionEnter);
      };
      this.m_hitIntensity = EAIHitIntensity.Light;
    };
    if this.m_animVariation <= 12 {
      this.m_animVariation += 1;
    } else {
      this.m_animVariation = 13;
    };
  }

  protected final func ProcessExtendedHitReactionAnimData(hitEvent: ref<gameHitEvent>) -> Void {
    if HitShapeUserDataBase.IsHitReactionZoneRightLeg(this.GetHitShapeUserData()) || HitShapeUserDataBase.IsHitReactionZoneLeftLeg(this.GetHitShapeUserData()) {
      this.m_reactionType = animHitReactionType.Stagger;
      this.m_extendedHitReactionDelayRegisteredTime = this.GetCurrentTime() + 1.80;
      this.m_comboResetTime = this.GetCurrentTime() + 1.80;
      this.m_lastHitReactionPlayed = EAILastHitReactionPlayed.Stagger;
    } else {
      this.m_reactionType = animHitReactionType.Impact;
      this.m_hitIntensity = EAIHitIntensity.Light;
      this.m_lastHitReactionPlayed = EAILastHitReactionPlayed.Impact;
    };
    if this.m_animVariation < 4 {
      this.m_animVariation += 1;
    } else {
      this.m_animVariation = 0;
    };
  }

  protected final func ProcessWoundsAndDismemberment() -> Void {
    let broadcaster: ref<StimBroadcasterComponent>;
    let hitReactionZone: EHitReactionZone;
    if this.m_deathHasBeenPlayed && this.m_deathRegisteredTime + this.m_disableDismembermentAfterDeathDelay <= this.GetCurrentTime() {
      return;
    };
    if !this.CanDieCondition() {
      return;
    };
    if this.m_attackData.HasFlag(hitFlag.FragmentationSplinter) {
      this.ProcessFragmentationSplinterReaction(this.m_hitShapeData.result.hitPositionEnter);
      return;
    };
    if AttackData.IsExplosion(this.m_attackData.GetAttackType()) {
      this.ProcessExplosionDismembement();
      return;
    };
    if Equals(this.m_attackData.GetAttackType(), gamedataAttackType.QuickMelee) {
      return;
    };
    hitReactionZone = HitShapeUserDataBase.GetHitReactionZone(this.GetHitShapeUserData());
    if HitShapeUserDataBase.IsHitReactionZoneHead(this.GetHitShapeUserData()) || HitShapeUserDataBase.IsHitReactionZoneTorso(this.GetHitShapeUserData()) {
      if this.WoundedFleshConditions() {
      } else {
        if this.WoundedCyberConditions() {
          DismembermentComponent.RequestDismemberment(this.GetOwner(), HitShapeUserDataBase.GetDismembermentBodyPart(this.GetHitShapeUserData()), this.GetDismembermentWoundType(), this.m_hitShapeData.result.hitPositionEnter);
          this.NotifyAboutDismembermentInstigated(this.m_attackData.GetInstigator(), hitReactionZone);
          this.m_bodyPartWoundCumulatedDamages[EnumInt(hitReactionZone)] = 0.00;
          this.m_reactionType = animHitReactionType.Stagger;
          StatusEffectHelper.ApplyStatusEffect(this.GetOwner(), t"BaseStatusEffect.AndroidHeadRemovedBlind");
        } else {
          if this.DismembermentConditions() {
            if Equals(HitShapeUserDataBase.GetDismembermentBodyPart(this.GetHitShapeUserData()), gameDismBodyPart.BODY) && !this.m_scatteredGuts {
              DismembermentComponent.RequestDismemberment(this.GetOwner(), HitShapeUserDataBase.GetDismembermentBodyPart(this.GetHitShapeUserData()), this.GetDismembermentWoundType(), this.m_hitShapeData.result.hitPositionEnter, false, "base\\characters\\common\\dismemberment\\man_big\\cut_parts\\gore\\ragdolls_hole_abdomen.dismdebris", 0.75);
              this.m_scatteredGuts = true;
            } else {
              DismembermentComponent.RequestDismemberment(this.GetOwner(), HitShapeUserDataBase.GetDismembermentBodyPart(this.GetHitShapeUserData()), this.GetDismembermentWoundType(), this.m_hitShapeData.result.hitPositionEnter);
            };
            this.NotifyAboutDismembermentInstigated(this.m_attackData.GetInstigator(), hitReactionZone);
            this.GetOwnerPuppet().Kill(this.m_attackData.GetInstigator());
            this.m_reactionType = animHitReactionType.Death;
            this.m_isAlive = false;
            this.m_hitIntensity = EAIHitIntensity.Medium;
          };
        };
      };
    } else {
      if this.WoundedFleshConditions() {
        broadcaster = this.GetOwner().GetStimBroadcasterComponent();
        if IsDefined(broadcaster) {
          broadcaster.TriggerSingleBroadcast(this.GetOwner(), gamedataStimType.Attention);
        };
        this.m_bodyPartWoundCumulatedDamages[EnumInt(hitReactionZone)] = 0.00;
        StatusEffectHelper.ApplyStatusEffect(this.GetOwner(), TDBID.Create("BaseStatusEffect.Crippled" + EnumValueToString("EHitReactionZone", Cast(EnumInt(hitReactionZone)))));
        this.m_specificHitTimeout = this.GetCurrentTime() + this.m_staggerDamageDuration;
        this.NotifyAboutWoundedInstigated(this.m_attackData.GetInstigator(), hitReactionZone);
        GameObject.PlayVoiceOver(this.GetOwnerPuppet(), EnumValueToName(n"EBarkList", Cast(EnumInt(this.ReactionZoneEnumToBarkListEnum(hitReactionZone)))), n"Scripts:ProcessWoundsAndDismemberment");
        this.m_reactionType = animHitReactionType.Pain;
        this.m_hasBeenWounded = true;
      } else {
        if this.WoundedCyberConditions() {
          DismembermentComponent.RequestDismemberment(this.GetOwner(), HitShapeUserDataBase.GetDismembermentBodyPart(this.GetHitShapeUserData()), this.GetDismembermentWoundType(), this.m_hitShapeData.result.hitPositionEnter);
          this.NotifyAboutDismembermentInstigated(this.m_attackData.GetInstigator(), hitReactionZone);
          this.m_bodyPartWoundCumulatedDamages[EnumInt(hitReactionZone)] = 0.00;
          StatusEffectHelper.ApplyStatusEffect(this.GetOwner(), TDBID.Create("BaseStatusEffect.Dismembered" + EnumValueToString("EHitReactionZone", Cast(EnumInt(hitReactionZone)))));
          this.m_specificHitTimeout = this.GetCurrentTime() + this.m_staggerDamageDuration;
          GameObject.PlayVoiceOver(this.GetOwnerPuppet(), EnumValueToName(n"EBarkList", Cast(EnumInt(this.ReactionZoneEnumToBarkListEnum(hitReactionZone)))), n"Scripts:ProcessWoundsAndDismemberment");
          this.m_reactionType = animHitReactionType.Pain;
          this.m_hasBeenWounded = true;
        } else {
          if this.DismembermentConditions() {
            DismembermentComponent.RequestDismemberment(this.GetOwner(), HitShapeUserDataBase.GetDismembermentBodyPart(this.GetHitShapeUserData()), this.GetDismembermentWoundType(), this.m_hitShapeData.result.hitPositionEnter);
            this.NotifyAboutDismembermentInstigated(this.m_attackData.GetInstigator(), hitReactionZone);
            this.GetOwnerPuppet().Kill(this.m_attackData.GetInstigator());
            this.m_reactionType = animHitReactionType.Death;
            this.m_isAlive = false;
            this.m_hitIntensity = EAIHitIntensity.Medium;
          };
        };
      };
    };
  }

  protected final func ReactionZoneEnumToBarkListEnum(reactionZone: EHitReactionZone) -> EBarkList {
    switch reactionZone {
      case EHitReactionZone.Head:
        return EBarkList.vo_enemy_reaction_crippled_arm;
      case EHitReactionZone.ChestLeft:
        return EBarkList.vo_enemy_reaction_crippled_arm;
      case EHitReactionZone.ArmLeft:
        return EBarkList.vo_enemy_reaction_crippled_arm;
      case EHitReactionZone.HandLeft:
        return EBarkList.vo_enemy_reaction_crippled_arm;
      case EHitReactionZone.ChestRight:
        return EBarkList.vo_enemy_reaction_crippled_arm;
      case EHitReactionZone.ArmRight:
        return EBarkList.vo_enemy_reaction_crippled_arm;
      case EHitReactionZone.HandRight:
        return EBarkList.vo_enemy_reaction_crippled_arm;
      case EHitReactionZone.Abdomen:
        return EBarkList.vo_enemy_reaction_crippled_arm;
      case EHitReactionZone.LegLeft:
        return EBarkList.vo_enemy_reaction_crippled_leg;
      case EHitReactionZone.LegRight:
        return EBarkList.vo_enemy_reaction_crippled_leg;
    };
  }

  protected final func ReactionZoneEnumToBodyPartID(reactionZone: EHitReactionZone) -> Int32 {
    switch reactionZone {
      case EHitReactionZone.Head:
        return 1;
      case EHitReactionZone.ChestLeft:
        return 2;
      case EHitReactionZone.ArmLeft:
        return 2;
      case EHitReactionZone.HandLeft:
        return 2;
      case EHitReactionZone.ChestRight:
        return 3;
      case EHitReactionZone.ArmRight:
        return 3;
      case EHitReactionZone.HandRight:
        return 3;
      case EHitReactionZone.Abdomen:
        return 4;
      case EHitReactionZone.LegLeft:
        return 5;
      case EHitReactionZone.LegRight:
        return 6;
    };
  }

  protected final func WoundedBaseConditions() -> Bool {
    let reactionZoneIndex: Int32;
    if this.m_cumulatedPhysicalImpulse >= this.m_knockdownImpulseThreshold && this.m_cumulatedDamages >= this.m_knockdownDamageThreshold && this.m_knockdownDamageThreshold > 0.00 && this.m_knockdownImpulseThreshold > 0.00 && !this.CheckInstantDismembermentOnDeath() {
      return false;
    };
    reactionZoneIndex = EnumInt(HitShapeUserDataBase.GetHitReactionZone(this.GetHitShapeUserData()));
    if this.m_bodyPartWoundCumulatedDamages[reactionZoneIndex] < this.m_woundedBodyPartDamageThreshold[reactionZoneIndex] && this.m_bodyPartDismemberCumulatedDamages[reactionZoneIndex] < this.m_dismembermentBodyPartDamageThreshold[reactionZoneIndex] && !this.CheckInstantDismembermentOnDeath() {
      return false;
    };
    return true;
  }

  protected final func WoundedFleshConditions() -> Bool {
    let itemInHand: ref<ItemObject>;
    let itemInRecord: ref<NPCEquipmentItem_Record>;
    let primaryWeaponID: ItemID;
    let reactionZoneIndex: Int32 = EnumInt(HitShapeUserDataBase.GetHitReactionZone(this.GetHitShapeUserData()));
    if this.m_woundedBodyPartDamageThreshold[reactionZoneIndex] <= 0.00 {
      return false;
    };
    if !ScriptedPuppet.IsAlive(this.GetOwner()) {
      return false;
    };
    if (this.GetOwner() as ScriptedPuppet).IsMassive() {
      return false;
    };
    itemInRecord = TweakDBInterface.GetCharacterRecord(this.GetOwnerNPC().GetRecordID()).PrimaryEquipment().GetEquipmentItemsItem(0) as NPCEquipmentItem_Record;
    AIActionTransactionSystem.GetItemID(this.GetOwner() as ScriptedPuppet, itemInRecord.Item(), itemInRecord.OnBodySlot().GetID(), primaryWeaponID);
    if WeaponObject.IsMelee(primaryWeaponID) {
      return false;
    };
    itemInHand = GameInstance.GetTransactionSystem(this.GetOwner().GetGame()).GetItemInSlot(this.GetOwner(), t"AttachmentSlots.WeaponRight");
    if WeaponObject.IsMelee(itemInHand.GetItemID()) {
      return false;
    };
    if this.m_bodyPartWoundCumulatedDamages[reactionZoneIndex] >= this.m_woundedBodyPartDamageThreshold[reactionZoneIndex] && this.m_woundedBodyPartDamageThreshold[reactionZoneIndex] > 0.00 && this.WoundedBaseConditions() && !this.DismembermentConditions() && !AttackData.IsLightMelee(this.m_attackData.GetAttackType()) && !AttackData.IsStrongMelee(this.m_attackData.GetAttackType()) && !StatusEffectSystem.ObjectHasStatusEffectOfType(this.GetOwner(), gamedataStatusEffectType.Wounded) && NotEquals(this.m_reactionType, animHitReactionType.Death) && NotEquals(this.m_reactionType, animHitReactionType.Pain) && NotEquals(this.m_reactionType, animHitReactionType.Ragdoll) && !ScriptedPuppet.IsDefeated(this.GetOwner()) && !this.GetOwnerNPC().IsAboutToBeDefeated() && Equals(this.GetHitShapeUserData().GetShapeType(), EHitShapeType.Flesh) && !this.m_hasBeenWounded {
      return true;
    };
    return false;
  }

  protected final func WoundedCyberConditions() -> Bool {
    let itemInRecord: ref<NPCEquipmentItem_Record>;
    let primaryWeaponID: ItemID;
    let reactionZoneIndex: Int32 = EnumInt(HitShapeUserDataBase.GetHitReactionZone(this.GetHitShapeUserData()));
    if this.m_woundedBodyPartDamageThreshold[reactionZoneIndex] <= 0.00 {
      return false;
    };
    if !ScriptedPuppet.IsAlive(this.GetOwner()) {
      return false;
    };
    if (this.GetOwner() as ScriptedPuppet).IsMassive() {
      return false;
    };
    itemInRecord = TweakDBInterface.GetCharacterRecord(this.GetOwnerNPC().GetRecordID()).PrimaryEquipment().GetEquipmentItemsItem(0) as NPCEquipmentItem_Record;
    AIActionTransactionSystem.GetItemID(this.GetOwner() as ScriptedPuppet, itemInRecord.Item(), itemInRecord.OnBodySlot().GetID(), primaryWeaponID);
    if Equals(TweakDBInterface.GetWeaponItemRecord(ItemID.GetTDBID(primaryWeaponID)).ItemType().Type(), gamedataItemType.Cyb_MantisBlades) {
      return false;
    };
    if Equals(TweakDBInterface.GetWeaponItemRecord(ItemID.GetTDBID(ScriptedPuppet.GetWeaponRight(this.GetOwner()).GetItemID())).ItemType().Type(), gamedataItemType.Cyb_MantisBlades) {
      return false;
    };
    if this.m_bodyPartWoundCumulatedDamages[reactionZoneIndex] >= this.m_woundedBodyPartDamageThreshold[reactionZoneIndex] && this.m_woundedBodyPartDamageThreshold[reactionZoneIndex] > 0.00 && this.WoundedBaseConditions() && !this.DismembermentConditions() && !AttackData.IsLightMelee(this.m_attackData.GetAttackType()) && !AttackData.IsStrongMelee(this.m_attackData.GetAttackType()) && (!StatusEffectSystem.ObjectHasStatusEffectOfType(this.GetOwner(), gamedataStatusEffectType.Wounded) || HitShapeUserDataBase.IsHitReactionZoneHead(this.GetHitShapeUserData())) && NotEquals(this.m_reactionType, animHitReactionType.Death) && NotEquals(this.m_reactionType, animHitReactionType.Pain) && NotEquals(this.m_reactionType, animHitReactionType.Ragdoll) && !ScriptedPuppet.IsDefeated(this.GetOwner()) && !this.GetOwnerNPC().IsAboutToBeDefeated() && (Equals(this.GetHitShapeUserData().GetShapeType(), EHitShapeType.Metal) || Equals(this.GetHitShapeUserData().GetShapeType(), EHitShapeType.Cyberware)) {
      return true;
    };
    return false;
  }

  protected final func CanDieCondition(opt doNotCheckAttackData: Bool) -> Bool {
    if IsDefined(this.m_attackData) && !doNotCheckAttackData {
      if this.GetOwnerNPC().IsDefeatMechanicActive() && this.m_attackData.HasFlag(hitFlag.Nonlethal) {
        return false;
      };
      if StatusEffectSystem.ObjectHasStatusEffect(this.m_attackData.GetInstigator(), t"GameplayRestriction.FistFight") {
        return false;
      };
    };
    if this.GetOwnerNPC().IsBoss() && !ScriptedPuppet.IsDefeated(this.GetOwner()) {
      return false;
    };
    if StatusEffectSystem.ObjectHasStatusEffect(this.GetOwnerNPC(), t"GameplayRestriction.FistFight") {
      return false;
    };
    if GameInstance.GetGodModeSystem(this.GetOwner().GetGame()).HasGodMode(this.GetOwner().GetEntityID(), gameGodModeType.Immortal) {
      return false;
    };
    if GameInstance.GetGodModeSystem(this.GetOwner().GetGame()).HasGodMode(this.GetOwner().GetEntityID(), gameGodModeType.Invulnerable) {
      return false;
    };
    if GameInstance.GetStatsSystem(this.GetOwner().GetGame()).GetStatValue(Cast(this.GetOwner().GetEntityID()), gamedataStatType.IsInvulnerable) > 0.00 {
      return false;
    };
    return true;
  }

  protected final func DismembermentConditions() -> Bool {
    let reactionZoneIndex: Int32 = EnumInt(HitShapeUserDataBase.GetHitReactionZone(this.GetHitShapeUserData()));
    if ScriptedPuppet.IsAlive(this.GetOwner()) && !this.GetOwnerNPC().IsAboutToDie() && !this.GetOwnerNPC().IsAboutToBeDefeated() && !ScriptedPuppet.IsDefeated(this.GetOwner()) {
      return false;
    };
    if HitShapeUserDataBase.IsHitReactionZoneTorso(this.GetHitShapeUserData()) && AttackData.IsMelee(this.m_attackData.GetAttackType()) {
      return false;
    };
    if this.CheckInstantDismembermentOnDeath() {
      return true;
    };
    if this.m_dismembermentBodyPartDamageThreshold[reactionZoneIndex] < 0.00 {
      return false;
    };
    if this.m_bodyPartDismemberCumulatedDamages[reactionZoneIndex] >= this.m_dismembermentBodyPartDamageThreshold[reactionZoneIndex] && this.m_dismembermentBodyPartDamageThreshold[reactionZoneIndex] > 0.00 {
      return true;
    };
    return false;
  }

  protected final func ProcessFragmentationSplinterReaction(hitPosition: Vector4) -> Void {
    let broadcaster: ref<StimBroadcasterComponent>;
    let statPoolSystem: ref<StatPoolsSystem> = GameInstance.GetStatPoolsSystem(this.GetOwner().GetGame());
    let currentHP: Float = statPoolSystem.GetStatPoolValue(Cast(this.GetOwner().GetEntityID()), gamedataStatPoolType.Health, true);
    if currentHP > 30.00 {
      return;
    };
    if RandF() > 0.40 {
      if this.GetOwnerNPC().WasJustKilledOrDefeated() {
        this.SendDismembermentCriticalEvent(gameDismWoundType.COARSE, gameDismBodyPart.LEFT_LEG, this.m_attackData.GetSource().GetWorldPosition(), RandRangeF(50.00, 75.00), this.m_hitShapeData.result.hitPositionEnter);
      } else {
        StatusEffectHelper.ApplyStatusEffect(this.GetOwner(), t"BaseStatusEffect.CrippledLegLeft");
        this.m_specificHitTimeout = this.GetCurrentTime() + this.m_staggerDamageDuration;
      };
    } else {
      if RandF() > 0.40 {
        if this.GetOwnerNPC().WasJustKilledOrDefeated() {
          this.SendDismembermentCriticalEvent(gameDismWoundType.COARSE, gameDismBodyPart.RIGHT_LEG, this.m_attackData.GetSource().GetWorldPosition(), RandRangeF(50.00, 75.00), this.m_hitShapeData.result.hitPositionEnter);
        } else {
          StatusEffectHelper.ApplyStatusEffect(this.GetOwner(), t"BaseStatusEffect.CrippledLegRight");
          this.m_specificHitTimeout = this.GetCurrentTime() + this.m_staggerDamageDuration;
        };
      };
    };
    GameObject.PlayVoiceOver(this.GetOwnerPuppet(), EnumValueToName(n"EBarkList", Cast(EnumInt(this.ReactionZoneEnumToBarkListEnum(HitShapeUserDataBase.GetHitReactionZone(this.GetHitShapeUserData()))))), n"Scripts:ProcessFragmentationSplinterReaction");
    broadcaster = this.GetOwner().GetStimBroadcasterComponent();
    if IsDefined(broadcaster) {
      broadcaster.TriggerSingleBroadcast(this.GetOwner(), gamedataStimType.Scream);
    };
  }

  protected final func ProcessExplosionDismembement() -> Void {
    let explosionCentrum: Vector4;
    let randomPreset: Int32;
    let strengthMin: Float = 50.00;
    let strengthMax: Float = 75.00;
    if Equals(this.m_reactionType, animHitReactionType.Death) || Equals(this.m_reactionType, animHitReactionType.Pain) || Equals(this.m_reactionType, animHitReactionType.Ragdoll) {
      explosionCentrum = this.m_attackData.GetSource().GetWorldPosition();
      if Vector4.Distance(this.GetOwnerPuppet().GetWorldPosition(), explosionCentrum) <= 1.70 && !this.m_isAlive {
        randomPreset = RandRange(1, 9);
        switch randomPreset {
          case 1:
            this.SendDismembermentCriticalEvent(gameDismWoundType.COARSE, gameDismBodyPart.BODY, explosionCentrum, RandRangeF(strengthMin, strengthMax), this.m_hitShapeData.result.hitPositionEnter);
            break;
          case 2:
            this.SendDismembermentCriticalEvent(gameDismWoundType.COARSE, gameDismBodyPart.BODY, explosionCentrum, RandRangeF(strengthMin, strengthMax), this.m_hitShapeData.result.hitPositionEnter);
            DismembermentComponent.RequestDismemberment(this.GetOwner(), gameDismBodyPart.LEFT_ARM, gameDismWoundType.COARSE, this.m_hitShapeData.result.hitPositionEnter, true);
            break;
          case 3:
            this.SendDismembermentCriticalEvent(gameDismWoundType.COARSE, gameDismBodyPart.BODY, explosionCentrum, RandRangeF(strengthMin, strengthMax), this.m_hitShapeData.result.hitPositionEnter);
            DismembermentComponent.RequestDismemberment(this.GetOwner(), gameDismBodyPart.RIGHT_ARM, gameDismWoundType.COARSE, this.m_hitShapeData.result.hitPositionEnter, true);
            break;
          case 4:
            this.SendDismembermentCriticalEvent(gameDismWoundType.COARSE, gameDismBodyPart.BODY, explosionCentrum, RandRangeF(strengthMin, strengthMax), this.m_hitShapeData.result.hitPositionEnter);
            DismembermentComponent.RequestDismemberment(this.GetOwner(), gameDismBodyPart.LEFT_ARM, gameDismWoundType.COARSE, this.m_hitShapeData.result.hitPositionEnter);
            DismembermentComponent.RequestDismemberment(this.GetOwner(), gameDismBodyPart.RIGHT_ARM, gameDismWoundType.COARSE, this.m_hitShapeData.result.hitPositionEnter, true);
            break;
          case 5:
            this.SendDismembermentCriticalEvent(gameDismWoundType.COARSE, gameDismBodyPart.BODY, explosionCentrum, RandRangeF(strengthMin, strengthMax), this.m_hitShapeData.result.hitPositionEnter);
            DismembermentComponent.RequestDismemberment(this.GetOwner(), gameDismBodyPart.LEFT_ARM, gameDismWoundType.COARSE, this.m_hitShapeData.result.hitPositionEnter, true);
            DismembermentComponent.RequestDismemberment(this.GetOwner(), gameDismBodyPart.RIGHT_ARM, gameDismWoundType.COARSE, this.m_hitShapeData.result.hitPositionEnter);
            DismembermentComponent.RequestDismemberment(this.GetOwner(), gameDismBodyPart.HEAD, gameDismWoundType.HOLE, this.m_hitShapeData.result.hitPositionEnter);
            break;
          case 6:
            this.SendDismembermentCriticalEvent(gameDismWoundType.COARSE, gameDismBodyPart.BODY, explosionCentrum, RandRangeF(strengthMin, strengthMax), this.m_hitShapeData.result.hitPositionEnter);
            DismembermentComponent.RequestDismemberment(this.GetOwner(), gameDismBodyPart.LEFT_ARM, gameDismWoundType.COARSE, this.m_hitShapeData.result.hitPositionEnter, true);
            DismembermentComponent.RequestDismemberment(this.GetOwner(), gameDismBodyPart.RIGHT_ARM, gameDismWoundType.COARSE, this.m_hitShapeData.result.hitPositionEnter, true);
            DismembermentComponent.RequestDismemberment(this.GetOwner(), gameDismBodyPart.HEAD, gameDismWoundType.HOLE, this.m_hitShapeData.result.hitPositionEnter);
            break;
          case 7:
            this.SendDismembermentCriticalEvent(gameDismWoundType.COARSE, gameDismBodyPart.BODY, explosionCentrum, RandRangeF(strengthMin, strengthMax), this.m_hitShapeData.result.hitPositionEnter);
            DismembermentComponent.RequestDismemberment(this.GetOwner(), gameDismBodyPart.LEFT_ARM, gameDismWoundType.COARSE, this.m_hitShapeData.result.hitPositionEnter, true);
            DismembermentComponent.RequestDismemberment(this.GetOwner(), gameDismBodyPart.RIGHT_ARM, gameDismWoundType.COARSE, this.m_hitShapeData.result.hitPositionEnter, true);
            DismembermentComponent.RequestDismemberment(this.GetOwner(), gameDismBodyPart.HEAD, gameDismWoundType.COARSE, this.m_hitShapeData.result.hitPositionEnter);
            break;
          case 8:
            this.SendDismembermentCriticalEvent(gameDismWoundType.COARSE, gameDismBodyPart.BODY, explosionCentrum, RandRangeF(strengthMin, strengthMax), this.m_hitShapeData.result.hitPositionEnter);
            DismembermentComponent.RequestDismemberment(this.GetOwner(), gameDismBodyPart.LEFT_ARM, gameDismWoundType.COARSE, this.m_hitShapeData.result.hitPositionEnter);
            DismembermentComponent.RequestDismemberment(this.GetOwner(), gameDismBodyPart.RIGHT_ARM, gameDismWoundType.COARSE, this.m_hitShapeData.result.hitPositionEnter);
            DismembermentComponent.RequestDismemberment(this.GetOwner(), gameDismBodyPart.HEAD, gameDismWoundType.HOLE, this.m_hitShapeData.result.hitPositionEnter);
            break;
          default:
            return;
        };
      } else {
        randomPreset = RandRange(1, 7);
        switch randomPreset {
          case 1:
            DismembermentComponent.RequestDismemberment(this.GetOwner(), gameDismBodyPart.HEAD, gameDismWoundType.COARSE, this.m_hitShapeData.result.hitPositionEnter);
            DismembermentComponent.RequestDismemberment(this.GetOwner(), gameDismBodyPart.BODY, gameDismWoundType.HOLE, this.m_hitShapeData.result.hitPositionEnter);
            DismembermentComponent.RequestDismemberment(this.GetOwner(), gameDismBodyPart.LEFT_ARM, gameDismWoundType.COARSE, this.m_hitShapeData.result.hitPositionEnter);
            DismembermentComponent.RequestDismemberment(this.GetOwner(), gameDismBodyPart.RIGHT_ARM, gameDismWoundType.COARSE, this.m_hitShapeData.result.hitPositionEnter);
            break;
          case 2:
            DismembermentComponent.RequestDismemberment(this.GetOwner(), gameDismBodyPart.HEAD, gameDismWoundType.COARSE, this.m_hitShapeData.result.hitPositionEnter);
            DismembermentComponent.RequestDismemberment(this.GetOwner(), gameDismBodyPart.BODY, gameDismWoundType.HOLE, this.m_hitShapeData.result.hitPositionEnter);
            DismembermentComponent.RequestDismemberment(this.GetOwner(), gameDismBodyPart.LEFT_ARM, gameDismWoundType.COARSE, this.m_hitShapeData.result.hitPositionEnter);
            break;
          case 3:
            DismembermentComponent.RequestDismemberment(this.GetOwner(), gameDismBodyPart.HEAD, gameDismWoundType.COARSE, this.m_hitShapeData.result.hitPositionEnter);
            DismembermentComponent.RequestDismemberment(this.GetOwner(), gameDismBodyPart.BODY, gameDismWoundType.HOLE, this.m_hitShapeData.result.hitPositionEnter);
            DismembermentComponent.RequestDismemberment(this.GetOwner(), gameDismBodyPart.RIGHT_ARM, gameDismWoundType.COARSE, this.m_hitShapeData.result.hitPositionEnter);
            break;
          case 4:
            DismembermentComponent.RequestDismemberment(this.GetOwner(), gameDismBodyPart.LEFT_LEG, gameDismWoundType.COARSE, this.m_hitShapeData.result.hitPositionEnter);
            DismembermentComponent.RequestDismemberment(this.GetOwner(), gameDismBodyPart.LEFT_ARM, gameDismWoundType.COARSE, this.m_hitShapeData.result.hitPositionEnter);
            break;
          case 5:
            DismembermentComponent.RequestDismemberment(this.GetOwner(), gameDismBodyPart.HEAD, gameDismWoundType.HOLE, this.m_hitShapeData.result.hitPositionEnter);
            DismembermentComponent.RequestDismemberment(this.GetOwner(), gameDismBodyPart.RIGHT_LEG, gameDismWoundType.COARSE, this.m_hitShapeData.result.hitPositionEnter);
            DismembermentComponent.RequestDismemberment(this.GetOwner(), gameDismBodyPart.RIGHT_ARM, gameDismWoundType.COARSE, this.m_hitShapeData.result.hitPositionEnter);
            break;
          case 6:
            DismembermentComponent.RequestDismemberment(this.GetOwner(), gameDismBodyPart.LEFT_LEG, gameDismWoundType.COARSE, this.m_hitShapeData.result.hitPositionEnter);
            DismembermentComponent.RequestDismemberment(this.GetOwner(), gameDismBodyPart.RIGHT_LEG, gameDismWoundType.COARSE, this.m_hitShapeData.result.hitPositionEnter);
            break;
          default:
            return;
        };
      };
    };
    this.NotifyAboutDismembermentInstigated(this.m_attackData.GetInstigator(), HitShapeUserDataBase.GetHitReactionZone(this.GetHitShapeUserData()));
  }

  protected final func SendDismembermentCriticalEvent(dismembermentType: gameDismWoundType, bodyPart: gameDismBodyPart, explosionEpicentrum: Vector4, strength: Float, hitPosition: Vector4) -> Void {
    let evt: ref<RequestDismembermentEvent> = new RequestDismembermentEvent();
    let evtExplosion: ref<DismembermentExplosionEvent> = new DismembermentExplosionEvent();
    let randomValue: Float = 0.00;
    evtExplosion.m_epicentrum = explosionEpicentrum;
    evtExplosion.m_strength = strength;
    evt.hitPosition = hitPosition;
    evt.dismembermentType = dismembermentType;
    evt.bodyPart = bodyPart;
    evt.isCritical = true;
    GameInstance.GetDelaySystem(this.GetOwnerPuppet().GetGame()).DelayEvent(this.GetOwnerPuppet(), evtExplosion, randomValue);
    GameInstance.GetDelaySystem(this.GetOwnerPuppet().GetGame()).DelayEvent(this.GetOwnerPuppet(), evt, randomValue);
  }

  protected final func GetHitIntensity(defeatedOverride: Bool) -> Void {
    if this.IsStrongExplosion(this.m_attackData) {
      this.m_hitIntensity = EAIHitIntensity.Explosion;
      this.m_animVariation = RandRange(0, 3);
    } else {
      if !(this.GetOwner() as ScriptedPuppet).IsMassive() && this.m_cumulatedPhysicalImpulse >= this.m_knockdownImpulseThreshold && (this.m_cumulatedDamages >= this.m_knockdownDamageThreshold || !this.m_isAlive) && this.m_knockdownDamageThreshold > 0.00 && this.m_knockdownImpulseThreshold > 0.00 {
        this.m_hitIntensity = EAIHitIntensity.Heavy;
        if this.CanDieCondition() && this.GetOwnerNPC().IsAboutToBeDefeated() && !defeatedOverride {
          this.GetOwner().Record1DamageInHistory(this.m_attackData.GetInstigator());
          this.GetOwnerPuppet().Kill(this.m_attackData.GetInstigator());
          this.m_reactionType = animHitReactionType.Death;
          this.m_isAlive = false;
        };
      } else {
        this.m_hitIntensity = EAIHitIntensity.Medium;
      };
    };
  }

  private final func IsPowerDifferenceBelow(powerDifferential: EPowerDifferential) -> Bool {
    return EnumInt(RPGManager.CalculatePowerDifferential(this.GetOwner())) <= EnumInt(powerDifferential);
  }

  protected final func GetReactionType() -> animHitReactionType {
    let currentTimeStamp: Float;
    let hitReactionMax: Int32;
    let hitReactionMin: Int32;
    let isPlayerExhausted: Bool;
    let npc: ref<NPCPuppet>;
    let powerDifferenceTooHigh: Bool;
    let powerDifferential: EPowerDifferential;
    let rarity: ref<NPCRarity_Record>;
    let stamina: Float;
    let statPoolSystem: ref<StatPoolsSystem>;
    let weaponRecord: ref<WeaponItem_Record>;
    if this.m_attackData.GetInstigator().IsPlayer() {
      isPlayerExhausted = StatusEffectSystem.ObjectHasStatusEffect(this.m_attackData.GetInstigator(), t"BaseStatusEffect.PlayerExhausted");
    };
    weaponRecord = TweakDBInterface.GetWeaponItemRecord(ItemID.GetTDBID(ScriptedPuppet.GetWeaponRight(this.m_attackData.GetSource()).GetItemID()));
    currentTimeStamp = this.GetCurrentTime();
    hitReactionMin = this.m_attackData.GetAttackDefinition().GetRecord().HitReactionSeverityMin();
    if weaponRecord.ForcedMinHitReaction() > hitReactionMin {
      hitReactionMin = weaponRecord.ForcedMinHitReaction();
    };
    hitReactionMax = this.m_attackData.GetAttackDefinition().GetRecord().HitReactionSeverityMax();
    powerDifferential = RPGManager.CalculatePowerDifferential(this.GetOwner());
    powerDifferenceTooHigh = EnumInt(powerDifferential) <= EnumInt(EPowerDifferential.IMPOSSIBLE);
    npc = this.GetOwner() as NPCPuppet;
    rarity = npc.GetPuppetRarity();
    if this.m_attackData.GetInstigator().IsPlayer() && Equals(GameObject.GetAttitudeTowards(npc, this.m_attackData.GetInstigator()), EAIAttitude.AIA_Friendly) {
      hitReactionMax = 0;
    };
    if AttackData.IsMelee(this.m_attackData.GetAttackType()) && NotEquals(this.GetSubAttackSubType(), gamedataAttackSubtype.DeflectAttack) {
      if this.GetIsOwnerImmuneToMelee() == 1.00 {
        hitReactionMin = 0;
        hitReactionMax = -1;
      };
    };
    if !ScriptedPuppet.IsAlive(this.GetOwner()) {
      return animHitReactionType.Death;
    };
    if StatusEffectSystem.ObjectHasStatusEffectWithTag(this.GetOwner(), n"DismemberedLeg") || (this.GetOwner() as ScriptedPuppet).IsMassive() {
      return animHitReactionType.Twitch;
    };
    if AttackData.IsQuickMelee(this.m_attackData.GetAttackType()) && RPGManager.HasStatFlag(this.m_attackData.GetInstigator(), gamedataStatType.CanQuickMeleeStagger) && this.GetIsOwnerImmuneToMelee() == 0.00 && this.m_quickMeleeCooldown <= currentTimeStamp {
      if this.m_attackData.HasFlag(hitFlag.WasDeflected) {
        statPoolSystem = GameInstance.GetStatPoolsSystem(this.GetOwner().GetGame());
        stamina = statPoolSystem.GetStatPoolValue(Cast(this.GetOwner().GetEntityID()), gamedataStatPoolType.Stamina);
        if Equals(TweakDBInterface.GetWeaponItemRecord(ItemID.GetTDBID(ScriptedPuppet.GetWeaponRight(this.GetOwner()).GetItemID())).ItemType().Type(), gamedataItemType.Cyb_StrongArms) {
          GameObject.StartReplicatedEffectEvent(this.GetOwner(), n"strong_arms_block");
        };
        if stamina > 0.00 && this.m_overrideHitReactionImpulse < stamina {
          this.m_previousMeleeHitTimeStamp = 0.00;
          NPCPuppet.SendNPCHitDataTrackingRequest(this.GetOwner() as NPCPuppet, ENPCTelemetryData.DeflectedAttack, 1);
          return animHitReactionType.Parry;
        };
        this.m_previousMeleeHitTimeStamp = currentTimeStamp;
        this.m_animVariation = 1;
        NPCPuppet.SendNPCHitDataTrackingRequest(this.GetOwner() as NPCPuppet, ENPCTelemetryData.WasGuardBreaked, 1);
        return animHitReactionType.GuardBreak;
      };
      if this.m_attackData.HasFlag(hitFlag.WasBlocked) {
        statPoolSystem = GameInstance.GetStatPoolsSystem(this.GetOwner().GetGame());
        stamina = statPoolSystem.GetStatPoolValue(Cast(this.GetOwner().GetEntityID()), gamedataStatPoolType.Stamina);
        if Equals(TweakDBInterface.GetWeaponItemRecord(ItemID.GetTDBID(ScriptedPuppet.GetWeaponRight(this.GetOwner()).GetItemID())).ItemType().Type(), gamedataItemType.Cyb_StrongArms) {
          GameObject.StartReplicatedEffectEvent(this.GetOwner(), n"strong_arms_block");
        };
        if stamina > 0.00 && this.m_overrideHitReactionImpulse < stamina {
          NPCPuppet.SendNPCHitDataTrackingRequest(this.GetOwner() as NPCPuppet, ENPCTelemetryData.BlockedAttack, 1);
          return animHitReactionType.Block;
        };
        this.m_previousMeleeHitTimeStamp = currentTimeStamp;
        this.m_animVariation = 0;
        NPCPuppet.SendNPCHitDataTrackingRequest(this.GetOwner() as NPCPuppet, ENPCTelemetryData.WasGuardBreaked, 1);
        return animHitReactionType.GuardBreak;
      };
      if !powerDifferenceTooHigh {
        this.m_quickMeleeCooldown = currentTimeStamp + PlayerPuppet.GetQuickMeleeCooldown();
        this.m_lastHitReactionPlayed = EAILastHitReactionPlayed.Stagger;
        this.m_specificHitTimeout = currentTimeStamp + this.m_staggerDamageDuration;
        this.m_comboResetTime = currentTimeStamp + 1.50;
        this.m_previousRangedHitTimeStamp = this.GetCurrentTime();
        return animHitReactionType.Stagger;
      };
    } else {
      if AttackData.IsQuickMelee(this.m_attackData.GetAttackType()) && this.m_quickMeleeCooldown > currentTimeStamp {
        return animHitReactionType.Twitch;
      };
      if (AttackData.IsLightMelee(this.m_attackData.GetAttackType()) || AttackData.IsQuickMelee(this.m_attackData.GetAttackType())) && this.GetIsOwnerImmuneToMelee() == 0.00 && !powerDifferenceTooHigh {
        if AttackData.IsQuickMelee(this.m_attackData.GetAttackType()) {
          this.m_quickMeleeCooldown = currentTimeStamp + PlayerPuppet.GetQuickMeleeCooldown();
        };
        if this.m_attackData.HasFlag(hitFlag.WasDeflected) {
          statPoolSystem = GameInstance.GetStatPoolsSystem(this.GetOwner().GetGame());
          stamina = statPoolSystem.GetStatPoolValue(Cast(this.GetOwner().GetEntityID()), gamedataStatPoolType.Stamina);
          if Equals(TweakDBInterface.GetWeaponItemRecord(ItemID.GetTDBID(ScriptedPuppet.GetWeaponRight(this.GetOwner()).GetItemID())).ItemType().Type(), gamedataItemType.Cyb_StrongArms) {
            GameObject.StartReplicatedEffectEvent(this.GetOwner(), n"strong_arms_block");
          };
          if stamina > 1.00 && this.m_overrideHitReactionImpulse < stamina {
            this.m_previousMeleeHitTimeStamp = 0.00;
            NPCPuppet.SendNPCHitDataTrackingRequest(this.GetOwner() as NPCPuppet, ENPCTelemetryData.DeflectedAttack, 1);
            return animHitReactionType.Parry;
          };
          this.m_previousMeleeHitTimeStamp = currentTimeStamp;
          this.m_animVariation = 1;
          NPCPuppet.SendNPCHitDataTrackingRequest(this.GetOwner() as NPCPuppet, ENPCTelemetryData.HitByLightAttack, 1);
          NPCPuppet.SendNPCHitDataTrackingRequest(this.GetOwner() as NPCPuppet, ENPCTelemetryData.WasGuardBreaked, 1);
          return animHitReactionType.GuardBreak;
        };
        if this.m_attackData.HasFlag(hitFlag.WasBlocked) {
          statPoolSystem = GameInstance.GetStatPoolsSystem(this.GetOwner().GetGame());
          stamina = statPoolSystem.GetStatPoolValue(Cast(this.GetOwner().GetEntityID()), gamedataStatPoolType.Stamina);
          if Equals(TweakDBInterface.GetWeaponItemRecord(ItemID.GetTDBID(ScriptedPuppet.GetWeaponRight(this.GetOwner()).GetItemID())).ItemType().Type(), gamedataItemType.Cyb_StrongArms) {
            GameObject.StartReplicatedEffectEvent(this.GetOwner(), n"strong_arms_block");
          };
          if stamina > 1.00 && this.m_overrideHitReactionImpulse < stamina {
            NPCPuppet.SendNPCHitDataTrackingRequest(this.GetOwner() as NPCPuppet, ENPCTelemetryData.BlockedAttack, 1);
            return animHitReactionType.Block;
          };
          this.m_previousMeleeHitTimeStamp = currentTimeStamp;
          this.m_animVariation = 0;
          NPCPuppet.SendNPCHitDataTrackingRequest(this.GetOwner() as NPCPuppet, ENPCTelemetryData.HitByLightAttack, 1);
          NPCPuppet.SendNPCHitDataTrackingRequest(this.GetOwner() as NPCPuppet, ENPCTelemetryData.WasGuardBreaked, 1);
          return animHitReactionType.GuardBreak;
        };
        this.m_previousMeleeHitTimeStamp = currentTimeStamp;
        if Equals(this.GetSubAttackSubType(), gamedataAttackSubtype.BlockAttack) {
          NPCPuppet.SendNPCHitDataTrackingRequest(this.GetOwner() as NPCPuppet, ENPCTelemetryData.HitByBlockAttack, 1);
        };
        if Equals(this.GetSubAttackSubType(), gamedataAttackSubtype.FinalAttack) {
          NPCPuppet.SendNPCHitDataTrackingRequest(this.GetOwner() as NPCPuppet, ENPCTelemetryData.HitByFinalComboAttack, 1);
          NPCPuppet.SendNPCHitDataTrackingRequest(this.GetOwner() as NPCPuppet, ENPCTelemetryData.HitByLightAttack, 1);
        } else {
          NPCPuppet.SendNPCHitDataTrackingRequest(this.GetOwner() as NPCPuppet, ENPCTelemetryData.HitByLightAttack, 1);
        };
        if !(this.GetOwner() as ScriptedPuppet).IsMassive() && !powerDifferenceTooHigh && !this.m_immuneToKnockDown && !isPlayerExhausted && (this.m_cumulatedPhysicalImpulse >= this.m_knockdownImpulseThreshold && this.m_cumulatedDamages >= this.m_knockdownDamageThreshold && this.m_knockdownDamageThreshold > 0.00 && this.m_knockdownImpulseThreshold > 0.00 && (hitReactionMax >= 3 || hitReactionMax == -1) || hitReactionMin >= 3 && this.m_knockdownDamageThreshold > 0.00 && this.m_knockdownImpulseThreshold > 0.00) {
          if this.m_specificHitTimeout > currentTimeStamp && Equals(this.m_lastHitReactionPlayed, EAILastHitReactionPlayed.Knockdown) {
            return animHitReactionType.Twitch;
          };
          this.m_lastHitReactionPlayed = EAILastHitReactionPlayed.Knockdown;
          this.m_specificHitTimeout = currentTimeStamp + this.m_knockdownDamageDuration;
          return animHitReactionType.Knockdown;
        };
        if (this.m_staggerDamageThreshold > 0.00 && this.m_cumulatedDamages >= this.m_staggerDamageThreshold && (hitReactionMax >= 2 || hitReactionMax == -1) || hitReactionMin >= 2 && this.m_staggerDamageThreshold > 0.00) && (!powerDifferenceTooHigh || Equals(rarity.Type(), gamedataNPCRarity.Boss)) && !isPlayerExhausted {
          if this.m_specificHitTimeout > currentTimeStamp && (Equals(this.m_lastHitReactionPlayed, EAILastHitReactionPlayed.Stagger) || Equals(this.m_lastHitReactionPlayed, EAILastHitReactionPlayed.Knockdown) || AIActionHelper.IsCurrentlyCrouching(this.GetOwnerPuppet())) {
            return animHitReactionType.Twitch;
          };
          this.m_lastHitReactionPlayed = EAILastHitReactionPlayed.Stagger;
          this.m_specificHitTimeout = currentTimeStamp + this.m_staggerDamageDurationMelee;
          this.m_comboResetTime = currentTimeStamp + 1.50;
          this.m_previousRangedHitTimeStamp = this.GetCurrentTime();
          return animHitReactionType.Stagger;
        };
        if (this.m_impactDamageThreshold > 0.00 && this.m_cumulatedDamages >= this.m_impactDamageThreshold && (hitReactionMax >= 1 || hitReactionMax == -1) || hitReactionMin >= 1 && this.m_impactDamageThreshold > 0.00) && !isPlayerExhausted {
          if this.m_specificHitTimeout > currentTimeStamp {
            return animHitReactionType.Twitch;
          };
          this.m_lastHitReactionPlayed = EAILastHitReactionPlayed.Impact;
          this.m_specificHitTimeout = currentTimeStamp + this.m_impactDamageDurationMelee;
          this.m_previousRangedHitTimeStamp = this.GetCurrentTime();
          return animHitReactionType.Impact;
        };
        return animHitReactionType.Twitch;
      };
      if (AttackData.IsStrongMelee(this.m_attackData.GetAttackType()) || Equals(this.GetSubAttackSubType(), gamedataAttackSubtype.FinalAttack)) && this.GetIsOwnerImmuneToMelee() == 0.00 && !powerDifferenceTooHigh {
        if this.m_attackData.HasFlag(hitFlag.WasDeflected) {
          statPoolSystem = GameInstance.GetStatPoolsSystem(this.GetOwner().GetGame());
          stamina = statPoolSystem.GetStatPoolValue(Cast(this.GetOwner().GetEntityID()), gamedataStatPoolType.Stamina);
          if Equals(TweakDBInterface.GetWeaponItemRecord(ItemID.GetTDBID(ScriptedPuppet.GetWeaponRight(this.GetOwner()).GetItemID())).ItemType().Type(), gamedataItemType.Cyb_StrongArms) {
            GameObject.StartReplicatedEffectEvent(this.GetOwner(), n"strong_arms_block");
          };
          if stamina > 0.00 && this.m_overrideHitReactionImpulse < stamina {
            this.m_previousMeleeHitTimeStamp = 0.00;
            NPCPuppet.SendNPCHitDataTrackingRequest(this.GetOwner() as NPCPuppet, ENPCTelemetryData.DeflectedAttack, 1);
            return animHitReactionType.Parry;
          };
          this.m_previousMeleeHitTimeStamp = currentTimeStamp;
          this.m_animVariation = 1;
          NPCPuppet.SendNPCHitDataTrackingRequest(this.GetOwner() as NPCPuppet, ENPCTelemetryData.HitByStrongAttack, 1);
          NPCPuppet.SendNPCHitDataTrackingRequest(this.GetOwner() as NPCPuppet, ENPCTelemetryData.WasGuardBreaked, 1);
          return animHitReactionType.GuardBreak;
        };
        if this.m_attackData.HasFlag(hitFlag.WasBlocked) {
          statPoolSystem = GameInstance.GetStatPoolsSystem(this.GetOwner().GetGame());
          stamina = statPoolSystem.GetStatPoolValue(Cast(this.GetOwner().GetEntityID()), gamedataStatPoolType.Stamina);
          if Equals(TweakDBInterface.GetWeaponItemRecord(ItemID.GetTDBID(ScriptedPuppet.GetWeaponRight(this.GetOwner()).GetItemID())).ItemType().Type(), gamedataItemType.Cyb_StrongArms) {
            GameObject.StartReplicatedEffectEvent(this.GetOwner(), n"strong_arms_block");
          };
          if stamina > 0.00 && this.m_overrideHitReactionImpulse < stamina {
            NPCPuppet.SendNPCHitDataTrackingRequest(this.GetOwner() as NPCPuppet, ENPCTelemetryData.BlockedAttack, 1);
            return animHitReactionType.Block;
          };
          this.m_previousMeleeHitTimeStamp = currentTimeStamp;
          this.m_animVariation = 0;
          NPCPuppet.SendNPCHitDataTrackingRequest(this.GetOwner() as NPCPuppet, ENPCTelemetryData.HitByStrongAttack, 1);
          NPCPuppet.SendNPCHitDataTrackingRequest(this.GetOwner() as NPCPuppet, ENPCTelemetryData.WasGuardBreaked, 1);
          return animHitReactionType.GuardBreak;
        };
        this.m_previousMeleeHitTimeStamp = currentTimeStamp;
        NPCPuppet.SendNPCHitDataTrackingRequest(this.GetOwner() as NPCPuppet, ENPCTelemetryData.HitByStrongAttack, 1);
        if !(this.GetOwner() as ScriptedPuppet).IsMassive() && !this.m_immuneToKnockDown && !isPlayerExhausted && (this.m_cumulatedPhysicalImpulse >= this.m_knockdownImpulseThreshold && this.m_cumulatedDamages >= this.m_knockdownDamageThreshold && this.m_knockdownDamageThreshold > 0.00 && this.m_knockdownImpulseThreshold > 0.00 && (hitReactionMax >= 3 || hitReactionMax == -1) || hitReactionMin >= 3 && this.m_knockdownDamageThreshold > 0.00 && this.m_knockdownImpulseThreshold > 0.00) {
          if this.m_specificHitTimeout > currentTimeStamp && Equals(this.m_lastHitReactionPlayed, EAILastHitReactionPlayed.Knockdown) {
            return animHitReactionType.Twitch;
          };
          this.m_lastHitReactionPlayed = EAILastHitReactionPlayed.Knockdown;
          this.m_specificHitTimeout = currentTimeStamp + this.m_knockdownDamageDuration;
          return animHitReactionType.Knockdown;
        };
        if (this.m_staggerDamageThreshold > 0.00 && this.m_cumulatedDamages >= this.m_staggerDamageThreshold && (hitReactionMax >= 2 || hitReactionMax == -1) || hitReactionMin >= 2 && this.m_staggerDamageThreshold > 0.00) && (!powerDifferenceTooHigh || Equals(rarity.Type(), gamedataNPCRarity.Boss)) && !isPlayerExhausted {
          if this.m_specificHitTimeout > currentTimeStamp && (Equals(this.m_lastHitReactionPlayed, EAILastHitReactionPlayed.Stagger) || Equals(this.m_lastHitReactionPlayed, EAILastHitReactionPlayed.Knockdown) || AIActionHelper.IsCurrentlyCrouching(this.GetOwnerPuppet())) {
            return animHitReactionType.Twitch;
          };
          this.m_lastHitReactionPlayed = EAILastHitReactionPlayed.Stagger;
          this.m_specificHitTimeout = currentTimeStamp + this.m_staggerDamageDurationMelee;
          this.m_comboResetTime = currentTimeStamp + 1.50;
          this.m_previousRangedHitTimeStamp = this.GetCurrentTime();
          return animHitReactionType.Stagger;
        };
        if (this.m_impactDamageThreshold > 0.00 && (hitReactionMax >= 1 || hitReactionMax == -1) || hitReactionMin >= 1 && this.m_impactDamageThreshold > 0.00) && !isPlayerExhausted {
          if this.m_specificHitTimeout > currentTimeStamp && (Equals(this.m_lastHitReactionPlayed, EAILastHitReactionPlayed.Knockdown) || AIActionHelper.IsCurrentlyCrouching(this.GetOwnerPuppet())) {
            return animHitReactionType.Twitch;
          };
          this.m_lastHitReactionPlayed = EAILastHitReactionPlayed.Impact;
          this.m_specificHitTimeout = currentTimeStamp + this.m_impactDamageDurationMelee;
          this.m_previousRangedHitTimeStamp = this.GetCurrentTime();
          return animHitReactionType.Impact;
        };
      } else {
        if AttackData.IsQuickMelee(this.m_attackData.GetAttackType()) {
          this.m_quickMeleeCooldown = currentTimeStamp + PlayerPuppet.GetQuickMeleeCooldown();
        };
        if this.m_attackData.HasFlag(hitFlag.WasDeflected) {
          statPoolSystem = GameInstance.GetStatPoolsSystem(this.GetOwner().GetGame());
          stamina = statPoolSystem.GetStatPoolValue(Cast(this.GetOwner().GetEntityID()), gamedataStatPoolType.Stamina);
          if Equals(TweakDBInterface.GetWeaponItemRecord(ItemID.GetTDBID(ScriptedPuppet.GetWeaponRight(this.GetOwner()).GetItemID())).ItemType().Type(), gamedataItemType.Cyb_StrongArms) {
            GameObject.StartReplicatedEffectEvent(this.GetOwner(), n"strong_arms_block");
          };
          if stamina > 1.00 && this.m_overrideHitReactionImpulse < stamina {
            this.m_previousMeleeHitTimeStamp = 0.00;
            NPCPuppet.SendNPCHitDataTrackingRequest(this.GetOwner() as NPCPuppet, ENPCTelemetryData.DeflectedAttack, 1);
            return animHitReactionType.Parry;
          };
          this.m_previousMeleeHitTimeStamp = currentTimeStamp;
          this.m_animVariation = 1;
          NPCPuppet.SendNPCHitDataTrackingRequest(this.GetOwner() as NPCPuppet, ENPCTelemetryData.HitByLightAttack, 1);
          NPCPuppet.SendNPCHitDataTrackingRequest(this.GetOwner() as NPCPuppet, ENPCTelemetryData.WasGuardBreaked, 1);
          return animHitReactionType.GuardBreak;
        };
        if this.m_attackData.HasFlag(hitFlag.WasBlocked) {
          statPoolSystem = GameInstance.GetStatPoolsSystem(this.GetOwner().GetGame());
          stamina = statPoolSystem.GetStatPoolValue(Cast(this.GetOwner().GetEntityID()), gamedataStatPoolType.Stamina);
          if Equals(TweakDBInterface.GetWeaponItemRecord(ItemID.GetTDBID(ScriptedPuppet.GetWeaponRight(this.GetOwner()).GetItemID())).ItemType().Type(), gamedataItemType.Cyb_StrongArms) {
            GameObject.StartReplicatedEffectEvent(this.GetOwner(), n"strong_arms_block");
          };
          if stamina > 1.00 && this.m_overrideHitReactionImpulse < stamina {
            NPCPuppet.SendNPCHitDataTrackingRequest(this.GetOwner() as NPCPuppet, ENPCTelemetryData.BlockedAttack, 1);
            return animHitReactionType.Block;
          };
          this.m_previousMeleeHitTimeStamp = currentTimeStamp;
          this.m_animVariation = 0;
          NPCPuppet.SendNPCHitDataTrackingRequest(this.GetOwner() as NPCPuppet, ENPCTelemetryData.HitByLightAttack, 1);
          NPCPuppet.SendNPCHitDataTrackingRequest(this.GetOwner() as NPCPuppet, ENPCTelemetryData.WasGuardBreaked, 1);
          return animHitReactionType.GuardBreak;
        };
        if !(this.GetOwner() as ScriptedPuppet).IsMassive() && !this.m_immuneToKnockDown && (hitReactionMin >= 3 && this.m_knockdownDamageThreshold > 0.00 && this.m_knockdownImpulseThreshold > 0.00 && this.m_specificHitTimeout <= currentTimeStamp || (hitReactionMax >= 3 || hitReactionMax == -1) && this.m_cumulatedPhysicalImpulse >= this.m_knockdownImpulseThreshold && this.m_cumulatedDamages >= this.m_knockdownDamageThreshold && this.m_knockdownDamageThreshold > 0.00 && this.m_knockdownImpulseThreshold > 0.00 && ((this.m_specificHitTimeout <= currentTimeStamp || this.m_previousRangedHitTimeStamp == this.GetCurrentTime()) && Equals(this.m_lastHitReactionPlayed, EAILastHitReactionPlayed.Knockdown) || NotEquals(this.m_lastHitReactionPlayed, EAILastHitReactionPlayed.Knockdown)) || this.IsStrongExplosion(this.m_attackData) && this.m_specificHitTimeout <= currentTimeStamp) {
          this.m_lastHitReactionPlayed = EAILastHitReactionPlayed.Knockdown;
          this.m_specificHitTimeout = currentTimeStamp + this.m_knockdownDamageDuration;
          return animHitReactionType.Knockdown;
        };
        if (this.m_staggerDamageThreshold > 0.00 && this.m_cumulatedDamages >= this.m_staggerDamageThreshold && (this.m_specificHitTimeout <= currentTimeStamp || this.m_previousRangedHitTimeStamp == this.GetCurrentTime() || Equals(this.m_lastHitReactionPlayed, EAILastHitReactionPlayed.Impact)) && (hitReactionMax >= 2 || hitReactionMax == -1) || hitReactionMin >= 2 && this.m_staggerDamageThreshold > 0.00 && this.m_specificHitTimeout <= currentTimeStamp) && (!powerDifferenceTooHigh || Equals(rarity.Type(), gamedataNPCRarity.Boss)) {
          this.m_lastHitReactionPlayed = EAILastHitReactionPlayed.Stagger;
          this.m_specificHitTimeout = currentTimeStamp + this.m_staggerDamageDuration;
          this.m_comboResetTime = currentTimeStamp + 1.50;
          this.m_previousRangedHitTimeStamp = this.GetCurrentTime();
          return animHitReactionType.Stagger;
        };
        if this.m_impactDamageThreshold > 0.00 && this.m_cumulatedDamages >= this.m_impactDamageThreshold && (this.m_specificHitTimeout <= currentTimeStamp || this.m_previousRangedHitTimeStamp == this.GetCurrentTime()) && (hitReactionMax >= 1 || hitReactionMax == -1) || hitReactionMin >= 1 && this.m_impactDamageThreshold > 0.00 && this.m_specificHitTimeout <= currentTimeStamp && (!powerDifferenceTooHigh || Equals(rarity.Type(), gamedataNPCRarity.Boss)) || Equals(npc.GetNPCType(), gamedataNPCType.Drone) && Equals(this.m_attackData.GetAttackType(), gamedataAttackType.Hack) && this.m_attackData.HasFlag(hitFlag.SuccessfulAttack) || Equals(npc.GetNPCType(), gamedataNPCType.Drone) && Equals(this.m_attackData.GetAttackType(), gamedataAttackType.Explosion) && !VehicleComponent.IsMountedToVehicle(npc.GetGame(), npc.GetEntityID()) && this.m_attackData.HasFlag(hitFlag.SuccessfulAttack) {
          this.m_lastHitReactionPlayed = EAILastHitReactionPlayed.Impact;
          this.m_specificHitTimeout = currentTimeStamp + this.m_impactDamageDuration;
          this.m_previousRangedHitTimeStamp = this.GetCurrentTime();
          return animHitReactionType.Impact;
        };
      };
    };
    return animHitReactionType.Twitch;
  }

  private final func IsStrongExplosion(attackData: ref<AttackData>) -> Bool {
    let explosionCentrum: Vector4;
    let explosionImpulse: Float;
    if AttackData.IsExplosion(attackData.GetAttackType()) && !attackData.HasFlag(hitFlag.WeakExplosion) {
      explosionCentrum = this.m_attackData.GetSource().GetWorldPosition();
      explosionImpulse = this.m_cumulatedPhysicalImpulse * 3.00 / Vector4.Distance(this.GetOwnerPuppet().GetWorldPosition(), explosionCentrum);
      if Vector4.Distance(this.GetOwnerPuppet().GetWorldPosition(), explosionCentrum) <= 3.00 {
        return true;
      };
      if explosionImpulse >= this.m_knockdownImpulseThreshold {
        return true;
      };
    };
    return false;
  }

  private final func SendDataToAIBehavior(reactionPlayed: animHitReactionType) -> Void {
    let hitAIEvent: ref<StimuliEvent> = new StimuliEvent();
    switch reactionPlayed {
      case animHitReactionType.Impact:
        hitAIEvent.name = n"Impact";
        break;
      case animHitReactionType.Pain:
        hitAIEvent.name = n"Pain";
        break;
      case animHitReactionType.Stagger:
        hitAIEvent.name = n"Stagger";
        break;
      case animHitReactionType.Knockdown:
        hitAIEvent.name = n"Knockdown";
        break;
      case animHitReactionType.Block:
        hitAIEvent.name = n"Block";
        break;
      case animHitReactionType.GuardBreak:
        hitAIEvent.name = n"GuardBreak";
        break;
      case animHitReactionType.Parry:
        hitAIEvent.name = n"Parry";
        break;
      case animHitReactionType.Death:
        if !ScriptedPuppet.CanRagdoll(this.GetOwnerPuppet()) {
          hitAIEvent.name = n"Death";
        } else {
          if this.GetOwnerPuppet().GetPuppetStateBlackboard().GetBool(GetAllBlackboardDefs().PuppetState.ForceRagdollOnDeath) {
            hitAIEvent.name = n"ForcedRagdoll";
          } else {
            hitAIEvent.name = n"Death";
          };
        };
        break;
      default:
        return;
    };
    hitAIEvent.id += 1u;
    this.m_currentStimId = hitAIEvent.id;
    this.m_lastStimName = hitAIEvent.name;
    if Equals(reactionPlayed, animHitReactionType.Death) || Equals(reactionPlayed, animHitReactionType.Ragdoll) {
      this.m_deathStimName = hitAIEvent.name;
    };
    this.GetOwner().QueueEvent(hitAIEvent);
  }

  protected final func SendMechDataToAIBehavior(reactionPlayed: animHitReactionType) -> Void {
    let hitAIEvent: ref<StimuliEvent> = new StimuliEvent();
    switch reactionPlayed {
      case animHitReactionType.Impact:
        hitAIEvent.name = n"Impact";
        break;
      case animHitReactionType.Stagger:
        hitAIEvent.name = n"Stagger";
        break;
      case animHitReactionType.Death:
        hitAIEvent.name = n"Death";
        break;
      default:
        return;
    };
    hitAIEvent.id += 1u;
    this.m_currentStimId = hitAIEvent.id;
    this.m_lastStimName = hitAIEvent.name;
    if Equals(reactionPlayed, animHitReactionType.Death) || Equals(reactionPlayed, animHitReactionType.Ragdoll) {
      this.m_deathStimName = hitAIEvent.name;
    };
    this.GetOwner().QueueEvent(hitAIEvent);
  }

  protected final func SetHitSource(attackType: gamedataAttackType) -> Void {
    if Equals(attackType, gamedataAttackType.Direct) || Equals(attackType, gamedataAttackType.Ranged) || Equals(attackType, gamedataAttackType.Explosion) || Equals(attackType, gamedataAttackType.Hack) {
      this.SetHitReactionSource(EAIHitSource.Ranged);
    } else {
      if Equals(attackType, gamedataAttackType.WhipAttack) || Equals(attackType, gamedataAttackType.ChargedWhipAttack) {
        this.SetHitReactionSource(EAIHitSource.MeleeSharp);
      } else {
        if Equals(attackType, gamedataAttackType.Melee) || Equals(attackType, gamedataAttackType.StrongMelee) {
          this.SetHitReactionSource(EAIHitSource.MeleeBlunt);
        } else {
          if Equals(attackType, gamedataAttackType.QuickMelee) {
            if RPGManager.HasStatFlag(this.m_attackData.GetInstigator(), gamedataStatType.CanQuickMeleeStagger) && this.m_quickMeleeCooldown <= this.GetCurrentTime() {
              this.SetHitReactionSource(EAIHitSource.QuickMelee);
            } else {
              this.SetHitReactionSource(EAIHitSource.MeleeBlunt);
            };
          };
        };
      };
    };
  }

  private final func SetAnimVariation() -> Void {
    let attackDirection: gamedataMeleeAttackDirection;
    let currentBodyPart: Int32;
    let excludedVariation: Int32;
    let i: Int32;
    if NotEquals(this.m_reactionType, animHitReactionType.GuardBreak) && NotEquals(this.m_reactionType, animHitReactionType.Parry) {
      if AttackData.IsMelee(this.m_attackData.GetAttackType()) && NotEquals(this.m_reactionType, animHitReactionType.Twitch) && NotEquals(this.m_reactionType, animHitReactionType.Death) {
        excludedVariation = -1;
        currentBodyPart = this.ReactionZoneEnumToBodyPartID(HitShapeUserDataBase.GetHitReactionZone(this.GetHitShapeUserData()));
        attackDirection = (this.m_attackData.GetAttackDefinition().GetRecord() as Attack_Melee_Record).AttackDirection().Direction().Type();
        i = 0;
        while i < ArraySize(this.m_previousAnimHitReactionArray) {
          if this.m_previousAnimHitReactionArray[i].hitBodyPart == currentBodyPart && this.m_previousAnimHitReactionArray[i].attackDirection == EnumInt(attackDirection) {
            excludedVariation = this.m_previousAnimHitReactionArray[i].animVariation;
          };
          i += 1;
        };
        switch attackDirection {
          case gamedataMeleeAttackDirection.Center:
            this.m_animVariation = 0 + RandDifferent(excludedVariation, 3);
            break;
          case gamedataMeleeAttackDirection.DownToUp:
            this.m_animVariation = 3 + RandDifferent(excludedVariation - 3, 3);
            break;
          case gamedataMeleeAttackDirection.LeftDownToRightUp:
            this.m_animVariation = 6 + RandDifferent(excludedVariation - 6, 3);
            break;
          case gamedataMeleeAttackDirection.LeftToRight:
            this.m_animVariation = 9 + RandDifferent(excludedVariation - 9, 3);
            break;
          case gamedataMeleeAttackDirection.LeftUpToRightDown:
            this.m_animVariation = 12 + RandDifferent(excludedVariation - 12, 3);
            break;
          case gamedataMeleeAttackDirection.RightDownToLeftUp:
            this.m_animVariation = 15 + RandDifferent(excludedVariation - 15, 3);
            break;
          case gamedataMeleeAttackDirection.RightToLeft:
            this.m_animVariation = 18 + RandDifferent(excludedVariation - 18, 3);
            break;
          case gamedataMeleeAttackDirection.RightUpToLeftDown:
            this.m_animVariation = 21 + RandDifferent(excludedVariation - 21, 3);
            break;
          case gamedataMeleeAttackDirection.UpToDown:
            this.m_animVariation = 24 + RandDifferent(excludedVariation - 24, 3);
            break;
          default:
            return;
        };
      } else {
        this.m_animVariation = RandRange(0, 3);
      };
    };
  }

  protected final func StoreHitData(attackAngle: Int32, hitSeverity: EAIHitIntensity, reactionType: animHitReactionType, bodyPart: EHitReactionZone, variation: Int32) -> Void {
    let scriptStoredHitData: ScriptHitData;
    if attackAngle != 0 {
      this.m_animHitReaction.hitDirection = attackAngle;
    } else {
      this.m_animHitReaction.hitDirection = 4;
    };
    this.m_animHitReaction.hitIntensity = EnumInt(hitSeverity);
    this.SetHitReactionType(reactionType);
    this.m_animHitReaction.animVariation = variation;
    if this.IsStrongExplosion(this.m_attackData) {
      this.m_animHitReaction.hitBodyPart = EnumInt(EAIHitBodyPart.Belly);
    } else {
      this.m_animHitReaction.hitBodyPart = this.ReactionZoneEnumToBodyPartID(bodyPart);
    };
    if Equals(reactionType, animHitReactionType.Death) && !this.m_deathHasBeenPlayed {
      this.m_deathRegisteredTime = this.GetCurrentTime();
      this.m_extendedDeathDelayRegisteredTime = this.GetCurrentTime();
    };
    if NotEquals(reactionType, animHitReactionType.Twitch) {
      this.m_lastAnimHitReaction.hitBodyPart = this.m_animHitReaction.hitBodyPart;
      this.m_lastAnimHitReaction.hitDirection = this.m_animHitReaction.hitDirection;
      this.m_lastAnimHitReaction.hitType = this.m_animHitReaction.hitType;
      this.m_lastAnimHitReaction.stance = this.m_animHitReaction.stance;
      this.m_lastAnimHitReaction.hitIntensity = this.m_animHitReaction.hitIntensity;
      this.m_lastAnimHitReaction.animVariation = this.m_animHitReaction.animVariation;
      this.m_lastAnimHitReaction.hitSource = this.m_animHitReaction.hitSource;
      this.m_lastAnimHitReaction.useInitialRotation = this.m_animHitReaction.useInitialRotation;
      if AttackData.IsLightMelee(this.m_attackData.GetAttackType()) || AttackData.IsStrongMelee(this.m_attackData.GetAttackType()) {
        this.m_meleeHitCount += 1;
        if AttackData.IsStrongMelee(this.m_attackData.GetAttackType()) {
          this.m_strongMeleeHitCount += 1;
        };
      } else {
        this.m_meleeHitCount = 0;
        this.m_strongMeleeHitCount = 0;
      };
    };
    this.SetHitStimEvent(this.m_animHitReaction);
    if ArraySize(this.m_previousAnimHitReactionArray) > 3 {
      ArrayRemove(this.m_previousAnimHitReactionArray, this.m_previousAnimHitReactionArray[0]);
    };
    scriptStoredHitData.animVariation = this.m_animHitReaction.animVariation;
    scriptStoredHitData.attackDirection = EnumInt((this.m_attackData.GetAttackDefinition().GetRecord() as Attack_Melee_Record).AttackDirection().Direction().Type());
    scriptStoredHitData.hitBodyPart = this.m_animHitReaction.hitBodyPart;
    ArrayPush(this.m_previousAnimHitReactionArray, scriptStoredHitData);
  }

  protected final func SendTwitchDataToAnimationGraph() -> Void {
    this.m_reactionType = animHitReactionType.Twitch;
    this.SetHitReactionType(this.m_reactionType);
    if this.m_animHitReaction.animVariation >= 3 {
      this.m_animHitReaction.animVariation = RandRange(0, 3);
    };
    AnimationControllerComponent.ApplyFeatureToReplicate(this.GetOwner(), n"hit", this.m_animHitReaction);
    AnimationControllerComponent.PushEventToReplicate(this.GetOwner(), n"hit");
  }

  protected final func SendTwitchDataToPlayerAnimationGraph(playerObject: wref<GameObject>) -> Void {
    this.SetHitReactionType(animHitReactionType.Twitch);
    AnimationControllerComponent.ApplyFeatureToReplicate(playerObject, n"hit", this.m_animHitReaction);
    AnimationControllerComponent.PushEventToReplicate(playerObject, n"hit");
  }

  private final func SetHitStimEvent(hitData: ref<AnimFeature_HitReactionsData>) -> Void {
    this.m_hitReactionData = hitData;
  }

  public final const func GetHitStimEvent() -> ref<AnimFeature_HitReactionsData> {
    return this.m_hitReactionData;
  }

  public final const func GetLastHitTimeStamp() -> Float {
    if this.m_previousMeleeHitTimeStamp > this.m_previousHitTime {
      return this.m_previousMeleeHitTimeStamp;
    };
    return this.m_previousHitTime;
  }

  protected cb func OnClearHitStimEvent(evt: ref<ClearHitStimEvent>) -> Bool {
    this.m_hitReactionData = null;
  }

  public final static func ClearHitStim(obj: ref<GameObject>) -> Void {
    let evt: ref<ClearHitStimEvent> = new ClearHitStimEvent();
    obj.QueueEvent(evt);
  }
}

public static exec func ForcedNPCDeath(gi: GameInstance) -> Void {
  let forcedDeathEvent: ref<ForcedDeathEvent> = new ForcedDeathEvent();
  forcedDeathEvent.hitIntensity = EnumInt(EAIHitIntensity.Medium);
  forcedDeathEvent.hitSource = EnumInt(EAIHitSource.MeleeSharp);
  forcedDeathEvent.hitType = EnumInt(animHitReactionType.Death);
  forcedDeathEvent.hitBodyPart = 1;
  forcedDeathEvent.hitNpcMovementSpeed = 0;
  forcedDeathEvent.hitDirection = 4;
  forcedDeathEvent.hitNpcMovementDirection = 0;
  let localPlayer: ref<GameObject> = GameInstance.GetPlayerSystem(gi).GetLocalPlayerMainGameObject();
  GameInstance.GetTargetingSystem(gi).GetLookAtObject(localPlayer).QueueEvent(forcedDeathEvent);
}
