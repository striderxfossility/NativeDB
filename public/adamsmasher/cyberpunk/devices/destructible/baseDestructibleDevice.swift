
public class BaseDestructibleDevice extends Device {

  @default(BaseDestructibleDevice, 5.0f)
  protected edit let m_minTime: Float;

  @default(BaseDestructibleDevice, 10.0f)
  protected edit let m_maxTime: Float;

  protected let m_destroyedMesh: ref<PhysicalMeshComponent>;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    super.OnRequestComponents(ri);
    EntityRequestComponentsInterface.RequestComponent(ri, n"mesh_destroyed", n"PhysicalMeshComponent", false);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    super.OnTakeControl(ri);
    this.m_destroyedMesh = EntityResolveComponentsInterface.GetComponent(ri, n"mesh_destroyed") as PhysicalMeshComponent;
    this.m_controller = EntityResolveComponentsInterface.GetComponent(ri, n"controller") as BaseDestructibleController;
  }

  protected func ResolveGameplayState() -> Void {
    this.ResolveGameplayState();
    if (this.GetDevicePS() as BaseDestructibleControllerPS).IsMasterDestroyed() {
      this.DeactivateDeviceSilent();
    } else {
      this.ActivateDevice();
    };
  }

  protected cb func OnMasterDeviceDestroyed(evt: ref<MasterDeviceDestroyed>) -> Bool {
    this.CreateDestructionEffects();
  }

  protected cb func OnPhysicalDestructionEvent(evt: ref<PhysicalDestructionEvent>) -> Bool {
    this.GetDevicePS().ForceDisableDevice();
    this.CreateDestructionEffects();
  }

  protected func CreateDestructionEffects() -> Void {
    let delayEvent: ref<DelayEvent> = new DelayEvent();
    this.CreatePhysicalBody();
    GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, delayEvent, RandRangeF(this.m_minTime, this.m_maxTime));
  }

  protected func CreatePhysicalBody() -> Void {
    let meshInterface: ref<PhysicalBodyInterface>;
    if !this.m_destroyedMesh.IsEnabled() {
      this.m_destroyedMesh.Toggle(true);
    };
    meshInterface = this.m_destroyedMesh.CreatePhysicalBodyInterface();
    meshInterface.ToggleKinematic(true);
    meshInterface.AddLinearImpulse(new Vector4(0.00, 0.50, 0.00, 0.00), true);
  }

  protected cb func OnDelayEvent(evt: ref<DelayEvent>) -> Bool {
    this.HidePhysicalBody();
  }

  protected func HidePhysicalBody() -> Void {
    this.m_destroyedMesh.Toggle(false);
  }

  protected func DeactivateDevice() -> Void {
    this.GetDevicePS().GetDeviceOperationsContainer().Execute(n"death_VFX", this);
  }

  protected func DeactivateDeviceSilent() -> Void {
    if this.m_destroyedMesh.IsEnabled() {
      this.m_destroyedMesh.Toggle(false);
    };
  }

  protected func ActivateDevice() -> Void {
    this.m_destroyedMesh.Toggle(true);
  }

  private const func GetController() -> ref<ScriptableDC> {
    return this.m_controller;
  }

  public const func GetDevicePS() -> ref<ScriptableDeviceComponentPS> {
    return this.GetControllerPersistentState() as ScriptableDeviceComponentPS;
  }
}
