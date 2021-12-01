
public class CraftingNotificationViewData extends GenericNotificationViewData {

  public let m_canBeMerged: Bool;

  public func CanMerge(data: ref<GenericNotificationViewData>) -> Bool {
    return this.m_canBeMerged;
  }
}

public class CraftingNotificationQueue extends gameuiGenericNotificationGameController {

  @default(CraftingNotificationQueue, 2.0f)
  private edit let m_duration: Float;

  public func GetShouldSaveState() -> Bool {
    return false;
  }

  public func GetID() -> Int32 {
    return EnumInt(GenericNotificationType.CraftingNotification);
  }

  protected cb func OnCraftingNotification(evt: ref<CraftingNotificationEvent>) -> Bool {
    let notificationData: gameuiGenericNotificationData;
    let title: String;
    let userData: ref<CraftingNotificationViewData>;
    switch evt.notificationType {
      case CraftingNotificationType.NoPerks:
        title = GetLocalizedText("UI-Notifications-CraftingNotEnoughPerks") + " " + GetLocalizedText(evt.perkName);
        break;
      case CraftingNotificationType.NotEnoughMaterial:
        title = "UI-Notifications-CraftingNotEnoughMaterials";
    };
    userData = new CraftingNotificationViewData();
    userData.title = title;
    userData.soundEvent = n"QuestSuccessPopup";
    userData.soundAction = n"OnOpen";
    userData.m_canBeMerged = true;
    notificationData.time = this.m_duration;
    notificationData.widgetLibraryItemName = n"crafting_notification";
    notificationData.notificationData = userData;
    this.AddNewNotificationData(notificationData);
  }
}

public class CraftingNotification extends GenericNotificationController {

  private let m_introAnimation: ref<inkAnimProxy>;

  protected cb func OnInitialize() -> Bool {
    this.m_introAnimation = this.PlayLibraryAnimation(n"crafting_notification");
  }

  protected cb func OnUnitialize() -> Bool {
    this.m_introAnimation.Stop();
  }
}
