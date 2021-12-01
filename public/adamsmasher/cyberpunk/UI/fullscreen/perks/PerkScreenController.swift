
public class PerkScreenController extends inkLogicController {

  protected edit let m_hubSelector: inkWidgetRef;

  protected edit let m_connectionLinesContainer: inkCompoundRef;

  protected edit let m_boughtConnectionLinesContainer: inkCompoundRef;

  protected edit let m_maxedConnectionLinesContainer: inkCompoundRef;

  protected edit let m_boughtMaskContainer: inkCanvasRef;

  protected edit let m_maxedMaskContainer: inkCanvasRef;

  protected edit let m_attributeNameText: inkTextRef;

  protected edit let m_attributeLevelText: inkTextRef;

  protected edit let m_levelControllerRef: inkWidgetRef;

  protected edit let m_rewardsControllerRef: inkWidgetRef;

  protected edit let m_TooltipsManagerRef: inkWidgetRef;

  protected edit let m_proficiencyRootRef: inkWidgetRef;

  protected edit let m_proficiencyDescriptionText: inkTextRef;

  protected let m_dataManager: ref<PlayerDevelopmentDataManager>;

  protected let m_displayData: ref<AttributeDisplayData>;

  private let m_proficiencyRoot: wref<TabRadioGroup>;

  private let m_widgetMap: array<wref<PerkDisplayContainerController>>;

  private let m_traitController: wref<PerkDisplayContainerController>;

  private let m_currentIndex: Int32;

  private let m_connectionLines: array<Int32; 45>;

  private let m_levelController: wref<StatsProgressController>;

  private let m_rewardsController: wref<StatsStreetCredReward>;

  private let m_tooltipsManager: wref<gameuiTooltipsManager>;

  protected cb func OnInitialize() -> Bool {
    this.RegisterToGlobalInputCallback(n"OnPostOnRelease", this, n"OnButtonRelease");
    this.m_levelController = this.SpawnFromLocal(inkWidgetRef.Get(this.m_levelControllerRef), n"SkillLevel").GetControllerByType(n"StatsProgressController") as StatsProgressController;
    this.m_rewardsController = this.SpawnFromLocal(inkWidgetRef.Get(this.m_rewardsControllerRef), n"SkillRewards").GetControllerByType(n"StatsStreetCredReward") as StatsStreetCredReward;
    this.m_tooltipsManager = inkWidgetRef.GetControllerByType(this.m_TooltipsManagerRef, n"gameuiTooltipsManager") as gameuiTooltipsManager;
    this.m_tooltipsManager.Setup();
    this.m_proficiencyRoot = inkWidgetRef.GetController(this.m_proficiencyRootRef) as TabRadioGroup;
    this.m_proficiencyRoot.RegisterToCallback(n"OnValueChanged", this, n"OnValueChanged");
    this.m_connectionLines = PerksScreenStaticData.GetPerksConnectionLines();
  }

  protected final func RegisterProficiencyButtons(attributeDisplayData: ref<AttributeDisplayData>, startingIndex: Int32) -> Void {
    let labels: array<String>;
    let proficienciesSize: Int32 = ArraySize(attributeDisplayData.m_proficiencies);
    let i: Int32 = 0;
    while i < proficienciesSize {
      ArrayPush(labels, attributeDisplayData.m_proficiencies[i].m_localizedName);
      i += 1;
    };
    this.m_proficiencyRoot.SetData(proficienciesSize, this.m_tooltipsManager, labels);
    this.m_proficiencyRoot.Toggle(startingIndex);
  }

  protected cb func OnUninitialize() -> Bool {
    this.UnregisterFromGlobalInputCallback(n"OnPostOnRelease", this, n"OnButtonRelease");
  }

  protected cb func OnSetUserData(userData: ref<IScriptable>) -> Bool {
    userData;
  }

  private final func GetMenuData(data: ref<ProficiencyDisplayData>) -> MenuData {
    let menuData: MenuData;
    menuData.identifier = data.m_index;
    menuData.label = data.m_localizedName;
    menuData.userData = data;
    return menuData;
  }

