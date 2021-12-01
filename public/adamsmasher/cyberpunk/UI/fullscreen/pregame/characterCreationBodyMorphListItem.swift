
public class characterCreationVoiceOverSwitcher extends inkLogicController {

  private edit let m_selectedLabel: inkTextRef;

  private edit let m_selectorNextBtn: inkWidgetRef;

  private edit let m_selectorPrevBtn: inkWidgetRef;

  private edit let m_warningLabel: inkTextRef;

  private let m_isMale: Bool;

  private edit let m_male: String;

  private edit let m_female: String;

  private edit let m_selectorTexture: inkImageRef;

  private edit let m_arrowsTexture: inkImageRef;

  private edit let m_optionSwitchHint: inkWidgetRef;

  private let translationAnimationCtrl: wref<inkTextReplaceController>;

  private let m_selector: wref<inkWidget>;

  protected cb func OnInitialize() -> Bool {
    this.m_selector = this.GetRootWidget();
    inkWidgetRef.SetVisible(this.m_optionSwitchHint, false);
    inkWidgetRef.RegisterToCallback(this.m_selectorNextBtn, n"OnHoverOver", this, n"OnHoverOverNext");
    inkWidgetRef.RegisterToCallback(this.m_selectorNextBtn, n"OnHoverOut", this, n"OnHoverOutNext");
    inkWidgetRef.RegisterToCallback(this.m_selectorPrevBtn, n"OnHoverOver", this, n"OnHoverOverPrev");
    inkWidgetRef.RegisterToCallback(this.m_selectorPrevBtn, n"OnHoverOut", this, n"OnHoverOutPrev");
    inkWidgetRef.RegisterToCallback(this.m_selectorNextBtn, n"OnRelease", this, n"OnSwitch");
    inkWidgetRef.RegisterToCallback(this.m_selectorPrevBtn, n"OnRelease", this, n"OnSwitch");
    this.m_selector.RegisterToCallback(n"OnHoverOver", this, n"OnHoverOverWidget");
    this.m_selector.RegisterToCallback(n"OnHoverOut", this, n"OnHoverOutWidget");
    this.m_selector.RegisterToCallback(n"OnRelease", this, n"OnShortcutPress");
  }

  protected cb func OnUninitialize() -> Bool {
    inkWidgetRef.UnregisterFromCallback(this.m_selectorNextBtn, n"OnHoverOver", this, n"OnHoverOverNext");
    inkWidgetRef.UnregisterFromCallback(this.m_selectorNextBtn, n"OnHoverOut", this, n"OnHoverOutNext");
    inkWidgetRef.UnregisterFromCallback(this.m_selectorPrevBtn, n"OnHoverOver", this, n"OnHoverOverPrev");
    inkWidgetRef.UnregisterFromCallback(this.m_selectorPrevBtn, n"OnHoverOut", this, n"OnHoverOutPrev");
    inkWidgetRef.UnregisterFromCallback(this.m_selectorNextBtn, n"OnRelease", this, n"OnSwitch");
    inkWidgetRef.UnregisterFromCallback(this.m_selectorPrevBtn, n"OnRelease", this, n"OnSwitch");
    this.m_selector.UnregisterFromCallback(n"OnHoverOver", this, n"OnHoverOverWidget");
    this.m_selector.UnregisterFromCallback(n"OnHoverOut", this, n"OnHoverOutWidget");
    this.m_selector.UnregisterFromCallback(n"OnRelease", this, n"OnShortcutPress");
  }

  protected cb func OnSwitch(e: ref<inkPointerEvent>) -> Bool {
    if e.IsAction(n"click") {
      this.Switch();
    };
  }

  public final func Switch() -> Void {
    this.SetIsBrainGenderMale(!this.m_isMale);
  }

  protected cb func OnShortcutPress(e: ref<inkPointerEvent>) -> Bool {
    if !e.IsHandled() {
      if e.IsAction(n"option_switch_prev") {
        this.PlaySound(n"Button", n"OnPress");
        this.Switch();
        e.Handle();
      } else {
        if e.IsAction(n"option_switch_next") {
          this.PlaySound(n"Button", n"OnPress");
          this.Switch();
          e.Handle();
        };
      };
    };
  }

  protected cb func OnHoverOverWidget(e: ref<inkPointerEvent>) -> Bool {
    if NotEquals(this.GetRootWidget().GetState(), n"Unavailable") {
      inkWidgetRef.SetVisible(this.m_optionSwitchHint, true);
    };
  }

  protected cb func OnHoverOutWidget(e: ref<inkPointerEvent>) -> Bool {
    inkWidgetRef.SetVisible(this.m_optionSwitchHint, false);
  }

  protected cb func OnHoverOverNext(e: ref<inkPointerEvent>) -> Bool {
    inkImageRef.SetTexturePart(this.m_selectorTexture, n"cell_option_right");
    inkImageRef.SetTexturePart(this.m_arrowsTexture, n"arrow_right");
  }

  protected cb func OnHoverOutNext(e: ref<inkPointerEvent>) -> Bool {
    inkImageRef.SetTexturePart(this.m_selectorTexture, n"cell_option_idle");
    inkImageRef.SetTexturePart(this.m_arrowsTexture, n"arrows_idle");
  }

