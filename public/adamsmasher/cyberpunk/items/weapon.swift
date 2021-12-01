
public native class WeaponObject extends ItemObject {

  private let m_hasOverheat: Bool;

  private let m_overheatEffectBlackboard: ref<worldEffectBlackboard>;

  private let m_overheatListener: ref<OverheatStatListener>;

  private let m_overheatDelaySent: Bool;

  private let m_chargeEffectBlackboard: ref<worldEffectBlackboard>;

  private let m_chargeStatListener: ref<WeaponChargeStatListener>;

  private let m_meleeHitEffectBlackboard: ref<worldEffectBlackboard>;

  private let m_meleeHitEffectValue: Float;

  private let m_damageTypeListener: ref<DamageStatListener>;

  private let m_trailName: String;

  @default(WeaponObject, 100.f)
  private let m_maxChargeThreshold: Float;

  private let m_lowAmmoEffectActive: Bool;

  private let m_hasSecondaryTriggerMode: Bool;

  private let m_weaponRecord: ref<WeaponItem_Record>;

  private let m_isHeavyWeapon: Bool;

  private let m_isMeleeWeapon: Bool;

  private let m_isRangedWeapon: Bool;

  private let m_AIBlackboard: ref<IBlackboard>;

  public final native func GetAttacks() -> array<ref<IAttack>>;

  public final native func GetCurrentAttack() -> ref<IAttack>;

  public final native func GetCurrentTriggerMode() -> ref<TriggerMode_Record>;

  public final native func GetFxPackage() -> wref<FxPackage>;

  public final native func GetFxPackageQuickMelee() -> wref<FxPackage>;

  public final native func GetSharedData() -> ref<IBlackboard>;

  public final native func GetTotalAmmoCount() -> Int32;

  public final native func GetTriggerModes() -> array<ref<TriggerMode_Record>>;

  public final native func HasAmmoChangeRequest() -> Bool;

  public final native func HasPendingReload() -> Bool;

  public final native func SetAttack(attackID: TweakDBID) -> Bool;

  public final native func StartContinuousAttack(startPos: Vector4, startDir: Vector4) -> Bool;

  public final native func StopContinuousAttack() -> Void;

  public final native func IsContinuousAttackStarted() -> Bool;

  public final native func HasScope() -> Bool;

  public final native func GetScopeOffset() -> Vector4;

  public final native func GetIronSightOffset() -> Vector4;

  public final native func GetMuzzleOffset() -> Vector4;

  public final native func IsSilenced() -> Bool;

  public final native func UpdateTargetingSight(targetID: EntityID, targetPosition: Vector4) -> Bool;

  public final native func IsTargetLocked() -> Bool;

  public final native func ShootStraight(shootStraight: Bool) -> Void;

  public final native func SetTriggerDown(triggerDown: Bool) -> Void;

  public final native func SetupBurstFireSound(numShotsInBurst: Int32) -> Void;

  public final native func StartReload(opt durationOverride: Float) -> Float;

  public final native func StopReload(opt reloadStatus: gameweaponReloadStatus) -> Void;

  public final native func AI_SetAttackData(attack: wref<IAttack>) -> Void;

  public final native func AI_PlayChargeStartedSound() -> Void;

  public final native func AI_PlayMeleeAttackSound(isQuickMelee: Bool) -> Void;

  public final native func AI_ShootAt(targetPositionProvider: ref<IPositionProvider>, targetObject: ref<GameObject>, instigator: wref<GameObject>, ammoCost: Uint16, projectileParams: gameprojectileWeaponParams, projectilesPerShot: Uint8, charge: Float, opt maxSpread: Float) -> Void;

  public final native func AI_ShootForwards(instigator: wref<GameObject>, ammoCost: Uint16, projectileParams: gameprojectileWeaponParams, projectilesPerShot: Uint8, charge: Float, opt overridePos: Vector4, opt overrideForward: Vector4) -> Void;

  public final native func AI_ShootSelfOffScreen(targetObject: ref<gamePuppet>, ammoCost: Uint16, projectileParams: gameprojectileWeaponParams, projectilesPerShot: Uint8, charge: Float) -> Void;

  private final native func SetWeaponEffects(weaponVFXActionRecord: array<wref<WeaponVFXAction_Record>>) -> Void;

  private final native func RemoveWeaponEffects() -> Void;

  protected cb func OnGameAttached() -> Bool {
    let weaponFxPackage: wref<WeaponFxPackage_Record>;
    let weaponVFXActionRecord: array<wref<WeaponVFXAction_Record>>;
    super.OnGameAttached();
    this.m_weaponRecord = TweakDBInterface.GetWeaponItemRecord(ItemID.GetTDBID(this.GetItemID()));
    this.m_isHeavyWeapon = Equals(EquipmentSystem.GetEquipAreaType(this.GetItemID()), gamedataEquipmentArea.WeaponHeavy);
    this.m_isMeleeWeapon = this.m_weaponRecord.TagsContains(WeaponObject.GetMeleeWeaponTag());
    this.m_isRangedWeapon = this.m_weaponRecord.TagsContains(WeaponObject.GetRangedWeaponTag());
    this.m_AIBlackboard = IBlackboard.Create(GetAllBlackboardDefs().AIShooting);
    this.OnAttachSetStatPools();
    this.RegisterStatPoolListeners();
    this.RegisterStatListeners();
    this.m_weaponRecord = TweakDBInterface.GetWeaponItemRecord(ItemID.GetTDBID(this.GetItemID()));
    weaponFxPackage = this.m_weaponRecord.FxPackage();
    if this.GetOwner().IsNPC() {
      GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, new UpdateDamageChangeEvent(), 0.00);
    };
    if this.GetOwner().IsPlayer() {
      this.SendScopeData();
      this.SendWeaponStatsAnimFeature();
      this.HandleVisualEffectsSetup();
      weaponFxPackage.Player_vfx_set().Actions(weaponVFXActionRecord);
    } else {
      weaponFxPackage.Npc_vfx_set().Actions(weaponVFXActionRecord);
    };
    this.SetWeaponEffects(weaponVFXActionRecord);
    this.SetWeaponOwner();
    this.m_hasSecondaryTriggerMode = false;
    if IsDefined(this.m_weaponRecord.SecondaryTriggerMode()) {
      if NotEquals(this.m_weaponRecord.PrimaryTriggerMode().Type(), this.m_weaponRecord.SecondaryTriggerMode().Type()) {
        this.m_hasSecondaryTriggerMode = true;
      };
    };
  }

  protected cb func OnPlayerWeaponSetupEvent(evt: ref<PlayerWeaponSetupEvent>) -> Bool {
    if this.GetOwner().IsPlayer() {
      this.SendScopeData();
      this.SendWeaponStatsAnimFeature();
      this.HandleVisualEffectsSetup();
    };
    this.SetWeaponOwner();
  }

  protected cb func OnDetach() -> Bool {
    super.OnDetach();
    this.RemoveWeaponEffects();
    if IsDefined(this.m_overheatListener) {
      GameInstance.GetStatPoolsSystem(this.GetGame()).RequestUnregisteringListener(Cast(this.GetEntityID()), gamedataStatPoolType.WeaponOverheat, this.m_overheatListener);
      this.m_overheatListener = null;
      this.m_overheatDelaySent = false;
    };
    if IsDefined(this.m_chargeStatListener) {
      GameInstance.GetStatPoolsSystem(this.GetGame()).RequestUnregisteringListener(Cast(this.GetEntityID()), gamedataStatPoolType.WeaponCharge, this.m_chargeStatListener);
      this.m_chargeStatListener = null;
    };
    if IsDefined(this.m_damageTypeListener) {
      GameInstance.GetStatsSystem(this.GetGame()).UnregisterListener(Cast(this.GetEntityID()), this.m_damageTypeListener);
      this.m_damageTypeListener = null;
    };
  }

  public final const func HasSecondaryTriggerMode() -> Bool {
    return this.m_hasSecondaryTriggerMode;
  }

  public final const func GetWeaponRecord() -> ref<WeaponItem_Record> {
    return this.m_weaponRecord;
  }

  public final const func IsHeavyWeapon() -> Bool {
    return this.m_isHeavyWeapon;
  }

  public final const func IsRanged() -> Bool {
    return this.m_isRangedWeapon;
  }

  public final const func IsMelee() -> Bool {
    return this.m_isMeleeWeapon;
  }

  public final const func WeaponHasTag(tag: CName) -> Bool {
    return this.m_weaponRecord.TagsContains(tag);
  }

  public final const func GetAIBlackboard() -> ref<IBlackboard> {
    return this.m_AIBlackboard;
  }

  public final static func GetBaseMaxChargeThreshold() -> Float {
    return 50.00;
  }

  public final static func GetFullyChargedThreshold() -> Float {
    return 75.00;
  }

  public final static func GetOverchargeThreshold() -> Float {
    return 100.00;
  }

  public final func GetCurrentMeleeTrailEffectName() -> CName {
    return StringToName(this.m_trailName);
  }

  public final func SetMaxChargeThreshold(maxCharge: Float) -> Void {
    let evt: ref<WeaponSetMaxChargeEvent>;
    if this.m_maxChargeThreshold != maxCharge {
      this.m_maxChargeThreshold = maxCharge;
      evt = new WeaponSetMaxChargeEvent();
      evt.maxCharge = maxCharge;
      this.QueueEvent(evt);
    };
  }

  public final func GetMaxChargeTreshold() -> Float {
    return this.m_maxChargeThreshold;
  }

  public final static func ChangeTriggerMode(self: ref<WeaponObject>, triggerMode: gamedataTriggerMode) -> Void {
    let evt: ref<WeaponChangeTriggerModeEvent> = new WeaponChangeTriggerModeEvent();
    evt.triggerMode = triggerMode;
    self.QueueEvent(evt);
  }

  public final static func GetMagazineAmmoCount(self: ref<WeaponObject>) -> Uint32 {
    if IsDefined(self) {
      return self.GetSharedData().GetUint(GetAllBlackboardDefs().Weapon.MagazineAmmoCount);
    };
    return 0u;
  }

  public final static func GetMagazineCapacity(self: ref<WeaponObject>) -> Uint32 {
    if IsDefined(self) {
      return self.GetSharedData().GetUint(GetAllBlackboardDefs().Weapon.MagazineAmmoCapacity);
    };
    return 0u;
  }

  public final static func GetMagazinePercentage(self: ref<WeaponObject>) -> Float {
    if IsDefined(self) {
      return Cast(self.GetSharedData().GetUint(GetAllBlackboardDefs().Weapon.MagazineAmmoCount)) / Cast(self.GetSharedData().GetUint(GetAllBlackboardDefs().Weapon.MagazineAmmoCapacity));
    };
    return -1.00;
  }

  public final static func HasAvailableAmmo(self: ref<WeaponObject>) -> Bool {
    if IsDefined(self) && self.GetTotalAmmoCount() > 0 {
      return true;
    };
    return false;
  }

  public final static func HasAvailableAmmoInInventory(self: ref<WeaponObject>) -> Bool {
    if IsDefined(self) && self.GetTotalAmmoCount() - Cast(WeaponObject.GetMagazineAmmoCount(self)) > 0 {
      return true;
    };
    return false;
  }

  public final static func IsMagazineFull(self: ref<WeaponObject>) -> Bool {
    if IsDefined(self) && WeaponObject.GetMagazineAmmoCount(self) == WeaponObject.GetMagazineCapacity(self) {
      return true;
    };
    return false;
  }

  public final func IsMagazineEmpty() -> Bool {
    return this.GetSharedData().GetUint(GetAllBlackboardDefs().Weapon.MagazineAmmoCount) <= 0u;
  }

  public final static func IsMagazineEmpty(self: ref<WeaponObject>) -> Bool {
    if IsDefined(self) && WeaponObject.GetMagazineAmmoCount(self) <= 0u {
      return true;
    };
    return false;
  }

  public final static func CanReload(self: ref<WeaponObject>) -> Bool {
    if IsDefined(self) && WeaponObject.HasAvailableAmmoInInventory(self) && !WeaponObject.IsMagazineFull(self) {
      return true;
    };
    return false;
  }

  public final static func CanCriticallyHit(self: ref<WeaponObject>) -> Bool {
    if IsDefined(self) {
      return GameInstance.GetStatsSystem(self.GetGame()).GetStatValue(Cast(self.GetEntityID()), gamedataStatType.CanWeaponCriticallyHit) > 0.00;
    };
    return false;
  }

  public final static func CanIgnoreArmor(self: ref<WeaponObject>) -> Bool {
    if IsDefined(self) {
      return GameInstance.GetStatsSystem(self.GetGame()).GetStatValue(Cast(self.GetEntityID()), gamedataStatType.CanWeaponIgnoreArmor) > 0.00;
    };
    return false;
  }

  private final func SendScopeData() -> Void {
    let animFeature: ref<AnimFeature_WeaponScopeData>;
    let weaponRecID: TweakDBID;
    let weaponRecord: ref<WeaponItem_Record> = this.GetWeaponRecord();
    if IsDefined(weaponRecord) {
      weaponRecID = weaponRecord.GetID();
    };
    animFeature = new AnimFeature_WeaponScopeData();
    animFeature.hasScope = this.HasScope();
    animFeature.ironsightAngleWithScope = TDB.GetFloat(weaponRecID + t".ironsightAngleWithScope");
    AnimationControllerComponent.ApplyFeature(this, n"ScopeData", animFeature);
  }

  private final func SendWeaponStatsAnimFeature() -> Void {
    let statSystem: ref<StatsSystem> = GameInstance.GetStatsSystem(this.GetGame());
    let weaponStatsID: EntityID = this.GetEntityID();
    let animFeature: ref<AnimFeature_WeaponStats> = new AnimFeature_WeaponStats();
    animFeature.cycleTime = statSystem.GetStatValue(Cast(weaponStatsID), gamedataStatType.CycleTime);
    animFeature.magazineCapacity = Cast(statSystem.GetStatValue(Cast(weaponStatsID), gamedataStatType.MagazineCapacity));
    AnimationControllerComponent.ApplyFeature(this, n"WeaponStats", animFeature);
  }

  private final func OnUpdateWeaponStatsEvent(evt: ref<UpdateWeaponStatsEvent>) -> Void {
    this.SendWeaponStatsAnimFeature();
  }

  public final static func GetAmmoType(weapon: wref<WeaponObject>) -> ItemID {
    let weaponID: ItemID = weapon.GetItemID();
    let weaponRecord: ref<WeaponItem_Record> = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(weaponID)) as WeaponItem_Record;
    let ammoID: ItemID = ItemID.CreateQuery(weaponRecord.Ammo().GetID());
    return ammoID;
  }

  public final static func GetWeaponChargeNormalized(weapon: wref<WeaponObject>) -> Float {
    let statPoolSystem: ref<StatPoolsSystem> = GameInstance.GetStatPoolsSystem(weapon.GetGame());
    let result: Float = 0.00;
    let chargeVal: Float = statPoolSystem.GetStatPoolValue(Cast(weapon.GetEntityID()), gamedataStatPoolType.WeaponCharge, false);
    result = ClampF(chargeVal / weapon.GetMaxChargeTreshold(), 0.00, 1.00);
    return result;
  }

  public final static func GetAmmoType(weaponID: ItemID) -> ItemID {
    let weaponRecord: ref<WeaponItem_Record> = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(weaponID)) as WeaponItem_Record;
    let ammoID: ItemID = ItemID.CreateQuery(weaponRecord.Ammo().GetID());
    return ammoID;
  }

  public final static func GetWeaponType(weaponID: ItemID) -> gamedataItemType {
    let wpnRec: ref<WeaponItem_Record> = TweakDBInterface.GetWeaponItemRecord(ItemID.GetTDBID(weaponID));
    if IsDefined(wpnRec) {
      return wpnRec.ItemType().Type();
    };
    return gamedataItemType.Invalid;
  }

  public final static func IsRanged(weaponID: ItemID) -> Bool {
    let tags: array<CName>;
    let wpnRec: ref<WeaponItem_Record> = TweakDBInterface.GetWeaponItemRecord(ItemID.GetTDBID(weaponID));
    if IsDefined(wpnRec) {
      tags = wpnRec.Tags();
      if ArrayContains(tags, WeaponObject.GetRangedWeaponTag()) {
        return true;
      };
    };
    return false;
  }

  public final static func IsRanged(wpnRec: wref<Item_Record>) -> Bool {
    let tags: array<CName>;
    if !IsDefined(wpnRec) {
      return false;
    };
    tags = wpnRec.Tags();
    if ArrayContains(tags, WeaponObject.GetRangedWeaponTag()) {
      return true;
    };
    return false;
  }

  public final static func IsMelee(weaponID: ItemID) -> Bool {
    let tags: array<CName>;
    let wpnRec: ref<WeaponItem_Record> = TweakDBInterface.GetWeaponItemRecord(ItemID.GetTDBID(weaponID));
    if IsDefined(wpnRec) {
      tags = wpnRec.Tags();
      if ArrayContains(tags, WeaponObject.GetMeleeWeaponTag()) {
        return true;
      };
    };
    return false;
  }

  public final static func IsMelee(wpnRec: wref<WeaponItem_Record>) -> Bool {
    let tags: array<CName>;
    if !IsDefined(wpnRec) {
      return false;
    };
    tags = wpnRec.Tags();
    if ArrayContains(tags, WeaponObject.GetMeleeWeaponTag()) {
      return true;
    };
    return false;
  }

  public final static func IsFists(weaponID: ItemID) -> Bool {
    return WeaponObject.IsOfType(weaponID, gamedataItemType.Wea_Fists);
  }

  public final static func IsOfType(weaponID: ItemID, type: gamedataItemType) -> Bool {
    let wpnRec: ref<WeaponItem_Record> = TweakDBInterface.GetWeaponItemRecord(ItemID.GetTDBID(weaponID));
    if IsDefined(wpnRec) {
      if Equals(wpnRec.ItemType().Type(), type) {
        return true;
      };
    };
    return false;
  }

  public final static func GetMeleeWeaponTag() -> CName {
    return n"MeleeWeapon";
  }

  public final static func GetRangedWeaponTag() -> CName {
    return n"RangedWeapon";
  }

  public final static func GetOneHandedRangedWeaponTag() -> CName {
    return n"OneHandedRangedWeapon";
  }

  public final static func IsCyberwareWeapon(weaponID: ItemID) -> Bool {
    let i: Int32;
    let tags: array<CName>;
    let wpnRec: ref<WeaponItem_Record> = TweakDBInterface.GetWeaponItemRecord(ItemID.GetTDBID(weaponID));
    if IsDefined(wpnRec) {
      tags = wpnRec.Tags();
      i = 0;
      while i < ArraySize(tags) {
        if Equals(tags[i], n"Meleeware") || Equals(tags[i], n"Attack_Projectile") {
          return true;
        };
        i += 1;
      };
    };
    return false;
  }

  private final func SetWeaponOwner() -> Void {
    let localOwner: Int32;
    let animFeature: ref<AnimFeature_OwnerType> = new AnimFeature_OwnerType();
    if this.GetOwner().IsPlayer() {
      localOwner = EnumInt(animWeaponOwnerType.Player);
    } else {
      if this.GetOwner().IsNPC() {
        localOwner = EnumInt(animWeaponOwnerType.NPC);
      } else {
        localOwner = EnumInt(IntEnum(2l));
      };
    };
    animFeature.ownerEnum = localOwner;
    AnimationControllerComponent.ApplyFeature(this, n"Owner", animFeature);
  }

  protected cb func OnSetWeaponOwner(evt: ref<SetWeaponOwnerEvent>) -> Bool {
    this.SetWeaponOwner();
  }

  public final static func SendMuzzleOffset(weapon: ref<WeaponObject>, owner: ref<GameObject>) -> Void {
    let animFeature: ref<AnimFeature_MuzzleData> = new AnimFeature_MuzzleData();
    animFeature.muzzleOffset = weapon.GetMuzzleOffset();
    AnimationControllerComponent.ApplyFeature(owner, n"MuzzleData", animFeature);
  }

  private final func CheckLocked() -> Void;

  protected cb func OnOutlineRequestEvent(evt: ref<OutlineRequestEvent>) -> Bool {
    Log("WeaponObject \\ OutlineRequestEvent " + EntityID.ToDebugString(this.GetEntityID()));
    if Equals(evt.flag, false) {
      evt.flag = true;
      this.QueueEventToChildItems(evt);
    };
  }

  protected cb func OnForceFadeOutlineEventForWeapon(evt: ref<ForceFadeOutlineEventForWeapon>) -> Bool {
    Log("WeaponObject \\ ForceFadeOutlineEventForWeapon " + EntityID.ToDebugString(this.GetEntityID()));
    if evt.entityID != this.GetEntityID() {
      evt.entityID = this.GetEntityID();
      this.QueueEventToChildItems(evt);
    };
  }

  private final func HandleVisualEffectsSetup() -> Void {
    let damageType: gamedataDamageType;
    if this.IsMelee() {
      damageType = this.GetCurrentDamageType();
      this.StartIdleMeleeEffect(damageType);
      this.SetCurrentMeleeTrailEffect(damageType);
    };
  }

  private final func GetCurrentDamageType() -> gamedataDamageType {
    let cachedThreshold: Float;
    let returnType: gamedataDamageType;
    let statSystem: ref<StatsSystem> = GameInstance.GetStatsSystem(this.GetGame());
    let weaponID: StatsObjectID = Cast(this.GetEntityID());
    let chemDmg: Float = statSystem.GetStatValue(weaponID, gamedataStatType.ChemicalDamage);
    let thermDmg: Float = statSystem.GetStatValue(weaponID, gamedataStatType.ThermalDamage);
    let elecDmg: Float = statSystem.GetStatValue(weaponID, gamedataStatType.ElectricDamage);
    if chemDmg + thermDmg + elecDmg > 0.00 {
      cachedThreshold = thermDmg;
      returnType = gamedataDamageType.Thermal;
      if elecDmg > cachedThreshold {
        cachedThreshold = elecDmg;
        returnType = gamedataDamageType.Electric;
      };
      if chemDmg > cachedThreshold {
        cachedThreshold = chemDmg;
        returnType = gamedataDamageType.Chemical;
      };
    } else {
      returnType = gamedataDamageType.Physical;
    };
    return returnType;
  }

  private final func SetCurrentMeleeTrailEffect(damageType: gamedataDamageType) -> Void {
    switch damageType {
      case gamedataDamageType.Physical:
        this.m_trailName = "trail_physical";
        break;
      case gamedataDamageType.Thermal:
        this.m_trailName = "trail_thermal";
        break;
      case gamedataDamageType.Chemical:
        this.m_trailName = "trail_chemical";
        break;
      case gamedataDamageType.Electric:
        this.m_trailName = "trail_electric";
        break;
      default:
        this.m_trailName = "trail_physical";
    };
  }

  protected cb func OnUpdateMeleeTrailEffect(evt: ref<UpdateMeleeTrailEffectEvent>) -> Bool {
    if evt.instigator.IsPlayer() {
      switch this.GetCurrentDamageType() {
        case gamedataDamageType.Physical:
          this.m_trailName = "trail_physical";
          break;
        case gamedataDamageType.Thermal:
          this.m_trailName = "trail_thermal";
          break;
        case gamedataDamageType.Chemical:
          this.m_trailName = "trail_chemical";
          break;
        case gamedataDamageType.Electric:
          this.m_trailName = "trail_electric";
          break;
        default:
          this.m_trailName = "trail_physical";
      };
    } else {
      switch this.GetCurrentDamageType() {
        case gamedataDamageType.Physical:
          this.m_trailName = "trail_physical_npc";
          break;
        case gamedataDamageType.Thermal:
          this.m_trailName = "trail_thermal_npc";
          break;
        case gamedataDamageType.Chemical:
          this.m_trailName = "trail_chemical_npc";
          break;
        case gamedataDamageType.Electric:
          this.m_trailName = "trail_electric_npc";
          break;
        default:
          this.m_trailName = "trail_physical_npc";
      };
    };
  }

  private final func StartIdleMeleeEffect(damageType: gamedataDamageType) -> Void {
    let vfx_name: CName;
    switch damageType {
      case gamedataDamageType.Physical:
        vfx_name = n"idle_physical";
        break;
      case gamedataDamageType.Thermal:
        vfx_name = n"idle_thermal";
        break;
      case gamedataDamageType.Chemical:
        vfx_name = n"idle_chemical";
        break;
      case gamedataDamageType.Electric:
        vfx_name = n"idle_electric";
        break;
      default:
        vfx_name = n"idle_physical";
    };
    GameObjectEffectHelper.StartEffectEvent(this, vfx_name, false, this.m_chargeEffectBlackboard);
  }

  public final func StartCurrentMeleeTrailEffect(opt attackSide: String) -> Void {
    let trailName: String;
    if IsStringValid(attackSide) {
      trailName = this.m_trailName + "_" + attackSide;
    } else {
      trailName = this.m_trailName;
    };
    GameObjectEffectHelper.StartEffectEvent(this, StringToName(trailName), false, this.m_chargeEffectBlackboard);
  }

  public final func StopCurrentMeleeTrailEffect(opt attackSide: String) -> Void {
    let trailName: String;
    if IsStringValid(attackSide) {
      trailName = this.m_trailName + "_" + attackSide;
    } else {
      trailName = this.m_trailName;
    };
    GameObjectEffectHelper.BreakEffectLoopEvent(this, StringToName(trailName));
  }

  public final static native func TriggerWeaponEffects(weapon: wref<WeaponObject>, fxAction: gamedataFxAction, opt fxBlackboard: ref<worldEffectBlackboard>) -> Void;

  public final static func StopWeaponEffects(weaponOwner: wref<GameObject>, weapon: wref<WeaponObject>, fxAction: gamedataFxAction, opt fxBlackboard: ref<worldEffectBlackboard>) -> Void {
    let weaponFxSet: wref<WeaponVFXSet_Record>;
    let weaponFxPackage: wref<WeaponFxPackage_Record> = weapon.m_weaponRecord.FxPackage();
    if !IsDefined(weaponFxPackage) {
      return;
    };
    if weaponOwner.IsPlayer() {
      weaponFxSet = weaponFxPackage.Player_vfx_set();
    } else {
      weaponFxSet = weaponFxPackage.Npc_vfx_set();
    };
    if IsDefined(weaponFxSet) {
      WeaponObject.KillFXActionFromSet(weapon, weaponFxSet, fxAction, fxBlackboard);
    };
  }

  private final static func KillFXActionFromSet(weapon: wref<WeaponObject>, weaponFxSet: wref<WeaponVFXSet_Record>, fxAction: gamedataFxAction, opt fxBlackboard: ref<worldEffectBlackboard>) -> Void {
    let i: Int32;
    let weaponFxActions: array<wref<WeaponVFXAction_Record>>;
    weaponFxSet.Actions(weaponFxActions);
    i = 0;
    while i < ArraySize(weaponFxActions) {
      if IsDefined(weaponFxActions[i]) && Equals(weaponFxActions[i].FxAction().Type(), fxAction) {
        GameObjectEffectHelper.ActivateEffectAction(weapon, gamedataFxActionType.Kill, weaponFxActions[i].FxName(), fxBlackboard);
      };
      i += 1;
    };
  }

  public final static func SendAmmoUpdateEvent(weaponOwner: wref<GameObject>, weapon: wref<WeaponObject>) -> Void {
    let evt: ref<AmmoStateChangeEvent> = new AmmoStateChangeEvent();
    evt.weaponOwner = weaponOwner;
    weapon.QueueEventForEntityID(weapon.GetEntityID(), evt);
  }

  private final func OnAttachSetStatPools() -> Void {
    let statPoolSystem: ref<StatPoolsSystem> = GameInstance.GetStatPoolsSystem(this.GetGame());
    if WeaponObject.IsOfType(this.GetItemID(), gamedataItemType.Cyb_NanoWires) {
      statPoolSystem.RequestSettingStatPoolValue(Cast(this.GetEntityID()), gamedataStatPoolType.WeaponCharge, 100.00, this);
    } else {
      if this.IsMelee() && statPoolSystem.IsStatPoolAdded(Cast(this.GetEntityID()), gamedataStatPoolType.WeaponCharge) {
        statPoolSystem.RequestSettingStatPoolValue(Cast(this.GetEntityID()), gamedataStatPoolType.WeaponCharge, 0.00, this);
      };
    };
  }

  private final func RegisterStatPoolListeners() -> Void {
    let hasCharge: Bool;
    let i: Int32;
    let statPoolList: array<wref<StatPool_Record>>;
    let wpnRec: ref<WeaponItem_Record>;
    let statPoolsSystem: ref<StatPoolsSystem> = GameInstance.GetStatPoolsSystem(this.GetGame());
    if !IsDefined(statPoolsSystem) {
      return;
    };
    wpnRec = TweakDBInterface.GetWeaponItemRecord(ItemID.GetTDBID(this.GetItemID()));
    if !IsDefined(wpnRec) {
      return;
    };
    wpnRec.StatPools(statPoolList);
    i = 0;
    while i < ArraySize(statPoolList) {
      switch statPoolList[i].StatPoolType() {
        case gamedataStatPoolType.WeaponOverheat:
          this.m_hasOverheat = true;
          break;
        case gamedataStatPoolType.WeaponCharge:
          hasCharge = true;
          break;
        default:
      };
      i += 1;
    };
    if hasCharge && this.IsMelee() {
      this.m_chargeStatListener = new WeaponChargeStatListener();
      this.m_chargeStatListener.weapon = this;
      GameInstance.GetStatPoolsSystem(this.GetGame()).RequestRegisteringListener(Cast(this.GetEntityID()), gamedataStatPoolType.WeaponCharge, this.m_chargeStatListener);
      this.m_chargeEffectBlackboard = null;
    };
  }

  private final func RegisterStatListeners() -> Void {
    this.m_damageTypeListener = new DamageStatListener();
    this.m_damageTypeListener.weapon = this;
    GameInstance.GetStatsSystem(this.GetGame()).RegisterListener(Cast(this.GetEntityID()), this.m_damageTypeListener);
  }

  protected cb func OnUpdateOverheat(evt: ref<UpdateOverheatEvent>) -> Bool {
    let startEvt: ref<StartOverheatEffectEvent>;
    let value: Float;
    if !IsDefined(this.m_overheatEffectBlackboard) && !this.m_overheatDelaySent {
      startEvt = new StartOverheatEffectEvent();
      GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, startEvt, 0.30);
      this.m_overheatDelaySent = true;
    } else {
      value = (100.00 - evt.value) / 100.00;
      this.m_overheatEffectBlackboard.SetValue(n"overheatValue", value);
    };
  }

  protected final func StartOverheatEffect() -> Void {
    this.m_overheatEffectBlackboard = new worldEffectBlackboard();
    let spawnEffectEvent: ref<entSpawnEffectEvent> = new entSpawnEffectEvent();
    this.m_overheatEffectBlackboard.SetValue(n"overheatValue", 1.00);
    spawnEffectEvent.effectName = n"overheat";
    spawnEffectEvent.blackboard = this.m_overheatEffectBlackboard;
    this.QueueEventToChildItems(spawnEffectEvent);
  }

  protected cb func OnSetActiveWeapon(evt: ref<SetActiveWeaponEvent>) -> Bool {
    if this.m_hasOverheat {
      this.m_overheatListener = new OverheatStatListener();
      this.m_overheatListener.weapon = this;
      GameInstance.GetStatPoolsSystem(this.GetGame()).RequestRegisteringListener(Cast(this.GetEntityID()), gamedataStatPoolType.WeaponOverheat, this.m_overheatListener);
      this.m_overheatEffectBlackboard = null;
    };
  }

  protected cb func OnRemoveActiveWeapon(evt: ref<RemoveActiveWeaponEvent>) -> Bool {
    if IsDefined(this.m_overheatListener) {
      GameInstance.GetStatPoolsSystem(this.GetGame()).RequestUnregisteringListener(Cast(this.GetEntityID()), gamedataStatPoolType.WeaponOverheat, this.m_overheatListener);
      this.m_overheatListener = null;
    };
  }

  protected cb func OnUpdateWeaponCharge(evt: ref<UpdateWeaponChargeEvent>) -> Bool {
    if !IsDefined(this.m_chargeEffectBlackboard) {
      this.m_chargeEffectBlackboard = new worldEffectBlackboard();
      this.m_chargeEffectBlackboard.SetValue(n"chargeValue", evt.newValue / 100.00);
      GameObjectEffectHelper.StartEffectEvent(this, n"charge", false, this.m_chargeEffectBlackboard);
    } else {
      this.m_chargeEffectBlackboard.SetValue(n"chargeValue", evt.newValue / 100.00);
    };
  }

  protected cb func OnStartOverheatEffectEvent(evt: ref<StartOverheatEffectEvent>) -> Bool {
    this.StartOverheatEffect();
  }

  protected cb func OnUpdateDamageChangeEvent(evt: ref<UpdateDamageChangeEvent>) -> Bool {
    this.HandleVisualEffectsSetup();
  }

  protected cb func OnMeleeHitEvent(evt: ref<MeleeHitEvent>) -> Bool {
    if IsDefined(evt.instigator) && evt.instigator.IsPlayer() && (evt.instigator as PlayerPuppet).IsControlledByLocalPeer() {
      if !IsDefined(evt.target) || evt.hitBlocked || !(evt.target.IsPuppet() || evt.target.IsDevice()) {
        GameObject.PlaySound(evt.instigator, TDB.GetCName(t"rumble.local.heavy_pulse"));
      } else {
        GameObject.PlaySound(evt.instigator, TDB.GetCName(t"rumble.local.light_pulse"));
      };
    };
    if evt.hitBlocked && IsDefined(evt.target) && evt.target.IsPlayer() && (evt.target as PlayerPuppet).IsControlledByLocalPeer() {
      GameObject.PlaySound(evt.instigator, TDB.GetCName(t"rumble.local.light_pulse"));
    };
    if !evt.hitBlocked && IsDefined(evt.target) && evt.target.IsPuppet() {
      if IsDefined(this.m_meleeHitEffectBlackboard) {
        this.m_meleeHitEffectValue += 0.25;
        this.m_meleeHitEffectBlackboard.SetValue(n"value", this.m_meleeHitEffectValue);
      } else {
        this.m_meleeHitEffectBlackboard = new worldEffectBlackboard();
        this.m_meleeHitEffectValue = 0.25;
        this.m_meleeHitEffectBlackboard.SetValue(n"value", this.m_meleeHitEffectValue);
        WeaponObject.TriggerWeaponEffects(this, gamedataFxAction.MeleeHit, this.m_meleeHitEffectBlackboard);
      };
    };
  }

  protected cb func OnAmmoStateChangeEvent(evt: ref<AmmoStateChangeEvent>) -> Bool {
    if WeaponObject.GetMagazinePercentage(this) <= 0.25 && !this.m_lowAmmoEffectActive {
      WeaponObject.TriggerWeaponEffects(this, gamedataFxAction.EnterLowAmmo);
      this.m_lowAmmoEffectActive = true;
    } else {
      if WeaponObject.GetMagazinePercentage(this) > 0.25 && this.m_lowAmmoEffectActive {
        WeaponObject.TriggerWeaponEffects(this, gamedataFxAction.ExitLowAmmo);
        this.m_lowAmmoEffectActive = false;
      };
    };
  }
}

