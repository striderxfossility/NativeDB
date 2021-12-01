
public class BuildButtonItemController extends inkButtonDpadSupportedController {

  private let m_associatedBuild: gamedataBuildType;

  protected cb func OnInitialize() -> Bool {
    super.OnInitialize();
  }

  public final func SetButtonDetails(argText: String, type: gamedataBuildType) -> Void {
    this.m_rootWidget = this.GetRootWidget() as inkCanvas;
    let currListText: wref<inkText> = this.m_rootWidget.GetWidget(n"textLabel") as inkText;
    currListText.SetText(argText);
    this.m_associatedBuild = type;
  }

  public final func GetAssociatedBuild() -> gamedataBuildType {
    return this.m_associatedBuild;
  }
}

public class buildsWidgetGameController extends inkGameController {

  private let m_horizontalPanelsList: array<wref<inkHorizontalPanel>>;

  protected cb func OnInitialize() -> Bool {
    let j: Int32;
    let tempList: wref<inkHorizontalPanel>;
    let verticalPanel: wref<inkVerticalPanel> = this.GetWidget(n"SubCanvas\\VerticalPanel") as inkVerticalPanel;
    let amountOfLists: Int32 = 2;
    let i: Int32 = 0;
    while i < amountOfLists {
      tempList = this.SpawnFromLocal(verticalPanel, n"BuildsList") as inkHorizontalPanel;
      ArrayPush(this.m_horizontalPanelsList, tempList);
      i += 1;
    };
    i = 0;
    j = 0;
    while j < EnumInt(gamedataBuildType.Count) {
      if this.IsProperDevBuild(IntEnum(j)) {
        this.CreateBuildButton(IntEnum(j));
        i += 1;
      };
      j += 1;
    };
    this.CreateCustomButton(CustomButtonType.UnlockAllVehicles);
    this.CreateCustomButton(CustomButtonType.ShowAllPoiMappins);
    this.CreateCustomButton(CustomButtonType.DiscoverAllPoiMappins);
    this.SetCursorOverWidget(this.m_horizontalPanelsList[0].GetWidget(0));
  }

  private final func IsProperDevBuild(type: gamedataBuildType) -> Bool {
    return Equals(type, gamedataBuildType.HandsOnStarting) || Equals(type, gamedataBuildType.MaxSkillsAllWeapons) || Equals(type, gamedataBuildType.StartingBuild);
  }

  private final func CreateBuildButton(type: gamedataBuildType) -> Void {
    let buildString: String;
    let currLogic: wref<BuildButtonItemController>;
    let currButton: wref<inkCanvas> = this.SpawnFromLocal(this.m_horizontalPanelsList[0], n"BuildButton") as inkCanvas;
    currButton.RegisterToCallback(n"OnRelease", this, n"OnBuildsMenuSelectBuild");
    currButton.RegisterToCallback(n"OnEnter", this, n"OnBuildMenuEnter");
    currButton.RegisterToCallback(n"OnLeave", this, n"OnBuildMenuExit");
    currLogic = currButton.GetController() as BuildButtonItemController;
    buildString = EnumValueToString("gamedataBuildType", Cast(EnumInt(type)));
    currLogic.SetButtonDetails(buildString, type);
    this.SetTooltip(type);
  }

  private final func CreateCustomButton(type: CustomButtonType) -> Void {
    let currLogic: wref<BuildButtonItemController>;
    let currButton: wref<inkCanvas> = this.SpawnFromLocal(this.m_horizontalPanelsList[1], n"BuildButton") as inkCanvas;
    switch type {
      case CustomButtonType.UnlockAllVehicles:
        currButton.RegisterToCallback(n"OnRelease", this, n"OnClickedCutonButton_UnlockAllVehicles");
        currLogic = currButton.GetController() as BuildButtonItemController;
        currLogic.SetButtonDetails("Unlock all vehicles", gamedataBuildType.Invalid);
        break;
      case CustomButtonType.ShowAllPoiMappins:
        currButton.RegisterToCallback(n"OnRelease", this, n"OnClickedCutonButton_ShowAllPoiMappins");
        currLogic = currButton.GetController() as BuildButtonItemController;
        currLogic.SetButtonDetails("Show all POIs", gamedataBuildType.Invalid);
        break;
      case CustomButtonType.DiscoverAllPoiMappins:
        currButton.RegisterToCallback(n"OnRelease", this, n"OnClickedCutonButton_DiscoverAllPoiMappins");
        currLogic = currButton.GetController() as BuildButtonItemController;
        currLogic.SetButtonDetails("Discover POIs", gamedataBuildType.Invalid);
    };
  }

