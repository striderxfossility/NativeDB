
public class MenuScenario_Vendor extends MenuScenario_BaseMenu {

  protected cb func OnEnterScenario(prevScenario: CName, userData: ref<IScriptable>) -> Bool {
    this.GetMenusState().OpenMenu(n"vendor_hub_menu", userData);
  }

  protected cb func OnSwitchToVendor(opt userData: ref<IScriptable>) -> Bool {
    this.SwitchMenu(n"fullscreen_vendor", userData);
  }

  protected cb func OnSwitchToRipperDoc(opt userData: ref<IScriptable>) -> Bool {
    this.SwitchMenu(n"ripperdoc", userData);
  }

  protected cb func OnSwitchToCrafting(opt userData: ref<IScriptable>) -> Bool {
    this.SwitchMenu(n"crafting_main", userData);
  }

  protected cb func OnVendorClose() -> Bool {
    this.GotoIdleState();
  }

  protected func GotoIdleState() -> Void {
    this.GetMenusState().DispatchEvent(n"vendor_hub_menu", n"OnBack");
    this.SwitchToScenario(n"MenuScenario_Idle");
  }

  protected cb func OnCloseHubMenuRequest() -> Bool {
    this.GotoIdleState();
  }
}
