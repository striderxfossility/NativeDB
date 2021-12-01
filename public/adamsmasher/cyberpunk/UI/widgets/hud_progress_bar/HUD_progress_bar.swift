
public class HUDProgressBarController extends inkHUDGameController {

  private edit let m_bar: inkWidgetRef;

  private edit let m_header: inkTextRef;

  private edit let m_percent: inkTextRef;

  private edit let m_completed: inkTextRef;

  private edit let m_failed: inkTextRef;

  private let m_rootWidget: wref<inkWidget>;

  private let m_progressBarBB: wref<IBlackboard>;

  private let m_progressBarDef: ref<UI_HUDProgressBarDef>;

  private let m_activeBBID: ref<CallbackHandle>;

  private let m_headerBBID: ref<CallbackHandle>;

  private let m_progressBBID: ref<CallbackHandle>;

  private let m_OutroAnimation: ref<inkAnimProxy>;

  private let m_LoopAnimation: ref<inkAnimProxy>;

  private let m_IntroAnimation: ref<inkAnimProxy>;

  private let m_IntroWasPlayed: Bool;

  private let valueSaved: Float;

  protected cb func OnInitialize() -> Bool {
    this.m_rootWidget = this.GetRootWidget();
    this.m_rootWidget.SetVisible(false);
    this.SetupBB();
  }

  protected cb func OnUnInitialize() -> Bool {
    this.UnregisterFromBB();
  }

  private final func SetupBB() -> Void {
    this.m_progressBarDef = GetAllBlackboardDefs().UI_HUDProgressBar;
    this.m_progressBarBB = this.GetBlackboardSystem().Get(this.m_progressBarDef);
    if IsDefined(this.m_progressBarBB) {
      this.m_activeBBID = this.m_progressBarBB.RegisterDelayedListenerBool(this.m_progressBarDef.Active, this, n"OnActivated");
      this.m_headerBBID = this.m_progressBarBB.RegisterDelayedListenerString(this.m_progressBarDef.Header, this, n"OnHeaderChanged");
      this.m_progressBBID = this.m_progressBarBB.RegisterDelayedListenerFloat(this.m_progressBarDef.Progress, this, n"OnProgressChanged");
    };
    if this.m_progressBarBB.GetBool(this.m_progressBarDef.Active) {
      this.Intro();
      this.m_IntroAnimation.GotoEndAndStop();
    };
  }

  private final func UnregisterFromBB() -> Void {
    if IsDefined(this.m_activeBBID) {
      this.m_progressBarBB.UnregisterDelayedListener(this.m_progressBarDef.Active, this.m_activeBBID);
      this.m_progressBarBB.UnregisterDelayedListener(this.m_progressBarDef.Header, this.m_headerBBID);
      this.m_progressBarBB.UnregisterDelayedListener(this.m_progressBarDef.Progress, this.m_progressBBID);
    };
  }

  protected cb func OnActivated(activated: Bool) -> Bool {
    this.UpdateProgressBarActive(activated);
  }

  protected cb func OnHeaderChanged(header: String) -> Bool {
    this.UpdateTimerHeader(header);
  }

  protected cb func OnProgressChanged(progress: Float) -> Bool {
    this.UpdateTimerProgress(progress);
  }

  public final func UpdateProgressBarActive(active: Bool) -> Void {
    if active {
      this.Intro();
    } else {
      this.Outro();
    };
  }

  public final func UpdateTimerProgress(value: Float) -> Void {
    inkWidgetRef.SetSize(this.m_bar, new Vector2(value * 600.00, 6.00));
    inkTextRef.SetText(this.m_percent, FloatToStringPrec(value * 100.00, 0));
    this.valueSaved = value;
    this.m_rootWidget.SetVisible(true);
    GameInstance.GetAudioSystem(this.GetPlayerControlledObject().GetGame()).Parameter(n"ui_loading_bar", value);
  }

  public final func UpdateTimerHeader(label: String) -> Void {
    inkTextRef.SetText(this.m_header, label);
  }

  private final func Intro() -> Void {
    this.m_OutroAnimation.Stop();
    this.m_IntroAnimation.Stop();
    this.m_rootWidget.SetVisible(true);
    if !this.m_IntroAnimation.IsPlaying() && !this.m_IntroWasPlayed {
      this.m_IntroAnimation = this.PlayLibraryAnimation(n"Quickhack_Intro");
      this.m_IntroAnimation.RegisterToCallback(inkanimEventType.OnFinish, this, n"IntroEnded");
      GameInstance.GetAudioSystem(this.GetPlayerControlledObject().GetGame()).Play(n"ui_loading_bar_start");
    };
  }

  private final func Outro() -> Void {
    this.m_OutroAnimation.Stop();
    this.m_IntroAnimation.Stop();
    if this.valueSaved < 0.96 {
      this.m_OutroAnimation = this.PlayLibraryAnimation(n"Quickhack_Outro_Failed");
    } else {
      this.m_OutroAnimation = this.PlayLibraryAnimation(n"Quickhack_Outro");
    };
    this.m_OutroAnimation.RegisterToCallback(inkanimEventType.OnFinish, this, n"Hide");
    GameInstance.GetAudioSystem(this.GetPlayerControlledObject().GetGame()).Play(n"ui_loading_bar_stop");
  }

  public final func IntroEnded() -> Void {
    this.m_IntroWasPlayed = true;
    this.m_OutroAnimation.Stop();
    this.m_IntroAnimation.Stop();
    this.m_IntroAnimation.Stop();
    this.m_LoopAnimation = this.PlayLibraryAnimation(n"Quickhack_Loop");
  }

  public final func Hide() -> Void {
    this.m_OutroAnimation.Stop();
    this.m_IntroAnimation.Stop();
    this.m_LoopAnimation.Stop();
    this.m_rootWidget.SetVisible(false);
    this.m_IntroWasPlayed = false;
  }
}
