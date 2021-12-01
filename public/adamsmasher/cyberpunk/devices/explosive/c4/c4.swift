
public class C4 extends ExplosiveDevice {

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    super.OnRequestComponents(ri);
    EntityRequestComponentsInterface.RequestComponent(ri, n"mesh", n"MeshComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"scanning", n"gameScanningComponent", false);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    super.OnTakeControl(ri);
    this.m_controller = EntityResolveComponentsInterface.GetComponent(ri, n"controller") as C4Controller;
  }

  protected cb func OnGameAttached() -> Bool {
    super.OnGameAttached();
    this.ToggleVisibility(this.GetDevicePS().IsON());
  }

  protected cb func OnDetach() -> Bool {
    super.OnDetach();
  }

  public const func GetDevicePS() -> ref<ScriptableDeviceComponentPS> {
    return this.GetControllerPersistentState() as ScriptableDeviceComponentPS;
  }

  protected cb func OnActivateC4(evt: ref<ActivateC4>) -> Bool {
    let adHocAnimEvent: ref<AdHocAnimationEvent> = new AdHocAnimationEvent();
    adHocAnimEvent.animationIndex = 2;
    adHocAnimEvent.useBothHands = true;
    adHocAnimEvent.unequipWeapon = true;
    GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerMainGameObject().QueueEvent(adHocAnimEvent);
    this.ToggleVisibility(true);
  }

  protected cb func OnDeactivateC4(evt: ref<DeactivateC4>) -> Bool {
    let adHocAnimEvent: ref<AdHocAnimationEvent> = new AdHocAnimationEvent();
    adHocAnimEvent.animationIndex = 2;
    adHocAnimEvent.useBothHands = true;
    adHocAnimEvent.unequipWeapon = true;
    GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerMainGameObject().QueueEvent(adHocAnimEvent);
    this.ToggleVisibility(false);
  }

  protected cb func OnDetonateC4(evt: ref<DetonateC4>) -> Bool {
    let fakeEntityID: EntityID;
    let deathEvent: ref<gameDeathEvent> = new gameDeathEvent();
    this.QueueEvent(deathEvent);
    this.m_collider.Toggle(false);
    GameInstance.GetBlackboardSystem(this.GetGame()).Get(GetAllBlackboardDefs().UI_Scanner).SetEntityID(GetAllBlackboardDefs().UI_Scanner.ScannedObject, fakeEntityID);
  }

  protected func ToggleVisibility(visible: Bool) -> Void {
    this.ToggleVisibility(visible);
    this.m_scanningComponent.Toggle(visible);
    this.m_collider.Toggle(true);
    if visible {
      this.GetDevicePS().SetDurabilityType(EDeviceDurabilityType.DESTRUCTIBLE);
    } else {
      this.GetDevicePS().SetDurabilityType(EDeviceDurabilityType.INVULNERABLE);
    };
  }
}
