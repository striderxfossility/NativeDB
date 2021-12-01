
public class StatPoolsManager extends IScriptable {

  public final static func ApplyDamage(hitEvent: ref<gameHitEvent>, forReal: Bool, out valuesLost: array<SDamageDealt>) -> Void {
    let asHitDataBase: ref<HitData_Base>;
    let asHitShapeUserDataBase: ref<HitShapeUserDataBase>;
    let attackValues: array<Float>;
    let damageCeiling: Float;
    let dmgType: gamedataDamageType;
    let firstHit: Bool;
    let i: Int32;
    let isProtectionLayer: Bool;
    let j: Int32;
    let maxPercentDamage: Float;
    let npcTarget: wref<NPCPuppet>;
    let poolType: gamedataStatPoolType;
    let projectilesPerShot: Float;
    let statsSystem: ref<StatsSystem>;
    let targetHit: Bool;
    let tempLost: array<SDamageDealt>;
    let hitShapes: array<HitShapeData> = hitEvent.hitRepresentationResult.hitShapes;
    let target: ref<GameObject> = hitEvent.target;
    ArrayClear(valuesLost);
    attackValues = hitEvent.attackComputed.GetAttackValues();
    i = 0;
    while i < ArraySize(attackValues) {
      dmgType = IntEnum(i);
      statsSystem = GameInstance.GetStatsSystem(target.GetGame());
      maxPercentDamage = statsSystem.GetStatValue(Cast(target.GetEntityID()), gamedataStatType.MaxPercentDamageTakenPerHit);
      npcTarget = target as NPCPuppet;
      if IsDefined(npcTarget) && maxPercentDamage > 0.00 && NotEquals(hitEvent.attackData.GetAttackType(), gamedataAttackType.Hack) {
        if npcTarget.IsBoss() {
          projectilesPerShot = statsSystem.GetStatValue(Cast(hitEvent.attackData.GetWeapon().GetEntityID()), gamedataStatType.ProjectilesPerShot);
          if AttackData.IsDoT(hitEvent.attackData.GetAttackType()) {
            maxPercentDamage *= TweakDBInterface.GetFloat(t"Constants.DamageSystem.maxDamageDoTProportion", 1.00);
          };
          damageCeiling = maxPercentDamage / 100.00 * statsSystem.GetStatValue(Cast(target.GetEntityID()), gamedataStatType.Health);
          if projectilesPerShot > 0.00 {
            damageCeiling /= projectilesPerShot;
          };
          attackValues[i] = ClampF(attackValues[i], 0.00, damageCeiling);
        };
      };
      if attackValues[i] > 0.00 && attackValues[i] < 1.00 {
        attackValues[i] = 1.00;
      };
      firstHit = false;
      j = 0;
      while j < ArraySize(hitShapes) {
        isProtectionLayer = false;
        asHitDataBase = hitShapes[j].userData as HitData_Base;
        asHitShapeUserDataBase = hitShapes[j].userData as HitShapeUserDataBase;
        if IsDefined(asHitDataBase) {
          isProtectionLayer = Equals(asHitDataBase.m_hitShapeType, HitShape_Type.ProtectionLayer);
        } else {
          if IsDefined(asHitShapeUserDataBase) {
            isProtectionLayer = asHitShapeUserDataBase.m_isProtectionLayer;
          };
        };
        if !firstHit && !isProtectionLayer {
          firstHit = true;
          targetHit = true;
        };
        if !targetHit && isProtectionLayer && ArraySize(hitShapes) < 12 {
          attackValues[i] = 0.00;
          hitEvent.attackData.RemoveFlag(hitFlag.Headshot);
          hitEvent.attackData.RemoveFlag(hitFlag.CriticalHit);
          hitEvent.attackData.SetHitType(gameuiHitType.Glance);
        };
        if IsDefined(asHitDataBase) {
          if StatPoolsManager.GetBodyPartStatPool(target, asHitDataBase.m_bodyPartStatPoolName, poolType) {
            StatPoolsManager.ApplyLocalizedDamageSingle(hitEvent, attackValues[i], dmgType, poolType, forReal, tempLost);
            StatPoolsManager.MergeStatPoolsLost(valuesLost, tempLost);
          };
        };
        j += 1;
      };
      StatPoolsManager.ApplyDamageSingle(hitEvent, dmgType, attackValues[i], forReal, tempLost);
      StatPoolsManager.MergeStatPoolsLost(valuesLost, tempLost);
      i += 1;
    };
    hitEvent.attackComputed.SetAttackValues(attackValues);
  }

