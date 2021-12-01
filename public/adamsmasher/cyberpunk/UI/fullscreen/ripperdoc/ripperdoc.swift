
public class RipperDocItemBoughtCallback extends InventoryScriptCallback {

  private let eventTarget: wref<RipperDocGameController>;

  public final func Bind(eventTargetArg: ref<RipperDocGameController>) -> Void {
    this.eventTarget = eventTargetArg;
  }

  public func OnItemAdded(itemIDArg: ItemID, itemData: wref<gameItemData>, flaggedAsSilent: Bool) -> Void {
    this.eventTarget.OnItemBought(itemIDArg, itemData);
  }
}

public class RipperDocGameController extends gameuiMenuGameController {

  private edit let m_TooltipsManagerRef: inkWidgetRef;

  private edit let m_buttonHintsManagerRef: inkWidgetRef;

  private edit let m_defaultTab: inkWidgetRef;

  private edit let m_itemTab: inkWidgetRef;

  private edit let m_femaleHovers: inkWidgetRef;

  private edit let m_maleHovers: inkWidgetRef;

  private edit let m_defaultAnimationTab: inkWidgetRef;

  private edit let m_itemAnimationTab: inkWidgetRef;

  private edit let m_F_frontalCortexHoverTexture: inkWidgetRef;

  private edit let m_F_eyesHoverTexture: inkWidgetRef;

  private edit let m_F_cardiovascularHoverTexture: inkWidgetRef;

  private edit let m_F_immuneHoverTexture: inkWidgetRef;

  private edit let m_F_nervousHoverTexture: inkWidgetRef;

  private edit let m_F_integumentaryHoverTexture: inkWidgetRef;

  private edit let m_F_systemReplacementHoverTexture: inkWidgetRef;

  private edit let m_F_musculoskeletalHoverTexture: inkWidgetRef;

  private edit let m_F_handsHoverTexture: inkWidgetRef;

  private edit let m_F_armsHoverTexture: inkWidgetRef;

  private edit let m_F_legsHoverTexture: inkWidgetRef;

  private edit let m_M_frontalCortexHoverTexture: inkWidgetRef;

  private edit let m_M_eyesHoverTexture: inkWidgetRef;

  private edit let m_M_cardiovascularHoverTexture: inkWidgetRef;

  private edit let m_M_immuneHoverTexture: inkWidgetRef;

  private edit let m_M_nervousHoverTexture: inkWidgetRef;

  private edit let m_M_integumentaryHoverTexture: inkWidgetRef;

  private edit let m_M_systemReplacementHoverTexture: inkWidgetRef;

  private edit let m_M_musculoskeletalHoverTexture: inkWidgetRef;

  private edit let m_M_handsHoverTexture: inkWidgetRef;

  private edit let m_M_armsHoverTexture: inkWidgetRef;

  private edit let m_M_legsHoverTexture: inkWidgetRef;

  private edit let m_man_wiresTexture: inkWidgetRef;

  private edit let m_woman_wiresTexture: inkWidgetRef;

  private edit let m_frontalCortexAnchor: inkCompoundRef;

  private edit let m_ocularCortexAnchor: inkCompoundRef;

  private edit let m_leftMiddleGridAnchor: inkCompoundRef;

  private edit let m_leftButtomGridAnchor: inkCompoundRef;

  private edit let m_rightTopGridAnchor: inkCompoundRef;

  private edit let m_rightButtomGridAnchor: inkCompoundRef;

  private edit let m_skeletonAnchor: inkCompoundRef;

  private edit let m_handsAnchor: inkCompoundRef;

  private edit let m_ripperdocIdRoot: inkWidgetRef;

  private edit let m_playerMoney: inkTextRef;

  private edit let m_playerMoneyHolder: inkWidgetRef;

  private edit let m_cyberwareSlotsList: inkCompoundRef;

  private edit let m_cyberwareVirtualGrid: inkVirtualCompoundRef;

  private edit let m_radioGroupRef: inkWidgetRef;

  private edit let m_cyberwareInfoContainer: inkCompoundRef;

  private edit let m_itemsListScrollAreaContainer: inkWidgetRef;

  private edit let m_sortingButton: inkWidgetRef;

  private edit let m_sortingDropdown: inkWidgetRef;

  private let m_mode: RipperdocModes;

  private let m_screen: CyberwareScreenType;

  private let m_buttonHintsController: wref<ButtonHints>;

  private let m_TooltipsManager: wref<gameuiTooltipsManager>;

  private let m_InventoryManager: ref<InventoryDataManagerV2>;

  private let m_uiScriptableSystem: wref<UIScriptableSystem>;

  private let m_menuEventDispatcher: wref<inkMenuEventDispatcher>;

  private let m_player: wref<PlayerPuppet>;

  private let m_vendorUserData: ref<VendorUserData>;

  private let m_VendorDataManager: ref<VendorDataManager>;

  private let m_selectedArea: gamedataEquipmentArea;

  private let m_equipmentGrid: wref<CyberwareInventoryMiniGrid>;

  private let m_VendorBlackboard: wref<IBlackboard>;

  private let m_equipmentBlackboard: wref<IBlackboard>;

  private let m_equipmentBlackboardCallback: ref<CallbackHandle>;

  private let m_cyberwareInfo: wref<AGenericTooltipController>;

  private let m_cyberwareInfoType: CyberwareInfoType;

  private let m_animationProxy: ref<inkAnimProxy>;

  private let m_virtualCyberwareListController: wref<inkVirtualGridController>;

  private let m_cyberwareClassifier: ref<CyberwareTemplateClassifier>;

  private let m_cyberwareDataSource: ref<ScriptableDataSource>;

  private let m_cyberwaregDataView: ref<CyberwareDataView>;

  private let m_currentFilter: RipperdocFilter;

  private let m_radioGroup: wref<FilterRadioGroup>;

  private let m_ripperId: wref<RipperdocIdPanel>;

  private let m_hoverAnimation: ref<inkAnimProxy>;

  private let m_hoverOverAnimation: ref<inkAnimProxy>;

  private let m_introDefaultAnimation: ref<inkAnimProxy>;

  private let m_outroDefaultAnimation: ref<inkAnimProxy>;

  private let m_introPaperdollAnimation: ref<inkAnimProxy>;

  private let m_outroPaperdollAnimation: ref<inkAnimProxy>;

  private let m_inventoryListener: ref<InventoryScriptListener>;

  private let m_cyberareGrids: array<wref<CyberwareInventoryMiniGrid>>;

  private let m_isActivePanel: Bool;

  private let m_equiped: Bool;

  private let m_activeSlotIndex: Int32;

  private let m_confirmationPopupToken: ref<inkGameNotificationToken>;

