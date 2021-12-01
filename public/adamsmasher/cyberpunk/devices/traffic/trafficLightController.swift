
public class ToggleLight extends ActionBool {

  public final func SetProperties(status: worldTrafficLightColor) -> Void {
    let isGreen: Bool;
    this.actionName = n"ToggleLight";
    if Equals(status, worldTrafficLightColor.GREEN) {
      isGreen = true;
    };
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(this.actionName, isGreen, n"LocKey#17842", n"LocKey#17843");
  }
}

public class TrafficLightGreen extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"TrafficLightGreen";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(this.actionName, true, n"LocKey#17842", n"LocKey#17842");
  }
}

public class TrafficLightRed extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"TrafficLightRed";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(this.actionName, true, n"LocKey#17843", n"LocKey#17843");
  }
}

public class TrafficLightController extends ScriptableDC {

  protected const func GetPS() -> ref<GameComponentPS> {
    return this.GetBasePS();
  }
}

public class TrafficLightControllerPS extends ScriptableDeviceComponentPS {

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

  public final func OnMasterDeviceDestroyed(evt: ref<MasterDeviceDestroyed>) -> EntityNotificationType {
    if !this.IsDisabled() {
      this.ForceDisableDevice();
    };
    this.UseNotifier(evt);
    return EntityNotificationType.SendThisEventToEntity;
  }
}
