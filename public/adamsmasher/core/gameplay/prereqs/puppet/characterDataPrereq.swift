
public class CharacterDataPrereq extends IScriptablePrereq {

  public let m_idToCheck: TweakDBID;

  protected func Initialize(recordID: TweakDBID) -> Void {
    this.m_idToCheck = TDBID.Create(TweakDBInterface.GetString(recordID + t".characterRecord", ""));
  }

  protected const func OnApplied(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Void {
    let castedState: ref<CharacterDataPrereqState>;
    let owner: wref<GameObject> = context as GameObject;
    if IsDefined(owner) {
      castedState = state as CharacterDataPrereqState;
      castedState.OnChanged(this.IsFulfilled(game, context));
    };
  }

  public const func IsFulfilled(game: GameInstance, context: ref<IScriptable>) -> Bool {
    let targetPuppet: ref<ScriptedPuppet> = context as ScriptedPuppet;
    return targetPuppet.GetRecordID() == this.m_idToCheck;
  }
}
