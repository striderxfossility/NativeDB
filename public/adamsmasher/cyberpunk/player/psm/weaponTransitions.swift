
public abstract class WeaponTransition extends DefaultTransition {

  public let m_magazineID: TweakDBID;

  public let m_magazineAttack: TweakDBID;

  public let m_rangedAttackPackage: ref<RangedAttackPackage_Record>;

  protected final func ShowAttackPreview(showIfAiming: Bool, weaponObject: ref<WeaponObject>, scriptInterface: ref<StateGameScriptInterface>, stateContext: ref<StateContext>) -> Void {
    let ricochetCount: Float;
    let ricochetEnableStat: Float;
    let statSystem: ref<StatsSystem>;
    let techPierceStat: Float;
    let weaponRecord: ref<WeaponItem_Record>;
    let show: Bool = false;
    let isAiming: Bool = showIfAiming && stateContext.IsStateActive(n"UpperBody", n"aimingState");
    if isAiming {
      statSystem = scriptInterface.GetStatsSystem();
      weaponRecord = weaponObject.GetWeaponRecord();
      if IsDefined(weaponRecord) && NotEquals(weaponRecord.PreviewEffectName(), n"") {
        techPierceStat = statSystem.GetStatValue(Cast(weaponObject.GetEntityID()), gamedataStatType.TechPierceEnabled);
        if Equals(weaponRecord.PreviewEffectTag(), n"ricochet") {
          ricochetEnableStat = statSystem.GetStatValue(Cast(scriptInterface.executionOwnerEntityID), gamedataStatType.CanSeeRicochetVisuals);
          ricochetCount = statSystem.GetStatValue(Cast(scriptInterface.executionOwnerEntityID), gamedataStatType.RicochetCount);
          show = ricochetEnableStat > 0.00 && ricochetCount > 0.00;
        } else {
          if Equals(weaponRecord.PreviewEffectTag(), n"pierce") {
            show = techPierceStat > 0.00;
          };
        };
      };
    };
    weaponObject.GetCurrentAttack().SetPreviewActive(show);
  }

  protected final func GetDesiredAttackRecord(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> ref<Attack_Record> {
    let attackRecord: ref<Attack_Record>;
    let magazine: InnerItemData;
    let rangedAttack: ref<RangedAttack_Record>;
    let weaponCharge: Float;
    let weaponObject: ref<WeaponObject> = this.GetWeaponObject(scriptInterface);
    let weaponRecord: ref<WeaponItem_Record> = weaponObject.GetWeaponRecord();
    if !IsDefined(this.m_rangedAttackPackage) {
      this.m_rangedAttackPackage = weaponRecord.RangedAttacks();
    };
    weaponObject.GetItemData().GetItemPart(magazine, t"AttachmentSlots.DamageMod");
    if this.m_magazineID != ItemID.GetTDBID(InnerItemData.GetItemID(magazine)) {
      this.m_magazineID = ItemID.GetTDBID(InnerItemData.GetItemID(magazine));
      if TDBID.IsValid(this.m_magazineID) {
        this.m_magazineAttack = TDBID.Create(TweakDBInterface.GetString(this.m_magazineID + t".overrideAttack", ""));
        this.m_rangedAttackPackage = TweakDBInterface.GetRangedAttackPackageRecord(this.m_magazineAttack);
      } else {
        this.m_magazineAttack = t"Character.Player_Puppet_Base";
      };
    };
    weaponCharge = WeaponObject.GetWeaponChargeNormalized(weaponObject);
    rangedAttack = weaponCharge >= 1.00 ? this.m_rangedAttackPackage.ChargeFire() : this.m_rangedAttackPackage.DefaultFire();
    if scriptInterface.GetTimeSystem().IsTimeDilationActive() && !Equals(weaponRecord.Evolution().Type(), gamedataWeaponEvolution.Tech) {
      attackRecord = rangedAttack.PlayerTimeDilated();
    } else {
      attackRecord = rangedAttack.PlayerAttack();
    };
    return attackRecord;
  }

  protected final const func GetBurstTimeRemainingName() -> CName {
    return n"ShootingSequence.BurstTimeRemaining";
  }

  protected final const func GetBurstCycleTimeName() -> CName {
    return n"ShootingSequence.BurstCycleTime";
  }

  protected final const func GetCycleTimeRemainingName() -> CName {
    return n"ShootingSequence.CycleTimeRemaining";
  }

  protected final const func GetBurstShotsRemainingName() -> CName {
    return n"ShootingSequence.BurstShotsRemaining";
  }

  protected final const func GetShootingStartName() -> CName {
    return n"ShootingSequence.Start";
  }

  protected final const func GetShootingNumBurstTotalName() -> CName {
    return n"ShootingSequence.NumBurstTotal";
  }

  protected final const func GetIsDelayFireName() -> CName {
    return n"ShootingSequence.IsDelayFire";
  }

  protected final const func GetIsChargedFullAutoName() -> CName {
    return n"ShootingSequence.IsChargedFullAutoSequence";
  }

  protected final const func GetQuestForceShootName() -> CName {
    return n"questForceShoot";
  }

  protected final const func InShootingSequence(stateContext: ref<StateContext>) -> Bool {
    return stateContext.GetFloatParameter(this.GetShootingStartName(), true) > 0.00;
  }

  protected final func StartShootingSequence(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>, fireDelay: Float, burstCycleTime: Float, numShotsBurst: Int32, isFullChargeFullAuto: Bool) -> Void {
    stateContext.SetPermanentFloatParameter(this.GetCycleTimeRemainingName(), fireDelay, true);
    stateContext.SetPermanentBoolParameter(this.GetIsDelayFireName(), fireDelay > 0.00, true);
    stateContext.SetPermanentFloatParameter(this.GetBurstTimeRemainingName(), burstCycleTime, true);
    stateContext.SetPermanentFloatParameter(this.GetBurstCycleTimeName(), burstCycleTime, true);
    stateContext.SetPermanentIntParameter(this.GetBurstShotsRemainingName(), numShotsBurst, true);
    stateContext.SetPermanentIntParameter(this.GetShootingNumBurstTotalName(), 0, true);
    stateContext.SetPermanentFloatParameter(this.GetShootingStartName(), EngineTime.ToFloat(GameInstance.GetSimTime(scriptInterface.GetGame())), true);
    stateContext.SetPermanentBoolParameter(this.GetIsChargedFullAutoName(), isFullChargeFullAuto, true);
    this.GetWeaponObject(scriptInterface).SetTriggerDown(true);
    this.GetWeaponObject(scriptInterface).SetupBurstFireSound(numShotsBurst);
  }

  protected final func ShootingSequencePostShoot(stateContext: ref<StateContext>) -> Void {
    let currShotCount: Int32 = stateContext.GetIntParameter(this.GetBurstShotsRemainingName(), true);
    currShotCount = currShotCount - 1;
    stateContext.SetPermanentIntParameter(this.GetBurstShotsRemainingName(), Max(currShotCount, 0), true);
    stateContext.SetPermanentFloatParameter(this.GetBurstTimeRemainingName(), stateContext.GetFloatParameter(this.GetBurstCycleTimeName(), true), true);
  }

  protected final func SetupNextShootingPhase(stateContext: ref<StateContext>, cycleTime: Float, burstCycleTime: Float, numShotsBurst: Int32) -> Void {
    let currBurstsInSequenceCount: Int32 = stateContext.GetIntParameter(this.GetShootingNumBurstTotalName(), true);
    stateContext.SetPermanentFloatParameter(this.GetCycleTimeRemainingName(), cycleTime, true);
    stateContext.SetPermanentFloatParameter(this.GetBurstTimeRemainingName(), burstCycleTime, true);
    stateContext.SetPermanentIntParameter(this.GetBurstShotsRemainingName(), numShotsBurst, true);
    stateContext.SetPermanentBoolParameter(this.GetIsDelayFireName(), false, true);
    stateContext.SetPermanentIntParameter(this.GetShootingNumBurstTotalName(), currBurstsInSequenceCount + 1, true);
  }

  protected final func EndShootingSequence(weapon: ref<WeaponObject>, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    stateContext.SetPermanentFloatParameter(this.GetCycleTimeRemainingName(), 0.00, true);
    stateContext.SetPermanentFloatParameter(this.GetBurstTimeRemainingName(), 0.00, true);
    stateContext.SetPermanentIntParameter(this.GetBurstShotsRemainingName(), 0, true);
    stateContext.SetPermanentIntParameter(this.GetShootingNumBurstTotalName(), 0, true);
    stateContext.SetPermanentFloatParameter(this.GetShootingStartName(), 0.00, true);
    stateContext.SetPermanentBoolParameter(this.GetIsDelayFireName(), false, true);
    stateContext.SetPermanentBoolParameter(this.GetIsChargedFullAutoName(), false, true);
    weapon.SetTriggerDown(false);
  }

  protected final func ShootingSequenceUpdateCycleTime(timeDelta: Float, stateContext: ref<StateContext>) -> Void {
    let timeRemaining: Float = stateContext.GetFloatParameter(this.GetCycleTimeRemainingName(), true);
    stateContext.SetPermanentFloatParameter(this.GetCycleTimeRemainingName(), MaxF(timeRemaining - timeDelta, 0.00), true);
  }

  protected final func ShootingSequenceUpdateBurstTime(timeDelta: Float, stateContext: ref<StateContext>) -> Void {
    let timeRemaining: Float = stateContext.GetFloatParameter(this.GetBurstTimeRemainingName(), true);
    stateContext.SetPermanentFloatParameter(this.GetBurstTimeRemainingName(), timeRemaining - timeDelta, true);
  }

  protected final const func CanPerformNextShotInSequence(const weaponObject: ref<WeaponObject>, const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let gameInstance: GameInstance = scriptInterface.GetGame();
    let cycleTime: Float = GameInstance.GetStatsSystem(gameInstance).GetStatValue(Cast(weaponObject.GetEntityID()), gamedataStatType.CycleTime);
    let lastShotTime: Float = stateContext.GetFloatParameter(n"LastShotTime", true);
    return EngineTime.ToFloat(GameInstance.GetSimTime(gameInstance)) > lastShotTime + cycleTime;
  }

  protected final const func CanPerformNextSemiAutoShot(weaponObject: ref<WeaponObject>, const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let validTriggerMode: Bool = false;
    if this.CanPerformNextShotInSequence(weaponObject, stateContext, scriptInterface) {
      validTriggerMode = scriptInterface.IsTriggerModeActive(gamedataTriggerMode.SemiAuto) || scriptInterface.IsTriggerModeActive(gamedataTriggerMode.Burst);
      return validTriggerMode && !weaponObject.IsMagazineEmpty();
    };
    return false;
  }

  protected final const func CanPerformNextFullAutoShot(weaponObject: ref<WeaponObject>, const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let validTriggerMode: Bool = false;
    if this.CanPerformNextShotInSequence(weaponObject, stateContext, scriptInterface) {
      validTriggerMode = scriptInterface.IsTriggerModeActive(gamedataTriggerMode.FullAuto) || stateContext.GetBoolParameter(this.GetIsChargedFullAutoName(), true) && scriptInterface.IsTriggerModeActive(gamedataTriggerMode.Charge);
      return validTriggerMode && !weaponObject.IsMagazineEmpty();
    };
    return false;
  }

  protected final func SetupStandardShootingSequence(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let weaponObject: ref<WeaponObject> = this.GetWeaponObject(scriptInterface);
    let statsSystem: ref<StatsSystem> = scriptInterface.GetStatsSystem();
    let burstCycleTimeStat: gamedataStatType = gamedataStatType.CycleTime_Burst;
    let burstNumShots: gamedataStatType = gamedataStatType.NumShotsInBurst;
    if weaponObject.HasSecondaryTriggerMode() && !this.IsPrimaryTriggerModeActive(scriptInterface) {
      burstCycleTimeStat = gamedataStatType.CycleTime_BurstSecondary;
      burstNumShots = gamedataStatType.NumShotsInBurstSecondary;
    };
    this.StartShootingSequence(stateContext, scriptInterface, statsSystem.GetStatValue(Cast(weaponObject.GetEntityID()), gamedataStatType.PreFireTime), statsSystem.GetStatValue(Cast(weaponObject.GetEntityID()), burstCycleTimeStat), Cast(statsSystem.GetStatValue(Cast(weaponObject.GetEntityID()), burstNumShots)), false);
  }

  protected final const func IsSemiAutoAction(weaponObject: ref<WeaponObject>, const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if scriptInterface.GetActionValue(n"RangedAttack") > 0.00 && this.IsInVisionModeActiveState(stateContext, scriptInterface) {
      return true;
    };
    return scriptInterface.IsActionJustPressed(n"RangedAttack");
  }

  protected final const func ToSemiAutoTransitionCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let weaponObject: ref<WeaponObject> = this.GetWeaponObject(scriptInterface);
    return this.IsSemiAutoAction(weaponObject, stateContext, scriptInterface) && this.CanPerformNextSemiAutoShot(weaponObject, stateContext, scriptInterface);
  }

  protected final const func IsFullAutoAction(weaponObject: ref<WeaponObject>, const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return scriptInterface.GetActionValue(n"RangedAttack") > 0.00;
  }

