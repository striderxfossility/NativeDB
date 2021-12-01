
public class Window extends Door {

  protected let m_soloCollider: ref<IComponent>;

  protected let m_strongSoloHandle: ref<MeshComponent>;

  private let m_duplicateDestruction: Bool;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    super.OnRequestComponents(ri);
    EntityRequestComponentsInterface.RequestComponent(ri, n"solo_collider", n"IComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"solo_handle", n"MeshComponent", false);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    super.OnTakeControl(ri);
    this.m_soloCollider = EntityResolveComponentsInterface.GetComponent(ri, n"solo_collider");
    this.m_strongSoloHandle = EntityResolveComponentsInterface.GetComponent(ri, n"solo_handle") as MeshComponent;
    this.m_controller = EntityResolveComponentsInterface.GetComponent(ri, n"controller") as WindowController;
  }

  protected cb func OnActionDemolition(evt: ref<ActionDemolition>) -> Bool {
    if IsDefined(this.m_strongSoloHandle) && IsDefined(this.m_soloCollider) {
      this.m_strongSoloHandle.Toggle(false);
      this.m_soloCollider.Toggle(false);
    } else {
      super.OnActionDemolition(evt);
    };
  }

  protected cb func OnPhysicalDestructionEvent(evt: ref<PhysicalDestructionEvent>) -> Bool {
    if evt.levelOfDestruction == 0u && !this.m_duplicateDestruction {
      this.m_duplicateDestruction = true;
      if this.IsConnectedToSecuritySystem() {
        this.GetDevicePS().TriggerSecuritySystemNotification(this.GetPlayerMainObject(), this.GetWorldPosition(), ESecurityNotificationType.ILLEGAL_ACTION);
      };
    };
  }

  protected func SetSoloAppearance() -> Void {
    if IsDefined(this.m_strongSoloHandle) && IsDefined(this.m_soloCollider) {
      if this.GetDevicePS().IsDemolitionSkillCheckActive() {
        if !this.m_strongSoloHandle.IsEnabled() {
          this.m_strongSoloHandle.Toggle(true);
        };
        if !this.m_soloCollider.IsEnabled() {
          this.m_soloCollider.Toggle(true);
        };
      } else {
        if this.m_strongSoloHandle.IsEnabled() {
          this.m_strongSoloHandle.Toggle(false);
        };
        if this.m_soloCollider.IsEnabled() {
          this.m_soloCollider.Toggle(false);
        };
      };
    };
  }
}
