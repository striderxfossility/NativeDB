
public class PerksMenuAttributeItemController extends inkLogicController {

  protected edit let m_attributeDisplay: inkWidgetRef;

  protected edit let m_connectionLine: inkImageRef;

  protected edit let m_attributeType: PerkMenuAttribute;

  protected edit let m_skillsLevelsContainer: inkCompoundRef;

  protected edit const let m_proficiencyButtonRefs: array<inkWidgetRef>;

  protected edit let m_isReversed: Bool;

  protected let m_dataManager: ref<PlayerDevelopmentDataManager>;

  protected let m_attributeDisplayController: wref<PerksMenuAttributeDisplayController>;

  protected let m_recentlyPurchased: Bool;

  protected let m_holdStarted: Bool;

  protected let m_data: ref<AttributeData>;

  protected let m_cool_in_proxy: ref<inkAnimProxy>;

  protected let m_cool_out_proxy: ref<inkAnimProxy>;

  protected cb func OnInitialize() -> Bool {
    let perkButtonController: ref<ProficiencyButtonController>;
    let perksMenuAttributeItemCreated: ref<PerksMenuAttributeItemCreated>;
    let i: Int32 = 0;
    while i < ArraySize(this.m_proficiencyButtonRefs) {
      perkButtonController = inkWidgetRef.GetController(this.m_proficiencyButtonRefs[i]) as ProficiencyButtonController;
      perkButtonController.SetIndex(i);
      perkButtonController.RegisterToCallback(n"OnButtonClick", this, n"OnProficiencyClicked");
      i += 1;
    };
    this.m_attributeDisplayController = inkWidgetRef.GetController(this.m_attributeDisplay) as PerksMenuAttributeDisplayController;
    this.m_attributeDisplayController.RegisterToCallback(n"OnHold", this, n"OnAttributeItemHold");
    this.m_attributeDisplayController.RegisterToCallback(n"OnRelease", this, n"OnAttributeItemClicked");
    this.m_attributeDisplayController.RegisterToCallback(n"OnHoverOver", this, n"OnAttributeItemHoverOver");
    this.m_attributeDisplayController.RegisterToCallback(n"OnHoverOut", this, n"OnAttributeItemHoverOut");
    this.RegisterToCallback(n"OnEnter", this, n"OnContainerHoverOver");
    this.RegisterToCallback(n"OnLeave", this, n"OnContainerHoverOut");
    inkWidgetRef.SetOpacity(this.m_connectionLine, 0.00);
    perksMenuAttributeItemCreated = new PerksMenuAttributeItemCreated();
    perksMenuAttributeItemCreated.perksMenuAttributeItem = this;
    this.QueueEvent(perksMenuAttributeItemCreated);
    this.ShowProficiencyButton(false);
  }

  public final func Setup(dataManager: ref<PlayerDevelopmentDataManager>) -> Void {
    this.m_dataManager = dataManager;
    this.m_attributeDisplayController.Setup(this.m_attributeType, dataManager);
    this.m_data = dataManager.GetAttribute(this.m_dataManager.GetAttributeRecordIDFromEnum(this.m_attributeType));
    this.SetupProficiencyButtons(this.m_data);
  }

  public final func GetStatType() -> gamedataStatType {
    return this.m_attributeDisplayController.GetStatType();
  }

  public final func GetAttributeType() -> PerkMenuAttribute {
    return this.m_attributeType;
  }

  public final func UpdateData(attributeData: ref<AttributeData>) -> Void {
    this.m_attributeDisplayController.UpdateData(attributeData);
    this.SetupProficiencyButtons(attributeData);
  }

  protected final func SetupProficiencyButtons(attributeData: ref<AttributeData>) -> Void {
    let perkButtonController: ref<ProficiencyButtonController>;
    let attributeDisplayData: ref<AttributeDisplayData> = this.m_dataManager.GetAttributeData(attributeData.id);
    let proficiencies: array<ref<ProficiencyDisplayData>> = attributeDisplayData.m_proficiencies;
    let dataCount: Int32 = ArraySize(proficiencies);
    let i: Int32 = 0;
    while i < ArraySize(this.m_proficiencyButtonRefs) && i < dataCount {
      perkButtonController = inkWidgetRef.GetController(this.m_proficiencyButtonRefs[i]) as ProficiencyButtonController;
      perkButtonController.SetLabel(proficiencies[i].m_localizedName);
      perkButtonController.SetLevel(proficiencies[i].m_level);
      i += 1;
    };
  }

