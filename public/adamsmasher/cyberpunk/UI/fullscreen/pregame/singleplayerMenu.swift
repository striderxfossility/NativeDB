
public class SingleplayerMenuGameController extends MainMenuGameController {

  private edit let m_buttonHintsManagerRef: inkWidgetRef;

  private edit let m_gogButtonWidgetRef: inkWidgetRef;

  private let m_buttonHintsController: wref<ButtonHints>;

  private let m_savesCount: Int32;

  protected cb func OnInitialize() -> Bool {
    let handler: wref<inkISystemRequestsHandler>;
    super.OnInitialize();
    this.m_savesCount = 0;
    this.m_menuListController.GetRootWidget().RegisterToCallback(n"OnRelease", this, n"OnListRelease");
    this.m_menuListController.GetRootWidget().RegisterToCallback(n"OnRepeat", this, n"OnListRelease");
    this.RegisterToGlobalInputCallback(n"OnPostOnRelease", this, n"OnGlobalRelease");
    handler = this.GetSystemRequestsHandler();
    handler.RegisterToCallback(n"OnSavesReady", this, n"OnSavesReady");
    this.m_savesCount = handler.RequestSavesCountSync();
    handler.RequestSavesForLoad();
    this.SetNextInitialLoadingScreen(handler.GetLatestSaveMetadata().initialLoadingScreenID);
    this.m_buttonHintsController = this.SpawnFromExternal(inkWidgetRef.Get(this.m_buttonHintsManagerRef), r"base\\gameplay\\gui\\common\\buttonhints.inkwidget", n"Root").GetController() as ButtonHints;
    this.m_buttonHintsController.AddButtonHint(n"select", GetLocalizedText("UI-UserActions-Select"));
    if AreGOGRewardsEnabled() {
      inkWidgetRef.RegisterToCallback(this.m_gogButtonWidgetRef, n"OnRelease", this, n"OnGogPressed");
      inkWidgetRef.SetVisible(this.m_gogButtonWidgetRef, true);
      inkWidgetRef.SetInteractive(this.m_gogButtonWidgetRef, true);
    } else {
      inkWidgetRef.SetVisible(this.m_gogButtonWidgetRef, false);
      inkWidgetRef.SetInteractive(this.m_gogButtonWidgetRef, false);
    };
    this.ShowActionsList();
  }

  protected cb func OnUninitialize() -> Bool {
    this.UnregisterFromGlobalInputCallback(n"OnPostOnRelease", this, n"OnGlobalRelease");
    this.m_menuListController.GetRootWidget().UnregisterFromCallback(n"OnRelease", this, n"OnListRelease");
    this.m_menuListController.GetRootWidget().UnregisterFromCallback(n"OnRepeat", this, n"OnListRelease");
    if AreGOGRewardsEnabled() {
      inkWidgetRef.UnregisterFromCallback(this.m_gogButtonWidgetRef, n"OnRelease", this, n"OnGogPressed");
    };
    super.OnUninitialize();
  }

  private func PopulateMenuItemList() -> Void {
    if this.m_savesCount > 0 {
      this.AddMenuItem(GetLocalizedText("UI-ScriptExports-Continue0"), PauseMenuAction.QuickLoad);
    };
    this.AddMenuItem(GetLocalizedText("UI-ScriptExports-NewGame0"), n"OnNewGame");
    this.AddMenuItem(GetLocalizedText("UI-ScriptExports-LoadGame0"), n"OnLoadGame");
    this.AddMenuItem(GetLocalizedText("UI-Labels-Settings"), n"OnSwitchToSettings");
    this.AddMenuItem(GetLocalizedText("UI-DLC-MenuTitle"), n"OnSwitchToDlc");
    this.AddMenuItem(GetLocalizedText("UI-Labels-Credits"), n"OnSwitchToCredits");
    if !IsFinal() || UseProfiler() {
      this.AddMenuItem("DEBUG NEW GAME", n"OnDebug");
    };
    this.m_menuListController.Refresh();
    this.SetCursorOverWidget(inkCompoundRef.GetWidgetByIndex(this.m_menuList, 0));
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
    if e.IsAction(n"back") {
      this.PlaySound(n"Button", n"OnPress");
      this.m_menuEventDispatcher.SpawnEvent(n"OnBack");
      e.Handle();
    } else {
      if e.IsAction(n"next_menu") {
        this.PlaySound(n"Button", n"OnPress");
        this.m_menuEventDispatcher.SpawnEvent(n"OnGOGProfile");
        e.Handle();
      } else {
        if e.IsAction(n"navigate_down") || e.IsAction(n"navigate_up") || e.IsAction(n"navigate_left") || e.IsAction(n"navigate_right") {
          this.SetCursorOverWidget(inkCompoundRef.GetWidgetByIndex(this.m_menuList, 0));
        };
      };
    };
  }

  protected cb func OnSavesReady(saves: array<String>) -> Bool {
    this.m_savesCount = ArraySize(saves);
    this.ShowActionsList();
  }

  protected cb func OnGogPressed(evt: ref<inkPointerEvent>) -> Bool {
    if evt.IsAction(n"click") {
      this.PlaySound(n"Button", n"OnPress");
      evt.Handle();
      this.m_menuEventDispatcher.SpawnEvent(n"OnGOGProfile");
    };
  }

  protected func HandleMenuItemActivate(data: ref<PauseMenuListItemData>) -> Bool {
    if this.HandleMenuItemActivate(data) {
      return false;
    };
    switch data.action {
      case PauseMenuAction.QuickLoad:
        if this.m_savesCount > 0 {
          GameInstance.GetTelemetrySystem(this.GetPlayerControlledObject().GetGame()).LogLastCheckpointLoaded();
          this.GetSystemRequestsHandler().LoadLastCheckpoint(false);
          return true;
        };
    };
    return false;
  }
}
