
public class NPCRecordHasVisualTag extends IScriptablePrereq {

  public let m_visualTag: CName;

  public let m_hasTag: Bool;

  protected func Initialize(recordID: TweakDBID) -> Void {
    let str: String = TweakDBInterface.GetString(recordID + t".visualTag", "");
    this.m_visualTag = StringToName(str);
    this.m_hasTag = TweakDBInterface.GetBool(recordID + t".hasTag", false);
  }

  protected const func IsOnRegisterSupported() -> Bool {
    return false;
  }

  public const func IsFulfilled(game: GameInstance, context: ref<IScriptable>) -> Bool {
    let owner: ref<GameObject> = context as GameObject;
    let targetPuppet: ref<ScriptedPuppet> = owner as ScriptedPuppet;
    if this.m_hasTag {
      if NPCManager.HasVisualTag(targetPuppet, this.m_visualTag) {
        return true;
      };
    } else {
      if !NPCManager.HasVisualTag(targetPuppet, this.m_visualTag) {
        return true;
      };
    };
    return false;
  }
}

public class EntityHasVisualTag extends IScriptablePrereq {

  private let m_visualTag: CName;

  private let m_hasTag: Bool;

  protected func Initialize(recordID: TweakDBID) -> Void {
    this.m_visualTag = StringToName(TweakDBInterface.GetString(recordID + t".visualTag", ""));
    this.m_hasTag = TweakDBInterface.GetBool(recordID + t".hasTag", false);
  }

  public const func IsFulfilled(game: GameInstance, context: ref<IScriptable>) -> Bool {
    let owner: ref<Entity> = context as Entity;
    if !IsDefined(owner) {
      return false;
    };
    if this.m_hasTag {
      if owner.MatchVisualTag(this.m_visualTag) {
        return true;
      };
    } else {
      if !owner.MatchVisualTag(this.m_visualTag) {
        return true;
      };
    };
    return false;
  }
}
