
public class AddHitFlagToAttackEffector extends ModifyAttackEffector {

  public let m_hitFlag: hitFlag;

  protected func Initialize(record: TweakDBID, game: GameInstance, parentRecord: TweakDBID) -> Void {
    let str: String = TweakDBInterface.GetString(record + t".hitFlag", "");
    this.m_hitFlag = IntEnum(Cast(EnumValueFromString("hitFlag", str)));
  }

  protected func Uninitialize(game: GameInstance) -> Void;

  private final func ProcessEffector() -> Void {
    let hitEvent: ref<gameHitEvent> = this.GetHitEvent();
    if !IsDefined(hitEvent) {
      return;
    };
    hitEvent.attackData.AddFlag(this.m_hitFlag, n"AddHitFlagToAttackEffector");
  }

  protected func ActionOn(owner: ref<GameObject>) -> Void {
    this.ProcessEffector();
  }

  protected func RepeatedAction(owner: ref<GameObject>) -> Void {
    this.ProcessEffector();
  }
}
