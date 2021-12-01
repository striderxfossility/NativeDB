
public class ChangeAppearanceEffector extends Effector {

  private let m_appearanceName: CName;

  private let m_resetAppearance: Bool;

  private let m_previousAppearance: CName;

  private let m_owner: wref<GameObject>;

  protected func Initialize(record: TweakDBID, game: GameInstance, parentRecord: TweakDBID) -> Void {
    this.m_appearanceName = TweakDBInterface.GetCName(record + t".appearanceName", n"");
    this.m_resetAppearance = TweakDBInterface.GetBool(record + t".resetAppearance", true);
  }

  protected func ActionOn(owner: ref<GameObject>) -> Void {
    this.m_owner = owner;
    if Equals(this.m_resetAppearance, true) {
      this.m_previousAppearance = this.m_owner.GetCurrentAppearanceName();
    } else {
      this.m_previousAppearance = n"";
    };
    if IsNameValid(this.m_appearanceName) {
      this.m_owner.ScheduleAppearanceChange(this.m_appearanceName);
    };
  }

  protected func Uninitialize(game: GameInstance) -> Void {
    if IsNameValid(this.m_previousAppearance) {
      this.m_owner.ScheduleAppearanceChange(this.m_previousAppearance);
    };
  }
}
