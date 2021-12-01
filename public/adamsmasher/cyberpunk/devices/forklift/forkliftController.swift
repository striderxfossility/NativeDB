
public class ForkliftController extends ScriptableDC {

  protected const func GetPS() -> ref<GameComponentPS> {
    return this.GetBasePS();
  }
}

public class ForkliftControllerPS extends ScriptableDeviceComponentPS {

  private persistent let m_forkliftSetup: ForkliftSetup;

  @default(ForkliftControllerPS, false)
  private persistent let m_isUp: Bool;

  public final func GetActionName() -> CName {
    return this.m_forkliftSetup.m_actionActivateName;
  }

  public final func GetLiftingAnimationTime() -> Float {
    return this.m_forkliftSetup.m_liftingAnimationTime;
  }

  public final func IsForkliftUp() -> Bool {
    return this.m_isUp;
  }

  public final func ToggleForkliftPosition() -> Void {
    this.m_isUp = !this.m_isUp;
  }

  public final func ChangeState(newState: EDeviceStatus) -> Void {
    this.SetDeviceState(newState);
  }

  protected func GameAttached() -> Void {
    this.GameAttached();
  }

  public func GetActions(out actions: array<ref<DeviceAction>>, context: GetActionsContext) -> Bool {
    this.GetActions(actions, context);
    if !this.IsDistracting() && this.IsON() {
      ArrayPush(actions, this.ActionActivateDevice("Activate"));
    };
    this.SetActionIllegality(actions, this.m_illegalActions.regularActions);
    return true;
  }

  protected const func CanCreateAnyQuickHackActions() -> Bool {
    if this.m_forkliftSetup.m_hasDistractionQuickhack {
      return true;
    };
    return false;
  }

  protected func GetQuickHackActions(out actions: array<ref<DeviceAction>>, context: GetActionsContext) -> Void {
    let currentAction: ref<ScriptableDeviceAction>;
    if !this.IsDistracting() && this.m_forkliftSetup.m_hasDistractionQuickhack {
      currentAction = this.ActionQuickHackDistraction();
      currentAction.SetObjectActionID(t"DeviceAction.MalfunctionClassHack");
      currentAction.SetDurationValue(this.GetDistractionDuration(currentAction));
      currentAction.SetInactiveWithReason(this.IsON(), "LocKey#7005");
      ArrayPush(actions, currentAction);
    };
    this.GetQuickHackActions(actions, context);
  }

  protected final func ActionActivateDevice(interactionName: String) -> ref<ActivateDevice> {
    let action: ref<ActivateDevice> = new ActivateDevice();
    action.clearanceLevel = DefaultActionsParametersHolder.GetInteractiveClearance();
    action.SetUp(this);
    action.SetProperties(this.GetActionName());
    action.AddDeviceName(this.m_deviceName);
    action.CreateActionWidgetPackage();
    action.CreateInteraction(interactionName);
    return action;
  }

  protected func OnActivateDevice(evt: ref<ActivateDevice>) -> EntityNotificationType {
    this.OnActivateDevice(evt);
    this.SetDeviceState(EDeviceStatus.OFF);
    this.ToggleForkliftPosition();
    return EntityNotificationType.SendThisEventToEntity;
  }
}