public abstract class AIWeapon extends IScriptable {

  public final static func GetShotTimeStamp(const weapon: wref<WeaponObject>) -> Float {
    return weapon.GetAIBlackboard().GetFloat(GetAllBlackboardDefs().AIShooting.shotTimeStamp);
  }

  public final static func GetNextShotTimeStamp(const weapon: wref<WeaponObject>) -> Float {
    return weapon.GetAIBlackboard().GetFloat(GetAllBlackboardDefs().AIShooting.nextShotTimeStamp);
  }

  public final static func GetTotalNumberOfShots(const weapon: wref<WeaponObject>) -> Int32 {
    return weapon.GetAIBlackboard().GetInt(GetAllBlackboardDefs().AIShooting.totalShotsFired);
  }

  public final static func GetDesiredNumberOfShots(const weapon: wref<WeaponObject>) -> Int32 {
    return weapon.GetAIBlackboard().GetInt(GetAllBlackboardDefs().AIShooting.desiredNumberOfShots);
  }

  public final static func GetIsFullyCharged(const weapon: wref<WeaponObject>) -> Bool {
    return weapon.GetAIBlackboard().GetBool(GetAllBlackboardDefs().AIShooting.fullyCharged);
  }

  public final static func UpdateSniperEffect(weapon: ref<WeaponObject>, duration: Float) -> Bool {
    return false;
  }

