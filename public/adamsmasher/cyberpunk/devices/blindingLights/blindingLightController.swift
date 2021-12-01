
public class BlindingLightController extends BasicDistractionDeviceController {

  protected const func GetPS() -> ref<GameComponentPS> {
    return this.GetBasePS();
  }
}

public class BlindingLightControllerPS extends BasicDistractionDeviceControllerPS {

  protected let reflectorSFX: ReflectorSFX;

  protected cb func OnInstantiated() -> Bool {
    super.OnInstantiated();
    if !IsStringValid(this.m_deviceName) {
      this.m_deviceName = "Gameplay-Devices-DisplayNames-MetroLights";
    };
  }

  protected func Initialize() -> Void {
    this.Initialize();
  }

  protected const func CanCreateAnyQuickHackActions() -> Bool {
    return true;
  }

  protected func GetQuickHackActions(out actions: array<ref<DeviceAction>>, context: GetActionsContext) -> Void {
    let currentAction: ref<ScriptableDeviceAction>;
    this.GetQuickHackActions(actions, context);
    currentAction = this.ActionOverloadDevice();
    currentAction.SetObjectActionID(t"DeviceAction.OverloadClassHack");
    currentAction.SetInactiveWithReason(this.IsPowered(), "LocKey#7013");
    currentAction.SetInactiveWithReason(!this.IsDistracting(), "LocKey#7004");
    ArrayPush(actions, currentAction);
    this.FinalizeGetQuickHackActions(actions, context);
  }

  public final func GetDistractionSound() -> CName {
    return this.reflectorSFX.m_distraction;
  }

  public final func GetTurnOnSound() -> CName {
    return this.reflectorSFX.m_turnOn;
  }

  public final func GetTurnOffSound() -> CName {
    return this.reflectorSFX.m_turnOff;
  }

  protected func ActionOverloadDevice() -> ref<OverloadDevice> {
    let action: ref<OverloadDevice> = this.ActionOverloadDevice();
    action.SetDurationValue(9.40);
    return action;
  }

  protected func OnOverloadDevice(evt: ref<OverloadDevice>) -> EntityNotificationType {
    if evt.IsStarted() {
      this.ExecutePSActionWithDelay(evt, this, evt.GetDurationValue());
      this.m_distractExecuted = true;
    } else {
      this.ForceDisableDevice();
      this.m_distractExecuted = false;
    };
    this.UseNotifier(evt);
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected func GetBackgroundTextureTweakDBID() -> TweakDBID {
    return t"DeviceIcons.LightDeviceBackground";
  }

  protected func GetDeviceIconTweakDBID() -> TweakDBID {
    return t"DeviceIcons.LightDeviceIcon";
  }
}
