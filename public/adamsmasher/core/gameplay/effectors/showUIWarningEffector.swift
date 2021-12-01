
public class ShowUIWarningEffector extends Effector {

  public let m_duration: Float;

  public let m_primaryText: String;

  public let m_secondaryText: String;

  public let m_owner: wref<GameObject>;

  protected func Initialize(record: TweakDBID, game: GameInstance, parentRecord: TweakDBID) -> Void {
    this.m_duration = TweakDBInterface.GetFloat(record + t".duration", 2.00);
    this.m_primaryText = TweakDBInterface.GetString(record + t".primaryText", "");
    this.m_secondaryText = TweakDBInterface.GetString(record + t".secondaryText", "");
  }

  protected func ActionOn(owner: ref<GameObject>) -> Void {
    let warningMsg: SimpleScreenMessage;
    let finalString: String = GetLocalizedText(this.m_primaryText) + " " + GetLocalizedText(this.m_secondaryText);
    warningMsg.isShown = true;
    warningMsg.duration = this.m_duration;
    warningMsg.message = finalString;
    GameInstance.GetBlackboardSystem(owner.GetGame()).Get(GetAllBlackboardDefs().UI_Notifications).SetVariant(GetAllBlackboardDefs().UI_Notifications.WarningMessage, ToVariant(warningMsg), true);
  }
}