  public final static func UpdateCharging(weapon: wref<WeaponObject>, const timeStamp: Float, weaponOwner: wref<GameObject>, out chargeLevel: Float) -> Bool {
    let chargeDuration: Float;
    if AIWeapon.GetIsFullyCharged(weapon) {
      return false;
    };
    if AIWeapon.GetChargeLevel(weapon, timeStamp, chargeLevel) {
      if chargeLevel >= 1.00 {
        chargeLevel = 1.00;
        AIWeapon.OnFullyCharged(weapon);
      };
      return true;
    };
    chargeDuration = GameInstance.GetStatsSystem(weapon.GetGame()).GetStatValue(Cast(weapon.GetEntityID()), gamedataStatType.ChargeTime);
    if chargeDuration <= 0.00 {
      chargeDuration = GameInstance.GetStatsSystem(weapon.GetGame()).GetStatValue(Cast(weapon.GetEntityID()), gamedataStatType.BaseChargeTime);
      if chargeDuration <= 0.00 {
        return false;
      };
    };
    weapon.GetAIBlackboard().SetFloat(GetAllBlackboardDefs().AIShooting.chargeStartTimeStamp, timeStamp);
    weapon.GetAIBlackboard().SetFloat(GetAllBlackboardDefs().AIShooting.maxChargedTimeStamp, timeStamp + chargeDuration);
    WeaponObject.TriggerWeaponEffects(weapon, gamedataFxAction.EnterCharge);
    AIActionHelper.PlayWeaponEffect(weapon, n"charging_tpp");
    weapon.AI_PlayChargeStartedSound();
    return true;
  }

