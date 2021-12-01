
public class WindowController extends DoorController {

  protected const func GetPS() -> ref<GameComponentPS> {
    return this.GetBasePS();
  }
}

public class WindowControllerPS extends DoorControllerPS {

  private inline let m_windowSkillChecks: ref<EngDemoContainer>;

  protected cb func OnInstantiated() -> Bool {
    super.OnInstantiated();
    if !IsStringValid(this.m_deviceName) {
      this.m_deviceName = "LocKey#78";
    };
    this.m_doorProperties.m_automaticallyClosesItself = false;
  }

  protected func Initialize() -> Void {
    this.Initialize();
  }

  protected func GameAttached() -> Void;

  protected func LogicReady() -> Void {
    this.LogicReady();
    this.InitializeSkillChecks(this.m_windowSkillChecks);
  }

  public func GetDeviceIconPath() -> String {
    return "base/gameplay/gui/brushes/devices/icon_door.widgetbrush";
  }

  protected func OnActionDemolition(evt: ref<ActionDemolition>) -> EntityNotificationType {
    if !evt.WasPassed() {
      return EntityNotificationType.DoNotNotifyEntity;
    };
    this.OnActionDemolition(evt);
    if evt.IsCompleted() {
      this.OnForceOpen(this.ActionForceOpen());
      this.DisableDevice();
    };
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected func GetDeviceIconTweakDBID() -> TweakDBID {
    return t"DeviceIcons.DoorDeviceIcon";
  }

  protected func GetBackgroundTextureTweakDBID() -> TweakDBID {
    return t"DeviceIcons.DoorDeviceBackground";
  }
}