  protected final const func ToFullAutoTransitionCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let weaponObject: ref<WeaponObject> = this.GetWeaponObject(scriptInterface);
    return this.IsFullAutoAction(weaponObject, stateContext, scriptInterface) && this.CanPerformNextFullAutoShot(weaponObject, stateContext, scriptInterface);
  }

  protected final func ShowDebugText(textToShow: String, scriptInterface: ref<StateGameScriptInterface>, out layerId: Uint32) -> Void {
    layerId = GameInstance.GetDebugVisualizerSystem(scriptInterface.GetGame()).DrawText(new Vector4(500.00, 550.00, 0.00, 0.00), textToShow, gameDebugViewETextAlignment.Left, new Color(255u, 255u, 0u, 255u));
    GameInstance.GetDebugVisualizerSystem(scriptInterface.GetGame()).SetScale(layerId, new Vector4(1.00, 1.00, 0.00, 0.00));
  }

  protected final func ClearDebugText(layerId: Uint32, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    GameInstance.GetDebugVisualizerSystem(scriptInterface.GetGame()).ClearLayer(layerId);
  }

  protected final const func GetWeaponObject(const scriptInterface: ref<StateGameScriptInterface>) -> ref<WeaponObject> {
    return scriptInterface.owner as WeaponObject;
  }

  protected final func PlayEffect(effectName: CName, scriptInterface: ref<StateGameScriptInterface>, opt eventTag: CName) -> Void {
    let spawnEffectEvent: ref<entSpawnEffectEvent>;
    let weapon: ref<WeaponObject> = this.GetWeaponObject(scriptInterface);
    if IsDefined(weapon) {
      spawnEffectEvent = new entSpawnEffectEvent();
      spawnEffectEvent.effectName = effectName;
      spawnEffectEvent.effectInstanceName = eventTag;
      weapon.QueueEventToChildItems(spawnEffectEvent);
    };
  }

  protected final func StopEffect(effectName: CName, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let killEffectEvent: ref<entKillEffectEvent>;
    let weapon: ref<WeaponObject> = this.GetWeaponObject(scriptInterface);
    if IsDefined(weapon) {
      killEffectEvent = new entKillEffectEvent();
      killEffectEvent.effectName = effectName;
      weapon.QueueEventToChildItems(killEffectEvent);
    };
  }

  protected final func GetWeaponTriggerModesNumber(scriptInterface: ref<StateGameScriptInterface>) -> Int32 {
    let triggerModesArray: array<wref<TriggerMode_Record>>;
    let item: ref<ItemObject> = scriptInterface.GetTransactionSystem().GetItemInSlot(scriptInterface.executionOwner, t"AttachmentSlots.WeaponRight");
    let itemID: ItemID = item.GetItemID();
    let weaponRecordData: ref<WeaponItem_Record> = TweakDBInterface.GetWeaponItemRecord(ItemID.GetTDBID(itemID));
    weaponRecordData.TriggerModes(triggerModesArray);
    return ArraySize(triggerModesArray);
  }

  protected final const func CompareTimeToPublicSafeTimestamp(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>, timeToCompare: Float) -> Bool {
    let exitTimeStamp: Float = stateContext.GetFloatParameter(n"TurnOffPublicSafeTimeStamp", true);
    return EngineTime.ToFloat(GameInstance.GetSimTime(scriptInterface.GetGame())) - exitTimeStamp > timeToCompare;
  }

  protected final const func SwitchTriggerMode(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let evt: ref<WeaponChangeTriggerModeEvent> = new WeaponChangeTriggerModeEvent();
    let weapon: ref<WeaponObject> = this.GetWeaponObject(scriptInterface);
    let weaponRecord: ref<WeaponItem_Record> = weapon.GetWeaponRecord();
    if this.IsPrimaryTriggerModeActive(scriptInterface) {
      evt.triggerMode = weaponRecord.SecondaryTriggerMode().Type();
    } else {
      evt.triggerMode = weaponRecord.PrimaryTriggerMode().Type();
    };
    weapon.QueueEvent(evt);
  }

  protected final const func IsPrimaryTriggerModeActive(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let weapon: ref<WeaponObject> = this.GetWeaponObject(scriptInterface);
    let weaponRecord: ref<WeaponItem_Record> = weapon.GetWeaponRecord();
    if weapon.GetCurrentTriggerMode() == weaponRecord.PrimaryTriggerMode() {
      return true;
    };
    return false;
  }

  protected final func UpdateInputBuffer(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    if scriptInterface.IsActionJustPressed(n"Reload") {
      stateContext.SetConditionFloatParameter(n"RealodInputPressBuffer", EngineTime.ToFloat(GameInstance.GetSimTime(scriptInterface.GetGame())) + 0.20, true);
      stateContext.SetConditionBoolParameter(n"RealodInputPressed", true, true);
    };
  }

  public final static func GetPlayerSpeed(scriptInterface: ref<StateGameScriptInterface>) -> Float {
    let player: ref<PlayerPuppet> = scriptInterface.executionOwner as PlayerPuppet;
    let velocity: Vector4 = player.GetVelocity();
    let speed: Float = Vector4.Length2D(velocity);
    return speed;
  }

  public final static func ServerHasReloadRequest(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let paramRequest: ref<parameterRequestReload> = stateContext.GetTemporaryScriptableParameter(n"serverRequestReload") as parameterRequestReload;
    if IsDefined(paramRequest) {
      return paramRequest.item == scriptInterface.owner;
    };
    return false;
  }

  protected final const func IsHeavyWeaponEmpty(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let weapon: wref<WeaponObject> = scriptInterface.owner as WeaponObject;
    return weapon.IsHeavyWeapon() && weapon.IsMagazineEmpty();
  }

  protected final const func GetMaxChargeThreshold(const scriptInterface: ref<StateGameScriptInterface>) -> Float {
    if scriptInterface.HasStatFlag(gamedataStatType.CanOverchargeWeapon) {
      return WeaponObject.GetOverchargeThreshold();
    };
    if scriptInterface.HasStatFlag(gamedataStatType.CanFullyChargeWeapon) {
      return WeaponObject.GetFullyChargedThreshold();
    };
    return WeaponObject.GetBaseMaxChargeThreshold();
  }

  protected final const func IsReloadDurationComplete(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let statValue: Float;
    let owner: wref<GameObject> = scriptInterface.owner;
    let ownerID: EntityID = owner.GetEntityID();
    let statsSystem: ref<StatsSystem> = GameInstance.GetStatsSystem(owner.GetGame());
    let logicalDuration: StateResultFloat = stateContext.GetPermanentFloatParameter(n"ReloadLogicalDuration");
    if logicalDuration.valid {
      statValue = logicalDuration.value;
      statValue += statsSystem.GetStatValue(Cast(ownerID), gamedataStatType.ReloadEndTime);
      if this.GetInStateTime() > statValue {
        return true;
      };
      return false;
    };
    return true;
  }

  protected final const func IsReloadUninterruptible(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let uninterruptibleTimeStamp: Float = stateContext.GetFloatParameter(n"uninterruptibleReloadTimeStamp", true);
    return this.GetInStateTime() > uninterruptibleTimeStamp;
  }

  protected final const func SetUninteruptibleReloadParams(stateContext: ref<StateContext>, clearParam: Bool) -> Void {
    if clearParam {
      stateContext.RemovePermanentBoolParameter(n"UninteruptibleReload");
      return;
    };
    stateContext.SetPermanentBoolParameter(n"UninteruptibleReload", true, true);
  }
}

public abstract class WeaponEventsTransition extends WeaponTransition {

  public func OnForcedExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.ActivateDamageProjection(false, this.GetWeaponObject(scriptInterface), scriptInterface, stateContext);
    this.SetUninteruptibleReloadParams(stateContext, true);
  }

  protected final func StartWeaponCharge(statPoolsSystem: ref<StatPoolsSystem>, weaponEntityID: EntityID) -> Void {
    let chargeMod: StatPoolModifier;
    statPoolsSystem.GetModifier(Cast(weaponEntityID), gamedataStatPoolType.WeaponCharge, gameStatPoolModificationTypes.Regeneration, chargeMod);
    chargeMod.enabled = true;
    statPoolsSystem.RequestSettingModifier(Cast(weaponEntityID), gamedataStatPoolType.WeaponCharge, gameStatPoolModificationTypes.Regeneration, chargeMod);
    statPoolsSystem.RequestResetingModifier(Cast(weaponEntityID), gamedataStatPoolType.WeaponCharge, gameStatPoolModificationTypes.Decay);
  }

  protected final func OnEnterNonChargeState(weapon: ref<WeaponObject>, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let weaponID: EntityID;
    weapon.GetSharedData().SetVariant(GetAllBlackboardDefs().Weapon.ChargeStep, ToVariant(gamedataChargeStep.Idle));
    if stateContext.GetBoolParameter(n"WeaponStopChargeRequested", true) {
      weaponID = weapon.GetEntityID();
      this.StopPool(scriptInterface.GetStatPoolsSystem(), weaponID, gamedataStatPoolType.WeaponCharge, true);
      stateContext.SetPermanentBoolParameter(n"WeaponStopChargeRequested", false, true);
    };
  }
}

public class WeaponReadyListenerTransition extends WeaponTransition {

  protected let m_executionOwner: wref<GameObject>;

  protected let m_callBackIDs: array<ref<CallbackHandle>>;

  protected let m_beingCreated: Bool;

  private let m_statListener: ref<DefaultTransitionStatListener>;

  private let m_statusEffectListener: ref<DefaultTransitionStatusEffectListener>;

  private let m_isVaulting: Bool;

  private let m_isDodging: Bool;

  private let m_isInWorkspot: Bool;

  private let m_isSliding: Bool;

  private let m_isInTakedown: Bool;

  private let m_isUsingCombatGadget: Bool;

  private let m_hasStatusEffectNoCombat: Bool;

  private let m_hasStatusEffectFastForward: Bool;

  private let m_hasStatusEffectVehicleScene: Bool;

  private let m_hasStunnedStatusEffect: Bool;

  private let m_hasJamStatusEffect: Bool;

  private let m_canWeaponShootWhileVaulting: Bool;

  private let m_canShootWhileDodging: Bool;

  private let m_canWeaponShootWhileSliding: Bool;

  private let m_isInSafeSceneTier: Bool;

  protected let m_weaponReadyListenerReturnValue: Bool;

  protected func OnAttach(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let allBlackboardDef: ref<AllBlackboardDefinitions> = GetAllBlackboardDefs();
    this.m_beingCreated = true;
    this.m_executionOwner = scriptInterface.executionOwner;
    ArrayPush(this.m_callBackIDs, scriptInterface.localBlackboard.RegisterListenerInt(allBlackboardDef.PlayerStateMachine.Locomotion, this, n"OnLocomotionChanged", true));
    ArrayPush(this.m_callBackIDs, scriptInterface.localBlackboard.RegisterListenerInt(allBlackboardDef.PlayerStateMachine.Takedown, this, n"OnTakedownChanged", true));
    ArrayPush(this.m_callBackIDs, scriptInterface.localBlackboard.RegisterListenerInt(allBlackboardDef.PlayerStateMachine.CombatGadget, this, n"OnCombatGadgetChanged", true));
    ArrayPush(this.m_callBackIDs, scriptInterface.localBlackboard.RegisterListenerInt(allBlackboardDef.PlayerStateMachine.HighLevel, this, n"OnHighLevelChanged", true));
    this.m_statListener = new DefaultTransitionStatListener();
    this.m_statListener.m_transitionOwner = this;
    scriptInterface.GetStatsSystem().RegisterListener(Cast(this.m_executionOwner.GetEntityID()), this.m_statListener);
    this.m_canWeaponShootWhileVaulting = scriptInterface.HasStatFlag(gamedataStatType.CanWeaponShootWhileVaulting);
    this.m_canShootWhileDodging = scriptInterface.HasStatFlag(gamedataStatType.CanShootWhileDodging);
    this.m_canWeaponShootWhileSliding = scriptInterface.HasStatFlag(gamedataStatType.CanWeaponShootWhileSliding);
    this.m_statusEffectListener = new DefaultTransitionStatusEffectListener();
    this.m_statusEffectListener.m_transitionOwner = this;
    scriptInterface.GetStatusEffectSystem().RegisterListener(this.m_executionOwner.GetEntityID(), this.m_statusEffectListener);
    this.UpdateHasNoCombatStatusEffect();
    this.UpdateHastFastForwardStatusEffect();
    this.UpdateHasVehicleSceneStatusEffect();
    this.UpdateHasStunnedStatusEffect();
    this.UpdateHasJamStatusEffect();
    this.m_beingCreated = false;
    this.UpdateWeaponReadyListenerReturnValue();
  }

  protected func OnDetach(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    ArrayClear(this.m_callBackIDs);
    this.m_statusEffectListener = null;
    scriptInterface.GetStatsSystem().UnregisterListener(Cast(this.m_executionOwner.GetEntityID()), this.m_statListener);
  }

  protected func UpdateWeaponReadyListenerReturnValue() -> Void {
    if this.m_beingCreated {
      return;
    };
    this.m_weaponReadyListenerReturnValue = true;
    if this.m_isVaulting && !this.m_canWeaponShootWhileVaulting || this.m_isDodging && !this.m_canShootWhileDodging || this.m_hasStatusEffectVehicleScene || this.m_hasStatusEffectNoCombat && !this.m_hasStatusEffectFastForward || this.m_hasStunnedStatusEffect || this.m_isInTakedown || this.m_isUsingCombatGadget || this.m_hasJamStatusEffect || !this.m_canWeaponShootWhileSliding && this.m_isSliding || this.m_isInSafeSceneTier {
      this.m_weaponReadyListenerReturnValue = false;
    };
  }

  public func OnStatChanged(ownerID: StatsObjectID, statType: gamedataStatType, diff: Float, value: Float) -> Void {
    if Equals(statType, gamedataStatType.CanWeaponShootWhileVaulting) {
      this.m_canWeaponShootWhileVaulting = value > 0.00;
    } else {
      if Equals(statType, gamedataStatType.CanShootWhileDodging) {
        this.m_canShootWhileDodging = value > 0.00;
      } else {
        if Equals(statType, gamedataStatType.CanWeaponShootWhileSliding) {
          this.m_canWeaponShootWhileSliding = value > 0.00;
        };
      };
    };
  }

  protected final func UpdateHasNoCombatStatusEffect() -> Void {
    this.m_hasStatusEffectNoCombat = StatusEffectSystem.ObjectHasStatusEffectWithTag(this.m_executionOwner, n"NoCombat");
  }

  protected final func UpdateHastFastForwardStatusEffect() -> Void {
    this.m_hasStatusEffectFastForward = StatusEffectSystem.ObjectHasStatusEffectWithTag(this.m_executionOwner, n"FastForward");
  }

  protected final func UpdateHasVehicleSceneStatusEffect() -> Void {
    this.m_hasStatusEffectVehicleScene = StatusEffectSystem.ObjectHasStatusEffectWithTag(this.m_executionOwner, n"VehicleScene");
  }

  protected final func UpdateHasStunnedStatusEffect() -> Void {
    this.m_hasStunnedStatusEffect = StatusEffectSystem.ObjectHasStatusEffectOfType(this.m_executionOwner, gamedataStatusEffectType.Stunned);
  }

  protected final func UpdateHasJamStatusEffect() -> Void {
    this.m_hasJamStatusEffect = StatusEffectSystem.ObjectHasStatusEffectOfType(this.m_executionOwner, gamedataStatusEffectType.Jam);
  }

  public func OnStatusEffectApplied(statusEffect: wref<StatusEffect_Record>) -> Void {
    if !this.m_hasStatusEffectNoCombat && statusEffect.GameplayTagsContains(n"NoCombat") {
      this.m_hasStatusEffectNoCombat = true;
      this.UpdateWeaponReadyListenerReturnValue();
    };
    if !this.m_hasStatusEffectFastForward && statusEffect.GameplayTagsContains(n"FastForward") {
      this.m_hasStatusEffectFastForward = true;
      this.UpdateWeaponReadyListenerReturnValue();
    };
    if !this.m_hasStatusEffectVehicleScene && statusEffect.GameplayTagsContains(n"VehicleScene") {
      this.m_hasStatusEffectVehicleScene = true;
      this.UpdateWeaponReadyListenerReturnValue();
    };
    if !this.m_hasStunnedStatusEffect && Equals(gamedataStatusEffectType.Stunned, statusEffect.StatusEffectType().Type()) {
      this.m_hasStunnedStatusEffect = true;
      this.UpdateWeaponReadyListenerReturnValue();
    };
    if !this.m_hasJamStatusEffect && Equals(gamedataStatusEffectType.Jam, statusEffect.StatusEffectType().Type()) {
      this.m_hasJamStatusEffect = true;
      this.UpdateWeaponReadyListenerReturnValue();
    };
  }

  public func OnStatusEffectRemoved(statusEffect: wref<StatusEffect_Record>) -> Void {
    if this.m_hasStatusEffectNoCombat && statusEffect.GameplayTagsContains(n"NoCombat") {
      this.UpdateHasNoCombatStatusEffect();
      this.UpdateWeaponReadyListenerReturnValue();
    };
    if this.m_hasStatusEffectFastForward && statusEffect.GameplayTagsContains(n"FastForward") {
      this.UpdateHastFastForwardStatusEffect();
      this.UpdateWeaponReadyListenerReturnValue();
    };
    if this.m_hasStatusEffectVehicleScene && statusEffect.GameplayTagsContains(n"VehicleScene") {
      this.UpdateHasVehicleSceneStatusEffect();
      this.UpdateWeaponReadyListenerReturnValue();
    };
    if this.m_hasStunnedStatusEffect && Equals(gamedataStatusEffectType.Stunned, statusEffect.StatusEffectType().Type()) {
      this.UpdateHasStunnedStatusEffect();
      this.UpdateWeaponReadyListenerReturnValue();
    };
    if this.m_hasJamStatusEffect && Equals(gamedataStatusEffectType.Jam, statusEffect.StatusEffectType().Type()) {
      this.UpdateHasJamStatusEffect();
      this.UpdateWeaponReadyListenerReturnValue();
    };
  }

  protected cb func OnLocomotionChanged(value: Int32) -> Bool {
    this.m_isVaulting = value == EnumInt(gamePSMLocomotionStates.Vault);
    this.m_isDodging = value == EnumInt(gamePSMLocomotionStates.Dodge) || value == EnumInt(gamePSMLocomotionStates.DodgeAir);
    this.m_isInWorkspot = value == EnumInt(gamePSMLocomotionStates.Workspot);
    this.m_isSliding = value == EnumInt(gamePSMLocomotionStates.Slide) || value == EnumInt(gamePSMLocomotionStates.SlideFall);
    this.UpdateWeaponReadyListenerReturnValue();
  }