  public final static func GetChargeLevel(const weapon: wref<WeaponObject>, const actionDuration: Float, out chargeLevel: Float) -> Bool {
    let chargingDuration: Float;
    let maxChargedTimeStamp: Float = weapon.GetAIBlackboard().GetFloat(GetAllBlackboardDefs().AIShooting.maxChargedTimeStamp);
    let chargeStartTimeStamp: Float = weapon.GetAIBlackboard().GetFloat(GetAllBlackboardDefs().AIShooting.chargeStartTimeStamp);
    if maxChargedTimeStamp <= 0.00 || chargeStartTimeStamp <= 0.00 || maxChargedTimeStamp == chargeStartTimeStamp {
      chargeLevel = 0.00;
      return false;
    };
    chargingDuration = actionDuration - chargeStartTimeStamp;
    chargeLevel = MinF(1.00, chargingDuration / (maxChargedTimeStamp - chargeStartTimeStamp));
    return chargeLevel >= 0.00;
  }

  public final static func HasExceededDesiredNumberOfShots(const weapon: wref<WeaponObject>) -> Bool {
    let total: Int32;
    let desired: Int32 = AIWeapon.GetDesiredNumberOfShots(weapon);
    if desired > 0 {
      total = AIWeapon.GetTotalNumberOfShots(weapon);
      return total >= desired;
    };
    return false;
  }

