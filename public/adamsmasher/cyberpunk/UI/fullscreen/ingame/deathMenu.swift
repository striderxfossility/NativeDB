
public native class DeathMenuGameController extends gameuiMenuItemListGameController {

  private edit let m_buttonHintsManagerRef: inkWidgetRef;

  private let m_buttonHintsController: wref<ButtonHints>;

  private let m_animIntro: ref<inkAnimProxy>;

  protected cb func OnInitialize() -> Bool {
    super.OnInitialize();
    this.m_buttonHintsController = this.SpawnFromExternal(inkWidgetRef.Get(this.m_buttonHintsManagerRef), r"base\\gameplay\\gui\\common\\buttonhints.inkwidget", n"Root").GetController() as ButtonHints;
    this.m_buttonHintsController.AddButtonHint(n"select", GetLocalizedText("Common-Access-Select"));
    this.m_menuListController.GetRootWidget().RegisterToCallback(n"OnRelease", this, n"OnListRelease");
    this.m_menuListController.GetRootWidget().RegisterToCallback(n"OnRepeat", this, n"OnListRelease");
    this.RegisterToGlobalInputCallback(n"OnPostOnRelease", this, n"OnGlobalRelease");
    this.PlaySound(n"DeathMenu", n"OnOpen");
  }

  protected cb func OnUninitialize() -> Bool {
    this.UnregisterFromGlobalInputCallback(n"OnPostOnRelease", this, n"OnGlobalRelease");
    this.m_menuListController.GetRootWidget().UnregisterFromCallback(n"OnRelease", this, n"OnListRelease");
    this.m_menuListController.GetRootWidget().UnregisterFromCallback(n"OnRepeat", this, n"OnListRelease");
    this.PlaySound(n"DeathMenu", n"OnClose");
    super.OnUninitialize();
  }

  protected cb func OnSetUserData(userData: ref<IScriptable>) -> Bool {
    let deathMenuData: ref<DeathMenuUserData> = userData as DeathMenuUserData;
    if IsDefined(deathMenuData) && deathMenuData.m_playInitAnimation {
      this.PlayLibraryAnimation(n"intro");
    };
  }

  private func ShouldAllowExitGameMenuItem() -> Bool {
    return false;
  }

  private func PopulateMenuItemList() -> Void {
    if this.GetSystemRequestsHandler().HasLastCheckpoint() {
      this.AddMenuItem(GetLocalizedText("UI-ScriptExports-LoadLastSavegame"), PauseMenuAction.QuickLoad);
    };
    this.AddMenuItem(GetLocalizedText("UI-ScriptExports-LoadGame0"), n"OnSwitchToLoadGame");
    this.AddMenuItem(GetLocalizedText("UI-Labels-Settings"), n"OnSwitchToSettings");
    this.AddMenuItem(GetLocalizedText("UI-Labels-ExitToMenu"), PauseMenuAction.ExitToMainMenu);
    this.m_menuListController.Refresh();
    this.SetCursorOverWidget(inkCompoundRef.GetWidgetByIndex(this.m_menuList, 0));
  }

  protected func HandleMenuItemActivate(data: ref<PauseMenuListItemData>) -> Bool {
    if this.HandleMenuItemActivate(data) {
      return false;
    };
    switch data.action {
      case PauseMenuAction.QuickLoad:
        GameInstance.GetTelemetrySystem(this.GetPlayerControlledObject().GetGame()).LogLastCheckpointLoaded();
        this.GetSystemRequestsHandler().LoadLastCheckpoint(true);
        return true;
    };
    return false;
  }

  protected cb func OnListRelease(e: ref<inkPointerEvent>) -> Bool {
    if e.IsHandled() {
      return false;
    };
    this.m_menuListController.HandleInput(e, this);
  }

  protected cb func OnGlobalRelease(e: ref<inkPointerEvent>) -> Bool {
    if e.IsHandled() {
      return false;
    };
    if e.IsAction(n"navigate_down") || e.IsAction(n"navigate_up") || e.IsAction(n"navigate_left") || e.IsAction(n"navigate_right") {
      this.SetCursorOverWidget(inkCompoundRef.GetWidgetByIndex(this.m_menuList, 0));
    };
  }
}
