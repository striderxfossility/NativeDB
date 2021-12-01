
public class ElevatorArrowsLogicController extends DeviceInkLogicControllerBase {

  @attrib(category, "Widget Refs")
  private edit let m_arrow1Widget: inkWidgetRef;

  @attrib(category, "Widget Refs")
  private edit let m_arrow2Widget: inkWidgetRef;

  @attrib(category, "Widget Refs")
  private edit let m_arrow3Widget: inkWidgetRef;

  private let m_animFade1: ref<inkAnimDef>;

  private let m_animFade2: ref<inkAnimDef>;

  private let m_animFade3: ref<inkAnimDef>;

  private let m_animSlow1: ref<inkAnimDef>;

  private let m_animSlow2: ref<inkAnimDef>;

  private let m_animOptions1: inkAnimOptions;

  private let m_animOptions2: inkAnimOptions;

  private let m_animOptions3: inkAnimOptions;

  protected cb func OnInitialize() -> Bool {
    this.CreateAnimations();
  }

  private final func CreateAnimations() -> Void {
    this.m_animFade1 = new inkAnimDef();
    let fadeInterp: ref<inkAnimTransparency> = new inkAnimTransparency();
    fadeInterp.SetStartTransparency(1.00);
    fadeInterp.SetEndTransparency(0.00);
    fadeInterp.SetDuration(0.25);
    this.m_animFade1.AddInterpolator(fadeInterp);
    this.m_animFade2 = new inkAnimDef();
    fadeInterp = new inkAnimTransparency();
    fadeInterp.SetStartTransparency(1.00);
    fadeInterp.SetEndTransparency(0.00);
    fadeInterp.SetDuration(0.25);
    this.m_animFade2.AddInterpolator(fadeInterp);
    this.m_animFade3 = new inkAnimDef();
    fadeInterp = new inkAnimTransparency();
    fadeInterp.SetStartTransparency(1.00);
    fadeInterp.SetEndTransparency(0.00);
    fadeInterp.SetDuration(0.25);
    this.m_animFade3.AddInterpolator(fadeInterp);
    this.m_animSlow1 = new inkAnimDef();
    fadeInterp = new inkAnimTransparency();
    fadeInterp.SetStartTransparency(1.00);
    fadeInterp.SetEndTransparency(0.25);
    fadeInterp.SetDuration(0.25);
    this.m_animSlow2.AddInterpolator(fadeInterp);
    this.m_animSlow2 = new inkAnimDef();
    fadeInterp = new inkAnimTransparency();
    fadeInterp.SetStartTransparency(1.00);
    fadeInterp.SetEndTransparency(0.25);
    fadeInterp.SetDuration(0.50);
    this.m_animSlow2.AddInterpolator(fadeInterp);
    this.m_animOptions1.loopType = inkanimLoopType.PingPong;
    this.m_animOptions1.loopCounter = 100u;
    this.m_animOptions2.loopType = inkanimLoopType.PingPong;
    this.m_animOptions2.loopCounter = 100u;
    this.m_animOptions2.executionDelay = 0.12;
    this.m_animOptions3.loopType = inkanimLoopType.PingPong;
    this.m_animOptions3.loopCounter = 100u;
    this.m_animOptions3.executionDelay = 0.25;
  }

  public final func PlayAnimationsArrowsDown() -> Void {
    inkWidgetRef.StopAllAnimations(this.m_arrow1Widget);
    inkWidgetRef.StopAllAnimations(this.m_arrow2Widget);
    inkWidgetRef.StopAllAnimations(this.m_arrow3Widget);
    inkWidgetRef.PlayAnimationWithOptions(this.m_arrow1Widget, this.m_animFade1, this.m_animOptions1);
    inkWidgetRef.PlayAnimationWithOptions(this.m_arrow2Widget, this.m_animFade2, this.m_animOptions2);
    inkWidgetRef.PlayAnimationWithOptions(this.m_arrow3Widget, this.m_animFade3, this.m_animOptions3);
  }

  public final func PlayAnimationsArrowsUp() -> Void {
    inkWidgetRef.StopAllAnimations(this.m_arrow1Widget);
    inkWidgetRef.StopAllAnimations(this.m_arrow2Widget);
    inkWidgetRef.StopAllAnimations(this.m_arrow3Widget);
    inkWidgetRef.PlayAnimationWithOptions(this.m_arrow1Widget, this.m_animFade1, this.m_animOptions3);
    inkWidgetRef.PlayAnimationWithOptions(this.m_arrow2Widget, this.m_animFade2, this.m_animOptions2);
    inkWidgetRef.PlayAnimationWithOptions(this.m_arrow3Widget, this.m_animFade3, this.m_animOptions1);
  }

  public final func PlayAltAnimations() -> Void {
    inkWidgetRef.StopAllAnimations(this.m_arrow1Widget);
    inkWidgetRef.StopAllAnimations(this.m_arrow2Widget);
    inkWidgetRef.PlayAnimationWithOptions(this.m_arrow1Widget, this.m_animSlow1, this.m_animOptions1);
    inkWidgetRef.PlayAnimationWithOptions(this.m_arrow2Widget, this.m_animSlow2, this.m_animOptions1);
  }
}
