
public class SasquatchComponent extends ScriptableComponent {

  private let m_owner: wref<NPCPuppet>;

  private let m_owner_id: EntityID;

  private let m_statPoolSystem: ref<StatPoolsSystem>;

  private let m_statPoolType: gamedataStatPoolType;

  public final func OnGameAttach() -> Void {
    this.m_owner = this.GetOwner() as NPCPuppet;
    this.m_owner_id = this.m_owner.GetEntityID();
    this.m_statPoolSystem = GameInstance.GetStatPoolsSystem(this.m_owner.GetGame());
    StatusEffectHelper.ApplyStatusEffect(this.m_owner, t"Sasquatch.Phase1", this.m_owner.GetEntityID());
    StatusEffectHelper.ApplyStatusEffect(this.m_owner, t"BaseStatusEffect.PainInhibitors", this.m_owner.GetEntityID());
    StatusEffectHelper.ApplyStatusEffect(this.m_owner, t"Sasquatch.Healing", this.m_owner.GetEntityID());
  }

  protected cb func OnStatusEffectApplied(evt: ref<ApplyStatusEffectEvent>) -> Bool {
    let tags: array<CName> = evt.staticData.GameplayTags();
    if ArrayContains(tags, n"Overload") {
      StatusEffectHelper.ApplyStatusEffect(this.m_owner, t"BaseStatusEffect.BossNoTakeDown", this.m_owner.GetEntityID());
      this.m_owner.DropWeapons();
    };
  }

  protected cb func OnDefeatedSasquatch(evt: ref<DefeatedEvent>) -> Bool {
    let player: wref<PlayerPuppet> = this.GetPlayerSystem().GetLocalPlayerControlledGameObject() as PlayerPuppet;
    StatusEffectHelper.RemoveStatusEffect(player, t"BaseStatusEffect.NetwatcherGeneral");
  }
}