  protected cb func OnAttributeItemClicked(evt: ref<inkPointerEvent>) -> Bool {
    let perksMenuAttributeItemClickedEvent: ref<PerksMenuAttributeItemClicked>;
    this.m_holdStarted = false;
    if evt.IsAction(n"select") {
      perksMenuAttributeItemClickedEvent = new PerksMenuAttributeItemClicked();
      perksMenuAttributeItemClickedEvent.widget = this.GetRootWidget();
      perksMenuAttributeItemClickedEvent.attributeType = this.m_attributeType;
      perksMenuAttributeItemClickedEvent.attributeData = this.m_attributeDisplayController.GetAttributeData();
      this.QueueEvent(perksMenuAttributeItemClickedEvent);
    };
  }

  protected cb func OnProficiencyClicked(controller: wref<inkButtonController>) -> Bool {
    let profCtrl: wref<ProficiencyButtonController> = controller as ProficiencyButtonController;
    let toSend: ref<PerksMenuProficiencyItemClicked> = new PerksMenuProficiencyItemClicked();
    toSend.widget = profCtrl.GetRootWidget();
    toSend.attributeType = this.m_attributeType;
    toSend.attributeData = this.m_attributeDisplayController.GetAttributeData();
    toSend.index = profCtrl.GetIndex();
    this.QueueEvent(toSend);
  }

  protected cb func OnAttributeItemHold(evt: ref<inkPointerEvent>) -> Bool {
    let holdStartEvent: ref<PerksMenuAttributeItemHoldStart>;
    let upgradeEvent: ref<AttributeUpgradePurchased>;
    let progress: Float = evt.GetHoldProgress();
    if progress > 0.00 && !this.m_holdStarted {
      holdStartEvent = new PerksMenuAttributeItemHoldStart();
      holdStartEvent.widget = this.GetRootWidget();
      holdStartEvent.attributeType = this.m_attributeType;
      holdStartEvent.attributeData = this.m_attributeDisplayController.GetAttributeData();
      holdStartEvent.actionName = evt.GetActionName();
      this.QueueEvent(holdStartEvent);
      this.m_holdStarted = true;
      if evt.IsAction(n"upgrade_attribute") {
        if !this.m_data.availableToUpgrade || !this.m_dataManager.HasAvailableAttributePoints() {
          this.m_attributeDisplayController.PlayAnimation(this.m_isReversed ? n"locked_attribute_reverse" : n"locked_attribute");
        };
      };
    };
    if progress >= 1.00 {
      if evt.IsAction(n"upgrade_attribute") {
        if !this.m_recentlyPurchased {
          this.m_recentlyPurchased = true;
          upgradeEvent = new AttributeUpgradePurchased();
          upgradeEvent.attributeType = this.m_attributeType;
          upgradeEvent.attributeData = this.m_attributeDisplayController.GetAttributeData();
          this.QueueEvent(upgradeEvent);
          if this.m_data.availableToUpgrade && this.m_dataManager.HasAvailableAttributePoints() {
            this.m_attributeDisplayController.PlayAnimation(this.m_isReversed ? n"buy_attribute_reverse" : n"buy_attribute");
            this.PlayLibraryAnimation(n"buy_wire_anim");
          };
        };
      };
    } else {
      this.m_recentlyPurchased = false;
    };
  }

  protected cb func OnContainerHoverOver(evt: ref<inkPointerEvent>) -> Bool {
    this.ShowProficiencyButton(true);
  }

  protected cb func OnContainerHoverOut(evt: ref<inkPointerEvent>) -> Bool {
    this.ShowProficiencyButton(false);
  }

  protected cb func OnAttributeItemHoverOver(evt: ref<inkPointerEvent>) -> Bool {
    this.ShowProficiencyButton(true);
  }

  protected cb func OnAttributeItemHoverOut(evt: ref<inkPointerEvent>) -> Bool;

  protected final func PlayConnectionAnimation(value: Bool) -> Void {
    let transparencyAnimation: ref<inkAnimDef> = new inkAnimDef();
    let transparencyInterpolator: ref<inkAnimTransparency> = new inkAnimTransparency();
    transparencyInterpolator.SetDuration(0.35);
    transparencyInterpolator.SetDirection(inkanimInterpolationDirection.To);
    transparencyInterpolator.SetType(inkanimInterpolationType.Linear);
    transparencyInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
    transparencyInterpolator.SetEndTransparency(value ? 1.00 : 0.00);
    transparencyAnimation.AddInterpolator(transparencyInterpolator);
    inkWidgetRef.PlayAnimation(this.m_connectionLine, transparencyAnimation);
  }

