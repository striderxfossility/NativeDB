
public class TrapComponent extends ScriptableComponent {

  private final func OnGameAttach() -> Void;

  protected cb func OnAreaEnter(evt: ref<AreaEnteredEvent>) -> Bool {
    let owningDevice: ref<Device> = this.GetOwner() as Device;
    let JuryrigEvent: ref<ChangeJuryrigTrapState> = new ChangeJuryrigTrapState();
    JuryrigEvent.newState = EJuryrigTrapState.TRIGGERED;
    if Equals(evt.componentName, n"TrapTrigger") && IsDefined(EntityGameInterface.GetEntity(evt.activator) as NPCPuppet) && Equals(owningDevice.GetDevicePS().GetJuryrigTrapState(), EJuryrigTrapState.ARMED) {
      this.SpawnAttack();
      JuryrigEvent.newState = EJuryrigTrapState.TRIGGERED;
      owningDevice.QueueEvent(JuryrigEvent);
    };
  }

  private final func SpawnAttack() -> Void {
    let attackContext: AttackInitContext;
    let statMods: array<ref<gameStatModifierData>>;
    let radius: Float = TDB.GetFloat(t"weapons.E3_grenade.damageRadius");
    attackContext.record = TweakDBInterface.GetAttackRecord(t"Attacks.FragGrenade");
    attackContext.instigator = GetPlayer(this.GetOwner().GetGame());
    attackContext.source = this.GetOwner();
    let explosionAttack: ref<Attack_GameEffect> = IAttack.Create(attackContext) as Attack_GameEffect;
    let explosionEffect: ref<EffectInstance> = explosionAttack.PrepareAttack(GetPlayer(this.GetOwner().GetGame()));
    explosionAttack.GetStatModList(statMods);
    EffectData.SetFloat(explosionEffect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.radius, radius);
    EffectData.SetVector(explosionEffect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.position, this.GetOwner().GetWorldPosition());
    EffectData.SetVariant(explosionEffect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.attack, ToVariant(explosionAttack));
    EffectData.SetVariant(explosionEffect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.attackStatModList, ToVariant(statMods));
    explosionAttack.StartAttack();
  }
}
