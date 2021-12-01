
public class HUDSignalProgressBarController extends inkHUDGameController {

  private edit let m_bar: inkWidgetRef;

  private edit let m_completed: inkWidgetRef;

  private edit let m_signalLost: inkWidgetRef;

  private edit let m_percent: inkTextRef;

  private edit const let m_signalBars: array<inkWidgetRef>;

  private let m_rootWidget: wref<inkWidget>;

  private let m_progressBarBB: wref<IBlackboard>;

  private let m_progressBarDef: ref<UI_HUDSignalProgressBarDef>;

  private let m_stateBBID: ref<CallbackHandle>;

  private let m_progressBBID: ref<CallbackHandle>;

  private let m_signalStrengthBBID: ref<CallbackHandle>;

  private let m_data: HUDProgressBarData;

  private let m_OutroAnimation: ref<inkAnimProxy>;

  private let m_SignalLostAnimation: ref<inkAnimProxy>;

  private let m_IntroAnimation: ref<inkAnimProxy>;

  private let m_alpha_fadein: ref<inkAnimDef>;

  private let m_AnimProxy: ref<inkAnimProxy>;

  private let m_AnimOptions: inkAnimOptions;

  private let alphaInterpolator: ref<inkAnimTransparency>;

  private let tick: Float;

  protected cb func OnInitialize() -> Bool {
    this.m_rootWidget = this.GetRootWidget();
    this.m_rootWidget.SetVisible(false);
    this.SetupBB();
  }

  protected cb func OnUnInitialize() -> Bool {
    this.UnregisterFromBB();
  }

  private final func SetupBB() -> Void {
    this.m_progressBarDef = GetAllBlackboardDefs().UI_HUDSignalProgressBar;
    this.m_progressBarBB = this.GetBlackboardSystem().Get(this.m_progressBarDef);
    if IsDefined(this.m_progressBarBB) {
      this.m_stateBBID = this.m_progressBarBB.RegisterDelayedListenerUint(this.m_progressBarDef.State, this, n"OnStateChanged");
      this.m_progressBBID = this.m_progressBarBB.RegisterDelayedListenerFloat(this.m_progressBarDef.Progress, this, n"OnProgressChanged");
      this.m_signalStrengthBBID = this.m_progressBarBB.RegisterDelayedListenerFloat(this.m_progressBarDef.SignalStrength, this, n"OnSignalStrengthChanged");
    };
  }

  private final func UnregisterFromBB() -> Void {
    this.m_progressBarBB.UnregisterDelayedListener(this.m_progressBarDef.State, this.m_stateBBID);
    this.m_progressBarBB.UnregisterDelayedListener(this.m_progressBarDef.Progress, this.m_progressBBID);
    this.m_progressBarBB.UnregisterDelayedListener(this.m_progressBarDef.SignalStrength, this.m_signalStrengthBBID);
  }

  protected cb func OnStateChanged(state: Uint32) -> Bool {
    let enumState: ProximityProgressBarState = IntEnum(state);
    if Equals(enumState, ProximityProgressBarState.Active) {
      this.Show();
    } else {
      if Equals(enumState, ProximityProgressBarState.Complete) {
      } else {
        if Equals(enumState, ProximityProgressBarState.Inactive) {
          this.Hide();
        };
      };
    };
  }

  protected cb func OnProgressChanged(progress: Float) -> Bool {
    this.UpdateTimerProgress(progress);
  }

  protected cb func OnSignalStrengthChanged(signalStrength: Float) -> Bool {
    this.UpdateSignalProgress(signalStrength);
  }

  public final func UpdateTimerProgress(value: Float) -> Void {
    inkWidgetRef.SetSize(this.m_bar, new Vector2(value * 800.00, 25.00));
    inkTextRef.SetText(this.m_percent, FloatToStringPrec(value * 100.00, 0) + "%");
  }