  protected cb func OnTakedownChanged(value: Int32) -> Bool {
    this.m_isInTakedown = value == EnumInt(gamePSMTakedown.Grapple) || value == EnumInt(gamePSMTakedown.Leap) || value == EnumInt(gamePSMTakedown.Takedown);
    this.UpdateWeaponReadyListenerReturnValue();
  }

  protected cb func OnCombatGadgetChanged(value: Int32) -> Bool {
    this.m_isUsingCombatGadget = value > EnumInt(gamePSMCombatGadget.Default) && value < EnumInt(gamePSMCombatGadget.WaitForUnequip);
    this.UpdateWeaponReadyListenerReturnValue();
  }

  protected cb func OnHighLevelChanged(value: Int32) -> Bool {
    this.m_isInSafeSceneTier = value > EnumInt(gamePSMHighLevel.SceneTier1) && value <= EnumInt(gamePSMHighLevel.SceneTier5);
    this.UpdateWeaponReadyListenerReturnValue();
  }

  protected final const func IsWeaponReadyToShoot(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if !this.m_weaponReadyListenerReturnValue {
      return false;
    };
    if stateContext.IsStateMachineActive(n"Consumable") {
      return false;
    };
    if this.IsRightHandInUnequippingState(stateContext) {
      return false;
    };
    if this.m_isInWorkspot {
      if !stateContext.GetBoolParameter(n"isInVehCombat", true) && !stateContext.GetBoolParameter(n"isInDriverCombat", true) {
        return false;
      };
    };
    if !this.IsRightHandInEquippedState(stateContext) {
      return false;
    };
    if (scriptInterface.executionOwner as PlayerPuppet).IsAimingAtFriendly() {
      return this.ShouldIgnoreWeaponSafe(scriptInterface);
    };
    return true;
  }
}

public class ReadyDecisions extends WeaponReadyListenerTransition {

  protected func UpdateWeaponReadyListenerReturnValue() -> Void {
    this.UpdateWeaponReadyListenerReturnValue();
    this.EnableOnEnterCondition(this.m_weaponReadyListenerReturnValue);
  }

  protected final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.IsWeaponReadyToShoot(stateContext, scriptInterface);
  }
}

public class ReadyEvents extends WeaponEventsTransition {

  public let m_timeStamp: Float;

  protected final func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let weapon: wref<WeaponObject> = scriptInterface.owner as WeaponObject;
    this.OnEnterNonChargeState(weapon, stateContext, scriptInterface);
    DefaultTransition.UpdateAimAssist(stateContext, scriptInterface);
    this.EndShootingSequence(weapon, stateContext, scriptInterface);
    stateContext.SetConditionWeakScriptableParameter(n"Weapon", weapon, true);
    scriptInterface.TEMP_WeaponStopFiring();
    if !weapon.IsMagazineEmpty() {
      this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Weapon, EnumInt(gamePSMRangedWeaponStates.Default));
    };
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Weapon, EnumInt(gamePSMRangedWeaponStates.Ready));
    stateContext.SetPermanentBoolParameter(n"WeaponInSafe", false, true);
    scriptInterface.SetAnimationParameterFloat(n"safe", 0.00);
    this.m_timeStamp = EngineTime.ToFloat(GameInstance.GetSimTime(scriptInterface.GetGame()));
  }

  protected final func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let weaponObject: ref<WeaponObject> = this.GetWeaponObject(scriptInterface);
    let attackID: TweakDBID = this.GetDesiredAttackRecord(stateContext, scriptInterface).GetID();
    if weaponObject.GetCurrentAttack().GetRecord().GetID() != attackID {
      weaponObject.SetAttack(attackID);
    };
    this.ShowAttackPreview(true, weaponObject, scriptInterface, stateContext);
    this.HandleDamagePreview(weaponObject, scriptInterface, stateContext);
  }

  protected final func OnTick(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let animFeature: ref<AnimFeature_WeaponHandlingStats>;
    let ownerID: EntityID;
    let statsSystem: ref<StatsSystem>;
    let gameInstance: GameInstance = scriptInterface.GetGame();
    let currentTime: Float = EngineTime.ToFloat(GameInstance.GetSimTime(gameInstance));
    let behindCover: Bool = NotEquals(GameInstance.GetSpatialQueriesSystem(gameInstance).GetPlayerObstacleSystem().GetCoverDirection(scriptInterface.executionOwner), IntEnum(0l));
    if behindCover {
      this.m_timeStamp = currentTime;
      stateContext.SetPermanentFloatParameter(n"TurnOffPublicSafeTimeStamp", this.m_timeStamp, true);
    };
    if WeaponTransition.GetPlayerSpeed(scriptInterface) < 0.10 && stateContext.IsStateActive(n"Locomotion", n"stand") {
      if scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Combat) != EnumInt(gamePSMCombat.InCombat) && !behindCover {
        if this.m_timeStamp + this.GetStaticFloatParameterDefault("timeBetweenIdleBreaks", 20.00) <= currentTime {
          scriptInterface.PushAnimationEvent(n"IdleBreak");
          this.m_timeStamp = currentTime;
        };
      };
    };
    if this.IsHeavyWeaponEmpty(scriptInterface) && !stateContext.GetBoolParameter(n"requestHeavyWeaponUnequip", true) {
      stateContext.SetPermanentBoolParameter(n"requestHeavyWeaponUnequip", true, true);
    };
    statsSystem = GameInstance.GetStatsSystem(gameInstance);
    ownerID = scriptInterface.ownerEntityID;
    animFeature = new AnimFeature_WeaponHandlingStats();
    animFeature.weaponRecoil = statsSystem.GetStatValue(Cast(ownerID), gamedataStatType.RecoilAnimation);
    animFeature.weaponSpread = statsSystem.GetStatValue(Cast(ownerID), gamedataStatType.SpreadAnimation);
    scriptInterface.SetAnimationParameterFeature(n"WeaponHandlingData", animFeature, scriptInterface.executionOwner);
  }

  private final func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Weapon, EnumInt(gamePSMRangedWeaponStates.Default));
    this.ActivateDamageProjection(false, this.GetWeaponObject(scriptInterface), scriptInterface, stateContext);
  }
}

public class NotReadyDecisions extends WeaponReadyListenerTransition {

  protected func UpdateWeaponReadyListenerReturnValue() -> Void {
    this.UpdateWeaponReadyListenerReturnValue();
    this.EnableOnEnterCondition(!this.m_weaponReadyListenerReturnValue);
  }

  protected final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return !this.IsWeaponReadyToShoot(stateContext, scriptInterface);
  }

  protected final const func ExitCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.IsWeaponReadyToShoot(stateContext, scriptInterface);
  }
}

public class NotReadyEvents extends WeaponEventsTransition {

  protected final func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let weaponObject: ref<WeaponObject> = this.GetWeaponObject(scriptInterface);
    this.OnEnterNonChargeState(weaponObject, stateContext, scriptInterface);
    this.EndShootingSequence(weaponObject, stateContext, scriptInterface);
    this.ShowAttackPreview(false, weaponObject, scriptInterface, stateContext);
    scriptInterface.TEMP_WeaponStopFiring();
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Weapon, EnumInt(gamePSMRangedWeaponStates.Default));
    this.ForceUnhideRegularHands(stateContext, scriptInterface);
    DefaultTransition.UpdateAimAssist(stateContext, scriptInterface);
    scriptInterface.GetStatPoolsSystem().RequestSettingStatPoolMinValue(Cast(scriptInterface.ownerEntityID), gamedataStatPoolType.WeaponCharge, scriptInterface.executionOwner);
    if !Cast(scriptInterface.GetQuestsSystem().GetFact(n"block_combat_scripts_tutorials")) {
      this.TutorialSetFact(scriptInterface, n"ranged_combat_tutorial");
    };
  }

  protected final func ForceUnhideRegularHands(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let animFeature: ref<AnimFeature_MeleeData> = new AnimFeature_MeleeData();
    animFeature.shouldHandsDisappear = false;
    scriptInterface.SetAnimationParameterFeature(n"MeleeData", animFeature);
  }
}

public class SafeDecisions extends WeaponTransition {

  protected final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if this.ShouldEnterSafe(stateContext, scriptInterface) {
      return true;
    };
    return false;
  }

  protected final const func ToPublicSafe(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if !this.EnterCondition(stateContext, scriptInterface) {
      return true;
    };
    return false;
  }
}

public class SafeEvents extends WeaponEventsTransition {

  protected final func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let broadcaster: ref<StimBroadcasterComponent>;
    let weaponObject: ref<WeaponObject> = this.GetWeaponObject(scriptInterface);
    this.OnEnterNonChargeState(weaponObject, stateContext, scriptInterface);
    this.ShowAttackPreview(false, weaponObject, scriptInterface, stateContext);
    this.EndShootingSequence(weaponObject, stateContext, scriptInterface);
    scriptInterface.TEMP_WeaponStopFiring();
    stateContext.SetPermanentBoolParameter(n"WeaponInSafe", true, true);
    stateContext.SetTemporaryBoolParameter(ZoomTransitionHelper.GetReevaluateZoomName(), true, true);
    scriptInterface.SetAnimationParameterFloat(n"safe", 1.00);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Weapon, EnumInt(gamePSMRangedWeaponStates.Safe));
    DefaultTransition.UpdateAimAssist(stateContext, scriptInterface);
    broadcaster = scriptInterface.executionOwner.GetStimBroadcasterComponent();
    if IsDefined(broadcaster) {
      broadcaster.TriggerSingleBroadcast(scriptInterface.executionOwner, gamedataStimType.WeaponSafe);
    };
  }

  protected final func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    stateContext.SetTemporaryBoolParameter(ZoomTransitionHelper.GetReevaluateZoomName(), true, true);
  }
}

public class PublicSafeDecisions extends WeaponReadyListenerTransition {

  private let m_isSprinting: Bool;

  private let m_inKereznikov: Bool;

  private let m_inCombat: Bool;

  private let m_inDangerousZone: Bool;

  private let m_inFocusMode: Bool;

  private let m_isInVehicleCombat: Bool;

  private let m_isInVehTurret: Bool;

  private let m_isAiming: Bool;

  private let m_rangedAttackPressed: Bool;

  protected func OnAttach(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let allBlackboardDef: ref<AllBlackboardDefinitions>;
    this.OnAttach(stateContext, scriptInterface);
    allBlackboardDef = GetAllBlackboardDefs();
    this.m_beingCreated = true;
    ArrayPush(this.m_callBackIDs, scriptInterface.localBlackboard.RegisterListenerInt(allBlackboardDef.PlayerStateMachine.Locomotion, this, n"OnLocomotionChanged", true));
    ArrayPush(this.m_callBackIDs, scriptInterface.localBlackboard.RegisterListenerInt(allBlackboardDef.PlayerStateMachine.Combat, this, n"OnCombatChanged", true));
    ArrayPush(this.m_callBackIDs, scriptInterface.localBlackboard.RegisterListenerInt(allBlackboardDef.PlayerStateMachine.Zones, this, n"OnZonesChanged", true));
    ArrayPush(this.m_callBackIDs, scriptInterface.localBlackboard.RegisterListenerInt(allBlackboardDef.PlayerStateMachine.Vision, this, n"OnVisionChanged", true));
    ArrayPush(this.m_callBackIDs, scriptInterface.localBlackboard.RegisterListenerInt(allBlackboardDef.PlayerStateMachine.Vehicle, this, n"OnVehicleChanged", true));
    ArrayPush(this.m_callBackIDs, scriptInterface.localBlackboard.RegisterListenerInt(allBlackboardDef.PlayerStateMachine.UpperBody, this, n"OnUpperBodyChanged", true));
    scriptInterface.executionOwner.RegisterInputListener(this, n"RangedAttack");
    this.m_rangedAttackPressed = scriptInterface.GetActionValue(n"RangedAttack") > 0.00;
    this.m_beingCreated = false;
    this.UpdateShouldOnEnterBeEnabled();
  }

  protected func OnDetach(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnDetach(stateContext, scriptInterface);
    scriptInterface.executionOwner.UnregisterInputListener(this);
  }

  protected final func UpdateShouldOnEnterBeEnabled() -> Void {
    if this.m_beingCreated {
      return;
    };
    if this.m_isSprinting || this.m_inCombat || this.m_inDangerousZone || this.m_inKereznikov || this.m_isInVehicleCombat || this.m_isInVehTurret || this.m_isAiming || this.m_inFocusMode && !this.m_rangedAttackPressed {
      this.EnableOnEnterCondition(false);
      return;
    };
    if !this.m_weaponReadyListenerReturnValue && !(this.m_inFocusMode && !this.m_rangedAttackPressed) {
      this.EnableOnEnterCondition(false);
      return;
    };
    this.EnableOnEnterCondition(true);
  }

  protected func UpdateWeaponReadyListenerReturnValue() -> Void {
    this.UpdateWeaponReadyListenerReturnValue();
    this.UpdateShouldOnEnterBeEnabled();
  }

  protected cb func OnAction(action: ListenerAction, consumer: ListenerActionConsumer) -> Bool {
    this.m_rangedAttackPressed = ListenerAction.GetValue(action) > 0.00;
    this.UpdateShouldOnEnterBeEnabled();
  }

  protected cb func OnLocomotionChanged(value: Int32) -> Bool {
    this.m_isSprinting = value == EnumInt(gamePSMLocomotionStates.Sprint);
    this.m_inKereznikov = value == EnumInt(gamePSMLocomotionStates.Kereznikov);
    this.UpdateShouldOnEnterBeEnabled();
  }

  protected cb func OnCombatChanged(value: Int32) -> Bool {
    this.m_inCombat = value == EnumInt(gamePSMCombat.InCombat);
    this.UpdateShouldOnEnterBeEnabled();
  }

  protected cb func OnZonesChanged(value: Int32) -> Bool {
    this.m_inDangerousZone = value == EnumInt(gamePSMZones.Dangerous);
    this.UpdateShouldOnEnterBeEnabled();
  }

  protected cb func OnVisionChanged(value: Int32) -> Bool {
    this.m_inFocusMode = value == EnumInt(gamePSMVision.Focus);
    this.UpdateShouldOnEnterBeEnabled();
  }

  protected cb func OnVehicleChanged(value: Int32) -> Bool {
    this.m_isInVehicleCombat = value == EnumInt(gamePSMVehicle.Combat);
    this.m_isInVehTurret = value == EnumInt(gamePSMVehicle.Turret);
    this.UpdateShouldOnEnterBeEnabled();
  }

  protected cb func OnUpperBodyChanged(value: Int32) -> Bool {
    this.m_isAiming = value == EnumInt(gamePSMUpperBodyStates.Aim);
    this.UpdateShouldOnEnterBeEnabled();
  }

