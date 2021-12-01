
public class MenuScenario_NetworkBreach extends MenuScenario_BaseMenu {

  protected cb func OnEnterScenario(prevScenario: CName, userData: ref<IScriptable>) -> Bool {
    this.SwitchMenu(n"network_breach");
  }

  protected cb func OnBack() -> Bool;

  protected cb func OnCloseHubMenuRequest() -> Bool;

  protected cb func OnNetworkBreachEnd() -> Bool {
    this.GotoIdleState();
  }
}
