
public class HighlightObjectEffector extends Effector {

  public let m_reason: CName;

  protected func Initialize(record: TweakDBID, game: GameInstance, parentRecord: TweakDBID) -> Void {
    this.m_reason = n"HighlightObjectEffector" + StringToName(IntToString(RandRange(0, 5000)));
  }

  protected func ActionOn(owner: ref<GameObject>) -> Void {
    GameObject.SendForceRevealObjectEvent(owner, true, this.m_reason);
  }

  protected func ActionOff(owner: ref<GameObject>) -> Void {
    GameObject.SendForceRevealObjectEvent(owner, false, this.m_reason);
  }
}
