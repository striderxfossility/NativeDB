
public class UIMenuNotificationViewData extends GenericNotificationViewData {

  public let m_canBeMerged: Bool;

  public func CanMerge(data: ref<GenericNotificationViewData>) -> Bool {
    return this.m_canBeMerged;
  }
}

public class UIMenuNotificationQueue extends gameuiGenericNotificationGameController {

  @default(UIMenuNotificationQueue, 5.0f)
  private edit let m_duration: Float;

  public func GetShouldSaveState() -> Bool {
    return false;
  }

  public func GetID() -> Int32 {
    return EnumInt(GenericNotificationType.VendorNotification);
  }

  protected cb func OnUINotification(evt: ref<UIMenuNotificationEvent>) -> Bool {
    let notificationData: gameuiGenericNotificationData;
    let requirement: SItemStackRequirementData;
    let userData: ref<UIMenuNotificationViewData> = new UIMenuNotificationViewData();
    switch evt.m_notificationType {
      case UIMenuNotificationType.VendorNotEnoughMoney:
        userData.title = "LocKey#54028";
        break;
      case UIMenuNotificationType.VNotEnoughMoney:
        userData.title = "LocKey#54029";
        break;
      case UIMenuNotificationType.VendorRequirementsNotMet:
        requirement = FromVariant(evt.m_additionalInfo).m_data;
        userData.title = GetLocalizedText("UI-Notifications-RequirementNotMet") + " " + IntToString(RoundF(requirement.requiredValue)) + " " + GetLocalizedText(UILocalizationHelper.GetStatNameLockey(RPGManager.GetStatRecord(requirement.statType)));
        break;
      case UIMenuNotificationType.InventoryActionBlocked:
        userData.title = "UI-Notifications-ActionBlocked";
        break;
      case UIMenuNotificationType.CraftingNoPerks:
        break;
      case UIMenuNotificationType.CraftingNotEnoughMaterial:
        userData.title = "UI-Notifications-CraftingNotEnoughMaterials";
        break;
      case UIMenuNotificationType.UpgradingLevelToLow:
        userData.title = "LocKey#52451";
        break;
      case UIMenuNotificationType.NoPerksPoints:
        userData.title = "UI-Notifications-NoPerksPoint";
        break;
      case UIMenuNotificationType.PerksLocked:
        userData.title = "UI-Notifications-PerksLocked";
        break;
      case UIMenuNotificationType.MaxLevelPerks:
        userData.title = "UI-Notifications-MaxPerks";
        break;
      case UIMenuNotificationType.NoAttributePoints:
        userData.title = "UI-Notifications-NoAttributesPoint";
        break;
      case UIMenuNotificationType.InCombat:
        userData.title = "LocKey#50792";
        break;
      case UIMenuNotificationType.CraftingQuickhack:
        userData.title = "LocKey#78498";
    };
    userData.soundEvent = n"QuestSuccessPopup";
    userData.soundAction = n"OnOpen";
    userData.m_canBeMerged = true;
    notificationData.time = this.m_duration;
    notificationData.widgetLibraryItemName = n"popups_side";
    notificationData.notificationData = userData;
    this.AddNewNotificationData(notificationData);
  }
}

public class UINotification extends GenericNotificationController {

  public func SetNotificationData(notificationData: ref<GenericNotificationViewData>) -> Void {
    this.SetNotificationData(notificationData);
    this.PlayLibraryAnimationOnAutoSelectedTargets(n"notification_intro", this.GetRootWidget());
  }
}
