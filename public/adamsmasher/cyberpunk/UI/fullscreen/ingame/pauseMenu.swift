
public class PauseMenuBackgroundGameController extends inkGameController {

  protected cb func OnInitialize() -> Bool {
    let setMenuModeEvent: ref<inkMenuLayer_SetMenuModeEvent> = new inkMenuLayer_SetMenuModeEvent();
    setMenuModeEvent.Init(inkMenuMode.PauseMenu, inkMenuState.Enabled);
    this.QueueBroadcastEvent(setMenuModeEvent);
    this.GetSystemRequestsHandler().PauseGame();
  }

  protected cb func OnUninitialize() -> Bool {
    let setMenuModeEvent: ref<inkMenuLayer_SetMenuModeEvent> = new inkMenuLayer_SetMenuModeEvent();
    setMenuModeEvent.Init(inkMenuMode.PauseMenu, inkMenuState.Disabled);
    this.QueueBroadcastEvent(setMenuModeEvent);
    this.GetSystemRequestsHandler().UnpauseGame();
  }
}

public class PauseMenuGameController extends gameuiMenuItemListGameController {

  private edit let m_buttonHintsManagerRef: inkWidgetRef;

  private let m_buttonHintsController: wref<ButtonHints>;

  public let m_gameInstance: GameInstance;

  private let m_quickSaveInProgress: Bool;

  protected cb func OnInitialize() -> Bool {
    let owner: ref<GameObject>;
    super.OnInitialize();
    owner = this.GetPlayerControlledObject();
    this.m_gameInstance = owner.GetGame();
    this.PlayLibraryAnimation(n"intro");
    this.m_buttonHintsController = this.SpawnFromExternal(inkWidgetRef.Get(this.m_buttonHintsManagerRef), r"base\\gameplay\\gui\\common\\buttonhints.inkwidget", n"Root").GetController() as ButtonHints;
    this.m_buttonHintsController.AddButtonHint(n"back", GetLocalizedText("Common-Access-Close"));
    this.m_buttonHintsController.AddButtonHint(n"select", GetLocalizedText("UI-UserActions-Select"));
    this.m_buttonHintsController.AddButtonHint(n"pause_menu_quicksave", GetLocalizedText("UI-ResourceExports-Quicksave"));
    this.m_menuListController.GetRootWidget().RegisterToCallback(n"OnRelease", this, n"OnListRelease");
    this.m_menuListController.GetRootWidget().RegisterToCallback(n"OnRepeat", this, n"OnListRelease");
    this.RegisterToGlobalInputCallback(n"OnPostOnRelease", this, n"OnGlobalRelease");
    this.GetSystemRequestsHandler().RegisterToCallback(n"OnSavingComplete", this, n"OnSavingComplete");
  }

  protected cb func OnUninitialize() -> Bool {
    this.UnregisterFromGlobalInputCallback(n"OnPostOnRelease", this, n"OnGlobalRelease");
    this.m_menuListController.GetRootWidget().UnregisterFromCallback(n"OnRelease", this, n"OnListRelease");
    this.m_menuListController.GetRootWidget().UnregisterFromCallback(n"OnRepeat", this, n"OnListRelease");
    this.GetSystemRequestsHandler().UnregisterFromCallback(n"OnSavingComplete", this, n"OnSavingComplete");
    super.OnUninitialize();
  }

  private func PopulateMenuItemList() -> Void {
    this.AddMenuItem(GetLocalizedText("UI-Labels-Resume"), n"OnClosePauseMenu");
    if !IsFinal() || UseProfiler() {
      this.AddMenuItem("OPEN DEBUG MENU", n"OnOpenDebugHubMenu");
    };
    this.AddMenuItem(GetLocalizedText("UI-ResourceExports-SaveGame"), PauseMenuAction.Save);
    this.AddMenuItem(GetLocalizedText("UI-ScriptExports-LoadGame0"), n"OnSwitchToLoadGame");
    this.AddMenuItem(GetLocalizedText("UI-Labels-Settings"), n"OnSwitchToSettings");
    this.AddMenuItem(GetLocalizedText("UI-DLC-MenuTitle"), n"OnSwitchToDlc");
    this.AddMenuItem(GetLocalizedText("UI-Labels-Credits"), n"OnSwitchToCredits");
    this.AddMenuItem(GetLocalizedText("UI-Labels-ExitToMenu"), PauseMenuAction.ExitToMainMenu);
    this.m_menuListController.Refresh();
    this.SetCursorOverWidget(inkCompoundRef.GetWidgetByIndex(this.m_menuList, 0));
  }

  protected cb func OnUnitialize() -> Bool {
    this.m_menuListController.UnregisterFromCallback(n"OnItemActivated", this, n"OnMenuItemActivated");
  }

  protected cb func OnSetMenuEventDispatcher(menuEventDispatcher: wref<inkMenuEventDispatcher>) -> Bool {
    this.m_menuEventDispatcher = menuEventDispatcher;
  }

