
public native class gameuiMenuItemListGameController extends gameuiSaveHandlingController {

  protected edit let m_menuList: inkCompoundRef;

  protected let m_menuEventDispatcher: wref<inkMenuEventDispatcher>;

  protected let m_menuListController: wref<ListController>;

  protected final native func CanExitGame() -> Bool;

  protected final native func ExitGame() -> Void;

  protected final native func GotoMainMenu() -> Void;

  protected cb func OnInitialize() -> Bool {
    this.m_menuListController = inkWidgetRef.GetController(this.m_menuList) as ListController;
    this.m_menuListController.RegisterToCallback(n"OnItemActivated", this, n"OnMenuItemActivated");
    this.ShowActionsList();
  }

  protected cb func OnUninitialize() -> Bool {
    this.m_menuListController.UnregisterFromCallback(n"OnItemActivated", this, n"OnMenuItemActivated");
  }

  protected cb func OnSetMenuEventDispatcher(menuEventDispatcher: wref<inkMenuEventDispatcher>) -> Bool {
    this.m_menuEventDispatcher = menuEventDispatcher;
  }

  private func PopulateMenuItemList() -> Void;

  protected func HandleMenuItemActivate(data: ref<PauseMenuListItemData>) -> Bool {
    switch data.action {
      case PauseMenuAction.OpenSubMenu:
        this.m_menuEventDispatcher.SpawnEvent(data.eventName);
        return true;
      case PauseMenuAction.QuickSave:
        this.GetSystemRequestsHandler().QuickSave();
        this.m_menuEventDispatcher.SpawnEvent(n"OnClosePauseMenu");
        return true;
      case PauseMenuAction.ExitGame:
        this.ExitGame();
        return true;
      case PauseMenuAction.ExitToMainMenu:
        this.GotoMainMenu();
        return true;
    };
    return false;
  }

  private func ShouldAllowExitGameMenuItem() -> Bool {
    return true;
  }

  protected final func AddMenuItem(label: String, spawnEvent: CName) -> Void {
    let data: ref<PauseMenuListItemData> = new PauseMenuListItemData();
    data.label = label;
    data.eventName = spawnEvent;
    data.action = PauseMenuAction.OpenSubMenu;
    this.m_menuListController.PushData(data);
  }

  protected final func AddMenuItem(label: String, action: PauseMenuAction) -> Void {
    let data: ref<PauseMenuListItemData> = new PauseMenuListItemData();
    data.label = label;
    data.action = action;
    this.m_menuListController.PushData(data);
  }

  protected final func Clear() -> Void {
    this.m_menuListController.Clear();
  }

  protected final func ShowActionsList() -> Void {
    this.Clear();
    this.PopulateMenuItemList();
    if this.ShouldAllowExitGameMenuItem() && this.CanExitGame() {
      this.AddMenuItem(GetLocalizedText("UI-Labels-CloseGame"), PauseMenuAction.ExitGame);
    };
    this.m_menuListController.Refresh();
    this.SetCursorOverWidget(inkCompoundRef.GetWidgetByIndex(this.m_menuList, 0));
  }

  protected cb func OnMenuItemActivated(index: Int32, target: ref<ListItemController>) -> Bool {
    let data: ref<PauseMenuListItemData> = target.GetData() as PauseMenuListItemData;
    this.PlaySound(n"Button", n"OnPress");
    this.HandleMenuItemActivate(data);
  }
}
