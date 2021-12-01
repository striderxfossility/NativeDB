
public class CodexPopupGameController extends inkGameController {

  private edit let m_entryViewRef: inkCompoundRef;

  private edit let m_characterEntryViewRef: inkCompoundRef;

  private edit let m_imageViewRef: inkImageRef;

  private let m_entryViewController: wref<CodexEntryViewController>;

  private let m_characterEntryViewController: wref<CodexEntryViewController>;

  private let m_player: wref<GameObject>;

  private let m_journalMgr: wref<JournalManager>;

  private let m_data: ref<CodexPopupData>;

  protected cb func OnInitialize() -> Bool {
    this.m_player = this.GetPlayerControlledObject();
    this.m_journalMgr = GameInstance.GetJournalManager(this.m_player.GetGame());
    this.m_entryViewController = inkWidgetRef.GetController(this.m_entryViewRef) as CodexEntryViewController;
    this.m_characterEntryViewController = inkWidgetRef.GetController(this.m_characterEntryViewRef) as CodexEntryViewController;
    this.SetupData();
    this.PlayLibraryAnimation(n"codex_intro");
    this.RegisterToGlobalInputCallback(n"OnPostOnRelease", this, n"OnRelease");
  }

  protected cb func OnUninitialize() -> Bool {
    this.UnregisterFromGlobalInputCallback(n"OnPostOnRelease", this, n"OnRelease");
  }

  protected cb func OnRelease(evt: ref<inkPointerEvent>) -> Bool {
    if evt.IsAction(n"proceed") || evt.IsAction(n"cancel") || evt.IsAction(n"back") {
      this.PlaySound(n"Button", n"OnPress");
      this.m_data.token.TriggerCallback(this.m_data);
    };
  }

  private final func SetupData() -> Void {
    let codexEntry: wref<JournalCodexEntry>;
    let codexEntryData: ref<CodexEntryData>;
    let currentCategory: wref<JournalCodexCategory>;
    let currentGroup: wref<JournalCodexGroup>;
    let currentType: CodexCategoryType;
    let imageEntry: ref<JournalImageEntry>;
    let newEntries: array<Int32>;
    let stateFilter: JournalRequestStateFilter;
    this.m_data = this.GetRootWidget().GetUserData(n"CodexPopupData") as CodexPopupData;
    if IsDefined(this.m_data) {
      codexEntry = this.m_data.m_entry as JournalCodexEntry;
      imageEntry = this.m_data.m_entry as JournalImageEntry;
      if IsDefined(imageEntry) {
        inkWidgetRef.SetVisible(this.m_entryViewRef, false);
        inkWidgetRef.SetVisible(this.m_characterEntryViewRef, false);
        inkWidgetRef.SetVisible(this.m_imageViewRef, true);
        InkImageUtils.RequestSetImage(this, this.m_imageViewRef, imageEntry.GetImageID());
      } else {
        currentGroup = this.m_journalMgr.GetParentEntry(codexEntry) as JournalCodexGroup;
        currentCategory = this.m_journalMgr.GetParentEntry(currentGroup) as JournalCodexCategory;
        currentType = CodexUtils.GetCategoryTypeFromId(currentCategory.GetId());
        stateFilter.inactive = true;
        stateFilter.active = true;
        codexEntryData = CodexUtils.ConvertToCodexData(this.m_journalMgr, codexEntry, 0, stateFilter, newEntries);
        if Equals(currentType, CodexCategoryType.Characters) {
          this.m_characterEntryViewController.ShowEntry(codexEntryData);
          inkWidgetRef.SetVisible(this.m_entryViewRef, false);
          inkWidgetRef.SetVisible(this.m_characterEntryViewRef, true);
          inkWidgetRef.SetVisible(this.m_imageViewRef, false);
        } else {
          this.m_entryViewController.ShowEntry(codexEntryData);
          inkWidgetRef.SetVisible(this.m_entryViewRef, true);
          inkWidgetRef.SetVisible(this.m_characterEntryViewRef, false);
          inkWidgetRef.SetVisible(this.m_imageViewRef, false);
        };
      };
    };
  }
}