  protected cb func OnInitialize() -> Bool {
    let vendorData: VendorData;
    let vendorPanelData: ref<VendorPanelData>;
    if IsDefined(this.m_vendorUserData) {
      vendorPanelData = this.m_vendorUserData.vendorData;
      vendorData = vendorPanelData.data;
      this.m_screen = CyberwareScreenType.Ripperdoc;
      this.m_VendorDataManager = new VendorDataManager();
      this.m_VendorDataManager.Initialize(this.GetPlayerControlledObject(), vendorData.entityID);
      this.m_ripperId = this.SpawnFromLocal(inkWidgetRef.Get(this.m_ripperdocIdRoot), n"ripperdoc_id").GetController() as RipperdocIdPanel;
      this.m_ripperId.SetName(this.m_VendorDataManager.GetVendorName());
      this.UpdateVendorMoney();
      inkWidgetRef.SetVisible(this.m_playerMoneyHolder, true);
      this.UpdatePlayerMoney();
    } else {
      this.m_screen = CyberwareScreenType.Inventory;
      inkWidgetRef.SetVisible(this.m_playerMoneyHolder, false);
    };
    this.RegisterInventoryListener(this.GetPlayerControlledObject());
    this.Init();
    inkCompoundRef.RemoveAllChildren(this.m_cyberwareSlotsList);
    this.m_virtualCyberwareListController = inkWidgetRef.GetControllerByType(this.m_cyberwareVirtualGrid, n"inkVirtualGridController") as inkVirtualGridController;
    this.m_cyberwareClassifier = new CyberwareTemplateClassifier();
    this.m_cyberwareDataSource = new ScriptableDataSource();
    this.m_cyberwaregDataView = new CyberwareDataView();
    this.m_cyberwaregDataView.SetSource(this.m_cyberwareDataSource);
    this.m_virtualCyberwareListController.SetClassifier(this.m_cyberwareClassifier);
    this.m_virtualCyberwareListController.SetSource(this.m_cyberwaregDataView);
    inkWidgetRef.SetOpacity(this.m_F_frontalCortexHoverTexture, 0.00);
    inkWidgetRef.SetOpacity(this.m_F_eyesHoverTexture, 0.00);
    inkWidgetRef.SetOpacity(this.m_F_cardiovascularHoverTexture, 0.00);
    inkWidgetRef.SetOpacity(this.m_F_immuneHoverTexture, 0.00);
    inkWidgetRef.SetOpacity(this.m_F_nervousHoverTexture, 0.00);
    inkWidgetRef.SetOpacity(this.m_F_integumentaryHoverTexture, 0.00);
    inkWidgetRef.SetOpacity(this.m_F_systemReplacementHoverTexture, 0.00);
    inkWidgetRef.SetOpacity(this.m_F_musculoskeletalHoverTexture, 0.00);
    inkWidgetRef.SetOpacity(this.m_F_handsHoverTexture, 0.00);
    inkWidgetRef.SetOpacity(this.m_F_armsHoverTexture, 0.00);
    inkWidgetRef.SetOpacity(this.m_F_legsHoverTexture, 0.00);
    inkWidgetRef.SetOpacity(this.m_M_frontalCortexHoverTexture, 0.00);
    inkWidgetRef.SetOpacity(this.m_M_eyesHoverTexture, 0.00);
    inkWidgetRef.SetOpacity(this.m_M_cardiovascularHoverTexture, 0.00);
    inkWidgetRef.SetOpacity(this.m_M_immuneHoverTexture, 0.00);
    inkWidgetRef.SetOpacity(this.m_M_nervousHoverTexture, 0.00);
    inkWidgetRef.SetOpacity(this.m_M_integumentaryHoverTexture, 0.00);
    inkWidgetRef.SetOpacity(this.m_M_systemReplacementHoverTexture, 0.00);
    inkWidgetRef.SetOpacity(this.m_M_musculoskeletalHoverTexture, 0.00);
    inkWidgetRef.SetOpacity(this.m_M_handsHoverTexture, 0.00);
    inkWidgetRef.SetOpacity(this.m_M_armsHoverTexture, 0.00);
    inkWidgetRef.SetOpacity(this.m_M_legsHoverTexture, 0.00);
    this.m_selectedArea = gamedataEquipmentArea.Invalid;
    this.SetupSorting();
    GameInstance.GetTelemetrySystem(this.GetPlayerControlledObject().GetGame()).LogVendorMenuState(this.m_VendorDataManager.GetVendorID(), true);
    super.OnInitialize();
  }

  protected cb func OnUninitialize() -> Bool {
    let vendorData: VendorData;
    vendorData.isActive = false;
    this.m_VendorBlackboard.SetVariant(GetAllBlackboardDefs().UI_Vendor.VendorData, ToVariant(vendorData), true);
    this.m_virtualCyberwareListController.SetClassifier(null);
    this.m_virtualCyberwareListController.SetSource(null);
    this.m_cyberwaregDataView.SetSource(null);
    this.m_cyberwareClassifier = null;
    this.m_cyberwareDataSource = null;
    this.m_cyberwaregDataView = null;
    this.UnregisterInventoryListener(this.GetPlayerControlledObject());
    this.m_InventoryManager.UnInitialize();
    this.UnregisterBlackboard();
    this.m_menuEventDispatcher.UnregisterFromEvent(n"OnBack", this, n"OnBack");
    GameInstance.GetTelemetrySystem(this.GetPlayerControlledObject().GetGame()).LogVendorMenuState(this.m_VendorDataManager.GetVendorID(), false);
    this.m_equipmentGrid = null;
    ArrayClear(this.m_cyberareGrids);
    super.OnUninitialize();
  }

  protected cb func OnVendorHubMenuChanged(evt: ref<VendorHubMenuChanged>) -> Bool {
    this.m_isActivePanel = Equals(evt.item, HubVendorMenuItems.Cyberware);
  }

  private final func SetFilters() -> Void {
    let enumCount: Int32 = Cast(EnumGetMax(n"RipperdocFilter")) + 1;
    this.m_radioGroup = inkWidgetRef.GetControllerByType(this.m_radioGroupRef, n"FilterRadioGroup") as FilterRadioGroup;
    this.m_radioGroup.SetData(enumCount, this.m_TooltipsManager, 1);
    this.m_radioGroup.RegisterToCallback(n"OnValueChanged", this, n"OnFilterChange");
    this.m_currentFilter = RipperdocFilter.All;
  }

  protected cb func OnFilterChange(controller: wref<inkRadioGroupController>, selectedIndex: Int32) -> Bool {
    this.PlaySound(n"Button", n"OnPress");
    this.m_cyberwaregDataView.SetFilterType(IntEnum(selectedIndex));
    this.PlayLibraryAnimation(n"filter_change");
    (inkWidgetRef.GetController(this.m_itemsListScrollAreaContainer) as inkScrollController).SetScrollPosition(0.00);
  }

  private final func StopAllAnimations() -> Void {
    if this.m_hoverAnimation.IsPlaying() {
      this.m_hoverAnimation.GotoStartAndStop();
    };
    if this.m_hoverOverAnimation.IsPlaying() {
      this.m_hoverOverAnimation.GotoStartAndStop();
    };
    if this.m_introDefaultAnimation.IsPlaying() {
      this.m_introDefaultAnimation.GotoStartAndStop();
    };
    if this.m_outroDefaultAnimation.IsPlaying() {
      this.m_outroDefaultAnimation.GotoStartAndStop();
    };
    if this.m_introPaperdollAnimation.IsPlaying() {
      this.m_introPaperdollAnimation.GotoStartAndStop();
    };
    if this.m_outroPaperdollAnimation.IsPlaying() {
      this.m_outroPaperdollAnimation.GotoStartAndStop();
    };
  }

  private final func IsTransitionAnimationPlaying() -> Bool {
    return this.m_introDefaultAnimation.IsPlaying() || this.m_outroDefaultAnimation.IsPlaying() || this.m_introPaperdollAnimation.IsPlaying() || this.m_outroPaperdollAnimation.IsPlaying();
  }

  private final func SetupSorting() -> Void {
    let controller: ref<DropdownListController>;
    let sortingButtonController: ref<DropdownButtonController>;
    inkWidgetRef.RegisterToCallback(this.m_sortingButton, n"OnRelease", this, n"OnSortingButtonClicked");
    controller = inkWidgetRef.GetController(this.m_sortingDropdown) as DropdownListController;
    sortingButtonController = inkWidgetRef.GetController(this.m_sortingButton) as DropdownButtonController;
    controller.Setup(this, SortingDropdownData.GetDefaultDropdownOptions(), sortingButtonController);
    sortingButtonController.SetData(SortingDropdownData.GetDropdownOption(controller.GetData(), ItemSortMode.Default));
  }

  protected cb func OnDropdownItemClickedEvent(evt: ref<DropdownItemClickedEvent>) -> Bool {
    let sortingButtonController: ref<DropdownButtonController>;
    let identifier: ItemSortMode = FromVariant(evt.identifier);
    let data: ref<DropdownItemData> = SortingDropdownData.GetDropdownOption((inkWidgetRef.GetController(this.m_sortingDropdown) as DropdownListController).GetData(), identifier);
    this.PlaySound(n"Button", n"OnPress");
    if IsDefined(data) {
      sortingButtonController = inkWidgetRef.GetController(this.m_sortingButton) as DropdownButtonController;
      sortingButtonController.SetData(data);
      this.m_cyberwaregDataView.SetSortMode(identifier);
    };
  }

  protected cb func OnSortingButtonClicked(evt: ref<inkPointerEvent>) -> Bool {
    let controller: ref<DropdownListController>;
    if evt.IsAction(n"click") {
      this.PlaySound(n"Button", n"OnPress");
      controller = inkWidgetRef.GetController(this.m_sortingDropdown) as DropdownListController;
      controller.Toggle();
    };
  }

  protected cb func OnSetUserData(userData: ref<IScriptable>) -> Bool {
    this.m_vendorUserData = userData as VendorUserData;
  }

  private final func UpdateVendorMoney() -> Void {
    let vendorMoney: Int32 = MarketSystem.GetVendorMoney(this.m_VendorDataManager.GetVendorInstance());
    this.m_ripperId.SetMoney(vendorMoney);
  }

  private final func UpdatePlayerMoney() -> Void {
    inkTextRef.SetText(this.m_playerMoney, IntToString(this.m_VendorDataManager.GetLocalPlayerCurrencyAmount()));
  }

  private final func RegisterInventoryListener(player: ref<GameObject>) -> Void {
    let itemBoughtCallback: ref<RipperDocItemBoughtCallback> = new RipperDocItemBoughtCallback();
    itemBoughtCallback.itemID = ItemID.undefined();
    itemBoughtCallback.Bind(this);
    this.m_inventoryListener = GameInstance.GetTransactionSystem(player.GetGame()).RegisterInventoryListener(player, itemBoughtCallback);
  }

