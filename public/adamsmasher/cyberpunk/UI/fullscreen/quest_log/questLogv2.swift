
public class questLogV2GameController extends gameuiMenuGameController {

  private edit let m_QuestDetailsRef: inkWidgetRef;

  private edit let m_QuestDetailsHeader: inkWidgetRef;

  private edit let m_OptinalObjectivesGroupRef: inkWidgetRef;

  private edit let m_CompletedObjectivesGroupRef: inkWidgetRef;

  private edit let m_QuestListRef: inkCompoundRef;

  private edit let m_ObjectivesListRef: inkCompoundRef;

  private edit let m_OptinalObjectivesListRef: inkCompoundRef;

  private edit let m_CompletedObjectivesListRef: inkCompoundRef;

  private edit let m_QuestTitleRef: inkTextRef;

  private edit let m_QuestDescriptionRef: inkTextRef;

  private edit let m_recommendedLevel: inkTextRef;

  private edit let m_rewardsList: inkCompoundRef;

  private edit let m_codexLinksList: inkCompoundRef;

  private edit let m_CodexEntryParent: inkCompoundRef;

  private edit let m_CodexButtonRef: inkCompoundRef;

  private edit let m_buttonHintsManagerRef: inkWidgetRef;

  private edit let m_codexLibraryPath: ResRef;

  private edit let m_ObjectiveViewName: CName;

  private edit let m_QuestGroupName: CName;

  private let m_JournalWrapper: ref<JournalWrapper>;

  private let m_CurrentQuestData: ref<QuestDataWrapper>;

  private let m_ObjectiveItems: array<wref<ObjectiveController>>;

  private let m_QuestLists: array<wref<QuestListController>>;

  private let m_CodexLinksListController: wref<ListController>;

  private let m_codexButton: wref<inkButtonController>;

  private let m_menuEventDispatcher: wref<inkMenuEventDispatcher>;

  private let m_buttonHintsController: wref<ButtonHints>;

  protected cb func OnInitialize() -> Bool {
    let ownerEntity: wref<GameObject> = this.GetPlayerControlledObject();
    let gameInstance: GameInstance = ownerEntity.GetGame();
    let m_QuestDetails: wref<inkWidget> = inkWidgetRef.Get(this.m_ObjectivesListRef);
    let m_QuestList: wref<inkWidget> = inkWidgetRef.Get(this.m_QuestListRef);
    m_QuestList.RegisterToCallback(n"OnHoverOver", this, n"OnQuestHover");
    m_QuestDetails.RegisterToCallback(n"OnHoverOver", this, n"OnObjectiveHover");
    m_QuestList.RegisterToCallback(n"OnHoverOut", this, n"OnHoverOut");
    m_QuestDetails.RegisterToCallback(n"OnHoverOut", this, n"OnHoverOut");
    this.m_JournalWrapper = new JournalWrapper();
    this.m_JournalWrapper.Init(gameInstance);
    this.m_CodexLinksListController = inkWidgetRef.GetControllerByType(this.m_codexLinksList, n"inkListController") as ListController;
    this.m_CodexLinksListController.RegisterToCallback(n"OnItemActivated", this, n"OnCodexLinkClicked");
    this.m_codexButton = inkWidgetRef.GetController(this.m_CodexButtonRef) as inkButtonController;
    this.m_codexButton.RegisterToCallback(n"OnRelease", this, n"OnCodexOpenButtonClicked");
    inkWidgetRef.SetVisible(this.m_CodexButtonRef, false);
    this.m_buttonHintsController = this.SpawnFromExternal(inkWidgetRef.Get(this.m_buttonHintsManagerRef), r"base\\gameplay\\gui\\common\\buttonhints.inkwidget", n"Root").GetController() as ButtonHints;
    this.m_buttonHintsController.AddButtonHint(EInputKey.IK_Pad_B_CIRCLE, GetLocalizedText("Common-Access-Close"));
    inkCompoundRef.RemoveAllChildren(this.m_QuestListRef);
    this.CreateQuestGroup(gameJournalQuestType.MainQuest, "MAIN QUESTS");
    this.CreateQuestGroup(gameJournalQuestType.SideQuest, "SIDE QUESTS");
    this.CreateQuestGroup(gameJournalQuestType.StreetStory, "STREET STORIES");
    this.CreateQuestGroup(gameJournalQuestType.Contract, "CONTRACTS");
    this.CreateQuestGroup(gameJournalQuestType.VehicleQuest, "VEHICLES");
    this.RefreshUI();
  }

