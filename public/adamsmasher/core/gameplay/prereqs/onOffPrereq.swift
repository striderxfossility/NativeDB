
public class OnOffPrereq extends IScriptablePrereq {

  protected const func OnApplied(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Void {
    (state as OnOffPrereqState).OnChanged(true);
  }

  protected const func OnUnregister(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Void {
    (state as OnOffPrereqState).OnChanged(false);
  }
}
