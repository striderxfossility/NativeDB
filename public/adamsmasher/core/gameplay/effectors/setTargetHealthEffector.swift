
public class SetTargetHealthEffector extends Effector {

  public let m_healthValueToSet: Float;

  protected func Initialize(record: TweakDBID, game: GameInstance, parentRecord: TweakDBID) -> Void {
    this.m_healthValueToSet = TweakDBInterface.GetFloat(record + t".healthValueToSet", 0.00);
  }

  protected func ActionOn(owner: ref<GameObject>) -> Void {
    let target: ref<NPCPuppet> = owner as NPCPuppet;
    this.Set(target);
  }

  private final func Set(target: ref<NPCPuppet>) -> Void {
    if !IsDefined(target) {
      return;
    };
    GameInstance.GetStatPoolsSystem(target.GetGame()).RequestChangingStatPoolValue(Cast(target.GetEntityID()), gamedataStatPoolType.Health, this.m_healthValueToSet, null, true, true);
  }
}