  public final static func GetShootingPatternPackage(const weapon: wref<WeaponObject>) -> wref<AIPatternsPackage_Record> {
    return FromVariant(weapon.GetAIBlackboard().GetVariant(GetAllBlackboardDefs().AIShooting.shootingPatternPackage));
  }

  public final static func SetShootingPatternPackage(const weapon: wref<WeaponObject>, patternPackage: wref<AIPatternsPackage_Record>) -> Void {
    weapon.GetAIBlackboard().SetVariant(GetAllBlackboardDefs().AIShooting.shootingPatternPackage, ToVariant(patternPackage));
  }

  public final static func GetShootingPattern(const weapon: wref<WeaponObject>) -> wref<AIPattern_Record> {
    let patternVariant: Variant = weapon.GetAIBlackboard().GetVariant(GetAllBlackboardDefs().AIShooting.shootingPattern);
    if VariantIsValid(patternVariant) {
      return FromVariant(patternVariant);
    };
    return null;
  }

  public final static func SetShootingPattern(const weapon: wref<WeaponObject>, pattern: wref<AIPattern_Record>) -> Void {
    weapon.GetAIBlackboard().SetVariant(GetAllBlackboardDefs().AIShooting.shootingPattern, ToVariant(pattern));
  }

  public final static func GetPatternRange(const weapon: wref<WeaponObject>) -> array<wref<AIPattern_Record>> {
    let result: array<wref<AIPattern_Record>>;
    let patternVariant: Variant = weapon.GetAIBlackboard().GetVariant(GetAllBlackboardDefs().AIShooting.patternList);
    if VariantIsValid(patternVariant) {
      result = FromVariant(patternVariant);
    };
    return result;
  }

  public final static func SetPatternRange(const weapon: wref<WeaponObject>, patternList: array<wref<AIPattern_Record>>) -> Void {
    weapon.GetAIBlackboard().SetVariant(GetAllBlackboardDefs().AIShooting.patternList, ToVariant(patternList));
  }

  public final static func QueueNextShot(weapon: wref<WeaponObject>, requestedTriggerMode: gamedataTriggerMode, const timeStamp: Float, opt delayForNextShot: Float) -> Void {
    let isFirstShot: Bool;
    let maxShotsInBurst: Int32;
    let nextShotDelta: Float;
    let shotsInBurstFired: Int32;
    let weaponCycleTime: Float;
    let chargeDuration: Float = GameInstance.GetStatsSystem(weapon.GetGame()).GetStatValue(Cast(weapon.GetEntityID()), gamedataStatType.ChargeTime);
    if chargeDuration <= 0.00 {
      chargeDuration = GameInstance.GetStatsSystem(weapon.GetGame()).GetStatValue(Cast(weapon.GetEntityID()), gamedataStatType.BaseChargeTime);
    };
    shotsInBurstFired = weapon.GetAIBlackboard().GetInt(GetAllBlackboardDefs().AIShooting.shotsInBurstFired);
    maxShotsInBurst = Cast(GameInstance.GetStatsSystem(weapon.GetGame()).GetStatValue(Cast(weapon.GetEntityID()), gamedataStatType.NumShotsInBurst));
    isFirstShot = shotsInBurstFired == 1;
    if AIActionHelper.WeaponHasTriggerMode(weapon, gamedataTriggerMode.Burst) && shotsInBurstFired >= 0 && shotsInBurstFired < maxShotsInBurst {
      nextShotDelta = GameInstance.GetStatsSystem(weapon.GetGame()).GetStatValue(Cast(weapon.GetEntityID()), gamedataStatType.CycleTime_Burst);
    } else {
      if Equals(requestedTriggerMode, gamedataTriggerMode.Charge) && chargeDuration > delayForNextShot + weaponCycleTime {
        nextShotDelta = chargeDuration;
      } else {
        weapon.GetAIBlackboard().SetInt(GetAllBlackboardDefs().AIShooting.shotsInBurstFired, 0);
        weaponCycleTime = GameInstance.GetStatsSystem(weapon.GetGame()).GetStatValue(Cast(weapon.GetEntityID()), gamedataStatType.CycleTime);
        if delayForNextShot > 0.00 {
          nextShotDelta = MaxF(weaponCycleTime, delayForNextShot);
        } else {
          nextShotDelta = weaponCycleTime;
        };
      };
    };
    weapon.GetAIBlackboard().SetFloat(GetAllBlackboardDefs().AIShooting.nextShotTimeStamp, timeStamp + nextShotDelta);
    if isFirstShot {
      if Equals(weapon.GetCurrentTriggerMode().Type(), gamedataTriggerMode.Burst) || maxShotsInBurst > 0 {
        weapon.SetupBurstFireSound(maxShotsInBurst);
      };
    };
  }

  private final static func OnShotFired(weapon: wref<WeaponObject>, requestedTriggerMode: gamedataTriggerMode, const timeStamp: Float) -> Void {
    let totalShotsFired: Int32;
    let maxShotsInBurst: Int32 = Cast(GameInstance.GetStatsSystem(weapon.GetGame()).GetStatValue(Cast(weapon.GetEntityID()), gamedataStatType.NumShotsInBurst));
    let shotsInBurstFired: Int32 = weapon.GetAIBlackboard().GetInt(GetAllBlackboardDefs().AIShooting.shotsInBurstFired);
    if AIActionHelper.WeaponHasTriggerMode(weapon, gamedataTriggerMode.Burst) {
      shotsInBurstFired += 1;
      weapon.GetAIBlackboard().SetInt(GetAllBlackboardDefs().AIShooting.shotsInBurstFired, shotsInBurstFired);
    };
    if shotsInBurstFired >= maxShotsInBurst {
      totalShotsFired = weapon.GetAIBlackboard().GetInt(GetAllBlackboardDefs().AIShooting.totalShotsFired);
      totalShotsFired += 1;
      weapon.GetAIBlackboard().SetInt(GetAllBlackboardDefs().AIShooting.totalShotsFired, totalShotsFired);
    };
    AIActionHelper.KillWeaponEffect(weapon, n"d_turret_laser");
    AIActionHelper.KillWeaponEffect(weapon, n"scan");
    if Equals(requestedTriggerMode, gamedataTriggerMode.Charge) {
      AIActionHelper.KillWeaponEffect(weapon, n"charging_tpp");
    };
    weapon.GetAIBlackboard().SetFloat(GetAllBlackboardDefs().AIShooting.shotTimeStamp, timeStamp);
    weapon.GetAIBlackboard().SetFloat(GetAllBlackboardDefs().AIShooting.nextShotTimeStamp, -1.00);
    weapon.GetAIBlackboard().SetFloat(GetAllBlackboardDefs().AIShooting.maxChargedTimeStamp, -1.00);
    weapon.GetAIBlackboard().SetBool(GetAllBlackboardDefs().AIShooting.fullyCharged, false);
  }

