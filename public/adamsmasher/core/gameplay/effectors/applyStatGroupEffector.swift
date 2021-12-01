
public class ApplyStatGroupEffector extends Effector {

  public let m_target: StatsObjectID;

  public let m_record: TweakDBID;

  public let m_applicationTarget: String;

  public let m_modGroupID: Uint64;

  protected func Initialize(record: TweakDBID, game: GameInstance, parentRecord: TweakDBID) -> Void {
    this.m_record = TweakDBInterface.GetApplyStatGroupEffectorRecord(record).StatGroup().GetID();
    this.m_applicationTarget = TweakDBInterface.GetString(record + t".applicationTarget", "");
  }

  private final func ProcessEffector(owner: ref<GameObject>) -> Void {
    let ss: ref<StatsSystem>;
    if !this.GetApplicationTargetAsStatsObjectID(owner, this.m_applicationTarget, this.m_target) {
      return;
    };
    this.m_modGroupID = TDBID.ToNumber(this.m_record);
    ss = GameInstance.GetStatsSystem(owner.GetGame());
    ss.DefineModifierGroupFromRecord(this.m_modGroupID, this.m_record);
    ss.ApplyModifierGroup(this.m_target, this.m_modGroupID);
  }

  protected func Uninitialize(game: GameInstance) -> Void {
    this.RemoveModifierGroup(game);
  }

  protected func RepeatedAction(owner: ref<GameObject>) -> Void {
    this.ProcessEffector(owner);
  }

  protected func ActionOn(owner: ref<GameObject>) -> Void {
    this.ProcessEffector(owner);
  }

  protected func ActionOff(owner: ref<GameObject>) -> Void {
    this.RemoveModifierGroup(owner.GetGame());
  }

  private final func RemoveModifierGroup(gameInstance: GameInstance) -> Void {
    let ss: ref<StatsSystem>;
    if !StatsObjectID.IsDefined(this.m_target) {
      return;
    };
    ss = GameInstance.GetStatsSystem(gameInstance);
    ss.RemoveModifierGroup(this.m_target, this.m_modGroupID);
    ss.UndefineModifierGroup(this.m_modGroupID);
  }
}
