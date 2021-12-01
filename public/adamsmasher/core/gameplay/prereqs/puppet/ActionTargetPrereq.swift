
public class ActionTargetPrereq extends IScriptablePrereq {

  public let m_targetRecord: wref<AIActionTarget_Record>;

  public let m_invert: Bool;

  protected func Initialize(recordID: TweakDBID) -> Void {
    let prereqRecord: ref<ActionTargetPrereq_Record> = TweakDBInterface.GetActionTargetPrereqRecord(recordID);
    this.m_targetRecord = prereqRecord.Target();
    this.m_invert = prereqRecord.Invert();
  }

  protected const func OnApplied(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Void {
    state.OnChanged(this.IsFulfilled(game, context));
  }

  public const func IsFulfilled(game: GameInstance, context: ref<IScriptable>) -> Bool {
    let ownerContext: ScriptExecutionContext;
    let targetObject: wref<GameObject>;
    let owner: wref<ScriptedPuppet> = context as ScriptedPuppet;
    if !AIHumanComponent.GetScriptContext(owner, ownerContext) {
      LogAIError("Owner must have AIHumanComponent");
      return this.m_invert ? true : false;
    };
    if !AIActionTarget.GetObject(ownerContext, this.m_targetRecord, targetObject) {
      return this.m_invert ? true : false;
    };
    return this.m_invert ? false : true;
  }
}
