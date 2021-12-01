
public native class StealthIndicatorGameController extends inkHUDGameController {

  private let m_rootWidget: wref<inkCompoundWidget>;

  protected cb func OnInitialize() -> Bool {
    this.m_rootWidget = this.GetRootWidget() as inkCompoundWidget;
  }
}

public native class StealthIndicatorPartLogicController extends BaseDirectionalIndicatorPartLogicController {

  private edit let m_arrowFrontWidget: inkImageRef;

  private edit let m_wrapper: inkCompoundRef;

  @default(StealthIndicatorPartLogicController, 40)
  private edit let m_stealthIndicatorDeadZoneAngle: Float;

  @default(StealthIndicatorPartLogicController, .5)
  private edit let m_slowestFlashTime: Float;

  private let m_rootWidget: wref<inkCompoundWidget>;

  private let m_lastValue: Float;

  private let m_animProxy: ref<inkAnimProxy>;

  private let m_flashAnimProxy: ref<inkAnimProxy>;

  private let m_scaleAnimDef: ref<inkAnimDef>;

  protected cb func OnInitialize() -> Bool {
    this.m_rootWidget = this.GetRootWidget() as inkCompoundWidget;
    this.m_lastValue = 0.00;
    this.OnScaleIn();
  }

  protected cb func OnUpdateDetection(params: gameuiDetectionParams) -> Bool {
    inkImageRef.SetTexturePart(this.m_arrowFrontWidget, StringToName("stealth_fill_00" + RoundF(ClampF(params.detectionProgress, 0.00, 100.00))));
    this.m_rootWidget.SetState(params.detectionProgress >= this.m_lastValue ? n"Increasing" : n"Decreasing");
    if this.m_lastValue == 0.00 && params.detectionProgress != 0.00 {
      this.PlayAnim(n"intro", n"OnIntroComplete", true);
    };
    if this.m_lastValue == 100.00 && params.detectionProgress != 100.00 {
      this.PlayAnim(n"intro", n"OnIntroComplete", true);
    };
    if this.m_lastValue != 100.00 && params.detectionProgress == 100.00 {
      this.PlayAnim(n"outro", n"OnOutroComplete", true);
    };
    if this.m_lastValue != 0.00 && params.detectionProgress == 0.00 {
      this.PlayAnim(n"outro", n"OnOutroComplete", true);
    };
    this.m_lastValue = params.detectionProgress;
  }

  private final func PlayAnim(animName: CName, callback: CName, forceVisible: Bool) -> Void {
    if forceVisible {
      this.m_rootWidget.SetVisible(true);
    };
    this.m_animProxy = this.PlayLibraryAnimation(animName);
    this.m_animProxy.RegisterToCallback(inkanimEventType.OnFinish, this, callback);
  }

  protected cb func OnHideIndicator() -> Bool {
    this.m_rootWidget.SetVisible(false);
  }

  protected cb func OnIntroComplete(proxy: ref<inkAnimProxy>) -> Bool;

  protected cb func OnOutroComplete(proxy: ref<inkAnimProxy>) -> Bool {
    this.m_rootWidget.SetVisible(false);
  }

  private final func OnScaleIn() -> Void {
    this.m_scaleAnimDef = new inkAnimDef();
    let scaleInterpolator: ref<inkAnimScale> = new inkAnimScale();
    scaleInterpolator.SetDuration(0.10);
    scaleInterpolator.SetStartScale(new Vector2(1.00, 1.00));
    scaleInterpolator.SetEndScale(new Vector2(1.00, 1.00));
    scaleInterpolator.SetType(inkanimInterpolationType.Linear);
    scaleInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
    this.m_scaleAnimDef.AddInterpolator(scaleInterpolator);
    this.m_flashAnimProxy = inkWidgetRef.PlayAnimation(this.m_wrapper, this.m_scaleAnimDef);
    this.m_flashAnimProxy.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnScaleInComplete");
  }

  protected cb func OnScaleInComplete(anim: ref<inkAnimProxy>) -> Bool {
    this.m_flashAnimProxy.UnregisterFromCallback(inkanimEventType.OnFinish, this, n"OnScaleInComplete");
    this.OnScreenDelay();
  }

  private final func OnScreenDelay() -> Void {
    let duration: Float = this.m_slowestFlashTime - this.m_lastValue / 100.00;
    this.m_scaleAnimDef = new inkAnimDef();
    let scaleInterpolator: ref<inkAnimScale> = new inkAnimScale();
    scaleInterpolator.SetDuration(duration);
    scaleInterpolator.SetStartScale(new Vector2(1.00, 1.00));
    scaleInterpolator.SetEndScale(new Vector2(1.00, 1.00));
    scaleInterpolator.SetType(inkanimInterpolationType.Linear);
    scaleInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
    this.m_scaleAnimDef.AddInterpolator(scaleInterpolator);
    this.m_flashAnimProxy = inkWidgetRef.PlayAnimation(this.m_wrapper, this.m_scaleAnimDef);
    this.m_flashAnimProxy.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnScreenDelayComplete");
  }

  protected cb func OnScreenDelayComplete(anim: ref<inkAnimProxy>) -> Bool {
    this.m_flashAnimProxy.UnregisterFromCallback(inkanimEventType.OnFinish, this, n"OnScreenDelayComplete");
    this.OnScaleOut();
  }

  private final func OnScaleOut() -> Void {
    this.m_scaleAnimDef = new inkAnimDef();
    let scaleInterpolator: ref<inkAnimScale> = new inkAnimScale();
    scaleInterpolator.SetDuration(0.10);
    scaleInterpolator.SetStartScale(new Vector2(1.00, 1.00));
    scaleInterpolator.SetEndScale(new Vector2(1.00, 1.00));
    scaleInterpolator.SetType(inkanimInterpolationType.Linear);
    scaleInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
    this.m_scaleAnimDef.AddInterpolator(scaleInterpolator);
    this.m_flashAnimProxy = inkWidgetRef.PlayAnimation(this.m_wrapper, this.m_scaleAnimDef);
    this.m_flashAnimProxy.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnScaleOutComplete");
  }

  protected cb func OnScaleOutComplete(anim: ref<inkAnimProxy>) -> Bool {
    this.m_flashAnimProxy.UnregisterFromCallback(inkanimEventType.OnFinish, this, n"OnScaleOutComplete");
    this.OnScaleIn();
  }

  public final native func GetDetectionProgress() -> Vector4;
}
