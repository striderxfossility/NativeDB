
public class AuthorisationNotificationQueue extends gameuiGenericNotificationGameController {

  @default(AuthorisationNotificationQueue, 2.0f)
  private edit let m_duration: Float;

  protected cb func OnAuthorisationNotification(evt: ref<AuthorisationNotificationEvent>) -> Bool {
    let notificationData: gameuiGenericNotificationData;
    let userData: ref<AuthorisationNotificationViewData>;
    switch evt.type {
      case gameuiAuthorisationNotificationType.GotKeycard:
        notificationData.widgetLibraryItemName = n"access_card_obtained";
        break;
      case gameuiAuthorisationNotificationType.AccessGranted:
        notificationData.widgetLibraryItemName = n"access_granted";
        break;
      default:
    };
    userData = new AuthorisationNotificationViewData();
    userData.authType = evt.type;
    notificationData.time = this.m_duration;
    notificationData.notificationData = userData;
    this.AddNewNotificationData(notificationData);
  }
}

public class AuthorisationNotification extends GenericNotificationController {

  public func SetNotificationData(notificationData: ref<GenericNotificationViewData>) -> Void {
    let authData: ref<AuthorisationNotificationViewData> = notificationData as AuthorisationNotificationViewData;
    switch authData.authType {
      case gameuiAuthorisationNotificationType.GotKeycard:
        this.PlayLibraryAnimation(n"anim_card_obtained");
        break;
      case gameuiAuthorisationNotificationType.AccessGranted:
        this.PlayLibraryAnimation(n"anim_access_granted");
        break;
      default:
    };
  }
}
