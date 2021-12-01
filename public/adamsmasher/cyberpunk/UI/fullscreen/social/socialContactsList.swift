
public class SocialPanelContactsList extends inkLogicController {

  @default(SocialPanelContactsList, contactsListItem)
  private edit let m_ListItemName: CName;

  private edit let m_ItemsRoot: inkBasePanelRef;

  private let m_ItemsList: array<wref<SocialPanelContactsListItem>>;

  @default(SocialPanelContactsList, -1)
  private let m_CurrentContactHash: Int32;

  private let m_LastClickedContact: wref<JournalContact>;

  public final func RefreshContactsList(contacts: array<SocialPanelContactInfo>) -> Void {
    let currentController: wref<SocialPanelContactsListItem>;
    let i: Int32 = 0;
    let limit: Int32 = ArraySize(contacts);
    let numItems: Int32 = 0;
    while i < limit {
      if IsDefined(contacts[i].Contact) {
        this.AddContactItem(contacts[i], numItems);
        numItems += 1;
      };
      i += 1;
    };
    while ArraySize(this.m_ItemsList) > numItems {
      currentController = ArrayPop(this.m_ItemsList);
      currentController.UnregisterFromCallback(n"OnRelease", this, n"OnListItemClicked");
      inkCompoundRef.RemoveChild(this.m_ItemsRoot, currentController.GetRootWidget());
    };
  }

  private final func AddContactItem(contactInfo: SocialPanelContactInfo, currentItem: Int32) -> Void {
    let currentController: wref<SocialPanelContactsListItem>;
    if currentItem < ArraySize(this.m_ItemsList) {
      currentController = this.m_ItemsList[currentItem];
    } else {
      currentController = this.SpawnFromLocal(inkWidgetRef.Get(this.m_ItemsRoot), this.m_ListItemName).GetController() as SocialPanelContactsListItem;
      currentController.RegisterToCallback(n"OnRelease", this, n"OnListItemClicked");
      ArrayPush(this.m_ItemsList, currentController);
    };
    currentController.Setup(contactInfo);
    if contactInfo.Hash == this.m_CurrentContactHash {
      currentController.SetToggled(true);
    };
  }

  public final func ChooseContact(contactToShowHash: Int32) -> Bool {
    let currentHash: Int32;
    let currentlySelected: Int32;
    let i: Int32 = 0;
    let limit: Int32 = ArraySize(this.m_ItemsList);
    let toSelect: Int32 = -1;
    while i < limit {
      currentHash = this.m_ItemsList[i].GetHash();
      if currentHash == contactToShowHash {
        toSelect = i;
      };
      if currentHash == this.m_CurrentContactHash {
        currentlySelected = i;
      };
      i += 1;
    };
    if toSelect != -1 {
      this.m_ItemsList[toSelect].SetToggled(true);
      this.m_CurrentContactHash = contactToShowHash;
      if currentlySelected != -1 {
        this.m_ItemsList[currentlySelected].SetToggled(false);
      };
      return true;
    };
    return false;
  }

  private final func OnListItemClicked(e: ref<inkPointerEvent>) -> Void {
    let currController: wref<SocialPanelContactsListItem> = e.GetTarget().GetController() as SocialPanelContactsListItem;
    if IsDefined(currController) {
      this.m_LastClickedContact = currController.GetContact();
      this.CallCustomCallback(n"OnContactChangedRequest");
    };
  }

  public final func GetClickedContact() -> wref<JournalContact> {
    return this.m_LastClickedContact;
  }
}

public class SocialPanelContactsListItem extends inkToggleController {

  private edit let m_Label: inkTextRef;

  private let m_ContactInfo: SocialPanelContactInfo;

  public final func Setup(contactInfo: SocialPanelContactInfo) -> Void {
    let dummyJournalManager: ref<IJournalManager>;
    this.m_ContactInfo = contactInfo;
    inkTextRef.SetText(this.m_Label, contactInfo.Contact.GetLocalizedName(dummyJournalManager));
    this.SetToggled(false);
  }

  public final func GetHash() -> Int32 {
    return this.m_ContactInfo.Hash;
  }

  public final func GetContact() -> wref<JournalContact> {
    return this.m_ContactInfo.Contact;
  }
}
