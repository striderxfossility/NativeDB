
public class IsPuppetBreachedPrereqState extends PrereqState {

  public let psListener: ref<gameScriptedPrereqPSChangeListenerWrapper>;

  protected final func OnPSStateChanged() -> Void {
    let prereq: ref<IsPuppetBreachedPrereq> = this.GetPrereq() as IsPuppetBreachedPrereq;
    this.OnChanged(prereq.IsFulfilled(GetGameInstance(), this.GetContext()));
  }
}

public class IsPuppetBreachedPrereq extends IScriptablePrereq {

  private let m_isBreached: Bool;

  protected func Initialize(recordID: TweakDBID) -> Void {
    this.m_isBreached = TweakDBInterface.GetBool(recordID + t".isBreached", false);
  }

  protected const func OnRegister(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Bool {
    let persistentId: PersistentID;
    let puppet: ref<ScriptedPuppet> = context as ScriptedPuppet;
    let castedState: ref<IsPuppetBreachedPrereqState> = state as IsPuppetBreachedPrereqState;
    if IsDefined(puppet) {
      persistentId = CreatePersistentID(puppet.GetEntityID(), puppet.GetPSClassName());
      castedState.psListener = gameScriptedPrereqPSChangeListenerWrapper.CreateListener(game, persistentId, castedState);
      return false;
    };
    return false;
  }

  protected const func OnUnregister(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Void {
    let castedState: ref<IsPuppetBreachedPrereqState> = state as IsPuppetBreachedPrereqState;
    castedState.psListener = null;
  }

  public const func IsFulfilled(game: GameInstance, context: ref<IScriptable>) -> Bool {
    let owner: ref<GameObject> = context as GameObject;
    let targetPuppet: ref<ScriptedPuppet> = owner as ScriptedPuppet;
    if this.m_isBreached {
      if targetPuppet.IsBreached() {
        return true;
      };
    } else {
      if !targetPuppet.IsBreached() {
        return true;
      };
    };
    return false;
  }
}
