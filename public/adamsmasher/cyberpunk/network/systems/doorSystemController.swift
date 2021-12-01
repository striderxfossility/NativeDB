
public class DoorSystemController extends BaseNetworkSystemController {

  protected const func GetPS() -> ref<GameComponentPS> {
    return this.GetBasePS();
  }
}

public class DoorSystemControllerPS extends BaseNetworkSystemControllerPS {

  protected cb func OnInstantiated() -> Bool {
    super.OnInstantiated();
    if !IsStringValid(this.m_deviceName) {
      this.m_deviceName = "Door System";
    };
  }

  protected func Initialize() -> Void {
    this.Initialize();
  }
}
