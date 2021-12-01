
public class ActivatedDeviceIndustrialArm extends ActivatedDeviceTrap {

  public let m_loopAnimation: EIndustrialArmAnimations;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    super.OnRequestComponents(ri);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    super.OnTakeControl(ri);
    this.m_controller = EntityResolveComponentsInterface.GetComponent(ri, n"controller") as ActivatedDeviceController;
  }

  protected func ResolveGameplayState() -> Void {
    this.ResolveGameplayState();
    this.RefreshAnimation();
  }

  public const func DeterminGameplayRole() -> EGameplayRole {
    return EGameplayRole.Distract;
  }

  protected cb func OnAreaEnter(evt: ref<AreaEnteredEvent>) -> Bool {
    if (this.GetDevicePS() as ActivatedDeviceControllerPS).ShouldActivateTrapOnAreaEnter() && !this.GetDevicePS().IsDisabled() {
      this.SendIndustrialArmAnimFeature(EnumInt(this.m_loopAnimation), true, false, false);
      this.SpawnVFXs((this.GetDevicePS() as ActivatedDeviceControllerPS).GetVFX());
      this.SendIndustrialArmDamageEvent();
    };
  }

  protected final func SendIndustrialArmDamageEvent() -> Void {
    let evt: ref<IndustrialArmDamageEvent> = new IndustrialArmDamageEvent();
    GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, evt, (this.GetDevicePS() as ActivatedDeviceControllerPS).GetAnimationTime());
  }

  protected cb func OnQuestSetIndustrialArmAnimationOverride(evt: ref<QuestSetIndustrialArmAnimationOverride>) -> Bool {
    this.RefreshAnimation();
  }

  protected cb func OnIndustrialArmDamageEvent(evt: ref<IndustrialArmDamageEvent>) -> Bool {
    this.DoAttack((this.GetDevicePS() as ActivatedDeviceControllerPS).GetAttackType());
  }

  protected cb func OnAreaExit(evt: ref<AreaExitedEvent>) -> Bool {
    this.RefreshAnimation();
  }

  protected func RefreshAnimation() -> Void {
    if (this.GetDevicePS() as ActivatedDeviceControllerPS).GetIndustrialArmAnimationOverride() != -1 {
      this.SendIndustrialArmAnimFeature((this.GetDevicePS() as ActivatedDeviceControllerPS).GetIndustrialArmAnimationOverride(), false, false, false);
    } else {
      this.SendIndustrialArmAnimFeature(EnumInt(this.m_loopAnimation), false, false, false);
    };
  }

  protected func StartGlitching(glitchState: EGlitchState, opt intensity: Float) -> Void {
    GameObjectEffectHelper.ActivateEffectAction(this, gamedataFxActionType.Start, (this.GetDevicePS() as ActivatedDeviceControllerPS).GetActivationVFXname());
    this.SendIndustrialArmAnimFeature(EnumInt(this.m_loopAnimation), false, true, false);
  }

  protected func StopGlitching() -> Void {
    GameObjectEffectHelper.ActivateEffectAction(this, gamedataFxActionType.BreakLoop, (this.GetDevicePS() as ActivatedDeviceControllerPS).GetActivationVFXname());
    this.RefreshAnimation();
  }

  protected final func SendIndustrialArmAnimFeature(idleAnimNumber: Int32, isRotate: Bool, isDistraction: Bool, isPoke: Bool) -> Void {
    let animFeature: ref<AnimFeature_IndustrialArm> = new AnimFeature_IndustrialArm();
    animFeature.idleAnimNumber = idleAnimNumber;
    animFeature.isRotate = isRotate;
    animFeature.isDistraction = isDistraction;
    animFeature.isPoke = isPoke;
    this.ApplyAnimFeatureToReplicate(this, n"IndustrialArm", animFeature);
  }
}
