
public class RemoveHitFlagFromAttackEffector extends ModifyAttackEffector {

  public let m_hitFlag: hitFlag;

  public let m_reason: CName;

  protected func Initialize(record: TweakDBID, game: GameInstance, parentRecord: TweakDBID) -> Void {
    let str: String = TweakDBInterface.GetString(record + t".hitFlag", "");
    this.m_hitFlag = IntEnum(Cast(EnumValueFromString("hitFlag", str)));
    this.m_reason = TweakDBInterface.GetCName(record + t".reason", n"");
  }

  protected func Uninitialize(game: GameInstance) -> Void;

  private final func ProcessEffector() -> Void {
    let hitEvent: ref<gameHitEvent> = this.GetHitEvent();
    if !IsDefined(hitEvent) {
      return;
    };
    hitEvent.attackData.RemoveFlag(this.m_hitFlag);
  }

  protected func ActionOn(owner: ref<GameObject>) -> Void {
    this.ProcessEffector();
  }

  protected func RepeatedAction(owner: ref<GameObject>) -> Void {
    this.ProcessEffector();
  }
}