  public final static func CanWeaponOverheat(gameObject: wref<WeaponObject>) -> Bool {
    let statPoolsSystem: ref<StatPoolsSystem>;
    if !IsDefined(gameObject) {
      return false;
    };
    statPoolsSystem = GameInstance.GetStatPoolsSystem(gameObject.GetGame());
    return statPoolsSystem.IsStatPoolAdded(Cast(gameObject.GetEntityID()), gamedataStatPoolType.WeaponOverheat);
  }

  public final static func GetWeaponOverheatStatPool(gameObject: wref<WeaponObject>) -> Float {
    let statPoolsSystem: ref<StatPoolsSystem>;
    if !IsDefined(gameObject) {
      return 0.00;
    };
    statPoolsSystem = GameInstance.GetStatPoolsSystem(gameObject.GetGame());
    return statPoolsSystem.GetStatPoolValue(Cast(gameObject.GetEntityID()), gamedataStatPoolType.WeaponOverheat, false);
  }

  private final static func ProcessWeaponOverheatStatPool(gameObject: wref<WeaponObject>, weaponOwner: wref<GameObject>, opt forceOverheat: Bool) -> Void {
    let isOverheated: Bool;
    let overheatPercentage: Float;
    let statPoolsSystem: ref<StatPoolsSystem>;
    if !IsDefined(gameObject) {
      return;
    };
    overheatPercentage = gameObject.GetSharedData().GetFloat(GetAllBlackboardDefs().Weapon.OverheatPercentage);
    isOverheated = gameObject.GetSharedData().GetBool(GetAllBlackboardDefs().Weapon.IsInForcedOverheatCooldown);
    statPoolsSystem = GameInstance.GetStatPoolsSystem(gameObject.GetGame());
    if isOverheated && !AIWeapon.GetWeaponOverheatBB(gameObject) || forceOverheat {
      AIWeapon.WeaponOverheated(gameObject);
      WeaponObject.TriggerWeaponEffects(gameObject, gamedataFxAction.EnterOverheat);
    } else {
      if overheatPercentage > 0.00 && isOverheated && AIWeapon.GetWeaponOverheatBB(gameObject) {
      } else {
        if overheatPercentage <= 0.00 && AIWeapon.GetWeaponOverheatBB(gameObject) {
          WeaponObject.TriggerWeaponEffects(gameObject, gamedataFxAction.ExitOverheat);
          AIWeapon.WeaponCooledDownFromOverheat(gameObject);
        } else {
          statPoolsSystem.RequestChangingStatPoolValue(Cast(gameObject.GetEntityID()), gamedataStatPoolType.WeaponOverheat, 7.00, null, false, false);
        };
      };
    };
  }

  private final static func GetWeaponOverheatBB(weapon: wref<WeaponObject>) -> Bool {
    return weapon.GetAIBlackboard().GetBool(GetAllBlackboardDefs().AIShooting.weaponOverheated);
  }

  public final static func ForceWeaponOverheat(weapon: wref<WeaponObject>, weaponOwner: wref<GameObject>) -> Void {
    let statPoolsSystem: ref<StatPoolsSystem> = GameInstance.GetStatPoolsSystem(weapon.GetGame());
    if AIWeapon.CanWeaponOverheat(weapon) {
      statPoolsSystem.RequestChangingStatPoolValue(Cast(weapon.GetEntityID()), gamedataStatPoolType.WeaponOverheat, 100.00, null, false, true);
      AIWeapon.ProcessWeaponOverheatStatPool(weapon, weaponOwner, true);
    };
  }

  private final static func OnFullyCharged(weapon: wref<WeaponObject>) -> Void {
    weapon.GetAIBlackboard().SetBool(GetAllBlackboardDefs().AIShooting.fullyCharged, true);
  }

  private final static func WeaponOverheated(weapon: wref<WeaponObject>) -> Void {
    weapon.GetAIBlackboard().SetBool(GetAllBlackboardDefs().AIShooting.weaponOverheated, true);
    AnimationControllerComponent.PushEventToReplicate(weapon, n"Overheat");
  }

  private final static func WeaponCooledDownFromOverheat(weapon: wref<WeaponObject>) -> Void {
    weapon.GetAIBlackboard().SetBool(GetAllBlackboardDefs().AIShooting.weaponOverheated, false);
  }

  public final static func OnStartShooting(weapon: wref<WeaponObject>, const opt desiredNumberOfShots: Int32) -> Void {
    weapon.GetAIBlackboard().SetInt(GetAllBlackboardDefs().AIShooting.shotsInBurstFired, 0);
    weapon.GetAIBlackboard().SetInt(GetAllBlackboardDefs().AIShooting.desiredNumberOfShots, desiredNumberOfShots);
    weapon.GetAIBlackboard().SetFloat(GetAllBlackboardDefs().AIShooting.nextShotTimeStamp, 0.00);
  }

  public final static func OnStopShooting(weapon: wref<WeaponObject>, const actionDuration: Float) -> Void {
    let chargeLevel: Float;
    AIActionHelper.KillWeaponEffect(weapon, n"d_turret_laser");
    AIActionHelper.KillWeaponEffect(weapon, n"scan");
    AIActionHelper.KillWeaponEffect(weapon, n"charging_tpp");
    AIActionHelper.BreakWeaponEffectLoop(weapon, n"charged");
    if AIWeapon.GetChargeLevel(weapon, actionDuration, chargeLevel) && chargeLevel < 1.00 {
      AIActionHelper.PlayWeaponEffect(weapon, n"discharge_tpp");
    };
    weapon.GetAIBlackboard().SetInt(GetAllBlackboardDefs().AIShooting.totalShotsFired, 0);
    weapon.GetAIBlackboard().SetFloat(GetAllBlackboardDefs().AIShooting.nextShotTimeStamp, -1.00);
    weapon.GetAIBlackboard().SetFloat(GetAllBlackboardDefs().AIShooting.maxChargedTimeStamp, -1.00);
    weapon.GetAIBlackboard().SetBool(GetAllBlackboardDefs().AIShooting.fullyCharged, false);
  }

