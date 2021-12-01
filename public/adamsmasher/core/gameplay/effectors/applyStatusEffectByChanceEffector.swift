
public class ApplyStatusEffectByChanceEffector extends Effector {

  public let m_targetEntityID: EntityID;

  public let m_applicationTarget: String;

  public let m_record: TweakDBID;

  public let m_removeWithEffector: Bool;

  public let m_chance: Float;

  protected func Initialize(record: TweakDBID, game: GameInstance, parentRecord: TweakDBID) -> Void {
    this.m_record = TweakDBInterface.GetApplyStatusEffectEffectorRecord(record).StatusEffect().GetID();
    this.m_applicationTarget = TweakDBInterface.GetString(record + t".applicationTarget", "");
    this.m_removeWithEffector = TweakDBInterface.GetBool(record + t".removeWithEffector", true);
    this.m_chance = TweakDBInterface.GetFloat(record + t".effectorChance", 1.00);
  }

  protected func Uninitialize(game: GameInstance) -> Void {
    if this.m_removeWithEffector {
      this.RemoveStatusEffect(game);
    };
  }

  protected func RepeatedAction(owner: ref<GameObject>) -> Void {
    let rand: Float = RandF();
    if rand <= this.m_chance {
      if !this.GetApplicationTarget(owner, this.m_applicationTarget, this.m_targetEntityID) {
        return;
      };
      this.ApplyStatusEffect(owner.GetGame());
    };
  }

  protected func ActionOff(owner: ref<GameObject>) -> Void {
    if this.m_removeWithEffector {
      this.RemoveStatusEffect(owner.GetGame());
    };
  }

  private final func ApplyStatusEffect(gameInstance: GameInstance) -> Void {
    let ses: ref<StatusEffectSystem>;
    if !EntityID.IsDefined(this.m_targetEntityID) || !TDBID.IsValid(this.m_record) {
      return;
    };
    ses = GameInstance.GetStatusEffectSystem(gameInstance);
    ses.ApplyStatusEffect(this.m_targetEntityID, this.m_record);
  }

  private final func RemoveStatusEffect(gameInstance: GameInstance) -> Void {
    let ses: ref<StatusEffectSystem>;
    if !EntityID.IsDefined(this.m_targetEntityID) || !TDBID.IsValid(this.m_record) {
      return;
    };
    ses = GameInstance.GetStatusEffectSystem(gameInstance);
    ses.RemoveStatusEffect(this.m_targetEntityID, this.m_record);
  }
}
