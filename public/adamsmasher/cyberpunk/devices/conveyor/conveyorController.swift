
public class ConveyorController extends ScriptableDC {

  protected const func GetPS() -> ref<GameComponentPS> {
    return this.GetBasePS();
  }

  private final func OnGameAttach() -> Void {
    this.RestoreDeviceState();
  }

  private final func RestoreDeviceState() -> Void {
    if (this.GetPS() as ConveyorControllerPS).IsON() {
      this.StartConveyor();
    } else {
      this.StopConveyor();
    };
  }

  protected cb func OnSetDeviceON(evt: ref<SetDeviceON>) -> Bool {
    this.StartConveyor();
  }

  protected cb func OnSetDeviceOFF(evt: ref<SetDeviceOFF>) -> Bool {
    this.StopConveyor();
  }

  protected cb func OnToggleON(evt: ref<ToggleON>) -> Bool {
    let value: Bool = FromVariant(evt.prop.first);
    if !value {
      this.StartConveyor();
    } else {
      this.StopConveyor();
    };
  }

  private final func StartConveyor() -> Void {
    let evt: ref<gameConveyorControlEvent> = new gameConveyorControlEvent();
    evt.enable = true;
    this.GetEntity().QueueEvent(evt);
  }

  private final func StopConveyor() -> Void {
    let evt: ref<gameConveyorControlEvent> = new gameConveyorControlEvent();
    evt.enable = false;
    this.GetEntity().QueueEvent(evt);
  }
}

public class ConveyorControllerPS extends ScriptableDeviceComponentPS {

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

  protected func OnSetDeviceON(evt: ref<SetDeviceON>) -> EntityNotificationType {
    let cachedStatus: ref<BaseDeviceStatus> = this.GetDeviceStatusAction();
    if this.IsUnpowered() || this.IsDisabled() {
      return this.SendActionFailedEvent(evt, evt.GetRequesterID(), "Unpowered or Disabled");
    };
    this.SetDeviceState(EDeviceStatus.ON);
    if !IsFinal() {
      this.LogActionDetails(evt, cachedStatus);
    };
    this.UseNotifier(evt);
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected func OnSetDeviceOFF(evt: ref<SetDeviceOFF>) -> EntityNotificationType {
    let cachedStatus: ref<BaseDeviceStatus> = this.GetDeviceStatusAction();
    if this.IsUnpowered() || this.IsDisabled() {
      return this.SendActionFailedEvent(evt, evt.GetRequesterID(), "Unpowered or Disabled");
    };
    this.SetDeviceState(EDeviceStatus.OFF);
    if !IsFinal() {
      this.LogActionDetails(evt, cachedStatus);
    };
    this.UseNotifier(evt);
    return EntityNotificationType.SendThisEventToEntity;
  }

  public func OnToggleON(evt: ref<ToggleON>) -> EntityNotificationType {
    let cachedStatus: ref<BaseDeviceStatus>;
    let value: Bool;
    let notifier: ref<ActionNotifier> = new ActionNotifier();
    notifier.SetNone();
    cachedStatus = this.GetDeviceStatusAction();
    value = FromVariant(evt.prop.first);
    if !value {
      this.SetDeviceState(EDeviceStatus.ON);
    } else {
      this.SetDeviceState(EDeviceStatus.OFF);
    };
    if !IsFinal() {
      this.LogActionDetails(evt, cachedStatus);
    };
    this.Notify(notifier, evt);
    return EntityNotificationType.SendThisEventToEntity;
  }
}