  private final static func ApplyLocalizedDamageSingle(hitEvent: ref<gameHitEvent>, dmg: Float, dmgType: gamedataDamageType, poolType: gamedataStatPoolType, forReal: Bool, out valuesLost: array<SDamageDealt>) -> Void {
    let currentPoolVal: Float;
    let dmgVal: Float;
    let newPool: SDamageDealt;
    let valueToDrain: Float;
    let targetID: StatsObjectID = Cast(hitEvent.target.GetEntityID());
    ArrayClear(valuesLost);
    currentPoolVal = GameInstance.GetStatPoolsSystem(hitEvent.target.GetGame()).GetStatPoolValue(targetID, poolType, false);
    if currentPoolVal > 0.00 {
      dmgVal = dmg;
      valueToDrain = currentPoolVal <= dmgVal ? currentPoolVal : dmgVal;
      if forReal {
        StatPoolsManager.DrainStatPool(hitEvent, poolType, valueToDrain);
      };
      newPool.affectedStatPool = poolType;
      newPool.value = valueToDrain;
      newPool.type = dmgType;
      ArrayPush(valuesLost, newPool);
    };
  }

  private final static func MergeStatPoolsLost(out to: array<SDamageDealt>, from: array<SDamageDealt>) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(from) {
      StatPoolsManager.AddDrain(to, from[i].affectedStatPool, from[i].value, from[i].type);
      i += 1;
    };
  }

  private final static func GetBodyPartStatPool(obj: ref<GameObject>, bodyPartName: CName, out poolType: gamedataStatPoolType) -> Bool {
    let value: Float;
    let objectID: StatsObjectID = Cast(obj.GetEntityID());
    let statPoolType: gamedataStatPoolType = IntEnum(Cast(EnumValueFromName(n"gamedataStatPoolType", bodyPartName)));
    if StatPoolsManager.IsStatPoolValid(statPoolType) {
      value = GameInstance.GetStatPoolsSystem(obj.GetGame()).GetStatPoolValue(objectID, statPoolType);
      if value > 0.00 {
        poolType = statPoolType;
      };
      return true;
    };
    poolType = gamedataStatPoolType.Invalid;
    return false;
  }

  private final static func AddDrain(out arr: array<SDamageDealt>, type: gamedataStatPoolType, value: Float, dmgType: gamedataDamageType) -> Void {
    let res: SDamageDealt;
    let i: Int32 = 0;
    while i < ArraySize(arr) {
      if Equals(arr[i].affectedStatPool, type) {
        arr[i].value += value;
        return;
      };
      i += 1;
    };
    res.type = dmgType;
    res.affectedStatPool = type;
    res.value = value;
    ArrayPush(arr, res);
  }

  private final static func ApplyDamageSingle(hitEvent: ref<gameHitEvent>, dmgType: gamedataDamageType, initialDamageValue: Float, forReal: Bool, out valuesLost: array<SDamageDealt>) -> Void {
    let currentHealthValue: Float;
    let statPoolValue: SDamageDealt;
    let attackData: ref<AttackData> = hitEvent.attackData;
    let instigator: wref<GameObject> = attackData.GetInstigator();
    let statPoolsSystem: ref<StatPoolsSystem> = GameInstance.GetStatPoolsSystem(hitEvent.target.GetGame());
    ArrayClear(valuesLost);
    currentHealthValue = statPoolsSystem.GetStatPoolValue(Cast(hitEvent.target.GetEntityID()), gamedataStatPoolType.Health, false);
    if currentHealthValue > 0.00 {
      StatPoolsManager.ApplyDamageToArmorSingle(hitEvent, dmgType, initialDamageValue, forReal, valuesLost);
      if initialDamageValue >= 0.00 {
        if currentHealthValue < initialDamageValue {
          attackData.AddFlag(hitFlag.WasKillingBlow, n"Killing Blow");
          initialDamageValue = currentHealthValue;
        };
        if forReal {
          statPoolsSystem.RequestSettingStatPoolValue(Cast(hitEvent.target.GetEntityID()), gamedataStatPoolType.CPO_Armor, 0.00, instigator);
          StatPoolsManager.DrainStatPool(hitEvent, gamedataStatPoolType.Health, initialDamageValue);
        };
        statPoolValue.type = dmgType;
        statPoolValue.affectedStatPool = gamedataStatPoolType.Health;
        statPoolValue.value = initialDamageValue;
        ArrayPush(valuesLost, statPoolValue);
        attackData.AddFlag(hitFlag.SuccessfulAttack, n"DealtDamage");
      };
    };
  }

  private final static func ApplyDamageToArmorSingle(hitEvent: ref<gameHitEvent>, dmgType: gamedataDamageType, out initialDamageValue: Float, forReal: Bool, out valuesLost: array<SDamageDealt>) -> Void {
    let statPoolValue: SDamageDealt;
    let statPoolsSystem: ref<StatPoolsSystem> = GameInstance.GetStatPoolsSystem(hitEvent.target.GetGame());
    let currentArmorValue: Float = statPoolsSystem.GetStatPoolValue(Cast(hitEvent.target.GetEntityID()), gamedataStatPoolType.CPO_Armor, false);
    if currentArmorValue > 0.00 {
      if forReal {
        StatPoolsManager.DrainStatPool(hitEvent, gamedataStatPoolType.CPO_Armor, initialDamageValue);
      };
      statPoolValue.type = dmgType;
      statPoolValue.affectedStatPool = gamedataStatPoolType.CPO_Armor;
      statPoolValue.value = MinF(initialDamageValue, currentArmorValue);
      ArrayPush(valuesLost, statPoolValue);
      initialDamageValue = initialDamageValue - currentArmorValue;
    };
  }

  public final static func ApplyStatusEffectDamage(hitEvent: ref<gameHitEvent>, resistPoolRecord: ref<StatPool_Record>, statusEffectID: TweakDBID) -> Void {
    let finalDamage: Float;
    let resistanceFactor: Float;
    let statusEffectListener: ref<StatusEffectTriggerListener>;
    let target: ref<GameObject> = hitEvent.target;
    let instigator: wref<GameObject> = hitEvent.attackData.GetInstigator();
    let targetID: EntityID = target.GetEntityID();
    let statPoolsSystem: ref<StatPoolsSystem> = GameInstance.GetStatPoolsSystem(target.GetGame());
    let resistPool: gamedataStatPoolType = resistPoolRecord.StatPoolType();
    let baseDamage: Float = hitEvent.attackComputed.GetTotalAttackValue(gamedataStatPoolType.Health);
    if !statPoolsSystem.IsStatPoolAdded(Cast(targetID), resistPool) {
      statusEffectListener = new StatusEffectTriggerListener();
      statusEffectListener.m_owner = target;
      statusEffectListener.m_statusEffect = statusEffectID;
      statusEffectListener.m_statPoolType = resistPool;
      statusEffectListener.m_instigator = instigator;
      statPoolsSystem.RequestAddingStatPool(Cast(targetID), resistPoolRecord.GetID());
      statPoolsSystem.RequestRegisteringListener(Cast(targetID), resistPool, statusEffectListener);
      GameObject.AddStatusEffectTriggerListener(target, statusEffectListener);
    };
    resistanceFactor = 0.50;
    finalDamage = baseDamage * resistanceFactor;
    StatPoolsManager.DrainStatPool(hitEvent, resistPool, finalDamage);
  }

  public final static func DrainStatPool(hitEvent: ref<gameHitEvent>, statPoolType: gamedataStatPoolType, value: Float) -> Void {
    let dmgExpPercent: Float;
    let isTargetImmortal: Bool;
    let percValueToDrain: Float;
    let processVendettaEvent: ref<ProcessVendettaAchievementEvent>;
    let targetID: StatsObjectID = Cast(hitEvent.target.GetEntityID());
    let godModeSystem: ref<GodModeSystem> = GameInstance.GetGodModeSystem(GetGameInstance());
    let statPoolsSystem: ref<StatPoolsSystem> = GameInstance.GetStatPoolsSystem(hitEvent.target.GetGame());
    let currentPercValue: Float = statPoolsSystem.GetStatPoolValue(targetID, statPoolType);
    let currentPointValue: Float = statPoolsSystem.ToPoints(targetID, statPoolType, currentPercValue);
    if currentPointValue <= 0.00 {
      currentPointValue = 1.00;
    };
    percValueToDrain = (value * currentPercValue) / currentPointValue;
    isTargetImmortal = godModeSystem.HasGodMode(hitEvent.target.GetEntityID(), gameGodModeType.Immortal);
    if percValueToDrain == 0.00 {
      return;
    };
    if currentPercValue > percValueToDrain && (!isTargetImmortal || currentPercValue > percValueToDrain + 1.00) {
      statPoolsSystem.RequestChangingStatPoolValue(targetID, statPoolType, -percValueToDrain, hitEvent.attackData.GetInstigator(), true);
      dmgExpPercent = percValueToDrain;
    } else {
      dmgExpPercent = currentPercValue;
      if isTargetImmortal {
        percValueToDrain = currentPercValue - 1.00;
        statPoolsSystem.RequestChangingStatPoolValue(targetID, statPoolType, -percValueToDrain, hitEvent.attackData.GetInstigator(), true);
        dmgExpPercent = percValueToDrain;
        if IsDefined(hitEvent.target as PlayerPuppet) && Equals(statPoolType, gamedataStatPoolType.Health) && IsDefined(hitEvent.attackData.GetInstigator() as NPCPuppet) {
          processVendettaEvent = new ProcessVendettaAchievementEvent();
          processVendettaEvent.deathInstigator = hitEvent.attackData.GetInstigator();
          hitEvent.target.QueueEvent(processVendettaEvent);
        };
      } else {
        statPoolsSystem.RequestChangingStatPoolValue(targetID, statPoolType, -currentPercValue, hitEvent.attackData.GetInstigator(), true);
      };
    };
    if dmgExpPercent > 0.00 {
      RPGManager.AwardExperienceFromDamage(hitEvent, dmgExpPercent);
    };
  }

  public final static func IsStatPoolValid(type: gamedataStatPoolType) -> Bool {
    let i: Int32 = 0;
    while i < EnumInt(gamedataStatPoolType.Count) {
      if Equals(type, IntEnum(i)) {
        return true;
      };
      i += 1;
    };
    return false;
  }

  public final static func SimulateDamageDeal(hitEvent: ref<gameHitEvent>) -> Bool {
    let curStatPoolValue: Float;
    let target: ref<GameObject> = hitEvent.target;
    let valueToDrain: Float = hitEvent.attackComputed.GetTotalAttackValue(gamedataStatPoolType.Health);
    if valueToDrain > 0.00 {
      curStatPoolValue = GameInstance.GetStatPoolsSystem(target.GetGame()).GetStatPoolValue(Cast(target.GetEntityID()), gamedataStatPoolType.Health, false);
      return valueToDrain >= curStatPoolValue ? true : false;
    };
    return false;
  }
}
