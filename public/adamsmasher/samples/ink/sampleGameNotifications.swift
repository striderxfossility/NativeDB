
public class gameNotificationsTest extends inkGameController {

  public let token: ref<inkGameNotificationToken>;

  protected cb func OnInitialize() -> Bool {
    let data: ref<inkGameNotificationData> = new inkGameNotificationData();
    data.notificationName = n"Test";
    this.token = this.ShowGameNotification(data);
    this.token.RegisterListener(this, n"OnResponse");
  }

  protected cb func OnResponse(data: ref<inkGameNotificationData>) -> Bool {
    this.token = null;
  }
}

public class gameNotificationsReceiverTest extends inkGameController {

  public let token: ref<inkGameNotificationToken>;

  protected cb func OnInitialize() -> Bool {
    let data: ref<inkGameNotificationData> = this.GetRootWidget().GetUserData(n"inkGameNotificationData") as inkGameNotificationData;
    let customData: ref<customGameNotificationDataSet> = new customGameNotificationDataSet();
    customData.customText = n"game notification test text";
    customData.testBool = true;
    data.token.TriggerCallback(customData);
  }
}
