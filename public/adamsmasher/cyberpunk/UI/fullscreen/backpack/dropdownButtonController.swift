
public class DropdownButtonController extends inkLogicController {

  protected edit let m_label: inkTextRef;

  protected edit let m_icon: inkImageRef;

  protected edit let m_frame: inkWidgetRef;

  protected edit let m_arrow: inkImageRef;

  protected cb func OnInitialize() -> Bool {
    this.RegisterToCallback(n"OnHoverOver", this, n"OnHoverOver");
    this.RegisterToCallback(n"OnHoverOut", this, n"OnHoverOut");
  }

  public final func SetData(data: ref<DropdownItemData>) -> Void {
    inkTextRef.SetText(this.m_label, NameToString(data.labelKey));
    inkWidgetRef.SetVisible(this.m_icon, NotEquals(data.direction, IntEnum(0l)));
    if Equals(data.direction, DropdownItemDirection.Up) {
      inkImageRef.SetBrushMirrorType(this.m_icon, inkBrushMirrorType.Vertical);
    } else {
      inkImageRef.SetBrushMirrorType(this.m_icon, inkBrushMirrorType.NoMirror);
    };
  }

  public final func SetOpened(opened: Bool) -> Void {
    inkImageRef.SetBrushMirrorType(this.m_arrow, opened ? inkBrushMirrorType.Vertical : inkBrushMirrorType.NoMirror);
  }

  protected cb func OnHoverOut(evt: ref<inkPointerEvent>) -> Bool {
    this.GetRootWidget().SetState(n"Default");
  }

  protected cb func OnHoverOver(evt: ref<inkPointerEvent>) -> Bool {
    this.GetRootWidget().SetState(n"Hover");
  }
}
