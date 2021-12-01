
public class ConnectedToBackdoorPrereq extends IScriptablePrereq {

  public let m_invert: Bool;

  protected func Initialize(recordID: TweakDBID) -> Void {
    this.m_invert = TweakDBInterface.GetBool(recordID + t".invert", false);
  }

  protected const func OnRegister(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Bool {
    state.OnChanged(this.IsFulfilled(game, context));
    return true;
  }

  public const func IsFulfilled(game: GameInstance, context: ref<IScriptable>) -> Bool {
    let checkPassed: Bool;
    let owner: wref<GameObject> = context as GameObject;
    if IsDefined(owner) {
      checkPassed = owner.IsConnectedToBackdoorDevice();
      if this.m_invert {
        checkPassed = !checkPassed;
      };
      return checkPassed;
    };
    return false;
  }
}