  protected cb func OnPlayerAttach(playerPuppet: ref<GameObject>) -> Bool {
    this.m_JournalWrapper = new JournalWrapper();
    this.m_JournalWrapper.Init(playerPuppet.GetGame());
    this.RefreshUI();
  }

  private final func RefreshUI() -> Void {
    let ownerEntity: wref<GameObject> = this.GetPlayerControlledObject();
    let gameInstance: GameInstance = ownerEntity.GetGame();
    this.m_JournalWrapper = new JournalWrapper();
    this.m_JournalWrapper.Init(gameInstance);
    this.BuildQuestList();
    this.BuildQuestDetails();
  }

  private final func CreateQuestGroup(questType: gameJournalQuestType, questLOCKey: String) -> Void {
    let currList: wref<QuestListController> = this.SpawnFromLocal(inkWidgetRef.Get(this.m_QuestListRef), this.m_QuestGroupName).GetControllerByType(n"QuestListController") as QuestListController;
    currList.Setup(questType, questLOCKey);
    currList.RegisterToCallback(n"OnActiveQuestChanged", this, n"OnActiveQuestChanged");
    ArrayPush(this.m_QuestLists, currList);
  }

  private final func BuildQuestList() -> Void {
    let currEntry: wref<JournalEntry>;
    let currQuest: wref<JournalQuest>;
    let i: Int32;
    let j: Int32;
    let limit: Int32;
    let limitJ: Int32;
    let listQuests: array<wref<JournalEntry>>;
    let questData: ref<QuestDataWrapper>;
    this.m_JournalWrapper.GetQuests(listQuests);
    i = 0;
    limit = ArraySize(this.m_QuestLists);
    while i < limit {
      this.m_QuestLists[i].Clear();
      i += 1;
    };
    i = 0;
    limit = ArraySize(listQuests);
    while i < limit {
      currQuest = listQuests[i] as JournalQuest;
      if IsDefined(currQuest) {
        questData = this.m_JournalWrapper.BuildQuestData(currQuest);
        j = 0;
        limitJ = ArraySize(this.m_QuestLists);
        while j < limitJ {
          if this.m_QuestLists[j].CanAddQuest(questData) {
            if !IsDefined(this.m_CurrentQuestData) {
              this.m_CurrentQuestData = questData;
              currEntry = this.m_CurrentQuestData.GetQuest();
              this.m_JournalWrapper.SetVisited(currEntry);
              questData.UpdateIsNew(false);
            };
            this.m_QuestLists[j].AddQuest(questData, Equals(this.m_CurrentQuestData.GetId(), questData.GetId()));
          } else {
            j += 1;
          };
        };
      };
      i += 1;
    };
  }

  private final func BuildQuestDetails() -> Void {
    let i: Int32;
    let linksData: array<wref<JournalEntry>>;
    let linksScriptableData: array<ref<IScriptable>>;
    if IsDefined(this.m_CurrentQuestData) {
      this.CreateQuestObjectives(this.m_CurrentQuestData);
      inkTextRef.SetText(this.m_QuestTitleRef, this.m_CurrentQuestData.GetTitle());
      linksData = this.m_CurrentQuestData.GetLinks();
      inkTextRef.SetText(this.m_QuestDescriptionRef, this.m_CurrentQuestData.GetDescription());
      this.m_CodexLinksListController.Clear();
      i = 0;
      while i < ArraySize(linksData) {
        ArrayPush(linksScriptableData, linksData[i]);
        i += 1;
      };
      this.m_CodexLinksListController.PushDataList(linksScriptableData, true);
      inkTextRef.SetText(this.m_recommendedLevel, ToString(this.m_CurrentQuestData.GetLevel()));
    } else {
      inkTextRef.SetText(this.m_QuestTitleRef, GetLocalizedText("LocKey#22226"));
      inkTextRef.SetText(this.m_QuestDescriptionRef, "");
      inkTextRef.SetText(this.m_recommendedLevel, "");
      this.m_CodexLinksListController.Clear();
      i = 0;
      while i < ArraySize(this.m_ObjectiveItems) {
        this.RemoveQuestObjective(i);
        i += 1;
      };
    };
  }

