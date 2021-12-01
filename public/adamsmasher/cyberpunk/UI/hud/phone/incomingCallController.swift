
public class IncomingCallGameController extends inkHUDGameController {

  private edit let m_contactNameWidget: inkTextRef;

  private let m_phoneBlackboard: wref<IBlackboard>;

  private let m_phoneBBDefinition: ref<UI_ComDeviceDef>;

  private let m_phoneCallInfoBBID: ref<CallbackHandle>;

  private let owner: wref<GameObject>;

  private let m_animProxy: ref<inkAnimProxy>;

  protected cb func OnInitialize() -> Bool {
    this.owner = this.GetPlayerControlledObject();
    this.m_phoneBBDefinition = GetAllBlackboardDefs().UI_ComDevice;
    this.m_phoneBlackboard = this.GetBlackboardSystem().Get(this.m_phoneBBDefinition);
    if IsDefined(this.m_phoneBlackboard) {
      this.m_phoneCallInfoBBID = this.m_phoneBlackboard.RegisterDelayedListenerVariant(this.m_phoneBBDefinition.PhoneCallInformation, this, n"OnPhoneCall");
    };
    this.GetRootWidget().SetVisible(false);
  }

  protected cb func OnUninitialize() -> Bool {
    if IsDefined(this.m_phoneBlackboard) {
      this.m_phoneBlackboard.UnregisterDelayedListener(this.m_phoneBBDefinition.PhoneCallInformation, this.m_phoneCallInfoBBID);
    };
  }

  private final func GetIncomingContact(phoneCallInfo: PhoneCallInformation) -> wref<JournalContact> {
    let contactsList: array<wref<JournalEntry>>;
    let context: JournalRequestContext;
    let currContact: wref<JournalContact>;
    let i: Int32;
    let limit: Int32;
    let m_JournalMgr: wref<JournalManager> = GameInstance.GetJournalManager(this.owner.GetGame());
    context.stateFilter.active = true;
    context.stateFilter.inactive = true;
    let contactName: CName = phoneCallInfo.contactName;
    m_JournalMgr.GetContacts(context, contactsList);
    i = 0;
    limit = ArraySize(contactsList);
    while i < limit {
      currContact = contactsList[i] as JournalContact;
      if Equals(currContact.GetId(), NameToString(contactName)) {
        return currContact;
      };
      i += 1;
    };
    return null;
  }

  protected cb func OnPhoneCall(value: Variant) -> Bool {
    let dummyJournalManager: ref<IJournalManager>;
    let phoneCallInfo: PhoneCallInformation = FromVariant(value);
    let contact: wref<JournalContact> = this.GetIncomingContact(phoneCallInfo);
    let shouldDisplay: Bool = Equals(phoneCallInfo.callPhase, questPhoneCallPhase.IncomingCall) && !phoneCallInfo.isPlayerCalling;
    inkTextRef.SetLetterCase(this.m_contactNameWidget, textLetterCase.UpperCase);
    inkTextRef.SetText(this.m_contactNameWidget, contact.GetLocalizedName(dummyJournalManager));
    this.GetRootWidget().SetVisible(shouldDisplay);
    if IsDefined(this.m_animProxy) {
      this.m_animProxy.Stop();
      this.m_animProxy = null;
    };
    if shouldDisplay {
      this.m_animProxy = this.PlayLibraryAnimation(n"ring");
    };
  }
}