  public final static func Fire(weaponOwner: wref<GameObject>, weapon: wref<WeaponObject>, const timeStamp: Float, tbhCoefficient: Float, requestedTriggerMode: gamedataTriggerMode, opt targetPosition: Vector4, opt target: ref<GameObject>, opt rangedAttack: TweakDBID, opt maxSpreadOverride: Float, opt aimingDelay: Float, opt offset: Vector4, opt shouldTrackTarget: Bool, opt predictionTime: Float, opt posProviderOverride: ref<IPositionProvider>) -> Void {
    let ammoPerShot: Int32;
    let attackAttemptEvent: ref<AIAttackAttemptEvent>;
    let bestTargetingComponent: wref<TargetingComponent>;
    let broadcaster: ref<StimBroadcasterComponent>;
    let cameraTransform: Transform;
    let chargeLevel: Float;
    let currentShootAtPos: Vector4;
    let maxSpread: Float;
    let miss: Bool;
    let playerShotOrigin: Vector4;
    let positionProvider: ref<IPositionProvider>;
    let projectileParams: gameprojectileWeaponParams;
    let projectilesPerShot: Int32;
    let statsSystem: ref<StatsSystem>;
    let targetShootComponent: ref<TargetShootComponent>;
    let weaponID: EntityID;
    let worldPos: WorldPosition;
    let playerShotOffset: Float = 0.40;
    let targetAsPuppet: ref<ScriptedPuppet> = target as ScriptedPuppet;
    if !IsDefined(weapon) || !weapon.IsAttached() {
      return;
    };
    weaponOwner.QueueEventForEntityID(weapon.GetEntityID(), new SetWeaponOwnerEvent());
    WeaponObject.SendMuzzleOffset(weapon, weaponOwner);
    if AIWeapon.CanWeaponOverheat(weapon) {
      AIWeapon.ProcessWeaponOverheatStatPool(weapon, weaponOwner);
      if AIWeapon.GetWeaponOverheatBB(weapon) {
        return;
      };
    };
    weaponID = weapon.GetEntityID();
    statsSystem = GameInstance.GetStatsSystem(weapon.GetGame());
    maxSpread = statsSystem.GetStatValue(Cast(weaponID), gamedataStatType.SpreadMaxAI);
    ammoPerShot = Cast(statsSystem.GetStatValue(Cast(weaponID), gamedataStatType.NumShotsToFire));
    projectilesPerShot = Cast(statsSystem.GetStatValue(Cast(weaponID), gamedataStatType.ProjectilesPerShot));
    if AIWeapon.GetChargeLevel(weapon, timeStamp, chargeLevel) {
      projectileParams.charge = chargeLevel;
    };
    if NotEquals(RPGManager.GetWeaponEvolution(weapon.GetItemID()), gamedataWeaponEvolution.Tech) && RPGManager.IsTechPierceEnabled(weaponOwner.GetGame(), weaponOwner, weapon.GetItemID()) {
      projectileParams.charge = 1.00;
    };
    chargeLevel *= 100.00;
    positionProvider = posProviderOverride;
    if aimingDelay > 0.00 && IsDefined(targetAsPuppet) {
      positionProvider = IPositionProvider.CreateEntityHistoryPositionProvider(targetAsPuppet.GetTransformHistoryComponent(), aimingDelay);
    };
    if IsDefined(target) {
      if target.IsPlayer() {
        bestTargetingComponent = (target as PlayerPuppet).GetPrimaryTargetingComponent();
      } else {
        bestTargetingComponent = GameInstance.GetTargetingSystem(weaponOwner.GetGame()).GetBestComponentOnTargetObject(weapon.GetWorldPosition(), weapon.GetWorldForward(), target, TargetComponentFilterType.Shooting);
      };
      if weaponOwner.GetSensesComponent().IsAgentVisible(target) || shouldTrackTarget {
        if IsDefined(bestTargetingComponent) {
          positionProvider = IsDefined(positionProvider) ? positionProvider : IPositionProvider.CreatePlacedComponentPositionProvider(bestTargetingComponent);
          if shouldTrackTarget {
            projectileParams.smartGunAccuracy = 1.00;
            projectileParams.smartGunIsProjectileGuided = true;
            projectileParams.trackedTargetComponent = bestTargetingComponent;
          };
        } else {
          positionProvider = IsDefined(positionProvider) ? positionProvider : IPositionProvider.CreateSlotPositionProvider(target, n"Head");
        };
        positionProvider.CalculatePosition(currentShootAtPos);
        if target.IsPlayer() {
          currentShootAtPos.Z -= 0.15;
        };
        if maxSpreadOverride > 0.00 {
          maxSpread = maxSpreadOverride;
        };
        targetShootComponent = target.GetTargetShootComponent();
        if IsDefined(targetShootComponent) && aimingDelay == 0.00 {
          offset += targetShootComponent.HandleWeaponShoot(weaponOwner, weapon, currentShootAtPos, maxSpread, tbhCoefficient, miss);
          if miss && shouldTrackTarget {
            gameprojectileWeaponParams.AddObjectToIgnoreCollisionWith(projectileParams, target.GetEntityID());
          };
        };
      };
    } else {
      WorldPosition.SetVector4(worldPos, targetPosition);
      positionProvider = IsDefined(positionProvider) ? positionProvider : IPositionProvider.CreateStaticPositionProvider(worldPos);
      currentShootAtPos = targetPosition;
    };
    if rangedAttack == t"Attacks.SuicideBullet" {
      projectileParams.ignoreWeaponOwnerCollision = false;
    } else {
      projectileParams.shootingOffset = statsSystem.GetStatValue(Cast(weaponID), gamedataStatType.ShootingOffsetAI);
    };
    AIWeapon.SetAttackBasedOnTimeDilation(weaponOwner, weapon, rangedAttack);
    projectileParams.hitPlaneOffset = offset;
    if rangedAttack == t"Attacks.SuicideBullet" && !GameInstance.GetTargetingSystem(weapon.GetGame()).IsVisibleTarget(GameInstance.GetPlayerSystem(weapon.GetGame()).GetLocalPlayerMainGameObject(), weaponOwner) {
      GameObject.ToggleForcedVisibilityInAnimSystemEvent(weaponOwner, n"SuicideBullet", true);
      weapon.AI_ShootSelfOffScreen(target as gamePuppet, Cast(ammoPerShot), projectileParams, Cast(projectilesPerShot), chargeLevel);
    } else {
      if IsDefined(weaponOwner as PlayerPuppet) {
        if GameInstance.GetCameraSystem(weaponOwner.GetGame()).GetActiveCameraWorldTransform(cameraTransform) {
          playerShotOrigin = Transform.GetPosition(cameraTransform) + Transform.GetForward(cameraTransform) * playerShotOffset;
          weapon.AI_ShootForwards(weaponOwner, Cast(ammoPerShot), projectileParams, Cast(projectilesPerShot), chargeLevel, playerShotOrigin, Transform.GetForward(cameraTransform));
        };
      } else {
        if AIActionHelper.ShouldShootDirectlyAtTarget(weaponOwner, weapon, currentShootAtPos) {
          if predictionTime > 0.00 {
            offset += Vector4.ClampLength((target as gamePuppet).GetVelocity(), 0.00, 15.00) * predictionTime;
          };
          positionProvider.SetWorldOffset(offset);
          weapon.AI_ShootAt(positionProvider, target, weaponOwner, Cast(ammoPerShot), projectileParams, Cast(projectilesPerShot), chargeLevel, maxSpread);
        } else {
          if !Vector4.IsZero(currentShootAtPos) && weaponOwner.GetTargetTrackerComponent().IsPositionValid(currentShootAtPos) {
            positionProvider.SetWorldOffset(offset);
            weapon.AI_ShootAt(positionProvider, target, weaponOwner, Cast(ammoPerShot), projectileParams, Cast(projectilesPerShot), chargeLevel, maxSpread);
          } else {
            weapon.AI_ShootForwards(weaponOwner, Cast(ammoPerShot), projectileParams, Cast(projectilesPerShot), chargeLevel);
          };
        };
      };
    };
    if IsDefined(target) {
      attackAttemptEvent = new AIAttackAttemptEvent();
      attackAttemptEvent.instigator = weaponOwner;
      attackAttemptEvent.target = target;
      weaponOwner.QueueEvent(attackAttemptEvent);
    };
    AnimationControllerComponent.PushEventToReplicate(weaponOwner, n"Shoot");
    AnimationControllerComponent.PushEventToReplicate(weapon, n"Shoot");
    WeaponObject.TriggerWeaponEffects(weapon, gamedataFxAction.Shoot);
    WeaponObject.SendAmmoUpdateEvent(weaponOwner, weapon);
    broadcaster = weaponOwner.GetStimBroadcasterComponent();
    if IsDefined(broadcaster) && !weaponOwner.IsPlayer() {
      broadcaster.TriggerSingleBroadcast(weapon, gamedataStimType.Gunshot);
    };
    AIWeapon.OnShotFired(weapon, requestedTriggerMode, timeStamp);
  }

  public final static func SetAttackBasedOnTimeDilation(owner: wref<GameObject>, weapon: wref<WeaponObject>, opt overrideRangedAttack: TweakDBID) -> Void {
    let attackID: TweakDBID;
    let isFriendlySource: Bool;
    let magazine: wref<ItemObject>;
    let magazineAttack: TweakDBID;
    let ownerAttitude: CName;
    let playerAttitude: CName;
    let rangedAttack: ref<RangedAttack_Record>;
    let weaponRecord: ref<WeaponItem_Record> = TweakDBInterface.GetWeaponItemRecord(ItemID.GetTDBID(weapon.GetItemID()));
    let useProjectile: Bool = GameInstance.GetTimeSystem(weapon.GetGame()).IsTimeDilationActive();
    if owner.IsNPC() && StatusEffectSystem.ObjectHasStatusEffect(owner, t"BaseStatusEffect.SuicideWithWeapon") {
      useProjectile = false;
    };
    playerAttitude = GameInstance.GetPlayerSystem(owner.GetGame()).GetLocalPlayerMainGameObject().GetAttitudeAgent().GetAttitudeGroup();
    ownerAttitude = owner.GetAttitudeAgent().GetAttitudeGroup();
    isFriendlySource = Equals(ownerAttitude, playerAttitude);
    if TDBID.IsValid(overrideRangedAttack) {
      rangedAttack = TweakDBInterface.GetRangedAttackRecord(overrideRangedAttack);
    } else {
      magazine = GameInstance.GetTransactionSystem(weapon.GetGame()).GetItemInSlot(weapon, t"AttachmentSlots.DamageMod");
      if IsDefined(magazine) {
        magazineAttack = TDBID.Create(TweakDBInterface.GetString(ItemID.GetTDBID(magazine.GetItemID()) + t".overrideAttack", ""));
      };
      if TDBID.IsValid(magazineAttack) {
        rangedAttack = TweakDBInterface.GetRangedAttackPackageRecord(magazineAttack).DefaultFire();
      } else {
        rangedAttack = weaponRecord.RangedAttacks().DefaultFire();
      };
    };
    if owner.IsNPC() || !isFriendlySource {
      if useProjectile {
        attackID = rangedAttack.NPCTimeDilated().GetID();
      } else {
        attackID = rangedAttack.NPCAttack().GetID();
      };
    } else {
      if isFriendlySource {
        if useProjectile {
          attackID = rangedAttack.PlayerTimeDilated().GetID();
        } else {
          attackID = rangedAttack.PlayerAttack().GetID();
        };
      };
    };
    weapon.SetAttack(attackID);
  }

  public final static func GetShootingPatternDelayBetweenShots(totalShotsFired: Int32, pattern: wref<AIPattern_Record>) -> Float {
    let debugRecordName: String;
    let delays: array<wref<AIPatternDelay_Record>>;
    let i: Int32;
    let patternSize: Int32;
    let shotDelay: Float;
    let shotNumber: Int32;
    pattern.Delays(delays);
    if !IsFinal() {
      debugRecordName = TDBID.ToStringDEBUG(pattern.GetID());
      if AIActionHelper.ActionDebugHelper("", debugRecordName) {
        LogAI("GetShootingPatternDelayBetweenShots Debug Breakpoint");
      };
    };
    patternSize = pattern.PatternSize();
    if patternSize < 1 {
      patternSize = ArraySize(delays);
    };
    shotNumber = Cast(ModF(Cast(totalShotsFired), Cast(patternSize)));
    if shotNumber < ArraySize(delays) && delays[shotNumber].ShotNumber() == shotNumber {
      shotDelay = delays[shotNumber].Delay();
    } else {
      i = 0;
      while i < ArraySize(delays) {
        if delays[i].ShotNumber() == shotNumber {
          shotDelay = delays[i].Delay();
        };
        i += 1;
      };
    };
    return MaxF(0.00, shotDelay);
  }

