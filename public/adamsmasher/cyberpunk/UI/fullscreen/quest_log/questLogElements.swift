
public class QuestListController extends inkLogicController {

  private edit let m_CategoryName: inkTextRef;

  private edit let m_icon: inkImageRef;

  private edit let m_QuestListRef: inkCompoundRef;

  private let m_QuestType: gameJournalQuestType;

  private let m_QuestItems: array<wref<QuestItemController>>;

  private let m_LastQuestData: wref<QuestDataWrapper>;

  public final func Setup(questType: gameJournalQuestType, questTypeLocTag: String) -> Void {
    this.m_QuestType = questType;
    inkTextRef.SetText(this.m_CategoryName, questTypeLocTag);
  }

  public final func CanAddQuest(questData: script_ref<ref<QuestDataWrapper>>) -> Bool {
    return (Equals(Deref(questData).GetType(), this.m_QuestType) || Equals(Deref(questData).GetType(), gameJournalQuestType.MinorQuest) && Equals(this.m_QuestType, gameJournalQuestType.SideQuest)) && Equals(Deref(questData).GetStatus(), gameJournalEntryState.Active);
  }

  public final func AddQuest(questData: script_ref<ref<QuestDataWrapper>>, active: Bool) -> Void {
    let currButton: wref<QuestItemController> = this.SpawnFromLocal(inkWidgetRef.Get(this.m_QuestListRef), n"questItem").GetControllerByType(n"QuestItemController") as QuestItemController;
    currButton.RegisterToCallback(n"OnButtonClick", this, n"OnQuestItemClick");
    currButton.RegisterToCallback(n"OnRelease", this, n"OnButtonRelease");
    ArrayPush(this.m_QuestItems, currButton);
    currButton.SetQuestData(questData);
    if active {
      currButton.MarkAsActive();
    };
    this.GetRootWidget().SetVisible(true);
  }

  protected cb func OnButtonRelease(e: ref<inkPointerEvent>) -> Bool {
    let currButton: wref<QuestItemController>;
    let evt: ref<QuestTrackingEvent>;
    let m_ToTrack: wref<ABaseQuestObjectiveWrapper>;
    if e.IsAction(n"disassemble_item") {
      currButton = e.GetCurrentTarget().GetController() as QuestItemController;
      if IsDefined(currButton) {
        m_ToTrack = currButton.GetObjectiveData();
        evt = new QuestTrackingEvent();
        evt.m_journalEntry = m_ToTrack.GetQuestObjective();
        evt.m_objective = currButton;
        this.QueueEvent(evt);
        this.OnQuestItemClick(currButton);
      };
    };
  }

  protected cb func OnQuestItemClick(controller: wref<inkButtonController>) -> Bool {
    let currButton: wref<QuestItemController> = controller as QuestItemController;
    if IsDefined(currButton) {
      currButton.HideNewIcon();
      this.m_LastQuestData = currButton.GetQuestData();
      this.CallCustomCallback(n"OnActiveQuestChanged");
    };
  }

  public final func GetLastQuestData() -> wref<QuestDataWrapper> {
    return this.m_LastQuestData;
  }

  public final func Clear() -> Void {
    let currButton: wref<QuestItemController>;
    while ArraySize(this.m_QuestItems) > 0 {
      currButton = ArrayPop(this.m_QuestItems);
      if IsDefined(currButton) {
        currButton.UnregisterFromCallback(n"OnButtonClick", this, n"OnQuestItemClick");
        inkCompoundRef.RemoveChild(this.m_QuestListRef, currButton.GetRootWidget());
      };
    };
    this.GetRootWidget().SetVisible(false);
  }
}

public class QuestItemController extends inkButtonController {

  private edit let m_QuestTitle: inkTextRef;

  private edit let m_QuestStatus: inkTextRef;

  private edit let m_QuestIcon: inkImageRef;

  private edit let m_TrackedIcon: inkImageRef;

  private edit let m_NewIcon: inkImageRef;

  private edit let m_FrameBackground_On: inkImageRef;

  private edit let m_FrameBackground_Off: inkImageRef;

  private edit let m_FrameFluff_On: inkImageRef;

  private edit let m_FrameFluff_Off: inkImageRef;

  private edit let m_Folder_On: inkImageRef;

  private edit let m_Folder_Off: inkImageRef;

  private edit let m_StyleRoot: inkWidgetRef;

  private let m_ToTrack: wref<ABaseQuestObjectiveWrapper>;

  @default(QuestItemController, Default)
  private edit let m_DefaultStateName: CName;

  @default(QuestItemController, Marked)
  private edit let m_MarkedStateName: CName;

  protected let m_QuestObjectiveData: ref<ABaseQuestObjectiveWrapper>;

  private let m_QuestData: ref<QuestDataWrapper>;

  protected cb func OnInitialize() -> Bool;

  public final func GetQuestData() -> ref<QuestDataWrapper> {
    return this.m_QuestData;
  }