  private final func UnregisterInventoryListener(player: ref<GameObject>) -> Void {
    if IsDefined(this.m_inventoryListener) {
      GameInstance.GetTransactionSystem(player.GetGame()).UnregisterInventoryListener(player, this.m_inventoryListener);
      this.m_inventoryListener = null;
    };
  }

  public final func OnItemBought(itemID: ItemID, itemData: wref<gameItemData>) -> Void {
    this.m_InventoryManager.MarkToRebuild();
    this.UpdateVendorMoney();
    this.UpdatePlayerMoney();
    this.SetInventoryCWList();
    this.EquipCyberware(itemData);
  }

  public final func OnItemSold(itemID: ItemID) -> Void {
    this.m_InventoryManager.MarkToRebuild();
    this.UpdateVendorMoney();
    this.UpdatePlayerMoney();
    this.SetInventoryCWList();
  }

  private final func EquipCyberware(itemData: wref<gameItemData>) -> Void {
    let additionalInfo: ref<VendorRequirementsNotMetNotificationData>;
    let equipRequest: ref<EquipRequest>;
    let notification: ref<UIMenuNotificationEvent>;
    if !EquipmentSystem.GetInstance(this.m_player).GetPlayerData(this.m_player).IsEquippable(itemData) {
      notification = new UIMenuNotificationEvent();
      notification.m_notificationType = UIMenuNotificationType.VendorRequirementsNotMet;
      additionalInfo = new VendorRequirementsNotMetNotificationData();
      additionalInfo.m_data = this.GetEquipRequirements(itemData);
      notification.m_additionalInfo = ToVariant(additionalInfo);
      GameInstance.GetUISystem(this.m_player.GetGame()).QueueEvent(notification);
      return;
    };
    this.m_activeSlotIndex = this.m_equipmentGrid.GetSlotToEquipe(itemData.GetID());
    this.m_equiped = false;
    equipRequest = new EquipRequest();
    equipRequest.owner = this.m_player;
    equipRequest.itemID = itemData.GetID();
    equipRequest.slotIndex = this.m_activeSlotIndex;
    this.PlaySound(n"ItemCyberware", n"OnInstall");
    GameInstance.GetScriptableSystemsContainer(this.m_player.GetGame()).Get(n"EquipmentSystem").QueueRequest(equipRequest);
  }

  private final func Init() -> Void {
    let isFemaleCharacter: Bool;
    this.m_player = this.GetPlayerControlledObject() as PlayerPuppet;
    this.m_TooltipsManager = inkWidgetRef.GetControllerByType(this.m_TooltipsManagerRef, n"gameuiTooltipsManager") as gameuiTooltipsManager;
    this.m_TooltipsManager.Setup(ETooltipsStyle.Menus);
    this.SetFilters();
    this.m_buttonHintsController = this.SpawnFromExternal(inkWidgetRef.Get(this.m_buttonHintsManagerRef), r"base\\gameplay\\gui\\common\\buttonhints.inkwidget", n"Root").GetController() as ButtonHints;
    this.m_InventoryManager = new InventoryDataManagerV2();
    this.m_InventoryManager.Initialize(this.m_player);
    this.m_uiScriptableSystem = UIScriptableSystem.GetInstance(this.m_player.GetGame());
    this.m_cyberwaregDataView.BindUIScriptableSystem(this.m_uiScriptableSystem);
    this.RegisterBlackboard(this.GetPlayerControlledObject());
    this.PrepareCyberwareSlots();
    isFemaleCharacter = this.IsGenderFemale();
    inkWidgetRef.SetVisible(this.m_femaleHovers, isFemaleCharacter);
    inkWidgetRef.SetVisible(this.m_maleHovers, !isFemaleCharacter);
    inkWidgetRef.SetVisible(this.m_woman_wiresTexture, isFemaleCharacter);
    inkWidgetRef.SetVisible(this.m_man_wiresTexture, !isFemaleCharacter);
    this.OpenDefaultMode();
    this.m_ripperId.PlayIntoAnimation();
    this.PlayLibraryAnimation(n"Paperdoll_default_tab_intro");
  }

