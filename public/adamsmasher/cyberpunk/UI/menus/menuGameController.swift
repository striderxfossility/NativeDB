
public native class gameuiMenuGameController extends inkGameController {

  private let m_baseEventDispatcher: wref<inkMenuEventDispatcher>;

  public final native func RefreshInputIcons() -> Void;

  protected cb func OnInitialize() -> Bool;

  protected cb func OnUninitialize() -> Bool {
    this.m_baseEventDispatcher.UnregisterFromEvent(n"OnBack", this, n"OnBack");
  }

  protected cb func OnSetMenuEventDispatcher(menuEventDispatcher: wref<inkMenuEventDispatcher>) -> Bool {
    this.m_baseEventDispatcher = menuEventDispatcher;
    this.m_baseEventDispatcher.RegisterToEvent(n"OnBack", this, n"OnBack");
  }

  protected cb func OnBack(userData: ref<IScriptable>) -> Bool {
    let evt: ref<BackActionCallback> = new BackActionCallback();
    this.QueueEvent(evt);
  }
}
