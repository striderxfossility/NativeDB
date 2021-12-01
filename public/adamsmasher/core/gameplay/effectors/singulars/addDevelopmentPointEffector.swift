
public class AddDevelopmentPointEffector extends Effector {

  public let m_amount: Int32;

  public let m_type: gamedataDevelopmentPointType;

  public let m_tdbid: TweakDBID;

  protected func Initialize(record: TweakDBID, game: GameInstance, parentRecord: TweakDBID) -> Void {
    this.m_amount = TweakDBInterface.GetInt(record + t".amountOfPoints", 0);
    this.m_tdbid = record;
    let str: String = TweakDBInterface.GetString(record + t".pointsType", "");
    this.m_type = IntEnum(Cast(EnumValueFromString("gamedataDevelopmentPointType", str)));
  }

  protected func ActionOn(owner: ref<GameObject>) -> Void {
    let addDevPointRequest: ref<AddDevelopmentPoints>;
    GameInstance.GetTelemetrySystem(owner.GetGame()).LogDevPointsAddedFromReward(this.m_tdbid, this.m_amount, this.m_type);
    addDevPointRequest = new AddDevelopmentPoints();
    addDevPointRequest.Set(owner, this.m_amount, this.m_type);
    PlayerDevelopmentSystem.GetInstance(owner).QueueRequest(addDevPointRequest);
  }
}

public class BuyAttributeEffector extends Effector {

  public let m_type: gamedataStatType;

  protected func Initialize(record: TweakDBID, game: GameInstance, parentRecord: TweakDBID) -> Void {
    let str: String = TweakDBInterface.GetString(record + t".attributeType", "");
    this.m_type = IntEnum(Cast(EnumValueFromString("gamedataStatType", str)));
  }

  protected func ActionOn(owner: ref<GameObject>) -> Void {
    let butAttributeRequest: ref<BuyAttribute>;
    if !PlayerDevelopmentData.IsAttribute(this.m_type) {
      return;
    };
    butAttributeRequest = new BuyAttribute();
    butAttributeRequest.Set(owner, this.m_type, true);
    PlayerDevelopmentSystem.GetInstance(owner).QueueRequest(butAttributeRequest);
  }
}
