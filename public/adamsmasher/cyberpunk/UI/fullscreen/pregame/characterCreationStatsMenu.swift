
public class CharacterCreationStatsMenu extends BaseCharacterCreationController {

  public edit let m_attribute_01: inkWidgetRef;

  public edit let m_attribute_02: inkWidgetRef;

  public edit let m_attribute_03: inkWidgetRef;

  public edit let m_attribute_04: inkWidgetRef;

  public edit let m_attribute_05: inkWidgetRef;

  public edit let m_pointsLabel: inkWidgetRef;

  public edit let m_tooltipSlot: inkWidgetRef;

  public edit let m_skillPointLabel: inkTextRef;

  private edit let m_reset: inkWidgetRef;

  public edit let m_nextMenuConfirmation: inkWidgetRef;

  public edit let m_nextMenukConfirmationLibraryWidget: inkWidgetRef;

  public edit let m_ConfirmationConfirmBtn: inkWidgetRef;

  public edit let m_ConfirmationCloseBtn: inkWidgetRef;

  private edit let m_TooltipsManagerRef: inkWidgetRef;

  public edit let m_previousPageBtn: inkWidgetRef;

  public edit let m_navigationButtons: inkWidgetRef;

  public edit let m_optionSwitchHint: inkWidgetRef;

  private let m_attributesControllers: array<wref<characterCreationStatsAttributeBtn>>;

  private let m_attributePointsAvailable: Int32;

  private let m_startingAttributePoints: Int32;

  private let m_TooltipsManager: wref<gameuiTooltipsManager>;

  private let m_toolTipOffset: inkMargin;

  private let m_animationProxy: ref<inkAnimProxy>;

  private let m_confirmAnimationProxy: ref<inkAnimProxy>;

  private let m_hoverdWidget: wref<inkWidget>;

