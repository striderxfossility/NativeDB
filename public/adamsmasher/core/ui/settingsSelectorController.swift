
public native class SettingsSelectorController extends inkLogicController {

  protected edit let m_LabelText: inkTextRef;

  protected edit let m_ModifiedFlag: inkTextRef;

  protected edit let m_Raycaster: inkWidgetRef;

  protected edit let m_optionSwitchHint: inkWidgetRef;

  protected edit let m_hoverGeneralHighlight: inkWidgetRef;

  protected edit let m_container: inkWidgetRef;

  protected let m_SettingsEntry: wref<ConfigVar>;

  protected let m_hoveredChildren: array<wref<inkWidget>>;

  protected let m_IsPreGame: Bool;

  private let m_varGroupPath: CName;

  private let m_varName: CName;

  protected let m_additionalText: CName;

  private let m_hoverInAnim: ref<inkAnimProxy>;

  private let m_hoverOutAnim: ref<inkAnimProxy>;

  public final native func BindSettings(entry: ref<ConfigVar>) -> Void;

  public final native func GetDisplayName() -> CName;

  public final native func GetDescription() -> CName;

  public final func GetVar() -> wref<ConfigVar> {
    return this.m_SettingsEntry;
  }

  public final func GetGroupPath() -> CName {
    return this.m_varGroupPath;
  }

  public final func GetVarName() -> CName {
    return this.m_varName;
  }

  public final func GetVarUpdatePolicy() -> ConfigVarUpdatePolicy {
    return this.m_SettingsEntry.GetUpdatePolicy();
  }

  public final func IsDynamic() -> Bool {
    return this.m_SettingsEntry.IsDynamic();
  }

  public final func SetAdditionalText(text: CName) -> Void {
    this.m_additionalText = text;
  }

  public final func ResetAdditionalText() -> Void {
    this.m_additionalText = n"";
  }

  public func Setup(entry: ref<ConfigVar>, isPreGame: Bool) -> Void {
    this.m_SettingsEntry = entry;
    this.m_IsPreGame = isPreGame;
    this.m_varGroupPath = this.m_SettingsEntry.GetGroupPath();
    this.m_varName = this.m_SettingsEntry.GetName();
    this.BindSettings(entry);
  }

  protected cb func OnInitialize() -> Bool {
    if inkWidgetRef.IsValid(this.m_Raycaster) {
      inkWidgetRef.SetVisible(this.m_optionSwitchHint, false);
      inkWidgetRef.SetVisible(this.m_hoverGeneralHighlight, false);
      inkWidgetRef.SetState(this.m_LabelText, n"Default");
      this.RegisterToCallback(n"OnHoverOver", this, n"OnHoverOver");
      this.RegisterToCallback(n"OnHoverOut", this, n"OnHoverOut");
    };
  }

  protected cb func OnHoverOver(e: ref<inkPointerEvent>) -> Bool {
    if this.m_SettingsEntry.IsDisabled() {
      return false;
    };
    if ArraySize(this.m_hoveredChildren) <= 0 {
      if this.m_hoverInAnim.IsPlaying() {
        this.m_hoverInAnim.Stop();
      };
      if this.m_hoverOutAnim.IsPlaying() {
        this.m_hoverOutAnim.Stop();
      };
      this.m_hoverInAnim = this.PlayLibraryAnimation(n"hover_over_anim");
      inkWidgetRef.SetState(this.m_LabelText, n"Hover");
      inkWidgetRef.SetVisible(this.m_optionSwitchHint, true);
      inkWidgetRef.SetVisible(this.m_hoverGeneralHighlight, true);
    };
    ArrayPush(this.m_hoveredChildren, e.GetCurrentTarget());
  }

  protected cb func OnHoverOut(e: ref<inkPointerEvent>) -> Bool {
    if this.m_SettingsEntry.IsDisabled() {
      return false;
    };
    ArrayRemove(this.m_hoveredChildren, e.GetCurrentTarget());
    if ArraySize(this.m_hoveredChildren) <= 0 {
      if this.m_hoverInAnim.IsPlaying() {
        this.m_hoverInAnim.Stop();
      };
      if this.m_hoverOutAnim.IsPlaying() {
        this.m_hoverOutAnim.Stop();
      };
      this.m_hoverOutAnim = this.PlayLibraryAnimation(n"hover_out_anim");
      inkWidgetRef.SetState(this.m_LabelText, n"Default");
      inkWidgetRef.SetVisible(this.m_optionSwitchHint, false);
      inkWidgetRef.SetVisible(this.m_hoverGeneralHighlight, false);
    };
  }

  protected cb func OnElementHovered(e: ref<inkPointerEvent>) -> Bool {
    this.CallCustomCallback(n"OnSettingHovered");
  }

  protected cb func OnUpdateValue() -> Bool {
    this.Refresh();
  }

  public func Refresh() -> Void {
    let i: Int32;
    let languageProvider: ref<inkLanguageOverrideProvider>;
    let modifiedSymbol: String;
    let text: String;
    let updatePolicy: ConfigVarUpdatePolicy;
    let wasModified: Bool;
    let size: Int32 = this.m_SettingsEntry.GetDisplayNameKeysSize();
    if size > 0 {
      text = NameToString(this.m_SettingsEntry.GetDisplayName());
      i = 0;
      while i < size {
        text = StrReplace(text, "%", GetLocalizedTextByKey(this.m_SettingsEntry.GetDisplayNameKey(i)));
        i += 1;
      };
    } else {
      text = GetLocalizedTextByKey(this.m_SettingsEntry.GetDisplayName());
    };
    updatePolicy = this.m_SettingsEntry.GetUpdatePolicy();
    if Equals(text, "") {
      text = "<NOT LOCALIZED>" + NameToString(this.m_SettingsEntry.GetDisplayName());
    };
    if Equals(updatePolicy, ConfigVarUpdatePolicy.ConfirmationRequired) {
      modifiedSymbol = "*";
      wasModified = this.m_SettingsEntry.HasRequestedValue();
    } else {
      if Equals(updatePolicy, ConfigVarUpdatePolicy.RestartRequired) || Equals(updatePolicy, ConfigVarUpdatePolicy.LoadLastCheckpointRequired) {
        modifiedSymbol = "!";
        wasModified = this.m_SettingsEntry.HasRequestedValue() || this.m_SettingsEntry.WasModifiedSinceLastSave();
      } else {
        modifiedSymbol = "";
        wasModified = false;
      };
    };
    languageProvider = inkWidgetRef.GetUserData(this.m_LabelText, n"inkLanguageOverrideProvider") as inkLanguageOverrideProvider;
    languageProvider.SetLanguage(scnDialogLineLanguage.Origin);
    inkTextRef.UpdateLanguageResources(this.m_LabelText, false);
    inkTextRef.SetText(this.m_LabelText, text);
    inkWidgetRef.SetVisible(this.m_ModifiedFlag, wasModified);
    inkTextRef.SetText(this.m_ModifiedFlag, modifiedSymbol);
  }

  protected cb func OnLeft(e: ref<inkPointerEvent>) -> Bool {
    if !this.m_SettingsEntry.IsDisabled() && e.IsAction(n"click") {
      this.AcceptValue(false);
      this.PlaySound(n"ButtonValueDown", n"OnPress");
    };
  }

  protected cb func OnRight(e: ref<inkPointerEvent>) -> Bool {
    if !this.m_SettingsEntry.IsDisabled() && e.IsAction(n"click") {
      this.AcceptValue(true);
      this.PlaySound(n"ButtonValueUp", n"OnPress");
    };
  }

  protected cb func OnShortcutRepeat(e: ref<inkPointerEvent>) -> Bool {
    if !this.m_SettingsEntry.IsDisabled() && !e.IsHandled() {
      if e.IsAction(n"option_switch_prev_settings") {
        this.ChangeValue(false);
        e.Handle();
      } else {
        if e.IsAction(n"option_switch_next_settings") {
          this.ChangeValue(true);
          e.Handle();
        };
      };
    };
  }

  protected cb func OnShortcutPress(e: ref<inkPointerEvent>) -> Bool {
    if !this.m_SettingsEntry.IsDisabled() && !e.IsHandled() {
      if e.IsAction(n"option_switch_prev_settings") {
        this.PlaySound(n"ButtonValueDown", n"OnPress");
        this.AcceptValue(false);
        e.Handle();
      } else {
        if e.IsAction(n"option_switch_next_settings") {
          this.PlaySound(n"ButtonValueUp", n"OnPress");
          this.AcceptValue(true);
          e.Handle();
        };
      };
    };
  }

  private func AcceptValue(forward: Bool) -> Void {
    this.ChangeValue(forward);
  }

  private func ChangeValue(forward: Bool) -> Void;
}