  public final func Setup(displayData: ref<AttributeDisplayData>, dataManager: ref<PlayerDevelopmentDataManager>, startingIndex: Int32) -> Void {
    let attributeData: ref<AttributeData>;
    this.m_dataManager = dataManager;
    this.m_displayData = displayData;
    let i: Int32 = 0;
    while i < ArraySize(this.m_widgetMap) {
      this.m_widgetMap[i].SetData(null, null);
      i += 1;
    };
    this.RegisterProficiencyButtons(displayData, startingIndex);
    attributeData = dataManager.GetAttribute(displayData.m_attributeId);
    inkTextRef.SetText(this.m_attributeNameText, attributeData.label);
    inkTextRef.SetText(this.m_attributeLevelText, IntToString(attributeData.value));
    this.RebuildPerks(startingIndex);
    this.PlayLibraryAnimation(n"start_perk_screen");
  }

  public final func RebuildPerks(index: Int32) -> Void {
    let area: ref<AreaDisplayData>;
    let controller: wref<PerkDisplayContainerController>;
    let i: Int32;
    let isLineVisible: Bool;
    let j: Int32;
    let perk: ref<PerkDisplayData>;
    let proficiency: ref<ProficiencyDisplayData>;
    this.m_currentIndex = index;
    let perksCount: Int32 = 0;
    inkCompoundRef.RemoveAllChildren(this.m_boughtMaskContainer);
    inkCompoundRef.RemoveAllChildren(this.m_maxedMaskContainer);
    proficiency = this.m_displayData.m_proficiencies[index];
    i = 0;
    while i < ArraySize(proficiency.m_areas) {
      area = proficiency.m_areas[i];
      j = 0;
      while j < ArraySize(area.m_perks) {
        perk = area.m_perks[j];
        controller = this.m_widgetMap[perksCount];
        controller.SetData(perk, this.m_dataManager);
        this.SpawnConnectionGradiantMask(controller);
        perksCount += 1;
        j += 1;
      };
      i += 1;
    };
    if this.m_traitController != null {
      this.m_traitController.SetData(proficiency.m_traitData, this.m_dataManager);
    };
    this.m_levelController.SetProfiencyLevel(proficiency);
    this.m_rewardsController.SetData(proficiency, this.m_tooltipsManager, 0);
    i = 0;
    while i <= ArraySize(this.m_connectionLines) {
      isLineVisible = this.m_connectionLines[i] <= perksCount;
      this.ShowLineWidget(this.m_connectionLinesContainer, isLineVisible, i);
      this.ShowLineWidget(this.m_boughtConnectionLinesContainer, isLineVisible, i);
      this.ShowLineWidget(this.m_maxedConnectionLinesContainer, isLineVisible, i);
      i += 1;
    };
    i = perksCount;
    while i < ArraySize(this.m_widgetMap) {
      controller = this.m_widgetMap[i];
      controller.SetData(null, null);
      i += 1;
    };
    inkTextRef.SetText(this.m_proficiencyDescriptionText, proficiency.m_localizedDescription);
  }

  protected cb func OnUnlimitedUnlocked(evt: ref<UnlimitedUnlocked>) -> Bool {
    if this.m_traitController != null {
      this.m_traitController.PlayLibraryAnimation(n"reveal_unlimited_perk_traces");
    };
  }

  private final func ProcessTutorialFact() -> Void {
    let questSystem: ref<QuestsSystem> = GameInstance.GetQuestsSystem(this.m_dataManager.GetPlayer().GetGame());
    if questSystem.GetFact(n"perks_tutorial") == 0 && questSystem.GetFact(n"disable_tutorials") == 0 {
      questSystem.SetFact(n"perks_tutorial", 1);
    };
  }

