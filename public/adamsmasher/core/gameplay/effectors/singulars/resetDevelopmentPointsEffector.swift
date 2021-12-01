
public class ResetDevelopmentPointsEffector extends Effector {

  protected func ActionOn(owner: ref<GameObject>) -> Void {
    let removeAllPerks: ref<RemoveAllPerks> = new RemoveAllPerks();
    removeAllPerks.Set(owner);
    PlayerDevelopmentSystem.GetInstance(owner).QueueRequest(removeAllPerks);
  }
}