  private final func HandlePressToSaveGame(target: wref<inkWidget>) -> Void {
    let locks: array<gameSaveLock>;
    if GameInstance.IsSavingLocked(this.m_gameInstance, locks) {
      this.PlaySound(n"Button", n"OnPress");
      this.PlayLibraryAnimationOnAutoSelectedTargets(n"pause_button_blocked", target);
      this.ShowSavingLockedNotification(locks);
      return;
    };
    this.PlaySound(n"Button", n"OnPress");
    this.m_menuEventDispatcher.SpawnEvent(n"OnSwitchToSaveGame");
  }

  private final func HandlePressToQuickSaveGame() -> Void {
    let locks: array<gameSaveLock>;
    if this.m_quickSaveInProgress || this.IsSaveFailedNotificationActive() || this.IsGameSavedNotificationActive() {
      this.PlaySound(n"Button", n"OnPress");
      return;
    };
    if GameInstance.IsSavingLocked(this.m_gameInstance, locks) {
      this.PlaySound(n"Button", n"OnPress");
      this.ShowSavingLockedNotification(locks);
      return;
    };
    this.PlaySound(n"Button", n"OnPress");
    this.GetSystemRequestsHandler().QuickSave();
    this.m_quickSaveInProgress = true;
  }

  protected cb func OnMenuItemActivated(index: Int32, target: ref<ListItemController>) -> Bool {
    let data: ref<PauseMenuListItemData>;
    let nextLoadingTypeEvt: ref<inkSetNextLoadingScreenEvent> = new inkSetNextLoadingScreenEvent();
    nextLoadingTypeEvt.SetNextLoadingScreenType(inkLoadingScreenType.FastTravel);
    data = target.GetData() as PauseMenuListItemData;
    switch data.action {
      case PauseMenuAction.OpenSubMenu:
        this.PlaySound(n"Button", n"OnPress");
        this.m_menuEventDispatcher.SpawnEvent(data.eventName);
        break;
      case PauseMenuAction.Save:
        this.HandlePressToSaveGame(target.GetRootWidget());
        break;
      case PauseMenuAction.QuickSave:
        this.HandlePressToQuickSaveGame();
        break;
      case PauseMenuAction.ExitGame:
        this.PlaySound(n"Button", n"OnPress");
        this.ExitGame();
        break;
      case PauseMenuAction.ExitToMainMenu:
        this.QueueBroadcastEvent(nextLoadingTypeEvt);
        this.PlaySound(n"Button", n"OnPress");
        this.GotoMainMenu();
    };
  }

  protected cb func OnSavingComplete(success: Bool, locks: array<gameSaveLock>) -> Bool {
    if success {
      this.RequestGameSavedNotification();
    } else {
      this.RequestSaveFailedNotification();
      this.ShowSavingLockedNotification(locks);
    };
    this.m_quickSaveInProgress = false;
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
    if e.IsAction(n"pause_menu_quicksave") {
      this.HandlePressToQuickSaveGame();
    } else {
      if e.IsAction(n"navigate_down") || e.IsAction(n"navigate_up") || e.IsAction(n"navigate_left") || e.IsAction(n"navigate_right") {
        this.SetCursorOverWidget(inkCompoundRef.GetWidgetByIndex(this.m_menuList, 0));
      };
    };
  }
}

public class PauseMenuButtonItem extends AnimatedListItemController {

  private edit let m_Fluff: inkTextRef;

  private let m_animLoop: ref<inkAnimProxy>;

  protected cb func OnInitialize() -> Bool {
    this.RegisterToCallback(n"OnHoverOver", this, n"OnHoverOver");
    this.RegisterToCallback(n"OnHoverOut", this, n"OnHoverOut");
    super.OnInitialize();
  }

  protected cb func OnUninitialize() -> Bool {
    super.OnUninitialize();
    this.UnregisterFromCallback(n"OnHoverOver", this, n"OnHoverOver");
    this.UnregisterFromCallback(n"OnHoverOut", this, n"OnHoverOut");
  }

  protected cb func OnAddedToList(target: wref<ListItemController>) -> Bool {
    inkTextRef.SetText(this.m_Fluff, "RES__ASYNC_" + this.GetIndex());
  }

  protected cb func OnHoverOver(e: ref<inkPointerEvent>) -> Bool {
    let options: inkAnimOptions;
    options.loopType = inkanimLoopType.Cycle;
    options.loopInfinite = true;
    this.PlayLibraryAnimation(n"pause_button_hover_over_anim");
    this.m_animLoop = this.PlayLibraryAnimation(n"pause_button_loop_anim", options);
  }

  protected cb func OnHoverOut(e: ref<inkPointerEvent>) -> Bool {
    if this.m_animLoop.IsPlaying() {
      this.m_animLoop.Stop();
    };
    this.PlayLibraryAnimation(n"pause_button_hover_out_anim");
  }
}
