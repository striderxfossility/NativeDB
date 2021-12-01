
public class DisassemblableEntitySimple extends InteractiveDevice {

  private let m_mesh: ref<MeshComponent>;

  private let m_collider: ref<IComponent>;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    EntityRequestComponentsInterface.RequestComponent(ri, n"mesh", n"MeshComponent", true);
    EntityRequestComponentsInterface.RequestComponent(ri, n"collider", n"IComponent", true);
    EntityRequestComponentsInterface.RequestComponent(ri, n"disassemblableComponent", n"DisassemblableComponent", true);
    super.OnRequestComponents(ri);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    this.m_mesh = EntityResolveComponentsInterface.GetComponent(ri, n"mesh") as MeshComponent;
    this.m_collider = EntityResolveComponentsInterface.GetComponent(ri, n"collider");
    this.m_disassemblableComponent = EntityResolveComponentsInterface.GetComponent(ri, n"disassemblableComponent") as DisassemblableComponent;
    super.OnTakeControl(ri);
    this.m_controller = EntityResolveComponentsInterface.GetComponent(ri, n"controller") as GenericDeviceController;
  }

  public const func GetDevicePS() -> ref<ScriptableDeviceComponentPS> {
    return this.GetControllerPersistentState() as ScriptableDeviceComponentPS;
  }

  private const func GetController() -> ref<ScriptableDC> {
    return this.m_controller;
  }

  protected cb func OnDisassembleDevice(evt: ref<DisassembleDevice>) -> Bool {
    let player: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerControlledGameObject() as PlayerPuppet;
    this.EnterWorkspot(player, true, n"disassembleWorkspot");
  }

  protected cb func OnWorkspotFinished(componentName: CName) -> Bool {
    super.OnWorkspotFinished(componentName);
    if Equals(componentName, n"disassembleWorkspot") {
      this.m_collider.Toggle(false);
      this.m_mesh.Toggle(false);
      this.m_disassemblableComponent.ObtainParts();
    };
  }
}
