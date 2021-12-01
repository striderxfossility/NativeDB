
public class AlwaysTruePrereq extends IScriptablePrereq {

  protected const func OnApplied(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Void {
    (state as AlwaysTruePrereqState).OnChanged(true);
  }
}
