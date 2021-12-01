
public abstract final class UILocalizationHelper extends IScriptable {

  public final static func GetStatNameLockey(statRecord: wref<Stat_Record>) -> String {
    let lockey: String;
    let proficiencyRecord: wref<Proficiency_Record>;
    let statType: gamedataStatType = statRecord.StatType();
    if UILocalizationHelper.IsStatProficiency(statType) {
      proficiencyRecord = TweakDBInterface.GetProficiencyRecord(TDBID.Create("Proficiencies." + EnumValueToString("gamedataStatType", Cast(EnumInt(statType)))));
      if IsDefined(proficiencyRecord) {
        lockey = proficiencyRecord.Loc_name_key();
        if IsStringValid(lockey) {
          return lockey;
        };
      };
    };
    return statRecord.LocalizedName();
  }

  private final static func IsStatProficiency(statType: gamedataStatType) -> Bool {
    return Equals(statType, gamedataStatType.Level) || Equals(statType, gamedataStatType.StreetCred) || Equals(statType, gamedataStatType.Gunslinger) || Equals(statType, gamedataStatType.Assault) || Equals(statType, gamedataStatType.Demolition) || Equals(statType, gamedataStatType.Athletics) || Equals(statType, gamedataStatType.Brawling) || Equals(statType, gamedataStatType.ColdBlood) || Equals(statType, gamedataStatType.Stealth) || Equals(statType, gamedataStatType.Engineering) || Equals(statType, gamedataStatType.Crafting) || Equals(statType, gamedataStatType.Hacking) || Equals(statType, gamedataStatType.CombatHacking);
  }

  public final static func GetSystemBaseUnit() -> EMeasurementUnit {
    let measurementSystem: EMeasurementSystem = MeasurementUtils.GetPlayerSettingSystem();
    switch measurementSystem {
      case EMeasurementSystem.Metric:
        return EMeasurementUnit.Meter;
      case EMeasurementSystem.Imperial:
        return EMeasurementUnit.Feet;
    };
    return EMeasurementUnit.Meter;
  }
}