  protected cb func OnHoverOverPrev(e: ref<inkPointerEvent>) -> Bool {
    inkImageRef.SetTexturePart(this.m_selectorTexture, n"cell_option_left");
    inkImageRef.SetTexturePart(this.m_arrowsTexture, n"arrow_left");
  }

  protected cb func OnHoverOutPrev(e: ref<inkPointerEvent>) -> Bool {
    inkImageRef.SetTexturePart(this.m_selectorTexture, n"cell_option_idle");
    inkImageRef.SetTexturePart(this.m_arrowsTexture, n"arrows_idle");
  }

  public final func SetIsBrainGenderMale(isMale: Bool) -> Void {
    let localizedText: String;
    this.m_isMale = isMale;
    inkTextRef.SetText(this.m_selectedLabel, this.m_isMale ? "LocKey#43481" : "LocKey#43482");
    localizedText = GetLocalizedText(this.m_isMale ? "LocKey#42833" : "LocKey#42834");
    this.translationAnimationCtrl.SetBaseText("...");
    this.translationAnimationCtrl = inkWidgetRef.GetController(this.m_warningLabel) as inkTextReplaceController;
    this.translationAnimationCtrl.SetTargetText(localizedText);
    this.translationAnimationCtrl.PlaySetAnimation();
    this.CallCustomCallback(n"OnVoiceOverSwitched");
  }

  public final func IsBrainGenderMale() -> Bool {
    return this.m_isMale;
  }
}

public class characterCreationBodyMorphOption extends inkLogicController {

  private edit let m_optionLabel: inkTextRef;

  private edit let m_selectedLabel: inkTextRef;

  private edit let m_selectorNextBtn: inkWidgetRef;

  private edit let m_selectorPrevBtn: inkWidgetRef;

  private edit let m_selectorTexture: inkImageRef;

  private edit let m_arrowsTexture: inkImageRef;

  private edit let m_optionSwitchHint: inkWidgetRef;

  private const let m_selectorOption: wref<CharacterCustomizationOption>;

  private const let m_morphInfo: wref<gameuiMorphInfo>;

  private const let m_appearanceInfo: wref<gameuiAppearanceInfo>;

  private const let m_switcherInfo: wref<gameuiSwitcherInfo>;

  @default(characterCreationBodyMorphOption, -1)
  private let m_currSelectorIndex: Int32;

  private let m_selector: wref<inkWidget>;

  public let m_animationProxy: ref<inkAnimProxy>;

  protected cb func OnInitialize() -> Bool {
    this.m_selector = this.GetRootWidget();
    inkWidgetRef.RegisterToCallback(this.m_selectorNextBtn, n"OnHoverOver", this, n"OnHoverOverNext");
    inkWidgetRef.RegisterToCallback(this.m_selectorNextBtn, n"OnHoverOut", this, n"OnHoverOutNext");
    inkWidgetRef.RegisterToCallback(this.m_selectorPrevBtn, n"OnHoverOver", this, n"OnHoverOverPrev");
    inkWidgetRef.RegisterToCallback(this.m_selectorPrevBtn, n"OnHoverOut", this, n"OnHoverOutPrev");
    inkWidgetRef.RegisterToCallback(this.m_selectorNextBtn, n"OnRelease", this, n"OnNext");
    inkWidgetRef.RegisterToCallback(this.m_selectorPrevBtn, n"OnRelease", this, n"OnPrev");
    this.m_selector.RegisterToCallback(n"OnHoverOver", this, n"OnHoverOverWidget");
    this.m_selector.RegisterToCallback(n"OnHoverOut", this, n"OnHoverOutWidget");
    this.m_selector.RegisterToCallback(n"OnRelease", this, n"OnShortcutPress");
    inkWidgetRef.SetVisible(this.m_optionSwitchHint, false);
  }

  protected cb func OnUninitialize() -> Bool {
    inkWidgetRef.UnregisterFromCallback(this.m_selectorNextBtn, n"OnHoverOver", this, n"OnHoverOverNext");
    inkWidgetRef.UnregisterFromCallback(this.m_selectorNextBtn, n"OnHoverOut", this, n"OnHoverOutNext");
    inkWidgetRef.UnregisterFromCallback(this.m_selectorPrevBtn, n"OnHoverOver", this, n"OnHoverOverPrev");
    inkWidgetRef.UnregisterFromCallback(this.m_selectorPrevBtn, n"OnHoverOut", this, n"OnHoverOutPrev");
    inkWidgetRef.UnregisterFromCallback(this.m_selectorNextBtn, n"OnRelease", this, n"OnNext");
    inkWidgetRef.UnregisterFromCallback(this.m_selectorPrevBtn, n"OnRelease", this, n"OnPrev");
    this.m_selector.UnregisterFromCallback(n"OnHoverOver", this, n"OnHoverOverWidget");
    this.m_selector.UnregisterFromCallback(n"OnHoverOut", this, n"OnHoverOutWidget");
    this.m_selector.UnregisterFromCallback(n"OnRelease", this, n"OnShortcutPress");
  }

