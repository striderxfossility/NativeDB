
public class BaseDestructibleController extends ScriptableDC {

  protected const func GetPS() -> ref<GameComponentPS> {
    return this.GetBasePS();
  }
}

public class BaseDestructibleControllerPS extends ScriptableDeviceComponentPS {

  protected cb func OnInstantiated() -> Bool {
    super.OnInstantiated();
    if !IsStringValid(this.m_deviceName) {
      this.m_deviceName = "LocKey#127";
    };
  }

  protected func Initialize() -> Void {
    this.Initialize();
  }

  protected func GameAttached() -> Void {
    this.GameAttached();
    if this.IsDisabled() {
      this.ForceEnableDevice();
    };
  }

  public final func OnMasterDeviceDestroyed(evt: ref<MasterDeviceDestroyed>) -> EntityNotificationType {
    if !this.IsDisabled() {
      this.ForceDisableDevice();
    };
    this.UseNotifier(evt);
    return EntityNotificationType.SendThisEventToEntity;
  }

  public final func IsMasterDestroyed() -> Bool {
    let i: Int32;
    let master: ref<DestructibleMasterDeviceControllerPS>;
    let masters: array<ref<DeviceComponentPS>>;
    this.GetParents(masters);
    i = 0;
    while i < ArraySize(masters) {
      master = masters[i] as DestructibleMasterDeviceControllerPS;
      if IsDefined(master) {
        return master.IsDestroyed();
      };
      i += 1;
    };
    return false;
  }
}
