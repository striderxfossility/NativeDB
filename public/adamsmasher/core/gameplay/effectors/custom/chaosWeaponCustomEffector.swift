
public class ChaosWeaponCustomEffector extends Effector {

  public let m_effectorOwnerID: EntityID;

  public let m_target: StatsObjectID;

  public let m_record: TweakDBID;

  public let m_applicationTarget: String;

  public let m_modGroupID: Uint64;

  protected func Initialize(record: TweakDBID, game: GameInstance, parentRecord: TweakDBID) -> Void {
    this.m_record = TweakDBInterface.GetApplyStatGroupEffectorRecord(record).StatGroup().GetID();
    this.m_applicationTarget = TweakDBInterface.GetString(record + t".applicationTarget", "");
  }

  protected func ProcessEffector(owner: ref<GameObject>) -> Void {
    this.m_effectorOwnerID = owner.GetEntityID();
    let ss: ref<StatsSystem> = GameInstance.GetStatsSystem(owner.GetGame());
    if !this.GetApplicationTargetAsStatsObjectID(owner, this.m_applicationTarget, this.m_target) {
      return;
    };
    ss.RemoveModifierGroup(this.m_target, this.m_modGroupID);
    ss.UndefineModifierGroup(this.m_modGroupID);
    this.m_modGroupID = TDBID.ToNumber(this.m_record);
    ss.DefineModifierGroupFromRecord(this.m_modGroupID, this.m_record);
    ss.ApplyModifierGroup(this.m_target, this.m_modGroupID);
  }

  protected func Uninitialize(game: GameInstance) -> Void {
    this.RemoveModifierGroup(game);
  }

  protected func ActionOn(owner: ref<GameObject>) -> Void {
    this.ProcessEffector(owner);
  }

  private final func RemoveModifierGroup(gameInstance: GameInstance) -> Void {
    let ss: ref<StatsSystem>;
    if !StatsObjectID.IsDefined(this.m_target) || !EntityID.IsDefined(this.m_effectorOwnerID) {
      return;
    };
    ss = GameInstance.GetStatsSystem(gameInstance);
    ss.RemoveModifierGroup(this.m_target, this.m_modGroupID);
    ss.UndefineModifierGroup(this.m_modGroupID);
  }
}

public class ChaosWeaponDamageTypeEffector extends ChaosWeaponCustomEffector {

  public let m_damageTypeModGroups: array<TweakDBID>;

  protected func Initialize(record: TweakDBID, game: GameInstance, parentRecord: TweakDBID) -> Void {
    this.m_applicationTarget = TweakDBInterface.GetString(record + t".applicationTarget", "");
    ArrayPush(this.m_damageTypeModGroups, t"Items.ChaosPhysical");
    ArrayPush(this.m_damageTypeModGroups, t"Items.ChaosThermal");
    ArrayPush(this.m_damageTypeModGroups, t"Items.ChaosElectric");
    ArrayPush(this.m_damageTypeModGroups, t"Items.ChaosChemical");
  }

  protected func ProcessEffector(owner: ref<GameObject>) -> Void {
    let randIndex: Int32;
    this.m_effectorOwnerID = owner.GetEntityID();
    let ss: ref<StatsSystem> = GameInstance.GetStatsSystem(owner.GetGame());
    if !this.GetApplicationTargetAsStatsObjectID(owner, this.m_applicationTarget, this.m_target) {
      return;
    };
    ss.RemoveModifierGroup(this.m_target, this.m_modGroupID);
    ss.UndefineModifierGroup(this.m_modGroupID);
    randIndex = RandRange(0, ArraySize(this.m_damageTypeModGroups));
    this.m_modGroupID = TDBID.ToNumber(this.m_damageTypeModGroups[randIndex]);
    ss.DefineModifierGroupFromRecord(this.m_modGroupID, this.m_damageTypeModGroups[randIndex]);
    ss.ApplyModifierGroup(this.m_target, this.m_modGroupID);
  }
}
