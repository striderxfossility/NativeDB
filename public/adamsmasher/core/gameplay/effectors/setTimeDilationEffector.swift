
public class SetTimeDilationEffector extends Effector {

  public let m_owner: wref<GameObject>;

  public let m_reason: CName;

  public let m_easeInCurve: CName;

  public let m_easeOutCurve: CName;

  public let m_dilation: Float;

  public let m_duration: Float;

  protected func Initialize(record: TweakDBID, game: GameInstance, parentRecord: TweakDBID) -> Void {
    this.m_reason = TweakDBInterface.GetCName(record + t".reason", n"");
    this.m_dilation = TweakDBInterface.GetFloat(record + t".dilation", 0.00);
    this.m_duration = TweakDBInterface.GetFloat(record + t".duration", 0.00);
    this.m_easeInCurve = TweakDBInterface.GetCName(record + t".easeInCurve", n"");
    this.m_easeOutCurve = TweakDBInterface.GetCName(record + t".easeOutCurve", n"");
  }

  protected func ActionOn(owner: ref<GameObject>) -> Void {
    let timeSystem: ref<TimeSystem>;
    if timeSystem.IsTimeDilationActive() || this.m_duration == 0.00 {
      return;
    };
    this.m_owner = owner;
    timeSystem = GameInstance.GetTimeSystem(this.m_owner.GetGame());
    if IsDefined(this.m_owner) && IsDefined(timeSystem) {
      timeSystem.SetIgnoreTimeDilationOnLocalPlayerZero(true);
      timeSystem.SetTimeDilation(this.m_reason, this.m_dilation, this.m_duration, this.m_easeInCurve, this.m_easeOutCurve);
    };
  }

  protected func ActionOff(owner: ref<GameObject>) -> Void {
    let timeSystem: ref<TimeSystem>;
    if IsDefined(this.m_owner) && this.m_duration < 0.00 {
      timeSystem = GameInstance.GetTimeSystem(this.m_owner.GetGame());
      if IsDefined(timeSystem) {
        timeSystem.UnsetTimeDilation(this.m_reason, this.m_easeOutCurve);
      };
    };
  }
}
