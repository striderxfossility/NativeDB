
public class OnscreenMessageGameController extends inkHUDGameController {

  private let m_root: wref<inkWidget>;

  private let m_blackboard: wref<IBlackboard>;

  private let m_blackboardDef: ref<UI_NotificationsDef>;

  private let m_screenMessageUpdateCallbackId: ref<CallbackHandle>;

  private let m_screenMessage: SimpleScreenMessage;

  private edit let m_mainTextWidget: inkTextRef;

  private let m_blinkingAnim: ref<inkAnimDef>;

  private let m_showAnim: ref<inkAnimDef>;

  private let m_hideAnim: ref<inkAnimDef>;

  private let m_animProxyShow: ref<inkAnimProxy>;

  private let m_animProxyHide: ref<inkAnimProxy>;

  private let m_animProxyTimeout: ref<inkAnimProxy>;

  protected cb func OnInitialize() -> Bool {
    let variant: Variant;
    this.m_root = this.GetRootWidget();
    this.m_root.SetVisible(false);
    this.m_blackboardDef = GetAllBlackboardDefs().UI_Notifications;
    this.m_blackboard = this.GetBlackboardSystem().Get(this.m_blackboardDef);
    this.m_screenMessageUpdateCallbackId = this.m_blackboard.RegisterDelayedListenerVariant(this.m_blackboardDef.OnscreenMessage, this, n"OnScreenMessageUpdate");
    variant = this.m_blackboard.GetVariant(this.m_blackboardDef.OnscreenMessage);
    if VariantIsValid(variant) {
      this.m_screenMessage = FromVariant(variant);
    };
    this.CreateAnimations();
  }

  protected cb func OnUnitialize() -> Bool {
    this.m_blackboard.UnregisterDelayedListener(this.m_blackboardDef.OnscreenMessage, this.m_screenMessageUpdateCallbackId);
  }

  protected cb func OnScreenMessageUpdate(value: Variant) -> Bool {
    this.m_screenMessage = FromVariant(value);
    this.UpdateWidgets();
  }

  private final func UpdateWidgets() -> Void {
    this.m_root.StopAllAnimations();
    if this.m_screenMessage.isShown {
      inkTextRef.SetLetterCase(this.m_mainTextWidget, textLetterCase.UpperCase);
      inkTextRef.SetText(this.m_mainTextWidget, GetLocalizedText(this.m_screenMessage.message));
      this.m_root.SetVisible(true);
      this.m_animProxyShow = this.PlayLibraryAnimation(n"CInematic_Subtitle");
    } else {
      this.m_root.SetVisible(false);
    };
  }

  private final func SetTimeout(value: Float) -> Void {
    let interpol: ref<inkAnimTransparency>;
    let timeoutAnim: ref<inkAnimDef>;
    if value > 0.00 {
      timeoutAnim = new inkAnimDef();
      interpol = new inkAnimTransparency();
      interpol.SetDuration(value);
      interpol.SetStartTransparency(1.00);
      interpol.SetEndTransparency(1.00);
      interpol.SetIsAdditive(true);
      timeoutAnim.AddInterpolator(interpol);
      this.m_animProxyTimeout = this.m_root.PlayAnimation(timeoutAnim);
      this.m_animProxyTimeout.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnTimeout");
    };
  }

  protected cb func OnTimeout(anim: ref<inkAnimProxy>) -> Bool {
    if anim.IsFinished() {
      this.m_blackboard.SetVariant(this.m_blackboardDef.OnscreenMessage, ToVariant(NoScreenMessage()));
    };
  }

  protected cb func OnShown(anim: ref<inkAnimProxy>) -> Bool {
    if anim.IsFinished() {
      this.TriggerBlinkAnimation();
    };
  }

  protected cb func OnBlinkAnimation(anim: ref<inkAnimProxy>) -> Bool {
    if anim.IsFinished() {
      this.TriggerBlinkAnimation();
    };
  }

  protected cb func OnHidden(anim: ref<inkAnimProxy>) -> Bool {
    this.m_root.SetVisible(false);
  }

  private final func TriggerBlinkAnimation() -> Void {
    let proxy: ref<inkAnimProxy> = this.m_root.PlayAnimation(this.m_blinkingAnim);
    proxy.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnBlinkAnimation");
  }

  private final func CreateAnimations() -> Void {
    let alphaBlinkInInterpol: ref<inkAnimTransparency>;
    let alphaHideInterpol: ref<inkAnimTransparency>;
    let alphaShowInterpol: ref<inkAnimTransparency>;
    this.m_blinkingAnim = new inkAnimDef();
    let alphaBlinkOutInterpol: ref<inkAnimTransparency> = new inkAnimTransparency();
    alphaBlinkOutInterpol.SetStartTransparency(1.00);
    alphaBlinkOutInterpol.SetEndTransparency(0.40);
    alphaBlinkOutInterpol.SetDuration(0.50);
    alphaBlinkOutInterpol.SetType(inkanimInterpolationType.Linear);
    alphaBlinkOutInterpol.SetMode(inkanimInterpolationMode.EasyOut);
    alphaBlinkInInterpol = new inkAnimTransparency();
    alphaBlinkInInterpol.SetStartTransparency(0.40);
    alphaBlinkInInterpol.SetEndTransparency(1.00);
    alphaBlinkInInterpol.SetDuration(0.50);
    alphaBlinkInInterpol.SetStartDelay(0.50);
    alphaBlinkInInterpol.SetType(inkanimInterpolationType.Linear);
    alphaBlinkInInterpol.SetMode(inkanimInterpolationMode.EasyOut);
    this.m_blinkingAnim.AddInterpolator(alphaBlinkOutInterpol);
    this.m_blinkingAnim.AddInterpolator(alphaBlinkInInterpol);
    this.m_showAnim = new inkAnimDef();
    alphaShowInterpol = new inkAnimTransparency();
    alphaShowInterpol.SetStartTransparency(0.00);
    alphaShowInterpol.SetEndTransparency(1.00);
    alphaShowInterpol.SetDuration(0.50);
    alphaShowInterpol.SetType(inkanimInterpolationType.Exponential);
    alphaShowInterpol.SetMode(inkanimInterpolationMode.EasyOut);
    this.m_showAnim.AddInterpolator(alphaShowInterpol);
    this.m_hideAnim = new inkAnimDef();
    alphaHideInterpol = new inkAnimTransparency();
    alphaHideInterpol.SetStartTransparency(1.00);
    alphaHideInterpol.SetEndTransparency(0.00);
    alphaHideInterpol.SetDuration(1.00);
    alphaBlinkInInterpol.SetStartDelay(0.10);
    alphaHideInterpol.SetType(inkanimInterpolationType.Exponential);
    alphaHideInterpol.SetMode(inkanimInterpolationMode.EasyOut);
    this.m_hideAnim.AddInterpolator(alphaHideInterpol);
  }
}
