
public class PersonnelSystemController extends DeviceSystemBaseController {

  protected const func GetPS() -> ref<GameComponentPS> {
    return this.GetBasePS();
  }
}

public class PersonnelSystemControllerPS extends DeviceSystemBaseControllerPS {

  protected cb func OnInstantiated() -> Bool {
    super.OnInstantiated();
    if !IsStringValid(this.m_deviceName) {
      this.m_deviceName = "Personnel System";
    };
  }

  protected func Initialize() -> Void {
    this.Initialize();
  }
}
