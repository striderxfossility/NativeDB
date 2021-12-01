
public class HoloTableController extends MediaDeviceController {

  protected const func GetPS() -> ref<GameComponentPS> {
    return this.GetBasePS();
  }
}

public class HoloTableControllerPS extends MediaDeviceControllerPS {

  protected cb func OnInstantiated() -> Bool {
    super.OnInstantiated();
    if !IsStringValid(this.m_deviceName) {
      this.m_deviceName = "LocKey#17851";
    };
  }

  protected func Initialize() -> Void {
    this.Initialize();
  }

  public final func SetMeshesAmount(value: Int32) -> Void {
    this.m_amountOfStations = value;
  }

  public func GetActions(out actions: array<ref<DeviceAction>>, context: GetActionsContext) -> Bool {
    this.GetActions(actions, context);
    if !this.IsUserAuthorized(context.processInitiatorObject.GetEntityID()) {
      return false;
    };
    if ToggleON.IsDefaultConditionMet(this, context) {
      ArrayPush(actions, this.ActionToggleON());
    };
    this.SetActionIllegality(actions, this.m_illegalActions.regularActions);
    return true;
  }

  protected const func CanCreateAnyQuickHackActions() -> Bool {
    return true;
  }

  protected func GetQuickHackActions(out actions: array<ref<DeviceAction>>, context: GetActionsContext) -> Void {
    let currentAction: ref<ScriptableDeviceAction> = this.ActionQuickHackDistraction();
    currentAction.SetObjectActionID(t"DeviceAction.MalfunctionClassHack");
    currentAction.SetDurationValue(this.GetDistractionDuration(currentAction));
    currentAction.SetInactiveWithReason(ScriptableDeviceAction.IsDefaultConditionMet(this, context), "LocKey#7003");
    ArrayPush(actions, currentAction);
    this.FinalizeGetQuickHackActions(actions, context);
  }

  public func OnNextStation(evt: ref<NextStation>) -> EntityNotificationType {
    this.OnNextStation(evt);
    return EntityNotificationType.SendThisEventToEntity;
  }

  public func OnPreviousStation(evt: ref<PreviousStation>) -> EntityNotificationType {
    this.OnPreviousStation(evt);
    return EntityNotificationType.SendThisEventToEntity;
  }
}
