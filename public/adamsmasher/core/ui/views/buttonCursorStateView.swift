
public class ButtonCursorStateView extends BaseButtonView {

  @default(ButtonCursorStateView, Hover)
  private edit let m_HoverStateName: CName;

  @default(ButtonCursorStateView, Hover)
  private edit let m_PressStateName: CName;

  @default(ButtonCursorStateView, Default)
  private edit let m_DefaultStateName: CName;

  protected func ButtonStateChanged(oldState: inkEButtonState, newState: inkEButtonState) -> Void {
    switch newState {
      case inkEButtonState.Press:
        this.SetCursorContext(this.m_PressStateName);
        break;
      case inkEButtonState.Hover:
        this.SetCursorContext(this.m_HoverStateName);
        break;
      default:
        this.SetCursorContext(this.m_DefaultStateName);
    };
  }
}