  private final func SpawnConnectionGradiantMask(controller: wref<PerkDisplayContainerController>) -> Void {
    let container: inkCanvasRef;
    let position: inkMargin;
    let widget: wref<inkWidget>;
    let data: ref<BasePerkDisplayData> = controller.GetPerkDisplayData();
    if data.m_locked || data.m_level <= 0 {
      return;
    };
    container = data.m_level == data.m_maxLevel ? this.m_maxedMaskContainer : this.m_boughtMaskContainer;
    widget = this.SpawnFromLocal(inkWidgetRef.Get(container), n"ConnectionGradiantMask");
    if widget == null {
      return;
    };
    position = controller.GetRootWidget().GetMargin();
    position.left += 100.00;
    position.top += 120.00;
    widget.SetMargin(position);
    widget.SetAnchorPoint(new Vector2(0.50, 0.50));
  }

  private final func ShowLineWidget(lineContainer: inkCompoundRef, show: Bool, lineNumber: Int32) -> Void {
    let line: wref<inkWidget> = inkCompoundRef.GetWidgetByPath(lineContainer, inkWidgetPath.Build(StringToName("connect" + IntToString(lineNumber))));
    line.SetVisible(show);
  }

  protected cb func OnValueChanged(controller: wref<inkRadioGroupController>, selectedIndex: Int32) -> Bool {
    this.RebuildPerks(selectedIndex == -1 ? this.m_currentIndex : selectedIndex);
    this.PlayLibraryAnimation(n"start_perk_screen");
  }

  protected cb func OnPerkBoughtEvent(evt: ref<PerkBoughtEvent>) -> Bool {
    let developmentData: ref<PlayerDevelopmentData> = PlayerDevelopmentSystem.GetData(this.m_dataManager.GetPlayer());
    let proficiencyType: gamedataProficiencyType = developmentData.GetProficiencyFromPerkArea(developmentData.GetPerkAreaFromPerk(evt.perkType));
    this.m_displayData.m_proficiencies[this.m_currentIndex] = this.m_dataManager.GetProficiencyWithData(proficiencyType);
    this.RebuildPerks(this.m_currentIndex);
  }

  protected cb func OnTraitBoughtEvent(evt: ref<TraitBoughtEvent>) -> Bool {
    let proficiencyType: gamedataProficiencyType = this.m_displayData.m_proficiencies[this.m_currentIndex].m_proficiency;
    this.m_displayData.m_proficiencies[this.m_currentIndex] = this.m_dataManager.GetProficiencyWithData(proficiencyType);
    this.RebuildPerks(this.m_currentIndex);
  }

  protected cb func OnPerkDisplayContainerCreated(evt: ref<PerkDisplayContainerCreatedEvent>) -> Bool {
    let controller: ref<PerkDisplayContainerController> = evt.container.GetController() as PerkDisplayContainerController;
    if evt.isTrait {
      this.m_traitController = controller;
    } else {
      if evt.index > 0 {
        if ArraySize(this.m_widgetMap) < evt.index {
          ArrayResize(this.m_widgetMap, evt.index);
        };
        this.m_widgetMap[evt.index - 1] = controller;
      };
    };
  }

  public final func GetProficiencyDisplayData() -> ref<ProficiencyDisplayData> {
    return this.m_displayData.m_proficiencies[this.m_currentIndex];
  }

  public final func GetHubSelectorWidget() -> wref<inkWidget> {
    return inkWidgetRef.Get(this.m_proficiencyRootRef);
  }
}

public class PerksSkillLabelController extends HubMenuLabelController {

  public func SetTargetData(data: MenuData, direction: Int32) -> Void {
    this.m_data = data;
    this.m_direction = direction;
    if direction != 0 {
      this.m_watchForSize = true;
      this.m_wrapperNextController.SetData(data);
    } else {
      this.m_watchForInstatnSize = true;
      this.m_wrapperController.SetData(data);
    };
  }

  public func SetActive(active: Bool) -> Void {
    this.SetActive(active);
  }
}

public class PerksSkillLabelContentContainer extends HubMenuLabelContentContainer {

  protected edit let m_levelLabel: inkTextRef;

  protected edit let m_levelBar: inkWidgetRef;

