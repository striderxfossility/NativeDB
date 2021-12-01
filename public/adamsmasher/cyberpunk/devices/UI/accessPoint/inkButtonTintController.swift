
public class inkButtonTintController extends inkButtonController {

  public edit let m_NormalColor: Color;

  public edit let m_HoverColor: Color;

  public edit let m_PressColor: Color;

  public edit let m_DisableColor: Color;

  public edit let m_TintControlRef: inkWidgetRef;

  protected cb func OnButtonStateChanged(controller: wref<inkButtonController>, oldState: inkEButtonState, newState: inkEButtonState) -> Bool {
    switch newState {
      case inkEButtonState.Normal:
        inkWidgetRef.SetTintColor(this.m_TintControlRef, this.m_NormalColor);
        break;
      case inkEButtonState.Hover:
        inkWidgetRef.SetTintColor(this.m_TintControlRef, this.m_HoverColor);
        break;
      case inkEButtonState.Press:
        inkWidgetRef.SetTintColor(this.m_TintControlRef, this.m_PressColor);
        this.PlaySound(n"Button", n"OnPress");
        break;
      case inkEButtonState.Disabled:
        inkWidgetRef.SetTintColor(this.m_TintControlRef, this.m_DisableColor);
    };
  }
}
