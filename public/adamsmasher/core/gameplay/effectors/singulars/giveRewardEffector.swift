
public class GiveRewardEffector extends Effector {

  public let m_reward: TweakDBID;

  public let m_target: EntityID;

  protected func Initialize(record: TweakDBID, game: GameInstance, parentRecord: TweakDBID) -> Void {
    let str: String = TweakDBInterface.GetString(record + t".reward", "");
    this.m_reward = TDBID.Create(str);
  }

  protected func Uninitialize(game: GameInstance) -> Void;

  protected func RepeatedAction(owner: ref<GameObject>) -> Void {
    this.GetApplicationTarget(owner, "Target", this.m_target);
    if EntityID.IsDefined(this.m_target) {
      RPGManager.GiveReward(owner.GetGame(), this.m_reward, Cast(this.m_target));
    } else {
      RPGManager.GiveReward(owner.GetGame(), this.m_reward);
    };
  }

  protected func ActionOn(owner: ref<GameObject>) -> Void;

  protected func ActionOff(owner: ref<GameObject>) -> Void;
}
