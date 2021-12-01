
public native class gameuiGenericNotificationGameController extends inkGameController {

  public final native func AddNewNotificationData(notification: gameuiGenericNotificationData) -> Void;

  public final native func RemoveNotification(notification: ref<IScriptable>) -> Void;

  public final native func SetNotificationPause(value: Bool) -> Void;

  public final native func SetNotificationPauseWhenHidden(value: Bool) -> Void;

  public func GetShouldSaveState() -> Bool {
    return false;
  }

  public func GetID() -> Int32 {
    return EnumInt(GenericNotificationType.Generic);
  }
}
