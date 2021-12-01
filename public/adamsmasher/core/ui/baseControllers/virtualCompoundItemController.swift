
public native class inkVirtualCompoundItemController extends inkButtonController {

  public final native func GetIndex() -> Uint32;

  public final native func GetData() -> Variant;

  public final native func IsSelected() -> Bool;

  public final native func IsToggled() -> Bool;

  protected cb func OnSetCursorOver() -> Bool {
    this.SetCursorOverWidget(this.GetRootWidget());
  }
}
