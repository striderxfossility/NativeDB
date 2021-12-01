
public class MultiplayerMenuGameController extends PreGameSubMenuGameController {

  public func InitializeMenuName(menuName: wref<inkText>) -> Void {
    menuName.SetText("UI-Cyberpunk-Fullscreen-Pregame-MULTIPLAYER");
  }

  public func InitializeButtons(buttonsList: wref<inkVerticalPanel>) -> Void {
    this.AddButton(buttonsList, "FIND SERVERS", n"OnFindServers");
    this.AddButton(buttonsList, "PLAY RECORDED SESSION", n"OnPlayRecordedSession");
    this.AddButton(buttonsList, "EXIT TO DESKTOP", n"OnExit");
  }

  protected cb func OnFindServers(e: ref<inkPointerEvent>) -> Bool {
    if e.IsAction(n"click") {
      this.m_menuEventDispatcher.SpawnEvent(n"OnFindServers");
    };
  }

  protected cb func OnPlayRecordedSession(e: ref<inkPointerEvent>) -> Bool {
    if e.IsAction(n"click") {
      this.m_menuEventDispatcher.SpawnEvent(n"OnPlayRecordedSession");
    };
  }

  protected cb func OnExit(e: ref<inkPointerEvent>) -> Bool {
    if e.IsAction(n"click") {
      this.GetSystemRequestsHandler().ExitGame();
    };
  }
}
