
public class SetCustomShootPosition extends AIbehaviortaskScript {

  private edit let m_offset: Vector3;

  private edit let m_fxOffset: Vector3;

  private edit let m_lockTimer: Float;

  private edit let m_landIndicatorFX: FxResource;

  @default(SetCustomShootPosition, false)
  private edit let m_keepsAcquiring: Bool;

  @default(SetCustomShootPosition, true)
  private edit let m_shootToTheGround: Bool;

  private edit let m_predictionTime: Float;

  private let m_refOwner: wref<AIActionTarget_Record>;

  private let m_refAIActionTarget: wref<AIActionTarget_Record>;

  private let m_refCustomWorldPositionTarget: wref<AIActionTarget_Record>;

  private let m_ownerPosition: Vector4;

  private let m_targetPosition: Vector4;

  private let m_fxPosition: Vector4;

  private let m_target: wref<GameObject>;

  private let m_owner: wref<GameObject>;

  private let m_fxInstance: ref<FxInstance>;

  @default(SetCustomShootPosition, false)
  private let m_targetAcquired: Bool;

  private let m_startTime: Float;

  protected func Activate(context: ScriptExecutionContext) -> Void {
    this.m_refOwner = TweakDBInterface.GetAIActionTargetRecord(t"AIActionTarget.Owner");
    this.m_refAIActionTarget = TweakDBInterface.GetAIActionTargetRecord(t"AIActionTarget.CombatTarget");
    this.m_refCustomWorldPositionTarget = TweakDBInterface.GetAIActionTargetRecord(t"AIActionTarget.CustomWorldPosition");
    this.m_startTime = EngineTime.ToFloat(GameInstance.GetTimeSystem(this.m_owner.GetGame()).GetSimTime());
  }

  protected func Update(context: ScriptExecutionContext) -> AIbehaviorUpdateOutcome {
    let currentTime: Float;
    let ownerZPos: Float;
    let trackedLocation: TrackedLocation;
    TargetTrackingExtension.GetTrackedLocation(context, this.m_owner, trackedLocation);
    if this.m_keepsAcquiring && this.m_lockTimer > 0.00 {
      currentTime = EngineTime.ToFloat(GameInstance.GetTimeSystem(this.m_owner.GetGame()).GetSimTime());
      if currentTime >= this.m_startTime + this.m_lockTimer {
        this.m_targetAcquired = true;
      };
    };
    if !this.m_targetAcquired {
      AIActionTarget.Get(context, this.m_refAIActionTarget, false, this.m_target, this.m_targetPosition);
      AIActionTarget.Get(context, this.m_refOwner, false, this.m_owner, this.m_ownerPosition);
      this.m_targetPosition = this.m_target.GetWorldPosition();
      this.m_ownerPosition = this.m_owner.GetWorldPosition();
      ownerZPos = this.m_ownerPosition.Z;
      this.m_fxPosition = this.m_targetPosition;
      if !this.m_shootToTheGround {
        this.m_targetPosition -= this.m_owner.GetWorldRight() * this.m_offset.X;
        this.m_targetPosition -= this.m_owner.GetWorldForward() * this.m_offset.Y;
        this.m_targetPosition = this.m_owner.GetWorldUp() * this.m_offset.Z;
        this.m_fxPosition -= this.m_owner.GetWorldRight() * this.m_fxOffset.X;
        this.m_fxPosition -= this.m_owner.GetWorldForward() * this.m_fxOffset.Y;
        this.m_fxPosition -= this.m_owner.GetWorldUp() * this.m_fxOffset.Z;
        this.m_fxPosition.W = 0.00;
        this.m_targetPosition.W = 0.00;
      } else {
        this.m_targetPosition.Z = ownerZPos;
        this.m_fxPosition.Z = ownerZPos;
        this.m_targetPosition -= this.m_owner.GetWorldRight() * this.m_offset.X;
        this.m_targetPosition -= this.m_owner.GetWorldForward() * this.m_offset.Y;
        this.m_targetPosition -= this.m_owner.GetWorldUp() * this.m_offset.Z;
        this.m_fxPosition -= this.m_owner.GetWorldRight() * this.m_fxOffset.X;
        this.m_fxPosition -= this.m_owner.GetWorldForward() * this.m_fxOffset.Y;
        this.m_fxPosition -= this.m_owner.GetWorldUp() * this.m_fxOffset.Z;
        this.m_fxPosition.W = 0.00;
        this.m_targetPosition.W = 0.00;
      };
      this.m_targetPosition += trackedLocation.speed * this.m_predictionTime;
      this.m_fxPosition += trackedLocation.speed * this.m_predictionTime;
      if !this.m_keepsAcquiring {
        this.m_targetAcquired = true;
      };
    };
    AIActionTarget.Set(context, this.m_refCustomWorldPositionTarget, this.m_targetPosition);
    if FxResource.IsValid(this.m_landIndicatorFX) {
      this.SpawnLandVFXs(context, this.m_landIndicatorFX, this.m_fxPosition);
    };
    return AIbehaviorUpdateOutcome.IN_PROGRESS;
  }

  private final func SpawnLandVFXs(context: ScriptExecutionContext, fx: FxResource, fxposition: Vector4) -> Void {
    let position: WorldPosition;
    let transform: WorldTransform;
    if FxResource.IsValid(fx) {
      WorldPosition.SetVector4(position, fxposition);
      WorldTransform.SetWorldPosition(transform, position);
      this.m_fxInstance = this.CreateFxInstance(context, fx, transform);
    };
  }

  private final func KillLandVFX(fxInstance: ref<FxInstance>) -> Void {
    fxInstance.BreakLoop();
  }

  private final func CreateFxInstance(context: ScriptExecutionContext, resource: FxResource, transform: WorldTransform) -> ref<FxInstance> {
    let fxSystem: ref<FxSystem> = GameInstance.GetFxSystem(AIBehaviorScriptBase.GetGame(context));
    let fx: ref<FxInstance> = fxSystem.SpawnEffect(resource, transform);
    return fx;
  }

  protected func Deactivate(context: ScriptExecutionContext) -> Void {
    this.m_targetAcquired = false;
    this.KillLandVFX(this.m_fxInstance);
  }
}
