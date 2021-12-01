
public class AIAlertedStateDelegate extends ScriptBehaviorDelegate {

  public let m_attackInstigatorPosition: Vector4;

  public final func DoSetExplosionInstigatorPositionAsStimSource(context: ScriptExecutionContext) -> Bool {
    let investigateData: stimInvestigateData;
    let stimuliCache: array<ref<StimuliEvent>>;
    if !Vector4.IsZero(this.m_attackInstigatorPosition) {
      ScriptExecutionContext.SetArgumentVector(context, n"StimSource", this.m_attackInstigatorPosition);
    } else {
      stimuliCache = (ScriptExecutionContext.GetOwner(context) as ScriptedPuppet).GetStimReactionComponent().GetStimuliCache();
      if ArraySize(stimuliCache) != 0 {
        investigateData = stimuliCache[ArraySize(stimuliCache) - 1].stimInvestigateData;
        if Equals(stimuliCache[ArraySize(stimuliCache) - 1].GetStimType(), gamedataStimType.Explosion) && investigateData.revealsInstigatorPosition {
          this.m_attackInstigatorPosition = investigateData.attackInstigatorPosition;
          ScriptExecutionContext.SetArgumentVector(context, n"StimSource", investigateData.attackInstigatorPosition);
        };
      };
    };
    return true;
  }

  public final func DoSetRandomAimPointLeft(context: ScriptExecutionContext) -> Bool {
    let aimPoint: Vector4 = this.GetPositionAroundInstigator(context, RandRangeF(2.80, 4.60), 0.00, RandRangeF(1.80, 3.60));
    ScriptExecutionContext.SetArgumentVector(context, n"StimSource", aimPoint);
    return true;
  }

  public final func DoSetRandomAimPointRight(context: ScriptExecutionContext) -> Bool {
    let aimPoint: Vector4 = this.GetPositionAroundInstigator(context, RandRangeF(-2.80, -4.60), 0.00, RandRangeF(1.80, 3.40));
    ScriptExecutionContext.SetArgumentVector(context, n"StimSource", aimPoint);
    return true;
  }

  public final func DoLowerWeapon(context: ScriptExecutionContext) -> Bool {
    let animFeature: ref<AnimFeature_AIAction> = new AnimFeature_AIAction();
    animFeature.state = 3;
    AnimationControllerComponent.ApplyFeatureToReplicate(ScriptExecutionContext.GetOwner(context), n"NonCombatAim", animFeature);
    return true;
  }

  private final func GetPositionAroundInstigator(context: ScriptExecutionContext, xOffset: Float, yOffset: Float, zOffset: Float) -> Vector4 {
    let ownerPuppet: ref<ScriptedPuppet> = ScriptExecutionContext.GetOwner(context) as ScriptedPuppet;
    let instigatorSimulatedRotation: Quaternion = Quaternion.BuildFromDirectionVector(ownerPuppet.GetWorldPosition() - this.m_attackInstigatorPosition, ownerPuppet.GetWorldUp());
    let aimOffset: Vector4 = new Vector4(xOffset, yOffset, zOffset, 1.00);
    let worldAimOffset: Vector4 = Vector4.RotByAngleXY(aimOffset, Vector4.Heading(Quaternion.GetForward(instigatorSimulatedRotation)));
    let worldPosition: Vector4 = this.m_attackInstigatorPosition + worldAimOffset;
    return worldPosition;
  }
}

public class AlertedAnimWrapper extends AIbehaviortaskScript {

  protected func Activate(context: ScriptExecutionContext) -> Void {
    AnimationControllerComponent.SetAnimWrapperWeightOnOwnerAndItems(ScriptExecutionContext.GetOwner(context), n"alertedLocomotion", 1.00);
  }
}