  protected final func RegisterBlackboard(player: ref<GameObject>) -> Void {
    this.m_equipmentBlackboard = GameInstance.GetBlackboardSystem(player.GetGame()).Get(GetAllBlackboardDefs().UI_Equipment);
    if IsDefined(this.m_equipmentBlackboard) {
      this.m_equipmentBlackboardCallback = this.m_equipmentBlackboard.RegisterDelayedListenerVariant(GetAllBlackboardDefs().UI_Equipment.itemEquipped, this, n"OnItemEquiped");
    };
    this.m_VendorBlackboard = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UI_Vendor);
  }

  protected final func UnregisterBlackboard() -> Void {
    if IsDefined(this.m_equipmentBlackboard) {
      this.m_equipmentBlackboard.UnregisterListenerVariant(GetAllBlackboardDefs().UI_Equipment.itemEquipped, this.m_equipmentBlackboardCallback);
    };
    this.m_VendorBlackboard = null;
  }

  private final func PlayIntroAnimation(area: gamedataEquipmentArea, female: Bool) -> Void {
    let animName: CName;
    if this.m_introPaperdollAnimation.IsPlaying() {
      this.m_introPaperdollAnimation.GotoStartAndStop();
    };
    if this.m_outroPaperdollAnimation.IsPlaying() {
      this.m_outroPaperdollAnimation.GotoStartAndStop();
    };
    switch area {
      case gamedataEquipmentArea.FrontalCortexCW:
        animName = n"frontalCortex_intro";
        break;
      case gamedataEquipmentArea.EyesCW:
        animName = n"ocular_intro";
        break;
      case gamedataEquipmentArea.CardiovascularSystemCW:
        animName = n"circlatory_intro";
        break;
      case gamedataEquipmentArea.ImmuneSystemCW:
        animName = n"immune_intro";
        break;
      case gamedataEquipmentArea.NervousSystemCW:
        animName = n"nervous_intro";
        break;
      case gamedataEquipmentArea.IntegumentarySystemCW:
        animName = n"integumentary_intro";
        break;
      case gamedataEquipmentArea.SystemReplacementCW:
        animName = n"operating_intro";
        break;
      case gamedataEquipmentArea.MusculoskeletalSystemCW:
        animName = n"skeleton_intro";
        break;
      case gamedataEquipmentArea.HandsCW:
        animName = n"hands_intro";
        break;
      case gamedataEquipmentArea.ArmsCW:
        animName = n"arms_intro";
        break;
      case gamedataEquipmentArea.LegsCW:
        animName = n"legs_intro";
    };
    animName = female ? animName : n"M_" + animName;
    inkWidgetRef.SetVisible(this.m_itemAnimationTab, true);
    this.m_introPaperdollAnimation = this.PlayLibraryAnimation(animName);
    this.m_introPaperdollAnimation.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnIntroPaperdollAnimationFinished");
  }

  protected cb func OnIntroPaperdollAnimationFinished(anim: ref<inkAnimProxy>) -> Bool {
    this.m_introPaperdollAnimation.UnregisterFromCallback(inkanimEventType.OnFinish, this, n"OnIntroPaperdollAnimationFinished");
    inkWidgetRef.SetVisible(this.m_defaultAnimationTab, false);
  }

  private final func PlayOutroAnimation(area: gamedataEquipmentArea, female: Bool) -> Void {
    let animName: CName;
    if this.m_introPaperdollAnimation.IsPlaying() {
      this.m_introPaperdollAnimation.GotoStartAndStop();
    };
    if this.m_outroPaperdollAnimation.IsPlaying() {
      this.m_outroPaperdollAnimation.GotoStartAndStop();
    };
    switch area {
      case gamedataEquipmentArea.FrontalCortexCW:
        animName = n"frontalCortex_outro";
        break;
      case gamedataEquipmentArea.EyesCW:
        animName = n"ocular_outro";
        break;
      case gamedataEquipmentArea.CardiovascularSystemCW:
        animName = n"circlatory_outro";
        break;
      case gamedataEquipmentArea.ImmuneSystemCW:
        animName = n"immune_outro";
        break;
      case gamedataEquipmentArea.NervousSystemCW:
        animName = n"nervous_outro";
        break;
      case gamedataEquipmentArea.IntegumentarySystemCW:
        animName = n"integumentary_outro";
        break;
      case gamedataEquipmentArea.SystemReplacementCW:
        animName = n"operating_outro";
        break;
      case gamedataEquipmentArea.MusculoskeletalSystemCW:
        animName = n"skeleton_outro";
        break;
      case gamedataEquipmentArea.HandsCW:
        animName = n"hands_outro";
        break;
      case gamedataEquipmentArea.ArmsCW:
        animName = n"arms_outro";
        break;
      case gamedataEquipmentArea.LegsCW:
        animName = n"legs_outro";
    };
    animName = female ? animName : n"M_" + animName;
    inkWidgetRef.SetVisible(this.m_defaultAnimationTab, true);
    this.m_outroPaperdollAnimation = this.PlayLibraryAnimation(animName);
    this.m_outroPaperdollAnimation.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnOutroPaperdollAnimationFinished");
  }

  protected cb func OnOutroPaperdollAnimationFinished(anim: ref<inkAnimProxy>) -> Bool {
    this.m_outroPaperdollAnimation.UnregisterFromCallback(inkanimEventType.OnFinish, this, n"OnOutroPaperdollAnimationFinished");
    inkWidgetRef.SetVisible(this.m_itemAnimationTab, false);
  }

  private final func GetHoverAnimationTarget(area: gamedataEquipmentArea, female: Bool) -> wref<inkWidget> {
    let target: wref<inkWidget>;
    switch area {
      case gamedataEquipmentArea.FrontalCortexCW:
        target = female ? inkWidgetRef.Get(this.m_F_frontalCortexHoverTexture) : inkWidgetRef.Get(this.m_M_frontalCortexHoverTexture);
        break;
      case gamedataEquipmentArea.EyesCW:
        target = female ? inkWidgetRef.Get(this.m_F_eyesHoverTexture) : inkWidgetRef.Get(this.m_M_eyesHoverTexture);
        break;
      case gamedataEquipmentArea.CardiovascularSystemCW:
        target = female ? inkWidgetRef.Get(this.m_F_cardiovascularHoverTexture) : inkWidgetRef.Get(this.m_M_cardiovascularHoverTexture);
        break;
      case gamedataEquipmentArea.ImmuneSystemCW:
        target = female ? inkWidgetRef.Get(this.m_F_immuneHoverTexture) : inkWidgetRef.Get(this.m_M_immuneHoverTexture);
        break;
      case gamedataEquipmentArea.NervousSystemCW:
        target = female ? inkWidgetRef.Get(this.m_F_nervousHoverTexture) : inkWidgetRef.Get(this.m_M_nervousHoverTexture);
        break;
      case gamedataEquipmentArea.IntegumentarySystemCW:
        target = female ? inkWidgetRef.Get(this.m_F_integumentaryHoverTexture) : inkWidgetRef.Get(this.m_M_integumentaryHoverTexture);
        break;
      case gamedataEquipmentArea.SystemReplacementCW:
        target = female ? inkWidgetRef.Get(this.m_F_systemReplacementHoverTexture) : inkWidgetRef.Get(this.m_M_systemReplacementHoverTexture);
        break;
      case gamedataEquipmentArea.MusculoskeletalSystemCW:
        target = female ? inkWidgetRef.Get(this.m_F_musculoskeletalHoverTexture) : inkWidgetRef.Get(this.m_M_musculoskeletalHoverTexture);
        break;
      case gamedataEquipmentArea.HandsCW:
        target = female ? inkWidgetRef.Get(this.m_F_handsHoverTexture) : inkWidgetRef.Get(this.m_M_handsHoverTexture);
        break;
      case gamedataEquipmentArea.ArmsCW:
        target = female ? inkWidgetRef.Get(this.m_F_armsHoverTexture) : inkWidgetRef.Get(this.m_M_armsHoverTexture);
        break;
      case gamedataEquipmentArea.LegsCW:
        target = female ? inkWidgetRef.Get(this.m_F_legsHoverTexture) : inkWidgetRef.Get(this.m_M_legsHoverTexture);
    };
    return target;
  }

  private final func PlayHoverAnimation(area: gamedataEquipmentArea) -> Void {
    let target: wref<inkWidget>;
    if this.m_hoverAnimation.IsPlaying() {
      this.m_hoverAnimation.GotoEndAndStop();
    };
    if this.IsTransitionAnimationPlaying() || NotEquals(this.m_mode, RipperdocModes.Default) {
      return;
    };
    this.m_selectedArea = area;
    target = this.GetHoverAnimationTarget(area, this.IsGenderFemale());
    this.m_hoverAnimation = this.PlayLibraryAnimationOnTargets(n"hover_area", SelectWidgets(target));
  }

  private final func PlayHoverOverAnimation(area: gamedataEquipmentArea) -> Void {
    let target: wref<inkWidget>;
    if this.m_hoverOverAnimation.IsPlaying() {
      this.m_hoverOverAnimation.GotoEndAndStop();
    };
    if this.IsTransitionAnimationPlaying() || NotEquals(this.m_mode, RipperdocModes.Default) {
      return;
    };
    target = this.GetHoverAnimationTarget(area, this.IsGenderFemale());
    this.m_hoverOverAnimation = this.PlayLibraryAnimationOnTargets(n"hoverover_area", SelectWidgets(target));
  }

  private final func PrepareCyberwareSlots() -> Void {
    inkCompoundRef.RemoveAllChildren(this.m_rightButtomGridAnchor);
    inkCompoundRef.RemoveAllChildren(this.m_frontalCortexAnchor);
    inkCompoundRef.RemoveAllChildren(this.m_ocularCortexAnchor);
    inkCompoundRef.RemoveAllChildren(this.m_leftMiddleGridAnchor);
    inkCompoundRef.RemoveAllChildren(this.m_leftButtomGridAnchor);
    inkCompoundRef.RemoveAllChildren(this.m_rightTopGridAnchor);
    inkCompoundRef.RemoveAllChildren(this.m_skeletonAnchor);
    inkCompoundRef.RemoveAllChildren(this.m_handsAnchor);
    this.SpawnCWAreaGrid(gamedataEquipmentArea.FrontalCortexCW, this.m_frontalCortexAnchor, inkEHorizontalAlign.Right);
    this.SpawnCWAreaGrid(gamedataEquipmentArea.EyesCW, this.m_ocularCortexAnchor, inkEHorizontalAlign.Right);
    this.SpawnCWAreaGrid(gamedataEquipmentArea.CardiovascularSystemCW, this.m_leftMiddleGridAnchor, inkEHorizontalAlign.Right);
    this.SpawnCWAreaGrid(gamedataEquipmentArea.ImmuneSystemCW, this.m_leftButtomGridAnchor, inkEHorizontalAlign.Right);
    this.SpawnCWAreaGrid(gamedataEquipmentArea.NervousSystemCW, this.m_leftButtomGridAnchor, inkEHorizontalAlign.Right);
    this.SpawnCWAreaGrid(gamedataEquipmentArea.IntegumentarySystemCW, this.m_leftButtomGridAnchor, inkEHorizontalAlign.Right);
    this.SpawnCWAreaGrid(gamedataEquipmentArea.SystemReplacementCW, this.m_rightTopGridAnchor, inkEHorizontalAlign.Left);
    this.SpawnCWAreaGrid(gamedataEquipmentArea.MusculoskeletalSystemCW, this.m_skeletonAnchor, inkEHorizontalAlign.Left);
    this.SpawnCWAreaGrid(gamedataEquipmentArea.HandsCW, this.m_handsAnchor, inkEHorizontalAlign.Left);
    this.SpawnCWAreaGrid(gamedataEquipmentArea.ArmsCW, this.m_rightButtomGridAnchor, inkEHorizontalAlign.Left);
    this.SpawnCWAreaGrid(gamedataEquipmentArea.LegsCW, this.m_rightButtomGridAnchor, inkEHorizontalAlign.Left);
  }

  private final func SpawnCWAreaGrid(equipArea: gamedataEquipmentArea, parentRef: inkCompoundRef, align: inkEHorizontalAlign) -> Void {
    let gridUserData: ref<GridUserData> = new GridUserData();
    gridUserData.equipArea = equipArea;
    gridUserData.align = align;
    let widgetName: CName = Equals(align, inkEHorizontalAlign.Right) ? n"cyberwareInventoryMiniGridLeft" : n"cyberwareInventoryMiniGridRight";
    this.AsyncSpawnFromLocal(inkWidgetRef.Get(parentRef), widgetName, this, n"OnGridSpawned", gridUserData);
  }

  protected cb func OnGridSpawned(widget: ref<inkWidget>, userData: ref<IScriptable>) -> Bool {
    let amountOfNewItems: Int32;
    let cyberwares: array<InventoryItemData>;
    let i: Int32;
    let itemData: InventoryItemData;
    let minigridController: ref<CyberwareInventoryMiniGrid>;
    let numSlots: Int32;
    let gridUserData: ref<GridUserData> = userData as GridUserData;
    widget.SetHAlign(gridUserData.align);
    minigridController = widget.GetController() as CyberwareInventoryMiniGrid;
    numSlots = this.m_InventoryManager.GetNumberOfSlots(gridUserData.equipArea);
    i = 0;
    while i < numSlots {
      itemData = this.m_InventoryManager.GetItemDataEquippedInArea(gridUserData.equipArea, i);
      InventoryItemData.SetEquipmentArea(itemData, gridUserData.equipArea);
      ArrayPush(cyberwares, itemData);
      i += 1;
    };
    amountOfNewItems = Equals(this.m_screen, CyberwareScreenType.Ripperdoc) ? this.GetAmountOfAvailableItems(gridUserData.equipArea) : this.GetAmountOfMods(itemData);
    minigridController.SetupData(gridUserData.equipArea, cyberwares, amountOfNewItems, this, Equals(this.m_mode, RipperdocModes.Item) ? n"OnEquipmentSlotClick" : n"OnPreviewCyberwareClick", this.m_screen, InventoryItemData.GetAttachmentsSize(itemData) > 0);
    ArrayPush(this.m_cyberareGrids, minigridController);
  }

  private final func UpdateCWAreaGrid(selectedArea: gamedataEquipmentArea) -> Void {
    let amountOfNewItems: Int32;
    let cyberwares: array<InventoryItemData>;
    let itemData: InventoryItemData;
    let numSlots: Int32 = this.m_InventoryManager.GetNumberOfSlots(selectedArea);
    let i: Int32 = 0;
    while i < numSlots {
      itemData = this.m_InventoryManager.GetItemDataEquippedInArea(selectedArea, i);
      InventoryItemData.SetEquipmentArea(itemData, selectedArea);
      ArrayPush(cyberwares, itemData);
      i += 1;
    };
    amountOfNewItems = Equals(this.m_screen, CyberwareScreenType.Ripperdoc) ? this.GetAmountOfAvailableItems(selectedArea) : this.GetAmountOfMods(itemData);
    i = 0;
    while i < ArraySize(this.m_cyberareGrids) {
      if Equals(this.m_cyberareGrids[i].GetEquipementArea(), selectedArea) {
        this.m_cyberareGrids[i].UpdateData(selectedArea, cyberwares, amountOfNewItems, this.m_screen);
        return;
      };
      i += 1;
    };
  }

  private final func SelectSlot(newSlotIndex: Int32) -> Void {
    this.m_equipmentGrid.SelectSlot(newSlotIndex);
    this.UpdateTooltipData(this.m_equipmentGrid.GetSelectedSlotData());
  }

  private final func UpdateTooltipData(itemData: InventoryItemData) -> Void {
    let targetCyberwareInfoType: CyberwareInfoType;
    let tooltipsData: ref<InventoryTooltipData>;
    if InventoryItemData.IsEmpty(itemData) {
      inkWidgetRef.SetVisible(this.m_cyberwareInfoContainer, false);
      return;
    };
    if InventoryItemData.GetGameItemData(itemData).HasTag(n"Cyberdeck") {
      targetCyberwareInfoType = CyberwareInfoType.Cyberdeck;
    };
    inkWidgetRef.SetVisible(this.m_cyberwareInfoContainer, true);
    if this.m_cyberwareInfo == null || NotEquals(this.m_cyberwareInfoType, targetCyberwareInfoType) {
      inkCompoundRef.RemoveAllChildren(this.m_cyberwareInfoContainer);
      this.m_cyberwareInfo = null;
      if Equals(targetCyberwareInfoType, CyberwareInfoType.Cyberdeck) {
        this.m_cyberwareInfo = this.SpawnFromExternal(inkWidgetRef.Get(this.m_cyberwareInfoContainer), r"base\\gameplay\\gui\\common\\tooltip\\cyberdecktooltip.inkwidget", n"cyberdeckTooltip").GetController() as AGenericTooltipController;
      } else {
        this.m_cyberwareInfo = this.SpawnFromExternal(inkWidgetRef.Get(this.m_cyberwareInfoContainer), r"base\\gameplay\\gui\\common\\tooltip\\tooltipslibrary_4k.inkwidget", n"itemTooltip").GetController() as AGenericTooltipController;
      };
      this.m_cyberwareInfoType = targetCyberwareInfoType;
    };
    tooltipsData = this.m_InventoryManager.GetTooltipDataForInventoryItem(itemData, InventoryItemData.IsEquipped(itemData));
    this.m_equipmentGrid.UpdateTitle(tooltipsData.itemName);
    this.m_cyberwareInfo.SetData(tooltipsData);
    inkWidgetRef.SetVisible(this.m_cyberwareInfoContainer, true);
    this.PlayLibraryAnimationOnTargets(n"tooltipContainer_change", SelectWidgets(inkWidgetRef.Get(this.m_cyberwareInfoContainer)));
  }

  private final func GetAmountOfAvailableItems(equipArea: gamedataEquipmentArea) -> Int32 {
    let ripperdocInventory: array<InventoryItemData> = this.GetRipperdocItemsForEquipmentArea(equipArea);
    let playerInventory: array<InventoryItemData> = this.m_InventoryManager.GetPlayerInventoryData(equipArea);
    let i: Int32 = 0;
    while i < ArraySize(playerInventory) {
      if !InventoryItemData.IsEquipped(playerInventory[i]) {
        ArrayPush(ripperdocInventory, playerInventory[i]);
      };
      i = i + 1;
    };
    return ArraySize(ripperdocInventory);
  }

  private final func GetAmountOfMods(itemData: InventoryItemData) -> Int32 {
    let attachments: InventoryItemAttachments;
    let i: Int32;
    let mods: array<InventoryItemData>;
    let modsCount: Int32;
    let slotsCount: Int32 = InventoryItemData.GetAttachmentsSize(itemData);
    if NotEquals(InventoryItemData.GetEquipmentArea(itemData), gamedataEquipmentArea.ArmsCW) && slotsCount > 0 {
      attachments = InventoryItemData.GetAttachment(itemData, 0);
      mods = this.m_InventoryManager.GetPlayerInventoryPartsForItem(InventoryItemData.GetID(itemData), attachments.SlotID);
      return ArraySize(mods);
    };
    i = 0;
    while i < slotsCount {
      attachments = InventoryItemData.GetAttachment(itemData, i);
      mods = this.m_InventoryManager.GetPlayerInventoryPartsForItem(InventoryItemData.GetID(itemData), attachments.SlotID);
      modsCount += ArraySize(mods);
      i += 1;
    };
    return modsCount;
  }

  private final func IsGenderFemale() -> Bool {
    return Equals(this.m_player.GetResolvedGenderName(), n"Female");
  }

  protected cb func OnVendorUpdated(value: Variant) -> Bool;

  protected cb func OnSetMenuEventDispatcher(menuEventDispatcher: wref<inkMenuEventDispatcher>) -> Bool {
    super.OnSetMenuEventDispatcher(menuEventDispatcher);
    this.m_menuEventDispatcher = menuEventDispatcher;
    this.m_menuEventDispatcher.RegisterToEvent(n"OnBack", this, n"OnBack");
  }

  protected cb func OnBack(userData: ref<IScriptable>) -> Bool {
    switch this.m_mode {
      case RipperdocModes.Default:
        if Equals(this.m_screen, CyberwareScreenType.Inventory) {
          super.OnBack(userData);
        } else {
          if !StatusEffectSystem.ObjectHasStatusEffectWithTag(this.GetPlayerControlledObject(), n"LockInHubMenu") {
            this.CloseVendor();
          };
        };
        break;
      case RipperdocModes.Item:
        this.OpenDefaultMode();
    };
  }

  private final func RefreshUI() -> Void {
    this.m_InventoryManager.MarkToRebuild();
    switch this.m_mode {
      case RipperdocModes.Default:
        this.OpenDefaultMode();
        break;
      case RipperdocModes.Item:
        this.OpenItemMode();
    };
  }

  private final func SwapMode(mode: RipperdocModes) -> Void {
    this.m_mode = mode;
  }

  private final func CloseVendor() -> Void {
    this.m_menuEventDispatcher.SpawnEvent(n"OnVendorClose");
  }

  protected cb func OnItemEquiped(value: Variant) -> Bool {
    if !this.m_equiped {
      this.SetInventoryCWList();
      this.SetEquipmentGrid();
      this.PlayLibraryAnimation(n"filter_change");
      this.m_equiped = true;
    };
  }

  protected cb func OnPreviewCyberwareClick(evt: ref<inkPointerEvent>) -> Bool {
    let itemController: wref<InventoryItemDisplayController>;
    let itemData: InventoryItemData;
    let openModsScreenEvent: ref<CyberwareTabModsRequest>;
    if evt.IsAction(n"select") {
      itemController = this.GetCyberwareSlotControllerFromTarget(evt);
      this.m_selectedArea = itemController.GetEquipmentArea();
      this.m_activeSlotIndex = itemController.GetSlotIndex();
      this.PlaySound(n"Button", n"OnPress");
      switch this.m_screen {
        case CyberwareScreenType.Ripperdoc:
          this.OpenItemMode();
          break;
        case CyberwareScreenType.Inventory:
          itemData = itemController.GetItemData();
          if InventoryItemData.GetAttachmentsSize(itemData) > 0 {
            openModsScreenEvent = new CyberwareTabModsRequest();
            openModsScreenEvent.open = true;
            openModsScreenEvent.wrapper = new CyberwareDisplayWrapper();
            openModsScreenEvent.wrapper.displayData = itemController.GetItemDisplayData();
            this.QueueEvent(openModsScreenEvent);
          };
      };
    };
  }

  protected cb func OnEquipmentSlotClick(evt: ref<inkPointerEvent>) -> Bool {
    let itemController: wref<InventoryItemDisplayController>;
    if evt.IsAction(n"select") {
      this.PlaySound(n"Button", n"OnPress");
      itemController = this.GetCyberwareSlotControllerFromTarget(evt);
      this.SelectSlot(itemController.GetSlotIndex());
    };
  }

  private final func OpenDefaultMode() -> Void {
    this.StopAllAnimations();
    this.SwapMode(RipperdocModes.Default);
    this.HideItemMode();
    inkWidgetRef.SetVisible(this.m_defaultTab, true);
    this.UpdateCWAreaGrid(this.m_selectedArea);
    this.m_introDefaultAnimation = this.PlayLibraryAnimation(n"default_tab_intro");
    if NotEquals(this.m_selectedArea, gamedataEquipmentArea.Invalid) {
      this.PlayOutroAnimation(this.m_selectedArea, this.IsGenderFemale());
    };
    this.ProcessRipperdocSlotsModeTutorial();
    this.SetDefaultModeButtonHints();
  }

  private final func HideDefaultMode() -> Void {
    this.StopAllAnimations();
    this.m_outroDefaultAnimation = this.PlayLibraryAnimation(n"default_tab_outro");
    this.m_outroDefaultAnimation.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnDefaultTabOutroAnimFinished");
    this.PlayIntroAnimation(this.m_selectedArea, this.IsGenderFemale());
  }

  protected cb func OnDefaultTabOutroAnimFinished(anim: ref<inkAnimProxy>) -> Bool {
    this.m_outroDefaultAnimation.UnregisterFromCallback(inkanimEventType.OnFinish, this, n"OnDefaultTabOutroAnimFinished");
    inkWidgetRef.SetVisible(this.m_defaultTab, false);
  }

  private func ReadUICondition(condition: gamedataUICondition) -> Bool {
    switch condition {
      case gamedataUICondition.InSubMenu:
        return Equals(this.m_mode, RipperdocModes.Item);
      case gamedataUICondition.InHandsSubMenu:
        return Equals(this.m_selectedArea, gamedataEquipmentArea.HandsCW);
      case gamedataUICondition.InEyesSubMenu:
        return Equals(this.m_selectedArea, gamedataEquipmentArea.EyesCW);
    };
    return false;
  }

  private final func OpenItemMode() -> Void {
    this.StopAllAnimations();
    this.HideDefaultMode();
    this.m_equiped = true;
    inkWidgetRef.SetVisible(this.m_itemTab, true);
    this.SwapMode(RipperdocModes.Item);
    this.SetInventoryCWList();
    this.SetEquipmentGrid();
    this.ProcessRipperdocItemModeTutorial();
    this.SetItemModeButtonHints();
    this.PlayLibraryAnimation(n"item_tab_intro");
    this.PlayLibraryAnimationOnTargets(n"item_tab_miniGrid_intro", SelectWidgets(this.m_equipmentGrid.GetRootWidget()));
  }

  protected final func ProcessRipperdocSlotsModeTutorial() -> Void {
    if GameInstance.GetQuestsSystem(this.m_player.GetGame()).GetFact(n"tutorial_ripperdoc_slots") == 0 && Equals(this.m_screen, CyberwareScreenType.Ripperdoc) {
      GameInstance.GetQuestsSystem(this.m_player.GetGame()).SetFact(n"tutorial_ripperdoc_slots", 1);
    };
  }

  protected final func ProcessRipperdocItemModeTutorial() -> Void {
    if GameInstance.GetQuestsSystem(this.m_player.GetGame()).GetFact(n"tutorial_ripperdoc_buy") == 0 && Equals(this.m_screen, CyberwareScreenType.Ripperdoc) {
      GameInstance.GetQuestsSystem(this.m_player.GetGame()).SetFact(n"tutorial_ripperdoc_buy", 1);
    };
  }

  private final func HideItemMode() -> Void {
    inkWidgetRef.SetVisible(this.m_itemTab, false);
  }

  private final func SetEquipmentGrid() -> Void {
    let widget: wref<inkWidget>;
    let cyberwares: array<InventoryItemData> = this.GetEquippedCWList();
    if this.m_equipmentGrid == null {
      inkCompoundRef.RemoveAllChildren(this.m_cyberwareSlotsList);
      widget = this.SpawnFromLocal(inkWidgetRef.Get(this.m_cyberwareSlotsList), n"cyberwareInventoryMiniGrid");
      widget.SetHAlign(inkEHorizontalAlign.Fill);
      this.m_equipmentGrid = widget.GetController() as CyberwareInventoryMiniGrid;
      this.m_equipmentGrid.SetupData(this.m_selectedArea, cyberwares, 0, this, n"OnEquipmentSlotClick", this.m_screen, false);
    } else {
      this.m_equipmentGrid.UpdateData(this.m_selectedArea, cyberwares);
    };
    this.SelectSlot(this.m_activeSlotIndex);
  }

  private final func GetEquippedCWList() -> array<InventoryItemData> {
    let cyberwares: array<InventoryItemData>;
    let itemData: InventoryItemData;
    let numSlots: Int32 = this.m_InventoryManager.GetNumberOfSlots(this.m_selectedArea);
    let i: Int32 = 0;
    while i < numSlots {
      itemData = this.m_InventoryManager.GetItemDataEquippedInArea(this.m_selectedArea, i);
      InventoryItemData.SetEquipmentArea(itemData, this.m_selectedArea);
      ArrayPush(cyberwares, itemData);
      i += 1;
    };
    return cyberwares;
  }

  private final func PlayAnim(animName: CName, opt callBack: CName, opt playbackOptions: inkAnimOptions) -> Void {
    if IsDefined(this.m_animationProxy) && this.m_animationProxy.IsPlaying() {
      this.m_animationProxy.GotoEndAndStop();
    };
    this.m_animationProxy = this.PlayLibraryAnimation(animName, playbackOptions);
    if NotEquals(callBack, n"") {
      this.m_animationProxy.RegisterToCallback(inkanimEventType.OnFinish, this, callBack);
    };
  }

  private final func SetInventoryCWList() -> Void {
    let isReqMet: Bool;
    let itemDatas: array<ref<IScriptable>>;
    let itemWrapper: ref<CyberwareDataWrapper>;
    let playerMoney: Int32;
    let ripperdocCyberwares: array<InventoryItemData> = this.GetRipperdocItemsForEquipmentArea(this.m_selectedArea);
    let playerCyberwares: array<InventoryItemData> = this.m_InventoryManager.GetPlayerInventoryData(this.m_selectedArea);
    let i: Int32 = 0;
    while i < ArraySize(playerCyberwares) {
      if !InventoryItemData.IsEquipped(playerCyberwares[i]) {
        InventoryItemData.SetEquipRequirement(playerCyberwares[i], this.GetEquipRequirements(InventoryItemData.GetGameItemData(playerCyberwares[i])));
        itemWrapper = new CyberwareDataWrapper();
        isReqMet = EquipmentSystem.GetInstance(this.m_player).GetPlayerData(this.m_player).IsEquippable(InventoryItemData.GetGameItemData(playerCyberwares[i]));
        InventoryItemData.SetIsEquippable(playerCyberwares[i], isReqMet);
        itemWrapper.InventoryItem = playerCyberwares[i];
        this.m_InventoryManager.GetOrCreateInventoryItemSortData(itemWrapper.InventoryItem, this.m_uiScriptableSystem);
        itemWrapper.IsVendor = false;
        ArrayPush(itemDatas, itemWrapper);
      };
      i = i + 1;
    };
    playerMoney = this.m_VendorDataManager.GetLocalPlayerCurrencyAmount();
    i = 0;
    while i < ArraySize(ripperdocCyberwares) {
      InventoryItemData.SetEquipRequirement(ripperdocCyberwares[i], this.GetEquipRequirements(InventoryItemData.GetGameItemData(ripperdocCyberwares[i])));
      itemWrapper = new CyberwareDataWrapper();
      itemWrapper.InventoryItem = ripperdocCyberwares[i];
      this.m_InventoryManager.GetOrCreateInventoryItemSortData(itemWrapper.InventoryItem, this.m_uiScriptableSystem);
      itemWrapper.IsVendor = true;
      itemWrapper.PlayerMoney = playerMoney;
      ArrayPush(itemDatas, itemWrapper);
      i = i + 1;
    };
    this.m_cyberwareDataSource.Reset(itemDatas);
  }

  private final func GetEquipRequirements(itemData: ref<gameItemData>) -> SItemStackRequirementData {
    let data: SItemStackRequirementData;
    let i: Int32;
    let prereqs: array<wref<IPrereq_Record>>;
    let statPrereq: ref<StatPrereq_Record>;
    RPGManager.GetItemRecord(itemData.GetID()).EquipPrereqs(prereqs);
    i = 0;
    while i < ArraySize(prereqs) {
      statPrereq = prereqs[i] as StatPrereq_Record;
      if IsDefined(statPrereq) {
        data.statType = IntEnum(Cast(EnumValueFromName(n"gamedataStatType", statPrereq.StatType())));
        data.requiredValue = statPrereq.ValueToCheck();
        return data;
      };
      i += 1;
    };
    return data;
  }

  protected cb func OnSlotClick(evt: ref<ItemDisplayClickEvent>) -> Bool {
    let additionalInfo: ref<VendorRequirementsNotMetNotificationData>;
    let itemGameData: wref<gameItemData>;
    let type: VendorConfirmationPopupType;
    let vendorNotification: ref<UIMenuNotificationEvent>;
    let itemData: InventoryItemData = evt.itemData;
    if !this.m_isActivePanel || InventoryItemData.IsEmpty(itemData) {
      return false;
    };
    itemGameData = InventoryItemData.GetGameItemData(itemData);
    if evt.actionName.IsAction(n"click") {
      this.PlaySound(n"Button", n"OnPress");
      if InventoryItemData.IsVendorItem(itemData) {
        if !InventoryItemData.IsRequirementMet(itemData) {
          vendorNotification = new UIMenuNotificationEvent();
          vendorNotification.m_notificationType = UIMenuNotificationType.VendorRequirementsNotMet;
          additionalInfo = new VendorRequirementsNotMetNotificationData();
          additionalInfo.m_data = InventoryItemData.GetRequirement(itemData);
          vendorNotification.m_additionalInfo = ToVariant(additionalInfo);
          GameInstance.GetUISystem(this.m_player.GetGame()).QueueEvent(vendorNotification);
        } else {
          if this.m_VendorDataManager.GetBuyingPrice(itemGameData.GetID()) > this.m_VendorDataManager.GetLocalPlayerCurrencyAmount() {
            vendorNotification = new UIMenuNotificationEvent();
            vendorNotification.m_notificationType = UIMenuNotificationType.VNotEnoughMoney;
            GameInstance.GetUISystem(this.m_player.GetGame()).QueueEvent(vendorNotification);
          } else {
            type = EquipmentSystem.GetInstance(this.m_player).GetPlayerData(this.m_player).IsEquippable(itemGameData) ? VendorConfirmationPopupType.BuyAndEquipCyberware : VendorConfirmationPopupType.BuyNotEquipableCyberware;
            this.OpenConfirmationPopup(itemData, this.m_VendorDataManager.GetBuyingPrice(itemGameData.GetID()), type, n"OnBuyConfirmationPopupClosed");
          };
        };
      } else {
        if !InventoryItemData.IsEquipped(itemData) && this.m_equiped {
          this.EquipCyberware(itemGameData);
        };
      };
    };
  }

  private final func OpenConfirmationPopup(itemData: InventoryItemData, price: Int32, type: VendorConfirmationPopupType, listener: CName) -> Void {
    let data: ref<VendorConfirmationPopupData> = new VendorConfirmationPopupData();
    data.notificationName = n"base\\gameplay\\gui\\widgets\\notifications\\vendor_confirmation.inkwidget";
    data.isBlocking = true;
    data.useCursor = true;
    data.queueName = n"modal_popup";
    data.itemData = itemData;
    data.quantity = InventoryItemData.GetQuantity(itemData);
    data.type = type;
    data.price = price;
    this.m_confirmationPopupToken = this.ShowGameNotification(data);
    this.m_confirmationPopupToken.RegisterListener(this, listener);
    this.m_buttonHintsController.Hide();
  }

  protected cb func OnBuyConfirmationPopupClosed(data: ref<inkGameNotificationData>) -> Bool {
    this.m_confirmationPopupToken = null;
    let resultData: ref<VendorConfirmationPopupCloseData> = data as VendorConfirmationPopupCloseData;
    if resultData.confirm {
      this.m_VendorDataManager.BuyItemFromVendor(InventoryItemData.GetGameItemData(resultData.itemData), InventoryItemData.GetQuantity(resultData.itemData));
    };
    this.m_buttonHintsController.Show();
    this.PlaySound(n"Button", n"OnPress");
  }

  protected cb func OnCyberwareSlotHoverOver(evt: ref<ItemDisplayHoverOverEvent>) -> Bool {
    this.InventoryItemHoverOver(evt.itemData);
    this.PlayHoverAnimation(InventoryItemData.GetEquipmentArea(evt.itemData));
  }

  protected cb func OnCyberwareSlotHoverOut(evt: ref<ItemDisplayHoverOutEvent>) -> Bool {
    this.HideTooltips();
    this.SetInventoryItemButtonHintsHoverOut();
    this.PlayHoverOverAnimation(this.m_selectedArea);
  }

  private final func InventoryItemHoverOver(itemData: InventoryItemData) -> Void {
    let equippedCyberwares: array<InventoryItemData>;
    let i: Int32;
    let itemTooltipData: ref<InventoryTooltipData>;
    this.HideTooltips();
    if InventoryItemData.IsEmpty(itemData) {
      return;
    };
    if InventoryItemData.IsEquipped(itemData) {
      itemTooltipData = this.m_InventoryManager.GetTooltipDataForInventoryItem(itemData, true, InventoryItemData.IsVendorItem(itemData));
    } else {
      equippedCyberwares = this.GetEquippedCWList();
      i = 0;
      while i < ArraySize(equippedCyberwares) {
        if !InventoryItemData.IsEmpty(equippedCyberwares[0]) {
          itemTooltipData = this.m_InventoryManager.GetComparisonTooltipsData(equippedCyberwares[0], itemData, false);
        };
        i += 1;
      };
      if itemTooltipData == null {
        itemTooltipData = this.m_InventoryManager.GetTooltipDataForInventoryItem(itemData, false, InventoryItemData.IsVendorItem(itemData));
      };
    };
    this.ShowCWTooltip(itemData, itemTooltipData);
    this.SetInventoryItemButtonHintsHoverOver(itemData);
  }

  private final func ShowCWTooltip(itemData: InventoryItemData, itemTooltipData: ref<InventoryTooltipData>) -> Void {
    if InventoryItemData.GetGameItemData(itemData).HasTag(n"Cyberdeck") {
      this.m_TooltipsManager.ShowTooltip(n"cyberdeckTooltip", itemTooltipData, new inkMargin(60.00, 60.00, 0.00, 0.00));
    } else {
      if Equals(InventoryItemData.GetItemType(itemData), gamedataItemType.Prt_Program) {
        this.m_TooltipsManager.ShowTooltip(n"programTooltip", itemTooltipData, new inkMargin(60.00, 60.00, 0.00, 0.00));
      } else {
        this.m_TooltipsManager.ShowTooltip(0, itemTooltipData, new inkMargin(60.00, 60.00, 0.00, 0.00));
      };
    };
  }

  private final func HideTooltips() -> Void {
    this.m_TooltipsManager.HideTooltips();
  }

  private final func SetDefaultModeButtonHints() -> Void {
    this.m_buttonHintsController.RemoveButtonHint(n"back");
    if !StatusEffectSystem.ObjectHasStatusEffectWithTag(this.GetPlayerControlledObject(), n"LockInHubMenu") || Equals(this.m_screen, CyberwareScreenType.Inventory) {
      this.m_buttonHintsController.AddButtonHint(n"back", GetLocalizedText("Common-Access-Close"));
    };
  }

  private final func SetItemModeButtonHints() -> Void {
    this.m_buttonHintsController.AddButtonHint(n"back", "UI-ScriptExports-Back0");
  }

  private final func SetInventoryItemButtonHintsHoverOver(displayingData: InventoryItemData) -> Void {
    if Equals(this.m_mode, RipperdocModes.Default) {
      if Equals(this.m_screen, CyberwareScreenType.Ripperdoc) {
        this.m_buttonHintsController.AddButtonHint(n"select", "Gameplay-Devices-Interactions-Open");
      } else {
        this.m_buttonHintsController.RemoveButtonHint(n"select");
        this.m_buttonHintsController.AddButtonHint(n"back", "UI-ScriptExports-Back0");
      };
    } else {
      if !InventoryItemData.IsEmpty(displayingData) && !InventoryItemData.IsEquipped(displayingData) {
        if !InventoryItemData.IsVendorItem(displayingData) {
          this.m_buttonHintsController.AddButtonHint(n"select", "Gameplay-Devices-Interactions-Equip");
        } else {
          this.m_buttonHintsController.AddButtonHint(n"select", "LocKey#17847");
        };
        this.SetCursorContext(n"Hover");
      } else {
        this.m_buttonHintsController.AddButtonHint(n"select", "LocKey#34928");
        this.SetCursorContext(n"Default");
      };
    };
  }

  private final func SetInventoryItemButtonHintsHoverOut() -> Void {
    this.m_buttonHintsController.RemoveButtonHint(n"select");
  }

  private final func OnIntro() -> Void;

  private final func OnOutro() -> Void;

  private final func GetCyberwareSlotControllerFromTarget(evt: ref<inkPointerEvent>) -> ref<InventoryItemDisplayController> {
    let widget: ref<inkWidget> = evt.GetCurrentTarget();
    let controller: wref<InventoryItemDisplayController> = widget.GetController() as InventoryItemDisplayController;
    return controller;
  }

  private final func GetRipperdocItemsForEquipmentArea(equipArea: gamedataEquipmentArea) -> array<InventoryItemData> {
    let gameData: ref<gameItemData>;
    let itemData: InventoryItemData;
    let itemDataArray: array<InventoryItemData>;
    let itemRecord: wref<Item_Record>;
    let data: array<ref<VendorGameItemData>> = this.m_VendorDataManager.GetRipperDocItems();
    let owner: wref<GameObject> = this.m_VendorDataManager.GetVendorInstance();
    let i: Int32 = 0;
    while i < ArraySize(data) {
      gameData = data[i].gameItemData;
      itemRecord = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(gameData.GetID()));
      if Equals(itemRecord.EquipArea().Type(), equipArea) {
        itemData = this.m_InventoryManager.GetInventoryItemData(owner, data[i].gameItemData, true);
        InventoryItemData.SetIsVendorItem(itemData, true);
        InventoryItemData.SetIsEquippable(itemData, EquipmentSystem.GetInstance(this.m_player).GetPlayerData(this.m_player).IsEquippable(data[i].gameItemData));
        InventoryItemData.SetIsRequirementMet(itemData, data[i].itemStack.isAvailable);
        InventoryItemData.SetRequirement(itemData, data[i].itemStack.requirement);
        ArrayPush(itemDataArray, itemData);
      };
      i += 1;
    };
    return itemDataArray;
  }
}

