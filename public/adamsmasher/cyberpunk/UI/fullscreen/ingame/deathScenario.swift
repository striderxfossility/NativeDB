
public class MenuScenario_DeathMenu extends MenuScenario_BaseMenu {

  protected cb func OnEnterScenario(prevScenario: CName, userData: ref<IScriptable>) -> Bool {
    let deathUserData: ref<DeathMenuUserData> = new DeathMenuUserData();
    deathUserData.m_playInitAnimation = true;
    this.GetMenusState().OpenMenu(n"pause_menu_background");
    this.SwitchMenu(n"death_menu", deathUserData);
  }

  protected cb func OnSwitchToLoadGame() -> Bool {
    this.SwitchMenu(n"load_game");
  }

  protected cb func OnSwitchToSettings() -> Bool {
    this.SwitchMenu(n"settings_main");
  }

  protected cb func OnCloseDeathMenu() -> Bool {
    this.SwitchToScenario(n"MenuScenario_Idle");
  }

  protected cb func OnMainMenuBack() -> Bool {
    this.SwitchMenu(n"death_menu");
  }

  protected cb func OnCloseSettingsScreen() -> Bool {
    this.GoBack(true);
  }

  protected cb func OnBack() -> Bool {
    this.GoBack(false);
  }

  protected cb func OnSwitchToBrightnessSettings() -> Bool {
    this.m_prevMenuName = this.m_currMenuName;
    this.SwitchMenu(n"brightness_settings");
  }

  protected cb func OnSwitchToHDRSettings() -> Bool {
    this.m_prevMenuName = this.m_currMenuName;
    this.SwitchMenu(n"hdr_settings");
  }

  protected cb func OnSwitchToControllerPanel() -> Bool {
    let menuState: wref<inkMenusState> = this.GetMenusState();
    this.m_prevMenuName = this.m_currMenuName;
    this.SwitchMenu(menuState.GetControllerMenuName());
  }

  private final func GoBack(forceCloseSettings: Bool) -> Void {
    let menuState: wref<inkMenusState> = this.GetMenusState();
    if Equals(this.m_currMenuName, n"death_menu") {
      return;
    };
    if NotEquals(this.m_prevMenuName, n"") {
      this.SwitchMenu(this.m_prevMenuName);
      this.m_prevMenuName = n"";
    } else {
      if (Equals(this.m_currMenuName, n"settings_main") || Equals(this.m_currMenuName, menuState.GetControllerMenuName())) && !forceCloseSettings {
        menuState.DispatchEvent(this.m_currMenuName, n"OnBack");
      } else {
        this.GotoIdleState();
      };
    };
  }

  protected func GotoIdleState() -> Void {
    this.SwitchMenu(n"death_menu");
  }
}
