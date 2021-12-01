
public class MenuScenario_E3EndMenu extends MenuScenario_BaseMenu {

  protected cb func OnEnterScenario(prevScenario: CName, userData: ref<IScriptable>) -> Bool {
    this.GetMenusState().OpenMenu(n"pause_menu_background");
    this.SwitchMenu(n"e3_end_screen");
  }

  protected cb func OnSwitchToLoadGame() -> Bool {
    this.SwitchMenu(n"load_game");
  }

  protected cb func OnCloseDeathMenu() -> Bool {
    this.SwitchToScenario(n"MenuScenario_Idle");
  }

  protected cb func OnMainMenuBack() -> Bool {
    this.SwitchMenu(n"e3_end_screen");
  }

  protected func GotoIdleState() -> Void;
}

public class E3EndMenuGameController extends gameuiMenuItemListGameController {

  protected cb func OnInitialize() -> Bool {
    let evt: ref<inkMenuLayer_SetCursorVisibility>;
    let uiSystem: ref<UISystem> = GameInstance.GetUISystem(this.GetPlayerControlledObject().GetGame());
    uiSystem.PushGameContext(UIGameContext.Default);
    uiSystem.RequestNewVisualState(n"inkPauseMenuState");
    evt = new inkMenuLayer_SetCursorVisibility();
    evt.Init(false);
    this.QueueEvent(evt);
    this.RegisterToGlobalInputCallback(n"OnPostOnRelease", this, n"OnAnyKeyPress");
  }

  protected cb func OnUninitialize() -> Bool {
    let evt: ref<inkMenuLayer_SetCursorVisibility>;
    this.UnregisterFromGlobalInputCallback(n"OnPostOnRelease", this, n"OnAnyKeyPress");
    evt = new inkMenuLayer_SetCursorVisibility();
    evt.Init(true);
    this.QueueEvent(evt);
  }

  protected cb func OnAnyKeyPress(e: ref<inkPointerEvent>) -> Bool {
    e.Handle();
    if e.IsAction(n"UI_Skip") {
      this.GetSystemRequestsHandler().GotoMainMenu();
    };
  }

  protected cb func OnSetMenuEventDispatcher(menuEventDispatcher: wref<inkMenuEventDispatcher>) -> Bool {
    this.m_menuEventDispatcher = menuEventDispatcher;
  }
}
