
public class AnimatedListItemController extends ListItemController {

  @default(AnimatedListItemController, MenuButtonFadeOut)
  protected edit let m_animOutName: CName;

  @default(AnimatedListItemController, MenuButtonPulse)
  protected edit let m_animPulseName: CName;

  protected edit let m_animTargetHover: inkWidgetRef;

  protected edit let m_animTargetPulse: inkWidgetRef;

  @default(AnimatedListItemController, 1.0f)
  protected edit let m_normalRootOpacity: Float;

  @default(AnimatedListItemController, 1.0f)
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
    let fadeOutInterp: ref<inkAnimTransparency>;
    let pulseInterp: ref<inkAnimTransparency>;
    super.OnInitialize();
    this.m_rootWidget = this.GetRootCompoundWidget();
    this.m_animTarget_Hover = inkWidgetRef.Get(this.m_animTargetHover);
    this.m_animTarget_Pulse = inkWidgetRef.Get(this.m_animTargetPulse);
    this.m_animHover = new inkAnimDef();
    fadeOutInterp = new inkAnimTransparency();
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
    this.RegisterToCallback(n"OnAddedToList", this, n"OnAddedToList");
  }

  protected cb func OnUninitialize() -> Bool {
    this.UnregisterFromCallback(n"OnAddedToList", this, n"OnAddedToList");
  }

  protected cb func OnButtonStateChanged(controller: wref<inkButtonController>, oldState: inkEButtonState, newState: inkEButtonState) -> Bool {
    if Equals(oldState, inkEButtonState.Normal) && Equals(newState, inkEButtonState.Hover) {
      this.m_rootWidget.SetOpacity(this.m_hoverRootOpacity);
      this.m_animHoverProxy.Stop();
      this.m_animTarget_Hover.SetOpacity(1.00);
      if inkWidgetRef.IsValid(this.m_animTargetPulse) {
        this.m_animPulseProxy.Stop();
        this.m_animPulseProxy = this.m_animTarget_Pulse.PlayAnimationWithOptions(this.m_animPulse, this.m_animPulseOptions);
      };
      this.SetCursorContext(n"Hover");
    } else {
      if Equals(oldState, inkEButtonState.Hover) && NotEquals(newState, inkEButtonState.Hover) {
        this.m_rootWidget.SetOpacity(this.m_normalRootOpacity);
        this.m_animHoverProxy.Stop();
        this.m_animHoverProxy = this.m_animTarget_Hover.PlayAnimation(this.m_animHover);
        if inkWidgetRef.IsValid(this.m_animTargetPulse) {
          this.m_animPulseProxy.Stop();
          this.m_animTarget_Pulse.SetOpacity(0.00);
        };
        this.SetCursorContext(n"Default");
      };
    };
  }

  protected cb func OnAddedToList(target: wref<ListItemController>) -> Bool {
    let m_animListText: ref<inkAnimDef>;
    let m_animTextInterp: ref<inkAnimTextOffset>;
    let stageOneTime: Float;
    let stageTwoTime: Float;
    if !inkWidgetRef.IsValid(this.m_labelPathRef) {
      return false;
    };
    if this.GetIndex() == 0 {
      m_animListText = new inkAnimDef();
      m_animTextInterp = new inkAnimTextOffset();
      m_animTextInterp.SetDuration(0.08);
      m_animTextInterp.SetStartProgress(0.25);
      m_animTextInterp.SetEndProgress(0.00);
      m_animListText.AddInterpolator(m_animTextInterp);
      inkWidgetRef.Get(this.m_labelPathRef).PlayAnimation(m_animListText);
    } else {
      stageOneTime = 0.10;
      stageTwoTime = 0.10 + MinF(5.00, Cast(this.GetIndex())) * 0.15;
      m_animListText = new inkAnimDef();
      m_animTextInterp = new inkAnimTextOffset();
      m_animTextInterp.SetStartDelay(0.00);
      m_animTextInterp.SetDuration(stageOneTime);
      m_animTextInterp.SetStartProgress(0.75);
      m_animTextInterp.SetEndProgress(0.01);
      m_animTextInterp.SetType(inkanimInterpolationType.Quadratic);
      m_animTextInterp.SetMode(inkanimInterpolationMode.EasyOut);
      m_animListText.AddInterpolator(m_animTextInterp);
      m_animTextInterp = new inkAnimTextOffset();
      m_animTextInterp.SetStartDelay(stageOneTime);
      m_animTextInterp.SetDuration(stageTwoTime);
      m_animTextInterp.SetStartProgress(0.01);
      m_animTextInterp.SetEndProgress(0.00);
      m_animTextInterp.SetType(inkanimInterpolationType.Quadratic);
      m_animTextInterp.SetMode(inkanimInterpolationMode.EasyOut);
      m_animListText.AddInterpolator(m_animTextInterp);
      inkWidgetRef.Get(this.m_labelPathRef).PlayAnimation(m_animListText);
    };
  }
}
