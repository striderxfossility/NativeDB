
public class ItemTooltipStatController extends inkLogicController {

  protected edit let m_statName: inkTextRef;

  protected edit let m_statValue: inkTextRef;

  protected edit let m_statComparedContainer: inkWidgetRef;

  protected edit let m_statComparedValue: inkTextRef;

  protected edit let m_arrow: inkImageRef;

  private let m_measurementUnit: EMeasurementUnit;

  public final func SetData(data: InventoryTooltipData_StatData) -> Void {
    let damageMax: Float;
    let damageMin: Float;
    let decimalPart: Float;
    let statFinalValue: String;
    let statText: String;
    let statsTweakID: TweakDBID = TDBID.Create("BaseStats." + EnumValueToString("gamedataStatType", Cast(EnumInt(data.statType))));
    let isPercentage: Bool = TweakDBInterface.GetBool(statsTweakID + t".isPercentage", false);
    let roundValue: Bool = TweakDBInterface.GetBool(statsTweakID + t".roundValue", false);
    let displayPlus: Bool = TweakDBInterface.GetBool(statsTweakID + t".displayPlus", false);
    let inMeters: Bool = TweakDBInterface.GetBool(statsTweakID + t".inMeters", false);
    let inSeconds: Bool = TweakDBInterface.GetBool(statsTweakID + t".inSeconds", false);
    let currentValue: Float = data.currentValueF;
    this.m_measurementUnit = UILocalizationHelper.GetSystemBaseUnit();
    if RPGManager.IsPercentageStat(data.statType) {
      currentValue = currentValue * 100.00;
    };
    decimalPart = data.currentValueF - Cast(FloorF(currentValue));
    if AbsF(currentValue) > 0.01 {
      if AbsF(decimalPart) > 0.01 && !roundValue {
        statText += FloatToStringPrec(currentValue, 2);
      } else {
        statText += IntToString(RoundF(currentValue));
      };
    };
    if RPGManager.IsDamageStat(data.statType) {
      damageMin = currentValue * 0.90;
      damageMax = currentValue * 1.10;
      statText = FloatToStringPrec(damageMin, 0) + "-" + FloatToStringPrec(damageMax, 0);
    };
    inkTextRef.SetText(this.m_statName, data.statName);
    if displayPlus {
      statFinalValue += "+";
    };
    statFinalValue += statText;
    if isPercentage {
      statFinalValue += "%";
    };
    if inMeters {
      currentValue = MeasurementUtils.ValueUnitToUnit(currentValue, EMeasurementUnit.Meter, this.m_measurementUnit);
      statFinalValue += GetLocalizedText(NameToString(MeasurementUtils.GetUnitLocalizationKey(this.m_measurementUnit)));
    };
    if inSeconds {
      statFinalValue += GetLocalizedText("UI-Quickhacks-Seconds");
    };
    if Equals(data.statType, gamedataStatType.MaxDuration) {
      statFinalValue += " " + GetLocalizedText("UI-Quickhacks-Seconds");
    };
    inkTextRef.SetText(this.m_statValue, statFinalValue);
    this.UpdateComparedValue(data.diffValue, isPercentage, displayPlus, inMeters, inSeconds);
  }

  public final func SetData(data: ref<MinimalItemTooltipStatData>) -> Void {
    let damageMax: Float;
    let damageMin: Float;
    let decimalPart: Float;
    let statFinalValue: String;
    let statText: String;
    let currentValue: Float = data.value;
    this.m_measurementUnit = UILocalizationHelper.GetSystemBaseUnit();
    if RPGManager.IsPercentageStat(data.type) {
      currentValue = currentValue * 100.00;
    };
    decimalPart = data.value - Cast(FloorF(data.value));
    if AbsF(currentValue) >= 0.01 {
      if AbsF(decimalPart) >= 0.01 && !data.roundValue {
        statText += FloatToStringPrec(currentValue, 2);
      } else {
        statText += IntToString(RoundF(currentValue));
      };
    };
    if RPGManager.IsDamageStat(data.type) {
      damageMin = currentValue * 0.90;
      damageMax = currentValue * 1.10;
      statText = FloatToStringPrec(damageMin, 0) + "-" + FloatToStringPrec(damageMax, 0);
    };
    inkTextRef.SetText(this.m_statName, data.statName);
    if data.displayPlus {
      statFinalValue += "+";
    };
    statFinalValue += statText;
    if data.isPercentage {
      statFinalValue += "%";
    };
    if data.inMeters {
      currentValue = MeasurementUtils.ValueUnitToUnit(currentValue, EMeasurementUnit.Meter, this.m_measurementUnit);
      statFinalValue += GetLocalizedText(NameToString(MeasurementUtils.GetUnitLocalizationKey(this.m_measurementUnit)));
    };
    if data.inSeconds {
      statFinalValue += GetLocalizedText("UI-Quickhacks-Seconds");
    };
    if Equals(data.type, gamedataStatType.MaxDuration) {
      statFinalValue += GetLocalizedText("UI-Quickhacks-Seconds");
    };
    inkTextRef.SetText(this.m_statValue, statFinalValue);
    this.UpdateComparedValue(Cast(data.diff), data.isPercentage, data.displayPlus, data.inMeters, data.inSeconds);
  }

  private final func UpdateComparedValue(diff: Int32, isPercentage: Bool, displayPlus: Bool, inMeters: Bool, inSeconds: Bool) -> Void {
    let comaredStatText: String;
    this.m_measurementUnit = UILocalizationHelper.GetSystemBaseUnit();
    let isVisible: Bool = diff != 0;
    let statToSet: CName = diff > 0 ? n"Better" : n"Worse";
    if displayPlus {
      comaredStatText += diff > 0 ? "+" : "-";
    };
    comaredStatText += IntToString(Abs(diff));
    if isPercentage {
      comaredStatText += "%";
    };
    if inMeters {
      diff = FloorF(MeasurementUtils.ValueUnitToUnit(Cast(diff), EMeasurementUnit.Meter, this.m_measurementUnit));
      comaredStatText += GetLocalizedText(NameToString(MeasurementUtils.GetUnitLocalizationKey(this.m_measurementUnit)));
    };
    if inSeconds {
      comaredStatText += GetLocalizedText("UI-Quickhacks-Seconds");
    };
    inkTextRef.SetText(this.m_statComparedValue, comaredStatText);
    inkWidgetRef.SetVisible(this.m_arrow, isVisible);
    inkWidgetRef.SetVisible(this.m_statComparedValue, isVisible);
    inkWidgetRef.SetState(this.m_arrow, statToSet);
    inkWidgetRef.SetState(this.m_statComparedValue, statToSet);
    inkImageRef.SetBrushMirrorType(this.m_arrow, diff > 0 ? inkBrushMirrorType.NoMirror : inkBrushMirrorType.Vertical);
  }
}
