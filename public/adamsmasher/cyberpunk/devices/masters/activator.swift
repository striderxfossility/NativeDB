
public class Activator extends InteractiveMasterDevice {

  private let m_animFeature: ref<AnimFeature_SimpleDevice>;

  private let hitCount: Int32;

  private let m_meshComponent: ref<MeshComponent>;

  @default(Activator, default)
  public let meshAppearence: CName;

  @default(Activator, Yellow)
  public let meshAppearenceBreaking: CName;

  @default(Activator, red)
  public let meshAppearenceBroken: CName;

  @default(Activator, 2.98f)
  public let defaultDelay: Float;

  @default(Activator, 1.68f)
  public let yellowDelay: Float;

  @default(Activator, 4.03f)
  public let redDelay: Float;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    EntityRequestComponentsInterface.RequestComponent(ri, n"mesh", n"MeshComponent", true);
    super.OnRequestComponents(ri);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    this.m_meshComponent = EntityResolveComponentsInterface.GetComponent(ri, n"mesh") as MeshComponent;
    super.OnTakeControl(ri);
    this.m_controller = EntityResolveComponentsInterface.GetComponent(ri, n"controller") as ActivatorController;
  }

  private const func GetController() -> ref<ScriptableDC> {
    return this.m_controller;
  }

  public const func GetDevicePS() -> ref<ScriptableDeviceComponentPS> {
    return this.GetControllerPersistentState() as ScriptableDeviceComponentPS;
  }

  protected func EnterWorkspot(activator: ref<GameObject>, opt freeCamera: Bool, opt componentName: CName, opt deviceData: CName) -> Void {
    let workspotSystem: ref<WorkspotGameSystem> = GameInstance.GetWorkspotSystem(activator.GetGame());
    workspotSystem.PlayInDeviceSimple(this, activator, freeCamera, componentName, n"deviceWorkspot");
  }

  protected cb func OnDisassembleDevice(evt: ref<DisassembleDevice>) -> Bool {
    let playerStateMachineBlackboard: ref<IBlackboard>;
    let playerPuppet: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerMainGameObject() as PlayerPuppet;
    this.EnterWorkspot(playerPuppet, false, n"disassembleWorkspot");
    playerStateMachineBlackboard = GameInstance.GetBlackboardSystem(this.GetGame()).GetLocalInstanced(playerPuppet.GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
    playerStateMachineBlackboard.SetBool(GetAllBlackboardDefs().PlayerStateMachine.IsInteractingWithDevice, true);
    this.UpdateDeviceState();
    this.DelayApperanceSwitchEvent(this.meshAppearenceBreaking, this.yellowDelay);
    this.DelayApperanceSwitchEvent(this.meshAppearence, this.defaultDelay);
    this.DelayApperanceSwitchEvent(this.meshAppearenceBroken, this.redDelay);
  }

  protected cb func OnSpiderbotActivateActivator(evt: ref<SpiderbotActivateActivator>) -> Bool {
    let locationOverrideGlobalRef: GlobalNodeRef;
    let locationOverrideID: EntityID;
    let locationOverrideObject: wref<GameObject>;
    let locationOverrideRef: NodeRef;
    let spiderbotOrderDeviceEvent: ref<SpiderbotOrderDeviceEvent>;
    this.SendSetIsSpiderbotInteractionOrderedEvent(true);
    spiderbotOrderDeviceEvent = new SpiderbotOrderDeviceEvent();
    spiderbotOrderDeviceEvent.target = this;
    locationOverrideRef = (this.GetDevicePS() as ActivatorControllerPS).GetSpiderbotInteractionLocationOverride();
    locationOverrideGlobalRef = ResolveNodeRefWithEntityID(locationOverrideRef, this.GetEntityID());
    if GlobalNodeRef.IsDefined(ResolveNodeRef(locationOverrideRef, Cast(GlobalNodeID.GetRoot()))) {
      locationOverrideID = Cast(locationOverrideGlobalRef);
      locationOverrideObject = GameInstance.FindEntityByID(this.GetGame(), locationOverrideID) as GameObject;
      spiderbotOrderDeviceEvent.overrideMovementTarget = locationOverrideObject;
    };
    evt.GetExecutor().QueueEvent(spiderbotOrderDeviceEvent);
  }

  protected cb func OnSpiderbotOrderCompletedEvent(evt: ref<SpiderbotOrderCompletedEvent>) -> Bool {
    this.SendSetIsSpiderbotInteractionOrderedEvent(false);
    GameInstance.GetActivityLogSystem(this.GetGame()).AddLog("SPIDERBOT HAS FINISHED ACTIVATING THE DEVICE ... ");
    (this.GetDevicePS() as ActivatorControllerPS).ActivateConnectedDevices();
    this.SetGameplayRoleToNone();
  }

  protected cb func OnToggleActivation(evt: ref<ToggleActivation>) -> Bool {
    this.UpdateDeviceState();
    this.SetGameplayRoleToNone();
  }

  protected cb func OnDelayApperanceSwitchEvent(evt: ref<panelApperanceSwitchEvent>) -> Bool {
    GameObject.SetMeshAppearanceEvent(this, evt.newApperance);
  }

  protected cb func OnWorkspotFinished(componentName: CName) -> Bool {
    super.OnWorkspotFinished(componentName);
    if Equals(componentName, n"disassembleWorkspot") {
      this.m_disassemblableComponent.ObtainParts();
      (this.GetDevicePS() as ActivatorControllerPS).ActivateConnectedDevices();
      this.SetGameplayRoleToNone();
      this.UpdateAnimState();
    };
  }

  private final func UpdateAnimState() -> Void {
    if !IsDefined(this.m_animFeature) {
      this.m_animFeature = new AnimFeature_SimpleDevice();
    };
    this.m_animFeature.isOpen = true;
    this.m_interaction.Toggle(false);
    AnimationControllerComponent.ApplyFeature(this, n"DeviceMaintenancePanel", this.m_animFeature);
  }

  private final func DelayApperanceSwitchEvent(newApperance: CName, time: Float) -> Void {
    let evt: ref<panelApperanceSwitchEvent> = new panelApperanceSwitchEvent();
    evt.newApperance = newApperance;
    GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, evt, time);
  }

  protected cb func OnHit(evt: ref<gameHitEvent>) -> Bool {
    if Equals(this.GetDevicePS().GetDurabilityType(), EDeviceDurabilityType.DESTRUCTIBLE) {
      this.hitCount = this.hitCount + 1;
      if this.hitCount > 1 {
        (this.GetDevicePS() as ActivatorControllerPS).ActivateConnectedDevices();
        this.SetGameplayRoleToNone();
        this.m_meshComponent.Toggle(false);
      };
    };
  }

  public const func DeterminGameplayRole() -> EGameplayRole {
    return EGameplayRole.ControlOtherDevice;
  }

  public const func GetCurrentGameplayRole() -> EGameplayRole {
    let gameplayRole: EGameplayRole;
    if NotEquals(gameplayRole, IntEnum(1l)) {
      return gameplayRole;
    };
    return this.m_gameplayRoleComponent.GetCurrentGameplayRole();
  }
}
