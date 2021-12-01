
public class GlitchedTurret extends Device {

  public let animFeature: ref<AnimFeature_SensorDevice>;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    super.OnRequestComponents(ri);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    super.OnTakeControl(ri);
    this.m_controller = EntityResolveComponentsInterface.GetComponent(ri, n"controller") as GlitchedTurretController;
  }

  private const func GetController() -> ref<ScriptableDC> {
    return this.m_controller;
  }

  public const func GetDevicePS() -> ref<ScriptableDeviceComponentPS> {
    return this.GetControllerPersistentState() as ScriptableDeviceComponentPS;
  }

  protected cb func OnGameAttached() -> Bool {
    this.animFeature = new AnimFeature_SensorDevice();
    super.OnGameAttached();
  }

  protected func TurnOnDevice() -> Void {
    this.animFeature.isTurnedOn = true;
    this.ApplyAnimFeatureToReplicate(this, n"SensorDeviceData", this.animFeature);
    this.TurnOnDevice();
  }

  protected cb func OnQuestForceGlitch(evt: ref<QuestForceGlitch>) -> Bool {
    this.animFeature.isControlled = true;
    this.ApplyAnimFeatureToReplicate(this, n"SensorDeviceData", this.animFeature);
    this.RestorePower();
  }

  public const func DeterminGameplayRole() -> EGameplayRole {
    return EGameplayRole.Shoot;
  }

  protected const func HasAnyDirectInteractionActive() -> Bool {
    return true;
  }
}