  protected cb func OnHoverOverNext(e: ref<inkPointerEvent>) -> Bool {
    if IsDefined(this.m_selectorOption) && this.m_currSelectorIndex >= 0 {
      inkImageRef.SetTexturePart(this.m_selectorTexture, n"cell_option_right");
      inkImageRef.SetTexturePart(this.m_arrowsTexture, n"arrow_right");
    };
  }

  protected cb func OnHoverOutNext(e: ref<inkPointerEvent>) -> Bool {
    if IsDefined(this.m_selectorOption) && this.m_currSelectorIndex >= 0 {
      inkImageRef.SetTexturePart(this.m_selectorTexture, n"cell_option_idle");
      inkImageRef.SetTexturePart(this.m_arrowsTexture, n"arrows_idle");
    };
  }

  protected cb func OnHoverOverPrev(e: ref<inkPointerEvent>) -> Bool {
    if IsDefined(this.m_selectorOption) && this.m_currSelectorIndex >= 0 {
      inkImageRef.SetTexturePart(this.m_selectorTexture, n"cell_option_left");
      inkImageRef.SetTexturePart(this.m_arrowsTexture, n"arrow_left");
    };
  }

  protected cb func OnHoverOutPrev(e: ref<inkPointerEvent>) -> Bool {
    if IsDefined(this.m_selectorOption) && this.m_currSelectorIndex >= 0 {
      inkImageRef.SetTexturePart(this.m_selectorTexture, n"cell_option_idle");
      inkImageRef.SetTexturePart(this.m_arrowsTexture, n"arrows_idle");
    };
  }

  protected cb func OnNext(e: ref<inkPointerEvent>) -> Bool {
    if e.IsAction(n"click") {
      this.Next();
    };
  }

  protected cb func OnPrev(e: ref<inkPointerEvent>) -> Bool {
    if e.IsAction(n"click") {
      this.Previous();
    };
  }

  protected cb func OnShortcutPress(e: ref<inkPointerEvent>) -> Bool {
    if !e.IsHandled() {
      if e.IsAction(n"option_switch_prev") {
        this.PlaySound(n"Button", n"OnPress");
        this.Previous();
        e.Handle();
      } else {
        if e.IsAction(n"option_switch_next") {
          this.PlaySound(n"Button", n"OnPress");
          this.Next();
          e.Handle();
        };
      };
    };
  }

  protected cb func OnHoverOverWidget(e: ref<inkPointerEvent>) -> Bool {
    if NotEquals(this.GetRootWidget().GetState(), n"Unavailable") {
      inkWidgetRef.SetVisible(this.m_optionSwitchHint, true);
    };
  }

  protected cb func OnHoverOutWidget(e: ref<inkPointerEvent>) -> Bool {
    inkWidgetRef.SetVisible(this.m_optionSwitchHint, false);
  }

  public final func Previous() -> Void {
    if IsDefined(this.m_morphInfo) {
      this.SetSelectedMorphName(this.m_morphInfo, this.m_currSelectorIndex - 1);
    } else {
      if IsDefined(this.m_appearanceInfo) {
        this.SetSelectedAppearanceDefinition(this.m_appearanceInfo, this.m_currSelectorIndex - 1);
      } else {
        if IsDefined(this.m_switcherInfo) {
          this.SetSelectedSwitcherOption(this.m_switcherInfo, this.m_currSelectorIndex - 1);
        };
      };
    };
  }

  public final func Next() -> Void {
    if IsDefined(this.m_morphInfo) {
      this.SetSelectedMorphName(this.m_morphInfo, this.m_currSelectorIndex + 1);
    } else {
      if IsDefined(this.m_appearanceInfo) {
        this.SetSelectedAppearanceDefinition(this.m_appearanceInfo, this.m_currSelectorIndex + 1);
      } else {
        if IsDefined(this.m_switcherInfo) {
          this.SetSelectedSwitcherOption(this.m_switcherInfo, this.m_currSelectorIndex + 1);
        };
      };
    };
  }

  public final func GetSelectorOption() -> wref<CharacterCustomizationOption> {
    return this.m_selectorOption;
  }

  public final func GetSelectorIndex() -> Uint32 {
    return Cast(this.m_currSelectorIndex);
  }

  public final func SetOption(const option: wref<CharacterCustomizationOption>) -> Void {
    let morphInfo: ref<gameuiMorphInfo>;
    let switcherInfo: ref<gameuiSwitcherInfo>;
    let appearanceInfo: ref<gameuiAppearanceInfo> = option.info as gameuiAppearanceInfo;
    if IsDefined(appearanceInfo) {
      this.m_appearanceInfo = appearanceInfo;
      this.SetSelectorOption(option);
      this.SetSelectedAppearanceDefinition(this.m_appearanceInfo, Cast(option.currIndex), true);
      return;
    };
    morphInfo = option.info as gameuiMorphInfo;
    if IsDefined(morphInfo) {
      this.m_morphInfo = morphInfo;
      this.SetSelectorOption(option);
      this.SetSelectedMorphName(this.m_morphInfo, Cast(option.currIndex), true);
      return;
    };
    switcherInfo = option.info as gameuiSwitcherInfo;
    if IsDefined(switcherInfo) {
      this.m_switcherInfo = switcherInfo;
      this.SetSelectorOption(option);
      this.SetSelectedSwitcherOption(this.m_switcherInfo, Cast(option.currIndex), true);
    };
  }