  public final static func SelectShootingPattern(record: wref<AISubActionShootWithWeapon_Record>, weapon: wref<WeaponObject>, weaponOwner: wref<GameObject>, opt forceReselection: Bool) -> Void {
    let chosenPackage: wref<AIPatternsPackage_Record>;
    let debugRecordName: String;
    let patternsList: array<wref<AIPattern_Record>>;
    let selectedPattern: wref<AIPattern_Record>;
    let shootingPatternPackages: array<wref<AIPatternsPackage_Record>>;
    record.ShootingPatternPackages(shootingPatternPackages);
    chosenPackage = AIWeapon.SelectShootingPatternPackage(weaponOwner, weapon, shootingPatternPackages);
    if !IsFinal() {
      debugRecordName = TDBID.ToStringDEBUG(chosenPackage.GetID());
      if AIActionHelper.ActionDebugHelper("", weaponOwner, debugRecordName) {
        LogAI("SelectShootingPattern Debug Breakpoint");
      };
    };
    if AIWeapon.GetShootingPatternsList(weaponOwner, weapon, chosenPackage, patternsList) || forceReselection {
      if ArraySize(patternsList) > 0 {
        AIWeapon.SelectShootingPatternFromList(weapon, patternsList, selectedPattern);
      };
    };
    if IsDefined(selectedPattern) {
      if !IsFinal() {
        debugRecordName = TDBID.ToStringDEBUG(selectedPattern.GetID());
        if AIActionHelper.ActionDebugHelper("", weaponOwner, debugRecordName) {
          LogAI("SelectShootingPattern Debug Breakpoint");
        };
      };
      AIWeapon.SetShootingPattern(weapon, selectedPattern);
      AIWeapon.SetShootingPatternPackage(weapon, chosenPackage);
      AIWeapon.SetPatternRange(weapon, patternsList);
    };
  }

  public final static func SelectShootingPatternPackage(weaponOwner: wref<GameObject>, weapon: wref<WeaponObject>, opt records: array<wref<AIPatternsPackage_Record>>) -> wref<AIPatternsPackage_Record> {
    let archetypeData: wref<ArchetypeData_Record>;
    let candidate: wref<AIPatternsPackage_Record>;
    let characterRecord: ref<Character_Record>;
    let weaponRecord: ref<WeaponItem_Record>;
    if ArraySize(records) > 0 {
      if AIWeapon.GetPatternPackagesMeetingConditionChecks(weaponOwner, records, candidate) {
        return candidate;
      };
    };
    characterRecord = TweakDBInterface.GetCharacterRecord((weaponOwner as ScriptedPuppet).GetRecordID());
    if IsDefined(characterRecord) {
      archetypeData = characterRecord.ArchetypeData();
      if IsDefined(archetypeData) {
        archetypeData.ShootingPatternPackages(records);
        if ArraySize(records) > 0 {
          if AIWeapon.GetPatternPackagesMeetingConditionChecks(weaponOwner, records, candidate) {
            return candidate;
          };
        };
      };
    };
    ArrayClear(records);
    weaponRecord = TweakDBInterface.GetWeaponItemRecord(ItemID.GetTDBID(weapon.GetItemID()));
    weaponRecord.ShootingPatternPackages(records);
    if ArraySize(records) > 0 {
      if AIWeapon.GetPatternPackagesMeetingConditionChecks(weaponOwner, records, candidate) {
        return candidate;
      };
    };
    ArrayClear(records);
    AIActionHelper.GetBaseShootingPatternPackages(records);
    if ArraySize(records) > 0 {
      if AIWeapon.GetPatternPackagesMeetingConditionChecks(weaponOwner, records, candidate) {
        return candidate;
      };
    };
    return null;
  }

  public final static func GetPatternPackagesMeetingConditionChecks(weaponOwner: wref<GameObject>, records: array<wref<AIPatternsPackage_Record>>, out package: wref<AIPatternsPackage_Record>) -> Bool {
    let conditions: array<wref<AIActionCondition_Record>>;
    let context: ScriptExecutionContext;
    let res: Bool = AIHumanComponent.GetScriptContext(weaponOwner as ScriptedPuppet, context);
    let i: Int32 = 0;
    while i < ArraySize(records) {
      ArrayClear(conditions);
      records[i].ActivationConditions(conditions);
      if ArraySize(conditions) > 0 {
        if res && AICondition.CheckActionConditions(context, conditions) {
          package = records[i];
          return true;
        };
      } else {
        package = records[i];
        return true;
      };
      i += 1;
    };
    return false;
  }

  public final static func GetShootingPatternsList(weaponOwner: wref<GameObject>, weapon: wref<WeaponObject>, chosenPackage: wref<AIPatternsPackage_Record>, out patternsList: array<wref<AIPattern_Record>>) -> Bool {
    let conditions: array<wref<AIActionCondition_Record>>;
    let context: ScriptExecutionContext;
    let debugRecordName: String;
    let i: Int32;
    let patterns: array<wref<AIPattern_Record>>;
    let previousList: array<wref<AIPattern_Record>>;
    let res: Bool = AIHumanComponent.GetScriptContext(weaponOwner as ScriptedPuppet, context);
    chosenPackage.Patterns(patterns);
    i = 0;
    while i < ArraySize(patterns) {
      if !IsFinal() {
        debugRecordName = TDBID.ToStringDEBUG(patterns[i].GetID());
        if AIActionHelper.ActionDebugHelper("", weaponOwner, debugRecordName) {
          LogAI("SelectShootingPattern Debug Breakpoint");
        };
      };
      ArrayClear(conditions);
      patterns[i].ActivationConditions(conditions);
      if ArraySize(conditions) > 0 {
        if res && AICondition.CheckActionConditions(context, conditions) {
          ArrayPush(patternsList, patterns[i]);
        };
      } else {
        ArrayPush(patternsList, patterns[i]);
      };
      i += 1;
    };
    previousList = AIWeapon.GetPatternRange(weapon);
    if AIWeapon.CompareAIPatternRecordArrays(previousList, patternsList) {
      return false;
    };
    return true;
  }

  public final static func CompareAIPatternRecordArrays(const arr1: array<wref<AIPattern_Record>>, const arr2: array<wref<AIPattern_Record>>) -> Bool {
    let i: Int32;
    let size: Int32 = ArraySize(arr1);
    if size != ArraySize(arr2) {
      return false;
    };
    while i < size {
      if arr1[i] != arr2[i] {
        return false;
      };
      i += 1;
    };
    return true;
  }

  public final static func SelectShootingPatternFromList(weapon: wref<WeaponObject>, const patternsList: array<wref<AIPattern_Record>>, out selectedPattern: wref<AIPattern_Record>) -> Void {
    let lastPattern: wref<AIPattern_Record> = AIWeapon.GetShootingPattern(weapon);
    if IsDefined(lastPattern) && ArraySize(patternsList) > 1 {
      selectedPattern = patternsList[RandRange(0, ArraySize(patternsList))];
      if selectedPattern == lastPattern {
      } else {
      };
    } else {
      selectedPattern = patternsList[RandRange(0, ArraySize(patternsList))];
    };
  }
}

public static exec func SilenceWeapon(gameInstance: GameInstance, flag: String) -> Void {
  let playerPuppet: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(gameInstance).GetLocalPlayerMainGameObject() as PlayerPuppet;
  let blackboardSystem: ref<BlackboardSystem> = GameInstance.GetBlackboardSystem(gameInstance);
  let blackboard: ref<IBlackboard> = blackboardSystem.GetLocalInstanced(playerPuppet.GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
  blackboard.SetBool(GetAllBlackboardDefs().PlayerStateMachine.DEBUG_SilencedWeapon, StringToBool(flag));
}

public class OverheatStatListener extends ScriptStatPoolsListener {

  public let weapon: wref<WeaponObject>;

  private let updateEvt: ref<UpdateOverheatEvent>;

  private let startEvt: ref<StartOverheatEffectEvent>;

  public func OnStatPoolValueChanged(oldValue: Float, newValue: Float, percToPoints: Float) -> Void {
    this.updateEvt = new UpdateOverheatEvent();
    this.updateEvt.value = newValue;
    this.weapon.QueueEventForEntityID(this.weapon.GetEntityID(), this.updateEvt);
  }
}

public class DamageStatListener extends ScriptStatsListener {

  public let weapon: wref<WeaponObject>;

  private let updateEvt: ref<UpdateDamageChangeEvent>;

  public func OnStatChanged(ownerID: StatsObjectID, statType: gamedataStatType, diff: Float, total: Float) -> Void {
    if Equals(statType, gamedataStatType.ChemicalDamage) || Equals(statType, gamedataStatType.PhysicalDamage) || Equals(statType, gamedataStatType.ThermalDamage) || Equals(statType, gamedataStatType.ElectricDamage) {
      this.updateEvt = new UpdateDamageChangeEvent();
      this.weapon.QueueEventForEntityID(this.weapon.GetEntityID(), this.updateEvt);
    };
  }
}

public class WeaponChargeStatListener extends CustomValueStatPoolsListener {

  public let weapon: wref<WeaponObject>;

  public func OnStatPoolValueChanged(oldValue: Float, newValue: Float, percToPoints: Float) -> Void {
    let updateEvt: ref<UpdateWeaponChargeEvent> = new UpdateWeaponChargeEvent();
    updateEvt.newValue = newValue;
    updateEvt.oldValue = oldValue;
    this.weapon.QueueEventForEntityID(this.weapon.GetEntityID(), updateEvt);
  }
}
