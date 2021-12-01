
public class SocialPanelGameController extends gameuiMenuGameController {

  private edit let m_SocialPanelContactsListRef: inkWidgetRef;

  private edit let m_SocialPanelContactsDetailsRef: inkWidgetRef;

  private let m_ContactsList: wref<SocialPanelContactsList>;

  private let m_ContactDetails: wref<SocialPanelContactsDetails>;

  private let m_RootWidget: wref<inkWidget>;

  private let m_JournalMgr: wref<JournalManager>;

  protected cb func OnInitialize() -> Bool {
    let owner: wref<GameObject>;
    this.m_RootWidget = this.GetRootWidget();
    this.m_ContactsList = inkWidgetRef.GetController(this.m_SocialPanelContactsListRef) as SocialPanelContactsList;
    this.m_ContactDetails = inkWidgetRef.GetController(this.m_SocialPanelContactsDetailsRef) as SocialPanelContactsDetails;
    this.m_ContactsList.RegisterToCallback(n"OnContactChangedRequest", this, n"OnContactChangedRequest");
    owner = this.GetPlayerControlledObject();
    this.m_JournalMgr = GameInstance.GetJournalManager(owner.GetGame());
    this.RefreshView();
  }

  protected cb func OnUninitialize() -> Bool {
    if IsDefined(this.m_ContactsList) {
      this.m_ContactsList.UnregisterFromCallback(n"OnContactChangedRequest", this, n"OnContactChangedRequest");
    };
  }

  private final func RefreshView() -> Void {
    let contactInfo: array<SocialPanelContactInfo>;
    let context: JournalRequestContext;
    let currentContact: wref<JournalContact>;
    let entries: array<wref<JournalEntry>>;
    let i: Int32;
    let limit: Int32;
    context.stateFilter.active = true;
    this.m_JournalMgr.GetContacts(context, entries);
    i = 0;
    limit = ArraySize(entries);
    while i < limit {
      currentContact = entries[i] as JournalContact;
      if IsDefined(currentContact) {
        ArrayPush(contactInfo, new SocialPanelContactInfo(this.m_JournalMgr.GetEntryHash(currentContact), currentContact));
      };
      i += 1;
    };
    this.m_ContactsList.RefreshContactsList(contactInfo);
  }

  protected cb func OnContactChangedRequest(e: wref<inkWidget>) -> Bool {
    this.DisplayContact(this.m_ContactsList.GetClickedContact());
  }

  public final func DisplayContact(contactToShow: wref<JournalContact>) -> Void {
    if IsDefined(contactToShow) {
      if this.m_ContactsList.ChooseContact(this.m_JournalMgr.GetEntryHash(contactToShow)) {
        this.m_ContactDetails.ShowContact(contactToShow, this.m_JournalMgr);
      };
    };
  }
}