  protected cb func OnInitialize() -> Bool {
    let attribute01Controller: ref<characterCreationStatsAttributeBtn>;
    let attribute02Controller: ref<characterCreationStatsAttributeBtn>;
    let attribute03Controller: ref<characterCreationStatsAttributeBtn>;
    let attribute04Controller: ref<characterCreationStatsAttributeBtn>;
    let attribute05Controller: ref<characterCreationStatsAttributeBtn>;
    let attributeType: gamedataStatType;
    super.OnInitialize();
    this.RequestCameraChange(n"Summary_Preview");
    attributeType = gamedataStatType.Strength;
    attribute01Controller = inkWidgetRef.GetController(this.m_attribute_01) as characterCreationStatsAttributeBtn;
    attribute01Controller.SetData(attributeType, Cast(this.m_characterCustomizationState.GetAttribute(attributeType)));
    attributeType = gamedataStatType.Intelligence;
    attribute02Controller = inkWidgetRef.GetController(this.m_attribute_02) as characterCreationStatsAttributeBtn;
    attribute02Controller.SetData(attributeType, Cast(this.m_characterCustomizationState.GetAttribute(attributeType)));
    attributeType = gamedataStatType.Reflexes;
    attribute03Controller = inkWidgetRef.GetController(this.m_attribute_03) as characterCreationStatsAttributeBtn;
    attribute03Controller.SetData(attributeType, Cast(this.m_characterCustomizationState.GetAttribute(attributeType)));
    attributeType = gamedataStatType.TechnicalAbility;
    attribute04Controller = inkWidgetRef.GetController(this.m_attribute_04) as characterCreationStatsAttributeBtn;
    attribute04Controller.SetData(attributeType, Cast(this.m_characterCustomizationState.GetAttribute(attributeType)));
    attributeType = gamedataStatType.Cool;
    attribute05Controller = inkWidgetRef.GetController(this.m_attribute_05) as characterCreationStatsAttributeBtn;
    attribute05Controller.SetData(attributeType, Cast(this.m_characterCustomizationState.GetAttribute(attributeType)));
    ArrayClear(this.m_attributesControllers);
    ArrayPush(this.m_attributesControllers, attribute01Controller);
    ArrayPush(this.m_attributesControllers, attribute02Controller);
    ArrayPush(this.m_attributesControllers, attribute03Controller);
    ArrayPush(this.m_attributesControllers, attribute04Controller);
    ArrayPush(this.m_attributesControllers, attribute05Controller);
    inkWidgetRef.RegisterToCallback(this.m_attribute_01, n"OnValueIncremented", this, n"OnValueIncremented");
    inkWidgetRef.RegisterToCallback(this.m_attribute_01, n"OnValueDecremented", this, n"OnValueDecremented");
    inkWidgetRef.RegisterToCallback(this.m_attribute_02, n"OnValueIncremented", this, n"OnValueIncremented");
    inkWidgetRef.RegisterToCallback(this.m_attribute_02, n"OnValueDecremented", this, n"OnValueDecremented");
    inkWidgetRef.RegisterToCallback(this.m_attribute_03, n"OnValueIncremented", this, n"OnValueIncremented");
    inkWidgetRef.RegisterToCallback(this.m_attribute_03, n"OnValueDecremented", this, n"OnValueDecremented");
    inkWidgetRef.RegisterToCallback(this.m_attribute_04, n"OnValueIncremented", this, n"OnValueIncremented");
    inkWidgetRef.RegisterToCallback(this.m_attribute_04, n"OnValueDecremented", this, n"OnValueDecremented");
    inkWidgetRef.RegisterToCallback(this.m_attribute_05, n"OnValueIncremented", this, n"OnValueIncremented");
    inkWidgetRef.RegisterToCallback(this.m_attribute_05, n"OnValueDecremented", this, n"OnValueDecremented");
    inkWidgetRef.RegisterToCallback(this.m_attribute_01, n"OnBtnHoverOver", this, n"OnBtnHoverOver");
    inkWidgetRef.RegisterToCallback(this.m_attribute_02, n"OnBtnHoverOver", this, n"OnBtnHoverOver");
    inkWidgetRef.RegisterToCallback(this.m_attribute_03, n"OnBtnHoverOver", this, n"OnBtnHoverOver");
    inkWidgetRef.RegisterToCallback(this.m_attribute_04, n"OnBtnHoverOver", this, n"OnBtnHoverOver");
    inkWidgetRef.RegisterToCallback(this.m_attribute_05, n"OnBtnHoverOver", this, n"OnBtnHoverOver");
    inkWidgetRef.RegisterToCallback(this.m_attribute_01, n"OnBtnHoverOut", this, n"OnBtnHoverOut");
    inkWidgetRef.RegisterToCallback(this.m_attribute_02, n"OnBtnHoverOut", this, n"OnBtnHoverOut");
    inkWidgetRef.RegisterToCallback(this.m_attribute_03, n"OnBtnHoverOut", this, n"OnBtnHoverOut");
    inkWidgetRef.RegisterToCallback(this.m_attribute_04, n"OnBtnHoverOut", this, n"OnBtnHoverOut");
    inkWidgetRef.RegisterToCallback(this.m_attribute_05, n"OnBtnHoverOut", this, n"OnBtnHoverOut");
    this.RegisterToGlobalInputCallback(n"OnPostOnRelease", this, n"OnShortcutPress");
    this.RegisterToCallback(n"OnHoverOver", this, n"OnHoverOverWidget");
    this.RegisterToCallback(n"OnHoverOut", this, n"OnHoverOutWidget");
    inkWidgetRef.RegisterToCallback(this.m_previousPageBtn, n"OnRelease", this, n"OnPreviousButton");
    inkWidgetRef.RegisterToCallback(this.m_ConfirmationConfirmBtn, n"OnRelease", this, n"OnConfirmationConfirm");
    inkWidgetRef.RegisterToCallback(this.m_ConfirmationCloseBtn, n"OnRelease", this, n"OnConfirmationClose");
    this.RefreshControllers();
    this.PrepareTooltips();
    this.SetDefaultTooltip();
    this.m_toolTipOffset.left = 60.00;
    this.m_toolTipOffset.top = 5.00;
    this.m_attributePointsAvailable = Cast(this.m_characterCustomizationState.GetAttributePointsAvailable());
    inkTextRef.SetText(this.m_skillPointLabel, ToString(this.m_attributePointsAvailable));
    this.RefreshPointsLabel();
    this.ManageAllButtonsVisibility();
    this.GetTelemetrySystem().LogInitialChoiceSetStatege(telemetryInitalChoiceStage.Attributes);
    inkWidgetRef.SetVisible(this.m_optionSwitchHint, false);
    this.OnIntro();
  }