public class SettingsSelectorControllerBool extends SettingsSelectorController {

  protected edit let m_onState: inkWidgetRef;

  protected edit let m_offState: inkWidgetRef;

  protected edit let m_onStateBody: inkWidgetRef;

  protected edit let m_offStateBody: inkWidgetRef;

  public func Setup(entry: ref<ConfigVar>, isPreGame: Bool) -> Void {
    this.Setup(entry, isPreGame);
  }

  public func Refresh() -> Void {
    let buttonLogic: ref<inkButtonController>;
    let value: Bool;
    let realValue: ref<ConfigVarBool> = this.m_SettingsEntry as ConfigVarBool;
    this.Refresh();
    value = realValue.GetValue();
    inkWidgetRef.SetVisible(this.m_onState, value);
    inkWidgetRef.SetVisible(this.m_offState, !value);
    buttonLogic = inkWidgetRef.GetControllerByType(this.m_onState, n"inkButtonController") as inkButtonController;
    if IsDefined(buttonLogic) {
      buttonLogic.SetEnabled(!this.m_SettingsEntry.IsDisabled());
    };
    buttonLogic = inkWidgetRef.GetControllerByType(this.m_offState, n"inkButtonController") as inkButtonController;
    if IsDefined(buttonLogic) {
      buttonLogic.SetEnabled(!this.m_SettingsEntry.IsDisabled());
    };
  }