  public final func ResetOption() -> Void {
    this.m_morphInfo = null;
    this.m_appearanceInfo = null;
    this.m_switcherInfo = null;
    this.m_currSelectorIndex = -1;
  }

  public final func RefreshView() -> Void {
    let isVisible: Bool = this.m_currSelectorIndex > -1 && (IsDefined(this.m_morphInfo) && ArraySize(this.m_morphInfo.morphNames) > 1 || IsDefined(this.m_appearanceInfo) && ArraySize(this.m_appearanceInfo.definitions) > 1 || IsDefined(this.m_switcherInfo) && ArraySize(this.m_switcherInfo.options) > 1);
    if isVisible {
      this.GetRootWidget().SetState(n"Available");
      inkImageRef.SetTexturePart(this.m_selectorTexture, n"cell_option_idle");
      inkWidgetRef.SetVisible(this.m_arrowsTexture, true);
    } else {
      inkTextRef.SetText(this.m_selectedLabel, "LocKey#20482");
      this.GetRootWidget().SetState(n"Unavailable");
      inkImageRef.SetTexturePart(this.m_selectorTexture, n"cell_option_disabled");
      inkWidgetRef.SetVisible(this.m_arrowsTexture, false);
    };
  }

  public final func SetSelectorOption(const option: wref<CharacterCustomizationOption>) -> Void {
    this.m_selectorOption = option;
    inkTextRef.SetText(this.m_optionLabel, option.info.localizedName);
  }

  public final func SetSelectedMorphName(const morphInfo: wref<gameuiMorphInfo>, currIndex: Int32, opt force: Bool) -> Void {
    let index: Int32;
    if ArraySize(morphInfo.morphNames) > 1 {
      index = this.Circle(currIndex, 0, ArraySize(morphInfo.morphNames) - 1);
      if force || this.m_currSelectorIndex != index {
        this.m_currSelectorIndex = index;
        inkTextRef.SetText(this.m_selectedLabel, morphInfo.morphNames[this.m_currSelectorIndex].localizedName);
        this.CallCustomCallback(n"OnSliderChange");
      };
    } else {
      this.m_currSelectorIndex = -1;
    };
    this.RefreshView();
  }

  public final func SetSelectedAppearanceDefinition(const appearanceInfo: wref<gameuiAppearanceInfo>, currIndex: Int32, opt force: Bool) -> Void {
    let index: Int32;
    if ArraySize(appearanceInfo.definitions) > 1 {
      index = this.Circle(currIndex, 0, ArraySize(appearanceInfo.definitions) - 1);
      if force || this.m_currSelectorIndex != index {
        this.m_currSelectorIndex = index;
        inkTextRef.SetText(this.m_selectedLabel, appearanceInfo.definitions[this.m_currSelectorIndex].localizedName);
        this.CallCustomCallback(n"OnSliderChange");
      };
    } else {
      this.m_currSelectorIndex = -1;
    };
    this.RefreshView();
  }

  public final func SetSelectedSwitcherOption(const switcherInfo: wref<gameuiSwitcherInfo>, currIndex: Int32, opt force: Bool) -> Void {
    let index: Int32;
    if ArraySize(switcherInfo.options) > 1 {
      index = this.Circle(currIndex, 0, ArraySize(switcherInfo.options) - 1);
      if force || this.m_currSelectorIndex != index {
        this.m_currSelectorIndex = index;
        inkTextRef.SetText(this.m_selectedLabel, switcherInfo.options[this.m_currSelectorIndex].localizedName);
        this.CallCustomCallback(n"OnSliderChange");
      };
    } else {
      this.m_currSelectorIndex = -1;
    };
    this.RefreshView();
  }

  public final func Circle(v: Int32, min: Int32, max: Int32) -> Int32 {
    if v < min {
      return max;
    };
    if v > max {
      return min;
    };
    return v;
  }
}

public class characterCreationBodyMorphOptionSelectorButton extends inkLogicController {

  private edit let m_overArrow: inkWidgetRef;

  protected cb func OnInitialize() -> Bool {
    let root: wref<inkWidget>;
    inkWidgetRef.SetVisible(this.m_overArrow, false);
    root = this.GetRootWidget();
    root.RegisterToCallback(n"OnHoverOver", this, n"OnHoverOver");
    root.RegisterToCallback(n"OnHoverOut", this, n"OnHoverOut");
  }

  protected cb func OnUninitialize() -> Bool {
    let root: wref<inkWidget> = this.GetRootWidget();
    root.UnregisterFromCallback(n"OnHoverOver", this, n"OnHoverOver");
    root.UnregisterFromCallback(n"OnHoverOut", this, n"OnHoverOut");
  }

  protected cb func OnHoverOver(e: ref<inkPointerEvent>) -> Bool {
    inkWidgetRef.SetVisible(this.m_overArrow, true);
  }

  protected cb func OnHoverOut(e: ref<inkPointerEvent>) -> Bool {
    inkWidgetRef.SetVisible(this.m_overArrow, false);
  }
}

public class characterCreationBodyMorphColorOption extends inkLogicController {

  private edit let m_optionLabel: inkTextRef;

