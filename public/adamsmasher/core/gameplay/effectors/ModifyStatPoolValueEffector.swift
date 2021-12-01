
public class ModifyStatPoolValueEffector extends Effector {

  public let m_statPoolUpdates: array<wref<StatPoolUpdate_Record>>;

  public let m_usePercent: Bool;

  public let m_applicationTarget: String;

  public let m_setValue: Bool;

  protected func Initialize(record: TweakDBID, game: GameInstance, parentRecord: TweakDBID) -> Void {
    TweakDBInterface.GetEffectorRecord(record).StatPoolUpdates(this.m_statPoolUpdates);
    this.m_usePercent = TweakDBInterface.GetBool(record + t".usePercent", false);
    this.m_applicationTarget = TweakDBInterface.GetString(record + t".applicationTarget", "");
    this.m_setValue = TweakDBInterface.GetBool(record + t".setValue", false);
  }

  protected func ActionOn(owner: ref<GameObject>) -> Void {
    this.ProcessEffector(owner);
  }

  protected func RepeatedAction(owner: ref<GameObject>) -> Void {
    this.ProcessEffector(owner);
  }

  private final func ProcessEffector(owner: ref<GameObject>) -> Void {
    let applicationTargetID: EntityID;
    let i: Int32;
    let poolSys: ref<StatPoolsSystem>;
    let statPoolType: gamedataStatPoolType;
    let statPoolValue: Float;
    if !this.GetApplicationTarget(owner, this.m_applicationTarget, applicationTargetID) {
      return;
    };
    poolSys = GameInstance.GetStatPoolsSystem(owner.GetGame());
    i = 0;
    while i < ArraySize(this.m_statPoolUpdates) {
      statPoolType = this.m_statPoolUpdates[i].StatPoolType().StatPoolType();
      statPoolValue = this.m_statPoolUpdates[i].StatPoolValue();
      if this.m_setValue {
        poolSys.RequestSettingStatPoolValue(Cast(applicationTargetID), statPoolType, statPoolValue, owner, false);
      } else {
        poolSys.RequestChangingStatPoolValue(Cast(applicationTargetID), statPoolType, statPoolValue, owner, false, this.m_usePercent);
      };
      i += 1;
    };
  }
}
