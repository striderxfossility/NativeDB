
public class RestoreStatPoolEffector extends Effector {

  public let m_statPoolType: gamedataStatPoolType;

  public let m_valueToRestore: Float;

  public let m_percentage: Bool;

  protected func Initialize(record: TweakDBID, game: GameInstance, parentRecord: TweakDBID) -> Void {
    this.m_statPoolType = IntEnum(Cast(EnumValueFromString("gamedataStatPoolType", TweakDBInterface.GetString(record + t".statPoolType", ""))));
    this.m_valueToRestore = TweakDBInterface.GetFloat(record + t".value", 0.00);
    this.m_percentage = TweakDBInterface.GetBool(record + t".isPercentage", false);
  }

  protected func ActionOn(owner: ref<GameObject>) -> Void {
    if NotEquals(this.m_statPoolType, gamedataStatPoolType.Invalid) && this.m_valueToRestore > 0.00 {
      GameInstance.GetStatPoolsSystem(owner.GetGame()).RequestChangingStatPoolValue(Cast(owner.GetEntityID()), this.m_statPoolType, this.m_valueToRestore, owner, false, this.m_percentage);
    };
  }
}
