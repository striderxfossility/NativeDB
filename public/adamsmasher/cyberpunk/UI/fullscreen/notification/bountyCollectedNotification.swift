
public class BountyCollectedNotificationQueue extends gameuiGenericNotificationGameController {

  @default(BountyCollectedNotificationQueue, 2.0f)
  protected edit let m_duration: Float;

  @default(BountyCollectedNotificationQueue, notification_bounty)
  private let m_bountyNotification: CName;

  public final func PushNotification() -> Void {
    let notificationData: gameuiGenericNotificationData;
    notificationData.time = this.m_duration;
    notificationData.widgetLibraryItemName = this.m_bountyNotification;
    notificationData.notificationData = new BountyCollectedNotificationViewData();
    this.AddNewNotificationData(notificationData);
  }

  protected cb func OnBountyCompletionEvent(evt: ref<BountyCompletionEvent>) -> Bool {
    this.PushNotification();
  }
}

public class BountyCollectedNotificationViewData extends GenericNotificationViewData {

  public func CanMerge(data: ref<GenericNotificationViewData>) -> Bool {
    return false;
  }
}

public class BountyCollectedNotification extends GenericNotificationController {

  private edit let m_bountyCollectedUpdateAnimation: CName;

  public func SetNotificationData(notificationData: ref<GenericNotificationViewData>) -> Void {
    this.PlayLibraryAnimation(this.m_bountyCollectedUpdateAnimation);
    this.SetNotificationData(notificationData);
  }
}