  protected final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let equippingFromEmptyHandsWithAttack: StateResultBool;
    if this.m_inFocusMode && !this.m_rangedAttackPressed {
      return true;
    };
    if stateContext.GetBoolParameter(n"ForceReadyState", true) {
      return false;
    };
    if this.IsSafeStateForced(stateContext, scriptInterface) {
      return false;
    };
    equippingFromEmptyHandsWithAttack = stateContext.GetPermanentBoolParameter(n"equippingRangedFromEmptyHandsAttack");
    if scriptInterface.GetActionValue(n"RangedAttack") > 0.00 && !(equippingFromEmptyHandsWithAttack.value && equippingFromEmptyHandsWithAttack.valid) {
      return false;
    };
    if !stateContext.GetBoolParameter(n"InPublicZone", true) {
      return false;
    };
    if !this.CompareTimeToPublicSafeTimestamp(stateContext, scriptInterface, this.GetStaticFloatParameterDefault("idleTimeToEnter", 1.00)) {
      return false;
    };
    if stateContext.IsStateMachineActive(n"CombatGadget") {
      return false;
    };
    if stateContext.IsStateMachineActive(n"CarriedObject") && scriptInterface.HasStatFlag(gamedataStatType.CanShootWhileCarryingBody) {
      return false;
    };
    if NotEquals(scriptInterface.GetSpatialQueriesSystem().GetPlayerObstacleSystem().GetCoverDirection(scriptInterface.executionOwner), IntEnum(0l)) {
      return false;
    };
    return this.IsWeaponReadyToShoot(stateContext, scriptInterface);
  }

  protected final const func ToNotReady(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if !this.IsWeaponReadyToShoot(stateContext, scriptInterface) {
      return true;
    };
    return false;
  }

  protected final const func ToPublicSafeToReady(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if this.ShouldLeaveSafe(stateContext, scriptInterface) {
      return true;
    };
    return false;
  }

  protected final const func ToNoAmmo(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if this.GetWeaponObject(scriptInterface).IsMagazineEmpty() && WeaponObject.CanReload(this.GetWeaponObject(scriptInterface)) {
      return true;
    };
    return false;
  }

  private final const func ShouldLeaveSafe(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let isAiming: Bool = scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.UpperBody) == EnumInt(gamePSMUpperBodyStates.Aim);
    let isKereznikowActive: Bool = scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Locomotion) == EnumInt(gamePSMLocomotionStates.Kereznikov);
    if this.IsInFocusMode(scriptInterface) && (scriptInterface.IsActionJustPressed(n"RangedAttack") || scriptInterface.GetActionValue(n"RangedAttack") > 0.00) {
      return true;
    };
    if this.IsInFocusMode(scriptInterface) {
      return false;
    };
    if stateContext.GetBoolParameter(n"ForceReadyState", true) {
      return true;
    };
    if isKereznikowActive {
      return true;
    };
    if scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Combat) == EnumInt(gamePSMCombat.InCombat) {
      return true;
    };
    if scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Zones) == EnumInt(gamePSMZones.Dangerous) {
      return true;
    };
    if scriptInterface.GetActionValue(n"RangedAttack") > 0.00 {
      return true;
    };
    if isAiming {
      return true;
    };
    if scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.CombatGadget) >= EnumInt(gamePSMCombatGadget.Equipped) {
      return true;
    };
    if NotEquals(scriptInterface.GetSpatialQueriesSystem().GetPlayerObstacleSystem().GetCoverDirection(scriptInterface.executionOwner), IntEnum(0l)) {
      return true;
    };
    if stateContext.IsStateMachineActive(n"CarriedObject") && scriptInterface.HasStatFlag(gamedataStatType.CanShootWhileCarryingBody) {
      return true;
    };
    return false;
  }
}

public class PublicSafeEvents extends WeaponEventsTransition {

  @default(PublicSafeEvents, false)
  public let m_weaponUnequipRequestSent: Bool;

  protected final func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let broadcaster: ref<StimBroadcasterComponent>;
    let weaponObject: ref<WeaponObject> = this.GetWeaponObject(scriptInterface);
    this.OnEnterNonChargeState(weaponObject, stateContext, scriptInterface);
    this.EndShootingSequence(weaponObject, stateContext, scriptInterface);
    this.ShowAttackPreview(false, weaponObject, scriptInterface, stateContext);
    scriptInterface.TEMP_WeaponStopFiring();
    stateContext.SetPermanentBoolParameter(n"WeaponInSafe", true, true);
    scriptInterface.SetAnimationParameterFloat(n"safe", 1.00);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Weapon, EnumInt(gamePSMRangedWeaponStates.Safe));
    DefaultTransition.UpdateAimAssist(stateContext, scriptInterface);
    broadcaster = scriptInterface.executionOwner.GetStimBroadcasterComponent();
    if IsDefined(broadcaster) {
      broadcaster.TriggerSingleBroadcast(scriptInterface.executionOwner, gamedataStimType.WeaponSafe);
    };
    stateContext.SetPermanentBoolParameter(n"equippingRangedFromEmptyHandsAttack", false, true);
    this.m_weaponUnequipRequestSent = false;
  }

  protected final func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.RequestWeaponUnequipNotifyUpperBody(stateContext, scriptInterface);
  }

  private final func RequestWeaponUnequipNotifyUpperBody(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    if !this.m_weaponUnequipRequestSent && this.GetStaticFloatParameterDefault("timeToAutoUnequipWeapon", 0.00) > 0.00 && this.GetInStateTime() >= this.GetStaticFloatParameterDefault("timeToAutoUnequipWeapon", 0.00) {
      this.SendEquipmentSystemWeaponManipulationRequest(scriptInterface, EquipmentManipulationAction.UnequipWeapon);
      this.m_weaponUnequipRequestSent = true;
    };
  }

  protected final func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void;

  protected final func OnExitToNotReady(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void;
}

public class PublicSafeToReadyDecisions extends WeaponTransition {

  protected final const func ToReady(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.GetInStateTime() > this.GetStaticFloatParameterDefault("transitionDuration", 0.30);
  }
}

public class PublicSafeToReadyEvents extends WeaponEventsTransition {

  protected final func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    scriptInterface.SetAnimationParameterFloat(n"safe", 0.00);
    stateContext.SetPermanentBoolParameter(n"WeaponInSafe", false, true);
  }

  protected final func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    stateContext.SetPermanentFloatParameter(n"TurnOffPublicSafeTimeStamp", EngineTime.ToFloat(GameInstance.GetSimTime(scriptInterface.GetGame())), true);
  }
}

public class QuickMeleeDecisions extends WeaponTransition {

  protected final func OnAttach(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    scriptInterface.executionOwner.RegisterInputListener(this, n"QuickMelee");
    this.EnableOnEnterCondition(false);
  }

  protected final func OnDetach(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    scriptInterface.executionOwner.UnregisterInputListener(this);
  }

  protected cb func OnAction(action: ListenerAction, consumer: ListenerActionConsumer) -> Bool {
    this.EnableOnEnterCondition(ListenerAction.IsButtonJustReleased(action));
  }

  protected final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let isCarrying: Bool;
    let statusEffectRecordData: wref<StatusEffectPlayerData_Record> = this.GetStatusEffectRecordData(stateContext);
    this.EnableOnEnterCondition(false);
    if scriptInterface.IsActionJustTapped(n"QuickMelee") {
      if StatusEffectSystem.ObjectHasStatusEffectWithTag(scriptInterface.executionOwner, n"NoQuickMelee") {
        return false;
      };
      if !(statusEffectRecordData == null) && (statusEffectRecordData.ForceSafeWeapon() || statusEffectRecordData.JamWeapon()) {
        return false;
      };
      if this.GetStaticBoolParameterDefault("disable", false) {
        return false;
      };
      if GameObject.IsCooldownActive(scriptInterface.owner, n"QuickMelee") {
        return false;
      };
      if stateContext.IsStateMachineActive(n"Consumable") || stateContext.IsStateMachineActive(n"CombatGadget") || this.IsInFocusMode(scriptInterface) {
        return false;
      };
      isCarrying = scriptInterface.localBlackboard.GetBool(GetAllBlackboardDefs().PlayerStateMachine.Carrying);
      if isCarrying {
        return false;
      };
      if this.IsInSafeSceneTier(scriptInterface) {
        return false;
      };
      return true;
    };
    return false;
  }

  protected final const func ToStandardExit(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if this.GetInStateTime() >= this.GetStaticFloatParameterDefault("duration", 1.00) {
      return true;
    };
    return false;
  }

  protected final const func ToSemiAuto(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.ToSemiAutoTransitionCondition(stateContext, scriptInterface);
  }

  protected final const func ToFullAuto(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.ToFullAutoTransitionCondition(stateContext, scriptInterface);
  }

  protected final const func ExitCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.IsPassedCancelWindow(stateContext, scriptInterface);
  }

  protected final const func IsPassedCancelWindow(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let cancelWindow: StateResultFloat = stateContext.GetPermanentFloatParameter(n"QuickMeleeCancelWindow");
    if cancelWindow.valid && EngineTime.ToFloat(GameInstance.GetSimTime(scriptInterface.GetGame())) >= cancelWindow.value {
      return true;
    };
    return false;
  }
}

public class QuickMeleeEvents extends WeaponEventsTransition {

  public let m_gameEffect: ref<EffectInstance>;

  public let m_targetObject: wref<GameObject>;

  public let m_targetComponent: ref<IPlacedComponent>;

  @default(QuickMeleeEvents, false)
  public let m_quickMeleeAttackCreated: Bool;

  public let m_quickMeleeAttackData: QuickMeleeAttackData;

  protected final func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let broadcaster: ref<StimBroadcasterComponent>;
    this.m_quickMeleeAttackCreated = false;
    scriptInterface.TEMP_WeaponStopFiring();
    broadcaster = scriptInterface.executionOwner.GetStimBroadcasterComponent();
    if IsDefined(broadcaster) {
      broadcaster.TriggerSingleBroadcast(scriptInterface.executionOwner, gamedataStimType.MeleeAttack);
    };
    stateContext.SetPermanentBoolParameter(n"VisionToggled", false, true);
    this.ForceDisableVisionMode(stateContext);
    stateContext.SetTemporaryBoolParameter(n"InterruptSprint", true, true);
    stateContext.SetPermanentFloatParameter(n"TurnOffPublicSafeTimeStamp", scriptInterface.GetNow(), true);
    stateContext.SetPermanentBoolParameter(n"WeaponInSafe", false, true);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Weapon, EnumInt(gamePSMRangedWeaponStates.QuickMelee));
    DefaultTransition.UpdateAimAssist(stateContext, scriptInterface);
    this.SendAnimFeature(stateContext, scriptInterface, 1);
    scriptInterface.PushAnimationEvent(n"QuickMelee");
    DefaultTransition.PlayRumble(scriptInterface, this.GetStaticStringParameterDefault("rumbleOnEnter", "light_fast"));
    this.GetWeaponObject(scriptInterface).SetAttack(this.GetQuickMeleeAttackTweakID(scriptInterface));
    this.GetAttackParameters(scriptInterface);
    if this.m_quickMeleeAttackData.forcePlayerToStand {
      stateContext.SetConditionBoolParameter(n"CrouchToggled", false, true);
    };
    this.ConsumeStamina(scriptInterface);
    this.AdjustPlayerPosition(stateContext, scriptInterface, this.GetQuickMeleeTarget(scriptInterface, this.m_quickMeleeAttackData.adjustmentRange), this.m_quickMeleeAttackData.adjustmentDuration, this.m_quickMeleeAttackData.adjustmentRadius, this.m_quickMeleeAttackData.adjustmentCurve);
    stateContext.SetPermanentFloatParameter(n"QuickMeleeCancelWindow", EngineTime.ToFloat(GameInstance.GetSimTime(scriptInterface.GetGame())) + this.m_quickMeleeAttackData.duration, true);
  }

  protected final func ConsumeStamina(scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let staminaCost: Float;
    let staminaCostMods: array<wref<StatModifier_Record>>;
    let attackRecord: wref<Attack_Melee_Record> = TweakDBInterface.GetAttack_GameEffectRecord(this.GetQuickMeleeAttackTweakID(scriptInterface)) as Attack_Melee_Record;
    attackRecord.StaminaCost(staminaCostMods);
    staminaCost = RPGManager.CalculateStatModifiers(staminaCostMods, scriptInterface.GetGame(), scriptInterface.owner, Cast(scriptInterface.ownerEntityID));
    if staminaCost > 0.00 {
      PlayerStaminaHelpers.ModifyStamina(scriptInterface.executionOwner as PlayerPuppet, -staminaCost);
    };
  }

  protected final func InitiateQuickMeleeAttack(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let colliderBox: Vector4;
    let endPosition: Vector4;
    let startPosition: Vector4;
    startPosition.X = 0.00;
    startPosition.Y = 0.00;
    startPosition.Z = 0.00;
    endPosition.X = 0.00;
    endPosition.Y = this.m_quickMeleeAttackData.attackRange;
    endPosition.Z = 0.00;
    let dir: Vector4 = endPosition - startPosition;
    colliderBox.X = 0.30;
    colliderBox.Y = 0.30;
    colliderBox.Z = 0.30;
    let attackTime: Float = this.m_quickMeleeAttackData.attackGameEffectDuration;
    if dir.Y != 0.00 {
      endPosition.Y = this.m_quickMeleeAttackData.attackRange;
    };
    this.SpawnQuickMeleeGameEffect(stateContext, scriptInterface, startPosition, endPosition, attackTime, colliderBox);
  }

  protected final func GetQuickMeleeTarget(scriptInterface: ref<StateGameScriptInterface>, opt withinDistance: Float) -> ref<GameObject> {
    let angleOut: EulerAngles;
    let targetingSystem: ref<TargetingSystem> = scriptInterface.GetTargetingSystem();
    this.m_targetComponent = targetingSystem.GetComponentClosestToCrosshair(scriptInterface.executionOwner, angleOut, TSQ_NPC());
    this.m_targetObject = scriptInterface.GetObjectFromComponent(this.m_targetComponent);
    if this.m_targetObject.IsPuppet() && ScriptedPuppet.IsAlive(this.m_targetObject) && !ScriptedPuppet.IsDefeated(this.m_targetObject) && (Equals(GameObject.GetAttitudeTowards(this.m_targetObject, scriptInterface.executionOwner), EAIAttitude.AIA_Neutral) || Equals(GameObject.GetAttitudeTowards(this.m_targetObject, scriptInterface.executionOwner), EAIAttitude.AIA_Hostile)) {
      if withinDistance <= 0.00 || Vector4.Distance(scriptInterface.executionOwner.GetWorldPosition(), this.m_targetObject.GetWorldPosition()) <= withinDistance {
        return this.m_targetObject;
      };
    };
    return null;
  }

  protected final func SpawnQuickMeleeGameEffect(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>, startPosition: Vector4, endPosition: Vector4, attackTime: Float, colliderBox: Vector4) -> Void {
    let attack: ref<Attack_GameEffect>;
    let effect: ref<EffectInstance>;
    let initContext: AttackInitContext;
    let cameraWorldTransform: Transform = scriptInterface.GetCameraWorldTransform();
    let attackStartPositionWorld: Vector4 = Transform.TransformPoint(cameraWorldTransform, startPosition);
    attackStartPositionWorld.W = 0.00;
    let attackEndPositionWorld: Vector4 = Transform.TransformPoint(cameraWorldTransform, endPosition);
    attackEndPositionWorld.W = 0.00;
    let attackDirectionWorld: Vector4 = attackEndPositionWorld - attackStartPositionWorld;
    let weapon: ref<WeaponObject> = this.GetWeaponObject(scriptInterface);
    this.PlaySound(n"Quickmelee_guns", scriptInterface);
    initContext.record = TweakDBInterface.GetAttack_GameEffectRecord(this.GetQuickMeleeAttackTweakID(scriptInterface));
    initContext.source = scriptInterface.executionOwner;
    initContext.instigator = scriptInterface.executionOwner;
    initContext.weapon = weapon;
    attack = IAttack.Create(initContext) as Attack_GameEffect;
    effect = attack.PrepareAttack(scriptInterface.executionOwner);
    EffectData.SetVector(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.box, colliderBox);
    EffectData.SetFloat(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.duration, attackTime);
    EffectData.SetVector(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.position, attackStartPositionWorld);
    EffectData.SetQuat(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.rotation, Transform.GetOrientation(cameraWorldTransform));
    EffectData.SetVector(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.forward, Vector4.Normalize(attackDirectionWorld));
    EffectData.SetFloat(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.range, Vector4.Length(attackDirectionWorld));
    EffectData.SetVariant(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.fxPackage, ToVariant(weapon.GetFxPackageQuickMelee()));
    EffectData.SetBool(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.playerOwnedWeapon, true);
    this.m_gameEffect = effect;
    attack.StartAttack();
    this.PlayEffect(TDB.GetCName(this.GetQuickMeleeAttackTweakID(scriptInterface) + t".vfxName"), scriptInterface);
  }

  protected final func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.UpdateInputBuffer(stateContext, scriptInterface);
    if !this.m_quickMeleeAttackCreated && this.GetInStateTime() >= this.GetStaticFloatParameterDefault("attackGameEffectDelay", 0.00) {
      this.InitiateQuickMeleeAttack(stateContext, scriptInterface);
      this.m_quickMeleeAttackCreated = true;
    };
    if this.m_quickMeleeAttackCreated {
      this.UpdateGameEffectPosition(stateContext, scriptInterface);
    };
  }

  protected final func UpdateGameEffectPosition(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    startPosition.X = 0.00;
    startPosition.Y = 0.00;
    startPosition.Z = 0.00;
    endPosition.X = 0.00;
    endPosition.Y = this.m_quickMeleeAttackData.attackRange;
    endPosition.Z = 0.00;
    let cameraWorldTransform: Transform = scriptInterface.GetCameraWorldTransform();
    let startPosition: Vector4 = startPosition;
    let endPosition: Vector4 = endPosition;
    startPosition = startPosition;
    EffectData.SetVector(this.m_gameEffect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.position, Transform.TransformPoint(cameraWorldTransform, startPosition));
  }

  protected final func GetAttackParameters(scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let recordID: TweakDBID = this.GetQuickMeleeAttackTweakID(scriptInterface);
    this.m_quickMeleeAttackData.attackGameEffectDelay = TDB.GetFloat(recordID + t".attackGameEffectDelay");
    this.m_quickMeleeAttackData.attackGameEffectDuration = TDB.GetFloat(recordID + t".attackGameEffectDuration");
    this.m_quickMeleeAttackData.attackRange = TDB.GetFloat(recordID + t".attackRange");
    this.m_quickMeleeAttackData.forcePlayerToStand = TDB.GetBool(recordID + t".forcePlayerToStand");
    this.m_quickMeleeAttackData.shouldAdjust = TDB.GetBool(recordID + t".shouldAdjust");
    this.m_quickMeleeAttackData.adjustmentRange = TDB.GetFloat(recordID + t".adjustmentRange");
    this.m_quickMeleeAttackData.adjustmentDuration = TDB.GetFloat(recordID + t".adjustmentDuration");
    this.m_quickMeleeAttackData.adjustmentRadius = TDB.GetFloat(recordID + t".adjustmentRadius");
    this.m_quickMeleeAttackData.adjustmentCurve = TDB.GetCName(recordID + t".adjustmentCurve");
    this.m_quickMeleeAttackData.cooldown = TDB.GetFloat(recordID + t".cooldown");
    this.m_quickMeleeAttackData.duration = TDB.GetFloat(recordID + t".duration");
  }

  protected final func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let attackID: TweakDBID;
    this.SendAnimFeature(stateContext, scriptInterface, 0);
    attackID = this.GetDesiredAttackRecord(stateContext, scriptInterface).GetID();
    this.GetWeaponObject(scriptInterface).SetAttack(attackID);
    GameObject.StartCooldown(scriptInterface.owner, n"QuickMelee", this.m_quickMeleeAttackData.cooldown);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Weapon, EnumInt(gamePSMRangedWeaponStates.Default));
    DefaultTransition.UpdateAimAssist(stateContext, scriptInterface);
  }

  public func OnForcedExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let attackID: TweakDBID;
    this.SendAnimFeature(stateContext, scriptInterface, 0);
    attackID = this.GetDesiredAttackRecord(stateContext, scriptInterface).GetID();
    this.GetWeaponObject(scriptInterface).SetAttack(attackID);
    GameObject.StartCooldown(scriptInterface.owner, n"QuickMelee", this.m_quickMeleeAttackData.cooldown);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Weapon, EnumInt(gamePSMRangedWeaponStates.Default));
    DefaultTransition.UpdateAimAssist(stateContext, scriptInterface);
  }

  protected final func SendAnimFeature(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>, state: Int32) -> Void {
    let animFeature: ref<AnimFeature_QuickMelee> = new AnimFeature_QuickMelee();
    animFeature.state = state;
    scriptInterface.SetAnimationParameterFeature(n"QuickMelee", animFeature);
  }

  protected final func GetQuickMeleeAttackTweakID(scriptInterface: ref<StateGameScriptInterface>) -> TweakDBID {
    let attackName: String;
    let record: ref<Attack_Record>;
    let attacks: array<ref<IAttack>> = this.GetWeaponObject(scriptInterface).GetAttacks();
    let i: Int32 = 0;
    while i < ArraySize(attacks) {
      record = attacks[i].GetRecord();
      attackName = record.AttackType().Name();
      if Equals(attackName, "QuickMelee") {
        return record.GetID();
      };
      i += 1;
    };
    return TDBID.undefined();
  }
}

