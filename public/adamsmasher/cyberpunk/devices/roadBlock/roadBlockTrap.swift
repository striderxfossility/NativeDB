
public class RoadBlockTrap extends InteractiveMasterDevice {

  protected let m_areaComponent: ref<TriggerComponent>;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    super.OnRequestComponents(ri);
    EntityRequestComponentsInterface.RequestComponent(ri, n"trapArea", n"TriggerComponent", false);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    super.OnTakeControl(ri);
    this.m_areaComponent = EntityResolveComponentsInterface.GetComponent(ri, n"trapArea") as TriggerComponent;
    this.m_controller = EntityResolveComponentsInterface.GetComponent(ri, n"controller") as RoadBlockTrapController;
  }

  protected cb func OnActivateDevice(evt: ref<ActivateDevice>) -> Bool {
    if this.IsPlayerInside() {
      (this.GetDevicePS() as RoadBlockTrapControllerPS).RefreshSlaves_Event();
    };
  }

  protected cb func OnAreaEnter(evt: ref<AreaEnteredEvent>) -> Bool {
    let activator: wref<GameObject>;
    super.OnAreaEnter(evt);
    if NotEquals(evt.componentName, n"trapArea") {
      return false;
    };
    if !this.GetDevicePS().IsActivated() || this.GetDevicePS().IsDisabled() {
      return false;
    };
    activator = EntityGameInterface.GetEntity(evt.activator) as GameObject;
    if activator.IsPlayer() {
      this.TrapPlayer(activator as PlayerPuppet);
      (this.GetDevicePS() as RoadBlockTrapControllerPS).RefreshSlaves_Event();
      this.GetDevicePS().ForceDisableDevice();
    };
  }

  protected cb func OnAreaExit(evt: ref<AreaExitedEvent>) -> Bool {
    super.OnAreaExit(evt);
  }

  private final func IsPlayerInside() -> Bool {
    let i: Int32;
    let puppets: array<ref<Entity>> = this.m_areaComponent.GetOverlappingEntities();
    if ArraySize(puppets) > 0 {
      i = 0;
      while i < ArraySize(puppets) {
        if IsDefined(puppets[i] as PlayerPuppet) {
          return true;
        };
        i += 1;
      };
    };
    return false;
  }

  private const func GetController() -> ref<ScriptableDC> {
    return this.m_controller;
  }

  public const func GetDevicePS() -> ref<ScriptableDeviceComponentPS> {
    return this.GetControllerPersistentState() as ScriptableDeviceComponentPS;
  }

  private final func TrapPlayer(player: wref<PlayerPuppet>) -> Void {
    let ev: ref<PSMImpulse> = new PSMImpulse();
    ev.id = n"impulse";
    let playerVelocity: Vector4 = player.GetVelocity();
    playerVelocity.Z = 0.00;
    ev.impulse = -1.00 * playerVelocity;
    player.QueueEvent(ev);
    GameInstance.GetTeleportationFacility(this.GetGame()).Teleport(player, this.GetWorldPosition(), Vector4.ToRotation(player.GetWorldForward()));
  }
}
