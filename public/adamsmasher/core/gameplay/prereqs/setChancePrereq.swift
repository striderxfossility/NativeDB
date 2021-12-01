
public class SetChancePrereq extends IScriptablePrereq {

  public let m_setChance: Float;

  protected const func OnApplied(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Void {
    let random: Float = RandRangeF(0.00, 1.00);
    (state as SetChancePrereqState).OnChanged(random < this.m_setChance);
  }

  protected func Initialize(record: TweakDBID) -> Void {
    this.m_setChance = TweakDBInterface.GetFloat(record + t".setChance", 0.00);
  }
}