public class CyberwareTemplateClassifier extends inkVirtualItemTemplateClassifier {

  public func ClassifyItem(data: Variant) -> Uint32 {
    return 0u;
  }
}

public class CyberwareDataView extends ScriptableDataView {

  private let m_itemFilterType: RipperdocFilter;

  private let m_itemSortMode: ItemSortMode;

  private let m_uiScriptableSystem: wref<UIScriptableSystem>;

  public final func BindUIScriptableSystem(uiScriptableSystem: wref<UIScriptableSystem>) -> Void {
    this.m_uiScriptableSystem = uiScriptableSystem;
  }

  public final func SetFilterType(type: RipperdocFilter) -> Void {
    this.m_itemFilterType = type;
    this.Filter();
  }

  public func FilterItem(data: ref<IScriptable>) -> Bool {
    let m_wrappedData: ref<CyberwareDataWrapper> = data as CyberwareDataWrapper;
    switch this.m_itemFilterType {
      case RipperdocFilter.Player:
        return !InventoryItemData.IsVendorItem(m_wrappedData.InventoryItem);
      case RipperdocFilter.Vendor:
        return InventoryItemData.IsVendorItem(m_wrappedData.InventoryItem);
      default:
        return true;
    };
    return true;
  }

  public final func SetSortMode(mode: ItemSortMode) -> Void {
    this.m_itemSortMode = mode;
    this.EnableSorting();
    this.Sort();
    this.DisableSorting();
  }

