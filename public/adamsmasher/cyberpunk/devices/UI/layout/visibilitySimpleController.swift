
public class VisibilitySimpleControllerBase extends inkLogicController {

  public edit const let affectedWidgets: array<CName>;

  private let m_isVisible: Bool;

  private let m_widget: wref<inkWidget>;

  protected cb func OnInitialize() -> Bool {
    this.m_widget = this.GetRootWidget();
    this.m_widget.RegisterToCallback(n"OnHoverOver", this, n"OnHoverOver");
    this.m_widget.RegisterToCallback(n"OnHoverOut", this, n"OnHoverOut");
  }

  protected cb func OnUninitialize() -> Bool;

  protected cb func OnHoverOver(e: ref<inkPointerEvent>) -> Bool {
    if !this.m_isVisible && e.GetCurrentTarget() == this.m_widget {
      this.Show();
      this.m_isVisible = true;
    };
  }

  protected cb func OnHoverOut(e: ref<inkPointerEvent>) -> Bool {
    if this.m_isVisible && e.GetCurrentTarget() == this.m_widget {
      this.Hide();
      this.m_isVisible = false;
    };
  }

  protected final func Hide() -> Void {
    let widget: ref<inkWidget>;
    let i: Int32 = 0;
    while i < ArraySize(this.affectedWidgets) {
      widget = this.GetWidget(this.affectedWidgets[i]);
      if widget != null {
        widget.SetVisible(false);
      };
      i += 1;
    };
  }

  protected final func Show() -> Void {
    let widget: ref<inkWidget>;
    let i: Int32 = 0;
    while i < ArraySize(this.affectedWidgets) {
      widget = this.GetWidget(this.affectedWidgets[i]);
      if widget != null {
        widget.SetVisible(true);
      };
      i += 1;
    };
  }
}
