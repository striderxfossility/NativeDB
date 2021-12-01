
public class OdaCementBagController extends ScriptableDC {

  protected const func GetPS() -> ref<GameComponentPS> {
    return this.GetBasePS();
  }
}

public class OdaCementBagControllerPS extends ScriptableDeviceComponentPS {

  protected let m_cementEffectCooldown: Float;

  protected cb func OnInstantiated() -> Bool {
    super.OnInstantiated();
  }

  protected func Initialize() -> Void {
    this.Initialize();
  }

  public final func GetCementCooldown() -> Float {
    return this.m_cementEffectCooldown;
  }
}
