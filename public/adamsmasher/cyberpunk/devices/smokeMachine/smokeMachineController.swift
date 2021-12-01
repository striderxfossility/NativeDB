
public class SmokeMachineController extends BasicDistractionDeviceController {

  protected const func GetPS() -> ref<GameComponentPS> {
    return this.GetBasePS();
  }
}

public class SmokeMachineControllerPS extends BasicDistractionDeviceControllerPS {

  protected cb func OnInstantiated() -> Bool {
    super.OnInstantiated();
  }

  protected func Initialize() -> Void {
    this.Initialize();
  }

  protected const func CanCreateAnyQuickHackActions() -> Bool {
    return true;
  }

  protected func GetQuickHackActions(out actions: array<ref<DeviceAction>>, context: GetActionsContext) -> Void {
    let currentAction: ref<ScriptableDeviceAction> = this.ActionOverloadDevice();
    currentAction.SetObjectActionID(t"DeviceAction.OverloadClassHack");
    ArrayPush(actions, currentAction);
    this.GetQuickHackActions(actions, context);
  }

  protected func ActionOverloadDevice() -> ref<OverloadDevice> {
    let action: ref<OverloadDevice> = new OverloadDevice();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    action.CreateInteraction("ObscureVision");
    action.SetDurationValue(5.00);
    return action;
  }

  protected func OnOverloadDevice(evt: ref<OverloadDevice>) -> EntityNotificationType {
    if evt.IsStarted() {
      this.ExecutePSActionWithDelay(evt, this, evt.GetDurationValue());
      this.ForceDisableDevice();
    };
    this.UseNotifier(evt);
    return EntityNotificationType.SendThisEventToEntity;
  }
}
