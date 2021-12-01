
public class WeakFence extends InteractiveDevice {

  protected let m_impulseForce: Float;

  protected let m_impulseVector: Vector4;

  protected edit const let m_sideTriggerNames: array<CName>;

  protected let m_triggerComponents: array<ref<TriggerComponent>>;

  protected let m_currentWorkspotSuffix: CName;

  protected let m_offMeshConnectionComponent: ref<OffMeshConnectionComponent>;

  protected let m_physicalMesh: ref<IPlacedComponent>;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    let i: Int32;
    super.OnRequestComponents(ri);
    EntityRequestComponentsInterface.RequestComponent(ri, n"offMeshConnection", n"OffMeshConnectionComponent", true);
    EntityRequestComponentsInterface.RequestComponent(ri, n"fence_door", n"IPlacedComponent", true);
    i = 0;
    while i < ArraySize(this.m_sideTriggerNames) {
      EntityRequestComponentsInterface.RequestComponent(ri, this.m_sideTriggerNames[i], n"TriggerComponent", true);
      i += 1;
    };
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    let i: Int32;
    super.OnTakeControl(ri);
    this.m_offMeshConnectionComponent = EntityResolveComponentsInterface.GetComponent(ri, n"offMeshConnection") as OffMeshConnectionComponent;
    this.m_physicalMesh = EntityResolveComponentsInterface.GetComponent(ri, n"fence_door") as IPlacedComponent;
    this.m_controller = EntityResolveComponentsInterface.GetComponent(ri, n"controller") as WeakFenceController;
    i = 0;
    while i < ArraySize(this.m_sideTriggerNames) {
      ArrayPush(this.m_triggerComponents, EntityResolveComponentsInterface.GetComponent(ri, this.m_sideTriggerNames[i]) as TriggerComponent);
      i += 1;
    };
  }

  protected func ResolveGameplayState() -> Void {
    this.ResolveGameplayState();
    if this.GetDevicePS().IsDisabled() {
      this.m_physicalMesh.Toggle(false);
      this.EnableOffMeshConnections();
    } else {
      this.DisableOffMeshConnections();
    };
  }

  protected const func GetController() -> ref<ScriptableDC> {
    return this.m_controller;
  }

  public const func GetDevicePS() -> ref<ScriptableDeviceComponentPS> {
    return this.GetControllerPersistentState() as ScriptableDeviceComponentPS;
  }

  protected cb func OnActivateDevice(evt: ref<ActivateDevice>) -> Bool {
    this.PlayWorkspotAnimations();
    this.EnableOffMeshConnections();
  }

  protected cb func OnActionEngineering(evt: ref<ActionEngineering>) -> Bool {
    this.PlayWorkspotAnimations();
    this.EnableOffMeshConnections();
  }

  protected final func PlayWorkspotAnimations() -> Void {
    let workspotSystem: ref<WorkspotGameSystem>;
    let playerStateMachineBlackboard: ref<IBlackboard> = GameInstance.GetBlackboardSystem(this.GetGame()).GetLocalInstanced(GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerControlledGameObject().GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
    playerStateMachineBlackboard.SetBool(GetAllBlackboardDefs().PlayerStateMachine.IsInteractingWithDevice, true);
    this.CheckCurrentSide();
    workspotSystem = GameInstance.GetWorkspotSystem(this.GetGame());
    workspotSystem.PlayInDevice(this, GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerMainGameObject(), n"lockedCamera", n"playerWorkspot" + this.m_currentWorkspotSuffix, n"deviceWorkspot" + this.m_currentWorkspotSuffix, n"fence_sync");
  }

  protected cb func OnWorkspotFinished(componentName: CName) -> Bool {
    super.OnWorkspotFinished(componentName);
    this.UpdateAnimState();
  }

  protected final func CheckCurrentSide() -> Void {
    let finalName: String;
    let j: Int32;
    let overlappingEntities: array<ref<Entity>>;
    let i: Int32 = 0;
    while i < ArraySize(this.m_triggerComponents) {
      overlappingEntities = this.m_triggerComponents[i].GetOverlappingEntities();
      j = 0;
      while j < ArraySize(overlappingEntities) {
        if (overlappingEntities[j] as GameObject).IsPlayer() {
          finalName = "Side" + ToString(i + 1);
          this.m_currentWorkspotSuffix = StringToName(finalName);
        };
        j += 1;
      };
      i += 1;
    };
  }

  private final func UpdateAnimState() -> Void {
    let animFeature: ref<AnimFeature_SimpleDevice> = new AnimFeature_SimpleDevice();
    animFeature.isOpen = true;
    if Equals(this.m_currentWorkspotSuffix, n"Side1") {
      animFeature.isOpenLeft = true;
    } else {
      animFeature.isOpenRight = true;
    };
    AnimationControllerComponent.ApplyFeature(this, n"weakFence", animFeature);
  }

  public const func DeterminGameplayRole() -> EGameplayRole {
    return EGameplayRole.OpenPath;
  }

  protected final func EnableOffMeshConnections() -> Void {
    if this.m_offMeshConnectionComponent != null {
      this.m_offMeshConnectionComponent.EnableOffMeshConnection();
      this.m_offMeshConnectionComponent.EnableForPlayer();
    };
  }

  protected final func DisableOffMeshConnections() -> Void {
    if this.m_offMeshConnectionComponent != null {
      this.m_offMeshConnectionComponent.DisableOffMeshConnection();
      this.m_offMeshConnectionComponent.DisableForPlayer();
    };
  }
}