  public final func RefreshTrackedStyle(opt force: Bool) -> Void {
    if this.m_QuestData.IsTracked() || this.m_QuestData.IsTrackedInHierarchy() || force {
      inkWidgetRef.SetState(this.m_QuestIcon, n"Tracked");
      inkWidgetRef.SetState(this.m_QuestTitle, n"Tracked");
      inkWidgetRef.SetState(this.m_QuestStatus, n"Tracked");
      inkWidgetRef.SetState(this.m_FrameBackground_Off, n"Tracked");
      inkWidgetRef.SetState(this.m_FrameFluff_Off, n"Tracked");
      inkWidgetRef.SetState(this.m_Folder_Off, n"Tracked");
    } else {
      inkWidgetRef.SetState(this.m_QuestIcon, n"Default");
      inkWidgetRef.SetState(this.m_QuestTitle, n"Default");
      inkWidgetRef.SetState(this.m_QuestStatus, n"Default");
      inkWidgetRef.SetState(this.m_FrameBackground_Off, n"Default");
      inkWidgetRef.SetState(this.m_FrameFluff_Off, n"Default");
      inkWidgetRef.SetState(this.m_Folder_Off, n"Default");
    };
  }

  public final func SetQuestData(currQuest: script_ref<ref<QuestDataWrapper>>) -> Void {
    this.m_QuestData = Deref(currQuest);
    inkWidgetRef.SetVisible(this.m_TrackedIcon, false);
    inkTextRef.SetText(this.m_QuestTitle, this.m_QuestData.GetTitle());
    inkWidgetRef.SetState(this.m_StyleRoot, this.m_DefaultStateName);
    if Equals(this.m_QuestData.GetStatus(), gameJournalEntryState.Succeeded) {
      inkTextRef.SetText(this.m_QuestStatus, GetLocalizedText("UI-Notifications-QuestCompleted"));
      inkWidgetRef.SetVisible(this.m_NewIcon, false);
    } else {
      if Equals(this.m_QuestData.GetStatus(), gameJournalEntryState.Failed) {
        inkTextRef.SetText(this.m_QuestStatus, GetLocalizedText("UI-Notifications-Failed"));
        inkWidgetRef.SetVisible(this.m_NewIcon, false);
      } else {
        inkTextRef.SetText(this.m_QuestStatus, GetLocalizedText("UI-Statistic-Level") + " " + ToString(this.m_QuestData.GetLevel()));
        inkWidgetRef.SetVisible(this.m_NewIcon, this.m_QuestData.IsNew());
      };
    };
    inkWidgetRef.SetVisible(this.m_FrameBackground_On, false);
    inkWidgetRef.SetVisible(this.m_FrameFluff_On, false);
    inkWidgetRef.SetVisible(this.m_Folder_On, false);
    this.RefreshTrackedStyle();
    InkImageUtils.RequestSetImage(this, this.m_QuestIcon, "UIIcon." + ToString(this.m_QuestData.GetDistrict()));
  }

  public final func MarkAsActive() -> Void {
    if this.m_QuestData.IsTracked() || this.m_QuestData.IsTrackedInHierarchy() {
      inkWidgetRef.SetState(this.m_QuestIcon, n"Selected");
      inkWidgetRef.SetState(this.m_QuestTitle, n"Selected");
      inkWidgetRef.SetState(this.m_QuestStatus, n"Selected");
      inkWidgetRef.SetState(this.m_FrameBackground_On, n"Tracked");
      inkWidgetRef.SetState(this.m_FrameFluff_On, n"Tracked");
      inkWidgetRef.SetState(this.m_Folder_On, n"Tracked");
    } else {
      inkWidgetRef.SetState(this.m_QuestIcon, n"Selected");
      inkWidgetRef.SetState(this.m_QuestTitle, n"Selected");
      inkWidgetRef.SetState(this.m_QuestStatus, n"Selected");
      inkWidgetRef.SetState(this.m_FrameBackground_On, n"Default");
      inkWidgetRef.SetState(this.m_FrameFluff_On, n"Default");
      inkWidgetRef.SetState(this.m_Folder_On, n"Default");
    };
    inkWidgetRef.SetVisible(this.m_FrameBackground_On, true);
    inkWidgetRef.SetVisible(this.m_FrameFluff_On, true);
    inkWidgetRef.SetVisible(this.m_Folder_On, true);
  }

  private final func GetQuestStatus() -> String {
    let questStatus: String = "";
    switch this.m_QuestData.GetStatus() {
      case gameJournalEntryState.Succeeded:
        questStatus = questStatus + "[DONE]";
        break;
      case gameJournalEntryState.Failed:
        questStatus = questStatus + "[FAILED]";
        break;
      case gameJournalEntryState.Active:
        questStatus = questStatus + "[ACTIVE]";
        break;
      case gameJournalEntryState.Inactive:
        questStatus = questStatus + "[INACTIVE]";
    };
    return questStatus;
  }