  protected func PreSortingInjection(builder: ref<ItemCompareBuilder>) -> ref<ItemCompareBuilder> {
    return builder;
  }

  public func SortItem(left: ref<IScriptable>, right: ref<IScriptable>) -> Bool {
    let leftItem: InventoryItemSortData = InventoryItemData.GetSortData(left as CyberwareDataWrapper.InventoryItem);
    let rightItem: InventoryItemSortData = InventoryItemData.GetSortData(right as CyberwareDataWrapper.InventoryItem);
    switch this.m_itemSortMode {
      case ItemSortMode.NewItems:
        return this.PreSortingInjection(ItemCompareBuilder.Make(leftItem, rightItem)).NewItem(this.m_uiScriptableSystem).QualityDesc().ItemType().NameAsc().GetBool();
      case ItemSortMode.NameAsc:
        return this.PreSortingInjection(ItemCompareBuilder.Make(leftItem, rightItem)).NameAsc().QualityDesc().GetBool();
      case ItemSortMode.NameDesc:
        return this.PreSortingInjection(ItemCompareBuilder.Make(leftItem, rightItem)).NameDesc().QualityDesc().GetBool();
      case ItemSortMode.QualityAsc:
        return this.PreSortingInjection(ItemCompareBuilder.Make(leftItem, rightItem)).QualityDesc().NameAsc().QualityDesc().GetBool();
      case ItemSortMode.QualityDesc:
        return this.PreSortingInjection(ItemCompareBuilder.Make(leftItem, rightItem)).QualityAsc().NameAsc().QualityDesc().GetBool();
      case ItemSortMode.WeightAsc:
        return this.PreSortingInjection(ItemCompareBuilder.Make(leftItem, rightItem)).WeightAsc().NameAsc().QualityDesc().GetBool();
      case ItemSortMode.WeightDesc:
        return this.PreSortingInjection(ItemCompareBuilder.Make(leftItem, rightItem)).WeightDesc().NameAsc().QualityDesc().GetBool();
      case ItemSortMode.PriceAsc:
        return this.PreSortingInjection(ItemCompareBuilder.Make(leftItem, rightItem)).PriceAsc().NameAsc().QualityDesc().GetBool();
      case ItemSortMode.PriceDesc:
        return this.PreSortingInjection(ItemCompareBuilder.Make(leftItem, rightItem)).PriceDesc().NameAsc().QualityDesc().GetBool();
      case ItemSortMode.ItemType:
        return this.PreSortingInjection(ItemCompareBuilder.Make(leftItem, rightItem)).ItemType().NameAsc().QualityDesc().GetBool();
    };
    return this.PreSortingInjection(ItemCompareBuilder.Make(leftItem, rightItem)).QualityDesc().ItemType().NameAsc().GetBool();
  }
}

