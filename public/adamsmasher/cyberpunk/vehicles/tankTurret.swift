
public class TankTurretComponent extends ScriptableComponent {

  @attrib(customEditor, "TweakDBGroupInheritance;Attack_GameEffect")
  public edit let m_attackRecord: TweakDBID;

  public edit let m_slotComponentName1: CName;

  public edit let m_slotName1: CName;

  public edit let m_slotComponentName2: CName;

  public edit let m_slotName2: CName;

  private let m_slotComponent1: ref<SlotComponent>;

  private let m_slotComponent2: ref<SlotComponent>;

  public final func OnGameAttach() -> Void {
    let owner: ref<GameObject> = this.GetOwner();
    let player: ref<GameObject> = GameInstance.GetPlayerSystem(owner.GetGame()).GetLocalPlayerMainGameObject();
    player.RegisterInputListener(this, n"ShootTertiary");
    this.m_slotComponent1 = this.FindComponentByName(this.m_slotComponentName1) as SlotComponent;
    this.m_slotComponent2 = this.FindComponentByName(this.m_slotComponentName2) as SlotComponent;
  }

  protected cb func OnAction(action: ListenerAction, consumer: ListenerActionConsumer) -> Bool {
    if IsDefined(this.m_slotComponent1) {
      this.Shoot(this.m_slotComponent1, this.m_slotName1);
    };
    if IsDefined(this.m_slotComponent2) {
      this.Shoot(this.m_slotComponent2, this.m_slotName2);
    };
  }

  private final func Shoot(slotComponent: ref<SlotComponent>, slotName: CName) -> Void {
    let attack: ref<Attack_GameEffect>;
    let attackContext: AttackInitContext;
    let effect: ref<EffectInstance>;
    let forward: Vector4;
    let position: Vector4;
    let slotTransform: WorldTransform;
    let statMods: array<ref<gameStatModifierData>>;
    slotComponent.GetSlotTransform(slotName, slotTransform);
    GameInstance.GetTargetingSystem(this.GetOwner().GetGame()).GetDefaultCrosshairData(GameInstance.GetPlayerSystem(this.GetOwner().GetGame()).GetLocalPlayerMainGameObject(), position, forward);
    position = WorldPosition.ToVector4(WorldTransform.GetWorldPosition(slotTransform));
    attackContext.source = this.GetOwner();
    attackContext.record = TweakDBInterface.GetAttackRecord(this.m_attackRecord);
    attackContext.instigator = attackContext.source;
    attack = IAttack.Create(attackContext) as Attack_GameEffect;
    attack.GetStatModList(statMods);
    effect = attack.PrepareAttack(this.GetOwner());
    EffectData.SetVector(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.position, position);
    EffectData.SetVector(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.muzzlePosition, position);
    EffectData.SetVector(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.forward, forward);
    EffectData.SetVariant(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.attack, ToVariant(attack));
    EffectData.SetVariant(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.attackStatModList, ToVariant(statMods));
    attack.StartAttack();
  }
}

public class TankTurret extends WeakspotObject {

  protected cb func OnWeakspotInitialized() -> Bool;
}