public class NoAmmoDecisions extends WeaponTransition {

  private let m_callbackID: ref<CallbackHandle>;

  protected final func OnAttach(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let allBlackboardDef: ref<AllBlackboardDefinitions>;
    let weapon: ref<WeaponObject> = scriptInterface.owner as WeaponObject;
    let bb: ref<IBlackboard> = weapon.GetSharedData();
    if IsDefined(bb) && IsDefined(weapon) {
      allBlackboardDef = GetAllBlackboardDefs();
      this.m_callbackID = bb.RegisterListenerUint(allBlackboardDef.Weapon.MagazineAmmoCount, this, n"OnAmmoCountChanged");
      this.OnAmmoCountChanged(bb.GetUint(allBlackboardDef.Weapon.MagazineAmmoCount));
    };
  }

  protected final func OnDetach(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.m_callbackID = null;
  }

  protected cb func OnAmmoCountChanged(value: Uint32) -> Bool {
    this.EnableOnEnterCondition(value == 0u);
  }

  protected final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let isSwitchingItems: Bool = scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.UpperBody) == EnumInt(gamePSMUpperBodyStates.SwitchItems);
    return !isSwitchingItems;
  }

  protected final const func ToReady(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return !this.GetWeaponObject(scriptInterface).IsMagazineEmpty();
  }

  protected final const func ExitCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if scriptInterface.IsActionJustTapped(n"QuickMelee") {
      return true;
    };
    if !this.GetWeaponObject(scriptInterface).IsMagazineEmpty() || !WeaponObject.CanReload(this.GetWeaponObject(scriptInterface)) {
      return false;
    };
    return true;
  }

  protected final const func ToReload(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let weaponObject: ref<WeaponObject> = this.GetWeaponObject(scriptInterface);
    if !WeaponObject.CanReload(weaponObject) {
      return false;
    };
    if !scriptInterface.HasStatFlag(gamedataStatType.CanWeaponReloadWhileSprinting) && scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Locomotion) == EnumInt(gamePSMLocomotionStates.Sprint) {
      return false;
    };
    if !scriptInterface.HasStatFlag(gamedataStatType.CanWeaponReloadWhileVaulting) && stateContext.IsStateActive(n"Locomotion", n"vault") {
      return false;
    };
    if !scriptInterface.HasStatFlag(gamedataStatType.CanWeaponReloadWhileSliding) && stateContext.IsStateActive(n"Locomotion", n"slide") {
      return false;
    };
    if scriptInterface.IsActionJustPressed(n"RangedAttack") {
      return true;
    };
    if Equals(weaponObject.GetWeaponRecord().ItemType().Type(), gamedataItemType.Wea_SniperRifle) {
      return !stateContext.IsStateActive(n"UpperBody", n"aimingState");
    };
    return this.GetInStateTime() > this.GetStaticFloatParameterDefault("timeToAutoReload", 0.30);
  }

  protected final const func ToPublicSafe(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return !WeaponObject.CanReload(this.GetWeaponObject(scriptInterface));
  }
}

public class NoAmmoEvents extends WeaponEventsTransition {

  protected final func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let weaponObject: ref<WeaponObject> = this.GetWeaponObject(scriptInterface);
    let weaponRecord: ref<WeaponItem_Record> = weaponObject.GetWeaponRecord();
    scriptInterface.TEMP_WeaponStopFiring();
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Weapon, EnumInt(gamePSMRangedWeaponStates.NoAmmo));
    scriptInterface.SetAnimationParameterFloat(n"empty_clip", 1.00);
    this.OnEnterNonChargeState(weaponObject, stateContext, scriptInterface);
    this.ShowAttackPreview(false, weaponObject, scriptInterface, stateContext);
    scriptInterface.GetStatPoolsSystem().RequestSettingStatPoolMinValue(Cast(weaponObject.GetEntityID()), gamedataStatPoolType.WeaponCharge, scriptInterface.executionOwner);
    if (weaponObject.GetItemData().HasTag(n"DiscardOnEmpty") || Equals(weaponRecord.EquipArea().Type(), gamedataEquipmentArea.WeaponHeavy)) && !stateContext.IsStateActive(n"UpperBody", n"temporaryUnequip") {
      this.SendEquipmentSystemWeaponManipulationRequest(scriptInterface, EquipmentManipulationAction.CycleNextWeaponWheelItem, gameEquipAnimationType.Default);
    };
    WeaponObject.TriggerWeaponEffects(scriptInterface.owner as WeaponObject, gamedataFxAction.EnterNoAmmo);
  }

  protected final func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let dryFireEvent: ref<AudioEvent>;
    if scriptInterface.IsActionJustPressed(n"RangedAttack") {
      dryFireEvent = new AudioEvent();
      dryFireEvent.eventName = n"dry_fire";
      this.GetWeaponObject(scriptInterface).QueueEvent(dryFireEvent);
    };
  }

  protected final func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    WeaponObject.TriggerWeaponEffects(scriptInterface.owner as WeaponObject, gamedataFxAction.ExitNoAmmo);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Weapon, EnumInt(gamePSMRangedWeaponStates.Default));
  }
}

public class ReloadDecisions extends WeaponTransition {

  protected final func OnAttach(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    scriptInterface.executionOwner.RegisterInputListener(this, n"Reload");
  }

  protected final func OnDetach(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    scriptInterface.executionOwner.UnregisterInputListener(this);
  }

  protected cb func OnAction(action: ListenerAction, consumer: ListenerActionConsumer) -> Bool {
    this.EnableOnEnterCondition(true);
  }

  protected final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let inputBuffered: Bool = stateContext.GetConditionBool(n"RealodInputPressed") && stateContext.GetConditionFloat(n"RealodInputPressBuffer") > EngineTime.ToFloat(GameInstance.GetSimTime(scriptInterface.GetGame()));
    if scriptInterface.IsActionJustTapped(n"Reload") || inputBuffered {
      if WeaponObject.CanReload(scriptInterface.owner as WeaponObject) {
        if scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Vision) != EnumInt(gamePSMVision.Default) {
          return false;
        };
        if scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.CombatGadget) == EnumInt(gamePSMCombatGadget.Charging) {
          return false;
        };
        if scriptInterface.localBlackboard.GetBool(GetAllBlackboardDefs().PlayerStateMachine.SceneAimForced) {
          return false;
        };
        if !scriptInterface.HasStatFlag(gamedataStatType.CanWeaponReloadWhileSliding) && this.IsInSlidingState(stateContext) {
          return false;
        };
        if !scriptInterface.HasStatFlag(gamedataStatType.CanWeaponReloadWhileVaulting) && stateContext.IsStateActive(n"Locomotion", n"vault") {
          return false;
        };
        if stateContext.IsStateMachineActive(n"Consumable") {
          return false;
        };
        return true;
      };
    } else {
      this.EnableOnEnterCondition(false);
    };
    return false;
  }

  protected final const func ExitCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if this.IsReloadDurationComplete(stateContext, scriptInterface) {
      if stateContext.GetBoolParameter(n"FinishedReload") {
        return true;
      };
    };
    if stateContext.GetBoolParameter(n"InterruptReload") && !this.IsReloadUninterruptible(stateContext, scriptInterface) {
      return true;
    };
    if scriptInterface.IsActionJustPressed(n"RangedAttack") && Cast(scriptInterface.GetStatsSystem().GetStatValue(Cast(scriptInterface.ownerEntityID), gamedataStatType.ReloadAmount)) > 0 {
      if !this.GetWeaponObject(scriptInterface).IsMagazineEmpty() && !this.IsReloadUninterruptible(stateContext, scriptInterface) {
        return true;
      };
    };
    if scriptInterface.IsActionJustPressed(n"QuickMelee") && !GameObject.IsCooldownActive(scriptInterface.owner, n"QuickMelee") {
      return true;
    };
    if !scriptInterface.HasStatFlag(gamedataStatType.CanWeaponReloadWhileVaulting) && stateContext.IsStateActive(n"Locomotion", n"vault") {
      return true;
    };
    return false;
  }

  protected final const func ToReload(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if !this.IsReloadDurationComplete(stateContext, scriptInterface) {
      return false;
    };
    if scriptInterface.GetActionValue(n"AttackB") > 0.00 {
      return false;
    };
    return WeaponObject.CanReload(this.GetWeaponObject(scriptInterface));
  }

  protected final const func ToSemiAuto(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.ToSemiAutoTransitionCondition(stateContext, scriptInterface);
  }

  protected final const func ToFullAuto(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.ToFullAutoTransitionCondition(stateContext, scriptInterface);
  }
}

public class ReloadEvents extends WeaponEventsTransition {

  public let m_statListener: ref<DefaultTransitionStatListener>;

  public let m_randomSync: ref<AnimFeature_SelectRandomAnimSync>;

  public let m_animReloadData: ref<AnimFeature_WeaponReload>;

  public let m_animReloadSpeed: ref<AnimFeature_WeaponReloadSpeedData>;

  public let m_bbCallbackID: ref<CallbackHandle>;

  public let m_weaponRecord: ref<WeaponItem_Record>;

  public let m_animReloadDataDirty: Bool;

  public let m_animReloadSpeedDirty: Bool;

  public let m_uninteruptibleSet: Bool;

  public let m_weaponHasAutoLoader: Bool;

  public let m_canReloadWhileSprinting: Bool;

  public let m_magazineEmpty: Bool;

  public let m_lastReloadWasEmpty: Bool;

  protected final func OnAttach(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let allBlackboardDef: ref<AllBlackboardDefinitions>;
    let statsSystem: ref<StatsSystem> = scriptInterface.GetStatsSystem();
    let weapon: ref<WeaponObject> = scriptInterface.owner as WeaponObject;
    this.m_weaponRecord = weapon.GetWeaponRecord();
    let bb: ref<IBlackboard> = weapon.GetSharedData();
    if IsDefined(bb) && IsDefined(weapon) {
      allBlackboardDef = GetAllBlackboardDefs();
      this.m_bbCallbackID = bb.RegisterListenerUint(allBlackboardDef.Weapon.MagazineAmmoCount, this, n"OnAmmoCountChanged", true);
    };
    this.m_statListener = new DefaultTransitionStatListener();
    this.m_statListener.m_transitionOwner = this;
    statsSystem.RegisterListener(Cast(scriptInterface.ownerEntityID), this.m_statListener);
    statsSystem.RegisterListener(Cast(scriptInterface.executionOwner.GetEntityID()), this.m_statListener);
    this.m_canReloadWhileSprinting = scriptInterface.HasStatFlag(gamedataStatType.CanWeaponReloadWhileSprinting);
    this.m_weaponHasAutoLoader = scriptInterface.HasStatFlagOwner(gamedataStatType.WeaponHasAutoloader, scriptInterface.owner);
    this.m_animReloadData = new AnimFeature_WeaponReload();
    this.m_animReloadSpeed = new AnimFeature_WeaponReloadSpeedData();
    this.m_animReloadData.amountToReload = Cast(statsSystem.GetStatValue(Cast(scriptInterface.ownerEntityID), gamedataStatType.ReloadAmount));
    this.m_animReloadData.loopDuration = statsSystem.GetStatValue(Cast(scriptInterface.ownerEntityID), gamedataStatType.ReloadTime);
    this.m_animReloadData.emptyDuration = statsSystem.GetStatValue(Cast(scriptInterface.ownerEntityID), gamedataStatType.EmptyReloadTime);
    this.m_animReloadSpeed.reloadSpeed = this.GetReloadAnimSpeed(gamedataStatType.ReloadTime, this.m_weaponRecord);
    this.m_animReloadSpeed.emptyReloadSpeed = this.GetReloadAnimSpeed(gamedataStatType.EmptyReloadTime, this.m_weaponRecord);
    this.m_animReloadDataDirty = true;
    this.m_animReloadSpeedDirty = true;
    this.UpdateIsEmptyReload();
  }

