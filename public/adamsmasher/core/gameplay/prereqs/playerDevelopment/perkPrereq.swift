
public class PerkPrereq extends IScriptablePrereq {

  public let m_perk: gamedataPerkType;

  protected func Initialize(recordID: TweakDBID) -> Void {
    let str: String = TweakDBInterface.GetString(recordID + t".perk", "");
    this.m_perk = IntEnum(Cast(EnumValueFromString("gamedataPerkType", str)));
  }

  public const func IsFulfilled(game: GameInstance, context: ref<IScriptable>) -> Bool {
    let owner: ref<GameObject> = context as GameObject;
    return PlayerDevelopmentSystem.GetData(owner).HasPerk(this.m_perk);
  }
}
