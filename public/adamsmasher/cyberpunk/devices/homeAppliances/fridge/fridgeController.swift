
public class ToggleOpenFridge extends ActionBool {

  public final func SetProperties(isOpen: Bool) -> Void {
    this.actionName = n"ToggleOpenFridge";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"Open", isOpen, n"LocKey#273", n"LocKey#274");
  }
}

public class FridgeController extends ScriptableDC {

  protected const func GetPS() -> ref<GameComponentPS> {
    return this.GetBasePS();
  }
}

public class FridgeControllerPS extends ScriptableDeviceComponentPS {

  private persistent let m_isOpen: Bool;

  protected cb func OnInstantiated() -> Bool {
    super.OnInstantiated();
    if !IsStringValid(this.m_deviceName) {
      this.m_deviceName = "LocKey#79";
    };
  }

  protected func Initialize() -> Void {
    this.Initialize();
  }

  protected func ActionToggleOpenFridge() -> ref<ToggleOpenFridge> {
    let action: ref<ToggleOpenFridge> = new ToggleOpenFridge();
    action.clearanceLevel = DefaultActionsParametersHolder.GetToggleOpenClearance();
    action.SetUp(this);
    action.SetProperties(this.m_isOpen);
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  public func GetActions(out actions: array<ref<DeviceAction>>, context: GetActionsContext) -> Bool {
    this.GetActions(actions, context);
    if !this.IsUserAuthorized(context.processInitiatorObject.GetEntityID()) {
      return false;
    };
    if Equals(this.m_deviceState, EDeviceStatus.DISABLED) {
      return false;
    };
    if Clearance.IsInRange(context.clearance, DefaultActionsParametersHolder.GetToggleOpenClearance()) {
      ArrayPush(actions, this.ActionToggleOpenFridge());
    };
    this.SetActionIllegality(actions, this.m_illegalActions.regularActions);
    return true;
  }

  public final func OnOpen(evt: ref<ToggleOpenFridge>) -> EntityNotificationType {
    this.m_isOpen = !this.m_isOpen;
    evt.prop.first = ToVariant(this.m_isOpen);
    this.UseNotifier(evt);
    return EntityNotificationType.SendThisEventToEntity;
  }

  public const func GetClearance() -> ref<Clearance> {
    return Clearance.CreateClearance(2, 2);
  }

  public final func IsOpen() -> Bool {
    return this.m_isOpen;
  }
}
