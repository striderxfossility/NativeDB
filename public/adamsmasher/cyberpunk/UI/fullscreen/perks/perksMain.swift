
public class PerksMainGameController extends gameuiMenuGameController {

  private edit let m_tooltipsManagerRef: inkWidgetRef;

  private edit let m_buttonHintsManagerRef: inkWidgetRef;

  private edit let m_playerLevel: inkTextRef;

  private edit const let m_centerHiglightParts: array<inkWidgetRef>;

  private edit let m_attributeSelectorsContainer: inkWidgetRef;

  private edit let m_perksScreen: inkWidgetRef;

  private edit let m_pointsDisplay: inkWidgetRef;

  private edit let m_johnnyConnectorRef: inkWidgetRef;

  private edit let m_attributeTooltipHolderRight: inkWidgetRef;

  private edit let m_attributeTooltipHolderLeft: inkWidgetRef;

  private edit let m_respecButtonContainer: inkWidgetRef;

  private edit let m_cantRespecNotificationContainer: inkWidgetRef;

  private edit let m_resetPrice: inkTextRef;

  private edit let m_spentPerks: inkTextRef;

  private let m_activeScreen: CharacterScreenType;

  private let m_tooltipsManager: wref<gameuiTooltipsManager>;

  private let m_buttonHintsController: wref<ButtonHints>;

  private let m_dataManager: ref<PlayerDevelopmentDataManager>;

  private let m_menuEventDispatcher: wref<inkMenuEventDispatcher>;

  private let m_perksMenuItemCreatedQueue: array<ref<PerksMenuAttributeItemCreated>>;

  private let m_attributesControllersList: array<wref<PerksMenuAttributeItemController>>;

  private let m_playerStatsBlackboard: wref<IBlackboard>;

  private let m_characterLevelListener: ref<CallbackHandle>;

  private let m_perksScreenController: wref<PerkScreenController>;

  private let m_pointsDisplayController: wref<PerksPointsDisplayController>;

  private let m_questSystem: wref<QuestsSystem>;

  private let m_resetConfirmationToken: ref<inkGameNotificationToken>;

  private let m_inCombat: Bool;

  private let enoughMoneyForRespec: Bool;

  private let m_cantRespecAnim: ref<inkAnimProxy>;

  private let m_lastHoveredAttribute: PerkMenuAttribute;