  private edit let m_colorPickerBtn: inkWidgetRef;

  private edit let m_selectorNextBtn: inkWidgetRef;

  private edit let m_selectorPrevBtn: inkWidgetRef;

  private edit let m_selectorTexture: inkImageRef;

  private edit let m_arrowsTexture: inkImageRef;

  private edit let m_optionSwitchHint: inkWidgetRef;

  private const let m_colorPickerOption: wref<CharacterCustomizationOption>;

  private const let m_appearanceInfo: wref<gameuiAppearanceInfo>;

  @default(characterCreationBodyMorphColorOption, -1)
  private let m_currColorIndex: Int32;

  private let m_selector: wref<inkWidget>;

  protected cb func OnInitialize() -> Bool {
    this.m_selector = this.GetRootWidget();
    inkWidgetRef.SetVisible(this.m_colorPickerBtn, false);
    inkWidgetRef.SetVisible(this.m_optionSwitchHint, false);
    inkWidgetRef.RegisterToCallback(this.m_selectorNextBtn, n"OnHoverOver", this, n"OnHoverOverNext");
    inkWidgetRef.RegisterToCallback(this.m_selectorNextBtn, n"OnHoverOut", this, n"OnHoverOutNext");
    inkWidgetRef.RegisterToCallback(this.m_selectorPrevBtn, n"OnHoverOver", this, n"OnHoverOverPrev");
    inkWidgetRef.RegisterToCallback(this.m_selectorPrevBtn, n"OnHoverOut", this, n"OnHoverOutPrev");
    inkWidgetRef.RegisterToCallback(this.m_colorPickerBtn, n"OnHoverOver", this, n"OnHoverOverColorPicker");
    inkWidgetRef.RegisterToCallback(this.m_colorPickerBtn, n"OnHoverOut", this, n"OnHoverOutColorPicker");
    inkWidgetRef.RegisterToCallback(this.m_colorPickerBtn, n"OnTriggered", this, n"OnColorPickerTriggered");
    inkWidgetRef.RegisterToCallback(this.m_selectorNextBtn, n"OnRelease", this, n"OnNext");
    inkWidgetRef.RegisterToCallback(this.m_selectorPrevBtn, n"OnRelease", this, n"OnPrev");
    this.m_selector.RegisterToCallback(n"OnHoverOver", this, n"OnHoverOverWidget");
    this.m_selector.RegisterToCallback(n"OnHoverOut", this, n"OnHoverOutWidget");
    this.m_selector.RegisterToCallback(n"OnRelease", this, n"OnShortcutPress");
  }

  protected cb func OnUninitialize() -> Bool {
    inkWidgetRef.UnregisterFromCallback(this.m_selectorNextBtn, n"OnHoverOver", this, n"OnHoverOverNext");
    inkWidgetRef.UnregisterFromCallback(this.m_selectorNextBtn, n"OnHoverOut", this, n"OnHoverOutNext");
    inkWidgetRef.UnregisterFromCallback(this.m_selectorPrevBtn, n"OnHoverOver", this, n"OnHoverOverPrev");
    inkWidgetRef.UnregisterFromCallback(this.m_selectorPrevBtn, n"OnHoverOut", this, n"OnHoverOutPrev");
    inkWidgetRef.UnregisterFromCallback(this.m_colorPickerBtn, n"OnHoverOver", this, n"OnHoverOverColorPicker");
    inkWidgetRef.UnregisterFromCallback(this.m_colorPickerBtn, n"OnHoverOut", this, n"OnHoverOutColorPicker");
    inkWidgetRef.UnregisterFromCallback(this.m_colorPickerBtn, n"OnTriggered", this, n"OnColorPickerTriggered");
    inkWidgetRef.UnregisterFromCallback(this.m_selectorNextBtn, n"OnRelease", this, n"OnNext");
    inkWidgetRef.UnregisterFromCallback(this.m_selectorPrevBtn, n"OnRelease", this, n"OnPrev");
    this.m_selector.UnregisterFromCallback(n"OnHoverOver", this, n"OnHoverOverWidget");
    this.m_selector.UnregisterFromCallback(n"OnHoverOut", this, n"OnHoverOutWidget");
    this.m_selector.UnregisterFromCallback(n"OnRelease", this, n"OnShortcutPress");
  }

  protected cb func OnNext(e: ref<inkPointerEvent>) -> Bool {
    if e.IsAction(n"click") {
      this.Next();
    };
  }

  protected cb func OnPrev(e: ref<inkPointerEvent>) -> Bool {
    if e.IsAction(n"click") {
      this.Previous();
    };
  }

  public final func Previous() -> Void {
    if IsDefined(this.m_appearanceInfo) {
      this.SetSelectedAppearanceDefinitionColor(this.m_appearanceInfo, this.m_currColorIndex - 1);
      this.CallCustomCallback(n"OnColorChange");
    };
  }

  public final func Next() -> Void {
    if IsDefined(this.m_appearanceInfo) {
      this.SetSelectedAppearanceDefinitionColor(this.m_appearanceInfo, this.m_currColorIndex + 1);
      this.CallCustomCallback(n"OnColorChange");
    };
  }