  protected cb func OnUninitialize() -> Bool {
    super.OnUninitialize();
    this.UnregisterFromGlobalInputCallback(n"OnPostOnRelease", this, n"OnShortcutPress");
    this.UnregisterFromCallback(n"OnHoverOver", this, n"OnHoverOverWidget");
    inkWidgetRef.UnregisterFromCallback(this.m_attribute_01, n"OnValueIncremented", this, n"OnValueIncremented");
    inkWidgetRef.UnregisterFromCallback(this.m_attribute_01, n"OnValueDecremented", this, n"OnValueDecremented");
    inkWidgetRef.UnregisterFromCallback(this.m_attribute_02, n"OnValueIncremented", this, n"OnValueIncremented");
    inkWidgetRef.UnregisterFromCallback(this.m_attribute_02, n"OnValueDecremented", this, n"OnValueDecremented");
    inkWidgetRef.UnregisterFromCallback(this.m_attribute_03, n"OnValueIncremented", this, n"OnValueIncremented");
    inkWidgetRef.UnregisterFromCallback(this.m_attribute_03, n"OnValueDecremented", this, n"OnValueDecremented");
    inkWidgetRef.UnregisterFromCallback(this.m_attribute_04, n"OnValueIncremented", this, n"OnValueIncremented");
    inkWidgetRef.UnregisterFromCallback(this.m_attribute_04, n"OnValueDecremented", this, n"OnValueDecremented");
    inkWidgetRef.UnregisterFromCallback(this.m_attribute_05, n"OnValueIncremented", this, n"OnValueIncremented");
    inkWidgetRef.UnregisterFromCallback(this.m_attribute_05, n"OnValueDecremented", this, n"OnValueDecremented");
    inkWidgetRef.UnregisterFromCallback(this.m_attribute_01, n"OnBtnHoverOver", this, n"OnBtnHoverOver");
    inkWidgetRef.UnregisterFromCallback(this.m_attribute_02, n"OnBtnHoverOver", this, n"OnBtnHoverOver");
    inkWidgetRef.UnregisterFromCallback(this.m_attribute_03, n"OnBtnHoverOver", this, n"OnBtnHoverOver");
    inkWidgetRef.UnregisterFromCallback(this.m_attribute_04, n"OnBtnHoverOver", this, n"OnBtnHoverOver");
    inkWidgetRef.UnregisterFromCallback(this.m_attribute_05, n"OnBtnHoverOver", this, n"OnBtnHoverOver");
    inkWidgetRef.UnregisterFromCallback(this.m_attribute_01, n"OnBtnHoverOut", this, n"OnBtnHoverOut");
    inkWidgetRef.UnregisterFromCallback(this.m_attribute_02, n"OnBtnHoverOut", this, n"OnBtnHoverOut");
    inkWidgetRef.UnregisterFromCallback(this.m_attribute_03, n"OnBtnHoverOut", this, n"OnBtnHoverOut");
    inkWidgetRef.UnregisterFromCallback(this.m_attribute_04, n"OnBtnHoverOut", this, n"OnBtnHoverOut");
    inkWidgetRef.UnregisterFromCallback(this.m_attribute_05, n"OnBtnHoverOut", this, n"OnBtnHoverOut");
    inkWidgetRef.UnregisterFromCallback(this.m_previousPageBtn, n"OnRelease", this, n"OnPreviousButton");
    inkWidgetRef.UnregisterFromCallback(this.m_ConfirmationConfirmBtn, n"OnRelease", this, n"OnConfirmationConfirm");
    inkWidgetRef.UnregisterFromCallback(this.m_ConfirmationCloseBtn, n"OnRelease", this, n"OnConfirmationClose");
  }