  protected cb func OnInitialize() -> Bool {
    let refreshAreas: ref<RefreshPerkAreas>;
    this.m_perksScreenController = inkWidgetRef.GetController(this.m_perksScreen) as PerkScreenController;
    this.m_pointsDisplayController = inkWidgetRef.GetController(this.m_pointsDisplay) as PerksPointsDisplayController;
    this.m_dataManager = new PlayerDevelopmentDataManager();
    this.m_dataManager.Initialize(GameInstance.GetPlayerSystem(this.GetPlayerControlledObject().GetGame()).GetLocalPlayerMainGameObject() as PlayerPuppet, this);
    this.m_buttonHintsController = this.SpawnFromExternal(inkWidgetRef.Get(this.m_buttonHintsManagerRef), r"base\\gameplay\\gui\\common\\buttonhints.inkwidget", n"Root").GetController() as ButtonHints;
    this.m_buttonHintsController.AddButtonHint(n"back", GetLocalizedText("Common-Access-Close"));
    this.m_playerStatsBlackboard = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UI_PlayerStats);
    this.m_characterLevelListener = this.m_playerStatsBlackboard.RegisterDelayedListenerInt(GetAllBlackboardDefs().UI_PlayerStats.Level, this, n"OnCharacterLevelUpdated", true);
    this.m_inCombat = this.m_dataManager.GetPlayer().GetPlayerStateMachineBlackboard().GetInt(GetAllBlackboardDefs().PlayerStateMachine.Combat) == EnumInt(gamePSMCombat.InCombat);
    this.PrepareTooltips();
    this.SetupLayout();
    this.ResetData();
    this.HandleEventQueue();
    this.ResetHighlightPartsVisibility();
    refreshAreas = new RefreshPerkAreas();
    refreshAreas.Set(this.m_dataManager.GetPlayer());
    this.m_dataManager.GetPlayerDevelopmentSystem().QueueRequest(refreshAreas);
    inkWidgetRef.RegisterToCallback(this.m_respecButtonContainer, n"OnRelease", this, n"OnResetPerksClick");
    inkWidgetRef.RegisterToCallback(this.m_respecButtonContainer, n"OnHoverOver", this, n"OnResetPerksHoverOver");
    inkWidgetRef.RegisterToCallback(this.m_respecButtonContainer, n"OnHoverOut", this, n"OnResetPerksHoverOut");
  }

  protected cb func OnUnitialize() -> Bool {
    this.m_playerStatsBlackboard.UnregisterDelayedListener(GetAllBlackboardDefs().UI_PlayerStats.Level, this.m_characterLevelListener);
    inkWidgetRef.UnregisterFromCallback(this.m_respecButtonContainer, n"OnRelease", this, n"OnResetPerksClick");
    inkWidgetRef.UnregisterFromCallback(this.m_respecButtonContainer, n"OnHoverOver", this, n"OnResetPerksHoverOver");
    inkWidgetRef.UnregisterFromCallback(this.m_respecButtonContainer, n"OnHoverOut", this, n"OnResetPerksHoverOut");
  }

  protected cb func OnCharacterLevelUpdated(value: Int32) -> Bool {
    inkTextRef.SetText(this.m_playerLevel, IntToString(value));
  }

  protected final func ResetHighlightPartsVisibility() -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_centerHiglightParts) {
      inkWidgetRef.SetOpacity(this.m_centerHiglightParts[i], 0.00);
      i += 1;
    };
  }

  protected final func HandleEventQueue() -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_perksMenuItemCreatedQueue) {
      this.OnPerksMenuAttributeItemCreated(this.m_perksMenuItemCreatedQueue[i]);
      i += 1;
    };
  }

  protected cb func OnPlayerAttach(playerPuppet: ref<GameObject>) -> Bool {
    this.m_questSystem = GameInstance.GetQuestsSystem(playerPuppet.GetGame());
    this.CheckJohnnyFact();
  }

  private final func CheckJohnnyFact() -> Void {
    let attributeController: ref<PerksMenuAttributeItemController>;
    let hasJohnny: Bool;
    let i: Int32;
    if IsDefined(this.m_questSystem) {
      hasJohnny = this.m_questSystem.GetFact(n"q005_johnny_chip_acquired") == 1;
      i = 0;
      while i < ArraySize(this.m_attributesControllersList) {
        attributeController = this.m_attributesControllersList[i];
        if Equals(attributeController.GetAttributeType(), PerkMenuAttribute.Johnny) {
          attributeController.GetRootWidget().SetVisible(hasJohnny);
          inkWidgetRef.SetVisible(this.m_johnnyConnectorRef, !hasJohnny);
        };
        i += 1;
      };
    };
  }

  protected cb func OnPerksMenuAttributeItemCreated(evt: ref<PerksMenuAttributeItemCreated>) -> Bool {
    if IsDefined(this.m_dataManager) {
      evt.perksMenuAttributeItem.Setup(this.m_dataManager);
      ArrayPush(this.m_attributesControllersList, evt.perksMenuAttributeItem);
    } else {
      ArrayPush(this.m_perksMenuItemCreatedQueue, evt);
    };
    this.CheckJohnnyFact();
  }

  protected cb func OnUninitialize() -> Bool {
    this.m_menuEventDispatcher.UnregisterFromEvent(n"OnBack", this, n"OnBack");
  }

  protected cb func OnSetMenuEventDispatcher(menuEventDispatcher: wref<inkMenuEventDispatcher>) -> Bool {
    this.m_menuEventDispatcher = menuEventDispatcher;
    this.m_menuEventDispatcher.RegisterToEvent(n"OnBack", this, n"OnBack");
  }

  protected cb func OnBack(userData: ref<IScriptable>) -> Bool {
    switch this.m_activeScreen {
      case CharacterScreenType.Perks:
        this.SetActiveScreen(CharacterScreenType.Attributes);
        break;
      case CharacterScreenType.Attributes:
        if !StatusEffectSystem.ObjectHasStatusEffectWithTag(this.GetPlayerControlledObject(), n"LockInHubMenu") {
          this.m_menuEventDispatcher.SpawnEvent(n"OnCloseHubMenu");
        };
    };
  }

  private final func SetupLayout() -> Void {
    this.SetActiveScreen(CharacterScreenType.Attributes);
  }

  protected cb func OnAttributeHoverOver(evt: ref<PerksMenuAttributeItemHoverOver>) -> Bool {
    let tooltipHolder: inkWidgetRef;
    switch evt.attributeType {
      case PerkMenuAttribute.Intelligence:
      case PerkMenuAttribute.Body:
      case PerkMenuAttribute.Reflex:
        tooltipHolder = this.m_attributeTooltipHolderRight;
        break;
      case PerkMenuAttribute.Johnny:
      case PerkMenuAttribute.Cool:
      case PerkMenuAttribute.Technical_Ability:
        tooltipHolder = this.m_attributeTooltipHolderLeft;
        break;
      default:
        tooltipHolder = this.m_attributeTooltipHolderRight;
    };
    this.PlayHoverAnimation(true);
    this.SetAttributeBuyButtonHintHoverOver(evt.attributeData);
    this.ShowTooltip(inkWidgetRef.Get(tooltipHolder), evt.attributeData, gameuiETooltipPlacement.RightCenter);
    this.m_lastHoveredAttribute = evt.attributeType;
  }

  protected cb func OnAttributeHoverOut(evt: ref<PerksMenuAttributeItemHoverOut>) -> Bool {
    if Equals(this.m_lastHoveredAttribute, evt.attributeType) {
      this.PlayHoverAnimation(false);
      this.SetAttributeBuyButtonHintHoverOut();
      this.HideTooltip();
    };
  }

  protected cb func OnAttributeHoldStart(evt: ref<PerksMenuAttributeItemHoldStart>) -> Bool {
    if evt.actionName.IsAction(n"upgrade_attribute") {
      this.PlaySound(n"Attributes", n"OnStart");
    };
    if evt.actionName.IsAction(n"upgrade_attribute") && !this.m_dataManager.HasAvailableAttributePoints(true) {
      this.SetCursorContext(n"InvalidAction");
    };
  }

  protected cb func OnAttributeClicked(evt: ref<PerksMenuAttributeItemClicked>) -> Bool {
    let data: ref<AttributeDisplayData>;
    if NotEquals(evt.attributeType, PerkMenuAttribute.Johnny) {
      data = this.m_dataManager.GetAttributeData(evt.attributeData.id);
      this.m_perksScreenController.Setup(data, this.m_dataManager, 0);
      this.SetActiveScreen(CharacterScreenType.Perks);
    };
  }

  protected cb func OnProficiencyClicked(evt: ref<PerksMenuProficiencyItemClicked>) -> Bool {
    let data: ref<AttributeDisplayData>;
    if NotEquals(evt.attributeType, PerkMenuAttribute.Johnny) {
      data = this.m_dataManager.GetAttributeData(evt.attributeData.id);
      this.m_perksScreenController.Setup(data, this.m_dataManager, evt.index);
      this.SetActiveScreen(CharacterScreenType.Perks);
    };
  }

  protected cb func OnAttributePurchaseRequest(evt: ref<AttributeUpgradePurchased>) -> Bool {
    this.m_dataManager.UpgradeAttribute(evt.attributeData);
  }

  protected cb func OnAttributePurchased(evt: ref<AttributeBoughtEvent>) -> Bool {
    if NotEquals(evt.attributeType, gamedataStatType.Invalid) {
      this.PlaySound(n"Attributes", n"OnDone");
    } else {
      this.PlaySound(n"Attributes", n"OnFail");
    };
  }

  protected cb func OnPerkHoverOver(evt: ref<PerkHoverOverEvent>) -> Bool {
    this.SetPerksButtonHintHoverOver(evt.perkData);
    this.ShowTooltip(evt.widget, evt.perkData);
  }

  protected cb func OnPerkHoverOut(evt: ref<PerkHoverOutEvent>) -> Bool {
    this.SetPerksButtonHintHoverOut();
    this.HideTooltip();
  }

  protected cb func OnPerkHoldStart(evt: ref<PerksItemHoldStart>) -> Bool {
    this.PlaySound(n"Attributes", n"OnStart");
    if (evt.actionName.IsAction(n"upgrade_attribute") || evt.actionName.IsAction(n"use_item") || evt.actionName.IsAction(n"click")) && !this.m_dataManager.IsPerkUpgradeable(evt.perkData, true) {
      this.SetCursorContext(n"InvalidAction");
      this.PlaySound(n"Attributes", n"OnFail");
    };
  }

  protected cb func OnPerkPurchased(evt: ref<PerkBoughtEvent>) -> Bool {
    if NotEquals(evt.perkType, gamedataPerkType.Invalid) {
      this.PlaySound(n"Attributes", n"OnDone");
    } else {
      this.PlaySound(n"Attributes", n"OnFail");
    };
  }

  protected cb func OnPlayerDevUpdateData(evt: ref<PlayerDevUpdateDataEvent>) -> Bool {
    let attributes: array<ref<AttributeData>>;
    let i: Int32;
    let j: Int32;
    this.UpdateAvailablePoints();
    attributes = this.m_dataManager.GetAttributes();
    i = 0;
    while i < ArraySize(attributes) {
      j = 0;
      while j < ArraySize(this.m_attributesControllersList) {
        if Equals(this.m_attributesControllersList[j].GetStatType(), attributes[i].type) {
          this.m_attributesControllersList[j].UpdateData(attributes[i]);
        } else {
          j += 1;
        };
      };
      i += 1;
    };
    this.m_tooltipsManager.RefreshTooltip(0);
    this.m_tooltipsManager.RefreshTooltip(n"perkTooltip");
  }

  protected cb func OnActiveSkillScreenChanged(e: ref<ActiveSkillScreenChangedEvent>) -> Bool {
    this.UpdateAvailablePoints();
  }

  protected cb func OnBackClick(controller: wref<inkButtonController>) -> Bool {
    this.SetActiveScreen(CharacterScreenType.Attributes);
  }

  public final func SetRespecButton(visible: Bool) -> Void {
    let spentPerkPoints: Int32;
    if !visible {
      inkWidgetRef.SetVisible(this.m_respecButtonContainer, false);
      return;
    };
    spentPerkPoints = this.m_dataManager.GetSpentPerkPoints() + this.m_dataManager.GetSpentTraitPoints();
    inkWidgetRef.SetVisible(this.m_respecButtonContainer, spentPerkPoints > 0);
    inkTextRef.SetText(this.m_spentPerks, IntToString(spentPerkPoints));
    inkTextRef.SetText(this.m_resetPrice, IntToString(this.m_dataManager.GetTotalRespecCost()));
    this.enoughMoneyForRespec = this.m_dataManager.CheckRespecCost();
    if this.m_inCombat || !this.enoughMoneyForRespec {
      inkWidgetRef.SetState(this.m_respecButtonContainer, n"Disable");
    } else {
      inkWidgetRef.SetState(this.m_respecButtonContainer, n"Default");
    };
  }

  protected cb func OnResetPerksHoverOver(evt: ref<inkPointerEvent>) -> Bool {
    if !this.m_inCombat && this.enoughMoneyForRespec {
      inkWidgetRef.SetState(this.m_respecButtonContainer, n"Hover");
    } else {
      inkWidgetRef.SetVisible(this.m_cantRespecNotificationContainer, true);
      if IsDefined(this.m_cantRespecAnim) {
        this.m_cantRespecAnim.Stop();
      };
      this.m_cantRespecAnim = this.PlayLibraryAnimationOnTargets(n"tooltip_in", SelectWidgets(inkWidgetRef.Get(this.m_cantRespecNotificationContainer)));
    };
  }

  protected cb func OnResetPerksHoverOut(evt: ref<inkPointerEvent>) -> Bool {
    if !this.m_inCombat && this.enoughMoneyForRespec {
      inkWidgetRef.SetState(this.m_respecButtonContainer, n"Default");
    } else {
      inkWidgetRef.SetVisible(this.m_cantRespecNotificationContainer, false);
    };
  }

  protected cb func OnResetPerksClick(evt: ref<inkPointerEvent>) -> Bool {
    let vendorNotification: ref<UIMenuNotificationEvent>;
    if evt.IsAction(n"click") {
      if this.m_inCombat {
        vendorNotification = new UIMenuNotificationEvent();
        vendorNotification.m_notificationType = UIMenuNotificationType.InventoryActionBlocked;
        this.QueueEvent(vendorNotification);
      } else {
        if this.m_dataManager.CheckRespecCost() {
          this.m_resetConfirmationToken = GenericMessageNotification.Show(this, "UI-Menus-Perks-ResetPerks", "UI-Menus-Perks-ResetConfirmation", GenericMessageNotificationType.YesNo);
          this.m_resetConfirmationToken.RegisterListener(this, n"OnResetConfirmed");
        } else {
          vendorNotification = new UIMenuNotificationEvent();
          vendorNotification.m_notificationType = UIMenuNotificationType.VNotEnoughMoney;
          this.QueueEvent(vendorNotification);
        };
      };
    };
  }

  protected cb func OnResetConfirmed(data: ref<inkGameNotificationData>) -> Bool {
    let removeAllPerks: ref<RemoveAllPerks>;
    let resultData: ref<GenericMessageNotificationCloseData> = data as GenericMessageNotificationCloseData;
    this.m_resetConfirmationToken = null;
    if IsDefined(resultData) && Equals(resultData.result, GenericMessageNotificationResult.Yes) {
      removeAllPerks = new RemoveAllPerks();
      removeAllPerks.Set(this.m_dataManager.GetPlayer());
      PlayerDevelopmentSystem.GetInstance(this.m_dataManager.GetPlayer()).QueueRequest(removeAllPerks);
    };
  }

  protected cb func OnPerkResetEvent(evt: ref<PerkResetEvent>) -> Bool {
    this.UpdateAvailablePoints();
  }

  private final func ResetData() -> Void {
    this.SetupLayout();
    this.UpdateAvailablePoints();
  }

  private final func SetActiveScreen(screenType: CharacterScreenType) -> Void {
    this.m_activeScreen = screenType;
    let isPerksScreen: Bool = Equals(this.m_activeScreen, CharacterScreenType.Perks);
    this.m_pointsDisplayController.Setup(this.m_activeScreen);
    this.UpdateAvailablePoints();
    inkWidgetRef.SetVisible(this.m_attributeSelectorsContainer, !isPerksScreen);
    inkWidgetRef.SetVisible(this.m_perksScreen, isPerksScreen);
    this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UI_TopbarHubMenu).SetBool(GetAllBlackboardDefs().UI_TopbarHubMenu.IsSubmenuHidden, isPerksScreen, true);
    this.m_perksScreenController.PlayLibraryAnimation(n"start_perk_screen");
    if !isPerksScreen {
      this.PlayLibraryAnimation(n"panel_intro");
    };
  }

  private final func UpdateAvailablePoints() -> Void {
    let developmentData: ref<PlayerDevelopmentData>;
    let proficiencyType: gamedataProficiencyType;
    switch this.m_activeScreen {
      case CharacterScreenType.Attributes:
        this.m_pointsDisplayController.SetValues(this.m_dataManager.GetAttributePoints(), this.m_dataManager.GetPerkPoints());
        this.SetRespecButton(true);
        break;
      case CharacterScreenType.Perks:
        developmentData = PlayerDevelopmentSystem.GetData(this.m_dataManager.GetPlayer());
        proficiencyType = this.m_perksScreenController.GetProficiencyDisplayData().m_proficiency;
        this.m_pointsDisplayController.SetValues(developmentData.GetInvestedPerkPoints(proficiencyType), this.m_dataManager.GetPerkPoints());
        this.SetRespecButton(false);
    };
  }

  private final func PrepareTooltips() -> Void {
    this.m_tooltipsManager = inkWidgetRef.GetControllerByType(this.m_tooltipsManagerRef, n"gameuiTooltipsManager") as gameuiTooltipsManager;
    this.m_tooltipsManager.Setup(ETooltipsStyle.Menus);
  }

  private final func ShowTooltip(widget: wref<inkWidget>, data: ref<IDisplayData>, opt placement: gameuiETooltipPlacement) -> Void {
    let tooltipData: ref<BasePerksMenuTooltipData> = data.CreateTooltipData(this.m_dataManager);
    if tooltipData == null {
      return;
    };
    if data.IsA(n"PerkDisplayData") || data.IsA(n"TraitDisplayData") {
      this.m_tooltipsManager.ShowTooltipAtWidget(n"perkTooltip", widget, tooltipData, placement);
    } else {
      this.m_tooltipsManager.ShowTooltipAtWidget(0, widget, tooltipData, placement);
    };
  }

  private final func HideTooltip() -> Void {
    this.m_tooltipsManager.HideTooltips();
  }

  private final func SetAttributeHintsHoverOver() -> Void {
    this.m_buttonHintsController.AddButtonHint(n"select", GetLocalizedText("Common-Access-Select"));
  }

  private final func SetAttributeHintsHoverOut() -> Void {
    this.m_buttonHintsController.RemoveButtonHint(n"select");
  }

  private final func SetPerksButtonHintHoverOver(data: ref<BasePerkDisplayData>) -> Void {
    let cursorData: ref<MenuCursorUserData> = new MenuCursorUserData();
    cursorData.SetAnimationOverride(n"hoverOnHoldToComplete");
    if this.m_dataManager.IsPerkUpgradeable(data) {
      this.m_buttonHintsController.AddButtonHint(n"upgrade_perk", "[" + GetLocalizedText("Gameplay-Devices-Interactions-Helpers-Hold") + "] " + GetLocalizedText("UI-ScriptExports-Buy0"));
      cursorData.AddAction(n"upgrade_perk");
    };
    if cursorData.GetActionsListSize() >= 0 {
      this.SetCursorContext(n"Hover", cursorData);
    } else {
      this.SetCursorContext(n"Hover");
    };
  }

  private final func SetPerksButtonHintHoverOut() -> Void {
    this.m_buttonHintsController.RemoveButtonHint(n"select");
    this.m_buttonHintsController.RemoveButtonHint(n"upgrade_perk");
  }

  private final func SetAttributeBuyButtonHintHoverOver(data: ref<AttributeData>) -> Void {
    let cursorData: ref<MenuCursorUserData> = new MenuCursorUserData();
    cursorData.SetAnimationOverride(n"hoverOnHoldToComplete");
    cursorData.AddAction(n"upgrade_attribute");
    if this.m_dataManager.HasAvailableAttributePoints() {
      this.m_buttonHintsController.AddButtonHint(n"upgrade_perk", "(" + GetLocalizedText("Gameplay-Devices-Interactions-Helpers-Hold") + ") " + GetLocalizedText("UI-ScriptExports-Buy0"));
      this.SetCursorContext(n"Hover", cursorData);
    } else {
      this.SetCursorContext(n"Hover");
    };
  }

  private final func SetAttributeBuyButtonHintHoverOut() -> Void {
    this.m_buttonHintsController.RemoveButtonHint(n"upgrade_perk");
  }

  protected final func PlayHoverAnimation(value: Bool) -> Void {
    let i: Int32;
    let transparencyAnimation: ref<inkAnimDef> = new inkAnimDef();
    let transparencyInterpolator: ref<inkAnimTransparency> = new inkAnimTransparency();
    transparencyInterpolator.SetDuration(0.35);
    transparencyInterpolator.SetDirection(inkanimInterpolationDirection.To);
    transparencyInterpolator.SetType(inkanimInterpolationType.Linear);
    transparencyInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
    transparencyInterpolator.SetEndTransparency(value ? 1.00 : 0.00);
    transparencyAnimation.AddInterpolator(transparencyInterpolator);
    i = 0;
    while i < ArraySize(this.m_centerHiglightParts) {
      inkWidgetRef.PlayAnimation(this.m_centerHiglightParts[i], transparencyAnimation);
      i += 1;
    };
  }
}
