
public class ApplyEffectorEffector extends Effector {

  public let m_target: EntityID;

  public let m_applicationTarget: String;

  public let m_effectorToApply: TweakDBID;

  protected func Initialize(record: TweakDBID, game: GameInstance, parentRecord: TweakDBID) -> Void {
    this.m_effectorToApply = TweakDBInterface.GetApplyEffectorEffectorRecord(record).EffectorToApply().GetID();
    this.m_applicationTarget = TweakDBInterface.GetString(record + t".applicationTarget", "");
  }

  protected func ActionOn(owner: ref<GameObject>) -> Void {
    let es: ref<EffectorSystem>;
    if !this.GetApplicationTarget(owner, this.m_applicationTarget, this.m_target) {
      return;
    };
    es = GameInstance.GetEffectorSystem(owner.GetGame());
    es.ApplyEffector(this.m_target, owner, this.m_effectorToApply);
  }

  protected func ActionOff(owner: ref<GameObject>) -> Void {
    this.Uninitialize(owner.GetGame());
  }

  protected func Uninitialize(game: GameInstance) -> Void {
    let es: ref<EffectorSystem>;
    if !EntityID.IsDefined(this.m_target) {
      return;
    };
    es = GameInstance.GetEffectorSystem(game);
    es.RemoveEffector(this.m_target, this.m_effectorToApply);
  }
}
