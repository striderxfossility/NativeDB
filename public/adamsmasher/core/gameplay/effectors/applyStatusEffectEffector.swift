
public class ApplyStatusEffectEffector extends Effector {

  public let m_targetEntityID: EntityID;

  public let m_applicationTarget: String;

  public let m_record: TweakDBID;

  public let m_removeWithEffector: Bool;

  public let m_inverted: Bool;

  public let m_count: Float;

  public let m_instigator: String;

  protected func Initialize(record: TweakDBID, game: GameInstance, parentRecord: TweakDBID) -> Void {
    this.m_record = TweakDBInterface.GetApplyStatusEffectEffectorRecord(record).StatusEffect().GetID();
    this.m_applicationTarget = TweakDBInterface.GetString(record + t".applicationTarget", "");
    this.m_removeWithEffector = TweakDBInterface.GetBool(record + t".removeWithEffector", true);
    this.m_inverted = TweakDBInterface.GetBool(record + t".inverted", false);
    this.m_count = TweakDBInterface.GetFloat(record + t".count", 1.00);
    this.m_instigator = TweakDBInterface.GetString(record + t".instigator", "");
  }

  protected func Uninitialize(game: GameInstance) -> Void {
    if this.m_removeWithEffector {
      if this.m_inverted {
        this.ApplyStatusEffect(game);
      } else {
        this.RemoveStatusEffect(game);
      };
    };
  }

  private final func ProcessAction(owner: ref<GameObject>) -> Void {
    if !this.GetApplicationTarget(owner, this.m_applicationTarget, this.m_targetEntityID) {
      return;
    };
    if this.m_inverted {
      this.RemoveStatusEffect(owner.GetGame());
    } else {
      this.ApplyStatusEffect(owner.GetGame());
    };
  }

  protected func ActionOn(owner: ref<GameObject>) -> Void {
    this.ProcessAction(owner);
  }

  protected func RepeatedAction(owner: ref<GameObject>) -> Void {
    this.ProcessAction(owner);
  }

  protected func ActionOff(owner: ref<GameObject>) -> Void {
    if this.m_removeWithEffector {
      if this.m_inverted {
        this.ApplyStatusEffect(owner.GetGame());
      } else {
        this.RemoveStatusEffect(owner.GetGame());
      };
    };
  }

  private final func ApplyStatusEffect(gameInstance: GameInstance) -> Void {
    let instigator: wref<GameObject>;
    let ses: ref<StatusEffectSystem>;
    if !EntityID.IsDefined(this.m_targetEntityID) || !TDBID.IsValid(this.m_record) {
      return;
    };
    instigator = this.GetInstigator(gameInstance);
    ses = GameInstance.GetStatusEffectSystem(gameInstance);
    if IsDefined(instigator) {
      ses.ApplyStatusEffect(this.m_targetEntityID, this.m_record, instigator.GetEntityID(), Cast(this.m_count));
    } else {
      ses.ApplyStatusEffect(this.m_targetEntityID, this.m_record, Cast(this.m_count));
    };
  }

  private final func RemoveStatusEffect(gameInstance: GameInstance) -> Void {
    let ses: ref<StatusEffectSystem>;
    if !EntityID.IsDefined(this.m_targetEntityID) || !TDBID.IsValid(this.m_record) {
      return;
    };
    ses = GameInstance.GetStatusEffectSystem(gameInstance);
    ses.RemoveStatusEffect(this.m_targetEntityID, this.m_record);
  }

  protected final func GetInstigator(gameInstance: GameInstance) -> wref<GameObject> {
    switch this.m_instigator {
      case "Player":
        return GetPlayer(gameInstance);
      default:
        return null;
    };
  }
}

public class FinisherEffector extends ApplyStatusEffectEffector {

  protected func Uninitialize(game: GameInstance) -> Void {
    this.Uninitialize(game);
  }

  protected func ActionOn(owner: ref<GameObject>) -> Void {
    this.ActionOn(owner);
    if owner.IsPuppet() {
      NPCPuppet.FinisherEffectorActionOn(owner as NPCPuppet, this.GetInstigator(owner.GetGame()));
    };
  }
}
