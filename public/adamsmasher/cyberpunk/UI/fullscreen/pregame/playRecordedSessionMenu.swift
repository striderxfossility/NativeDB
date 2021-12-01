
public class PlayRecordedSessionMenuGameController extends PreGameSubMenuGameController {

  private let m_recordsSelector: wref<SelectorController>;

  private let m_records: array<String>;

  protected cb func OnInitialize() -> Bool {
    let selectorsList: wref<inkVerticalPanel>;
    super.OnInitialize();
    selectorsList = this.GetWidget(n"Data/Selectors") as inkVerticalPanel;
    this.m_records = this.GetSystemRequestsHandler().GetRecords();
    this.m_recordsSelector = this.AddSelector(selectorsList, "Record:", this.m_records);
  }

  public func InitializeMenuName(menuName: wref<inkText>) -> Void {
    menuName.SetText("UI-Cyberpunk-Fullscreen-Pregame-PLAY_RECORDED_SESSION");
  }

  public func InitializeButtons(buttonsList: wref<inkVerticalPanel>) -> Void {
    this.AddButton(buttonsList, "PLAY", n"OnPlay");
    this.AddButton(buttonsList, "BACK", n"OnBack");
  }

  protected cb func OnPlay(e: ref<inkPointerEvent>) -> Bool {
    let index: Int32;
    if e.IsAction(n"click") {
      index = this.m_recordsSelector.GetCurrIndex();
      if index >= 0 && index < ArraySize(this.m_records) {
        this.GetSystemRequestsHandler().PlayRecord(this.m_records[index]);
      };
    };
  }

  protected cb func OnBack(e: ref<inkPointerEvent>) -> Bool {
    if e.IsAction(n"click") {
      this.m_menuEventDispatcher.SpawnEvent(n"OnBack");
    };
  }
}
