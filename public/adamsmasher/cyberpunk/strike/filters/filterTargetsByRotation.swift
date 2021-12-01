
public class IsFacingTowardsSource extends EffectObjectSingleFilter_Scripted {

  public edit let m_applyForPlayer: Bool;

  public edit let m_applyForNPCs: Bool;

  public edit let m_invert: Bool;

  @default(IsFacingTowardsSource, 90.f)
  public edit let m_maxAllowedAngleYaw: Float;

  @default(IsFacingTowardsSource, 45.f)
  public edit let m_maxAllowedAnglePitch: Float;

  public final func Process(ctx: EffectScriptContext, filterCtx: EffectSingleFilterScriptContext) -> Bool {
    let sourceTransform: Transform;
    let targetPuppet: ref<ScriptedPuppet>;
    let targetTransform: Transform;
    let isFacingSource: Bool = true;
    let targetEntity: ref<Entity> = EffectSingleFilterScriptContext.GetEntity(filterCtx);
    let sourceEntity: ref<Entity> = EffectScriptContext.GetSource(ctx);
    if !IsDefined(targetEntity) || !IsDefined(sourceEntity) {
      return true;
    };
    sourceTransform = Transform.Create(sourceEntity.GetWorldPosition(), sourceEntity.GetWorldOrientation());
    targetPuppet = targetEntity as ScriptedPuppet;
    if this.m_applyForPlayer && targetEntity == GameInstance.GetPlayerSystem(EffectScriptContext.GetGameInstance(ctx)).GetLocalPlayerControlledGameObject() {
      GameInstance.GetCameraSystem(EffectScriptContext.GetGameInstance(ctx)).GetActiveCameraWorldTransform(targetTransform);
      isFacingSource = this.IsWithinAngleLimits(sourceTransform, targetTransform, this.m_maxAllowedAngleYaw, this.m_maxAllowedAnglePitch);
    };
    if this.m_applyForNPCs && IsDefined(targetPuppet) {
      targetTransform = Transform.Create(targetEntity.GetWorldPosition(), targetEntity.GetWorldOrientation());
      isFacingSource = this.IsWithinAngleLimits(sourceTransform, targetTransform, this.m_maxAllowedAngleYaw, -1.00);
    };
    return this.m_invert ? !isFacingSource : isFacingSource;
  }

  public final func IsWithinAngleLimits(sourceTransform: Transform, targetTransform: Transform, maxAllowedAngleYaw: Float, maxAllowedAnglePitch: Float) -> Bool {
    let angleDelta: Float;
    let isWithinLimits: Bool = true;
    let distanceVector: Vector4 = Transform.GetPosition(sourceTransform) - Transform.GetPosition(targetTransform);
    let targetAngles: EulerAngles = Vector4.ToRotation(Quaternion.GetForward(Transform.GetOrientation(targetTransform)));
    let distanceVectorAngles: EulerAngles = Vector4.ToRotation(distanceVector);
    if maxAllowedAngleYaw > 0.00 {
      angleDelta = AbsF(targetAngles.Yaw - distanceVectorAngles.Yaw);
      isWithinLimits = isWithinLimits && angleDelta <= maxAllowedAngleYaw;
    };
    if maxAllowedAnglePitch > 0.00 {
      angleDelta = AbsF(targetAngles.Pitch - distanceVectorAngles.Pitch);
      isWithinLimits = isWithinLimits && angleDelta <= maxAllowedAnglePitch;
    };
    return isWithinLimits;
  }
}
