
public class GetAccess extends ActionBool {

  public final func SetProperties(hasAccess: Bool) -> Void {
    this.actionName = n"GetAccess";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"GetAccess", hasAccess, n"LocKey#17838", n"LocKey#17839");
  }
}

public abstract class DeviceSystemBaseController extends MasterController {

  protected const func GetPS() -> ref<GameComponentPS> {
    return this.GetBasePS();
  }
}

public abstract class DeviceSystemBaseControllerPS extends MasterControllerPS {

  protected persistent let m_quickHacksEnabled: Bool;

  protected func ActionGetAccess() -> ref<GetAccess> {
    let action: ref<GetAccess> = new GetAccess();
    action.SetUp(this);
    action.SetProperties(this.m_quickHacksEnabled);
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  public func GetActions(out outActions: array<ref<DeviceAction>>, context: GetActionsContext) -> Bool {
    if !this.GetActions(outActions, context) {
      return false;
    };
    if ScriptableDeviceAction.IsDefaultConditionMet(this, context) {
      ArrayPush(outActions, this.ActionGetAccess());
    };
    this.SetActionIllegality(outActions, this.m_illegalActions.regularActions);
    return true;
  }

  public final func OnGetAccess(evt: ref<GetAccess>) -> EntityNotificationType {
    let mySlaves: array<ref<DeviceComponentPS>> = this.GetImmediateSlaves();
    this.m_quickHacksEnabled = !this.m_quickHacksEnabled;
    let i: Int32 = 0;
    while i < ArraySize(mySlaves) {
      mySlaves[i].ExposeQuickHacks(true);
      this.RevokeQuickHacks(mySlaves[i]);
      i += 1;
    };
    this.UseNotifier(evt);
    return EntityNotificationType.DoNotNotifyEntity;
  }

  private final func RevokeQuickHacks(device: ref<DeviceComponentPS>) -> Void {
    let revokeEvent: ref<RevokeQuickHackAccess> = new RevokeQuickHackAccess();
    GameInstance.GetDelaySystem(this.GetGameInstance()).DelayPSEvent(device.GetID(), device.GetClassName(), revokeEvent, 60.00);
  }
}
