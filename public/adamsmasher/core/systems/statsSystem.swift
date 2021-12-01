
public native class ScriptStatsListener extends IStatsListener {

  public func OnStatChanged(ownerID: StatsObjectID, statType: gamedataStatType, diff: Float, total: Float) -> Void;

  public func OnGodModeChanged(ownerID: EntityID, newType: gameGodModeType) -> Void;

  public final native func SetStatType(statType: gamedataStatType) -> Void;
}

public class StatsSystemHelper extends IScriptable {

  public final static func GetDetailedStatInfo(obj: ref<GameObject>, statType: gamedataStatType, out statData: gameStatDetailedData) -> Bool {
    let detailsArray: array<gameStatDetailedData> = GameInstance.GetStatsSystem(obj.GetGame()).GetStatDetails(Cast(obj.GetEntityID()));
    let i: Int32 = 0;
    while i < ArraySize(detailsArray) {
      if Equals(detailsArray[i].statType, statType) {
        statData = detailsArray[i];
        return true;
      };
      i += 1;
    };
    return false;
  }
}

public static func GetDamageValue(object: ref<GameObject>, damageType: gamedataDamageType) -> Float {
  let attacksPerSec: Float;
  let baseDamage: Float;
  let statsSystem: ref<StatsSystem> = GameInstance.GetStatsSystem(object.GetGame());
  let damageRecord: ref<DamageType_Record> = statsSystem.GetDamageRecordFromType(damageType);
  let statType: gamedataStatType = GetStatTypeFromDamageTypeRecord(damageRecord);
  let objectID: StatsObjectID = Cast(object.GetEntityID());
  let DPS: Float = statsSystem.GetStatValue(objectID, statType);
  let reloadTime: Float = statsSystem.GetStatValue(objectID, gamedataStatType.ReloadTime);
  let magazineCapacity: Float = statsSystem.GetStatValue(objectID, gamedataStatType.MagazineCapacity);
  let numShotsPerCycle: Float = statsSystem.GetStatValue(objectID, gamedataStatType.NumShotsToFire);
  let cycleTime: Float = statsSystem.GetStatValue(objectID, gamedataStatType.CycleTime);
  let projectilesPerShot: Float = statsSystem.GetStatValue(objectID, gamedataStatType.ProjectilesPerShot);
  let numAttacksPerMagazine: Float = projectilesPerShot * numShotsPerCycle * magazineCapacity;
  if numAttacksPerMagazine <= 0.00 {
    return DPS;
  };
  attacksPerSec = (projectilesPerShot * numShotsPerCycle * magazineCapacity) / (cycleTime * magazineCapacity + reloadTime);
  baseDamage = DPS / attacksPerSec;
  return baseDamage;
}

public static func GetStatTypeFromDamageTypeRecord(damageRecord: ref<DamageType_Record>) -> gamedataStatType {
  let associatedStat: ref<Stat_Record>;
  let statType: gamedataStatType = gamedataStatType.Invalid;
  if IsDefined(damageRecord) {
    associatedStat = damageRecord.AssociatedStat();
    if IsDefined(associatedStat) {
      statType = IntEnum(Cast(EnumValueFromString("gamedataStatType", associatedStat.EnumName())));
    };
  };
  return statType;
}
