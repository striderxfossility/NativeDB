
public class VirtualMasterDevicePS extends ScriptableDeviceComponentPS {

  public let m_owner: ref<IScriptable>;

  public let m_globalActions: array<ref<DeviceAction>>;

  protected persistent let m_context: GetActionsContext;

  public let m_connectedDevices: array<ref<DeviceComponentPS>>;

  public func InitializeVirtualDevice() -> Void {
    this.SetDeviceState(EDeviceStatus.ON);
    this.Initialize();
  }

  protected func DoCustomShit(devices: array<ref<DeviceComponentPS>>, on: Bool) -> Void;

  protected func GetGlobalActions(out actions: array<ref<DeviceAction>>) -> Void;
}
