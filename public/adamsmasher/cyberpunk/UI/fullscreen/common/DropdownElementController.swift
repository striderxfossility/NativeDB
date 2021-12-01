
public class DropdownElementController extends BaseButtonView {

  protected edit let m_text: inkTextRef;

  protected edit let m_arrow: inkImageRef;

  protected edit let m_frame: inkWidgetRef;

  protected edit let m_contentContainer: inkWidgetRef;

  protected let m_data: ref<DropdownItemData>;

  protected let m_active: Bool;

  protected cb func OnInitialize() -> Bool {
    inkWidgetRef.RegisterToCallback(this.m_contentContainer, n"OnHoverOver", this, n"OnHoverOver");
    inkWidgetRef.RegisterToCallback(this.m_contentContainer, n"OnHoverOut", this, n"OnHoverOut");
  }

  public final func Setup(data: ref<DropdownItemData>) -> Void {
    this.m_data = data;
    inkTextRef.SetText(this.m_text, GetLocalizedText(NameToString(data.labelKey)));
    if Equals(data.direction, IntEnum(0l)) {
      inkWidgetRef.SetVisible(this.m_arrow, false);
    } else {
      if Equals(data.direction, DropdownItemDirection.Up) {
        inkWidgetRef.SetVisible(this.m_arrow, true);
        inkImageRef.SetBrushMirrorType(this.m_arrow, inkBrushMirrorType.Vertical);
      } else {
        inkWidgetRef.SetVisible(this.m_arrow, true);
        inkImageRef.SetBrushMirrorType(this.m_arrow, inkBrushMirrorType.NoMirror);
      };
    };
  }

  public final func GetIdentifier() -> Variant {
    return this.m_data.identifier;
  }

  public final func SetHighlighted(highlighted: Bool) -> Void {
    inkWidgetRef.SetState(this.m_frame, highlighted ? n"Hover" : n"Default");
    if !this.m_active {
      this.GetRootWidget().SetState(highlighted ? n"Hover" : n"Default");
    };
  }

  public final func SetActive(active: Bool) -> Void {
    this.m_active = active;
    this.GetRootWidget().SetState(active ? n"Active" : n"Default");
  }

  protected cb func OnHoverOver(evt: ref<inkPointerEvent>) -> Bool {
    this.SetHighlighted(true);
  }

  protected cb func OnHoverOut(evt: ref<inkPointerEvent>) -> Bool {
    this.SetHighlighted(false);
  }
}