  protected cb func OnInitialize() -> Bool {
    super.OnInitialize();
    if inkWidgetRef.IsValid(this.m_offStateBody) {
      inkWidgetRef.RegisterToCallback(this.m_offStateBody, n"OnRelease", this, n"OnLeft");
    };
    if inkWidgetRef.IsValid(this.m_onStateBody) {
      inkWidgetRef.RegisterToCallback(this.m_onStateBody, n"OnRelease", this, n"OnRight");
    };
    if inkWidgetRef.IsValid(this.m_Raycaster) {
      this.RegisterToCallback(n"OnRelease", this, n"OnShortcutPress");
    };
  }

  private func AcceptValue(forward: Bool) -> Void {
    let boolValue: ref<ConfigVarBool> = this.m_SettingsEntry as ConfigVarBool;
    boolValue.Toggle();
  }
}

public native class SettingsSelectorControllerKeyBinding extends SettingsSelectorController {

  private edit let m_text: inkRichTextBoxRef;

  private edit let m_buttonRef: inkWidgetRef;

  private edit let m_editView: inkWidgetRef;

  @default(SettingsSelectorControllerKeyBinding, 0.4f)
  private edit let m_editOpacity: Float;

  public final native func IsListeningForInput() -> Bool;

  public final native func ListenForInput() -> Void;

  public final native func StopListeningForInput() -> Void;

  public final native func TriggerActionFeedback() -> Void;

  public final static native func PrepareInputTag(keyName: CName, groupName: CName, actionName: CName) -> String;

  protected cb func OnInitialize() -> Bool {
    super.OnInitialize();
    if inkWidgetRef.IsValid(this.m_buttonRef) {
      inkWidgetRef.RegisterToCallback(this.m_buttonRef, n"OnRelease", this, n"OnRelease");
    };
  }

  protected cb func OnUninitialize() -> Bool {
    if inkWidgetRef.IsValid(this.m_buttonRef) {
      inkWidgetRef.UnregisterFromCallback(this.m_buttonRef, n"OnRelease", this, n"OnRelease");
    };
  }

  private final func IsCancel(keyName: CName) -> Bool {
    return Equals(keyName, n"IK_Escape");
  }

  protected cb func OnKeyBindingEvent(e: ref<KeyBindingEvent>) -> Bool {
    if this.IsListeningForInput() {
      if !this.IsCancel(e.keyName) {
        this.SetValue(e.keyName);
      } else {
        this.Refresh();
      };
      this.StopListeningForInput();
      inkWidgetRef.SetOpacity(this.m_editView, 0.00);
    };
  }

  public func Refresh() -> Void {
    let varName: ref<ConfigVarName>;
    this.Refresh();
    varName = this.m_SettingsEntry as ConfigVarName;
    inkTextRef.SetText(this.m_text, SettingsSelectorControllerKeyBinding.PrepareInputTag(varName.GetValue(), varName.GetGroup().GetName(), varName.GetName()));
    this.TriggerActionFeedback();
  }

  protected cb func OnRelease(e: ref<inkPointerEvent>) -> Bool {
    if e.IsAction(n"click") {
      inkTextRef.SetLocalizedText(this.m_text, n"UI-Settings-ButtonMappings-Misc-KeyBind");
      inkWidgetRef.SetOpacity(this.m_editView, this.m_editOpacity);
      this.ListenForInput();
    } else {
      if e.IsAction(n"unequip_item") {
        this.ResetValue();
      };
    };
  }

  private final func SetValue(key: CName) -> Void {
    let value: ref<ConfigVarName> = this.m_SettingsEntry as ConfigVarName;
    value.SetValue(key);
  }

  private final func ResetValue() -> Void {
    this.GetVar().RestoreDefault();
  }
}

