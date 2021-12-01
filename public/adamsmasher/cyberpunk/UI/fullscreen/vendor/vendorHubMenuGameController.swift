
public class VendorHubMenuGameController extends gameuiMenuGameController {

  private edit let m_tabRootContainer: inkWidgetRef;

  private edit let m_tabRootRef: inkWidgetRef;

  private edit let m_playerCurrency: inkTextRef;

  private edit let m_vendorShopLabel: inkTextRef;

  private edit let m_notificationRoot: inkWidgetRef;

  private edit let m_playerWeight: inkTextRef;

  private edit let m_levelValue: inkTextRef;

  private edit let m_streetCredLabel: inkTextRef;

  private edit let m_levelBarProgress: inkWidgetRef;

  private edit let m_levelBarSpacer: inkWidgetRef;

  private edit let m_streetCredBarProgress: inkWidgetRef;

  private edit let m_streetCredBarSpacer: inkWidgetRef;

  private let m_VendorDataManager: ref<VendorDataManager>;

  private let m_vendorUserData: ref<VendorUserData>;

  private let m_vendorPanelData: ref<VendorPanelData>;

  private let m_storageUserData: ref<StorageUserData>;

  private let m_PDS: ref<PlayerDevelopmentSystem>;

  private let m_root: wref<inkWidget>;

  private let m_tabRoot: wref<TabRadioGroup>;

  public let m_VendorBlackboard: wref<IBlackboard>;

  public let m_playerStatsBlackboard: wref<IBlackboard>;

  public let m_VendorBlackboardDef: ref<UI_VendorDef>;

  public let m_VendorUpdatedCallbackID: ref<CallbackHandle>;

  public let m_weightListener: ref<CallbackHandle>;

  public let m_characterLevelListener: ref<CallbackHandle>;

  public let m_characterCurrentXPListener: ref<CallbackHandle>;

  public let m_characterCredListener: ref<CallbackHandle>;

  public let m_characterCredPointsListener: ref<CallbackHandle>;

  public let m_characterCurrentHealthListener: ref<CallbackHandle>;

  private let m_menuEventDispatcher: wref<inkMenuEventDispatcher>;

  private let m_player: wref<PlayerPuppet>;

  private let m_menuData: array<MenuData>;

  private let m_storageDef: ref<StorageBlackboardDef>;

  private let m_storageBlackboard: wref<IBlackboard>;

  protected cb func OnInitialize() -> Bool {
    this.SpawnFromLocal(inkWidgetRef.Get(this.m_notificationRoot), n"notification_layer");
  }

  protected cb func OnUninitialize() -> Bool {
    let vendorData: VendorData;
    vendorData.isActive = false;
    this.m_VendorBlackboard.SetVariant(GetAllBlackboardDefs().UI_Vendor.VendorData, ToVariant(vendorData), true);
    this.RemoveBB();
    this.UnregisterFromGlobalInputCallback(n"OnPostOnRelease", this, n"OnButtonRelease");
  }