  private final func StopHoverAnimations() -> Void {
    if IsDefined(this.m_cool_in_proxy) {
      this.m_cool_in_proxy.Stop();
    };
    if IsDefined(this.m_cool_out_proxy) {
      this.m_cool_out_proxy.Stop();
    };
  }

  private final func ShowProficiencyButton(value: Bool) -> Void {
    let hoverOutEvent: ref<PerksMenuAttributeItemHoverOut>;
    let hoverOverEvent: ref<PerksMenuAttributeItemHoverOver>;
    let count: Int32 = ArraySize(this.m_proficiencyButtonRefs);
    let i: Int32 = 0;
    while i < count {
      inkWidgetRef.SetVisible(this.m_proficiencyButtonRefs[i], value);
      i += 1;
    };
    if value {
      this.m_attributeDisplayController.SetHovered(true);
      this.PlayConnectionAnimation(true);
      hoverOverEvent = new PerksMenuAttributeItemHoverOver();
      hoverOverEvent.widget = this.GetRootWidget();
      hoverOverEvent.attributeType = this.m_attributeType;
      hoverOverEvent.attributeData = this.m_attributeDisplayController.GetAttributeData();
      this.QueueEvent(hoverOverEvent);
      this.StopHoverAnimations();
      this.m_cool_in_proxy = this.m_attributeDisplayController.PlayAnimation(this.m_isReversed ? n"cool_attribute_hover_in_reverse" : n"cool_attribute_hover_in");
    } else {
      this.m_attributeDisplayController.SetHovered(false);
      this.PlayConnectionAnimation(false);
      hoverOutEvent = new PerksMenuAttributeItemHoverOut();
      hoverOutEvent.widget = this.GetRootWidget();
      hoverOutEvent.attributeType = this.m_attributeType;
      hoverOutEvent.attributeData = this.m_attributeDisplayController.GetAttributeData();
      this.QueueEvent(hoverOutEvent);
      this.StopHoverAnimations();
      this.m_cool_out_proxy = this.m_attributeDisplayController.PlayAnimation(this.m_isReversed ? n"cool_attribute_hover_out_reverse" : n"cool_attribute_hover_out");
    };
  }
}

public class ProficiencyButtonController extends inkButtonController {

  private edit let m_labelText: inkTextRef;

  private edit let m_levelText: inkTextRef;

  private edit let m_frameHovered: inkWidgetRef;

  private let m_transparencyAnimationProxy: ref<inkAnimProxy>;

  private let m_index: Int32;

  protected cb func OnInitialize() -> Bool {
    this.RegisterToCallback(n"OnButtonStateChanged", this, n"OnButtonStateChanged");
  }

  public final func SetLabel(value: String) -> Void {
    inkTextRef.SetText(this.m_labelText, value);
  }

  public final func SetLevel(value: Int32) -> Void {
    let levelParams: ref<inkTextParams> = new inkTextParams();
    levelParams.AddNumber("level", value);
    inkTextRef.SetTextParameters(this.m_levelText, levelParams);
  }

  public final func SetIndex(value: Int32) -> Void {
    this.m_index = value;
  }

  public final func GetIndex() -> Int32 {
    return this.m_index;
  }

  protected cb func OnButtonStateChanged(controller: wref<inkButtonController>, oldState: inkEButtonState, newState: inkEButtonState) -> Bool {
    switch newState {
      case inkEButtonState.Normal:
        this.PlaySelectionAnimation(false);
        break;
      case inkEButtonState.Hover:
        this.PlaySelectionAnimation(true);
        break;
      case inkEButtonState.Press:
        this.PlaySound(n"Button", n"OnPress");
        break;
      case inkEButtonState.Disabled:
    };
  }

  private final func PlaySelectionAnimation(value: Bool) -> Void {
    let transparencyAnimation: ref<inkAnimDef> = new inkAnimDef();
    let transparencyInterpolator: ref<inkAnimTransparency> = new inkAnimTransparency();
    transparencyInterpolator.SetDuration(0.35);
    transparencyInterpolator.SetDirection(inkanimInterpolationDirection.To);
    transparencyInterpolator.SetType(inkanimInterpolationType.Linear);
    transparencyInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
    transparencyInterpolator.SetEndTransparency(value ? 1.00 : 0.00);
    transparencyAnimation.AddInterpolator(transparencyInterpolator);
    if IsDefined(this.m_transparencyAnimationProxy) && this.m_transparencyAnimationProxy.IsPlaying() {
      this.m_transparencyAnimationProxy.Stop();
    };
    this.m_transparencyAnimationProxy = inkWidgetRef.PlayAnimation(this.m_frameHovered, transparencyAnimation);
  }
}
