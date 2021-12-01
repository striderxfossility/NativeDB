
public native class ListController extends inkLogicController {

  public final native func PushData(value: ref<IScriptable>, opt refreshImmediately: Bool) -> Void;

  public final native func PushDataList(value: array<ref<IScriptable>>, opt refreshImmediately: Bool) -> Void;

  public final native func Clear(opt refreshImmediately: Bool) -> Void;

  public final native func Refresh() -> Void;

  public final native func Next() -> Void;

  public final native func Prior() -> Void;

  public final native func FindIndex(value: ref<IScriptable>) -> Int32;

  public final native func HasValidSelection() -> Bool;

  public final native func GetSelectedIndex() -> Int32;

  public final native func SetSelectedIndex(index: Int32, opt force: Bool) -> Void;

  public final native func GetToggledIndex() -> Int32;

  public final native func SetToggledIndex(index: Int32) -> Void;

  public final native func SetLibraryID(id: CName) -> Void;

  public final native func GetItemAt(index: Int32) -> wref<inkWidget>;

  public final native func Size() -> Int32;

  public final func HandleInput(e: ref<inkPointerEvent>, opt gameCtrl: wref<gameuiMenuGameController>) -> Void {
    let widgetHStack: ref<inkHorizontalPanel> = this.GetRootWidget() as inkHorizontalPanel;
    if IsDefined(widgetHStack) {
      if e.IsAction(n"navigate_left") {
        this.Prior();
        this.MoveCursorToSelection(gameCtrl);
        e.Handle();
      } else {
        if e.IsAction(n"navigate_right") {
          this.Next();
          this.MoveCursorToSelection(gameCtrl);
          e.Handle();
        };
      };
    } else {
      if e.IsAction(n"navigate_up") {
        this.Prior();
        this.MoveCursorToSelection(gameCtrl);
        e.Handle();
      } else {
        if e.IsAction(n"navigate_down") {
          this.Next();
          this.MoveCursorToSelection(gameCtrl);
          e.Handle();
        };
      };
    };
  }

  private final func MoveCursorToSelection(gameCtrl: wref<gameuiMenuGameController>) -> Void {
    let selection: wref<inkWidget>;
    if IsDefined(gameCtrl) {
      selection = this.GetItemAt(this.GetSelectedIndex());
      if IsDefined(selection) {
        gameCtrl.SetCursorOverWidget(selection);
      };
    };
  }
}