public class CyberwareItemLogicController extends inkVirtualCompoundItemController {

  protected edit let m_slotRoot: inkCompoundRef;

  protected let m_slot: wref<InventoryItemDisplayController>;

  public final func OnDataChanged(value: Variant) -> Void {
    let itemData: ref<CyberwareDataWrapper> = FromVariant(value) as CyberwareDataWrapper;
    if !IsDefined(this.m_slot) {
      this.m_slot = ItemDisplayUtils.SpawnCommonSlotController(this, inkWidgetRef.Get(this.m_slotRoot), n"itemDisplay") as InventoryItemDisplayController;
    };
    if itemData.IsVendor {
      this.m_slot.Setup(itemData.InventoryItem, ItemDisplayContext.Vendor, itemData.PlayerMoney >= Cast(InventoryItemData.GetBuyPrice(itemData.InventoryItem)));
    } else {
      this.m_slot.Setup(itemData.InventoryItem, ItemDisplayContext.VendorPlayer, true, true);
    };
  }
}

public class RipperdocIdPanel extends inkLogicController {

  protected edit let m_NameLabel: inkTextRef;

  protected edit let m_MoneyLabel: inkTextRef;

  public final func SetName(vendorName: String) -> Void {
    if !IsStringValid(vendorName) {
      vendorName = "MISSING VENDOR NAME";
    };
    inkTextRef.SetText(this.m_NameLabel, vendorName);
  }

  public final func SetMoney(money: Int32) -> Void {
    inkTextRef.SetText(this.m_MoneyLabel, IntToString(money));
  }

  public final func PlayIntoAnimation() -> Void {
    this.PlayLibraryAnimation(n"ripper_id");
  }
}
