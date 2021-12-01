
public native class ListItemController extends inkButtonController {

  public edit let m_labelPathRef: inkTextRef;

  public final native func GetIndex() -> Int32;

  public final native func GetData() -> wref<IScriptable>;

  public final native func IsSelected() -> Bool;

  public final native func IsToggled() -> Bool;

  protected cb func OnInitialize() -> Bool;

  protected cb func OnDataChanged(value: ref<IScriptable>) -> Bool {
    let data: ref<ListItemData> = value as ListItemData;
    if inkWidgetRef.IsValid(this.m_labelPathRef) {
      inkTextRef.SetText(this.m_labelPathRef, data.label);
    };
  }

  protected cb func OnSetCursorOver() -> Bool {
    this.SetCursorOverWidget(this.GetRootWidget());
  }
}
