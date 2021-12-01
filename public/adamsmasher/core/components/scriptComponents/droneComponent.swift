
public class DroneComponent extends ScriptableComponent {

  private let m_senseComponent: ref<SenseComponent>;

  private let m_npcCollisionComponent: ref<SimpleColliderComponent>;

  private let m_playerOnlyCollisionComponent: ref<SimpleColliderComponent>;

  private let m_highLevelCb: Uint32;

  private let m_currentScanType: MechanicalScanType;

  private let m_currentScanEffect: ref<EffectInstance>;

  private let m_currentScanAnimation: CName;

  private let m_isDetectionScanning: Bool;

  private let m_trackedTarget: wref<GameObject>;

  private let m_currentLocomotionWrapper: CName;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    EntityRequestComponentsInterface.RequestComponent(ri, n"playerOnlyCollision", n"SimpleColliderComponent", false);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    this.m_senseComponent = EntityResolveComponentsInterface.GetComponent(ri, n"Senses") as SenseComponent;
    this.m_npcCollisionComponent = EntityResolveComponentsInterface.GetComponent(ri, n"npcCollision") as SimpleColliderComponent;
    this.m_playerOnlyCollisionComponent = EntityResolveComponentsInterface.GetComponent(ri, n"playerOnlyCollision") as SimpleColliderComponent;
  }

  protected final func OnGameAttach() -> Void {
    let puppet: ref<ScriptedPuppet>;
    this.SendStaticDataToAnimgraph();
    this.m_currentScanType = IntEnum(0l);
    this.ApplyLocomotionWrappers(n"Walk");
    puppet = this.GetOwner() as ScriptedPuppet;
    if puppet.IsDead() {
      GameObject.PlaySound(puppet, n"drone_disable");
    } else {
      GameObject.PlaySound(puppet, n"drone_enable");
    };
    if IsDefined(this.m_playerOnlyCollisionComponent) {
      this.m_playerOnlyCollisionComponent.Toggle(false);
    };
  }

  protected cb func OnHighLevelStateDataEvent(evt: ref<gameHighLevelStateDataEvent>) -> Bool {
    if Equals(evt.currentHighLevelState, gamedataNPCHighLevelState.Alerted) {
      DroneComponent.SetLocomotionWrappers(this.GetOwner() as ScriptedPuppet, n"Walk");
    };
    if Equals(evt.currentHighLevelState, gamedataNPCHighLevelState.Combat) || Equals(evt.currentHighLevelState, gamedataNPCHighLevelState.Alerted) {
      this.ApplyPose(DronePose.Combat);
    } else {
      this.ApplyPose(DronePose.Relaxed);
    };
  }

  protected cb func OnAIEvent(aiEvent: ref<AIEvent>) -> Bool {
    switch aiEvent.name {
      case n"CombatPose":
        this.ApplyPose(DronePose.Combat);
        break;
      case n"RelaxedPose":
        this.ApplyPose(DronePose.Relaxed);
        break;
      default:
    };
  }

  private final func ApplyPose(desiredPose: DronePose) -> Void {
    let stateAnimationDataFeature: ref<AnimFeature_DroneStateAnimationData> = new AnimFeature_DroneStateAnimationData();
    stateAnimationDataFeature.statePose = EnumInt(desiredPose);
    AnimationControllerComponent.ApplyFeature(this.GetOwner(), n"DroneStateAnimationData", stateAnimationDataFeature);
  }

  protected cb func OnRagdollEnabledEvent(evt: ref<RagdollNotifyEnabledEvent>) -> Bool {
    if IsDefined(this.m_playerOnlyCollisionComponent) && TweakDBInterface.GetBool((this.GetOwner() as ScriptedPuppet).GetRecordID() + t".keepColliderOnDeath", false) {
      this.m_playerOnlyCollisionComponent.Toggle(true);
    };
  }

  protected cb func OnDefeated(evt: ref<DefeatedEvent>) -> Bool {
    GameObject.PlaySound(this.GetOwner(), n"drone_defeated");
  }

  protected cb func OnDeath(evt: ref<gameDeathEvent>) -> Bool {
    let reenableColliderEvent: ref<ReenableColliderEvent>;
    let uncontrolledMovementEvent: ref<UncontrolledMovementStartEvent>;
    let owner: ref<NPCPuppet> = this.GetOwner() as NPCPuppet;
    GameObject.PlaySound(owner, n"drone_destroyed");
    if StatusEffectSystem.ObjectHasStatusEffect(owner, t"BaseStatusEffect.SystemCollapse") {
      GameObject.StartReplicatedEffectEvent(owner, n"hacks_system_collapse");
      this.RemoveSpawnGLPs(owner);
    } else {
      if StatusEffectSystem.ObjectHasStatusEffectOfType(owner, gamedataStatusEffectType.BrainMelt) {
        GameObject.StartReplicatedEffectEvent(owner, n"hacks_brain_bolt_kill");
        this.RemoveSpawnGLPs(owner);
      } else {
        GameObject.StartReplicatedEffectEvent(owner, n"destruction");
      };
    };
    if TweakDBInterface.GetBool(owner.GetRecordID() + t".keepColliderOnDeath", false) {
      reenableColliderEvent = new ReenableColliderEvent();
      GameInstance.GetDelaySystem(owner.GetGame()).DelayEvent(owner, reenableColliderEvent, 0.20);
    };
    uncontrolledMovementEvent = new UncontrolledMovementStartEvent();
    uncontrolledMovementEvent.ragdollOnCollision = true;
    uncontrolledMovementEvent.ragdollNoGroundThreshold = -1.00;
    uncontrolledMovementEvent.DebugSetSourceName(n"DroneComponent - the drone died so we started uncontrolled movement to ragdoll on collision");
    owner.QueueEvent(uncontrolledMovementEvent);
  }

  private final func RemoveSpawnGLPs(owner: ref<NPCPuppet>) -> Void {
    let glp: ref<GameplayLogicPackageSystem> = GameInstance.GetGameplayLogicPackageSystem(owner.GetGame());
    let i: Int32 = 0;
    while i < owner.GetRecord().GetOnSpawnGLPsCount() {
      glp.RemovePackage(owner, owner.GetRecord().GetOnSpawnGLPsItem(i).GetID());
      i += 1;
    };
  }

  protected cb func OnReenableCollider(evt: ref<ReenableColliderEvent>) -> Bool {
    let puppet: ref<NPCPuppet> = this.GetOwner() as NPCPuppet;
    if !puppet.IsRagdollEnabled() {
      this.m_npcCollisionComponent.Toggle(true);
      if IsDefined(this.m_playerOnlyCollisionComponent) {
        this.m_playerOnlyCollisionComponent.Toggle(false);
      };
    };
  }

  private final func SendStaticDataToAnimgraph() -> Void {
    let appleFeatureEvent: ref<ApplyDroneProceduralAnimFeatureEvent>;
    let ownerID: TweakDBID;
    let proceduralAnimationFeature: ref<AnimFeature_DroneProcedural>;
    let owner: ref<ScriptedPuppet> = this.GetOwner() as ScriptedPuppet;
    if IsDefined(owner) {
      ownerID = owner.GetRecordID();
      proceduralAnimationFeature = new AnimFeature_DroneProcedural();
      proceduralAnimationFeature.mass = TweakDBInterface.GetFloat(ownerID + t".mass", 0.00);
      proceduralAnimationFeature.size_front = TweakDBInterface.GetFloat(ownerID + t".sizeFront", 0.00);
      proceduralAnimationFeature.size_back = TweakDBInterface.GetFloat(ownerID + t".sizeBack", 0.00);
      proceduralAnimationFeature.size_left = TweakDBInterface.GetFloat(ownerID + t".sizeLeft", 0.00);
      proceduralAnimationFeature.size_right = TweakDBInterface.GetFloat(ownerID + t".sizeRight", 0.00);
      proceduralAnimationFeature.walk_tilt_coef = TweakDBInterface.GetFloat(ownerID + t".walkTiltCoefficient", 0.00);
      proceduralAnimationFeature.mass_normalized_coef = TweakDBInterface.GetFloat(ownerID + t".massNormalizedCoefficient", 0.00);
      proceduralAnimationFeature.tilt_angle_on_speed = TweakDBInterface.GetFloat(ownerID + t".tiltAngleOnSpeed", 0.00);
      proceduralAnimationFeature.speed_idle_threshold = TweakDBInterface.GetFloat(ownerID + t".speedIdleThreshold", 0.00);
      proceduralAnimationFeature.starting_recovery_ballance = TweakDBInterface.GetFloat(ownerID + t".startingRecoveryBalance", 0.00);
      proceduralAnimationFeature.pseudo_acceleration = TweakDBInterface.GetFloat(ownerID + t".pseudoAcceleration", 0.00);
      proceduralAnimationFeature.turn_inertia_damping = TweakDBInterface.GetFloat(ownerID + t".turnInertiaDamping", 0.00);
      proceduralAnimationFeature.combat_default_z_offset = TweakDBInterface.GetFloat(ownerID + t".combatDefaultZOffset", 0.00);
      appleFeatureEvent = new ApplyDroneProceduralAnimFeatureEvent();
      appleFeatureEvent.feature = proceduralAnimationFeature;
      GameInstance.GetDelaySystem(owner.GetGame()).DelayEvent(owner, appleFeatureEvent, 0.20, false);
    };
  }

  protected cb func OnApplyProceduralAnimFeatureEvent(evt: ref<ApplyDroneProceduralAnimFeatureEvent>) -> Bool {
    AnimationControllerComponent.ApplyFeature(this.GetOwner(), n"DroneProcedural", evt.feature);
  }

  protected cb func OnApplyDroneLocomotionWrapperEvent(evt: ref<ApplyDroneLocomotionWrapperEvent>) -> Bool {
    this.ApplyLocomotionWrappers(evt.movementType);
  }

  private final func ApplyLocomotionWrappers(movementType: CName) -> Void {
    let owner: ref<GameObject>;
    if NotEquals(movementType, this.m_currentLocomotionWrapper) {
      owner = this.GetOwner();
      AnimationControllerComponent.SetAnimWrapperWeight(owner, n"DroneLocomotion_Walk", 0.00);
      AnimationControllerComponent.SetAnimWrapperWeight(owner, n"DroneLocomotion_Run", 0.00);
      AnimationControllerComponent.SetAnimWrapperWeight(owner, n"DroneLocomotion_Sprint", 0.00);
      AnimationControllerComponent.SetAnimWrapperWeight(owner, n"DroneLocomotion_" + movementType, 1.00);
      this.m_currentLocomotionWrapper = movementType;
    };
  }

  public final static func SetLocomotionWrappers(owner: ref<ScriptedPuppet>, movementType: CName) -> Void {
    let applyWrapperEvent: ref<ApplyDroneLocomotionWrapperEvent> = new ApplyDroneLocomotionWrapperEvent();
    applyWrapperEvent.movementType = movementType;
    owner.QueueEvent(applyWrapperEvent);
  }
}
