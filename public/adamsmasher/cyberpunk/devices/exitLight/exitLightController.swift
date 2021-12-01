
public class ExitLightController extends ScriptableDC {

  protected const func GetPS() -> ref<GameComponentPS> {
    return this.GetBasePS();
  }
}

public class ExitLightControllerPS extends ScriptableDeviceComponentPS {

  protected cb func OnInstantiated() -> Bool {
    super.OnInstantiated();
    if !IsStringValid(this.m_deviceName) {
      this.m_deviceName = "Light";
    };
  }

  protected func Initialize() -> Void {
    this.Initialize();
  }
}
