
public class SocialPanelContactsDetails extends inkLogicController {

  private edit let m_ContactAvatarRef: inkImageRef;

  private edit let m_ContactNameRef: inkTextRef;

  private edit let m_ContactDescriptionRef: inkTextRef;

  public final func ShowContact(contactToShow: wref<JournalContact>, journalManager: ref<IJournalManager>) -> Void {
    InkImageUtils.RequestSetImage(this, this.m_ContactAvatarRef, contactToShow.GetAvatarID(journalManager));
    inkTextRef.SetText(this.m_ContactNameRef, contactToShow.GetLocalizedName(journalManager));
    inkTextRef.SetText(this.m_ContactDescriptionRef, "TODO: " + contactToShow.GetLocalizedName(journalManager) + " DESCRIPTION");
  }
}
