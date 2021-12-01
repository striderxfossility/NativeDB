
public class BaseHubMenuController extends inkGameController {

  private let m_menuEventDispatcher: wref<inkMenuEventDispatcher>;

  private let m_menuData: ref<IScriptable>;

  protected cb func OnInitialize() -> Bool;

  protected cb func OnUninitialize() -> Bool {
    this.m_menuEventDispatcher.UnregisterFromEvent(n"OnBack", this, n"OnBack");
  }

  protected cb func OnSetMenuEventDispatcher(menuEventDispatcher: wref<inkMenuEventDispatcher>) -> Bool {
    this.m_menuEventDispatcher = menuEventDispatcher;
    this.m_menuEventDispatcher.RegisterToEvent(n"OnBack", this, n"OnBack");
  }

  protected cb func OnBack(userData: ref<IScriptable>) -> Bool {
    let evt: ref<BackActionCallback> = new BackActionCallback();
    this.QueueEvent(evt);
  }
}
