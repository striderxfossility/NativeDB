
public class HudPhoneMessageController extends HUDPhoneElement {

  private edit let m_MessageText: inkTextRef;

  private let m_MessageAnim: ref<inkAnimProxy>;

  @default(HudPhoneMessageController, messageShowingAnimation)
  private edit let m_ShowingAnimationName: CName;

  @default(HudPhoneMessageController, messageHidingAnimation)
  private edit let m_HidingAnimationName: CName;

  @default(HudPhoneMessageController, messageVisibleAnimation)
  private edit let m_VisibleAnimationName: CName;

  @default(HudPhoneMessageController, 120)
  private edit let m_MessageMaxLength: Int32;

  @default(HudPhoneMessageController, ...)
  private edit let m_MessageTopper: String;

  @default(HudPhoneMessageController, false)
  private let m_Paused: Bool;

  private let m_CurrentMessage: wref<JournalPhoneMessage>;

  private let m_Queue: array<wref<JournalPhoneMessage>>;

  protected final func GetNumElementsInQueue() -> Int32 {
    return ArraySize(this.m_Queue);
  }

  protected final func ClearQueue() -> Void {
    ArrayClear(this.m_Queue);
  }

  protected final func Enqueue(element: wref<JournalPhoneMessage>) -> Void {
    ArrayPush(this.m_Queue, element);
  }

  protected final func Dequeue() -> Void {
    let element: wref<JournalPhoneMessage>;
    if this.GetNumElementsInQueue() > 0 {
      element = this.m_Queue[0];
      ArrayErase(this.m_Queue, 0);
      this.OnDequeue(element);
    };
  }

  public final func ShowMessage(messageToShow: wref<JournalPhoneMessage>) -> Void {
    this.Enqueue(messageToShow);
    this.CheckIfReadyToDequeue();
  }

  protected cb func OnStateChanged(widget: wref<inkWidget>, oldState: CName, newState: CName) -> Bool {
    let currentState: EHudPhoneVisibility;
    this.StopAllAnimations();
    currentState = this.GetStateFromName(newState);
    if Equals(currentState, EHudPhoneVisibility.Showing) {
      this.m_MessageAnim = this.PlayLibraryAnimation(this.m_ShowingAnimationName);
      this.m_MessageAnim.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnAnimationFinished");
    } else {
      if Equals(currentState, EHudPhoneVisibility.Visible) {
        this.m_RootWidget.SetOpacity(1.00);
        this.m_MessageAnim = this.PlayLibraryAnimation(this.m_VisibleAnimationName);
        this.m_MessageAnim.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnAnimationFinished");
      } else {
        if Equals(currentState, EHudPhoneVisibility.Hiding) {
          this.m_MessageAnim = this.PlayLibraryAnimation(this.m_HidingAnimationName);
          this.m_MessageAnim.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnAnimationFinished");
        } else {
          if Equals(currentState, EHudPhoneVisibility.Invisible) {
            this.m_RootWidget.SetOpacity(0.00);
          };
        };
      };
    };
    this.CheckIfReadyToDequeue();
  }

  private final func CheckIfReadyToDequeue() -> Void {
    if !this.m_Paused && Equals(this.GetState(), EHudPhoneVisibility.Invisible) {
      this.Dequeue();
    };
  }

  protected final func OnDequeue(message: wref<JournalPhoneMessage>) -> Void {
    let msgText: String;
    if IsDefined(message) {
      this.m_CurrentMessage = message;
      msgText = message.GetText();
      if StrLen(msgText) > this.m_MessageMaxLength {
        msgText = StrLeft(msgText, this.m_MessageMaxLength - StrLen(this.m_MessageTopper)) + this.m_MessageTopper;
      };
      inkTextRef.SetText(this.m_MessageText, msgText);
      this.Show();
    };
  }

  private final func StopAllAnimations() -> Void {
    if IsDefined(this.m_MessageAnim) {
      this.m_MessageAnim.UnregisterFromCallback(inkanimEventType.OnFinish, this, n"OnAnimationFinished");
      this.m_MessageAnim.Stop();
      this.m_MessageAnim = null;
    };
  }

  protected cb func OnAnimationFinished(anim: ref<inkAnimProxy>) -> Bool {
    let currentState: EHudPhoneVisibility;
    this.StopAllAnimations();
    currentState = this.GetState();
    if Equals(currentState, EHudPhoneVisibility.Showing) {
      this.SetState(EHudPhoneVisibility.Visible);
    } else {
      if Equals(currentState, EHudPhoneVisibility.Visible) {
        this.Hide();
      } else {
        if Equals(currentState, EHudPhoneVisibility.Hiding) {
          this.SetState(EHudPhoneVisibility.Invisible);
        };
      };
    };
  }

  public final func Dismiss() -> Void {
    this.ClearQueue();
    this.Hide();
  }

  public final func Pause() -> Void {
    if !this.m_Paused {
      this.m_Paused = true;
      this.Hide();
    };
  }

  public final func Unpause() -> Void {
    if this.m_Paused {
      this.m_Paused = false;
      this.CheckIfReadyToDequeue();
    };
  }

  public final func GetCurrentMessage() -> wref<JournalPhoneMessage> {
    return this.m_CurrentMessage;
  }
}
