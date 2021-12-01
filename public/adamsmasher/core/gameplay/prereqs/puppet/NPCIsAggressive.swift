
public class NPCIsAggressivePrereq extends IScriptablePrereq {

  public let m_invert: Bool;

  protected func Initialize(recordID: TweakDBID) -> Void {
    this.m_invert = TweakDBInterface.GetBool(recordID + t".invert", false);
  }

  public const func IsFulfilled(game: GameInstance, context: ref<IScriptable>) -> Bool {
    let checkPassed: Bool;
    let owner: wref<ScriptedPuppet> = context as ScriptedPuppet;
    if IsDefined(owner) {
      checkPassed = owner.IsAggressive();
      if this.m_invert {
        checkPassed = !checkPassed;
      };
      return checkPassed;
    };
    return false;
  }

  protected const func OnApplied(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Void {
    state.OnChanged(this.IsFulfilled(game, context));
  }
}
