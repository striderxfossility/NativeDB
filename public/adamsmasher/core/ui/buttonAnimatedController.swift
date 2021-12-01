
public class inkButtonAnimatedController extends inkButtonController {

  protected edit let m_animTargetHover: inkWidgetRef;

  protected edit let m_animTargetPulse: inkWidgetRef;

  @default(inkButtonAnimatedController, 1.0f)
  protected edit let m_normalRootOpacity: Float;

  @default(inkButtonAnimatedController, 1.0f)
  protected edit let m_hoverRootOpacity: Float;

  protected let m_rootWidget: wref<inkCompoundWidget>;

  protected let m_animTarget_Hover: wref<inkWidget>;

  protected let m_animTarget_Pulse: wref<inkWidget>;

  private let m_animHover: ref<inkAnimDef>;

  private let m_animPulse: ref<inkAnimDef>;

  private let m_animHoverProxy: ref<inkAnimProxy>;

  private let m_animPulseProxy: ref<inkAnimProxy>;

  private let m_animPulseOptions: inkAnimOptions;

  protected cb func OnInitialize() -> Bool {
    let pulseInterp: ref<inkAnimTransparency>;
    this.m_rootWidget = this.GetRootCompoundWidget();
    this.m_animTarget_Hover = inkWidgetRef.Get(this.m_animTargetHover);
    this.m_animTarget_Pulse = inkWidgetRef.Get(this.m_animTargetPulse);
    this.m_animHover = new inkAnimDef();
    let fadeOutInterp: ref<inkAnimTransparency> = new inkAnimTransparency();
    fadeOutInterp.SetStartTransparency(1.00);
    fadeOutInterp.SetEndTransparency(0.00);
    fadeOutInterp.SetDuration(0.15);
    this.m_animHover.AddInterpolator(fadeOutInterp);
    this.m_animPulse = new inkAnimDef();
    pulseInterp = new inkAnimTransparency();
    pulseInterp.SetStartTransparency(1.00);
    pulseInterp.SetEndTransparency(0.50);
    pulseInterp.SetDuration(0.75);
    this.m_animPulse.AddInterpolator(pulseInterp);
    pulseInterp = new inkAnimTransparency();
    pulseInterp.SetStartTransparency(1.00);
    pulseInterp.SetEndTransparency(1.00);
    pulseInterp.SetDuration(1.00);
    this.m_animPulse.AddInterpolator(pulseInterp);
    pulseInterp = new inkAnimTransparency();
    pulseInterp.SetStartTransparency(1.00);
    pulseInterp.SetEndTransparency(0.50);
    pulseInterp.SetDuration(0.75);
    this.m_animPulse.AddInterpolator(pulseInterp);
    pulseInterp = new inkAnimTransparency();
    pulseInterp.SetStartTransparency(0.50);
    pulseInterp.SetEndTransparency(0.50);
    pulseInterp.SetDuration(1.00);
    this.m_animPulse.AddInterpolator(pulseInterp);
    this.m_animPulseOptions.loopType = inkanimLoopType.Cycle;
    this.m_animPulseOptions.loopCounter = 500u;
  }

  protected cb func OnUnitialize() -> Bool;

  public final func SetButtonText(argValue: String) -> Void {
    let currListText: wref<inkText> = this.GetButton();
    currListText.SetText(argValue);
  }

  public final func GetButtonText() -> String {
    let currListText: wref<inkText> = this.GetButton();
    return currListText.GetText();
  }

  private final func GetButton() -> wref<inkText> {
    let root: wref<inkCanvas> = this.GetRootWidget() as inkCanvas;
    let currListText: wref<inkText> = root.GetWidget(n"textLabel") as inkText;
    return currListText;
  }

  protected cb func OnButtonStateChanged(controller: wref<inkButtonController>, oldState: inkEButtonState, newState: inkEButtonState) -> Bool {
    if Equals(oldState, inkEButtonState.Normal) && Equals(newState, inkEButtonState.Hover) {
      this.m_rootWidget.SetOpacity(this.m_hoverRootOpacity);
      this.m_animHoverProxy.Stop();
      this.m_animTarget_Hover.SetOpacity(1.00);
      this.m_animPulseProxy.Stop();
      this.m_animPulseProxy = this.m_animTarget_Pulse.PlayAnimationWithOptions(this.m_animPulse, this.m_animPulseOptions);
      this.SetCursorContext(n"Hover");
    } else {
      if Equals(oldState, inkEButtonState.Hover) && NotEquals(newState, inkEButtonState.Hover) {
        this.m_rootWidget.SetOpacity(this.m_normalRootOpacity);
        this.m_animHoverProxy.Stop();
        this.m_animHoverProxy = this.m_animTarget_Hover.PlayAnimation(this.m_animHover);
        this.m_animPulseProxy.Stop();
        this.m_animTarget_Pulse.SetOpacity(0.00);
        this.SetCursorContext(n"Default");
      };
    };
    if Equals(newState, inkEButtonState.Press) {
      this.PlaySound(n"Button", n"OnPress");
    } else {
      if Equals(newState, inkEButtonState.Hover) && NotEquals(oldState, inkEButtonState.Press) {
        this.PlaySound(n"Button", n"OnHover");
      };
    };
  }
}
