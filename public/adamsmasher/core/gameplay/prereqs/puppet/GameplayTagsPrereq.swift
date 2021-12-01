
public class GameplayTagsPrereq extends IScriptablePrereq {

  public let m_allowedTags: array<CName>;

  public let m_invert: Bool;

  protected func Initialize(recordID: TweakDBID) -> Void {
    let prereqRecord: ref<GameplayTagsPrereq_Record> = TweakDBInterface.GetGameplayTagsPrereqRecord(recordID);
    this.m_allowedTags = prereqRecord.AllowedTags();
    this.m_invert = prereqRecord.Invert();
  }

  protected const func OnApplied(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Void {
    state.OnChanged(this.IsFulfilled(game, context));
  }

  public const func IsFulfilled(game: GameInstance, context: ref<IScriptable>) -> Bool {
    let owner: ref<ScriptedPuppet> = context as ScriptedPuppet;
    if !IsDefined(owner) {
      return this.m_invert ? true : false;
    };
    if !NPCManager.HasAllTags(owner.GetRecordID(), this.m_allowedTags) {
      return this.m_invert ? true : false;
    };
    return this.m_invert ? false : true;
  }
}
