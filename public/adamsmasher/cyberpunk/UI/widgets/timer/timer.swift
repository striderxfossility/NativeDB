
public class TimerGameController extends inkHUDGameController {

  private edit let m_value: inkTextRef;

  private let m_rootWidget: wref<inkWidget>;

  private let m_timerBB: wref<IBlackboard>;

  private let m_timerDef: ref<UIGameDataDef>;

  private let m_activeBBID: ref<CallbackHandle>;

  private let m_progressBBID: ref<CallbackHandle>;

  protected cb func OnInitialize() -> Bool {
    this.m_rootWidget = this.GetRootWidget();
    this.m_rootWidget.SetVisible(false);
    this.SetupBB();
  }

  protected cb func OnUninitialize() -> Bool {
    this.UnregisterFromBB();
  }

  private final func SetupBB() -> Void {
    this.m_timerDef = GetAllBlackboardDefs().UIGameData;
    this.m_timerBB = this.GetBlackboardSystem().Get(this.m_timerDef);
    if IsDefined(this.m_timerBB) {
      this.m_activeBBID = this.m_timerBB.RegisterDelayedListenerFloat(this.m_timerDef.QuestTimerInitialDuration, this, n"OnTimerActiveUpdated");
      this.m_progressBBID = this.m_timerBB.RegisterDelayedListenerFloat(this.m_timerDef.QuestTimerCurrentDuration, this, n"OnTimerProgressUpdated");
    };
  }

  private final func UnregisterFromBB() -> Void {
    if IsDefined(this.m_timerBB) {
      this.m_timerBB.UnregisterDelayedListener(this.m_timerDef.QuestTimerInitialDuration, this.m_activeBBID);
      this.m_timerBB.UnregisterDelayedListener(this.m_timerDef.QuestTimerCurrentDuration, this.m_progressBBID);
    };
  }

  protected cb func OnTimerActiveUpdated(value: Float) -> Bool {
    this.UpdateTimerActive(value);
  }

  protected cb func OnTimerProgressUpdated(value: Float) -> Bool {
    this.UpdateTimerProgress(value);
  }

  public final func UpdateTimerActive(value: Float) -> Void {
    let active: Bool;
    if value > 0.00 {
      active = true;
    };
    if active {
      this.Intro();
    } else {
      this.Outro();
    };
  }

  public final func UpdateTimerProgress(time: Float) -> Void {
    let res: String;
    let minutes: Int32 = FloorF(time / 60.00);
    let seconds: Int32 = FloorF(time - Cast(60 * minutes));
    if minutes <= 9 {
      res += "0";
    };
    res += IntToString(minutes) + ":";
    if seconds <= 9 {
      res += "0";
    };
    res += IntToString(seconds);
    inkTextRef.SetText(this.m_value, res);
  }

  private final func Intro() -> Void {
    this.m_rootWidget.SetVisible(true);
  }

  private final func Outro() -> Void {
    this.Hide();
  }

  public final func Hide() -> Void {
    this.m_rootWidget.SetVisible(false);
  }
}
