
public class CPOVotingDevice extends CPOMissionDevice {

  protected let m_deviceName: CName;

  private final const func GetVoteFactName() -> CName {
    let factName: String = NameToString(this.m_compatibleDeviceName) + "_" + NameToString(this.m_deviceName) + "_voted";
    return StringToName(factName);
  }

  private final const func GetVoteTimerFactName() -> CName {
    let factName: String = NameToString(this.m_compatibleDeviceName) + "_started";
    return StringToName(factName);
  }

  protected cb func OnGameAttached() -> Bool {
    let factName: String = NameToString(this.m_compatibleDeviceName) + "_enabled";
    this.m_factToUnblock = StringToName(factName);
    super.OnGameAttached();
    this.SetFact(this.GetVoteFactName(), 0, EMathOperationType.Set);
  }

  protected cb func OnInteraction(choiceEvent: ref<InteractionChoiceEvent>) -> Bool {
    let playerVoted: ref<CPOMissionPlayerVotedEvent>;
    if Equals(choiceEvent.choice.choiceMetaData.tweakDBName, "CPOVote") {
      if this.m_blockAfterOperation {
        this.m_isBlocked = true;
      };
      this.SetFact(this.GetVoteFactName(), 1, EMathOperationType.Add);
      this.SetFact(this.GetVoteTimerFactName(), 1, EMathOperationType.Add);
      playerVoted = new CPOMissionPlayerVotedEvent();
      playerVoted.compatibleDeviceName = this.m_compatibleDeviceName;
      choiceEvent.activator.QueueEvent(playerVoted);
    };
  }
}
