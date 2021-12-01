
public class SampleUITextSystemController extends inkGameController {

  private edit let m_locKeyTextWidget: inkTextRef;

  private edit let m_localizedTextWidget: inkTextRef;

  private let m_textParams: ref<inkTextParams>;

  private edit let m_numberTextWidget: inkTextRef;

  private edit let m_numberIncreaseButton: inkWidgetRef;

  private edit let m_numberDecreaseButton: inkWidgetRef;

  @default(SampleUITextSystemController, 1)
  private let m_numberToInject: Int32;

  private edit let m_stringTextInputWidget: inkTextInputRef;

  @default(SampleUITextSystemController, Dex)
  private let m_stringToInject: String;

  private edit let m_timeRefreshButton: inkWidgetRef;

  private edit const let m_measurementWidgets: array<inkWidgetRef>;

  private edit let m_metricSystemButton: inkWidgetRef;

  private edit let m_imperialSystemButton: inkWidgetRef;

  private edit let m_animateTextOffsetButton: inkWidgetRef;

  private edit let m_textOffsetWidget: inkTextRef;

  private edit let m_animateTextReplaceButton: inkWidgetRef;

  private edit let m_textReplaceWidget: inkTextRef;

  private edit let m_animateValueButton: inkWidgetRef;

  private edit let m_animateValueWidget: inkTextRef;

  protected cb func OnInitialize() -> Bool {
    this.InitControls();
    this.InitTextParams();
  }

  private final func InitControls() -> Void {
    inkTextRef.SetText(this.m_numberTextWidget, IntToString(this.m_numberToInject));
    inkWidgetRef.RegisterToCallback(this.m_numberIncreaseButton, n"OnRelease", this, n"OnIncreaseNumberToInject");
    inkWidgetRef.RegisterToCallback(this.m_numberDecreaseButton, n"OnRelease", this, n"OnDecreaseNumberToInject");
    inkWidgetRef.RegisterToCallback(this.m_stringTextInputWidget, n"OnTextChanged", this, n"OnChangeTextToInject");
    inkWidgetRef.RegisterToCallback(this.m_timeRefreshButton, n"OnRelease", this, n"OnRefreshTime");
    inkWidgetRef.RegisterToCallback(this.m_metricSystemButton, n"OnRelease", this, n"OnSwitchToMetricSystem");
    inkWidgetRef.RegisterToCallback(this.m_imperialSystemButton, n"OnRelease", this, n"OnSwitchToImperialSystem");
    inkWidgetRef.RegisterToCallback(this.m_animateTextOffsetButton, n"OnRelease", this, n"OnAnimateTextOffset");
    inkWidgetRef.RegisterToCallback(this.m_animateTextReplaceButton, n"OnRelease", this, n"OnAnimateTextReplace");
    inkWidgetRef.RegisterToCallback(this.m_animateValueButton, n"OnRelease", this, n"OnAnimateValue");
  }

  private final func InitTextParams() -> Void {
    let fakeLocKey: CName = n"My name is {player_name}, I am Level {player_level,number,integer}, and the time is {curr_date,time,short}";
    inkTextRef.SetLocalizedTextScript(this.m_locKeyTextWidget, fakeLocKey);
    this.m_textParams = new inkTextParams();
    this.m_textParams.AddNumber("player_level", this.m_numberToInject);
    this.m_textParams.AddString("player_name", this.m_stringToInject);
    this.m_textParams.AddCurrentDate("curr_date");
    inkTextRef.SetLocalizedTextScript(this.m_localizedTextWidget, fakeLocKey, this.m_textParams);
  }

  private final func UpdateNumberParam(value: Int32) -> Void {
    this.m_numberToInject = value;
    inkTextRef.SetText(this.m_numberTextWidget, IntToString(this.m_numberToInject));
    if IsDefined(this.m_textParams) {
      this.m_textParams.UpdateNumber("player_level", this.m_numberToInject);
    };
  }

  private final func UpdateStringParam(value: String) -> Void {
    this.m_stringToInject = value;
    if IsDefined(this.m_textParams) {
      this.m_textParams.UpdateString("player_name", this.m_stringToInject);
    };
  }

  private final func UpdateTimeParam() -> Void {
    if IsDefined(this.m_textParams) {
      this.m_textParams.UpdateCurrentDate("curr_date");
    };
  }

  private final func UpdateMeasurementSystem(system: EMeasurementSystem) -> Void {
    let controller: ref<SampleUIMeasurementController>;
    let total: Int32 = ArraySize(this.m_measurementWidgets);
    let i: Int32 = 0;
    while i < total {
      controller = inkWidgetRef.GetController(this.m_measurementWidgets[i]) as SampleUIMeasurementController;
      controller.SetMeasurementSystem(system);
      i += 1;
    };
  }