  public let m_skillData: ref<ProficiencyDisplayData>;

  public func SetData(data: MenuData) -> Void {
    this.m_data = data;
    this.RefreshSkillData(data.userData as ProficiencyDisplayData);
  }

  private final func RefreshSkillData(skill: ref<ProficiencyDisplayData>) -> Void {
    this.m_skillData = skill;
    this.m_labelName = this.m_skillData.m_localizedName;
    inkTextRef.SetText(this.m_label, this.m_labelName);
  }

  protected cb func OnPerkPurchased(evt: ref<PerkBoughtEvent>) -> Bool {
    this.RefreshSkillData(this.m_data.userData as ProficiencyDisplayData);
  }
}

public class PerksScreenStaticData extends IScriptable {

  public final static func GetPerksConnectionLines() -> array<Int32; 45> {
    let result: Int32[45];
    result[0] = 29;
    result[1] = 17;
    result[2] = 27;
    result[3] = 29;
    result[4] = 21;
    result[5] = 15;
    result[6] = 19;
    result[7] = 19;
    result[8] = 20;
    result[9] = 20;
    result[10] = 14;
    result[11] = 13;
    result[12] = 13;
    result[13] = 9;
    result[14] = 25;
    result[15] = 3;
    result[16] = 9;
    result[17] = 8;
    result[18] = 2;
    result[19] = 7;
    result[20] = 9;
    result[21] = 6;
    result[22] = 6;
    result[23] = 4;
    result[24] = 5;
    result[25] = 5;
    result[26] = 6;
    result[27] = 12;
    result[28] = 12;
    result[29] = 10;
    result[30] = 11;
    result[31] = 12;
    result[32] = 18;
    result[33] = 18;
    result[34] = 28;
    result[35] = 30;
    result[36] = 26;
    result[37] = 24;
    result[38] = 24;
    result[39] = 16;
    result[40] = 18;
    result[41] = 23;
    result[42] = 22;
    result[43] = 22;
    result[44] = 23;
    return result;
  }
}

public class ProficiencyTabButtonController extends TabButtonController {

  private let m_proxy: ref<inkAnimProxy>;

  private let m_isToggledState: Bool;

  protected cb func OnInitialize() -> Bool {
    super.OnInitialize();
    this.RegisterToCallback(n"OnToggleChanged", this, n"OnToggleChanged");
  }

  protected cb func OnUninitialize() -> Bool {
    this.UnregisterFromCallback(n"OnToggleChanged", this, n"OnToggleChanged");
  }

  protected cb func OnToggleChanged(controller: wref<inkToggleController>, isToggled: Bool) -> Bool {
    let state: inkEToggleState = this.GetToggleState();
    let isToggledState: Bool = Equals(state, inkEToggleState.Toggled) || Equals(state, inkEToggleState.ToggledPress) || Equals(state, inkEToggleState.ToggledHover);
    if Equals(this.m_isToggledState, isToggledState) {
      return false;
    };
    this.m_isToggledState = isToggledState;
    if IsDefined(this.m_proxy) {
      this.m_proxy.Stop(true);
    };
    if isToggledState {
      this.m_proxy = this.PlayLibraryAnimation(n"tab_hover");
      this.PlaySound(n"Button", n"OnHover");
    } else {
      this.m_proxy = this.PlayLibraryAnimation(n"tab_hover_out");
    };
  }
}

public class TabRadioGroup extends inkRadioGroupController {

  private edit let m_root: inkCompoundRef;

  public let toggles: array<wref<TabButtonController>>;

  private let m_TooltipsManager: wref<gameuiTooltipsManager>;

