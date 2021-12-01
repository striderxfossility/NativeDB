
public class DismemberEffector extends Effector {

  public let m_bodyPart: CName;

  public let m_woundType: CName;

  public let m_hitPosition: Vector3;

  public let m_isCritical: Bool;

  protected func Initialize(record: TweakDBID, game: GameInstance, parentRecord: TweakDBID) -> Void {
    this.m_bodyPart = TweakDBInterface.GetCName(record + t".bodyPart", n"HEAD");
    this.m_woundType = TweakDBInterface.GetCName(record + t".woundType", n"CLEAN");
    this.m_hitPosition = TweakDBInterface.GetVector3(record + t".hitPosition", new Vector3(0.00, 0.00, 0.00));
    this.m_isCritical = TweakDBInterface.GetBool(record + t".isCritical", false);
  }

  protected func ActionOn(owner: ref<GameObject>) -> Void {
    DismembermentComponent.RequestDismemberment(owner, IntEnum(Cast(EnumValueFromName(n"gameDismBodyPart", this.m_bodyPart))), IntEnum(Cast(EnumValueFromName(n"gameDismWoundType", this.m_woundType))), Vector4.Vector3To4(this.m_hitPosition), this.m_isCritical);
  }
}