public class SettingsSelectorControllerRange extends SettingsSelectorController {

  protected edit let m_ValueText: inkTextRef;

  protected edit let m_LeftArrow: inkWidgetRef;

  protected edit let m_RightArrow: inkWidgetRef;

  protected edit let m_ProgressBar: inkWidgetRef;

  protected cb func OnInitialize() -> Bool {
    super.OnInitialize();
    if inkWidgetRef.IsValid(this.m_LeftArrow) {
      inkWidgetRef.RegisterToCallback(this.m_LeftArrow, n"OnRelease", this, n"OnLeft");
    };
    if inkWidgetRef.IsValid(this.m_RightArrow) {
      inkWidgetRef.RegisterToCallback(this.m_RightArrow, n"OnRelease", this, n"OnRight");
    };
    if inkWidgetRef.IsValid(this.m_Raycaster) {
      this.RegisterShortcutCallbacks();
    };
  }

  public func Refresh() -> Void {
    let buttonLogic: ref<inkButtonController>;
    this.Refresh();
    if inkWidgetRef.IsValid(this.m_RightArrow) {
      inkWidgetRef.SetVisible(this.m_RightArrow, !this.m_SettingsEntry.IsDisabled());
    };
    if inkWidgetRef.IsValid(this.m_LeftArrow) {
      inkWidgetRef.SetVisible(this.m_LeftArrow, !this.m_SettingsEntry.IsDisabled());
    };
    if inkWidgetRef.IsValid(this.m_container) {
      buttonLogic = inkWidgetRef.GetControllerByType(this.m_container, n"inkButtonController") as inkButtonController;
      if IsDefined(buttonLogic) {
        buttonLogic.SetEnabled(!this.m_SettingsEntry.IsDisabled());
      };
    };
  }

  protected func RegisterShortcutCallbacks() -> Void {
    this.RegisterToCallback(n"OnRelease", this, n"OnShortcutPress");
  }

  protected final func UpdateValueTextLanguageResources() -> Void {
    let languageProvider: ref<inkLanguageOverrideProvider> = inkWidgetRef.GetUserData(this.m_ValueText, n"inkLanguageOverrideProvider") as inkLanguageOverrideProvider;
    languageProvider.SetLanguage(scnDialogLineLanguage.Origin);
    inkTextRef.UpdateLanguageResources(this.m_ValueText, false);
  }
}

public class SettingsSelectorControllerInt extends SettingsSelectorControllerRange {

  private let m_newValue: Int32;

  private edit let m_sliderWidget: inkWidgetRef;

  private let m_sliderController: wref<inkSliderController>;

  public func Setup(entry: ref<ConfigVar>, isPreGame: Bool) -> Void {
    let value: ref<ConfigVarInt>;
    this.Setup(entry, isPreGame);
    value = this.m_SettingsEntry as ConfigVarInt;
    this.m_sliderController = inkWidgetRef.GetControllerByType(this.m_sliderWidget, n"inkSliderController") as inkSliderController;
    this.m_sliderController.Setup(Cast(value.GetMinValue()), Cast(value.GetMaxValue()), Cast(this.m_newValue), Cast(value.GetStepValue()));
    this.m_sliderController.RegisterToCallback(n"OnSliderValueChanged", this, n"OnSliderValueChanged");
    this.m_sliderController.RegisterToCallback(n"OnSliderHandleReleased", this, n"OnHandleReleased");
  }