  protected cb func OnShortcutPress(e: ref<inkPointerEvent>) -> Bool {
    if !e.IsHandled() {
      if e.IsAction(n"option_switch_prev") {
        this.PlaySound(n"Button", n"OnPress");
        this.Previous();
        e.Handle();
      } else {
        if e.IsAction(n"option_switch_next") {
          this.PlaySound(n"Button", n"OnPress");
          this.Next();
          e.Handle();
        };
      };
    };
  }

  protected cb func OnHoverOverWidget(e: ref<inkPointerEvent>) -> Bool {
    if NotEquals(this.GetRootWidget().GetState(), n"Unavailable") {
      inkWidgetRef.SetVisible(this.m_optionSwitchHint, true);
    };
  }

  protected cb func OnHoverOutWidget(e: ref<inkPointerEvent>) -> Bool {
    inkWidgetRef.SetVisible(this.m_optionSwitchHint, false);
  }

  protected cb func OnHoverOverNext(e: ref<inkPointerEvent>) -> Bool {
    if IsDefined(this.m_colorPickerOption) && this.m_currColorIndex >= 0 {
      inkImageRef.SetTexturePart(this.m_selectorTexture, n"cell_gallery_right");
      inkImageRef.SetTexturePart(this.m_arrowsTexture, n"arrow_gal_right");
    };
  }

  protected cb func OnHoverOutNext(e: ref<inkPointerEvent>) -> Bool {
    if IsDefined(this.m_colorPickerOption) && this.m_currColorIndex >= 0 {
      inkImageRef.SetTexturePart(this.m_selectorTexture, n"cell_gallery_idle");
      inkImageRef.SetTexturePart(this.m_arrowsTexture, n"arrow_gal_idle");
    };
  }

  protected cb func OnHoverOverPrev(e: ref<inkPointerEvent>) -> Bool {
    if IsDefined(this.m_colorPickerOption) && this.m_currColorIndex >= 0 {
      inkImageRef.SetTexturePart(this.m_selectorTexture, n"cell_gallery_left");
      inkImageRef.SetTexturePart(this.m_arrowsTexture, n"arrow_gal_left");
    };
  }

  protected cb func OnHoverOutPrev(e: ref<inkPointerEvent>) -> Bool {
    if IsDefined(this.m_colorPickerOption) && this.m_currColorIndex >= 0 {
      inkImageRef.SetTexturePart(this.m_selectorTexture, n"cell_gallery_idle");
      inkImageRef.SetTexturePart(this.m_arrowsTexture, n"arrow_gal_idle");
    };
  }

  protected cb func OnHoverOverColorPicker(e: ref<inkPointerEvent>) -> Bool {
    if IsDefined(this.m_colorPickerOption) && this.m_currColorIndex >= 0 {
      inkImageRef.SetTexturePart(this.m_selectorTexture, n"cell_gallery_centre");
      inkImageRef.SetTexturePart(this.m_arrowsTexture, n"arrow_gal_centre");
    };
  }

  protected cb func OnHoverOutColorPicker(e: ref<inkPointerEvent>) -> Bool {
    if IsDefined(this.m_colorPickerOption) && this.m_currColorIndex >= 0 {
      inkImageRef.SetTexturePart(this.m_selectorTexture, n"cell_gallery_idle");
      inkImageRef.SetTexturePart(this.m_arrowsTexture, n"arrow_gal_idle");
    };
  }

  protected cb func OnColorPickerTriggered(widget: wref<inkWidget>) -> Bool {
    this.CallCustomCallback(n"OnColorPickerTriggered");
  }

  public final func GetColorPickerOption() -> wref<CharacterCustomizationOption> {
    return this.m_colorPickerOption;
  }

  public final func GetColorIndex() -> Uint32 {
    return Cast(this.m_currColorIndex);
  }

  public final func IsColorPickerTriggered() -> Bool {
    let controller: ref<characterCreationBodyMorphOptionColorPickerButton> = inkWidgetRef.GetController(this.m_colorPickerBtn) as characterCreationBodyMorphOptionColorPickerButton;
    return controller.IsTriggered();
  }

  public final func RefreshColorPicker(index: Int32, isTriggered: Bool) -> Void {
    let controller: ref<characterCreationBodyMorphOptionColorPickerButton>;
    let appearanceInfo: ref<gameuiAppearanceInfo> = this.m_colorPickerOption.info as gameuiAppearanceInfo;
    this.SetSelectedAppearanceDefinitionColor(appearanceInfo, index);
    controller = inkWidgetRef.GetController(this.m_colorPickerBtn) as characterCreationBodyMorphOptionColorPickerButton;
    controller.Trigger(isTriggered);
  }

  public final func SetOption(const option: wref<CharacterCustomizationOption>) -> Void {
    let appearanceInfo: ref<gameuiAppearanceInfo> = option.info as gameuiAppearanceInfo;
    if IsDefined(appearanceInfo) && appearanceInfo.useThumbnails {
      this.SetColorPickerOption(appearanceInfo, option);
      this.SetSelectedAppearanceDefinitionColor(appearanceInfo, Cast(option.currIndex), true);
    };
  }

  public final func ResetOption() -> Void {
    this.m_appearanceInfo = null;
    this.m_currColorIndex = -1;
  }

