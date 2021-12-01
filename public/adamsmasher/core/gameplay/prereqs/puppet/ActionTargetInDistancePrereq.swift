
public class ActionTargetInDistancePrereq extends IScriptablePrereq {

  public let m_targetRecord: wref<AIActionTarget_Record>;

  public let m_distance: Float;

  public let m_invert: Bool;

  protected func Initialize(recordID: TweakDBID) -> Void {
    let prereqRecord: ref<ActionTargetInDistancePrereq_Record> = TweakDBInterface.GetActionTargetInDistancePrereqRecord(recordID);
    this.m_targetRecord = prereqRecord.Target();
    this.m_distance = prereqRecord.Distance();
    this.m_invert = prereqRecord.Invert();
  }

  protected const func OnApplied(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Void {
    state.OnChanged(this.IsFulfilled(game, context));
  }

  public const func IsFulfilled(game: GameInstance, context: ref<IScriptable>) -> Bool {
    let distSqr: Float;
    let ownerContext: ScriptExecutionContext;
    let succ: Bool;
    let targetObject: wref<GameObject>;
    let owner: wref<ScriptedPuppet> = context as ScriptedPuppet;
    if !AIHumanComponent.GetScriptContext(owner, ownerContext) {
      LogAIError("Owner must have AIHumanComponent");
      return this.m_invert ? true : false;
    };
    if !AIActionTarget.GetObject(ownerContext, this.m_targetRecord, targetObject) {
      return this.m_invert ? true : false;
    };
    if this.m_distance < 0.00 {
      return this.m_invert ? true : false;
    };
    distSqr = Vector4.DistanceSquared(owner.GetWorldPosition(), targetObject.GetWorldPosition());
    succ = distSqr < this.m_distance * this.m_distance;
    return this.m_invert ? !succ : succ;
  }
}
