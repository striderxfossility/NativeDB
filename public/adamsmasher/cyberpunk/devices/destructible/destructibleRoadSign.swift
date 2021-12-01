
public class DestructibleRoadSign extends BaseDestructibleDevice {

  protected let m_frameMesh: ref<MeshComponent>;

  protected let m_uiMesh: ref<MeshComponent>;

  protected let m_uiMesh_2: ref<MeshComponent>;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    super.OnRequestComponents(ri);
    EntityRequestComponentsInterface.RequestComponent(ri, n"mesh_frame", n"MeshComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"mesh_ui", n"MeshComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"mesh_ui_2", n"MeshComponent", false);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    super.OnTakeControl(ri);
    this.m_frameMesh = EntityResolveComponentsInterface.GetComponent(ri, n"mesh_frame") as MeshComponent;
    this.m_uiMesh = EntityResolveComponentsInterface.GetComponent(ri, n"mesh_ui") as MeshComponent;
    this.m_uiMesh_2 = EntityResolveComponentsInterface.GetComponent(ri, n"mesh_ui_2") as MeshComponent;
    this.m_controller = EntityResolveComponentsInterface.GetComponent(ri, n"controller") as BaseDestructibleController;
  }

  protected func CreateDestructionEffects() -> Void {
    this.CreateDestructionEffects();
    if IsDefined(this.m_frameMesh) {
      this.m_frameMesh.Toggle(false);
    };
    if IsDefined(this.m_uiMesh) {
      this.m_uiMesh.Toggle(false);
    };
    if IsDefined(this.m_uiMesh_2) {
      this.m_uiMesh_2.Toggle(false);
    };
  }

  protected cb func OnPhysicalDestructionEvent(evt: ref<PhysicalDestructionEvent>) -> Bool {
    super.OnPhysicalDestructionEvent(evt);
  }

  protected func DeactivateDevice() -> Void {
    this.DeactivateDevice();
  }

  protected func DeactivateDeviceSilent() -> Void {
    this.DeactivateDeviceSilent();
    if IsDefined(this.m_frameMesh) {
      this.m_frameMesh.Toggle(false);
    };
    if IsDefined(this.m_uiMesh) {
      this.m_uiMesh.Toggle(false);
    };
    if IsDefined(this.m_uiMesh_2) {
      this.m_uiMesh_2.Toggle(false);
    };
  }

  protected func ActivateDevice() -> Void {
    this.m_destroyedMesh.Toggle(false);
    this.m_frameMesh.Toggle(true);
    this.m_uiMesh.Toggle(true);
    if IsDefined(this.m_uiMesh_2) {
      this.m_uiMesh_2.Toggle(true);
    };
  }
}
