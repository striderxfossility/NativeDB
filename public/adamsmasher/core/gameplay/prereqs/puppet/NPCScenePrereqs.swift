
public class NPCInScenePrereqState extends PrereqState {

  public let sceneListener: ref<gameScriptedPrereqSceneInspectionListenerWrapper>;

  protected final func OnSceneInspectionStateChanged(isEntityInScene: Bool) -> Void {
    let prereq: ref<NPCInScenePrereq> = this.GetPrereq() as NPCInScenePrereq;
    this.OnChanged(prereq.Evaluate(isEntityInScene));
  }
}

public class NPCInScenePrereq extends IScriptablePrereq {

  public let m_invert: Bool;

  protected func Initialize(recordID: TweakDBID) -> Void {
    this.m_invert = TweakDBInterface.GetBool(recordID + t".invert", false);
  }

  protected const func OnRegister(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Bool {
    let puppet: ref<ScriptedPuppet> = context as ScriptedPuppet;
    let castedState: ref<NPCInScenePrereqState> = state as NPCInScenePrereqState;
    if IsDefined(puppet) {
      castedState.sceneListener = gameScriptedPrereqSceneInspectionListenerWrapper.CreateEntityListener(game, puppet.GetEntityID(), castedState);
      return false;
    };
    return false;
  }

  protected const func OnUnregister(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Void {
    let castedState: ref<NPCInScenePrereqState> = state as NPCInScenePrereqState;
    castedState.sceneListener = null;
  }

  public const func IsFulfilled(game: GameInstance, context: ref<IScriptable>) -> Bool {
    let targetPuppet: ref<ScriptedPuppet> = context as ScriptedPuppet;
    return this.Evaluate(GameInstance.GetSceneSystem(game).GetScriptInterface().IsEntityInScene(targetPuppet.GetEntityID()));
  }

  public final const func Evaluate(isEntityInScene: Bool) -> Bool {
    if isEntityInScene {
      return this.m_invert ? false : true;
    };
    return this.m_invert ? true : false;
  }
}
