
public class IsPuppetActivePrereqState extends PrereqState {

  public let psListener: ref<gameScriptedPrereqPSChangeListenerWrapper>;

  protected final func OnPSStateChanged() -> Void {
    let prereq: ref<IsPuppetActivePrereq> = this.GetPrereq() as IsPuppetActivePrereq;
    this.OnChanged(prereq.IsFulfilled(GetGameInstance(), this.GetContext()));
  }
}

public class IsPuppetActivePrereq extends IScriptablePrereq {

  public let m_invert: Bool;

  protected func Initialize(recordID: TweakDBID) -> Void {
    this.m_invert = TweakDBInterface.GetBool(recordID + t".invert", false);
  }

  protected const func OnApplied(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Void {
    let castedState: ref<CharacterDataPrereqState>;
    let owner: wref<GameObject> = context as ScriptedPuppet;
    if IsDefined(owner) {
      castedState.OnChanged(this.IsFulfilled(game, context));
    };
  }

  protected const func OnRegister(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Bool {
    let persistentId: PersistentID;
    let puppet: ref<ScriptedPuppet> = context as ScriptedPuppet;
    let castedState: ref<IsPuppetActivePrereqState> = state as IsPuppetActivePrereqState;
    if IsDefined(puppet) {
      persistentId = CreatePersistentID(puppet.GetEntityID(), puppet.GetPSClassName());
      castedState.psListener = gameScriptedPrereqPSChangeListenerWrapper.CreateListener(game, persistentId, castedState);
      return false;
    };
    return false;
  }

  protected const func OnUnregister(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Void {
    let castedState: ref<IsPuppetActivePrereqState> = state as IsPuppetActivePrereqState;
    castedState.psListener = null;
  }

  public const func IsFulfilled(game: GameInstance, context: ref<IScriptable>) -> Bool {
    let targetPuppet: ref<ScriptedPuppet> = context as ScriptedPuppet;
    let result: Bool = targetPuppet.IsActive();
    if this.m_invert {
      return !result;
    };
    return result;
  }
}
