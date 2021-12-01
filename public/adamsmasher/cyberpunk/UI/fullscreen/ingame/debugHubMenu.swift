
public class DebugHubMenuGameController extends gameuiMenuGameController {

  private let m_menuCtrl: wref<DebugHubMenuLogicController>;

  private let m_selectorCtrl: wref<hubSelectorController>;

  private let m_menuEventDispatcher: wref<inkMenuEventDispatcher>;

  private let m_player: wref<PlayerPuppet>;

  private let m_PDS: ref<PlayerDevelopmentSystem>;

  private let currencyListener: Uint32;

  private let characterCredListener: Uint32;

  private let characterLevelListener: Uint32;

  private let characterCurrentXPListener: Uint32;

  private let characterCredPointsListener: Uint32;

  private let m_Transaction: ref<TransactionSystem>;

  protected cb func OnInitialize() -> Bool {
    this.m_menuCtrl = this.GetRootWidget().GetController() as DebugHubMenuLogicController;
    this.m_selectorCtrl = this.m_menuCtrl.GetSelectorController();
    this.m_selectorCtrl.RegisterToCallback(n"OnSelectionChanged", this, n"OnMenuChanged");
    this.RegisterToGlobalInputCallback(n"OnPostOnRelease", this, n"OnButtonRelease");
  }

  protected cb func OnUninitialize() -> Bool {
    this.m_selectorCtrl.UnregisterFromCallback(n"OnSelectionChanged", this, n"OnMenuChanged");
    this.UnregisterFromGlobalInputCallback(n"OnPostOnRelease", this, n"OnButtonRelease");
  }

  protected cb func OnSetMenuEventDispatcher(menuEventDispatcher: wref<inkMenuEventDispatcher>) -> Bool {
    this.m_menuEventDispatcher = menuEventDispatcher;
  }

  protected cb func OnButtonRelease(evt: ref<inkPointerEvent>) -> Bool {
    if evt.IsHandled() {
      return false;
    };
    if evt.IsAction(n"right_button") || evt.IsAction(n"prior_menu") {
      this.m_selectorCtrl.Prior();
    } else {
      if evt.IsAction(n"left_button") || evt.IsAction(n"next_menu") {
        this.m_selectorCtrl.Next();
      } else {
        return false;
      };
    };
    evt.Handle();
  }

  protected cb func OnMenuChanged(index: Int32, value: String) -> Bool {
    this.m_menuEventDispatcher.SpawnEvent(this.m_menuCtrl.GetEventNameByIndex(index));
  }
}

public class DebugHubMenuLogicController extends inkLogicController {

  private let m_selectorWidget: wref<inkWidget>;

  private let m_selectorCtrl: wref<hubSelectorController>;

  private let m_menusList: array<CName>;

  private let m_eventsList: array<CName>;

  private let m_defailtMenuName: CName;

  protected cb func OnInitialize() -> Bool {
    this.m_selectorWidget = this.SpawnFromLocal(this.GetRootWidget(), n"selector");
    this.m_selectorCtrl = this.m_selectorWidget.GetController() as hubSelectorController;
    this.m_selectorWidget.SetAnchor(inkEAnchor.TopCenter);
    this.m_selectorWidget.SetAnchorPoint(new Vector2(0.50, 0.00));
    if IsClient() {
      this.AddMenuItem("CHARACTER SELECTION", n"OnSwitchToCpoCharacterSelection", n"cpo_character_selection");
      this.AddMenuItem("MUPPET LOADOUT SELECTION", n"OnSwitchToCpoMuppetLoadoutSelection", n"cpo_muppet_loadout_selection");
    };
    this.AddMenuItem("BUILDS", n"OnSwitchToBuilds", n"builds_panel");
  }

  public final func GetSelectorController() -> ref<hubSelectorController> {
    return this.m_selectorCtrl;
  }

  public final func SetDefaultMenu(defaultMenu: CName) -> Void {
    this.m_defailtMenuName = defaultMenu;
    if IsDefined(this.m_selectorCtrl) {
      this.m_selectorCtrl.SetCurrIndex(ArrayFindFirst(this.m_menusList, this.m_defailtMenuName));
    };
  }

  public final func GetEventNameByIndex(index: Int32) -> CName {
    if index >= 0 && index < ArraySize(this.m_eventsList) {
      return this.m_eventsList[index];
    };
    LogError("DebugHubMenuLogicController::GetEventNameByIndex(), menu index " + index + " is out of bounds");
    return this.m_defailtMenuName;
  }

  private final func AddMenuItem(menuLabel: String, eventName: CName, menuName: CName) -> Void {
    let menuData: MenuData;
    menuData.label = menuLabel;
    this.m_selectorCtrl.AddValue(menuLabel);
    this.m_selectorCtrl.AddMenuTab(menuData);
    ArrayPush(this.m_menusList, menuName);
    ArrayPush(this.m_eventsList, eventName);
  }
}

public class DebugMenuScenario_HubMenu extends MenuScenario_BaseMenu {

  @default(DebugMenuScenario_HubMenu, builds_panel)
  private let defaultMenu: CName;

  @default(DebugMenuScenario_HubMenu, builds_panel)
  private let cpoDefaultMenu: CName;

  private final func SetDefaultMenu(menuName: CName) -> Void {
    if IsClient() {
      this.cpoDefaultMenu = menuName;
    } else {
      this.defaultMenu = menuName;
    };
  }

  private final const func GetDefaultMenu() -> CName {
    return IsClient() ? this.cpoDefaultMenu : this.defaultMenu;
  }

  protected cb func OnEnterScenario(prevScenario: CName, userData: ref<IScriptable>) -> Bool {
    let currentState: ref<inkMenusState>;
    let hubCtrl: ref<DebugHubMenuLogicController>;
    let hubMenu: wref<inkWidget>;
    this.GetMenusState().OpenMenu(n"debug_hub_menu");
    this.OnOpenBaseMenu(this.GetDefaultMenu());
    currentState = this.GetMenusState();
    hubMenu = currentState.GetMenu(n"debug_hub_menu");
    hubCtrl = hubMenu.GetController() as DebugHubMenuLogicController;
    hubCtrl.SetDefaultMenu(this.GetDefaultMenu());
  }

  protected cb func OnLeaveScenario(nextScenario: CName) -> Bool {
    this.GetMenusState().CloseMenu(n"debug_hub_menu");
    super.OnLeaveScenario(nextScenario);
  }

  protected cb func OnOpenBaseMenu(menuName: CName) -> Bool {
    this.SwitchMenu(menuName);
    this.SetDefaultMenu(menuName);
  }

  protected cb func OnSwitchToCyberware() -> Bool {
    this.OnOpenBaseMenu(n"temp_cyberware_equip");
  }

  protected cb func OnSwitchToBuilds() -> Bool {
    this.OnOpenBaseMenu(n"builds_panel");
  }

  protected cb func OnSwitchToFastTravel() -> Bool {
    this.OnOpenBaseMenu(n"fast_travel");
  }

  protected cb func OnBack() -> Bool {
    this.SwitchToScenario(n"MenuScenario_PauseMenu");
  }

  protected cb func OnSwitchToCpoCharacterSelection() -> Bool {
    this.OnOpenBaseMenu(n"cpo_character_selection");
  }

  protected cb func OnSwitchToCpoMuppetLoadoutSelection() -> Bool {
    this.OnOpenBaseMenu(n"cpo_muppet_loadout_selection");
  }
}
