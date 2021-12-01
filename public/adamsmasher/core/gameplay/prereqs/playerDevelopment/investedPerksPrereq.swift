
public class InvestedPerksPrereq extends IScriptablePrereq {

  public let m_amount: Int32;

  public let m_proficiency: gamedataProficiencyType;

  protected func Initialize(recordID: TweakDBID) -> Void {
    let str: String = TweakDBInterface.GetString(recordID + t".proficiency", "");
    this.m_proficiency = IntEnum(Cast(EnumValueFromString("gamedataProficiencyType", str)));
    this.m_amount = TweakDBInterface.GetInt(recordID + t".amount", 0);
  }

  public const func IsFulfilled(game: GameInstance, context: ref<IScriptable>) -> Bool {
    let owner: ref<GameObject> = context as GameObject;
    return PlayerDevelopmentSystem.GetData(owner).GetInvestedPerkPoints(this.m_proficiency) >= this.m_amount;
  }

  public final const func GetRequiredAmount() -> Int32 {
    return this.m_amount;
  }

  public final const func GetProficiencyType() -> gamedataProficiencyType {
    return this.m_proficiency;
  }
}
