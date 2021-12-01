
public class NPCRarityPrereq extends IScriptablePrereq {

  public let m_rarity: gamedataNPCRarity;

  public let m_invert: Bool;

  protected func Initialize(recordID: TweakDBID) -> Void {
    let str: String = TweakDBInterface.GetString(recordID + t".rarity", "");
    this.m_rarity = IntEnum(Cast(EnumValueFromString("gamedataNPCRarity", str)));
    this.m_invert = TweakDBInterface.GetBool(recordID + t".invert", false);
  }

  protected const func IsOnRegisterSupported() -> Bool {
    return false;
  }

  public const func IsFulfilled(game: GameInstance, context: ref<IScriptable>) -> Bool {
    let owner: ref<GameObject> = context as GameObject;
    let targetPuppet: ref<ScriptedPuppet> = owner as ScriptedPuppet;
    let rarity: ref<NPCRarity_Record> = targetPuppet.GetPuppetRarity();
    if NotEquals(rarity.Type(), this.m_rarity) {
      return this.m_invert ? true : false;
    };
    return this.m_invert ? false : true;
  }
}