  protected cb func OnIncreaseNumberToInject(e: ref<inkPointerEvent>) -> Bool {
    if e.IsAction(n"click") {
      this.UpdateNumberParam(this.m_numberToInject + 1);
    };
  }

  protected cb func OnDecreaseNumberToInject(e: ref<inkPointerEvent>) -> Bool {
    if e.IsAction(n"click") {
      this.UpdateNumberParam(this.m_numberToInject - 1);
    };
  }

  protected cb func OnChangeTextToInject(str: String) -> Bool {
    this.UpdateStringParam(str);
  }

  protected cb func OnRefreshTime(e: ref<inkPointerEvent>) -> Bool {
    if e.IsAction(n"click") {
      this.UpdateTimeParam();
    };
  }

  protected cb func OnSwitchToMetricSystem(e: ref<inkPointerEvent>) -> Bool {
    if e.IsAction(n"click") {
      this.UpdateMeasurementSystem(EMeasurementSystem.Metric);
    };
  }

  protected cb func OnSwitchToImperialSystem(e: ref<inkPointerEvent>) -> Bool {
    if e.IsAction(n"click") {
      this.UpdateMeasurementSystem(EMeasurementSystem.Imperial);
    };
  }

  protected cb func OnAnimateTextOffset(e: ref<inkPointerEvent>) -> Bool {
    let controller: ref<inkTextOffsetController>;
    if e.IsAction(n"click") {
      controller = inkWidgetRef.GetController(this.m_textOffsetWidget) as inkTextOffsetController;
      controller.PlaySetAnimation();
    };
  }

  protected cb func OnAnimateTextReplace(e: ref<inkPointerEvent>) -> Bool {
    let controller: ref<inkTextReplaceController>;
    if e.IsAction(n"click") {
      controller = inkWidgetRef.GetController(this.m_textReplaceWidget) as inkTextReplaceController;
      controller.PlaySetAnimation();
    };
  }

  protected cb func OnAnimateValue(e: ref<inkPointerEvent>) -> Bool {
    let controller: ref<inkTextValueProgressController>;
    if e.IsAction(n"click") {
      controller = inkWidgetRef.GetController(this.m_animateValueWidget) as inkTextValueProgressController;
      controller.PlaySetAnimation();
    };
  }
}

public class SampleUIMeasurementController extends inkLogicController {

  private edit let m_value: Float;

  private edit let m_unit: EMeasurementUnit;

  private edit let m_valueText: inkTextRef;

  private edit let m_unitText: inkTextRef;

  private edit let m_valueIncreaseButton: inkWidgetRef;

  private edit let m_valueDecreaseButton: inkWidgetRef;

  protected cb func OnInitialize() -> Bool {
    inkWidgetRef.RegisterToCallback(this.m_valueIncreaseButton, n"OnRelease", this, n"OnIncreaseValue");
    inkWidgetRef.RegisterToCallback(this.m_valueDecreaseButton, n"OnRelease", this, n"OnDecreaseValue");
    this.UpdateTextWidgets();
  }

  public final func SetMeasurementSystem(system: EMeasurementSystem) -> Void {
    this.m_value = MeasurementUtils.ValueToSystem(this.m_value, this.m_unit, system);
    this.m_unit = MeasurementUtils.UnitToSystem(this.m_unit, system);
    this.UpdateTextWidgets();
  }

  private final func UpdateTextWidgets() -> Void {
    inkTextRef.SetText(this.m_valueText, this.FormatValue(this.m_value));
    inkTextRef.SetLocalizedTextScript(this.m_unitText, MeasurementUtils.GetUnitLocalizationKey(this.m_unit));
  }

  private final func FormatValue(value: Float) -> String {
    let valueStr: String = FloatToString(value);
    let endIdx: Int32 = StrFindLast(valueStr, ".") + 3;
    if endIdx < StrLen(valueStr) {
      return StrLeft(valueStr, endIdx);
    };
    return valueStr;
  }

  protected cb func OnIncreaseValue(e: ref<inkPointerEvent>) -> Bool {
    if e.IsAction(n"click") {
      this.m_value += 1.00;
      this.UpdateTextWidgets();
    };
  }

  protected cb func OnDecreaseValue(e: ref<inkPointerEvent>) -> Bool {
    if e.IsAction(n"click") {
      this.m_value -= 1.00;
      this.UpdateTextWidgets();
    };
  }
}
