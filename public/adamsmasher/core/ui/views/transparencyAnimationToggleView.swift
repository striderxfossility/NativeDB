
public class TransparencyAnimationToggleView extends BaseToggleView {

  @default(TransparencyAnimationToggleView, 0.02f)
  private edit let m_AnimationTime: Float;

  @default(TransparencyAnimationToggleView, 0.2f)
  private edit let m_HoverTransparency: Float;

  @default(TransparencyAnimationToggleView, 0.4f)
  private edit let m_PressTransparency: Float;

  @default(TransparencyAnimationToggleView, 0f)
  private edit let m_DefaultTransparency: Float;

  @default(TransparencyAnimationToggleView, 0f)
  private edit let m_DisabledTransparency: Float;

  private let m_AnimationProxies: array<ref<inkAnimProxy>>;

  private edit const let m_Targets: array<inkWidgetRef>;

  protected func ToggleStateChanged(oldState: inkEToggleState, newState: inkEToggleState) -> Void {
    let animDef: ref<inkAnimDef>;
    let i: Int32;
    let limit: Int32;
    let targetTransparency: Float;
    let transparencyInterpolator: ref<inkAnimTransparency>;
    switch newState {
      case inkEToggleState.ToggledHover:
      case inkEToggleState.Hover:
        targetTransparency = this.m_HoverTransparency;
        break;
      case inkEToggleState.Press:
      case inkEToggleState.ToggledPress:
        targetTransparency = this.m_PressTransparency;
        break;
      case inkEToggleState.Disabled:
        targetTransparency = this.m_DisabledTransparency;
        break;
      default:
        targetTransparency = this.m_DefaultTransparency;
    };
    i = 0;
    limit = ArraySize(this.m_AnimationProxies);
    while i < limit {
      if IsDefined(this.m_AnimationProxies[i]) && this.m_AnimationProxies[i].IsPlaying() {
        this.m_AnimationProxies[i].Stop();
      };
      i += 1;
    };
    ArrayClear(this.m_AnimationProxies);
    animDef = new inkAnimDef();
    transparencyInterpolator = new inkAnimTransparency();
    transparencyInterpolator.SetEndTransparency(targetTransparency);
    transparencyInterpolator.SetDuration(this.m_AnimationTime);
    transparencyInterpolator.SetDirection(inkanimInterpolationDirection.To);
    animDef.AddInterpolator(transparencyInterpolator);
    i = 0;
    limit = ArraySize(this.m_Targets);
    while i < limit {
      ArrayPush(this.m_AnimationProxies, inkWidgetRef.PlayAnimation(this.m_Targets[i], animDef));
      i += 1;
    };
  }
}
