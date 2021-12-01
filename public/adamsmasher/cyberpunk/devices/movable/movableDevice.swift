
public class MovableDevice extends InteractiveDevice {

  public let m_workspotSideName: CName;

  protected edit const let m_sideTriggerNames: array<CName>;

  protected let m_triggerComponents: array<ref<TriggerComponent>>;

  protected edit const let m_offMeshConnectionsToOpenNames: array<CName>;

  protected let m_offMeshConnectionsToOpen: array<ref<OffMeshConnectionComponent>>;

  protected let m_additionalMeshComponent: ref<MeshComponent>;

  @attrib(tooltip, "If set to true, the position of the WorkspotResourceComponent containing the player workspot will be used for the player during sync animations.")
  protected edit let m_UseWorkspotComponentPosition: Bool;

  protected let m_shouldMoveRight: Bool;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    let i: Int32;
    super.OnRequestComponents(ri);
    EntityRequestComponentsInterface.RequestComponent(ri, n"additionalMesh", n"MeshComponent", false);
    i = 0;
    while i < ArraySize(this.m_sideTriggerNames) {
      EntityRequestComponentsInterface.RequestComponent(ri, this.m_sideTriggerNames[i], n"TriggerComponent", true);
      i += 1;
    };
    i = 0;
    while i < ArraySize(this.m_offMeshConnectionsToOpenNames) {
      EntityRequestComponentsInterface.RequestComponent(ri, this.m_offMeshConnectionsToOpenNames[i], n"OffMeshConnectionComponent", true);
      i += 1;
    };
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    let i: Int32;
    super.OnTakeControl(ri);
    this.m_additionalMeshComponent = EntityResolveComponentsInterface.GetComponent(ri, n"additionalMesh") as MeshComponent;
    i = 0;
    while i < ArraySize(this.m_sideTriggerNames) {
      ArrayPush(this.m_triggerComponents, EntityResolveComponentsInterface.GetComponent(ri, this.m_sideTriggerNames[i]) as TriggerComponent);
      i += 1;
    };
    i = 0;
    while i < ArraySize(this.m_offMeshConnectionsToOpenNames) {
      ArrayPush(this.m_offMeshConnectionsToOpen, EntityResolveComponentsInterface.GetComponent(ri, this.m_offMeshConnectionsToOpenNames[i]) as OffMeshConnectionComponent);
      i += 1;
    };
    this.m_controller = EntityResolveComponentsInterface.GetComponent(ri, n"controller") as MovableDeviceController;
  }

  protected func ResolveGameplayState() -> Void {
    this.ResolveGameplayState();
    this.UpdateOffMeshLinks();
  }

  protected cb func OnGameAttached() -> Bool {
    super.OnGameAttached();
    this.UpdateAnimState();
  }

  protected func EnterWorkspot(activator: ref<GameObject>, opt freeCamera: Bool, opt componentName: CName, opt syncSlotName: CName) -> Void {
    let sideSuffix: CName;
    let workspotSlidingBehaviour: WorkspotSlidingBehaviour;
    let workspotSystem: ref<WorkspotGameSystem> = GameInstance.GetWorkspotSystem(activator.GetGame());
    if this.m_shouldMoveRight {
      sideSuffix = this.m_workspotSideName + n"Right";
    } else {
      sideSuffix = this.m_workspotSideName + n"Left";
    };
    if this.m_UseWorkspotComponentPosition {
      workspotSlidingBehaviour = WorkspotSlidingBehaviour.PlayAtResourcePosition;
    } else {
      workspotSlidingBehaviour = WorkspotSlidingBehaviour.DontPlayAtResourcePosition;
    };
    workspotSystem.PlayInDevice(this, activator, n"lockedCamera", componentName + sideSuffix, n"deviceWorkspot" + sideSuffix, n"movableSync", 0.50, workspotSlidingBehaviour);
  }

  protected cb func OnActionDemolition(evt: ref<ActionDemolition>) -> Bool {
    if !evt.IsCompleted() {
      return false;
    };
    this.HandleMoveDevice();
  }

  protected cb func OnActionMoveObstacle(evt: ref<MoveObstacle>) -> Bool {
    this.HandleMoveDevice();
  }

  protected final func HandleMoveDevice() -> Void {
    let playerStateMachineBlackboard: ref<IBlackboard>;
    let player: ref<GameObject> = GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerControlledGameObject();
    this.PlayTransformAnim();
    this.CheckCurrentSide();
    this.EnterWorkspot(player, false, n"playerWorkspot");
    playerStateMachineBlackboard = GameInstance.GetBlackboardSystem(this.GetGame()).GetLocalInstanced(player.GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
    playerStateMachineBlackboard.SetBool(GetAllBlackboardDefs().PlayerStateMachine.IsInteractingWithDevice, true);
    this.UpdateAnimState();
    this.UpdateOffMeshLinks();
  }

  protected final func PlayTransformAnim() -> Void {
    let playEvent: ref<gameTransformAnimationPlayEvent> = new gameTransformAnimationPlayEvent();
    playEvent.animationName = n"start";
    playEvent.looping = false;
    playEvent.timesPlayed = 1u;
    playEvent.timeScale = 1.00;
    this.QueueEvent(playEvent);
  }

  private final func UpdateAnimState() -> Void {
    let animFeature: ref<AnimFeature_SimpleDevice> = new AnimFeature_SimpleDevice();
    if (this.GetDevicePS() as MovableDeviceControllerPS).WasDeviceMoved() {
      animFeature.isOpen = true;
      if this.m_shouldMoveRight {
        animFeature.isOpenRight = true;
      } else {
        animFeature.isOpenLeft = true;
      };
      AnimationControllerComponent.ApplyFeature(this, n"MovableDevice", animFeature);
      this.SetGameplayRoleToNone();
    };
  }

  public const func DeterminGameplayRole() -> EGameplayRole {
    return EGameplayRole.Push;
  }

  protected final func UpdateOffMeshLinks() -> Void {
    let i: Int32;
    if (this.GetDevicePS() as MovableDeviceControllerPS).WasDeviceMoved() {
      i = 0;
      while i < ArraySize(this.m_offMeshConnectionsToOpen) {
        this.m_offMeshConnectionsToOpen[i].EnableOffMeshConnection();
        this.m_offMeshConnectionsToOpen[i].EnableForPlayer();
        i += 1;
      };
    } else {
      i = 0;
      while i < ArraySize(this.m_offMeshConnectionsToOpen) {
        this.m_offMeshConnectionsToOpen[i].DisableOffMeshConnection();
        this.m_offMeshConnectionsToOpen[i].DisableForPlayer();
        i += 1;
      };
    };
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
          this.m_workspotSideName = StringToName(finalName);
        };
        j += 1;
      };
      i += 1;
    };
    if Equals(this.m_workspotSideName, n"") {
      this.m_workspotSideName = n"Side1";
    };
  }
}

public class MovableQuestTrigger extends GameObject {

  protected let m_factName: CName;

  protected let m_onlyDetectsPlayer: Bool;

  protected cb func OnAreaEnter(trigger: ref<AreaEnteredEvent>) -> Bool {
    if this.m_onlyDetectsPlayer {
      if (EntityGameInterface.GetEntity(trigger.activator) as GameObject).IsPlayer() {
        SetFactValue(this.GetGame(), this.m_factName, 1);
      };
    } else {
      SetFactValue(this.GetGame(), this.m_factName, 1);
    };
  }

  protected cb func OnAreaExit(trigger: ref<AreaExitedEvent>) -> Bool {
    if this.m_onlyDetectsPlayer {
      if (EntityGameInterface.GetEntity(trigger.activator) as GameObject).IsPlayer() {
        SetFactValue(this.GetGame(), this.m_factName, 0);
      };
    } else {
      SetFactValue(this.GetGame(), this.m_factName, 0);
    };
  }
}
