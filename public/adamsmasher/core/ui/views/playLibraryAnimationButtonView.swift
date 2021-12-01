
public class PlayLibraryAnimationButtonView extends BaseButtonView {

  protected edit let m_ToHoverAnimationName: CName;

  protected edit let m_ToPressedAnimationName: CName;

  protected edit let m_ToDefaultAnimationName: CName;

  protected edit let m_ToDisabledAnimationName: CName;

  private let m_InputAnimation: ref<inkAnimProxy>;

  protected func ButtonStateChanged(oldState: inkEButtonState, newState: inkEButtonState) -> Void {
    let animationName: CName;
    switch newState {
      case inkEButtonState.Hover:
        animationName = this.m_ToHoverAnimationName;
        break;
      case inkEButtonState.Press:
        animationName = this.m_ToPressedAnimationName;
        break;
      case inkEButtonState.Disabled:
        animationName = this.m_ToDisabledAnimationName;
        break;
      default:
        animationName = this.m_ToDefaultAnimationName;
    };
    if IsNameValid(animationName) {
      if IsDefined(this.m_InputAnimation) && this.m_InputAnimation.IsPlaying() {
        this.m_InputAnimation.Stop();
      };
      this.m_InputAnimation = this.PlayLibraryAnimation(animationName);
    };
  }
}
