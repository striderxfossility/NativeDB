
public class SetFactEffector extends Effector {

  public let m_fact: CName;

  public let m_value: Int32;

  protected func Initialize(record: TweakDBID, game: GameInstance, parentRecord: TweakDBID) -> Void {
    this.m_fact = TweakDBInterface.GetCName(record + t".fact", n"");
    this.m_value = TweakDBInterface.GetInt(record + t".value", 0);
  }

  protected func ActionOn(owner: ref<GameObject>) -> Void {
    GameInstance.GetQuestsSystem(owner.GetGame()).SetFact(this.m_fact, this.m_value);
  }
}

public class ToggleFactEffector extends Effector {

  public let m_fact: CName;

  public let m_valueOn: Int32;

  public let m_valueOff: Int32;

  protected func Initialize(record: TweakDBID, game: GameInstance, parentRecord: TweakDBID) -> Void {
    this.m_fact = TweakDBInterface.GetCName(record + t".fact", n"");
    this.m_valueOn = TweakDBInterface.GetInt(record + t".valueOn", 0);
    this.m_valueOff = TweakDBInterface.GetInt(record + t".valueOff", 0);
  }

  protected func ActionOn(owner: ref<GameObject>) -> Void {
    GameInstance.GetQuestsSystem(owner.GetGame()).SetFact(this.m_fact, this.m_valueOn);
  }

  protected func ActionOff(owner: ref<GameObject>) -> Void {
    GameInstance.GetQuestsSystem(owner.GetGame()).SetFact(this.m_fact, this.m_valueOff);
  }
}
