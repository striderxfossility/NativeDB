
public class StatsManager extends IScriptable {

  public let m_playerGodModeModifierData: ref<gameStatModifierData>;

  public final static func GetObjectDPS(obj: ref<GameObject>) -> DPSPackage {
    let dmgVal: Float;
    let newPackage: DPSPackage;
    let objectID: StatsObjectID = Cast(obj.GetEntityID());
    let statsSystem: ref<StatsSystem> = GameInstance.GetStatsSystem(obj.GetGame());
    let i: Int32 = 0;
    while i < EnumInt(gamedataDamageType.Count) {
      dmgVal = statsSystem.GetStatValue(objectID, statsSystem.GetStatType(IntEnum(i)));
      if dmgVal > 0.00 {
        newPackage.value = dmgVal;
        newPackage.type = IntEnum(i);
        return newPackage;
      };
      i += 1;
    };
    LogStats("GetObjectDPS(): NO DPS Found! Returning empty struct! ");
    return newPackage;
  }
}