  protected func OnDetach(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    scriptInterface.GetStatsSystem().UnregisterListener(Cast(scriptInterface.ownerEntityID), this.m_statListener);
    scriptInterface.GetStatsSystem().UnregisterListener(Cast(scriptInterface.executionOwner.GetEntityID()), this.m_statListener);
    this.m_bbCallbackID = null;
  }

  protected final func UpdateIsEmptyReload() -> Void {
    this.m_animReloadData.emptyReload = this.m_magazineEmpty && !this.m_weaponHasAutoLoader;
  }

  protected cb func OnAmmoCountChanged(value: Uint32) -> Bool {
    let magazineEmpty: Bool = value == 0u;
    if NotEquals(magazineEmpty, this.m_magazineEmpty) {
      this.m_magazineEmpty = magazineEmpty;
      this.UpdateIsEmptyReload();
    };
  }

  public func OnStatChanged(ownerID: StatsObjectID, statType: gamedataStatType, diff: Float, value: Float) -> Void {
    if Equals(statType, gamedataStatType.WeaponHasAutoloader) {
      this.m_weaponHasAutoLoader = value > 0.00;
      this.UpdateIsEmptyReload();
    } else {
      if Equals(statType, gamedataStatType.ReloadAmount) {
        this.m_animReloadData.amountToReload = Cast(value);
        this.m_animReloadDataDirty = true;
      } else {
        if Equals(statType, gamedataStatType.ReloadTime) {
          this.m_animReloadData.loopDuration = value;
          this.m_animReloadSpeed.reloadSpeed = this.GetReloadAnimSpeed(gamedataStatType.ReloadTime, this.m_weaponRecord);
          this.m_animReloadDataDirty = true;
          this.m_animReloadSpeedDirty = true;
        } else {
          if Equals(statType, gamedataStatType.EmptyReloadTime) {
            this.m_animReloadData.emptyDuration = value;
            this.m_animReloadSpeed.emptyReloadSpeed = this.GetReloadAnimSpeed(gamedataStatType.EmptyReloadTime, this.m_weaponRecord);
            this.m_animReloadDataDirty = true;
            this.m_animReloadSpeedDirty = true;
          } else {
            if Equals(statType, gamedataStatType.CanWeaponReloadWhileSprinting) {
              this.m_canReloadWhileSprinting = value > 0.00;
            };
          };
        };
      };
    };
  }

  protected final const func GetReloadAnimSpeed(const statType: gamedataStatType, weaponRecord: ref<WeaponItem_Record>) -> Float {
    let baseVal: Float;
    let statVal: Float;
    if Equals(statType, gamedataStatType.ReloadTime) {
      baseVal = weaponRecord.BaseReloadTime();
      statVal = this.m_animReloadData.loopDuration;
    } else {
      if Equals(statType, gamedataStatType.EmptyReloadTime) {
        baseVal = weaponRecord.BaseEmptyReloadTime();
        statVal = this.m_animReloadData.emptyDuration;
      };
    };
    if baseVal > 0.00 && statVal > 0.00 {
      return baseVal / statVal;
    };
    return 1.00;
  }

  protected final func ActivateReloadAnimData(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    if !this.m_animReloadData.continueLoop {
      scriptInterface.PushAnimationEvent(n"Reload");
    } else {
      scriptInterface.PushAnimationEvent(n"ReloadLoop");
    };
    scriptInterface.SetAnimationParameterBool(n"is_reload_active", true);
    if this.m_animReloadDataDirty {
      scriptInterface.SetAnimationParameterFeature(n"ReloadData", this.m_animReloadData);
      this.m_animReloadDataDirty = false;
    };
    if this.m_animReloadSpeedDirty {
      scriptInterface.SetAnimationParameterFeature(n"ReloadSpeed", this.m_animReloadSpeed);
      this.m_animReloadSpeedDirty = false;
    };
  }

  protected final func DeactivateReloadAnimData(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    scriptInterface.SetAnimationParameterBool(n"is_reload_active", false);
  }

  protected final func RefreshReloadPermanentFloats(stateContext: ref<StateContext>) -> Void {
    if this.m_animReloadDataDirty {
      if this.m_animReloadData.emptyReload {
        stateContext.SetPermanentFloatParameter(n"uninterruptibleReloadTimeStamp", this.m_weaponRecord.UninterruptibleEmptyReloadStart() / this.m_animReloadSpeed.emptyReloadSpeed, true);
        stateContext.SetPermanentFloatParameter(n"ReloadLogicalDuration", this.m_animReloadData.emptyDuration, true);
      } else {
        stateContext.SetPermanentFloatParameter(n"uninterruptibleReloadTimeStamp", this.m_weaponRecord.UninterruptibleReloadStart() / this.m_animReloadSpeed.reloadSpeed, true);
        stateContext.SetPermanentFloatParameter(n"ReloadLogicalDuration", this.m_animReloadData.loopDuration, true);
      };
    };
  }

  protected final func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let weapon: ref<WeaponObject> = this.GetWeaponObject(scriptInterface);
    if NotEquals(this.m_lastReloadWasEmpty, this.m_animReloadData.emptyReload) {
      this.m_lastReloadWasEmpty = this.m_animReloadData.emptyReload;
      this.m_animReloadDataDirty = true;
    };
    this.ShowAttackPreview(false, weapon, scriptInterface, stateContext);
    this.m_uninteruptibleSet = false;
    this.SetUninteruptibleReloadParams(stateContext, true);
    if this.m_animReloadData.emptyReload {
      weapon.StartReload(this.m_animReloadData.emptyDuration);
    } else {
      weapon.StartReload(this.m_animReloadData.loopDuration);
    };
    this.RefreshReloadPermanentFloats(stateContext);
    this.OnEnterNonChargeState(weapon, stateContext, scriptInterface);
    this.EndShootingSequence(weapon, stateContext, scriptInterface);
    scriptInterface.TEMP_WeaponStopFiring();
    stateContext.SetConditionBoolParameter(n"RealodInputPressed", false, true);
    stateContext.SetTemporaryBoolParameter(n"InterruptAiming", true, true);
    if !this.m_canReloadWhileSprinting {
      stateContext.SetTemporaryBoolParameter(n"InterruptSprint", true, true);
    };
    if !IsDefined(this.m_randomSync) {
      this.m_randomSync = new AnimFeature_SelectRandomAnimSync();
      this.m_randomSync.value = -1;
    };
    this.m_randomSync.value = RandDifferent(this.m_randomSync.value, 3);
    if IsDefined(this.m_randomSync) {
      scriptInterface.SetAnimationParameterFeature(n"RandomSync", this.m_randomSync);
    };
    this.ActivateReloadAnimData(stateContext, scriptInterface);
    WeaponObject.TriggerWeaponEffects(weapon, gamedataFxAction.EnterReload);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Weapon, EnumInt(gamePSMRangedWeaponStates.Reload));
  }

  protected final func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let interruptReload: Bool;
    let logicalDuration: StateResultFloat;
    if !stateContext.GetBoolParameter(n"FinishedReload") {
      logicalDuration = stateContext.GetPermanentFloatParameter(n"ReloadLogicalDuration");
      if logicalDuration.valid {
        if this.GetInStateTime() > logicalDuration.value {
          this.GetWeaponObject(scriptInterface).StopReload(gameweaponReloadStatus.Standard);
          stateContext.SetTemporaryBoolParameter(n"FinishedReload", true, true);
        };
      };
    };
    if this.IsReloadUninterruptible(stateContext, scriptInterface) && !this.m_uninteruptibleSet {
      this.SetUninteruptibleReloadParams(stateContext, false);
      this.m_uninteruptibleSet = true;
    };
    if stateContext.IsStateMachineActive(n"Consumable") || stateContext.IsStateMachineActive(n"CombatGadget") {
      interruptReload = true;
    };
    if interruptReload {
      scriptInterface.PushAnimationEvent(n"EndReload");
      stateContext.SetTemporaryBoolParameter(n"InterruptReload", true, true);
    };
  }

  protected func OnExitToReload(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    if !this.m_animReloadData.continueLoop {
      this.m_animReloadData.continueLoop = true;
      this.m_animReloadDataDirty = true;
    };
  }

  protected func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let weapon: ref<WeaponObject> = this.GetWeaponObject(scriptInterface);
    stateContext.SetPermanentFloatParameter(n"LastReloadTime", EngineTime.ToFloat(GameInstance.GetSimTime(scriptInterface.GetGame())), true);
    scriptInterface.SetAnimationParameterFloat(n"empty_clip", 0.00);
    scriptInterface.PushAnimationEvent(n"EndReload");
    if this.m_animReloadData.continueLoop {
      this.m_animReloadData.continueLoop = false;
      this.m_animReloadDataDirty = true;
    };
    this.DeactivateReloadAnimData(stateContext, scriptInterface);
    WeaponObject.TriggerWeaponEffects(weapon, gamedataFxAction.ExitReload);
    WeaponObject.SendAmmoUpdateEvent(scriptInterface.executionOwner, weapon);
    this.SetUninteruptibleReloadParams(stateContext, true);
    this.m_uninteruptibleSet = false;
    if !stateContext.GetBoolParameter(n"FinishedReload") {
      scriptInterface.PushAnimationEvent(n"InterruptReload");
      weapon.StopReload(gameweaponReloadStatus.Interrupted);
    };
  }
}

public class ShootDecisions extends WeaponTransition {

  public const let stateBodyDone: Bool;

  protected final const func ExitCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.stateBodyDone;
  }
}

public class ShootEvents extends WeaponEventsTransition {

  protected final func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let attackID: TweakDBID;
    let broadcaster: ref<StimBroadcasterComponent>;
    let gameInstance: GameInstance = scriptInterface.GetGame();
    let statsSystem: ref<StatsSystem> = GameInstance.GetStatsSystem(gameInstance);
    let currentTime: Float = EngineTime.ToFloat(GameInstance.GetSimTime(gameInstance));
    let weapon: ref<WeaponObject> = this.GetWeaponObject(scriptInterface);
    this.ForceDisableVisionMode(stateContext);
    this.ShowAttackPreview(true, weapon, scriptInterface, stateContext);
    if !scriptInterface.HasStatFlag(gamedataStatType.CanWeaponShootWhileSprinting) && scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Locomotion) == EnumInt(gamePSMLocomotionStates.Sprint) {
      stateContext.SetTemporaryBoolParameter(n"InterruptSprint", true, true);
    };
    stateContext.SetPermanentFloatParameter(n"LastShotTime", currentTime, true);
    attackID = this.GetDesiredAttackRecord(stateContext, scriptInterface).GetID();
    weapon.SetAttack(attackID);
    weapon.QueueEvent(new WeaponPreFireEvent());
    stateContext.SetPermanentIntParameter(n"LastChargePressCount", Cast(scriptInterface.GetActionPressCount(n"RangedAttack")), true);
    stateContext.SetPermanentFloatParameter(n"TurnOffPublicSafeTimeStamp", currentTime, true);
    stateContext.SetPermanentBoolParameter(n"WeaponInSafe", false, true);
    scriptInterface.PushAnimationEvent(n"Shoot");
    stateContext.SetPermanentFloatParameter(n"StoppedFiringTimestamp", currentTime, true);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Weapon, EnumInt(gamePSMRangedWeaponStates.Shoot));
    broadcaster = scriptInterface.executionOwner.GetStimBroadcasterComponent();
    if statsSystem.GetStatValue(Cast(weapon.GetEntityID()), gamedataStatType.CanSilentKill) > 0.00 {
      if IsDefined(broadcaster) {
        broadcaster.TriggerSingleBroadcast(scriptInterface.executionOwner, gamedataStimType.IllegalAction);
        broadcaster.TriggerSingleBroadcast(scriptInterface.executionOwner, gamedataStimType.SilencedGunshot);
        broadcaster.TriggerSingleBroadcast(scriptInterface.executionOwner, gamedataStimType.SilencedGunshot, 8.00, true);
        if Equals(WeaponObject.GetWeaponType(weapon.GetItemID()), gamedataItemType.Wea_SniperRifle) {
          broadcaster.TriggerSingleBroadcast(scriptInterface.executionOwner, gamedataStimType.Gunshot, 8.00);
        };
      };
      WeaponObject.TriggerWeaponEffects(weapon, gamedataFxAction.SilencedShoot);
      WeaponObject.SendAmmoUpdateEvent(scriptInterface.executionOwner, weapon);
    } else {
      WeaponObject.TriggerWeaponEffects(weapon, gamedataFxAction.Shoot);
      WeaponObject.SendAmmoUpdateEvent(scriptInterface.executionOwner, weapon);
      if IsDefined(broadcaster) {
        if IsEntityInInteriorArea(GetPlayer(gameInstance)) {
          broadcaster.TriggerSingleBroadcast(scriptInterface.executionOwner, gamedataStimType.Gunshot, 25.00);
          broadcaster.TriggerSingleBroadcast(scriptInterface.executionOwner, gamedataStimType.Gunshot, 45.00, true);
        } else {
          broadcaster.TriggerSingleBroadcast(scriptInterface.executionOwner, gamedataStimType.Gunshot, GetPlayer(gameInstance).GetGunshotRange());
          broadcaster.TriggerSingleBroadcast(scriptInterface.executionOwner, gamedataStimType.Gunshot, 50.00, true);
        };
      };
      PlayerCoverHelper.BlockCoverVisibilityReduction(scriptInterface.executionOwner);
    };
    this.SendDataTrackingRequest(scriptInterface, ETelemetryData.RangedAttacksMade, 1);
    this.ChangeStatPoolValue(scriptInterface, scriptInterface.ownerEntityID, gamedataStatPoolType.WeaponOverheat, this.GetStaticFloatParameterDefault("overheatValAdd", 10.00));
    this.ShootingSequencePostShoot(stateContext);
  }

  protected final func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let statPoolsSystem: ref<StatPoolsSystem> = scriptInterface.GetStatPoolsSystem();
    let statsSystem: ref<StatsSystem> = scriptInterface.GetStatsSystem();
    let weaponObject: ref<WeaponObject> = this.GetWeaponObject(scriptInterface);
    if statsSystem.GetStatValue(Cast(weaponObject.GetEntityID()), gamedataStatType.FullAutoOnFullCharge) == 0.00 {
      statPoolsSystem.RequestSettingStatPoolMinValue(Cast(weaponObject.GetEntityID()), gamedataStatPoolType.WeaponCharge, scriptInterface.executionOwner);
    };
  }
}

public class CycleRoundDecisions extends WeaponTransition {

  protected final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return true;
  }

  protected final const func ExitCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let weaponObject: ref<WeaponObject> = this.GetWeaponObject(scriptInterface);
    if weaponObject.IsMagazineEmpty() {
      return true;
    };
    return this.CanPerformNextShotInSequence(weaponObject, stateContext, scriptInterface);
  }

  protected final const func ToFullAuto(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.ToFullAutoTransitionCondition(stateContext, scriptInterface);
  }
}

