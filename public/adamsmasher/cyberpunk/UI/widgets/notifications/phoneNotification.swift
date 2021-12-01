
public class PhoneMessageNotificationsGameController extends inkGameController {

  @default(PhoneMessageNotificationsGameController, 60)
  private let m_maxMessageSize: Int32;

  private edit let m_title: inkTextRef;

  private edit let m_text: inkTextRef;

  private edit let m_actionText: inkTextRef;

  private edit let m_actionPanel: wref<inkWidget>;

  private let m_player: wref<PlayerPuppet>;

  private let m_animationProxy: ref<inkAnimProxy>;

  private let m_data: wref<JournalNotificationData>;

  protected cb func OnInitialize() -> Bool {
    this.m_data = this.GetRootWidget().GetUserData(n"JournalNotificationData") as JournalNotificationData;
    this.m_player = this.GetOwnerEntity() as PlayerPuppet;
    this.m_player.RegisterInputListener(this, n"NotificationOpen");
    this.ShowNotification();
  }

  protected cb func OnUninitialize() -> Bool {
    this.m_player.UnregisterInputListener(this);
  }

  protected cb func OnAction(action: ListenerAction, consumer: ListenerActionConsumer) -> Bool {
    if Equals(ListenerAction.GetType(action), gameinputActionType.BUTTON_RELEASED) {
      if Equals(ListenerAction.GetName(action), n"NotificationOpen") {
        this.ShowPopup();
      };
    };
  }

  private final func ShowPopup() -> Void {
    let evt: ref<PhoneMessagePopupEvent> = new PhoneMessagePopupEvent();
    evt.m_data = new JournalNotificationData();
    evt.m_data.journalEntry = this.m_data.journalEntry;
    evt.m_data.journalEntryState = this.m_data.journalEntryState;
    evt.m_data.className = this.m_data.className;
    evt.m_data.queueName = n"modal_popup";
    evt.m_data.notificationName = n"base\\gameplay\\gui\\widgets\\notifications\\phone_message_popup.inkwidget";
    evt.m_data.isBlocking = true;
    this.QueueEvent(evt);
  }

  private final func ShowNotification() -> Void {
    let text: String;
    let entry: wref<JournalPhoneMessage> = this.m_data.journalEntry as JournalPhoneMessage;
    let contact: wref<JournalContact> = GameInstance.GetJournalManager(this.m_player.GetGame()).GetParentEntry(entry) as JournalContact;
    inkTextRef.SetText(this.m_title, contact.GetLocalizedName(GameInstance.GetJournalManager(this.m_player.GetGame())));
    text = entry.GetText();
    if StrLen(text) > this.m_maxMessageSize {
      text = StrLeft(text, this.m_maxMessageSize) + "...";
    };
    inkTextRef.SetText(this.m_text, text);
    this.PlayIntroAnimation();
  }

  private final func PlayIntroAnimation() -> Void {
    this.m_animationProxy = this.PlayLibraryAnimation(n"Outro");
    this.m_animationProxy.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnOutroAnimFinished");
  }

  protected cb func OnOutroAnimFinished(anim: ref<inkAnimProxy>) -> Bool {
    let fakeData: ref<inkGameNotificationData>;
    this.m_data.token.TriggerCallback(fakeData);
  }
}