  public final func RefreshView() -> Void {
    let isVisible: Bool = IsDefined(this.m_appearanceInfo) && ArraySize(this.m_appearanceInfo.definitions) > 1;
    inkWidgetRef.SetVisible(this.m_colorPickerBtn, isVisible);
    if isVisible {
      this.GetRootWidget().SetState(n"Available");
      inkImageRef.SetTexturePart(this.m_selectorTexture, n"cell_gallery_idle");
      inkWidgetRef.SetVisible(this.m_arrowsTexture, true);
    } else {
      this.GetRootWidget().SetState(n"Unavailable");
      inkImageRef.SetTexturePart(this.m_selectorTexture, n"cell_gallery_disabled");
      inkWidgetRef.SetVisible(this.m_arrowsTexture, false);
    };
  }

  public final func SetColorPickerOption(const appearanceInfo: wref<gameuiAppearanceInfo>, const option: wref<CharacterCustomizationOption>) -> Void {
    this.m_appearanceInfo = appearanceInfo;
    this.m_colorPickerOption = option;
    inkTextRef.SetText(this.m_optionLabel, appearanceInfo.localizedName);
    this.RefreshView();
  }

  public final func SetSelectedAppearanceDefinitionColor(const appearanceInfo: wref<gameuiAppearanceInfo>, currIndex: Int32, opt force: Bool) -> Void {
    let controller: ref<characterCreationBodyMorphOptionColorPickerButton>;
    let index: Int32;
    if ArraySize(appearanceInfo.definitions) > 1 {
      index = this.Circle(currIndex, 0, ArraySize(appearanceInfo.definitions) - 1);
      if force || this.m_currColorIndex != index {
        this.m_currColorIndex = index;
        controller = inkWidgetRef.GetController(this.m_colorPickerBtn) as characterCreationBodyMorphOptionColorPickerButton;
        controller.SetTintColor(appearanceInfo.definitions[this.m_currColorIndex].color, appearanceInfo.definitions[this.m_currColorIndex].icon);
        this.CallCustomCallback(n"OnColorChange");
      };
    } else {
      this.m_currColorIndex = -1;
    };
    this.RefreshView();
  }

  public final func Circle(v: Int32, min: Int32, max: Int32) -> Int32 {
    if v < min {
      return max;
    };
    if v > max {
      return min;
    };
    return v;
  }
}

public class characterCreationBodyMorphOptionColorPickerButton extends inkLogicController {

  private edit let m_background: inkWidgetRef;

  private edit let m_icon: inkImageRef;

  @default(characterCreationBodyMorphOptionColorPickerButton, false)
  private let m_isTriggered: Bool;

  protected cb func OnInitialize() -> Bool {
    let root: wref<inkWidget> = this.GetRootWidget();
    root.RegisterToCallback(n"OnHoverOver", this, n"OnHoverOver");
    root.RegisterToCallback(n"OnHoverOut", this, n"OnHoverOut");
    root.RegisterToCallback(n"OnRelease", this, n"OnTrigger");
    inkWidgetRef.SetVisible(this.m_icon, false);
  }

  protected cb func OnUninitialize() -> Bool {
    let root: wref<inkWidget> = this.GetRootWidget();
    root.UnregisterFromCallback(n"OnHoverOver", this, n"OnHoverOver");
    root.UnregisterFromCallback(n"OnHoverOut", this, n"OnHoverOut");
    root.UnregisterFromCallback(n"OnRelease", this, n"OnTrigger");
  }

  protected cb func OnHoverOver(e: ref<inkPointerEvent>) -> Bool {
    this.GetRootWidget().SetState(n"Hover");
  }

  protected cb func OnHoverOut(e: ref<inkPointerEvent>) -> Bool {
    this.GetRootWidget().SetState(n"Default");
  }

  protected cb func OnTrigger(e: ref<inkPointerEvent>) -> Bool {
    if e.IsAction(n"click") {
      this.Trigger(!this.m_isTriggered);
      this.CallCustomCallback(n"OnTriggered");
    };
  }

  public final func SetTintColor(color: Color, icon: TweakDBID) -> Void {
    let iconRecord: ref<UIIcon_Record>;
    inkWidgetRef.SetTintColor(this.m_background, color);
    if TDBID.IsValid(icon) {
      inkWidgetRef.SetVisible(this.m_icon, true);
      iconRecord = TweakDBInterface.GetUIIconRecord(icon);
      inkImageRef.SetAtlasResource(this.m_icon, iconRecord.AtlasResourcePath());
      inkImageRef.SetTexturePart(this.m_icon, iconRecord.AtlasPartName());
    } else {
      inkWidgetRef.SetVisible(this.m_icon, false);
    };
  }

  public final func IsTriggered() -> Bool {
    return this.m_isTriggered;
  }

  public final func Trigger(enable: Bool) -> Void {
    this.m_isTriggered = enable;
  }
}

public class characterCreationBodyMorphOptionColorPickerItem extends inkLogicController {

  private edit let m_background: inkWidgetRef;

  private edit let m_icon: inkImageRef;

  private edit let m_foreground: inkWidgetRef;

  private edit let m_selectionMark: inkWidgetRef;

