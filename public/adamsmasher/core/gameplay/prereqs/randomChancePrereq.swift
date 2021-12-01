
public class RandomChancePrereq extends IScriptablePrereq {

  protected const func OnApplied(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Void {
    let random: Float = RandRangeF(0.00, 1.00);
    (state as RandomChancePrereqState).OnChanged(random > 0.50);
  }
}