  public final func SetData(enumCount: Int32, opt tooltipsManager: wref<gameuiTooltipsManager>, opt labelList: array<String>, opt iconList: array<String>) -> Void {
    let tabToggle: ref<TabButtonController>;
    let widget: wref<inkWidget>;
    this.m_TooltipsManager = tooltipsManager;
    let i: Int32 = 0;
    while i < ArraySize(this.toggles) {
      widget = this.toggles[i].GetRootWidget();
      widget.SetVisible(false);
      i += 1;
    };
    i = 0;
    while i < enumCount {
      if ArraySize(this.toggles) <= i {
        widget = this.SpawnFromLocal(inkWidgetRef.Get(this.m_root), n"proficiencyTabButton");
        if widget == null {
          widget = this.SpawnFromExternal(inkWidgetRef.Get(this.m_root), r"base\\gameplay\\gui\\common\\components\\toggles.inkwidget", n"proficiencyTabButton");
        };
        tabToggle = widget.GetController() as TabButtonController;
        ArrayPush(this.toggles, tabToggle);
        this.AddToggle(tabToggle);
      } else {
        tabToggle = this.toggles[i];
      };
      tabToggle.SetToggleData(i, labelList[i], iconList[i]);
      widget = tabToggle.GetRootWidget();
      widget.SetVisible(true);
      if IsDefined(this.m_TooltipsManager) {
        tabToggle.RegisterToCallback(n"OnHoverOver", this, n"OnHoverOver");
        tabToggle.RegisterToCallback(n"OnHoverOut", this, n"OnHoverOut");
      };
      i += 1;
    };
  }

  protected cb func OnHoverOver(evt: ref<inkPointerEvent>) -> Bool {
    let widget: ref<inkWidget> = evt.GetCurrentTarget();
    let controller: ref<ToggleController> = widget.GetController() as ToggleController;
    let tooltipData: ref<MessageTooltipData> = new MessageTooltipData();
    tooltipData.Title = GetLocalizedText(controller.GetLabelKey());
    this.m_TooltipsManager.ShowTooltip(1, tooltipData, new inkMargin(60.00, 0.00, 0.00, 0.00));
  }

  protected cb func OnHoverOut(evt: ref<inkPointerEvent>) -> Bool {
    this.m_TooltipsManager.HideTooltips();
  }
}

public class TabButtonController extends inkToggleController {

  protected edit let m_label: inkTextRef;

  protected edit let m_icon: inkImageRef;

  protected let m_data: Int32;

  protected let m_labelSet: String;

  protected let m_iconSet: String;

  protected cb func OnInitialize() -> Bool {
    this.RegisterToCallback(n"OnRelease", this, n"OnTabSelected");
    this.RegisterToCallback(n"OnHoverOver", this, n"OnTabHoverOver");
    this.RegisterToCallback(n"OnHoverOut", this, n"OnTabHoverOut");
  }

  public final func SetToggleData(data: Int32, opt label: String, opt icon: String) -> Void {
    this.m_data = data;
    this.m_labelSet = label;
    this.m_iconSet = icon;
    if inkWidgetRef.IsValid(this.m_label) {
      inkTextRef.SetText(this.m_label, this.GetLabelKey());
    };
    if inkWidgetRef.IsValid(this.m_icon) {
      InkImageUtils.RequestSetImage(this, this.m_icon, this.GetIcon(), n"OnIconCallback");
    };
  }

  protected cb func OnIconCallback(e: ref<iconAtlasCallbackData>) -> Bool {
    if NotEquals(e.loadResult, inkIconResult.Success) {
      inkImageRef.SetTexturePart(this.m_icon, StringToName(this.m_iconSet));
    };
  }

  public final func GetData() -> Int32 {
    return this.m_data;
  }

  public func GetLabelKey() -> String {
    if IsStringValid(this.m_labelSet) {
      return this.m_labelSet;
    };
    return "";
  }

  public func GetIcon() -> String {
    if IsStringValid(this.m_iconSet) {
      return this.m_iconSet;
    };
    return "";
  }

  protected cb func OnTabSelected(e: ref<inkPointerEvent>) -> Bool {
    if e.IsAction(n"click") {
      this.PlaySound(n"Button", n"OnPress");
    };
  }

  protected cb func OnTabHoverOver(e: ref<inkPointerEvent>) -> Bool;

  protected cb func OnTabHoverOut(e: ref<inkPointerEvent>) -> Bool;
}
