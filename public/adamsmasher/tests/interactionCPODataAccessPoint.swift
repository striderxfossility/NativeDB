
public class CPOMissionDevice extends GameObject {

  protected let m_compatibleDeviceName: CName;

  @default(CPOMissionDataAccessPoint, true)
  @default(CPOMissionDevice, true)
  @default(CPOVotingDevice, false)
  protected let m_blockAfterOperation: Bool;

  @default(CPOVotingDevice, defaults to compatibleDeviceName_enabled)
  protected let m_factToUnblock: CName;

  @default(CPOMissionDataAccessPoint, false)
  @default(CPOMissionDevice, false)
  protected let m_isBlocked: Bool;

  @default(CPOMissionDataAccessPoint, 0)
  @default(CPOMissionDevice, 0)
  private let m_factUnblockCallbackID: Uint32;

  protected cb func OnGameAttached() -> Bool {
    super.OnGameAttached();
    this.RegisterFactsListener();
  }

  protected cb func OnDetach() -> Bool {
    this.UnregisterFactsListener();
  }

  protected func RegisterFactsListener() -> Void {
    if NotEquals(this.m_factToUnblock, n"") {
      this.m_factUnblockCallbackID = GameInstance.GetQuestsSystem(this.GetGame()).RegisterEntity(this.m_factToUnblock, this.GetEntityID());
      this.m_isBlocked = GameInstance.GetQuestsSystem(this.GetGame()).GetFact(this.m_factToUnblock) == 0;
    };
  }

  protected func UnregisterFactsListener() -> Void {
    if NotEquals(this.m_factToUnblock, n"") {
      GameInstance.GetQuestsSystem(this.GetGame()).UnregisterEntity(this.m_factToUnblock, this.m_factUnblockCallbackID);
    };
  }

  protected cb func OnEnabledFactChangeTrigerred(evt: ref<FactChangedEvent>) -> Bool {
    let factName: CName = evt.GetFactName();
    if Equals(factName, this.m_factToUnblock) {
      this.m_isBlocked = GameInstance.GetQuestsSystem(this.GetGame()).GetFact(this.m_factToUnblock) == 0;
    };
  }

  public final const func IsBlocked() -> Bool {
    return this.m_isBlocked;
  }

  public final const func GetCompatibleDeviceName() -> CName {
    return this.m_compatibleDeviceName;
  }

  protected final func SetFacts(facts: array<SFactToChange>) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(facts) {
      this.SetFact(facts[i].factName, facts[i].factValue, facts[i].operationType);
      i += 1;
    };
  }

  protected final func SetFact(factName: CName, factValue: Int32, factOperationType: EMathOperationType) -> Void {
    let newFactCount: Int32;
    if IsNameValid(factName) {
      if Equals(factOperationType, EMathOperationType.Set) {
        GameInstance.GetQuestsSystem(this.GetGame()).SetFact(factName, factValue);
      } else {
        newFactCount = GameInstance.GetQuestsSystem(this.GetGame()).GetFact(factName) + factValue;
        GameInstance.GetQuestsSystem(this.GetGame()).SetFact(factName, newFactCount);
      };
    };
  }
}

public class CPOMissionDataAccessPoint extends CPOMissionDevice {

  @default(CPOMissionDataAccessPoint, true)
  protected let m_hasDataToDownload: Bool;

  @default(CPOMissionDataAccessPoint, CPODataRaceParams)
  protected let m_damagesPresetName: CName;

  protected const let m_factsOnDownload: array<SFactToChange>;

  protected const let m_factsOnUpload: array<SFactToChange>;

  @default(CPOMissionDataAccessPoint, false)
  protected let m_ownerDecidesOnTransfer: Bool;

  public final const func HasDataToDownload() -> Bool {
    return this.m_hasDataToDownload;
  }