  protected cb func OnSliderValueChanged(sliderController: wref<inkSliderController>, progress: Float, value: Float) -> Bool {
    this.m_newValue = Cast(value);
    this.Refresh();
  }

  protected cb func OnHandleReleased() -> Bool {
    let value: ref<ConfigVarInt> = this.m_SettingsEntry as ConfigVarInt;
    value.SetValue(this.m_newValue);
  }

  private func RegisterShortcutCallbacks() -> Void {
    this.RegisterShortcutCallbacks();
    this.RegisterToCallback(n"OnRepeat", this, n"OnShortcutRepeat");
  }

  private func ChangeValue(forward: Bool) -> Void {
    let value: ref<ConfigVarInt> = this.m_SettingsEntry as ConfigVarInt;
    let step: Int32 = forward ? value.GetStepValue() : -value.GetStepValue();
    this.m_newValue = Clamp(this.m_newValue + step, value.GetMinValue(), value.GetMaxValue());
    this.Refresh();
  }

  private func AcceptValue(forward: Bool) -> Void {
    let value: ref<ConfigVarInt> = this.m_SettingsEntry as ConfigVarInt;
    if value.GetValue() == this.m_newValue {
      this.ChangeValue(forward);
    };
    value.SetValue(this.m_newValue);
  }

  public func Refresh() -> Void {
    this.Refresh();
    this.UpdateValueTextLanguageResources();
    inkTextRef.SetText(this.m_ValueText, IntToString(this.m_newValue));
    this.m_sliderController.ChangeValue(Cast(this.m_newValue));
  }

  protected cb func OnUpdateValue() -> Bool {
    let value: ref<ConfigVarInt> = this.m_SettingsEntry as ConfigVarInt;
    this.m_newValue = value.GetValue();
    super.OnUpdateValue();
  }
}

public class SettingsSelectorControllerFloat extends SettingsSelectorControllerRange {

  public let m_newValue: Float;

  private edit let m_sliderWidget: inkWidgetRef;

  private let m_sliderController: wref<inkSliderController>;

  public func Setup(entry: ref<ConfigVar>, isPreGame: Bool) -> Void {
    let value: ref<ConfigVarFloat>;
    this.Setup(entry, isPreGame);
    value = this.m_SettingsEntry as ConfigVarFloat;
    this.m_sliderController = inkWidgetRef.GetControllerByType(this.m_sliderWidget, n"inkSliderController") as inkSliderController;
    this.m_sliderController.Setup(value.GetMinValue(), value.GetMaxValue(), this.m_newValue, value.GetStepValue());
    this.m_sliderController.RegisterToCallback(n"OnSliderValueChanged", this, n"OnSliderValueChanged");
    this.m_sliderController.RegisterToCallback(n"OnSliderHandleReleased", this, n"OnHandleReleased");
  }

  protected cb func OnSliderValueChanged(sliderController: wref<inkSliderController>, progress: Float, value: Float) -> Bool {
    this.m_newValue = value;
    this.Refresh();
  }

  protected cb func OnHandleReleased() -> Bool {
    let value: ref<ConfigVarFloat> = this.m_SettingsEntry as ConfigVarFloat;
    value.SetValue(this.m_newValue);
  }

  private func RegisterShortcutCallbacks() -> Void {
    this.RegisterShortcutCallbacks();
    this.RegisterToCallback(n"OnRepeat", this, n"OnShortcutRepeat");
  }

  private func ChangeValue(forward: Bool) -> Void {
    let value: ref<ConfigVarFloat> = this.m_SettingsEntry as ConfigVarFloat;
    let step: Float = forward ? value.GetStepValue() : -value.GetStepValue();
    this.m_newValue = ClampF(this.m_newValue + step, value.GetMinValue(), value.GetMaxValue());
    this.Refresh();
  }

  private func AcceptValue(forward: Bool) -> Void {
    let value: ref<ConfigVarFloat> = this.m_SettingsEntry as ConfigVarFloat;
    if value.GetValue() == this.m_newValue {
      this.ChangeValue(forward);
    };
    value.SetValue(this.m_newValue);
  }

  public func Refresh() -> Void {
    this.Refresh();
    this.UpdateValueTextLanguageResources();
    inkTextRef.SetText(this.m_ValueText, FloatToStringPrec(this.m_newValue, 2));
    this.m_sliderController.ChangeValue(this.m_newValue);
  }

