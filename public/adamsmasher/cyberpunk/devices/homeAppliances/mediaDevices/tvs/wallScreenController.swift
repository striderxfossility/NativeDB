
public class ToggleShow extends ActionBool {

  public final func SetProperties(isShown: Bool) -> Void {
    this.actionName = n"ToggleShow";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"Show", isShown, n"LocKey#17833", n"LocKey#17834");
  }
}

public class WallScreenController extends TVController {

  protected const func GetPS() -> ref<GameComponentPS> {
    return this.GetBasePS();
  }
}

public class WallScreenControllerPS extends TVControllerPS {

  private persistent let m_isShown: Bool;

  protected cb func OnInstantiated() -> Bool {
    super.OnInstantiated();
    if !IsStringValid(this.m_deviceName) {
      this.m_deviceName = "Gameplay-Devices-DisplayNames-WallScreen";
    };
  }

  protected func Initialize() -> Void {
    this.Initialize();
  }

  private final func ActionToggleShow() -> ref<ToggleShow> {
    let action: ref<ToggleShow> = new ToggleShow();
    action.clearanceLevel = DefaultActionsParametersHolder.GetInteractiveClearance();
    action.SetUp(this);
    action.SetProperties(this.m_isShown);
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  public func GetActions(out actions: array<ref<DeviceAction>>, context: GetActionsContext) -> Bool {
    this.GetActions(actions, context);
    if !this.IsUserAuthorized(context.processInitiatorObject.GetEntityID()) {
      return false;
    };
    if Clearance.IsInRange(context.clearance, DefaultActionsParametersHolder.GetInteractiveClearance()) {
      ArrayPush(actions, this.ActionToggleShow());
    };
    this.SetActionIllegality(actions, this.m_illegalActions.regularActions);
    return true;
  }

  public final func OnToggleShow(evt: ref<ToggleShow>) -> EntityNotificationType {
    this.UseNotifier(evt);
    if this.IsUnpowered() || this.IsDisabled() {
      return EntityNotificationType.DoNotNotifyEntity;
    };
    this.m_isShown = !this.m_isShown;
    return EntityNotificationType.SendThisEventToEntity;
  }

  public final const func IsShown() -> Bool {
    return this.m_isShown;
  }

  public func GetDeviceIconPath() -> String {
    return "";
  }
}
