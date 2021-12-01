
public class WarningMessageGameController extends inkHUDGameController {

  private let m_root: wref<inkWidget>;

  private edit let m_mainTextWidget: inkTextRef;

  private let m_blackboard: wref<IBlackboard>;

  private let m_blackboardDef: ref<UI_NotificationsDef>;

  private let m_warningMessageCallbackId: ref<CallbackHandle>;

  private let m_simpleMessage: SimpleScreenMessage;

  private let m_blinkingAnim: ref<inkAnimDef>;

  private let m_showAnim: ref<inkAnimDef>;

  private let m_hideAnim: ref<inkAnimDef>;

  private let m_animProxyShow: ref<inkAnimProxy>;

  private let m_animProxyHide: ref<inkAnimProxy>;

  private let m_animProxyTimeout: ref<inkAnimProxy>;

  protected cb func OnInitialize() -> Bool {
    let msgVariant: Variant;
    this.m_root = this.GetRootWidget();
    this.m_root.SetVisible(false);
    this.m_blackboardDef = GetAllBlackboardDefs().UI_Notifications;
    this.m_blackboard = this.GetBlackboardSystem().Get(this.m_blackboardDef);
    this.m_warningMessageCallbackId = this.m_blackboard.RegisterDelayedListenerVariant(this.m_blackboardDef.WarningMessage, this, n"OnWarningMessageUpdate");
    msgVariant = this.m_blackboard.GetVariant(this.m_blackboardDef.WarningMessage);
    if VariantIsValid(msgVariant) {
      this.m_simpleMessage = FromVariant(msgVariant);
    };
    this.CreateAnimations();
  }

  protected cb func OnUnitialize() -> Bool {
    this.m_blackboard.UnregisterDelayedListener(this.m_blackboardDef.WarningMessage, this.m_warningMessageCallbackId);
  }

  protected cb func OnWarningMessageUpdate(value: Variant) -> Bool {
    this.m_simpleMessage = FromVariant(value);
    this.UpdateWidgets();
  }

  private final func UpdateWidgets() -> Void {
    let playbackOptions: inkAnimOptions;
    this.m_root.StopAllAnimations();
    if this.m_simpleMessage.isShown && NotEquals(this.m_simpleMessage.message, "Lorem Ipsum") && NotEquals(this.m_simpleMessage.message, "") {
      inkTextRef.SetLetterCase(this.m_mainTextWidget, textLetterCase.UpperCase);
      inkTextRef.SetText(this.m_mainTextWidget, this.m_simpleMessage.message);
      GameInstance.GetAudioSystem(this.GetPlayerControlledObject().GetGame()).Play(n"ui_jingle_chip_malfunction");
      if this.m_simpleMessage.isInstant {
        playbackOptions.fromMarker = n"idle_start";
      };
      playbackOptions.toMarker = n"freeze_intro";
      if IsDefined(this.m_animProxyShow) {
        this.m_animProxyShow.Stop();
      };
      this.m_animProxyShow = this.PlayLibraryAnimation(n"warning", playbackOptions);
      this.m_animProxyShow.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnShown");
      this.m_root.SetVisible(true);
    } else {
      playbackOptions.fromMarker = n"freeze_outro";
      this.m_animProxyHide = this.PlayLibraryAnimation(n"warning", playbackOptions);
      this.m_animProxyHide.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnHidden");
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
      this.m_blackboard.SetVariant(this.m_blackboardDef.WarningMessage, ToVariant(NoScreenMessage()));
    };
  }

  protected cb func OnShown(anim: ref<inkAnimProxy>) -> Bool {
    if anim.IsFinished() {
      this.TriggerBlinkAnimation();
    };
    if this.m_simpleMessage.duration > 0.00 {
      this.SetTimeout(this.m_simpleMessage.duration);
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

  private final func TriggerBlinkAnimation() -> Void;

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
