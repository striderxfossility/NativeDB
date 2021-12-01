
public class MaintenancePanelController extends MasterController {

  protected const func GetPS() -> ref<GameComponentPS> {
    return this.GetBasePS();
  }
}

public class MaintenancePanelControllerPS extends MasterControllerPS {

  private inline let m_maintenancePanelSkillChecks: ref<EngineeringContainer>;

  protected cb func OnInstantiated() -> Bool {
    super.OnInstantiated();
    if !IsStringValid(this.m_deviceName) {
      this.m_deviceName = "Gameplay-Devices-DisplayNames-MaintenancePanel";
    };
    this.m_disassembleProperties.m_canBeDisassembled = true;
  }

  protected func Initialize() -> Void {
    this.Initialize();
  }

  protected func GameAttached() -> Void;

  protected func LogicReady() -> Void {
    this.LogicReady();
    this.InitializeSkillChecks(this.m_maintenancePanelSkillChecks);
  }

  public final func RmoveAuthorizationFromSlaves() -> Void {
    let putAuthorizationIntoOff: ref<SetAuthorizationModuleOFF>;
    let devices: array<ref<DeviceComponentPS>> = this.GetImmediateSlaves();
    let i: Int32 = 0;
    while i < ArraySize(devices) {
      this.ExtractActionFromSlave(devices[i], n"SetAuthorizationModuleOFF", putAuthorizationIntoOff);
      if IsDefined(putAuthorizationIntoOff) {
        this.GetPersistencySystem().QueuePSDeviceEvent(putAuthorizationIntoOff);
      };
      i += 1;
    };
  }

  public final func RefreshLockOnSlaves() -> Void {
    let locked: ref<ToggleLock>;
    let open: ref<ForceOpen>;
    let devices: array<ref<DeviceComponentPS>> = this.GetImmediateSlaves();
    let i: Int32 = 0;
    while i < ArraySize(devices) {
      this.ExtractActionFromSlave(devices[i], n"ToggleLock", locked);
      if IsDefined(locked) {
        this.GetPersistencySystem().QueuePSDeviceEvent(locked);
      };
      this.ExtractActionFromSlave(devices[i], n"ForceOpen", open);
      if IsDefined(open) {
        this.GetPersistencySystem().QueuePSDeviceEvent(open);
      };
      i += 1;
    };
  }

  protected func ActionEngineering(context: GetActionsContext) -> ref<ActionEngineering> {
    let additionalActions: array<ref<DeviceAction>>;
    let action: ref<ActionEngineering> = this.ActionEngineering(context);
    ArrayPush(additionalActions, this.ActionDisassembleDevice());
    action.CreateInteraction(context.processInitiatorObject, additionalActions);
    return action;
  }

  public func OnDisassembleDevice(evt: ref<DisassembleDevice>) -> EntityNotificationType {
    this.TurnAuthorizationModuleOFF();
    this.RmoveAuthorizationFromSlaves();
    return this.OnDisassembleDevice(evt);
  }
}