  protected cb func OnInteraction(choiceEvent: ref<InteractionChoiceEvent>) -> Bool {
    let missionDataTransferred: ref<CPOMissionDataTransferred>;
    let choice: String = choiceEvent.choice.choiceMetaData.tweakDBName;
    if Equals(choice, "DownloadCPOMissionData") {
      if this.m_blockAfterOperation {
        this.m_isBlocked = true;
      };
      ChatterHelper.PlayCpoServerSyncVoiceOver(choiceEvent.activator, n"cpo_got_data");
      this.m_hasDataToDownload = false;
      this.SetFacts(this.m_factsOnDownload);
      missionDataTransferred = new CPOMissionDataTransferred();
      missionDataTransferred.dataDownloaded = true;
      missionDataTransferred.compatibleDeviceName = this.m_compatibleDeviceName;
      missionDataTransferred.ownerDecidesOnTransfer = this.m_ownerDecidesOnTransfer;
      if this.IsDamagePresetValid(this.m_damagesPresetName) {
        missionDataTransferred.dataDamagesPresetName = this.m_damagesPresetName;
      } else {
        missionDataTransferred.dataDamagesPresetName = n"CPODataRaceParams";
      };
      choiceEvent.activator.QueueEvent(missionDataTransferred);
    } else {
      if Equals(choice, "UploadCPOMissionData") {
        if this.m_blockAfterOperation {
          this.m_isBlocked = true;
        };
        this.m_hasDataToDownload = true;
        this.SetFacts(this.m_factsOnUpload);
        missionDataTransferred = new CPOMissionDataTransferred();
        missionDataTransferred.dataDownloaded = false;
        choiceEvent.activator.QueueEvent(missionDataTransferred);
      };
    };
  }

  protected final func IsDamagePresetValid(presetName: CName) -> Bool {
    let armorPresetTweakDBID: TweakDBID;
    let healthPresetTweakDBID: TweakDBID;
    if NotEquals(presetName, n"") {
      armorPresetTweakDBID = TDBID.Create("player." + NameToString(presetName) + ".armorDPS");
      healthPresetTweakDBID = TDBID.Create("player." + NameToString(presetName) + ".healthDPS");
      if TDBID.IsValid(armorPresetTweakDBID) && TDBID.IsValid(healthPresetTweakDBID) {
        return true;
      };
    };
    return false;
  }
}

public native class MultiplayerGiveChoiceTokenEvent extends Event {

  public native let compatibleDeviceName: CName;

  public native let timeout: Uint32;

  @default(MultiplayerGiveChoiceTokenEvent, false)
  private let m_tokenAlreadyGiven: Bool;

  public final native func RandomizePlayer(player: ref<GameObject>) -> ref<GameObject>;

  public final func GiveChoiceToken(player: ref<PlayerPuppet>) -> Void {
    let clearDataEvent: ref<CPOMissionDataTransferred>;
    let playerToGiveData: ref<GameObject>;
    let transferDataEvent: ref<CPOMissionDataTransferred>;
    if this.m_tokenAlreadyGiven && !player.HasCPOMissionData() {
      return;
    };
    if this.m_tokenAlreadyGiven {
      playerToGiveData = this.RandomizePlayer(player);
      clearDataEvent = new CPOMissionDataTransferred();
      clearDataEvent.dataDownloaded = false;
      player.QueueEvent(clearDataEvent);
    } else {
      this.m_tokenAlreadyGiven = true;
      playerToGiveData = player;
    };
    if IsDefined(playerToGiveData) {
      transferDataEvent = new CPOMissionDataTransferred();
      transferDataEvent.dataDownloaded = true;
      transferDataEvent.compatibleDeviceName = this.compatibleDeviceName;
      transferDataEvent.ownerDecidesOnTransfer = true;
      transferDataEvent.dataDamagesPresetName = n"";
      transferDataEvent.isChoiceToken = true;
      transferDataEvent.choiceTokenTimeout = this.timeout;
      playerToGiveData.QueueEvent(transferDataEvent);
    };
  }

  public final static func CreateEvent(compatibleDeviceName: CName, timeout: Uint32) -> ref<MultiplayerGiveChoiceTokenEvent> {
    let evt: ref<MultiplayerGiveChoiceTokenEvent> = new MultiplayerGiveChoiceTokenEvent();
    evt.compatibleDeviceName = compatibleDeviceName;
    evt.timeout = timeout;
    evt.m_tokenAlreadyGiven = true;
    return evt;
  }

  public final static func CreateDelayedEvent(player: ref<GameObject>, compatibleDeviceName: CName, timeout: Uint32) -> DelayID {
    let evt: ref<MultiplayerGiveChoiceTokenEvent> = MultiplayerGiveChoiceTokenEvent.CreateEvent(compatibleDeviceName, timeout);
    return GameInstance.GetDelaySystem(player.GetGame()).DelayEvent(player, evt, Cast(timeout));
  }
}