  protected cb func OnSetUserData(userData: ref<IScriptable>) -> Bool {
    let requestStatsEvent: ref<RequestStatsBB>;
    let vendorData: VendorData;
    let vendorPanelData: ref<VendorPanelData>;
    this.m_storageDef = GetAllBlackboardDefs().StorageBlackboard;
    this.m_storageBlackboard = this.GetBlackboardSystem().Get(this.m_storageDef);
    let storageUserData: ref<StorageUserData> = FromVariant(this.m_storageBlackboard.GetVariant(this.m_storageDef.StorageData));
    if userData == null && storageUserData == null {
      return false;
    };
    vendorPanelData = userData as VendorPanelData;
    this.m_storageUserData = storageUserData;
    if IsDefined(vendorPanelData) {
      vendorData = vendorPanelData.data;
      this.m_vendorUserData = new VendorUserData();
      this.m_vendorUserData.vendorData = vendorPanelData;
      this.m_player = this.GetPlayerControlledObject() as PlayerPuppet;
      this.m_PDS = GameInstance.GetScriptableSystemsContainer(this.m_player.GetGame()).Get(n"PlayerDevelopmentSystem") as PlayerDevelopmentSystem;
      this.m_VendorDataManager = new VendorDataManager();
      this.m_VendorDataManager.Initialize(this.GetPlayerControlledObject(), vendorData.entityID);
      requestStatsEvent = new RequestStatsBB();
      requestStatsEvent.Set(this.m_player);
      this.m_PDS.QueueRequest(requestStatsEvent);
      this.Init();
    } else {
      if IsDefined(storageUserData) {
        this.m_player = this.GetPlayerControlledObject() as PlayerPuppet;
        this.m_PDS = GameInstance.GetScriptableSystemsContainer(this.m_player.GetGame()).Get(n"PlayerDevelopmentSystem") as PlayerDevelopmentSystem;
        this.m_VendorDataManager = new VendorDataManager();
        this.m_VendorDataManager.Initialize(this.GetPlayerControlledObject(), vendorData.entityID);
        requestStatsEvent = new RequestStatsBB();
        requestStatsEvent.Set(this.m_player);
        this.m_PDS.QueueRequest(requestStatsEvent);
        this.Init();
      };
    };
  }

  private final func Init() -> Void {
    this.RegisterToGlobalInputCallback(n"OnPostOnRelease", this, n"OnButtonRelease");
    this.RegisterToGlobalInputCallback(n"OnPostOnAxis", this, n"OnButtonRelease");
    this.m_root = this.GetRootWidget();
    this.SetupMenuTabs();
    this.SetupTopBar();
    this.SetupBB();
    this.OnPlayerWeightUpdated(-1.00);
  }