  protected cb func OnUpdateValue() -> Bool {
    let value: ref<ConfigVarFloat> = this.m_SettingsEntry as ConfigVarFloat;
    this.m_newValue = value.GetValue();
    super.OnUpdateValue();
  }
}

public class SettingsSelectorControllerList extends SettingsSelectorControllerRange {

  protected edit let m_dotsContainer: inkHorizontalPanelRef;

  protected final func PopulateDots(size: Int32) -> Void {
    let dot: wref<inkWidget>;
    let dotWidth: Float;
    let i: Int32;
    let parentSize: Vector2;
    let parentWidth: Float;
    inkCompoundRef.RemoveAllChildren(this.m_dotsContainer);
    parentSize = inkWidgetRef.GetSize(this.m_dotsContainer);
    parentWidth = parentSize.X;
    dotWidth = parentWidth / Cast(size) - 8.00;
    dotWidth = ClampF(dotWidth, 8.00, 40.00);
    i = 0;
    while i < size {
      dot = this.SpawnFromLocal(inkWidgetRef.Get(this.m_dotsContainer), n"settingsDot");
      dot.SetSize(dotWidth, 4.00);
      i += 1;
    };
  }

  protected final func SelectDot(index: Int32) -> Void {
    let dot: wref<inkWidget>;
    let size: Int32 = inkCompoundRef.GetNumChildren(this.m_dotsContainer);
    let i: Int32 = 0;
    while i < size {
      dot = inkCompoundRef.GetWidgetByIndex(this.m_dotsContainer, i);
      if i == index {
        dot.SetState(n"Toggled");
      } else {
        dot.SetState(n"Default");
      };
      i += 1;
    };
  }
}

public class SettingsSelectorControllerListInt extends SettingsSelectorControllerList {

  public func Setup(entry: ref<ConfigVar>, isPreGame: Bool) -> Void {
    let data: array<Int32>;
    let value: ref<ConfigVarListInt>;
    this.Setup(entry, isPreGame);
    value = this.m_SettingsEntry as ConfigVarListInt;
    data = value.GetValues();
    this.PopulateDots(ArraySize(data));
    this.SelectDot(value.GetIndex());
  }

  private func ChangeValue(forward: Bool) -> Void {
    let value: ref<ConfigVarListInt> = this.m_SettingsEntry as ConfigVarListInt;
    let listElements: array<Int32> = value.GetValues();
    let index: Int32 = value.GetIndex();
    let newIndex: Int32 = index + forward ? 1 : -1;
    if newIndex < 0 {
      newIndex = ArraySize(listElements) - 1;
    } else {
      if newIndex >= ArraySize(listElements) {
        newIndex = 0;
      };
    };
    if index != newIndex {
      value.SetIndex(newIndex);
    };
  }

  public func Refresh() -> Void {
    let index: Int32;
    let value: ref<ConfigVarListInt>;
    this.Refresh();
    value = this.m_SettingsEntry as ConfigVarListInt;
    index = value.GetIndex();
    this.UpdateValueTextLanguageResources();
    if !value.ListHasDisplayValues() {
      inkTextRef.SetText(this.m_ValueText, IntToString(value.GetValue()));
    } else {
      inkTextRef.SetText(this.m_ValueText, GetLocalizedTextByKey(value.GetDisplayValue(index)));
    };
    this.SelectDot(index);
  }
}

public class SettingsSelectorControllerListFloat extends SettingsSelectorControllerList {

  public func Setup(entry: ref<ConfigVar>, isPreGame: Bool) -> Void {
    let data: array<Float>;
    let value: ref<ConfigVarListFloat>;
    this.Setup(entry, isPreGame);
    value = this.m_SettingsEntry as ConfigVarListFloat;
    data = value.GetValues();
    this.PopulateDots(ArraySize(data));
    this.SelectDot(value.GetIndex());
  }

  private func ChangeValue(forward: Bool) -> Void {
    let value: ref<ConfigVarListFloat> = this.m_SettingsEntry as ConfigVarListFloat;
    let listElements: array<Float> = value.GetValues();
    let index: Int32 = value.GetIndex();
    let newIndex: Int32 = index + forward ? 1 : -1;
    if newIndex < 0 {
      newIndex = ArraySize(listElements) - 1;
    } else {
      if newIndex >= ArraySize(listElements) {
        newIndex = 0;
      };
    };
    if index != newIndex {
      value.SetIndex(newIndex);
    };
  }