  public final func UpdateSignalProgress(value: Float) -> Void {
    let signal: Float = 50.00 * value;
    inkWidgetRef.SetSize(this.m_signalBars[0], new Vector2(10.00, MinF(signal * 0.10, 50.00)));
    inkWidgetRef.SetSize(this.m_signalBars[1], new Vector2(10.00, MinF(signal * 0.15, 50.00)));
    inkWidgetRef.SetSize(this.m_signalBars[2], new Vector2(10.00, MinF(signal * 0.20, 50.00)));
    inkWidgetRef.SetSize(this.m_signalBars[3], new Vector2(10.00, MinF(signal * 0.25, 50.00)));
    inkWidgetRef.SetSize(this.m_signalBars[4], new Vector2(10.00, MinF(signal * 0.30, 50.00)));
    inkWidgetRef.SetSize(this.m_signalBars[5], new Vector2(10.00, MinF(signal * 0.35, 50.00)));
    inkWidgetRef.SetSize(this.m_signalBars[6], new Vector2(10.00, MinF(signal * 0.40, 50.00)));
    inkWidgetRef.SetSize(this.m_signalBars[7], new Vector2(10.00, MinF(signal * 0.45, 50.00)));
    inkWidgetRef.SetSize(this.m_signalBars[8], new Vector2(10.00, MinF(signal * 0.50, 50.00)));
    inkWidgetRef.SetSize(this.m_signalBars[9], new Vector2(10.00, MinF(signal * 0.60, 50.00)));
    inkWidgetRef.SetSize(this.m_signalBars[10], new Vector2(10.00, MinF(signal * 0.70, 50.00)));
    inkWidgetRef.SetSize(this.m_signalBars[11], new Vector2(10.00, MinF(signal * 0.80, 50.00)));
    inkWidgetRef.SetSize(this.m_signalBars[12], new Vector2(10.00, MinF(signal * 0.90, 50.00)));
    inkWidgetRef.SetSize(this.m_signalBars[13], new Vector2(10.00, MinF(signal, 50.00)));
    inkWidgetRef.SetSize(this.m_signalBars[14], new Vector2(10.00, MinF(signal * 0.90, 50.00)));
    inkWidgetRef.SetSize(this.m_signalBars[15], new Vector2(10.00, MinF(signal * 0.80, 50.00)));
    inkWidgetRef.SetSize(this.m_signalBars[16], new Vector2(10.00, MinF(signal * 0.70, 50.00)));
    inkWidgetRef.SetSize(this.m_signalBars[17], new Vector2(10.00, MinF(signal * 0.60, 50.00)));
    inkWidgetRef.SetSize(this.m_signalBars[18], new Vector2(10.00, MinF(signal * 0.50, 50.00)));
    inkWidgetRef.SetSize(this.m_signalBars[19], new Vector2(10.00, MinF(signal * 0.45, 50.00)));
    inkWidgetRef.SetSize(this.m_signalBars[20], new Vector2(10.00, MinF(signal * 0.40, 50.00)));
    inkWidgetRef.SetSize(this.m_signalBars[21], new Vector2(10.00, MinF(signal * 0.35, 50.00)));
    inkWidgetRef.SetSize(this.m_signalBars[22], new Vector2(10.00, MinF(signal * 0.30, 50.00)));
    inkWidgetRef.SetSize(this.m_signalBars[23], new Vector2(10.00, MinF(signal * 0.25, 50.00)));
    inkWidgetRef.SetSize(this.m_signalBars[24], new Vector2(10.00, MinF(signal * 0.20, 50.00)));
    inkWidgetRef.SetSize(this.m_signalBars[25], new Vector2(10.00, MinF(signal * 0.15, 50.00)));
    inkWidgetRef.SetSize(this.m_signalBars[26], new Vector2(10.00, MinF(signal * 0.10, 50.00)));
  }

  private final func SignalLost(val: Bool) -> Void {
    if val {
      if !this.m_SignalLostAnimation.IsPlaying() {
        this.m_SignalLostAnimation = this.PlayLibraryAnimation(n"warning");
      };
    } else {
      if this.m_SignalLostAnimation.IsPlaying() {
        this.m_SignalLostAnimation.Stop();
      };
    };
  }

  private final func Show() -> Void {
    this.m_rootWidget.SetVisible(true);
    this.m_IntroAnimation.Stop();
    this.m_OutroAnimation.Stop();
    if !this.m_IntroAnimation.IsPlaying() {
      this.m_IntroAnimation = this.PlayLibraryAnimation(n"intro");
    };
  }

  private final func Completed() -> Void {
    this.m_rootWidget.SetVisible(true);
    this.m_IntroAnimation.Stop();
    this.m_OutroAnimation = this.PlayLibraryAnimation(n"outro");
    this.m_OutroAnimation.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnHide");
  }

  protected cb func OnHide(proxy: ref<inkAnimProxy>) -> Bool {
    this.m_rootWidget.SetVisible(false);
    this.m_OutroAnimation.UnregisterFromCallback(inkanimEventType.OnFinish, this, n"OnHide");
  }

  private final func Hide() -> Void {
    this.m_rootWidget.SetVisible(false);
  }
}