public class CycleRoundEvents extends WeaponEventsTransition {

  public let m_hasBlockedAiming: Bool;

  public let m_blockAimStart: Float;

  public let m_blockAimDuration: Float;

  protected final func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let weapon: ref<WeaponObject> = this.GetWeaponObject(scriptInterface);
    this.m_hasBlockedAiming = false;
    this.m_blockAimStart = scriptInterface.GetStatsSystem().GetStatValue(Cast(weapon.GetEntityID()), gamedataStatType.CycleTimeAimBlockStart);
    this.m_blockAimDuration = scriptInterface.GetStatsSystem().GetStatValue(Cast(weapon.GetEntityID()), gamedataStatType.CycleTimeAimBlockDuration);
    if this.m_blockAimDuration > 0.00 && this.m_blockAimStart > 0.00 {
      if scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.UpperBody) == EnumInt(gamePSMUpperBodyStates.Aim) {
        this.HoldAimingForTime(stateContext, scriptInterface, this.m_blockAimStart);
      };
    };
    if this.GetWeaponObject(scriptInterface).GetItemData().HasTag(n"AnimCycleRound") {
      scriptInterface.PushAnimationEvent(n"CycleRound");
    };
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Weapon, EnumInt(gamePSMRangedWeaponStates.Shoot));
  }

  protected final func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    if this.m_hasBlockedAiming {
      this.ResetSoftBlockAiming(stateContext, scriptInterface);
    };
  }

  protected final func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let weapon: ref<WeaponObject> = this.GetWeaponObject(scriptInterface);
    this.ShowAttackPreview(true, weapon, scriptInterface, stateContext);
    if this.m_blockAimDuration > 0.00 {
      if !this.m_hasBlockedAiming && this.m_blockAimStart < this.GetInStateTime() {
        this.BlockAimingForTime(stateContext, scriptInterface, this.m_blockAimDuration);
        this.m_hasBlockedAiming = true;
      };
    };
    this.ShootingSequenceUpdateCycleTime(timeDelta, stateContext);
    this.UpdateInputBuffer(stateContext, scriptInterface);
    if scriptInterface.IsTriggerModeActive(gamedataTriggerMode.FullAuto) {
      if scriptInterface.GetActionValue(n"RangedAttack") <= 0.00 || this.GetWeaponObject(scriptInterface).IsMagazineEmpty() {
        scriptInterface.TEMP_WeaponStopFiring();
      };
    };
  }
}

public class CycleTriggerModeDecisions extends WeaponTransition {

  protected final func OnAttach(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let weapon: ref<WeaponObject> = scriptInterface.owner as WeaponObject;
    this.EnableOnEnterCondition(weapon.HasSecondaryTriggerMode());
  }

  protected final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if stateContext.IsStateActive(n"UpperBody", n"aimingState") && this.IsPrimaryTriggerModeActive(scriptInterface) {
      return true;
    };
    if !stateContext.IsStateActive(n"UpperBody", n"aimingState") && !this.IsPrimaryTriggerModeActive(scriptInterface) {
      return true;
    };
    return false;
  }

  protected final const func ToReady(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.GetInStateTime() > stateContext.GetConditionFloat(n"CycleTriggerModeStatCycleTime");
  }

  protected final const func ToCharge(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let weapon: ref<WeaponObject>;
    if !scriptInterface.IsTriggerModeActive(gamedataTriggerMode.Charge) {
      return false;
    };
    if this.GetInStateTime() < stateContext.GetConditionFloat(n"CycleTriggerModeStatCycleTime") {
      return false;
    };
    weapon = this.GetWeaponObject(scriptInterface);
    return !weapon.IsMagazineEmpty() && scriptInterface.GetStatPoolsSystem().HasStatPoolValueReachedMin(Cast(weapon.GetEntityID()), gamedataStatPoolType.WeaponCharge) && scriptInterface.GetActionValue(n"RangedAttack") > 0.00;
  }
}

public class CycleTriggerModeEvents extends WeaponEventsTransition {

  protected final func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let animFeature: ref<AnimFeature_TriggerModeChange>;
    let statCycleTime: Float;
    let ownerID: StatsObjectID = Cast(scriptInterface.ownerEntityID);
    if scriptInterface.localBlackboard.GetBool(GetAllBlackboardDefs().PlayerStateMachine.ToggleFireMode) {
      this.SetBlackboardBoolVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.ToggleFireMode, false);
    };
    this.SwitchTriggerMode(stateContext, scriptInterface);
    statCycleTime = scriptInterface.GetStatsSystem().GetStatValue(ownerID, gamedataStatType.CycleTriggerModeTime);
    stateContext.SetConditionFloatParameter(n"CycleTriggerModeStatCycleTime", statCycleTime, true);
    animFeature = new AnimFeature_TriggerModeChange();
    animFeature.cycleTime = statCycleTime;
    scriptInterface.SetAnimationParameterFeature(n"TriggerModeChange", animFeature);
    scriptInterface.PushAnimationEvent(n"SwitchFiremode");
  }

  protected final func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void;

  protected final func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.UpdateInputBuffer(stateContext, scriptInterface);
  }
}

public class SemiAutoDecisions extends WeaponTransition {

  public let m_callBackID: ref<CallbackHandle>;

  protected final func OnAttach(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    scriptInterface.executionOwner.RegisterInputListener(this, n"RangedAttack");
    this.OnRangeAttackInput(scriptInterface.GetActionValue(n"RangedAttack"));
    this.m_callBackID = scriptInterface.localBlackboard.RegisterListenerBool(GetAllBlackboardDefs().PlayerStateMachine.QuestForceShoot, this, n"OnQuestForcedShoot", false);
  }

  protected final func OnDetach(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    scriptInterface.executionOwner.UnregisterInputListener(this);
    scriptInterface.localBlackboard.UnregisterListenerBool(GetAllBlackboardDefs().PlayerStateMachine.QuestForceShoot, this.m_callBackID);
  }

  protected final func OnQuestForcedShoot(value: Bool) -> Void {
    this.EnableOnEnterCondition(value);
  }

  protected final func OnRangeAttackInput(value: Float) -> Void {
    this.EnableOnEnterCondition(value > 0.00);
  }

  protected cb func OnAction(action: ListenerAction, consumer: ListenerActionConsumer) -> Bool {
    this.OnRangeAttackInput(ListenerAction.GetValue(action));
  }

  protected final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let questForceShoot: StateResultBool;
    let weaponObject: ref<WeaponObject> = this.GetWeaponObject(scriptInterface);
    let validTransition: Bool = false;
    if this.CanPerformNextSemiAutoShot(weaponObject, stateContext, scriptInterface) {
      validTransition = this.IsSemiAutoAction(weaponObject, stateContext, scriptInterface);
      if !validTransition {
        questForceShoot = stateContext.GetTemporaryBoolParameter(this.GetQuestForceShootName());
        validTransition = questForceShoot.value;
      };
    };
    return validTransition;
  }

  protected final const func ToShoot(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let isFireDelay: Bool = stateContext.GetBoolParameter(this.GetIsDelayFireName(), true);
    let timeRemaining: Float = stateContext.GetFloatParameter(this.GetCycleTimeRemainingName(), true);
    return !isFireDelay || timeRemaining <= 0.00;
  }
}

public class SemiAutoEvents extends WeaponEventsTransition {

  protected final func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Weapon, EnumInt(gamePSMRangedWeaponStates.Shoot));
    this.SetupStandardShootingSequence(stateContext, scriptInterface);
  }

  protected final func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.ShootingSequenceUpdateCycleTime(timeDelta, stateContext);
  }
}

public class FullAutoDecisions extends WeaponTransition {

  public let m_callBackID: ref<CallbackHandle>;

  protected final func OnAttach(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.m_callBackID = scriptInterface.localBlackboard.RegisterListenerBool(GetAllBlackboardDefs().PlayerStateMachine.QuestForceShoot, this, n"OnQuestForcedShoot", false);
    scriptInterface.executionOwner.RegisterInputListener(this, n"RangedAttack");
    this.OnRangeAttackInput(scriptInterface.GetActionValue(n"RangedAttack"));
  }

  protected final func OnDetach(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    scriptInterface.executionOwner.UnregisterInputListener(this);
    scriptInterface.localBlackboard.UnregisterListenerBool(GetAllBlackboardDefs().PlayerStateMachine.QuestForceShoot, this.m_callBackID);
  }

  protected final func OnQuestForcedShoot(value: Bool) -> Void {
    this.EnableOnEnterCondition(value);
  }

  protected final func OnRangeAttackInput(value: Float) -> Void {
    this.EnableOnEnterCondition(value > 0.00);
  }

  protected cb func OnAction(action: ListenerAction, consumer: ListenerActionConsumer) -> Bool {
    this.OnRangeAttackInput(ListenerAction.GetValue(action));
  }

  protected final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let questForceShoot: StateResultBool;
    let weaponObject: ref<WeaponObject> = this.GetWeaponObject(scriptInterface);
    let validTransition: Bool = false;
    if this.CanPerformNextFullAutoShot(weaponObject, stateContext, scriptInterface) {
      validTransition = this.IsFullAutoAction(weaponObject, stateContext, scriptInterface);
      if !validTransition {
        questForceShoot = stateContext.GetTemporaryBoolParameter(this.GetQuestForceShootName());
        validTransition = questForceShoot.value;
      };
    };
    return validTransition;
  }

  protected final const func ToShoot(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let weapon: ref<WeaponObject> = this.GetWeaponObject(scriptInterface);
    let isFireDelay: Bool = stateContext.GetBoolParameter(this.GetIsDelayFireName(), true);
    let timeRemaining: Float = stateContext.GetFloatParameter(this.GetCycleTimeRemainingName(), true);
    let validAmmo: Bool = !weapon.IsMagazineEmpty();
    return validAmmo && (!isFireDelay || timeRemaining <= 0.00);
  }

  protected final const func ToReady(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let isFireDelay: Bool = stateContext.GetBoolParameter(this.GetIsDelayFireName(), true);
    let timeRemaining: Float = stateContext.GetFloatParameter(this.GetCycleTimeRemainingName(), true);
    return (!isFireDelay || timeRemaining <= 0.00) && scriptInterface.GetActionValue(n"RangedAttack") <= 0.00;
  }
}

public class FullAutoEvents extends WeaponEventsTransition {

  protected final func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let cycleTimeForShootingPhase: Float;
    let statsSystem: ref<StatsSystem> = scriptInterface.GetStatsSystem();
    let weaponObject: ref<WeaponObject> = this.GetWeaponObject(scriptInterface);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Weapon, EnumInt(gamePSMRangedWeaponStates.Shoot));
    if !this.InShootingSequence(stateContext) {
      this.SetupStandardShootingSequence(stateContext, scriptInterface);
    } else {
      cycleTimeForShootingPhase = this.CalculateCycleTime(stateContext, scriptInterface);
      this.SetupNextShootingPhase(stateContext, cycleTimeForShootingPhase, statsSystem.GetStatValue(Cast(weaponObject.GetEntityID()), gamedataStatType.CycleTime_Burst), Cast(statsSystem.GetStatValue(Cast(weaponObject.GetEntityID()), gamedataStatType.NumShotsInBurst)));
    };
  }

  protected final func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let weapon: ref<WeaponObject> = this.GetWeaponObject(scriptInterface);
    this.ShootingSequenceUpdateCycleTime(timeDelta, stateContext);
    this.ShowAttackPreview(true, weapon, scriptInterface, stateContext);
  }

  private final func CalculateCycleTime(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Float {
    let lerp: Float;
    let finalMultiplier: Float = 1.00;
    let gameInstance: GameInstance = scriptInterface.GetGame();
    let currentTime: Float = EngineTime.ToFloat(GameInstance.GetSimTime(gameInstance));
    let statsSystem: ref<StatsSystem> = GameInstance.GetStatsSystem(gameInstance);
    let weaponObject: ref<WeaponObject> = this.GetWeaponObject(scriptInterface);
    let shootingSequenceStartTime: Float = stateContext.GetFloatParameter(this.GetShootingStartName(), true);
    let cycleTimeStart: Float = statsSystem.GetStatValue(Cast(weaponObject.GetEntityID()), gamedataStatType.CycleTime);
    let statMultiplier: Float = statsSystem.GetStatValue(Cast(weaponObject.GetEntityID()), gamedataStatType.CycleTimeShootingMult);
    let statPeriod: Float = statsSystem.GetStatValue(Cast(weaponObject.GetEntityID()), gamedataStatType.CycleTimeShootingMultPeriod);
    if statMultiplier != 0.00 {
      if statPeriod > 0.00 {
        lerp = LerpF((currentTime - shootingSequenceStartTime) / statPeriod, 0.00, 1.00, true);
      } else {
        lerp = 1.00;
      };
      finalMultiplier = 1.00 + lerp * statMultiplier;
    };
    return cycleTimeStart * finalMultiplier;
  }
}

public class BurstDecisions extends WeaponTransition {

  protected final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let burstShotRemaining: Int32 = stateContext.GetIntParameter(this.GetBurstShotsRemainingName(), true);
    let isBursting: Bool = burstShotRemaining >= 1;
    return isBursting && !this.GetWeaponObject(scriptInterface).IsMagazineEmpty();
  }

  protected final const func ToShoot(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let timeRemaining: Float = stateContext.GetFloatParameter(this.GetBurstTimeRemainingName(), true);
    let validTime: Bool = timeRemaining <= 0.00;
    let validAmmo: Bool = !this.GetWeaponObject(scriptInterface).IsMagazineEmpty();
    return validTime && validAmmo;
  }
}

public class BurstEvents extends WeaponEventsTransition {

  protected final func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let weapon: ref<WeaponObject> = this.GetWeaponObject(scriptInterface);
    this.ShootingSequenceUpdateBurstTime(timeDelta, stateContext);
    this.ShowAttackPreview(true, weapon, scriptInterface, stateContext);
  }
}

public abstract class ChargeEventsAbstract extends WeaponEventsTransition {

  protected let m_layerId: Uint32;

  protected final func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Weapon, EnumInt(gamePSMRangedWeaponStates.Default));
    stateContext.SetPermanentBoolParameter(n"WeaponStopChargeRequested", true, true);
    this.StopEffect(n"charging", scriptInterface);
    this.StopEffect(n"charged", scriptInterface);
    this.ClearDebugText(this.m_layerId, scriptInterface);
  }

  public func OnForcedExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Weapon, EnumInt(gamePSMRangedWeaponStates.Default));
    stateContext.SetPermanentBoolParameter(n"WeaponStopChargeRequested", true, true);
    this.StopEffect(n"charging", scriptInterface);
    this.StopEffect(n"charged", scriptInterface);
    this.ClearDebugText(this.m_layerId, scriptInterface);
  }

  protected func OnExitToShoot(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnExit(stateContext, scriptInterface);
  }

  protected func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.ShowAttackPreview(true, this.GetWeaponObject(scriptInterface), scriptInterface, stateContext);
  }

  protected final func SetupFullChargedShootingSequence(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let weaponObject: ref<WeaponObject> = this.GetWeaponObject(scriptInterface);
    let statsSystem: ref<StatsSystem> = scriptInterface.GetStatsSystem();
    this.StartShootingSequence(stateContext, scriptInterface, 0.00, statsSystem.GetStatValue(Cast(weaponObject.GetEntityID()), gamedataStatType.CycleTime_BurstMaxCharge), Cast(statsSystem.GetStatValue(Cast(weaponObject.GetEntityID()), gamedataStatType.NumShotsInBurstMaxCharge)), Cast(statsSystem.GetStatValue(Cast(weaponObject.GetEntityID()), gamedataStatType.FullAutoOnFullCharge)));
  }
}

public class ChargeDecisions extends WeaponTransition {

  private let m_callbackID: ref<CallbackHandle>;

  private let m_triggerModeCorrect: Bool;

