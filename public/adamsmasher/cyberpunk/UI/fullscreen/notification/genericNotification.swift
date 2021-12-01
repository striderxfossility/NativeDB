
public native class GenericNotificationViewData extends IScriptable {

  public native let title: String;

  public native let text: String;

  public native let soundEvent: CName;

  public native let soundAction: CName;

  public let action: ref<GenericNotificationBaseAction>;

  public func CanMerge(data: ref<GenericNotificationViewData>) -> Bool {
    return false;
  }

  public func OnRemoveNotification(data: ref<IScriptable>) -> Bool {
    return false;
  }

  public func GetPriority() -> Int32 {
    return EnumInt(EGenericNotificationPriority.Default);
  }
}

public class GenericNotificationController extends gameuiGenericNotificationReceiverGameController {

  protected edit let m_titleRef: inkTextRef;

  protected edit let m_textRef: inkTextRef;

  protected edit let m_actionLabelRef: inkTextRef;

  protected edit let m_actionRef: inkWidgetRef;

  protected let m_blockAction: Bool;

  private let translationAnimationCtrl: wref<inkTextReplaceController>;

  private let m_data: ref<GenericNotificationViewData>;

  private let m_player: wref<GameObject>;

  private let m_isInteractive: Bool;

  protected cb func OnInitialize() -> Bool {
    this.m_player = this.GetPlayerControlledObject();
  }

  protected cb func OnUninitialize() -> Bool {
    if this.m_isInteractive {
      this.GetPlayerControlledObject().UnregisterInputListener(this);
    };
  }

  public func SetNotificationData(notificationData: ref<GenericNotificationViewData>) -> Void {
    this.m_data = notificationData;
    if this.m_data.action != null {
      inkWidgetRef.SetVisible(this.m_actionRef, true);
      inkTextRef.SetText(this.m_actionLabelRef, this.m_data.action.GetLabel());
      this.m_isInteractive = true;
      this.GetPlayerControlledObject().RegisterInputListener(this, n"NotificationOpen");
    } else {
      inkWidgetRef.SetVisible(this.m_actionRef, false);
      this.m_isInteractive = false;
    };
    if inkWidgetRef.IsValid(this.m_titleRef) {
      inkTextRef.SetText(this.m_titleRef, this.m_data.title);
    };
    if inkWidgetRef.IsValid(this.m_textRef) {
      this.translationAnimationCtrl = inkWidgetRef.GetController(this.m_textRef) as inkTextReplaceController;
      if IsDefined(this.translationAnimationCtrl) {
        this.translationAnimationCtrl.SetTargetText(this.m_data.text);
        this.translationAnimationCtrl.PlaySetAnimation();
      } else {
        inkTextRef.SetText(this.m_textRef, this.m_data.text);
      };
    };
    if NotEquals(this.m_data.soundEvent, n"") && NotEquals(this.m_data.soundAction, n"") {
      this.PlaySound(this.m_data.soundEvent, this.m_data.soundAction);
    };
  }

  protected cb func OnAction(action: ListenerAction, consumer: ListenerActionConsumer) -> Bool {
    if this.m_blockAction {
      return Cast(0);
    };
    if Equals(ListenerAction.GetType(action), gameinputActionType.BUTTON_RELEASED) {
      if this.m_data.action.Execute(this.m_data) {
        ListenerActionConsumer.Consume(consumer);
        this.OnActionTriggered();
      };
    };
  }

  private func OnActionTriggered() -> Void;
}