  private final func SetupBB() -> Void {
    let vendorData: VendorData;
    vendorData.isActive = true;
    this.m_VendorBlackboardDef = GetAllBlackboardDefs().UI_Vendor;
    this.m_VendorBlackboard = this.GetBlackboardSystem().Get(this.m_VendorBlackboardDef);
    this.m_VendorBlackboard.SetVariant(GetAllBlackboardDefs().UI_Vendor.VendorData, ToVariant(vendorData), true);
    this.m_playerStatsBlackboard = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UI_PlayerStats);
    this.m_weightListener = this.m_playerStatsBlackboard.RegisterDelayedListenerFloat(GetAllBlackboardDefs().UI_PlayerStats.currentInventoryWeight, this, n"OnPlayerWeightUpdated");
    this.m_characterLevelListener = this.m_playerStatsBlackboard.RegisterDelayedListenerInt(GetAllBlackboardDefs().UI_PlayerStats.Level, this, n"OnCharacterLevelUpdated");
    this.m_characterCurrentXPListener = this.m_playerStatsBlackboard.RegisterDelayedListenerInt(GetAllBlackboardDefs().UI_PlayerStats.CurrentXP, this, n"OnCharacterLevelCurrentXPUpdated");
    this.m_playerStatsBlackboard.SignalInt(GetAllBlackboardDefs().UI_PlayerStats.CurrentXP);
    this.m_characterCredListener = this.m_playerStatsBlackboard.RegisterDelayedListenerInt(GetAllBlackboardDefs().UI_PlayerStats.StreetCredLevel, this, n"OnCharacterStreetCredLevelUpdated");
    this.m_playerStatsBlackboard.SignalInt(GetAllBlackboardDefs().UI_PlayerStats.StreetCredLevel);
    this.m_characterCredPointsListener = this.m_playerStatsBlackboard.RegisterDelayedListenerInt(GetAllBlackboardDefs().UI_PlayerStats.StreetCredPoints, this, n"OnCharacterStreetCredPointsUpdated");
    this.m_playerStatsBlackboard.SignalInt(GetAllBlackboardDefs().UI_PlayerStats.StreetCredPoints);
    this.m_playerStatsBlackboard.SignalInt(GetAllBlackboardDefs().UI_PlayerStats.weightMax);
    this.m_playerStatsBlackboard.SignalInt(GetAllBlackboardDefs().UI_PlayerStats.Level);
    this.m_characterCurrentHealthListener = this.m_playerStatsBlackboard.RegisterDelayedListenerInt(GetAllBlackboardDefs().UI_PlayerStats.CurrentHealth, this, n"OnCharacterCurrentHealthUpdated");
    if IsDefined(this.m_VendorBlackboard) {
      this.m_VendorUpdatedCallbackID = this.m_VendorBlackboard.RegisterDelayedListenerVariant(this.m_VendorBlackboardDef.VendorData, this, n"OnVendorUpdated");
    };
  }

  private final func RemoveBB() -> Void {
    if IsDefined(this.m_VendorBlackboard) {
      this.m_VendorBlackboard.UnregisterDelayedListener(this.m_VendorBlackboardDef.VendorData, this.m_VendorUpdatedCallbackID);
    };
    if IsDefined(this.m_playerStatsBlackboard) {
      this.m_playerStatsBlackboard.UnregisterDelayedListener(GetAllBlackboardDefs().UI_PlayerStats.Level, this.m_characterLevelListener);
      this.m_playerStatsBlackboard.UnregisterDelayedListener(GetAllBlackboardDefs().UI_PlayerStats.CurrentXP, this.m_characterCurrentXPListener);
      this.m_playerStatsBlackboard.UnregisterDelayedListener(GetAllBlackboardDefs().UI_PlayerStats.StreetCredLevel, this.m_characterCredListener);
      this.m_playerStatsBlackboard.UnregisterDelayedListener(GetAllBlackboardDefs().UI_PlayerStats.StreetCredPoints, this.m_characterCredPointsListener);
      this.m_playerStatsBlackboard.UnregisterDelayedListener(GetAllBlackboardDefs().UI_PlayerStats.CurrentXP, this.m_characterCurrentHealthListener);
    };
    this.m_VendorBlackboard = null;
  }

  private final func SetupTopBar() -> Void {
    inkTextRef.SetText(this.m_playerCurrency, IntToString(this.m_VendorDataManager.GetLocalPlayerCurrencyAmount()));
    inkTextRef.SetText(this.m_vendorShopLabel, this.m_VendorDataManager.GetVendorName());
  }

  protected cb func OnPlayerWeightUpdated(value: Float) -> Bool {
    let gameInstance: GameInstance = this.m_player.GetGame();
    let carryCapacity: Int32 = Cast(GameInstance.GetStatsSystem(gameInstance).GetStatValue(Cast(this.m_player.GetEntityID()), gamedataStatType.CarryCapacity));
    inkTextRef.SetText(this.m_playerWeight, IntToString(RoundF(this.m_player.m_curInventoryWeight)) + " / " + carryCapacity);
  }

  protected cb func OnCharacterLevelUpdated(value: Int32) -> Bool {
    inkTextRef.SetText(this.m_levelValue, IntToString(value));
  }

  protected cb func OnCharacterLevelCurrentXPUpdated(value: Int32) -> Bool {
    let remainingXP: Int32 = this.m_PDS.GetRemainingExpForLevelUp(this.m_player, gamedataProficiencyType.Level);
    let percentageValue: Float = Cast(value) / Cast(remainingXP + value);
    inkWidgetRef.SetSizeCoefficient(this.m_levelBarProgress, percentageValue);
    inkWidgetRef.SetSizeCoefficient(this.m_levelBarSpacer, 1.00 - percentageValue);
  }

  protected cb func OnCharacterStreetCredLevelUpdated(value: Int32) -> Bool {
    inkTextRef.SetText(this.m_streetCredLabel, ToString(value));
  }

  protected cb func OnCharacterStreetCredPointsUpdated(value: Int32) -> Bool {
    let remainingXP: Int32 = this.m_PDS.GetRemainingExpForLevelUp(this.m_player, gamedataProficiencyType.StreetCred);
    let percentageValue: Float = Cast(value) / Cast(remainingXP + value);
    inkWidgetRef.SetSizeCoefficient(this.m_streetCredBarProgress, percentageValue);
    inkWidgetRef.SetSizeCoefficient(this.m_streetCredBarSpacer, 1.00 - percentageValue);
  }

  protected cb func OnCharacterCurrentHealthUpdated(value: Int32) -> Bool {
    if value <= 0 {
      this.CloseVendor();
    };
  }

  private final func SetupMenuTabs() -> Void {
    let icons: array<String>;
    let labels: array<String>;
    let selectedIdentifier: Int32;
    let vendorObject: wref<NPCPuppet> = this.m_VendorDataManager.GetVendorInstance() as NPCPuppet;
    let isRipperdoc: Bool = vendorObject.IsRipperdoc();
    inkWidgetRef.SetVisible(this.m_tabRootContainer, false);
    if IsDefined(this.m_vendorUserData) && isRipperdoc {
      this.m_tabRoot = inkWidgetRef.GetController(this.m_tabRootRef) as TabRadioGroup;
      ArrayPush(labels, "UI-PanelNames-TRADE");
      ArrayPush(labels, "UI-PanelNames-CYBERWARE");
      ArrayPush(icons, "ico_cyberware");
      ArrayPush(icons, "ico_cyberware");
      this.m_tabRoot.SetData(2, null, labels, icons);
      inkWidgetRef.SetVisible(this.m_tabRootContainer, true);
      this.m_tabRoot.RegisterToCallback(n"OnValueChanged", this, n"OnValueChanged");
      selectedIdentifier = isRipperdoc ? EnumInt(HubVendorMenuItems.Cyberware) : EnumInt(HubVendorMenuItems.Trade);
      this.m_tabRoot.Toggle(selectedIdentifier);
      this.OnValueChanged(this.m_tabRoot, selectedIdentifier);
    } else {
      this.m_vendorUserData.menu = "TRADE";
      this.m_menuEventDispatcher.SpawnEvent(n"OnSwitchToVendor", this.m_vendorUserData);
    };
  }

  protected cb func OnValueChanged(controller: wref<inkRadioGroupController>, selectedIndex: Int32) -> Bool {
    switch selectedIndex {
      case 0:
        this.m_vendorUserData.menu = "TRADE";
        this.m_menuEventDispatcher.SpawnEvent(n"OnSwitchToVendor", this.m_vendorUserData);
        break;
      case 1:
        this.m_vendorUserData.menu = "CYBERWARE";
        this.m_menuEventDispatcher.SpawnEvent(n"OnSwitchToRipperDoc", this.m_vendorUserData);
    };
    this.NotifyActivePanel(IntEnum(selectedIndex));
  }

  protected cb func OnButtonRelease(evt: ref<inkPointerEvent>) -> Bool {
    if evt.IsHandled() {
      return false;
    };
    if evt.IsAction(n"prior_menu") && NotEquals(this.m_vendorUserData.menu, "TRADE") {
      this.m_tabRoot.Toggle(0);
    } else {
      if evt.IsAction(n"next_menu") && NotEquals(this.m_vendorUserData.menu, "CYBERWARE") {
        this.m_tabRoot.Toggle(1);
      } else {
        if evt.IsAction(n"back") {
          if StatusEffectSystem.ObjectHasStatusEffectWithTag(this.GetPlayerControlledObject(), n"LockInHubMenu") {
            return false;
          };
          if NotEquals(this.m_vendorUserData.menu, "CYBERWARE") {
            this.CloseVendor();
          };
        };
      };
    };
  }

  protected cb func OnVendorUpdated(value: Variant) -> Bool {
    this.SetupTopBar();
  }

  private final func NotifyActivePanel(item: HubVendorMenuItems) -> Void {
    let evt: ref<VendorHubMenuChanged> = new VendorHubMenuChanged();
    evt.item = item;
    this.QueueEvent(evt);
  }

  protected cb func OnSetMenuEventDispatcher(menuEventDispatcher: wref<inkMenuEventDispatcher>) -> Bool {
    this.m_menuEventDispatcher = menuEventDispatcher;
  }

  private final func CloseVendor() -> Void {
    let menuEvent: ref<inkMenuInstance_SpawnEvent> = new inkMenuInstance_SpawnEvent();
    menuEvent.Init(n"OnVendorClose");
    this.QueueEvent(menuEvent);
  }
}
