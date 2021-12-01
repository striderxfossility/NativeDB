
public class StatusEffectManagerComponent extends AIMandatoryComponents {

  private let m_weaponDropedInWounded: Bool;

  private final func GetPuppet() -> ref<ScriptedPuppet> {
    return this.GetOwner() as ScriptedPuppet;
  }

  private final func GetBlackboard() -> ref<IBlackboard> {
    return this.GetPuppet().GetPuppetStateBlackboard();
  }

  private final func SetAnimWrapperWeight(key: CName, value: Float) -> Void {
    let ev: ref<AnimWrapperWeightSetter> = new AnimWrapperWeightSetter();
    ev.key = key;
    ev.value = value;
    this.GetPuppet().QueueEvent(ev);
  }

  protected cb func OnStatusEffectApplied(evt: ref<ApplyStatusEffectEvent>) -> Bool {
    let statusEffectTags: array<CName>;
    if IsDefined(evt.staticData) {
      statusEffectTags = evt.staticData.GameplayTags();
      if ArrayContains(statusEffectTags, n"Dismember") {
        this.EnterInstantDismemberment();
      };
    };
  }

  private final func EnterInstantDismemberment() -> Void {
    let forcedDeathEvent: ref<ForcedDeathEvent> = new ForcedDeathEvent();
    forcedDeathEvent.hitIntensity = 1;
    forcedDeathEvent.hitSource = 1;
    forcedDeathEvent.hitType = 7;
    forcedDeathEvent.hitBodyPart = 1;
    forcedDeathEvent.hitNpcMovementSpeed = 0;
    forcedDeathEvent.hitDirection = 4;
    forcedDeathEvent.hitNpcMovementDirection = 0;
    this.GetPuppet().QueueEvent(forcedDeathEvent);
    DismembermentComponent.RequestDismemberment(this.GetOwner(), gameDismBodyPart.HEAD, gameDismWoundType.COARSE);
    GameObjectEffectHelper.StartEffectEvent(GameInstance.GetPlayerSystem(this.GetOwner().GetGame()).GetLocalPlayerMainGameObject(), n"blood_onscreen");
  }
}
