
public class MovableWallScreenController extends DoorController {

  protected const func GetPS() -> ref<GameComponentPS> {
    return this.GetBasePS();
  }
}

public class MovableWallScreenControllerPS extends DoorControllerPS {

  protected cb func OnInstantiated() -> Bool {
    super.OnInstantiated();
    if !IsStringValid(this.m_deviceName) {
      this.m_deviceName = "MovableWallScreen";
    };
  }

  protected func Initialize() -> Void {
    this.Initialize();
  }

  public func GetDeviceIconPath() -> String {
    return "base/gameplay/gui/brushes/devices/icon_tv.widgetbrush";
  }
}
