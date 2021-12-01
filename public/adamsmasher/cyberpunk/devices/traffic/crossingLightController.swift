
public class CrossingLightController extends TrafficLightController {

  protected const func GetPS() -> ref<GameComponentPS> {
    return this.GetBasePS();
  }
}

public class CrossingLightControllerPS extends TrafficLightControllerPS {

  protected let m_crossingLightSFXSetup: CrossingLightSetup;

  protected cb func OnInstantiated() -> Bool {
    super.OnInstantiated();
  }

  protected func Initialize() -> Void {
    this.Initialize();
  }

  protected func GameAttached() -> Void {
    this.GameAttached();
  }

  public final func GetGreenSFX() -> CName {
    return this.m_crossingLightSFXSetup.m_greenLightSFX;
  }

  public final func GetRedSFX() -> CName {
    return this.m_crossingLightSFXSetup.m_redLightSFX;
  }
}