  public final func OnClickedCutonButton_UnlockAllVehicles(e: ref<inkPointerEvent>) -> Void {
    let vehicleSystem: ref<VehicleSystem>;
    if e.IsAction(n"click") {
      DebugGiveHotkeys((this.GetOwnerEntity() as GameObject).GetGame());
      vehicleSystem = GameInstance.GetVehicleSystem((this.GetOwnerEntity() as GameObject).GetGame());
      if IsDefined(vehicleSystem) {
        vehicleSystem.EnableAllPlayerVehicles();
      };
    };
  }

  public final func OnClickedCutonButton_ShowAllPoiMappins(e: ref<inkPointerEvent>) -> Void {
    let journalManager: ref<JournalManager>;
    if e.IsAction(n"click") {
      journalManager = GameInstance.GetJournalManager((this.GetOwnerEntity() as GameObject).GetGame());
      if IsDefined(journalManager) {
        journalManager.DebugShowAllPoiMappins();
      };
    };
  }

  public final func OnClickedCutonButton_DiscoverAllPoiMappins(e: ref<inkPointerEvent>) -> Void {
    let mappinSystem: ref<MappinSystem>;
    if e.IsAction(n"click") {
      mappinSystem = GameInstance.GetMappinSystem((this.GetOwnerEntity() as GameObject).GetGame());
      if IsDefined(mappinSystem) {
        mappinSystem.DebugDiscoverAllPoiMappins();
      };
    };
  }

  public final func OnBuildsMenuSelectBuild(e: ref<inkPointerEvent>) -> Void {
    let PDS: ref<PlayerDevelopmentSystem>;
    let button: wref<inkCanvas>;
    let controller: wref<BuildButtonItemController>;
    let request: ref<SetProgressionBuild>;
    let player: ref<PlayerPuppet> = GetPlayer((this.GetOwnerEntity() as GameObject).GetGame());
    if e.IsAction(n"click") {
      DebugGiveHotkeys(player.GetGame());
      PDS = GameInstance.GetScriptableSystemsContainer((this.GetOwnerEntity() as GameObject).GetGame()).Get(n"PlayerDevelopmentSystem") as PlayerDevelopmentSystem;
      button = e.GetCurrentTarget() as inkCanvas;
      controller = button.GetController() as BuildButtonItemController;
      request = new SetProgressionBuild();
      request.Set(player, controller.GetAssociatedBuild());
      PDS.QueueRequest(request);
    };
  }

