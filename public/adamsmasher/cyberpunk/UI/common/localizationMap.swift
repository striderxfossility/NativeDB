
public class UILocalizationMap extends IScriptable {

  private let m_map: array<UILocRecord>;

  public final func Init() -> Void {
    ArrayClear(this.m_map);
    this.AddRecord(n"E3_DPS_UI", "DPS");
    this.AddRecord(n"E3_Penetration_UI", "PNT");
    this.AddRecord(n"E3_Accuracy_UI", "ACC");
    this.AddRecord(n"E3_RateOfFire_UI", "ROF");
    this.AddRecord(n"E3_Recoil_UI", "Recoil");
    this.AddRecord(n"E3_Spread_UI", "Spread");
    this.AddRecord(n"E3_Range_UI", "Range");
    this.AddRecord(n"PhysicalResistance", "Physical resistance");
    this.AddRecord(n"ThermalResistance", "Thermal resistance");
    this.AddRecord(n"ElectricResistance", "EMP resistance");
    this.AddRecord(n"ChemicalResistance", "Chemical resistance");
    this.AddRecord(n"Range", "Range");
  }

  public final func AddRecord(tag: CName, value: String) -> Void {
    let record: UILocRecord;
    record.m_tag = tag;
    record.m_value = value;
    ArrayPush(this.m_map, record);
  }

  public final func Localize(tag: CName) -> String {
    let count: Int32 = ArraySize(this.m_map);
    let i: Int32 = 0;
    while i < count {
      if Equals(this.m_map[i].m_tag, tag) {
        return this.m_map[i].m_value;
      };
      i += 1;
    };
    return NameToString(tag);
  }
}