  private final func CreateQuestObjectives(currQuestData: ref<QuestDataWrapper>) -> Void {
    let targetParent: wref<inkCompoundWidget>;
    let questObjectives: array<ref<QuestObjectiveWrapper>> = currQuestData.GetObjectives();
    let i: Int32 = 0;
    let limit: Int32 = Max(ArraySize(questObjectives), ArraySize(this.m_ObjectiveItems));
    while i < limit {
      if i >= ArraySize(this.m_ObjectiveItems) {
        if questObjectives[i].IsActive() {
          this.AddQuestObjective();
        };
      };
      if i >= ArraySize(questObjectives) || !questObjectives[i].IsActive() {
        this.RemoveQuestObjective(i);
      } else {
        if questObjectives[i].IsActive() {
          this.m_ObjectiveItems[i].Setup(questObjectives[i], questObjectives[i].IsOptional());
          if !questObjectives[i].IsActive() {
            targetParent = inkWidgetRef.Get(this.m_ObjectivesListRef) as inkCompoundWidget;
          } else {
            if questObjectives[i].IsOptional() {
              targetParent = inkWidgetRef.Get(this.m_ObjectivesListRef) as inkCompoundWidget;
            } else {
              targetParent = inkWidgetRef.Get(this.m_ObjectivesListRef) as inkCompoundWidget;
            };
          };
          this.m_ObjectiveItems[i].Reparent(targetParent);
        };
      };
      i += 1;
    };
    inkWidgetRef.SetVisible(this.m_OptinalObjectivesGroupRef, inkCompoundRef.GetNumChildren(this.m_OptinalObjectivesListRef) > 0);
    inkWidgetRef.SetVisible(this.m_CompletedObjectivesGroupRef, inkCompoundRef.GetNumChildren(this.m_CompletedObjectivesListRef) > 0);
  }

  private final func RemoveQuestObjective(index: Int32) -> Void {
    this.m_ObjectiveItems[index].GetRootWidget().SetVisible(false);
    this.m_ObjectiveItems[index].Reparent(this.GetRootCompoundWidget());
  }

  private final func AddQuestObjective() -> Void {
    let currObjective: wref<ObjectiveController> = this.SpawnFromLocal(this.GetRootWidget(), this.m_ObjectiveViewName).GetControllerByType(n"ObjectiveController") as ObjectiveController;
    currObjective.RegisterToCallback(n"OnTrackingRequest", this, n"OnTrackingRequest");
    currObjective.GetRootWidget().SetVisible(false);
    ArrayPush(this.m_ObjectiveItems, currObjective);
  }

  protected cb func OnSetMenuEventDispatcher(menuEventDispatcher: wref<inkMenuEventDispatcher>) -> Bool {
    this.m_menuEventDispatcher = menuEventDispatcher;
    this.m_menuEventDispatcher.RegisterToEvent(n"OnBack", this, n"OnBack");
  }

  protected cb func OnBack(userData: ref<IScriptable>) -> Bool {
    if !StatusEffectSystem.ObjectHasStatusEffectWithTag(this.GetPlayerControlledObject(), n"LockInHubMenu") {
      this.m_menuEventDispatcher.SpawnEvent(n"OnCloseHubMenu");
    };
  }

