
public class HubTimeSkipController extends inkLogicController {

  private edit let m_gameTimeText: inkTextRef;

  private edit let m_cantSkipTimeContainer: inkWidgetRef;

  private edit let m_timeSkipButton: inkWidgetRef;

  private let m_gameCtrlRef: wref<gameuiMenuGameController>;

  private let m_timeSystem: wref<TimeSystem>;

  private let m_timeSkipPopupToken: ref<inkGameNotificationToken>;

  private let m_cantSkipTimeAnim: ref<inkAnimProxy>;

  private let m_gameTimeTextParams: ref<inkTextParams>;

  private let m_canSkipTime: Bool;

  public final func Init(isEnabled: Bool, timeSystem: wref<TimeSystem>, gameController: wref<gameuiMenuGameController>) -> Void {
    this.m_canSkipTime = isEnabled;
    this.m_timeSystem = timeSystem;
    this.m_gameCtrlRef = gameController;
    let buttonController: ref<inkButtonController> = inkWidgetRef.GetController(this.m_timeSkipButton) as inkButtonController;
    buttonController.SetEnabled(this.m_canSkipTime);
    if this.m_canSkipTime {
      buttonController.RegisterToCallback(n"OnRelease", this, n"OnTimeSkipButtonPressed");
    } else {
      buttonController.RegisterToCallback(n"OnHoverOver", this, n"OnTimeSkipButtonHoverOver");
      buttonController.RegisterToCallback(n"OnHoverOut", this, n"OnTimeSkipButtonHoverOut");
    };
  }

  private final func UpdateGameTime() -> Void {
    GameTimeUtils.UpdateGameTimeText(this.m_timeSystem, this.m_gameTimeText, this.m_gameTimeTextParams);
  }

  protected cb func OnTimeSkipButtonHoverOver(evt: ref<inkPointerEvent>) -> Bool {
    if !this.m_canSkipTime {
      inkWidgetRef.SetVisible(this.m_cantSkipTimeContainer, true);
      if IsDefined(this.m_cantSkipTimeAnim) {
        this.m_cantSkipTimeAnim.Stop();
      };
      this.m_cantSkipTimeAnim = this.PlayLibraryAnimationOnTargets(n"tooltip_in", SelectWidgets(inkWidgetRef.Get(this.m_cantSkipTimeContainer)));
    };
  }

  protected cb func OnTimeSkipButtonHoverOut(evt: ref<inkPointerEvent>) -> Bool {
    if !this.m_canSkipTime {
      inkWidgetRef.SetVisible(this.m_cantSkipTimeContainer, false);
    };
  }

  protected cb func OnTimeSkipButtonPressed(e: ref<inkPointerEvent>) -> Bool {
    let data: ref<TimeSkipPopupData>;
    if !e.IsAction(n"click") {
      return true;
    };
    this.SetCursorVisibility(false);
    data = new TimeSkipPopupData();
    data.notificationName = n"base\\gameplay\\gui\\widgets\\notifications\\time_skip_popup_new.inkwidget";
    data.isBlocking = true;
    data.useCursor = true;
    data.queueName = n"modal_popup";
    this.m_timeSkipPopupToken = this.m_gameCtrlRef.ShowGameNotification(data);
    this.m_timeSkipPopupToken.RegisterListener(this, n"OnTimeSkipPopupClosed");
    this.PlaySound(n"Button", n"OnPress");
  }

  protected cb func OnTimeSkipPopupClosed(data: ref<inkGameNotificationData>) -> Bool {
    let timeSkipData: ref<TimeSkipPopupCloseData> = data as TimeSkipPopupCloseData;
    this.m_timeSkipPopupToken = null;
    this.SetCursorVisibility(true);
    if timeSkipData.timeChanged {
      this.UpdateGameTime();
      this.PlayLibraryAnimation(n"time_changed");
    };
  }

  private final func SetCursorVisibility(visible: Bool) -> Void {
    let evt: ref<inkMenuLayer_SetCursorVisibility> = new inkMenuLayer_SetCursorVisibility();
    evt.Init(visible);
    this.QueueEvent(evt);
  }
}
