
public class BossStealthComponent extends ScriptableComponent {

  private let m_owner: wref<NPCPuppet>;

  private let m_owner_id: EntityID;

  private let m_statPoolSystem: ref<StatPoolsSystem>;

  private let m_statPoolType: gamedataStatPoolType;

  private let m_targetTrackerComponent: ref<TargetTrackerComponent>;

  private final func OnGameAttach() -> Void {
    this.m_owner = this.GetOwner() as NPCPuppet;
    this.m_owner_id = this.m_owner.GetEntityID();
    this.m_owner.SetDisableRagdoll(true);
    this.m_statPoolSystem = GameInstance.GetStatPoolsSystem(this.m_owner.GetGame());
    this.m_targetTrackerComponent = this.m_owner.GetTargetTrackerComponent();
  }

  protected cb func OnStatusEffectApplied(evt: ref<ApplyStatusEffectEvent>) -> Bool {
    let tags: array<CName> = evt.staticData.GameplayTags();
    if ArrayContains(tags, n"Blind") {
      StatusEffectHelper.ApplyStatusEffect(this.m_owner, t"BaseStatusEffect.BossNoTakeDown", this.m_owner.GetEntityID());
      if IsDefined(this.m_targetTrackerComponent) {
        this.m_targetTrackerComponent.ClearThreats();
      };
    };
  }

  protected cb func OnNonStealthQuickHackVictimEvent(evt: ref<NonStealthQuickHackVictimEvent>) -> Bool {
    NPCStatesComponent.AlertPuppet(this.m_owner);
  }
}