  protected cb func OnInitialize() -> Bool {
    let root: wref<inkWidget>;
    inkWidgetRef.SetVisible(this.m_icon, false);
    inkWidgetRef.SetVisible(this.m_foreground, false);
    inkWidgetRef.SetVisible(this.m_selectionMark, false);
    root = this.GetRootWidget();
    root.RegisterToCallback(n"OnHoverOver", this, n"OnHoverOver");
    root.RegisterToCallback(n"OnHoverOut", this, n"OnHoverOut");
    root.RegisterToCallback(n"OnRelease", this, n"OnSelect");
  }

  protected cb func OnUninitialize() -> Bool {
    let root: wref<inkWidget> = this.GetRootWidget();
    root.UnregisterFromCallback(n"OnHoverOver", this, n"OnHoverOver");
    root.UnregisterFromCallback(n"OnHoverOut", this, n"OnHoverOut");
    root.UnregisterFromCallback(n"OnRelease", this, n"OnSelect");
  }

  protected cb func OnHoverOver(e: ref<inkPointerEvent>) -> Bool {
    inkWidgetRef.SetVisible(this.m_foreground, true);
  }

  protected cb func OnHoverOut(e: ref<inkPointerEvent>) -> Bool {
    inkWidgetRef.SetVisible(this.m_foreground, false);
  }

  protected cb func OnSelect(e: ref<inkPointerEvent>) -> Bool {
    if e.IsAction(n"click") {
      this.CallCustomCallback(n"OnSelect");
    };
  }

  public final func SetTintColor(color: Color, icon: TweakDBID) -> Void {
    let iconRecord: ref<UIIcon_Record>;
    inkWidgetRef.SetTintColor(this.m_background, color);
    if TDBID.IsValid(icon) {
      inkWidgetRef.SetVisible(this.m_icon, true);
      iconRecord = TweakDBInterface.GetUIIconRecord(icon);
      inkImageRef.SetAtlasResource(this.m_icon, iconRecord.AtlasResourcePath());
      inkImageRef.SetTexturePart(this.m_icon, iconRecord.AtlasPartName());
    } else {
      inkWidgetRef.SetVisible(this.m_icon, false);
    };
  }

  public final func SetSelected(selected: Bool) -> Void {
    inkWidgetRef.SetVisible(this.m_selectionMark, selected);
    if selected {
      this.SetCursorOverWidget(this.GetRootWidget());
    };
  }
}

public class characterCreationBodyMorphOptionColorPicker extends inkLogicController {

  private edit let m_grid: inkUniformGridRef;

  private edit let m_title: inkTextRef;

  private const let m_option: wref<CharacterCustomizationOption>;

  @default(characterCreationBodyMorphOptionColorPicker, -1)
  private let m_selectedIndex: Int32;

  protected cb func OnColorSelected(widget: wref<inkWidget>) -> Bool {
    let colorPickerItem: wref<inkWidget>;
    let colorPickerItemController: wref<characterCreationBodyMorphOptionColorPickerItem>;
    let count: Int32 = inkCompoundRef.GetNumChildren(this.m_grid);
    let i: Int32 = 0;
    while i < count {
      colorPickerItem = inkCompoundRef.GetWidgetByIndex(this.m_grid, i);
      colorPickerItemController = colorPickerItem.GetController() as characterCreationBodyMorphOptionColorPickerItem;
      if colorPickerItem == widget {
        colorPickerItemController.SetSelected(true);
        this.m_selectedIndex = i;
      } else {
        colorPickerItemController.SetSelected(false);
      };
      i += 1;
    };
    this.CallCustomCallback(n"OnColorSelected");
  }

  public final func GetOption() -> wref<CharacterCustomizationOption> {
    return this.m_option;
  }

  public final func SetTitle(title: String) -> Void {
    inkTextRef.SetText(this.m_title, title);
  }

  public final func GetSelectedIndex() -> Int32 {
    return this.m_selectedIndex;
  }

  public final func FillGrid(const option: wref<CharacterCustomizationOption>) -> Void {
    let appearanceInfo: ref<gameuiAppearanceInfo>;
    let colorPickerItem: wref<inkWidget>;
    let colorPickerItemController: wref<characterCreationBodyMorphOptionColorPickerItem>;
    let i: Int32;
    inkCompoundRef.RemoveAllChildren(this.m_grid);
    appearanceInfo = option.info as gameuiAppearanceInfo;
    if IsDefined(appearanceInfo) && appearanceInfo.useThumbnails {
      this.m_option = option;
      this.m_selectedIndex = Cast(option.currIndex);
      i = 0;
      while i < ArraySize(appearanceInfo.definitions) {
        colorPickerItem = this.SpawnFromLocal(inkWidgetRef.Get(this.m_grid), n"ColorPickerItem");
        colorPickerItemController = colorPickerItem.GetController() as characterCreationBodyMorphOptionColorPickerItem;
        colorPickerItemController.SetTintColor(appearanceInfo.definitions[i].color, appearanceInfo.definitions[i].icon);
        colorPickerItemController.SetSelected(i == this.m_selectedIndex);
        colorPickerItemController.RegisterToCallback(n"OnSelect", this, n"OnColorSelected");
        i += 1;
      };
    } else {
      this.m_option = null;
      this.m_selectedIndex = -1;
    };
  }
}