  public func Refresh() -> Void {
    let index: Int32;
    let value: ref<ConfigVarListFloat>;
    this.Refresh();
    value = this.m_SettingsEntry as ConfigVarListFloat;
    index = value.GetIndex();
    this.UpdateValueTextLanguageResources();
    if !value.ListHasDisplayValues() {
      inkTextRef.SetText(this.m_ValueText, FloatToStringPrec(value.GetValue(), 2));
    } else {
      inkTextRef.SetText(this.m_ValueText, GetLocalizedTextByKey(value.GetDisplayValue(index)));
    };
    this.SelectDot(index);
  }
}

public class SettingsSelectorControllerListString extends SettingsSelectorControllerList {

  public func Setup(entry: ref<ConfigVar>, isPreGame: Bool) -> Void {
    let data: array<String>;
    let value: ref<ConfigVarListString>;
    this.Setup(entry, isPreGame);
    value = this.m_SettingsEntry as ConfigVarListString;
    data = value.GetValues();
    this.PopulateDots(ArraySize(data));
    this.SelectDot(value.GetIndex());
  }

  private func ChangeValue(forward: Bool) -> Void {
    let value: ref<ConfigVarListString> = this.m_SettingsEntry as ConfigVarListString;
    let listElements: array<String> = value.GetValues();
    let index: Int32 = value.GetIndex();
    let newIndex: Int32 = index + forward ? 1 : -1;
    if newIndex < 0 {
      newIndex = ArraySize(listElements) - 1;
    } else {
      if newIndex >= ArraySize(listElements) {
        newIndex = 0;
      };
    };
    if index != newIndex {
      value.SetIndex(newIndex);
    };
  }

  public func Refresh() -> Void {
    let index: Int32;
    let value: ref<ConfigVarListString>;
    this.Refresh();
    value = this.m_SettingsEntry as ConfigVarListString;
    index = value.GetIndex();
    this.UpdateValueTextLanguageResources();
    if !value.ListHasDisplayValues() {
      inkTextRef.SetText(this.m_ValueText, GetLocalizedText(value.GetValue()));
    } else {
      inkTextRef.SetText(this.m_ValueText, GetLocalizedTextByKey(value.GetDisplayValue(index)));
    };
    this.SelectDot(index);
  }
}

public class SettingsSelectorControllerListName extends SettingsSelectorControllerList {

  protected let m_realValue: wref<ConfigVarListName>;

  protected let m_currentIndex: Int32;

  public func Setup(entry: ref<ConfigVar>, isPreGame: Bool) -> Void {
    let data: array<CName>;
    this.Setup(entry, isPreGame);
    this.m_realValue = this.m_SettingsEntry as ConfigVarListName;
    data = this.m_realValue.GetValues();
    this.m_currentIndex = this.m_realValue.GetIndex();
    this.PopulateDots(ArraySize(data));
    this.SelectDot(this.m_currentIndex);
    this.Refresh();
  }

  private func ChangeValue(forward: Bool) -> Void {
    let listElements: array<CName> = this.m_realValue.GetValues();
    let index: Int32 = this.m_currentIndex;
    let newIndex: Int32 = index + forward ? 1 : -1;
    if newIndex < 0 {
      newIndex = ArraySize(listElements) - 1;
    } else {
      if newIndex >= ArraySize(listElements) {
        newIndex = 0;
      };
    };
    if index != newIndex {
      this.m_currentIndex = newIndex;
      this.m_realValue.SetIndex(newIndex);
    };
  }

  public func Refresh() -> Void {
    let params: ref<inkTextParams>;
    this.Refresh();
    this.UpdateValueTextLanguageResources();
    if !this.m_realValue.ListHasDisplayValues() {
      inkTextRef.SetText(this.m_ValueText, GetLocalizedTextByKey(this.m_realValue.GetValueFor(this.m_currentIndex)));
    } else {
      if Equals(this.m_additionalText, n"") {
        inkTextRef.SetText(this.m_ValueText, GetLocalizedTextByKey(this.m_realValue.GetDisplayValue(this.m_currentIndex)));
      } else {
        params = new inkTextParams();
        params.AddLocalizedString("description", GetLocalizedTextByKey(this.m_realValue.GetDisplayValue(this.m_currentIndex)));
        params.AddLocalizedString("additional_text", ToString(this.m_additionalText));
        inkTextRef.SetLocalizedTextScript(this.m_ValueText, "LocKey#76949", params);
      };
    };
    this.SelectDot(this.m_currentIndex);
  }
}

