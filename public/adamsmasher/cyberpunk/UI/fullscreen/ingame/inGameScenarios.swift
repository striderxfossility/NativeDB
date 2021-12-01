
public class StartHubMenuEvent extends Event {

  public let m_initData: ref<HubMenuInitData>;

  public final func SetStartMenu(menuName: CName, opt submenuName: CName, opt userData: ref<IScriptable>) -> Void {
    this.m_initData = new HubMenuInitData();
    this.m_initData.m_menuName = menuName;
    this.m_initData.m_submenuName = submenuName;
    this.m_initData.m_userData = userData;
  }
}

public class MenuScenario_Idle extends inkMenuScenario {

  protected cb func OnEnterScenario(prevScenario: CName, userData: ref<IScriptable>) -> Bool {
    let menuState: wref<inkMenusState> = this.GetMenusState();
    if NotEquals(prevScenario, n"") {
      menuState.CloseAllMenus();
      menuState.ShowMenus(false);
    };
  }

  protected cb func OnBlockHub() -> Bool {
    this.GetMenusState().SetHubMenuBlocked(true);
  }

  protected cb func OnUnlockHub() -> Bool {
    this.GetMenusState().SetHubMenuBlocked(false);
  }

  protected cb func OnLeaveScenario(nextScenario: CName) -> Bool {
    this.GetMenusState().ShowMenus(true);
  }

  protected cb func OnOpenPauseMenu() -> Bool {
    this.SwitchToScenario(n"MenuScenario_PauseMenu");
  }

  protected cb func OnOpenHubMenu() -> Bool {
    let notificationEvent: ref<UIInGameNotificationEvent>;
    if !this.GetMenusState().IsHubMenuBlocked() {
      this.SwitchToScenario(n"MenuScenario_HubMenu");
    } else {
      this.QueueEvent(new UIInGameNotificationRemoveEvent());
      notificationEvent = new UIInGameNotificationEvent();
      notificationEvent.m_notificationType = UIInGameNotificationType.CombatRestriction;
      this.QueueEvent(notificationEvent);
    };
  }

  protected cb func OnOpenHubMenu_InitData(userData: ref<IScriptable>) -> Bool {
    let notificationEvent: ref<UIInGameNotificationEvent>;
    if !this.GetMenusState().IsHubMenuBlocked() {
      this.SwitchToScenario(n"MenuScenario_HubMenu", userData);
    } else {
      this.QueueEvent(new UIInGameNotificationRemoveEvent());
      notificationEvent = new UIInGameNotificationEvent();
      notificationEvent.m_notificationType = UIInGameNotificationType.CombatRestriction;
      this.QueueEvent(notificationEvent);
    };
  }

  protected cb func OnNetworkBreachBegin() -> Bool {
    this.SwitchToScenario(n"MenuScenario_NetworkBreach");
  }

  protected cb func OnShowDeathMenu() -> Bool {
    this.SwitchToScenario(n"MenuScenario_DeathMenu");
  }

  protected cb func OnShowStorageMenu() -> Bool {
    this.SwitchToScenario(n"MenuScenario_Storage");
  }

  protected cb func OnOpenFastTravel() -> Bool {
    this.SwitchToScenario(n"MenuScenario_FastTravel");
  }
}

public class MenuScenario_BaseMenu extends inkMenuScenario {

  protected let m_currMenuName: CName;

  protected let m_currUserData: ref<IScriptable>;

  protected let m_currSubMenuName: CName;

  protected let m_prevMenuName: CName;

  protected cb func OnLeaveScenario(nextScenario: CName) -> Bool {
    this.CloseMenu();
  }

  protected cb func OnBack() -> Bool {
    let menuState: wref<inkMenusState> = this.GetMenusState();
    if NotEquals(this.m_currSubMenuName, n"") {
      if !menuState.DispatchEvent(this.m_currSubMenuName, n"OnBack") {
        this.CloseSubMenu();
      };
    } else {
      if NotEquals(this.m_currMenuName, n"") {
        if !menuState.DispatchEvent(this.m_currMenuName, n"OnBack") {
          this.GotoIdleState();
        };
      };
    };
  }

  protected final func SwitchMenu(menuName: CName, opt userData: ref<IScriptable>) -> Void {
    let menuState: wref<inkMenusState> = this.GetMenusState();
    if NotEquals(this.m_currMenuName, n"") {
      menuState.DispatchEvent(this.m_currMenuName, n"OnCloseMenu");
      menuState.CloseMenu(this.m_currMenuName);
    };
    this.m_currMenuName = menuName;
    this.m_currUserData = userData;
    menuState.OpenMenu(this.m_currMenuName, userData);
  }

  protected final func CloseMenu() -> Void {
    let menuState: wref<inkMenusState> = this.GetMenusState();
    if NotEquals(this.m_currMenuName, n"") {
      menuState.DispatchEvent(this.m_currMenuName, n"OnCloseMenu");
      menuState.CloseMenu(this.m_currMenuName);
      this.m_currMenuName = n"";
    };
  }

  protected final func OpenSubMenu(menuName: CName, opt userData: ref<IScriptable>) -> Void {
    let menuState: wref<inkMenusState> = this.GetMenusState();
    if NotEquals(this.m_currSubMenuName, n"") {
      menuState.DispatchEvent(this.m_currSubMenuName, n"OnCloseMenu");
      menuState.CloseMenu(this.m_currSubMenuName);
    };
    this.m_currSubMenuName = menuName;
    menuState.OpenMenu(this.m_currSubMenuName, userData);
  }

  protected final func CloseSubMenu() -> Void {
    let menuState: wref<inkMenusState> = this.GetMenusState();
    if NotEquals(this.m_currSubMenuName, n"") {
      menuState.DispatchEvent(this.m_currSubMenuName, n"OnCloseMenu");
      menuState.CloseMenu(this.m_currSubMenuName);
      this.m_currSubMenuName = n"";
    };
  }

  protected func GotoIdleState() -> Void {
    this.SwitchToScenario(n"MenuScenario_Idle");
  }
}
