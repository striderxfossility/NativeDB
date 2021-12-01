
public class MenuScenario_HubMenu extends MenuScenario_BaseMenu {

  public let m_hubMenuInitData: wref<HubMenuInitData>;

  public let m_currentState: wref<inkMenusState>;

  public let m_hubMenuInstanceID: Uint32;

  protected func GotoIdleState() -> Void {
    let hubMenuInstanceData: ref<HubMenuInstanceData>;
    if NotEquals(this.m_currMenuName, n"hub_menu") {
      this.CloseMenu();
      this.m_currentState.CloseMenu(n"hub_menu");
      this.m_currentState.OpenMenu(n"hub_menu", this.m_hubMenuInitData);
      this.m_currMenuName = n"hub_menu";
      this.m_hubMenuInstanceID += 1u;
      hubMenuInstanceData = new HubMenuInstanceData();
      hubMenuInstanceData.m_ID = this.m_hubMenuInstanceID;
      this.m_currentState.DispatchEvent(this.m_currMenuName, n"OnHubMenuInstanceData", hubMenuInstanceData);
    } else {
      this.GotoIdleState();
    };
  }

  protected cb func OnEnterScenario(prevScenario: CName, userData: ref<IScriptable>) -> Bool {
    let hubCtrl: ref<MenuHubLogicController>;
    let hubMenu: wref<inkWidget>;
    let hubMenuInstanceData: ref<HubMenuInstanceData>;
    this.m_hubMenuInitData = userData as HubMenuInitData;
    this.m_currentState = this.GetMenusState();
    this.m_currentState.OpenMenu(n"hub_menu", this.m_hubMenuInitData);
    this.m_currMenuName = n"hub_menu";
    this.m_hubMenuInstanceID = 1u;
    hubMenuInstanceData = new HubMenuInstanceData();
    hubMenuInstanceData.m_ID = this.m_hubMenuInstanceID;
    this.m_currentState.DispatchEvent(this.m_currMenuName, n"OnHubMenuInstanceData", hubMenuInstanceData);
    hubMenu = this.m_currentState.GetMenu(n"hub_menu");
    if IsDefined(this.m_hubMenuInitData) {
      hubCtrl = hubMenu.GetControllerByType(n"MenuHubLogicController") as MenuHubLogicController;
      hubCtrl.SelectMenuExternally(this.m_hubMenuInitData.m_menuName, this.m_hubMenuInitData.m_submenuName, this.m_hubMenuInitData.m_userData);
    };
  }

  protected cb func OnNetworkBreachBegin() -> Bool {
    this.GotoIdleState();
    this.SwitchToScenario(n"MenuScenario_NetworkBreach");
  }

  protected cb func OnSwitchToTimeManager() -> Bool {
    this.OpenSubMenu(n"time_manager");
  }

  protected cb func OnSelectMenuItem(userData: ref<IScriptable>) -> Bool {
    let menuItemData: ref<MenuItemData> = userData as MenuItemData;
    let isFullscreenDifferent: Bool = NotEquals(menuItemData.m_menuData.fullscreenName, n"") && NotEquals(menuItemData.m_menuData.fullscreenName, this.m_currMenuName);
    let isDataDifferent: Bool = menuItemData.m_menuData.userData != this.m_currUserData;
    if isFullscreenDifferent || isDataDifferent {
      this.OnOpenMenu(menuItemData.m_menuData.fullscreenName, menuItemData.m_menuData.userData);
    };
  }

  protected cb func OnOpenMenu(menuName: CName, opt userData: ref<IScriptable>) -> Bool {
    let menuState: wref<inkMenusState> = this.GetMenusState();
    if NotEquals(this.m_currMenuName, n"") && NotEquals(this.m_currMenuName, n"hub_menu") {
      menuState.DispatchEvent(this.m_currMenuName, n"OnCloseMenu");
      menuState.CloseMenu(this.m_currMenuName);
    };
    this.m_currMenuName = menuName;
    menuState.OpenMenu(this.m_currMenuName, userData);
  }

  protected cb func OnCloseHubMenu() -> Bool {
    this.GotoIdleState();
  }

  protected cb func OnRequestHubMenu() -> Bool {
    this.GotoIdleState();
  }

  protected cb func OnCloseHubMenuRequest() -> Bool {
    this.GotoIdleState();
  }
}
