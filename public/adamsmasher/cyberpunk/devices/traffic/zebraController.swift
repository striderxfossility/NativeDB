
public class TrafficZebraController extends TrafficLightController {

  protected const func GetPS() -> ref<GameComponentPS> {
    return this.GetBasePS();
  }
}

public class TrafficZebraControllerPS extends TrafficLightControllerPS {

  protected cb func OnInstantiated() -> Bool {
    super.OnInstantiated();
    if !IsStringValid(this.m_deviceName) {
      this.m_deviceName = "Gameplay-Devices-DisplayNames-Zebra";
    };
  }

  protected func Initialize() -> Void {
    this.Initialize();
  }

  protected func GameAttached() -> Void {
    this.GameAttached();
  }
}
