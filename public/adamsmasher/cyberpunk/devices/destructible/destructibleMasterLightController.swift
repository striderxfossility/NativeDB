
public class DestructibleMasterLightController extends DestructibleMasterDeviceController {

  protected const func GetPS() -> ref<GameComponentPS> {
    return this.GetBasePS();
  }
}

public class DestructibleMasterLightControllerPS extends DestructibleMasterDeviceControllerPS {

  protected cb func OnInstantiated() -> Bool {
    super.OnInstantiated();
    if !IsStringValid(this.m_deviceName) {
      this.m_deviceName = "LocKey#42165";
    };
  }

  protected func GameAttached() -> Void {
    if this.IsDisabled() {
      this.ForceEnableDevice();
    };
    this.InitializeCLS();
  }

  public func GetActions(out actions: array<ref<DeviceAction>>, context: GetActionsContext) -> Bool {
    this.GetActions(actions, context);
    if ToggleON.IsDefaultConditionMet(this, context) {
      ArrayPush(actions, this.ActionToggleON());
    };
    this.SetActionIllegality(actions, this.m_illegalActions.regularActions);
    return true;
  }

  private final func InitializeCLS() -> Void {
    let evt: ref<InitializeCLSEvent>;
    let fuse: ref<FuseControllerPS>;
    let i: Int32;
    let masters: array<ref<DeviceComponentPS>>;
    this.GetParents(masters);
    i = 0;
    while i < ArraySize(masters) {
      fuse = masters[i] as FuseControllerPS;
      if IsDefined(fuse) && fuse.IsConnectedToCLS() && fuse.IsCLSInitialized() {
        this.UpdateStateOnCLS(fuse.GetDeviceState());
      } else {
        if IsDefined(fuse) && !fuse.IsCLSInitialized() {
          evt = new InitializeCLSEvent();
          this.GetPersistencySystem().QueuePSEvent(fuse.GetID(), fuse.GetClassName(), evt);
        };
      };
      i += 1;
    };
  }

  private final func UpdateStateOnCLS(state: EDeviceStatus) -> Void {
    if Equals(state, EDeviceStatus.ON) {
      if this.IsUnpowered() {
        this.ExecutePSAction(this.ActionSetDevicePowered(), this);
      };
      this.ExecutePSAction(this.ActionSetDeviceON(), this);
    } else {
      if Equals(state, EDeviceStatus.OFF) {
        this.ExecutePSAction(this.ActionSetDeviceOFF(), this);
      } else {
        if Equals(state, EDeviceStatus.UNPOWERED) {
          this.ExecutePSAction(this.ActionSetDeviceUnpowered(), this);
        };
      };
    };
  }
}
