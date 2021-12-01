
public class ApplyRandomStatusEffectEffector extends Effector {

  public let m_targetEntityID: EntityID;

  public let m_applicationTarget: String;

  public let m_effects: array<TweakDBID>;

  public let m_appliedEffect: TweakDBID;

  protected func Initialize(record: TweakDBID, game: GameInstance, parentRecord: TweakDBID) -> Void {
    let strs: array<String> = TDB.GetStringArray(record + t".statusEffects");
    let i: Int32 = 0;
    while i < ArraySize(strs) {
      ArrayPush(this.m_effects, TDBID.Create(strs[i]));
      i += 1;
    };
    this.m_applicationTarget = TweakDBInterface.GetString(record + t".applicationTarget", "");
  }

  protected func Uninitialize(game: GameInstance) -> Void {
    this.RemoveStatusEffect(game);
  }

  protected func ActionOn(owner: ref<GameObject>) -> Void {
    let ses: ref<StatusEffectSystem>;
    if !this.GetApplicationTarget(owner, this.m_applicationTarget, this.m_targetEntityID) {
      return;
    };
    this.SetRandomStatusEffect();
    ses = GameInstance.GetStatusEffectSystem(owner.GetGame());
    ses.ApplyStatusEffect(this.m_targetEntityID, this.m_appliedEffect);
  }

  protected func ActionOff(owner: ref<GameObject>) -> Void {
    this.RemoveStatusEffect(owner.GetGame());
  }

  private final func RemoveStatusEffect(gameInstance: GameInstance) -> Void {
    let ses: ref<StatusEffectSystem>;
    if !EntityID.IsDefined(this.m_targetEntityID) {
      return;
    };
    ses = GameInstance.GetStatusEffectSystem(gameInstance);
    ses.RemoveStatusEffect(this.m_targetEntityID, this.m_appliedEffect);
  }

  private final func SetRandomStatusEffect() -> Void {
    let i: Int32 = RandRange(0, ArraySize(this.m_effects));
    this.m_appliedEffect = this.m_effects[i];
  }
}
