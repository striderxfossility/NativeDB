
public class IsHumanPrereq extends IScriptablePrereq {

  public let m_invert: Bool;

  protected func Initialize(recordID: TweakDBID) -> Void {
    this.m_invert = TweakDBInterface.GetBool(recordID + t".invert", false);
  }

  public const func IsFulfilled(game: GameInstance, context: ref<IScriptable>) -> Bool {
    let checkPassed: Bool;
    let owner: wref<ScriptedPuppet> = context as ScriptedPuppet;
    if IsDefined(owner) {
      checkPassed = owner.IsHuman();
      if this.m_invert {
        checkPassed = !checkPassed;
      };
      return checkPassed;
    };
    return false;
  }
}