  public final func RefreshControllers() -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_attributesControllers) {
      this.m_attributesControllers[i].Refresh();
      i += 1;
    };
  }

  public final func RandomizeAttributes() -> Void {
    let i: Int32;
    let tempAttributesBtn: wref<characterCreationStatsAttributeBtn>;
    this.ResetAllBtnBackToBaseline();
    i = 0;
    while i < this.m_startingAttributePoints {
      tempAttributesBtn = this.m_attributesControllers[RandRange(0, ArraySize(this.m_attributesControllers))];
      tempAttributesBtn.data.value += 1;
      tempAttributesBtn.Refresh();
      i += 1;
    };
  }

  private final func ResetAllBtnBackToBaseline() -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_attributesControllers) {
      this.m_attributesControllers[i].data.SetValue(3);
      this.m_attributesControllers[i].Refresh();
      i += 1;
    };
    this.m_startingAttributePoints = 7;
    this.m_attributePointsAvailable = this.m_startingAttributePoints;
    inkTextRef.SetText(this.m_skillPointLabel, ToString(this.m_attributePointsAvailable));
    this.RefreshPointsLabel();
    this.ManageAllButtonsVisibility();
  }

  private final func SaveChanges() -> Void {
    let i: Int32;
    this.m_characterCustomizationState.SetAttributePointsAvailable(Cast(this.m_attributePointsAvailable));
    i = 0;
    while i < ArraySize(this.m_attributesControllers) {
      this.m_characterCustomizationState.SetAttribute(this.m_attributesControllers[i].data.attribute, Cast(this.m_attributesControllers[i].data.value));
      i += 1;
    };
  }

  public final func ShowConfirmation() -> Void {
    this.PlaySound(n"MapPin", n"OnDelete");
    inkWidgetRef.SetVisible(this.m_nextMenuConfirmation, true);
    inkWidgetRef.SetVisible(this.m_navigationButtons, false);
    this.m_animationProxy = inkWidgetRef.GetController(this.m_nextMenukConfirmationLibraryWidget).PlayLibraryAnimation(n"confirmation_intro");
    this.m_confirmAnimationProxy = inkWidgetRef.GetController(this.m_nextMenuConfirmation).PlayLibraryAnimation(n"confirmation_popup_btns");
  }

  public final func HideConfirmation() -> Void {
    inkWidgetRef.SetVisible(this.m_nextMenuConfirmation, false);
    inkWidgetRef.SetVisible(this.m_navigationButtons, true);
  }

  protected cb func OnButtonRelease(evt: ref<inkPointerEvent>) -> Bool {
    if !evt.IsHandled() {
      if evt.IsAction(n"back") && !inkWidgetRef.IsVisible(this.m_nextMenuConfirmation) {
        this.PlaySound(n"Button", n"OnPress");
        evt.Handle();
        this.PriorMenu();
      } else {
        if evt.IsAction(n"back") && inkWidgetRef.IsVisible(this.m_nextMenuConfirmation) {
          this.PlaySound(n"Button", n"OnPress");
          this.HideConfirmation();
        } else {
          if evt.IsAction(n"one_click_confirm") && !inkWidgetRef.IsVisible(this.m_nextMenuConfirmation) && StringToInt(inkTextRef.GetText(this.m_skillPointLabel)) > 0 {
            this.PlaySound(n"Button", n"OnPress");
            this.ShowConfirmation();
          } else {
            if evt.IsAction(n"one_click_confirm") && !inkWidgetRef.IsVisible(this.m_nextMenuConfirmation) && StringToInt(inkTextRef.GetText(this.m_skillPointLabel)) == 0 {
              this.PlaySound(n"Button", n"OnPress");
              evt.Handle();
              this.NextMenu();
            } else {
              if evt.IsAction(n"one_click_confirm") && inkWidgetRef.IsVisible(this.m_nextMenuConfirmation) {
                this.PlaySound(n"Button", n"OnPress");
                evt.Handle();
                this.NextMenu();
              } else {
                return false;
              };
            };
          };
        };
      };
      evt.Handle();
    };
  }

  protected func PriorMenu() -> Void {
    this.SaveChanges();
    this.PriorMenu();
  }

  protected func NextMenu() -> Void {
    this.SaveChanges();
    this.OnOutro();
  }

  protected cb func OnConfirmationClose(e: ref<inkPointerEvent>) -> Bool {
    if e.IsAction(n"click") {
      this.HideConfirmation();
      this.PlaySound(n"Button", n"OnPress");
    };
  }

  protected cb func OnConfirmationConfirm(e: ref<inkPointerEvent>) -> Bool {
    if e.IsAction(n"click") {
      this.NextMenu();
      this.PlaySound(n"Button", n"OnPress");
    };
  }

  protected cb func OnPreviousButton(e: ref<inkPointerEvent>) -> Bool {
    if e.IsAction(n"click") {
      this.PriorMenu();
      this.PlaySound(n"Button", n"OnPress");
    };
  }

  protected cb func OnRelease(e: ref<inkPointerEvent>) -> Bool {
    let target: wref<inkWidget> = e.GetTarget();
    if e.IsAction(n"click") {
      this.PlaySound(n"Button", n"OnPress");
      if target == inkWidgetRef.Get(this.m_reset) {
        this.ResetAllBtnBackToBaseline();
      };
      if target == inkWidgetRef.Get(this.m_nextPageHitArea) && StringToInt(inkTextRef.GetText(this.m_skillPointLabel)) == 0 {
        this.NextMenu();
      } else {
        if target == inkWidgetRef.Get(this.m_nextPageHitArea) && StringToInt(inkTextRef.GetText(this.m_skillPointLabel)) > 0 {
          this.ShowConfirmation();
        };
      };
    };
  }

  protected cb func OnValueIncremented(e: wref<inkWidget>) -> Bool {
    this.Add(e);
  }

  protected cb func OnValueDecremented(e: wref<inkWidget>) -> Bool {
    this.Subtract(e);
  }

  protected cb func OnShortcutPress(e: ref<inkPointerEvent>) -> Bool {
    if IsDefined(this.m_hoverdWidget) {
      if e.IsAction(n"option_switch_prev") {
        this.PlaySound(n"Button", n"OnPress");
        this.Subtract(this.m_hoverdWidget);
      } else {
        if e.IsAction(n"option_switch_next") {
          this.PlaySound(n"Button", n"OnPress");
          this.Add(this.m_hoverdWidget);
        };
      };
    };
  }

  private final func Add(targetWidget: wref<inkWidget>) -> Void {
    let tempController: wref<characterCreationStatsAttributeBtn> = targetWidget.GetController() as characterCreationStatsAttributeBtn;
    if this.CanBeIncremented(tempController.data.value) {
      tempController.data.SetValue(tempController.data.value + 1);
      tempController.Refresh();
      this.m_attributePointsAvailable -= 1;
      inkTextRef.SetText(this.m_skillPointLabel, ToString(this.m_attributePointsAvailable));
      this.RefreshPointsLabel();
      this.GetTelemetrySystem().LogInitialChoiceAttributeChanged(tempController.data.attribute);
      this.ManageAllButtonsVisibility();
      this.SetUpTooltipData(tempController);
      this.PlaySound(n"Button", n"OnPress");
    };
  }

  private final func Subtract(targetWidget: wref<inkWidget>) -> Void {
    let tempController: wref<characterCreationStatsAttributeBtn> = targetWidget.GetController() as characterCreationStatsAttributeBtn;
    if this.CanBeDecremented(tempController.data.value) {
      tempController.data.SetValue(tempController.data.value - 1);
      tempController.Refresh();
      this.m_attributePointsAvailable += 1;
      inkTextRef.SetText(this.m_skillPointLabel, ToString(this.m_attributePointsAvailable));
      this.RefreshPointsLabel();
      this.GetTelemetrySystem().LogInitialChoiceAttributeChanged(tempController.data.attribute);
      this.ManageAllButtonsVisibility();
      this.SetUpTooltipData(tempController);
      this.PlaySound(n"Button", n"OnPress");
    };
  }

  protected cb func OnHoverOverWidget(e: ref<inkPointerEvent>) -> Bool {
    let tempController: wref<characterCreationStatsAttributeBtn> = e.GetTarget().GetController() as characterCreationStatsAttributeBtn;
    if IsDefined(tempController) {
      this.m_hoverdWidget = e.GetTarget();
      inkWidgetRef.SetVisible(this.m_optionSwitchHint, true);
    };
  }

  protected cb func OnHoverOutWidget(e: ref<inkPointerEvent>) -> Bool {
    this.m_hoverdWidget = null;
    inkWidgetRef.SetVisible(this.m_optionSwitchHint, false);
  }

  private final func ManageAllButtonsVisibility() -> Void {
    let canBeDecremented: Bool;
    let canBeIncremented: Bool;
    let hasReachedTheLimit: Bool;
    let i: Int32 = 0;
    while i < ArraySize(this.m_attributesControllers) {
      canBeDecremented = this.CanBeDecremented(this.m_attributesControllers[i].data.value);
      canBeIncremented = this.CanBeIncremented(this.m_attributesControllers[i].data.value);
      hasReachedTheLimit = this.ReachedLimit(this.m_attributesControllers[i].data.value);
      this.m_attributesControllers[i].ManageBtnVisibility(canBeIncremented, canBeDecremented);
      this.m_attributesControllers[i].data.SetMaxed(!hasReachedTheLimit);
      this.m_attributesControllers[i].data.SetAtMinimum(!canBeDecremented);
      this.m_attributesControllers[i].ManageLabel(!canBeDecremented, !hasReachedTheLimit);
      i += 1;
    };
  }

  private final func CanBeIncremented(currValue: Int32) -> Bool {
    let maxLimit: Int32 = TweakDBInterface.GetInt(t"UICharacterCreationGeneral.BaseValues.maxAttributeValue", 0);
    return currValue < maxLimit && this.m_attributePointsAvailable > 0;
  }

  private final func ReachedLimit(currValue: Int32) -> Bool {
    let maxLimit: Int32 = TweakDBInterface.GetInt(t"UICharacterCreationGeneral.BaseValues.maxAttributeValue", 0);
    return currValue < maxLimit;
  }

  private final func CanBeDecremented(currValue: Int32) -> Bool {
    let minLimit: Int32 = TweakDBInterface.GetInt(t"UICharacterCreationGeneral.BaseValues.minAttributeValue", 0);
    return currValue > minLimit;
  }

  private final func FillAttributeData(label: String, value: Int32, desc: String) -> ref<CharacterCreationAttributeData> {
    let newItem: ref<CharacterCreationAttributeData> = new CharacterCreationAttributeData();
    newItem.label = label;
    newItem.value = value;
    newItem.desc = desc;
    return newItem;
  }

  private final func PrepareTooltips() -> Void {
    this.m_TooltipsManager = inkWidgetRef.GetControllerByType(this.m_TooltipsManagerRef, n"gameuiTooltipsManager") as gameuiTooltipsManager;
    this.m_TooltipsManager.Setup(ETooltipsStyle.Menus);
  }

  protected cb func OnBtnHoverOver(e: wref<inkWidget>) -> Bool {
    this.SetUpTooltipData(e.GetController() as characterCreationStatsAttributeBtn);
  }

  protected cb func OnBtnHoverOut(e: wref<inkWidget>) -> Bool {
    this.SetDefaultTooltip();
  }

  public final func SetDefaultTooltip() -> Void {
    let toolTipData: ref<CharacterCreationTooltipData> = new CharacterCreationTooltipData();
    toolTipData.Title = "LocKey#19686";
    toolTipData.Description = "LocKey#19687";
    toolTipData.attribiuteLevel = "";
    this.m_TooltipsManager.ShowTooltipInSlot(0, toolTipData, this.GetRootWidget());
  }

  public final func SetUpTooltipData(attribiuteController: wref<characterCreationStatsAttributeBtn>) -> Void {
    let toolTipData: ref<CharacterCreationTooltipData> = new CharacterCreationTooltipData();
    toolTipData.Title = attribiuteController.data.label;
    toolTipData.Description = attribiuteController.data.desc;
    toolTipData.attribiuteLevel = ToString(attribiuteController.data.value);
    if attribiuteController.data.maxed {
      toolTipData.maxedOrMinimumLabelText = "LocKey#42807";
    } else {
      if attribiuteController.data.atMinimum {
        toolTipData.maxedOrMinimumLabelText = "LocKey#42808";
      } else {
        toolTipData.maxedOrMinimumLabelText = "";
      };
    };
    this.m_TooltipsManager.ShowTooltipInSlot(0, toolTipData, this.GetRootWidget());
  }

  public final func PlayAnim(animName: CName, opt callBack: CName) -> Void {
    if IsDefined(this.m_animationProxy) && this.m_animationProxy.IsPlaying() {
      this.m_animationProxy.Stop();
    };
    this.m_animationProxy = this.PlayLibraryAnimation(animName);
    if NotEquals(callBack, n"") {
      this.m_animationProxy.RegisterToCallback(inkanimEventType.OnFinish, this, callBack);
    };
  }

  public final func RefreshPointsLabel() -> Void {
    if StringToInt(inkTextRef.GetText(this.m_skillPointLabel)) > 0 {
      inkWidgetRef.SetState(this.m_pointsLabel, n"PointsAvailable");
    } else {
      inkWidgetRef.SetState(this.m_pointsLabel, n"ZeroPoints");
    };
  }

  private final func OnIntro() -> Void {
    this.PlayAnim(n"intro");
  }

  private final func OnOutro() -> Void {
    this.PlayAnim(n"outro", n"OnOutroComplete");
  }

  protected cb func OnOutroComplete(anim: ref<inkAnimProxy>) -> Bool {
    this.NextMenu();
  }
}

public class CharacterCreationTooltip extends MessageTooltip {

  protected edit let m_attribiuteLevel: inkTextRef;

  protected edit let m_maxedOrMinimumLabelText: inkTextRef;

  protected edit let m_maxedOrMinimumLabel: inkWidgetRef;

  protected edit let m_attribiuteLevelLabel: inkWidgetRef;

  public func SetData(tooltipData: ref<ATooltipData>) -> Void {
    let messageData: ref<CharacterCreationTooltipData>;
    this.SetData(tooltipData);
    messageData = tooltipData as CharacterCreationTooltipData;
    if IsDefined(messageData) {
      inkTextRef.SetText(this.m_maxedOrMinimumLabelText, messageData.maxedOrMinimumLabelText);
      inkWidgetRef.SetVisible(this.m_maxedOrMinimumLabel, NotEquals(messageData.maxedOrMinimumLabelText, ""));
      inkTextRef.SetText(this.m_attribiuteLevel, messageData.attribiuteLevel);
      inkWidgetRef.SetVisible(this.m_attribiuteLevelLabel, NotEquals(messageData.attribiuteLevel, ""));
    };
  }
}
