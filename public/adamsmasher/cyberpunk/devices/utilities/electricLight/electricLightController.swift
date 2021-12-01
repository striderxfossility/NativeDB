
public class ElectricLightController extends ScriptableDC {

  protected const func GetPS() -> ref<GameComponentPS> {
    return this.GetBasePS();
  }
}

public class ElectricLightControllerPS extends ScriptableDeviceComponentPS {

  private persistent let m_isConnectedToCLS: Bool;

  private let m_wasCLSInitTriggered: Bool;

  protected cb func OnInstantiated() -> Bool {
    super.OnInstantiated();
    if !IsStringValid(this.m_deviceName) {
      this.m_deviceName = "LocKey#42165";
    };
  }

  protected func GameAttached() -> Void;

  protected func LogicReady() -> Void {
    this.LogicReady();
    this.m_isAttachedToGame = true;
  }

  public func GetActions(out actions: array<ref<DeviceAction>>, context: GetActionsContext) -> Bool {
    this.GetActions(actions, context);
    if ToggleON.IsDefaultConditionMet(this, context) {
      ArrayPush(actions, this.ActionToggleON());
    };
    this.SetActionIllegality(actions, this.m_illegalActions.regularActions);
    return true;
  }

  public func EvaluateDeviceState() -> Void {
    let fuse: ref<FuseControllerPS>;
    if this.IsDisabled() {
      return;
    };
    if this.m_isConnectedToCLS {
      fuse = this.GetCLSFuse();
      if IsDefined(fuse) {
        this.SetDeviceState(fuse.GetDeviceState());
      };
    } else {
      if this.m_wasCLSInitTriggered || !this.InitializeCLS(true) {
        this.EvaluateDeviceState();
      };
    };
  }

  public const func IsConnectedToCLS() -> Bool {
    if this.m_isConnectedToCLS {
      return true;
    };
    return this.IsConnectedToCLS();
  }

  private final func InitializeCLS(opt setStateInstant: Bool) -> Bool {
    let evt: ref<InitializeCLSEvent>;
    let fuse: ref<FuseControllerPS> = this.GetCLSFuse();
    if IsDefined(fuse) {
      if fuse.IsUnpowered() {
        if setStateInstant {
          this.SetDeviceState(EDeviceStatus.UNPOWERED);
        } else {
          this.UpdateStateOnCLS(EDeviceStatus.UNPOWERED);
        };
      } else {
        if fuse.IsCLSInitialized() {
          if setStateInstant {
            this.SetDeviceState(fuse.GetDeviceState());
          } else {
            this.UpdateStateOnCLS(fuse.GetDeviceState());
          };
        } else {
          evt = new InitializeCLSEvent();
          this.GetPersistencySystem().QueuePSEvent(fuse.GetID(), fuse.GetClassName(), evt);
          if setStateInstant {
            this.SetDeviceState(fuse.GetDeviceStateByCLS());
          };
        };
      };
      this.m_isConnectedToCLS = true;
    };
    this.m_wasCLSInitTriggered = true;
    return this.m_isConnectedToCLS;
  }

  private final func GetCLSFuse() -> ref<FuseControllerPS> {
    let fuse: ref<FuseControllerPS>;
    let i: Int32;
    let masters: array<ref<DeviceComponentPS>>;
    this.GetParents(masters);
    i = 0;
    while i < ArraySize(masters) {
      fuse = masters[i] as FuseControllerPS;
      if IsDefined(fuse) {
        if fuse.IsConnectedToCLS() {
          return fuse;
        };
      };
      i += 1;
    };
    return null;
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
