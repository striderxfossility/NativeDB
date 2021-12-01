
public class ActivatedDeviceNPC extends ActivatedDeviceTransfromAnim {

  public let m_hasProperAnimations: Bool;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    super.OnRequestComponents(ri);
    EntityRequestComponentsInterface.RequestComponent(ri, n"ui", n"worlduiWidgetComponent", false);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    this.m_uiComponent = EntityResolveComponentsInterface.GetComponent(ri, n"ui") as worlduiWidgetComponent;
    super.OnTakeControl(ri);
    this.m_controller = EntityResolveComponentsInterface.GetComponent(ri, n"controller") as ActivatedDeviceNPCController;
  }

  protected const func GetController() -> ref<ScriptableDC> {
    return this.m_controller;
  }

  public const func GetDevicePS() -> ref<ScriptableDeviceComponentPS> {
    return this.GetControllerPersistentState() as ScriptableDeviceComponentPS;
  }

  protected cb func OnActivateDevice(evt: ref<ActivateDevice>) -> Bool {
    super.OnActivateDevice(evt);
    this.EnterWorkspot((this.GetDevicePS() as ActivatedDeviceNPCControllerPS).GetSpawnedNPC(), false, n"activated");
  }

  protected cb func OnSpiderbotOrderCompletedEvent(evt: ref<SpiderbotOrderCompletedEvent>) -> Bool {
    super.OnSpiderbotOrderCompletedEvent(evt);
    this.EnterWorkspot((this.GetDevicePS() as ActivatedDeviceNPCControllerPS).GetSpawnedNPC(), false, n"activated");
    if this.m_uiComponent != null {
      this.m_uiComponent.Toggle(false);
    };
  }

  protected cb func OnGameEntitySpawnerEvent(evt: ref<gameEntitySpawnerEvent>) -> Bool {
    this.EnterWorkspot((this.GetDevicePS() as ActivatedDeviceNPCControllerPS).GetSpawnedNPC(), false, n"idle");
  }

  protected func EnterWorkspot(activator: ref<GameObject>, opt freeCamera: Bool, opt componentName: CName, opt deviceData: CName, opt typeOfEvent: CName) -> Void {
    let workspotSystem: ref<WorkspotGameSystem> = GameInstance.GetWorkspotSystem(activator.GetGame());
    if Equals(typeOfEvent, n"idle") {
      workspotSystem.PlayInDevice(this, activator, n"lockedCamera", n"npcIdleWorkspot", n"deviceIdleWorkspot", 0.01);
    } else {
      if Equals(typeOfEvent, n"activated") {
        workspotSystem.PlayInDevice(this, activator, n"lockedCamera", n"npcActivatedWorkspot", n"deviceActivatedWorkspot", 0.01);
        if !this.m_hasProperAnimations {
          (this.GetDevicePS() as ActivatedDeviceNPCControllerPS).GetSpawnedNPC().HideIrreversibly();
        };
      };
    };
  }

  protected cb func OnWorkspotFinished(componentName: CName) -> Bool {
    super.OnWorkspotFinished(componentName);
  }

  public const func DeterminGameplayRole() -> EGameplayRole {
    return EGameplayRole.Distract;
  }
}
