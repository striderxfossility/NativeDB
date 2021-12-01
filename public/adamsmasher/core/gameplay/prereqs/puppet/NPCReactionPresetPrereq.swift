
public class NPCReactionPresetPrereq extends IScriptablePrereq {

  public let m_reactionPreset: gamedataReactionPresetType;

  public let m_invert: Bool;

  protected func Initialize(recordID: TweakDBID) -> Void {
    let str: String = TweakDBInterface.GetString(recordID + t".reactionPreset", "");
    this.m_reactionPreset = IntEnum(Cast(EnumValueFromString("gamedataReactionPresetType", str)));
    this.m_invert = TweakDBInterface.GetBool(recordID + t".invert", false);
  }

  public const func IsFulfilled(game: GameInstance, context: ref<IScriptable>) -> Bool {
    let owner: ref<GameObject> = context as GameObject;
    let targetPuppet: ref<ScriptedPuppet> = owner as ScriptedPuppet;
    let reactionPreset: gamedataReactionPresetType = targetPuppet.GetPuppetReactionPresetType();
    if NotEquals(reactionPreset, this.m_reactionPreset) {
      return this.m_invert ? true : false;
    };
    return this.m_invert ? false : true;
  }
}
