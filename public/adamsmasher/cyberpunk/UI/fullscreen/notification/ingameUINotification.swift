
public class UIInGameNotificationViewData extends GenericNotificationViewData {

  public func CanMerge(data: ref<GenericNotificationViewData>) -> Bool {
    return true;
  }

  public func OnRemoveNotification(data: ref<IScriptable>) -> Bool {
    return true;
  }
}

public class UIInGameNotificationQueue extends gameuiGenericNotificationGameController {

  @default(UIInGameNotificationQueue, 5.0f)
  private edit let m_duration: Float;

  public func GetShouldSaveState() -> Bool {
    return false;
  }

  protected cb func OnUINotification(evt: ref<UIInGameNotificationEvent>) -> Bool {
    let notificationData: gameuiGenericNotificationData;
    let userData: ref<UIInGameNotificationViewData> = new UIInGameNotificationViewData();
    switch evt.m_notificationType {
      case UIInGameNotificationType.CombatRestriction:
        userData.title = "UI-Notifications-CombatRestriction";
        break;
      case UIInGameNotificationType.ActionRestriction:
        userData.title = "UI-Notifications-ActionBlocked";
        break;
      case UIInGameNotificationType.CantSaveActionRestriction:
        userData.title = "UI-Notifications-CantSave-Generic";
        break;
      case UIInGameNotificationType.CantSaveCombatRestriction:
        userData.title = "UI-Notifications-CantSave-Combat";
        break;
      case UIInGameNotificationType.CantSaveQuestRestriction:
        userData.title = "UI-Notifications-CantSave-Generic";
        break;
      case UIInGameNotificationType.CantSaveDeathRestriction:
        userData.title = "UI-Notifications-CantSave-Dead";
        break;
      case UIInGameNotificationType.NotEnoughSlotsSaveResctriction:
        userData.title = "UI-Notifications-SaveNotEnoughSlots";
        break;
      case UIInGameNotificationType.NotEnoughSpaceSaveResctriction:
        userData.title = "UI-Notifications-SaveNotEnoughSpace";
        break;
      case UIInGameNotificationType.PhotoModeDisabledRestriction:
        userData.title = "UI-PhotoMode-NotSupported";
    };
    userData.soundEvent = n"QuestSuccessPopup";
    userData.soundAction = n"OnOpen";
    notificationData.time = this.m_duration;
    notificationData.widgetLibraryItemName = n"popups_side";
    notificationData.notificationData = userData;
    this.AddNewNotificationData(notificationData);
  }

  protected cb func OnUINotificationRemove(evt: ref<UIInGameNotificationRemoveEvent>) -> Bool {
    this.RemoveNotification(evt);
  }
}

public class UIInGameNotification extends GenericNotificationController {

  public func SetNotificationData(notificationData: ref<GenericNotificationViewData>) -> Void {
    this.SetNotificationData(notificationData);
    this.PlayLibraryAnimationOnAutoSelectedTargets(n"notification_intro", this.GetRootWidget());
  }
}

public class UIInGameNotificationEvent extends Event {

  public let m_notificationType: UIInGameNotificationType;

  public let m_additionalInfo: Variant;

  public final static func CreateSavingLockedEvent(const locks: script_ref<array<gameSaveLock>>) -> ref<UIInGameNotificationEvent> {
    let notificationEvent: ref<UIInGameNotificationEvent> = new UIInGameNotificationEvent();
    notificationEvent.m_notificationType = UIInGameNotificationType.CantSaveActionRestriction;
    let i: Int32 = 0;
    while i < ArraySize(Deref(locks)) {
      switch Deref(locks)[i].reason {
        case gameSaveLockReason.Combat:
          if EnumInt(notificationEvent.m_notificationType) < EnumInt(UIInGameNotificationType.CantSaveCombatRestriction) {
            notificationEvent.m_notificationType = UIInGameNotificationType.CantSaveCombatRestriction;
          };
          break;
        case gameSaveLockReason.Tier:
        case gameSaveLockReason.LoadingScreen:
        case gameSaveLockReason.MainMenu:
        case gameSaveLockReason.Boundary:
        case gameSaveLockReason.Quest:
        case gameSaveLockReason.Scene:
          if EnumInt(notificationEvent.m_notificationType) < EnumInt(UIInGameNotificationType.CantSaveQuestRestriction) {
            notificationEvent.m_notificationType = UIInGameNotificationType.CantSaveQuestRestriction;
          };
          break;
        case gameSaveLockReason.PlayerState:
          if EnumInt(notificationEvent.m_notificationType) < EnumInt(UIInGameNotificationType.CantSaveDeathRestriction) {
            notificationEvent.m_notificationType = UIInGameNotificationType.CantSaveDeathRestriction;
          };
          break;
        case gameSaveLockReason.NotEnoughSlots:
          if EnumInt(notificationEvent.m_notificationType) < EnumInt(UIInGameNotificationType.NotEnoughSlotsSaveResctriction) {
            notificationEvent.m_notificationType = UIInGameNotificationType.NotEnoughSlotsSaveResctriction;
          };
          break;
        case gameSaveLockReason.NotEnoughSpace:
          if EnumInt(notificationEvent.m_notificationType) < EnumInt(UIInGameNotificationType.NotEnoughSpaceSaveResctriction) {
            notificationEvent.m_notificationType = UIInGameNotificationType.NotEnoughSpaceSaveResctriction;
          };
      };
      i += 1;
    };
    return notificationEvent;
  }
}
