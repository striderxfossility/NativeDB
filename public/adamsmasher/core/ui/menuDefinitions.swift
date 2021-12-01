
public class MenuScenario_ClippedMenu extends inkMenuScenario {

  protected cb func OnEnterScenario(prevScenario: CName, userData: ref<IScriptable>) -> Bool {
    let data: ref<inkClippedMenuScenarioData>;
    let i: Int32;
    let menuState: wref<inkMenusState> = this.GetMenusState();
    menuState.ShowMenus(false);
    data = userData as inkClippedMenuScenarioData;
    if IsDefined(data) {
      i = 0;
      while i < ArraySize(data.menus) {
        menuState.OpenMenu(data.menus[i]);
        i += 1;
      };
    };
  }

  protected cb func OnOpenPauseMenu() -> Bool {
    let menuState: wref<inkMenusState> = this.GetMenusState();
    menuState.ShowMenus(!menuState.IsMenusVisible());
  }

  protected cb func OnOpenHubMenu() -> Bool {
    let menuState: wref<inkMenusState> = this.GetMenusState();
    menuState.ShowMenus(!menuState.IsMenusVisible());
  }
}
