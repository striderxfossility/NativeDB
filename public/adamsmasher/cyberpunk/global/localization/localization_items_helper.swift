
public class ItemsLocalizationHelper extends IScriptable {

  public final static func GetAbbreviatedItemStatName(type: gamedataStatType) -> String {
    let abbrvName: String;
    let locMgr: ref<UILocalizationMap> = new UILocalizationMap();
    locMgr.AddRecord(n"Accuracy", "ACC");
    locMgr.AddRecord(n"PhysicalDamage", "PDM");
    locMgr.AddRecord(n"PhysicalPotency", "PPO");
    locMgr.AddRecord(n"Range", "RNG");
    locMgr.AddRecord(n"ReloadTime", "REL");
    locMgr.AddRecord(n"RecoilSpeed", "RSP");
    locMgr.AddRecord(n"MagazineCapacity", "MAG");
    locMgr.AddRecord(n"RecoilKickMax", "RKM");
    locMgr.AddRecord(n"AttackSpeed", "SPEED");
    locMgr.AddRecord(n"Charge", "CHR");
    locMgr.AddRecord(n"ChargeDischargeTime", "CDT");
    locMgr.AddRecord(n"ChargeMaxTimeInChargedState", "CMT");
    locMgr.AddRecord(n"ChargeMultiplier", "CMP");
    locMgr.AddRecord(n"ChargeReadyPercentage", "CRP");
    locMgr.AddRecord(n"ChargeTime", "CHT");
    locMgr.AddRecord(n"ChemicalDamage", "CDM");
    locMgr.AddRecord(n"ChemicalPotency", "CPO");
    locMgr.AddRecord(n"Damage", "DMG");
    locMgr.AddRecord(n"Durability", "DUR");
    locMgr.AddRecord(n"ElectricDamage", "EDM");
    locMgr.AddRecord(n"EMPPotency", "EPO");
    locMgr.AddRecord(n"ItemLevel", "LVL");
    locMgr.AddRecord(n"ProjectilesPerShot", "PPS");
    locMgr.AddRecord(n"SmartGunAdsMaxActiveTargets", "ADS");
    locMgr.AddRecord(n"SmartGunHipMaxActiveTargets", "HIP");
    locMgr.AddRecord(n"ZoomLevel", "ZLV");
    abbrvName = locMgr.Localize(EnumValueToName(n"gamedataStatType", EnumInt(type)));
    return abbrvName;
  }
}