  private let m_inputPressed: Bool;

  protected final func UpdateOnEnterConditionEnabled() -> Void {
    this.EnableOnEnterCondition(this.m_triggerModeCorrect && this.m_inputPressed);
  }

  protected final func OnAttach(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let weapon: ref<WeaponObject> = scriptInterface.owner as WeaponObject;
    let bb: ref<IBlackboard> = weapon.GetSharedData();
    if IsDefined(bb) && IsDefined(weapon) {
      this.m_callbackID = bb.RegisterListenerVariant(GetAllBlackboardDefs().Weapon.TriggerMode, this, n"OnTriggerModeChanged");
      this.UpdateTriggerMode(weapon.GetCurrentTriggerMode().Type());
    };
    scriptInterface.executionOwner.RegisterInputListener(this, n"RangedAttack");
    this.UpdateRangedAttackInput(scriptInterface.GetActionValue(n"RangedAttack"));
    this.UpdateOnEnterConditionEnabled();
  }

  protected final func OnDetach(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let weapon: ref<WeaponObject> = scriptInterface.owner as WeaponObject;
    let bb: ref<IBlackboard> = weapon.GetSharedData();
    scriptInterface.executionOwner.UnregisterInputListener(this);
    if IsDefined(weapon) && IsDefined(bb) {
      bb.UnregisterListenerVariant(GetAllBlackboardDefs().Weapon.TriggerMode, this.m_callbackID);
    };
    this.m_callbackID = null;
  }

  protected final func UpdateRangedAttackInput(value: Float) -> Void {
    this.m_inputPressed = value >= 0.50;
  }

  protected cb func OnAction(action: ListenerAction, consumer: ListenerActionConsumer) -> Bool {
    this.UpdateRangedAttackInput(ListenerAction.GetValue(action));
    this.UpdateOnEnterConditionEnabled();
  }

  protected final func UpdateTriggerMode(modeType: gamedataTriggerMode) -> Void {
    this.m_triggerModeCorrect = Equals(modeType, gamedataTriggerMode.Charge);
  }

  protected cb func OnTriggerModeChanged(value: Variant) -> Bool {
    let record: ref<TriggerMode_Record> = FromVariant(value);
    this.UpdateTriggerMode(record.Type());
    this.UpdateOnEnterConditionEnabled();
  }

  protected final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let weapon: ref<WeaponObject>;
    let actionPressCount: Uint32 = scriptInterface.GetActionPressCount(n"RangedAttack");
    let lastChargePressCount: StateResultInt = stateContext.GetPermanentIntParameter(n"LastChargePressCount");
    if lastChargePressCount.valid && lastChargePressCount.value == Cast(actionPressCount) {
      this.EnableOnEnterCondition(false);
      return false;
    };
    weapon = this.GetWeaponObject(scriptInterface);
    return !weapon.IsMagazineEmpty() && scriptInterface.GetStatPoolsSystem().HasStatPoolValueReachedMin(Cast(weapon.GetEntityID()), gamedataStatPoolType.WeaponCharge);
  }

  protected final const func ToShoot(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let weapon: ref<WeaponObject> = this.GetWeaponObject(scriptInterface);
    let weaponID: EntityID = weapon.GetEntityID();
    let gameInstance: GameInstance = scriptInterface.GetGame();
    let statsSystem: ref<StatsSystem> = GameInstance.GetStatsSystem(gameInstance);
    weaponID = weapon.GetEntityID();
    let chargeParameter: Float = WeaponObject.GetWeaponChargeNormalized(weapon);
    let readyPercentageParameter: Float = statsSystem.GetStatValue(Cast(weaponID), gamedataStatType.ChargeReadyPercentage);
    let fireWhenReadyParameter: Bool = statsSystem.GetStatValue(Cast(weaponID), gamedataStatType.ChargeShouldFireWhenReady) > 0.00;
    if fireWhenReadyParameter && chargeParameter >= readyPercentageParameter || scriptInterface.GetActionValue(n"RangedAttack") <= 0.00 {
      return true;
    };
    return false;
  }

  protected final const func ToChargeReady(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let weapon: ref<WeaponObject> = this.GetWeaponObject(scriptInterface);
    let weaponID: EntityID = weapon.GetEntityID();
    let gameInstance: GameInstance = scriptInterface.GetGame();
    let statsSystem: ref<StatsSystem> = GameInstance.GetStatsSystem(gameInstance);
    let chargeParameter: Float = WeaponObject.GetWeaponChargeNormalized(weapon);
    let readyPercentageParameter: Float = statsSystem.GetStatValue(Cast(weaponID), gamedataStatType.ChargeReadyPercentage);
    let fireWhenReadyParameter: Bool = statsSystem.GetStatValue(Cast(weaponID), gamedataStatType.ChargeShouldFireWhenReady) > 0.00;
    if !fireWhenReadyParameter && chargeParameter >= readyPercentageParameter && scriptInterface.GetActionValue(n"RangedAttack") > 0.00 {
      return true;
    };
    return false;
  }
}

public class ChargeEvents extends ChargeEventsAbstract {

  protected final func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let actionPressCount: Uint32;
    let weapon: ref<WeaponObject> = this.GetWeaponObject(scriptInterface);
    let weaponID: EntityID = weapon.GetEntityID();
    let maxCharge: Float = this.GetMaxChargeThreshold(scriptInterface);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Weapon, EnumInt(gamePSMRangedWeaponStates.Charging));
    actionPressCount = scriptInterface.GetActionPressCount(n"RangedAttack");
    stateContext.SetPermanentIntParameter(n"LastChargePressCount", Cast(actionPressCount), true);
    this.PlayEffect(n"charging", scriptInterface);
    weapon.SetMaxChargeThreshold(maxCharge);
    this.StartPool(scriptInterface.GetStatPoolsSystem(), weaponID, gamedataStatPoolType.WeaponCharge, maxCharge, this.GetChargeValuePerSec(scriptInterface));
    WeaponObject.TriggerWeaponEffects(weapon, gamedataFxAction.EnterCharge);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Weapon, EnumInt(gamePSMRangedWeaponStates.Charging));
    this.GetWeaponObject(scriptInterface).GetSharedData().SetVariant(GetAllBlackboardDefs().Weapon.ChargeStep, ToVariant(gamedataChargeStep.Charging));
  }

  protected func OnExitToChargeReady(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.ClearDebugText(this.m_layerId, scriptInterface);
  }

  protected final func GetChargeValuePerSec(scriptInterface: ref<StateGameScriptInterface>) -> Float {
    let chargeDuration: Float;
    let weapon: ref<WeaponObject>;
    let statsSystem: ref<StatsSystem> = scriptInterface.GetStatsSystem();
    if !IsDefined(statsSystem) {
      return -1.00;
    };
    weapon = this.GetWeaponObject(scriptInterface);
    if !IsDefined(weapon) {
      return -1.00;
    };
    chargeDuration = statsSystem.GetStatValue(Cast(weapon.GetEntityID()), gamedataStatType.ChargeTime);
    if chargeDuration <= 0.00 {
      return -1.00;
    };
    return 100.00 / chargeDuration;
  }

  protected func OnExitToShoot(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.SetupStandardShootingSequence(stateContext, scriptInterface);
    this.OnExitToShoot(stateContext, scriptInterface);
  }
}

public class ChargeReadyDecisions extends WeaponTransition {

  protected final const func ToShoot(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return scriptInterface.GetActionValue(n"RangedAttack") <= 0.00;
  }

  protected final const func ToChargeMax(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let statPoolsSystem: ref<StatPoolsSystem> = scriptInterface.GetStatPoolsSystem();
    let weaponID: EntityID = this.GetWeaponObject(scriptInterface).GetEntityID();
    let statPoolPerc: Float = statPoolsSystem.GetStatPoolValue(Cast(weaponID), gamedataStatPoolType.WeaponCharge);
    if statPoolPerc >= this.GetMaxChargeThreshold(scriptInterface) {
      return true;
    };
    return false;
  }
}

public class ChargeReadyEvents extends ChargeEventsAbstract {

  protected final func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Weapon, EnumInt(gamePSMRangedWeaponStates.Charging));
    this.GetWeaponObject(scriptInterface).GetSharedData().SetVariant(GetAllBlackboardDefs().Weapon.ChargeStep, ToVariant(gamedataChargeStep.Charged));
  }

  protected func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.ShowAttackPreview(true, this.GetWeaponObject(scriptInterface), scriptInterface, stateContext);
  }

  protected func OnExitToShoot(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.SetupStandardShootingSequence(stateContext, scriptInterface);
    this.OnExitToShoot(stateContext, scriptInterface);
  }

  protected func OnExitToChargeMax(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.StopEffect(n"charging", scriptInterface);
    this.ClearDebugText(this.m_layerId, scriptInterface);
  }
}

public class ChargeMaxDecisions extends WeaponTransition {

  protected final const func ToShoot(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let timeInState: Float;
    let timeInStateMaxParameter: Float;
    let statsSystem: ref<StatsSystem> = scriptInterface.GetStatsSystem();
    let weaponID: EntityID = this.GetWeaponObject(scriptInterface).GetEntityID();
    if scriptInterface.HasStatFlag(gamedataStatType.CanControlFullyChargedWeapon) && statsSystem.GetStatValue(Cast(weaponID), gamedataStatType.FullAutoOnFullCharge) == 0.00 {
      if scriptInterface.GetActionValue(n"RangedAttack") <= 0.00 {
        return true;
      };
      return false;
    };
    timeInStateMaxParameter = statsSystem.GetStatValue(Cast(weaponID), gamedataStatType.ChargeMaxTimeInChargedState);
    timeInState = this.GetInStateTime();
    if timeInState >= timeInStateMaxParameter || scriptInterface.GetActionValue(n"RangedAttack") <= 0.00 {
      return true;
    };
    return false;
  }
}

public class ChargeMaxEvents extends ChargeEventsAbstract {

  protected final func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Weapon, EnumInt(gamePSMRangedWeaponStates.Charging));
    this.PlayEffect(n"charged", scriptInterface);
    this.GetWeaponObject(scriptInterface).GetSharedData().SetVariant(GetAllBlackboardDefs().Weapon.ChargeStep, ToVariant(gamedataChargeStep.Overcharging));
  }

  protected func OnExitToShoot(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.PlayEffect(n"discharge", scriptInterface);
    this.SetupFullChargedShootingSequence(stateContext, scriptInterface);
    this.OnExitToShoot(stateContext, scriptInterface);
  }
}

public class DischargeDecisions extends WeaponTransition {

  protected final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let gameInstance: GameInstance = scriptInterface.GetGame();
    let statPoolsSystem: ref<StatPoolsSystem> = GameInstance.GetStatPoolsSystem(gameInstance);
    let statsSystem: ref<StatsSystem> = GameInstance.GetStatsSystem(gameInstance);
    let weaponID: EntityID = this.GetWeaponObject(scriptInterface).GetEntityID();
    let chargeParameter: Float = statPoolsSystem.GetStatPoolValue(Cast(weaponID), gamedataStatPoolType.WeaponCharge);
    let readyPercentageParameter: Float = statsSystem.GetStatValue(Cast(weaponID), gamedataStatType.ChargeReadyPercentage);
    if chargeParameter < readyPercentageParameter && scriptInterface.GetActionValue(n"RangedAttack") <= 0.00 {
      return true;
    };
    return false;
  }

  protected final const func ToReady(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let statPoolsSystem: ref<StatPoolsSystem> = scriptInterface.GetStatPoolsSystem();
    let weaponID: EntityID = this.GetWeaponObject(scriptInterface).GetEntityID();
    return statPoolsSystem.HasStatPoolValueReachedMin(Cast(weaponID), gamedataStatPoolType.WeaponCharge);
  }
}

public class DischargeEvents extends WeaponEventsTransition {

  public let layerId: Uint32;

  private let m_statPoolsSystem: ref<StatPoolsSystem>;

  private let m_statsSystem: ref<StatsSystem>;

  private let m_weaponID: EntityID;

  protected final func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let chargeMod: StatPoolModifier;
    let gameInstance: GameInstance = scriptInterface.GetGame();
    let weapon: ref<WeaponObject> = this.GetWeaponObject(scriptInterface);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Weapon, EnumInt(gamePSMRangedWeaponStates.Charging));
    this.ShowDebugText("<<<DISCHARGING>>>", scriptInterface, this.layerId);
    this.m_statPoolsSystem = GameInstance.GetStatPoolsSystem(gameInstance);
    this.m_statsSystem = GameInstance.GetStatsSystem(gameInstance);
    this.m_weaponID = weapon.GetEntityID();
    this.StopEffect(n"charging", scriptInterface);
    this.StopEffect(n"charged", scriptInterface);
    this.m_statPoolsSystem.GetModifier(Cast(this.m_weaponID), gamedataStatPoolType.WeaponCharge, gameStatPoolModificationTypes.Decay, chargeMod);
    chargeMod.enabled = true;
    this.m_statPoolsSystem.RequestResetingModifier(Cast(this.m_weaponID), gamedataStatPoolType.WeaponCharge, gameStatPoolModificationTypes.Regeneration);
    this.m_statPoolsSystem.RequestSettingModifier(Cast(this.m_weaponID), gamedataStatPoolType.WeaponCharge, gameStatPoolModificationTypes.Decay, chargeMod);
    WeaponObject.TriggerWeaponEffects(weapon, gamedataFxAction.EnterDischarge);
    weapon.GetSharedData().SetVariant(GetAllBlackboardDefs().Weapon.ChargeStep, ToVariant(gamedataChargeStep.Discharging));
  }

  protected final func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void;

  protected func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.ClearDebugText(this.layerId, scriptInterface);
    WeaponObject.TriggerWeaponEffects(this.GetWeaponObject(scriptInterface), gamedataFxAction.ExitDischarge);
  }
}

public class OverheatDecisions extends WeaponTransition {

  private let m_callbackID: ref<CallbackHandle>;

  protected final func OnAttach(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let allBlackboardDef: ref<AllBlackboardDefinitions>;
    let weapon: ref<WeaponObject> = scriptInterface.owner as WeaponObject;
    let bb: ref<IBlackboard> = weapon.GetSharedData();
    if IsDefined(bb) && IsDefined(weapon) {
      allBlackboardDef = GetAllBlackboardDefs();
      this.m_callbackID = bb.RegisterListenerBool(allBlackboardDef.Weapon.IsInForcedOverheatCooldown, this, n"OnForcedOverheatCooldownChanged");
      this.EnableOnEnterCondition(bb.GetBool(allBlackboardDef.Weapon.IsInForcedOverheatCooldown));
    };
  }

  protected final func OnDetach(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.m_callbackID = null;
  }

  protected cb func OnForcedOverheatCooldownChanged(value: Bool) -> Bool {
    this.EnableOnEnterCondition(value);
  }

  protected final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return true;
  }

  protected final const func ExitCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let isOverheated: Bool = this.GetWeaponObject(scriptInterface).GetSharedData().GetBool(GetAllBlackboardDefs().Weapon.IsInForcedOverheatCooldown);
    if !isOverheated {
      return this.GetInStateTime() > this.GetStaticFloatParameterDefault("overheatDuration", 5.00);
    };
    return false;
  }
}

public class OverheatEvents extends WeaponEventsTransition {

  protected final func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    scriptInterface.TEMP_WeaponStopFiring();
    stateContext.SetTemporaryBoolParameter(n"InterruptAiming", true, true);
    scriptInterface.PushAnimationEvent(n"Overheat");
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Weapon, EnumInt(gamePSMRangedWeaponStates.Overheat));
    WeaponObject.TriggerWeaponEffects(this.GetWeaponObject(scriptInterface), gamedataFxAction.ExitOverheat);
  }

  protected func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    WeaponObject.TriggerWeaponEffects(this.GetWeaponObject(scriptInterface), gamedataFxAction.ExitOverheat);
  }
}
