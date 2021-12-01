
public class characterCreationBodyMorphImageThumbnail extends inkButtonAnimatedController {

  public edit let m_selector: inkWidgetRef;

  public edit let m_equipped: inkWidgetRef;

  public edit let m_bg: inkWidgetRef;

  public let m_index: Int32;

  protected cb func OnInitialize() -> Bool {
    this.RegisterToCallback(n"OnHoverOver", this, n"OnHoverOver");
    this.RegisterToCallback(n"OnHoverOut", this, n"OnHoverOut");
    inkWidgetRef.SetVisible(this.m_selector, false);
  }

  public final func Refresh(selected: Bool, color: Color, index: Int32) -> Void {
    this.m_index = index;
    inkWidgetRef.SetTintColor(this.m_bg, color);
    inkWidgetRef.SetVisible(this.m_equipped, selected);
  }

  public final func RefreshSelectionState(selected: Bool) -> Void {
    inkWidgetRef.SetVisible(this.m_equipped, selected);
  }

  protected cb func OnHoverOver(e: ref<inkPointerEvent>) -> Bool {
    inkWidgetRef.SetVisible(this.m_selector, true);
  }

  protected cb func OnHoverOut(e: ref<inkPointerEvent>) -> Bool {
    inkWidgetRef.SetVisible(this.m_selector, false);
  }
}
