
public class ApplyAnimWrappersOnWeapon extends AIbehaviortaskScript {

  private edit let m_wrapperName: CName;

  private let m_refOwner: wref<AIActionTarget_Record>;

  private let m_owner: wref<GameObject>;

  private let m_ownerPosition: Vector4;

  private let m_animationController: ref<AnimationControllerComponent>;

  protected func Activate(context: ScriptExecutionContext) -> Void {
    this.m_refOwner = TweakDBInterface.GetAIActionTargetRecord(t"AIActionTarget.Owner");
  }

  protected func Update(context: ScriptExecutionContext) -> AIbehaviorUpdateOutcome {
    let puppet: wref<ScriptedPuppet>;
    AIActionTarget.Get(context, this.m_refOwner, false, this.m_owner, this.m_ownerPosition);
    puppet = this.m_owner as ScriptedPuppet;
    AnimationControllerComponent.SetAnimWrapperWeightOnOwnerAndItems(puppet, this.m_wrapperName, 1.00);
    return AIbehaviorUpdateOutcome.IN_PROGRESS;
  }

  protected func Deactivate(context: ScriptExecutionContext) -> Void;
}