  protected cb func OnUninitialize() -> Bool {
    this.m_codexButton.UnregisterFromCallback(n"OnRelease", this, n"OnCodexOpenButtonClicked");
    this.m_menuEventDispatcher.UnregisterFromEvent(n"OnBack", this, n"OnBack");
  }

  protected cb func OnActiveQuestChanged(widget: wref<inkWidget>) -> Bool {
    let questData: wref<JournalEntry>;
    let currLogic: wref<QuestListController> = widget.GetControllerByType(n"QuestListController") as QuestListController;
    if IsDefined(currLogic) {
      this.m_CurrentQuestData = currLogic.GetLastQuestData();
      questData = this.m_CurrentQuestData.GetQuest();
      this.m_JournalWrapper.SetVisited(questData);
      this.RefreshUI();
    };
  }

  protected cb func OnTrackingRequestEvent(evt: ref<QuestTrackingEvent>) -> Bool {
    this.m_JournalWrapper.SetTracking(evt.m_journalEntry);
    this.RefreshUI();
  }

  protected cb func OnTrackingRequest(widget: wref<inkWidget>) -> Bool {
    let currObjective: wref<ObjectiveController> = widget.GetControllerByType(n"ObjectiveController") as ObjectiveController;
    this.m_JournalWrapper.SetTracking(currObjective.GetToTrack().GetQuestObjective());
    this.RefreshUI();
    currObjective.SetState(n"Tracked");
  }

  protected cb func OnQuestHover(evt: ref<inkPointerEvent>) -> Bool {
    this.m_buttonHintsController.ClearButtonHints();
    this.m_buttonHintsController.AddButtonHint(EInputKey.IK_Pad_X_SQUARE, GetLocalizedText("UI-UserActions-Select"));
    this.m_buttonHintsController.AddButtonHint(EInputKey.IK_Pad_Y_TRIANGLE, GetLocalizedText("UI-UserActions-TrackObjective"));
    this.m_buttonHintsController.AddButtonHint(EInputKey.IK_Pad_B_CIRCLE, GetLocalizedText("Common-Access-Close"));
  }

  protected cb func OnObjectiveHover(evt: ref<inkPointerEvent>) -> Bool {
    this.m_buttonHintsController.ClearButtonHints();
    this.m_buttonHintsController.AddButtonHint(EInputKey.IK_Pad_X_SQUARE, GetLocalizedText("UI-UserActions-TrackObjective"));
    this.m_buttonHintsController.AddButtonHint(EInputKey.IK_Pad_B_CIRCLE, GetLocalizedText("Common-Access-Close"));
  }

  protected cb func OnHoverOut(evt: ref<inkPointerEvent>) -> Bool {
    this.m_buttonHintsController.ClearButtonHints();
    this.m_buttonHintsController.AddButtonHint(EInputKey.IK_Pad_B_CIRCLE, GetLocalizedText("Common-Access-Close"));
  }

  protected cb func OnCodexLinkClicked(index: Int32, target: ref<ListItemController>) -> Bool {
    this.OpenEntry(target.GetData() as JournalCodexEntry);
  }

  protected cb func OnCodexOpenButtonClicked(e: ref<inkPointerEvent>) -> Bool;

  private final func OpenEntry(entry: wref<JournalCodexEntry>) -> Void {
    inkWidgetRef.SetVisible(this.m_CodexButtonRef, true);
  }
}

public class CodexLinkQuestLog extends CodexImageButton {

  protected cb func OnInitialize() -> Bool {
    this.RegisterToCallback(n"OnDataChanged", this, n"OnDataChanged");
    super.OnInitialize();
  }

  protected cb func OnDataChanged(value: ref<IScriptable>) -> Bool {
    let data: wref<JournalCodexEntry> = value as JournalCodexEntry;
    if IsDefined(data) {
      inkTextRef.SetText(this.m_labelPathRef, data.GetTitle());
    } else {
      inkTextRef.SetText(this.m_labelPathRef, "### not found");
      LogUIError("selected entry not a JournalCodexEntry, check in journal, actual type=" + ToString(value.GetClassName()));
    };
  }
}