  public final func HideNewIcon() -> Void {
    inkWidgetRef.SetVisible(this.m_NewIcon, false);
  }

  public final func GetObjectiveData() -> wref<ABaseQuestObjectiveWrapper> {
    let questObjectives: array<ref<QuestObjectiveWrapper>> = this.m_QuestData.GetObjectives();
    let questObjectiveToTrack: ref<QuestObjectiveWrapper> = questObjectives[0];
    let i: Int32 = 0;
    while i < ArraySize(questObjectives) {
      questObjectiveToTrack = questObjectives[i];
      if Equals(questObjectives[i].GetStatus(), gameJournalEntryState.Active) {
        questObjectiveToTrack = questObjectives[i];
      };
      i += 1;
    };
    return questObjectiveToTrack;
  }
}

public class ObjectiveController extends inkButtonController {

  protected edit let m_ObjectiveLabel: inkTextRef;

  protected edit let m_ObjectiveStatus: inkTextRef;

  protected edit let m_QuestIcon: inkImageRef;

  protected edit let m_TrackedIcon: inkImageRef;

  protected edit let m_FrameBackground_On: inkImageRef;

  protected edit let m_FrameBackground_Off: inkImageRef;

  protected edit let m_FrameFluff_On: inkImageRef;

  protected edit let m_FrameFluff_Off: inkImageRef;

  protected edit let m_Folder_On: inkImageRef;

  protected edit let m_Folder_Off: inkImageRef;

  protected let m_QuestObjectiveData: ref<ABaseQuestObjectiveWrapper>;

  private let m_ToTrack: wref<ABaseQuestObjectiveWrapper>;

  protected cb func OnInitialize() -> Bool {
    this.RegisterToCallback(n"OnButtonClick", this, n"OnObjectiveClicked");
  }

  public final func SetState(val: CName) -> Void {
    if Equals(val, n"Tracked") {
      inkWidgetRef.SetVisible(this.m_TrackedIcon, true);
    } else {
      inkWidgetRef.SetVisible(this.m_TrackedIcon, false);
    };
    inkWidgetRef.SetState(this.m_QuestIcon, val);
    inkWidgetRef.SetState(this.m_ObjectiveLabel, val);
    inkWidgetRef.SetState(this.m_ObjectiveStatus, val);
    inkWidgetRef.SetState(this.m_FrameBackground_Off, val);
    inkWidgetRef.SetState(this.m_FrameFluff_Off, val);
    inkWidgetRef.SetState(this.m_Folder_Off, val);
  }

  private final func RefreshTrackedStyle() -> Void {
    if this.m_QuestObjectiveData.IsTracked() || this.m_QuestObjectiveData.IsTrackedInHierarchy() {
      this.SetState(n"Tracked");
    } else {
      this.SetState(n"Default");
    };
  }

  public final func Setup(data: ref<ABaseQuestObjectiveWrapper>, isOptional: Bool) -> Void {
    this.m_QuestObjectiveData = data;
    inkTextRef.SetText(this.m_ObjectiveLabel, GetLocalizedText(this.m_QuestObjectiveData.GetDescription()) + this.m_QuestObjectiveData.GetCounterText());
    inkTextRef.SetText(this.m_ObjectiveStatus, this.GetObjectiveStatus(isOptional));
    inkWidgetRef.SetVisible(this.m_TrackedIcon, this.m_QuestObjectiveData.IsTracked() || this.m_QuestObjectiveData.IsTrackedInHierarchy());
    this.SetEnabled(this.m_QuestObjectiveData.IsActive());
    this.GetRootWidget().SetVisible(NotEquals(this.m_QuestObjectiveData.GetStatus(), gameJournalEntryState.Inactive));
    this.RefreshTrackedStyle();
  }

  public final func GetObjectiveData() -> wref<ABaseQuestObjectiveWrapper> {
    return this.m_QuestObjectiveData;
  }

  protected func GetObjectiveStatus(isOptional: Bool) -> String {
    let questLabel: String;
    switch this.m_QuestObjectiveData.GetStatus() {
      case gameJournalEntryState.Succeeded:
        questLabel = "[DONE]";
        break;
      case gameJournalEntryState.Failed:
        questLabel = "[FAILED]";
        break;
      case gameJournalEntryState.Inactive:
        questLabel = "[INACTIVE]";
      default:
        if isOptional {
          questLabel = "[OPTIONAL]";
        };
    };
    return questLabel;
  }

  protected cb func OnObjectiveClicked(controller: wref<inkButtonController>) -> Bool {
    let targetObjective: wref<ObjectiveController> = controller as ObjectiveController;
    if IsDefined(targetObjective) {
      this.m_ToTrack = targetObjective.GetObjectiveData();
      this.CallCustomCallback(n"OnTrackingRequest");
    };
  }

  public final func GetToTrack() -> wref<ABaseQuestObjectiveWrapper> {
    return this.m_ToTrack;
  }
}