public class SettingsSelectorControllerLanguagesList extends SettingsSelectorControllerListName {

  protected edit let m_downloadButton: inkWidgetRef;

  private let m_descriptionText: inkTextRef;

  private let m_isVoiceOverInstalled: Bool;

  private let m_currentSetIndex: Int32;

  public final func SetDownloadButtonVisible(visible: Bool) -> Void {
    inkWidgetRef.SetVisible(this.m_downloadButton, visible);
  }

  public final func SetDownloadButtonEnabled(enabled: Bool) -> Void {
    inkWidgetRef.SetOpacity(this.m_downloadButton, enabled ? 1.00 : 0.30);
  }

  public func Setup(entry: ref<ConfigVar>, isPreGame: Bool) -> Void {
    this.Setup(entry, isPreGame);
    this.m_isVoiceOverInstalled = IsLanguageVoicePackInstalled(this.m_realValue.GetValueFor(this.m_currentIndex));
    this.m_currentSetIndex = this.m_currentIndex;
    this.SetDownloadButtonVisible(!this.m_isVoiceOverInstalled);
    this.Refresh();
  }

  protected cb func OnInitialize() -> Bool {
    super.OnInitialize();
    this.m_isVoiceOverInstalled = false;
    if inkWidgetRef.IsValid(this.m_downloadButton) {
      inkWidgetRef.RegisterToCallback(this.m_downloadButton, n"OnRelease", this, n"OnDownload");
    };
  }

  private func ChangeValue(forward: Bool) -> Void {
    let listElements: array<CName> = this.m_realValue.GetValues();
    let index: Int32 = this.m_currentIndex;
    let newIndex: Int32 = index + forward ? 1 : -1;
    if newIndex < 0 {
      newIndex = ArraySize(listElements) - 1;
    } else {
      if newIndex >= ArraySize(listElements) {
        newIndex = 0;
      };
    };
    if index != newIndex {
      this.m_currentIndex = newIndex;
      this.m_isVoiceOverInstalled = IsLanguageVoicePackInstalled(this.m_realValue.GetValueFor(this.m_currentIndex));
      this.SetDownloadButtonVisible(!this.m_isVoiceOverInstalled);
      this.ResetAdditionalText();
      if this.m_isVoiceOverInstalled {
        if this.m_currentIndex != this.m_currentSetIndex {
          this.m_currentSetIndex = this.m_currentIndex;
          this.m_realValue.SetIndex(this.m_currentIndex);
        };
      } else {
        this.SetAdditionalText(n"LocKey#76946");
      };
      this.Refresh();
    };
  }

  public final func RegisterDownloadButtonHovers(descriptionText: inkTextRef) -> Void {
    this.m_descriptionText = descriptionText;
    inkWidgetRef.RegisterToCallback(this.m_downloadButton, n"OnHoverOver", this, n"OnSettingHoverOver");
    inkWidgetRef.RegisterToCallback(this.m_downloadButton, n"OnHoverOut", this, n"OnSettingHoverOut");
  }

  protected cb func OnDownload(e: ref<inkPointerEvent>) -> Bool {
    if e.IsAction(n"click") {
      RequestInstallLanguagePackDialog(this.m_realValue.GetValueFor(this.m_currentIndex));
    };
  }

  public func Refresh() -> Void {
    if this.m_isVoiceOverInstalled {
      this.ResetAdditionalText();
    } else {
      this.SetAdditionalText(n"LocKey#76946");
    };
    this.Refresh();
  }

  protected cb func OnSettingHoverOver(e: ref<inkPointerEvent>) -> Bool {
    inkTextRef.SetLocalizedText(this.m_descriptionText, n"Will install this language pack");
    inkWidgetRef.SetVisible(this.m_descriptionText, true);
  }

  protected cb func OnSettingHoverOut(e: ref<inkPointerEvent>) -> Bool {
    inkWidgetRef.SetVisible(this.m_descriptionText, false);
  }
}
