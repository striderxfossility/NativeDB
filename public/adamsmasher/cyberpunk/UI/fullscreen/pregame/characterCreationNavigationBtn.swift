
public class characterCreationNavigationBtn extends inkButtonController {

  public edit let icon1: inkWidgetRef;

  public edit let shouldPlaySoundOnHover: Bool;

  private let m_root: wref<inkWidget>;

  protected cb func OnInitialize() -> Bool {
    this.RegisterToCallback(n"OnHoverOver", this, n"OnHoverOver");
    this.RegisterToCallback(n"OnHoverOut", this, n"OnHoverOut");
  }

  protected cb func OnHoverOver(e: ref<inkPointerEvent>) -> Bool {
    this.m_root.SetState(n"Hover");
    inkWidgetRef.SetVisible(this.icon1, true);
    if this.shouldPlaySoundOnHover {
    };
  }

  protected cb func OnHoverOut(e: ref<inkPointerEvent>) -> Bool {
    this.m_root.SetState(n"Default");
    inkWidgetRef.SetVisible(this.icon1, false);
  }
}
