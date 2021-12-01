
public class MenuScenario_FastTravel extends MenuScenario_BaseMenu {

  protected cb func OnEnterScenario(prevScenario: CName, userData: ref<IScriptable>) -> Bool {
    this.SwitchMenu(n"world_map");
  }

  protected cb func OnBack() -> Bool {
    this.GotoIdleState();
  }
}