  private final func SetTooltip(type: gamedataBuildType) -> Void {
    let build: wref<ProgressionBuild_Record>;
    let craftBook: wref<Craftable_Record>;
    let craftingRecipes: array<wref<Item_Record>>;
    let i: Int32;
    let startingAttributes: array<wref<BuildAttribute_Record>>;
    let startingCyberware: array<wref<BuildCyberware_Record>>;
    let startingEquipment: array<wref<BuildEquipment_Record>>;
    let startingItems: array<wref<InventoryItem_Record>>;
    let startingPerks: array<wref<BuildPerk_Record>>;
    let startingProficiencies: array<wref<BuildProficiency_Record>>;
    let tooltip: String = "";
    let tooltipWidgetText: wref<inkText> = this.GetWidget(n"SubCanvas\\tooltip\\text_wrapper\\tooltipText") as inkText;
    let tooltipWidgetText2: wref<inkText> = this.GetWidget(n"SubCanvas\\tooltip\\text_wrapper\\tooltipText2") as inkText;
    tooltipWidgetText.SetLetterCase(textLetterCase.UpperCase);
    tooltipWidgetText2.SetLetterCase(textLetterCase.UpperCase);
    build = TweakDBInterface.GetProgressionBuildRecord(TDBID.Create("ProgressionBuilds." + EnumValueToString("gamedataBuildType", Cast(EnumInt(type)))));
    tooltip = tooltip + EnumValueToString("gamedataBuildType", Cast(EnumInt(type))) + "\\n\\n";
    build.StartingProficiencies(startingProficiencies);
    build.StartingPerks(startingPerks);
    build.StartingAttributes(startingAttributes);
    build.StartingItems(startingItems);
    build.StartingEquipment(startingEquipment);
    build.StartingCyberware(startingCyberware);
    craftBook = build.CraftBook();
    craftBook.CraftableItem(craftingRecipes);
    tooltip = tooltip + "CHARACTER:\\n";
    i = 0;
    while i < ArraySize(startingProficiencies) {
      if Equals(startingProficiencies[i].Proficiency().DisplayName(), "Level") {
        tooltip = tooltip + startingProficiencies[i].Proficiency().DisplayName() + " " + startingProficiencies[i].Level() + "\\n";
      };
      i += 1;
    };
    tooltip = tooltip + "\\n";
    tooltip = tooltip + "ATTRIBUTES:\\n";
    i = 0;
    while i < ArraySize(startingAttributes) {
      tooltip = tooltip + EnumValueToString("gamedataStatType", EnumInt(startingAttributes[i].Attribute().StatType())) + " " + startingAttributes[i].Level() + "\\n";
      i += 1;
    };
    tooltip = tooltip + "\\n";
    tooltip = tooltip + "SKILLS:\\n";
    i = 0;
    while i < ArraySize(startingProficiencies) {
      if NotEquals(startingProficiencies[i].Proficiency().DisplayName(), "Level") {
        tooltip = tooltip + startingProficiencies[i].Proficiency().DisplayName() + " " + startingProficiencies[i].Level() + "\\n";
      };
      i += 1;
    };
    tooltip = tooltip + "\\n";
    tooltip = tooltip + "CRAFTING BLUEPRINTS:\\n";
    i = 0;
    while i < ArraySize(craftingRecipes) {
      tooltip = tooltip + NameToString(craftingRecipes[i].DisplayName()) + "\\n";
      i += 1;
    };
    tooltip = tooltip + "\\n";
    tooltipWidgetText.SetText(tooltip);
    tooltip = "";
    tooltip = tooltip + "CYBERWARE:\\n";
    i = 0;
    while i < ArraySize(startingCyberware) {
      tooltip = tooltip + NameToString(startingCyberware[i].Cyberware().DisplayName()) + "\\n";
      i += 1;
    };
    tooltip = tooltip + "\\n";
    tooltip = tooltip + "INVENTORY:\\n";
    i = 0;
    while i < ArraySize(startingEquipment) {
      tooltip = tooltip + NameToString(startingEquipment[i].Equipment().DisplayName()) + "\\n";
      i += 1;
    };
    i = 0;
    while i < ArraySize(startingItems) {
      if startingItems[i].Quantity() > 1 {
        tooltip = tooltip + NameToString(startingItems[i].Item().DisplayName()) + " (" + startingItems[i].Quantity() + ")\\n";
      } else {
        tooltip = tooltip + NameToString(startingItems[i].Item().DisplayName()) + "\\n";
      };
      i += 1;
    };
    tooltip = tooltip + "\\n";
    tooltipWidgetText2.SetText(tooltip);
  }

  private final func ShowTooltip(val: Bool) -> Void {
    let tooltipWidget: wref<inkCanvas> = this.GetWidget(n"SubCanvas\\tooltip") as inkCanvas;
    tooltipWidget.SetVisible(val);
  }

  public final func OnBuildMenuEnter(e: ref<inkPointerEvent>) -> Void {
    let button: wref<inkWidget> = e.GetCurrentTarget();
    let controller: wref<BuildButtonItemController> = button.GetController() as BuildButtonItemController;
    this.SetTooltip(controller.GetAssociatedBuild());
    this.ShowTooltip(true);
  }

  public final func OnBuildMenuExit(e: ref<inkPointerEvent>) -> Void {
    this.ShowTooltip(false);
  }
}
