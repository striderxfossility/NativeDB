
public class interactionWidgetGameController extends inkHUDGameController {

  private let m_root: wref<inkWidget>;

  private let m_titleLabel: wref<inkText>;

  private let m_titleBorder: wref<inkWidget>;

  private let m_optionsList: wref<inkHorizontalPanel>;

  private let m_widgetsPool: array<wref<inkWidget>>;

  private let m_widgetsCallbacks: array<ref<CallbackHandle>>;

  private let m_bbInteraction: wref<IBlackboard>;

  private let m_bbPlayerStateMachine: wref<IBlackboard>;

  private let m_bbInteractionDefinition: ref<UIInteractionsDef>;

  private let m_updateInteractionId: ref<CallbackHandle>;

  private let m_activeHubListenerId: ref<CallbackHandle>;

  private let m_contactsActiveListenerId: ref<CallbackHandle>;

  private let m_id: Int32;

  private let m_isActive: Bool;

  private let m_areContactsOpen: Bool;

  private let m_progressBarHolder: inkWidgetRef;

  private let m_progressBar: wref<DialogChoiceTimerController>;

  private let m_hasProgressBar: Bool;

  private let m_bb: wref<IBlackboard>;

  private let m_bbUIInteractionsDef: ref<UIInteractionsDef>;

  private let m_bbLastAttemptedChoiceCallbackId: ref<CallbackHandle>;

  private let m_OnZoneChangeCallback: ref<CallbackHandle>;

  private let m_pendingRequests: Int32;

  private let m_spawnTokens: array<wref<inkAsyncSpawnRequest>>;

  private let m_currentOptions: array<InteractionChoiceData>;

  protected cb func OnInitialize() -> Bool {
    this.m_root = this.GetRootWidget();
    this.m_titleLabel = this.GetWidget(n"titleCanvas\\titleFlex\\titleText") as inkText;
    this.m_titleBorder = this.GetWidget(n"titleCanvas\\titleFlex");
    this.m_optionsList = this.GetWidget(n"optionsList") as inkHorizontalPanel;
    this.m_root.SetVisible(false);
    this.m_bbPlayerStateMachine = this.GetPSMBlackboard(this.GetOwnerEntity() as PlayerPuppet);
    this.m_bbInteractionDefinition = GetAllBlackboardDefs().UIInteractions;
    this.m_bbInteraction = this.GetBlackboardSystem().Get(this.m_bbInteractionDefinition);
    this.m_updateInteractionId = this.m_bbInteraction.RegisterDelayedListenerVariant(this.m_bbInteractionDefinition.InteractionChoiceHub, this, n"OnUpdateInteraction");
    this.m_activeHubListenerId = this.m_bbInteraction.RegisterDelayedListenerVariant(this.m_bbInteractionDefinition.VisualizersInfo, this, n"OnChangeActiveVisualizer");
    if IsDefined(this.m_bbPlayerStateMachine) {
      this.m_OnZoneChangeCallback = this.m_bbPlayerStateMachine.RegisterDelayedListenerInt(GetAllBlackboardDefs().PlayerStateMachine.Zones, this, n"OnZoneChange");
    };
    this.m_bbUIInteractionsDef = GetAllBlackboardDefs().UIInteractions;
    this.m_bb = this.GetBlackboardSystem().Get(this.m_bbUIInteractionsDef);
    this.m_bbLastAttemptedChoiceCallbackId = this.m_bb.RegisterListenerVariant(this.m_bbUIInteractionsDef.LastAttemptedChoice, this, n"OnLastAttemptedChoice");
    this.m_id = 0;
    this.OnChangeActiveVisualizer(this.m_bbInteraction.GetVariant(this.m_bbInteractionDefinition.VisualizersInfo));
    if IsDefined(this.m_bbPlayerStateMachine) {
      this.OnZoneChange(this.m_bbPlayerStateMachine.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Zones));
    };
    this.OnUpdateInteraction(this.m_bbInteraction.GetVariant(this.m_bbInteractionDefinition.InteractionChoiceHub));
  }

  protected cb func OnUninitialize() -> Bool {
    if IsDefined(this.m_bbInteraction) {
      this.m_bbInteraction.UnregisterDelayedListener(this.m_bbInteractionDefinition.InteractionChoiceHub, this.m_updateInteractionId);
      this.m_bbInteraction.UnregisterDelayedListener(this.m_bbInteractionDefinition.ActiveChoiceHubID, this.m_activeHubListenerId);
    };
    if IsDefined(this.m_bbLastAttemptedChoiceCallbackId) {
      this.m_bb.UnregisterListenerVariant(this.m_bbUIInteractionsDef.LastAttemptedChoice, this.m_bbLastAttemptedChoiceCallbackId);
    };
  }

  protected cb func OnLastAttemptedChoice(value: Variant) -> Bool {
    let curChoiceLogicController: ref<interactionItemLogicController>;
    let choiceData: InteractionAttemptedChoice = FromVariant(value);
    if choiceData.choiceIdx >= 0 && choiceData.choiceIdx < ArraySize(this.m_widgetsPool) {
      curChoiceLogicController = this.m_widgetsPool[choiceData.choiceIdx].GetController() as interactionItemLogicController;
    };
    if IsDefined(curChoiceLogicController) {
      if choiceData.isSuccess && Equals(choiceData.visualizerType, EVisualizerType.Device) {
        curChoiceLogicController.PlayLibraryAnimation(n"success");
      } else {
        if !choiceData.isSuccess && Equals(choiceData.visualizerType, EVisualizerType.Device) {
          curChoiceLogicController.PlayLibraryAnimation(n"fail");
        };
      };
    };
  }

  private final func GetOwner() -> ref<GameObject> {
    let owner: ref<GameObject> = this.GetOwnerEntity() as GameObject;
    return owner;
  }

  protected cb func OnUpdateInteraction(argValue: Variant) -> Bool {
    let count: Int32;
    let curSpawnRequest: wref<inkAsyncSpawnRequest>;
    let currentItem: wref<inkWidget>;
    let timedDuration: Float;
    let timedProgress: Float;
    let isTimed: Bool = false;
    let data: InteractionChoiceHubData = FromVariant(argValue);
    this.m_id = data.id;
    if data.active {
      this.m_currentOptions = data.choices;
      this.m_titleBorder.SetVisible(StrLen(data.title) > 0 && NotEquals(data.title, " "));
      this.m_titleLabel.SetLetterCase(textLetterCase.UpperCase);
      this.m_titleLabel.SetText(data.title);
      count = ArraySize(this.m_currentOptions);
      while this.m_pendingRequests > 0 && ArraySize(this.m_widgetsPool) + this.m_pendingRequests > count {
        curSpawnRequest = ArrayPop(this.m_spawnTokens);
        if IsDefined(curSpawnRequest) {
          curSpawnRequest.Cancel();
          this.m_pendingRequests -= 1;
        };
      };
      while ArraySize(this.m_widgetsPool) > count {
        currentItem = ArrayPop(this.m_widgetsPool);
        ArrayPop(this.m_widgetsCallbacks);
        this.m_optionsList.RemoveChild(currentItem);
      };
      while ArraySize(this.m_widgetsPool) + this.m_pendingRequests < count {
        curSpawnRequest = this.AsyncSpawnFromLocal(this.m_optionsList, n"choice", this, n"OnItemSpawned");
        ArrayPush(this.m_spawnTokens, curSpawnRequest);
        this.m_pendingRequests += 1;
      };
      if this.m_pendingRequests <= 0 {
        this.UpadateChoiceData();
      };
      if IsDefined(data.timeProvider) {
        isTimed = true;
        timedProgress = data.timeProvider.GetCurrentProgress();
        timedDuration = data.timeProvider.GetDuration();
      };
      if isTimed {
        if !this.m_hasProgressBar {
          this.m_hasProgressBar = true;
          this.m_progressBar = this.SpawnFromExternal(inkWidgetRef.Get(this.m_progressBarHolder), r"base\\gameplay\\gui\\widgets\\interactions\\dialog.inkwidget", n"progress_bar").GetController() as DialogChoiceTimerController;
          this.m_progressBar.StartProgressBarAnim(timedDuration, timedProgress);
        };
      };
    };
    if (!isTimed || !data.active) && this.m_hasProgressBar {
      this.m_hasProgressBar = false;
      this.GetRootCompoundWidget().RemoveChild(this.m_progressBar.GetRootWidget());
    };
    this.m_root.SetVisible(data.active);
  }

  protected cb func OnItemSpawned(newItem: ref<inkWidget>, userData: ref<IScriptable>) -> Bool {
    let newItemCallback: ref<CallbackHandle> = this.m_bbPlayerStateMachine.RegisterDelayedListenerInt(GetAllBlackboardDefs().PlayerStateMachine.Zones, newItem, n"OnZoneChange");
    ArrayPush(this.m_widgetsPool, newItem);
    ArrayPush(this.m_widgetsCallbacks, newItemCallback);
    this.m_pendingRequests -= 1;
    if this.m_pendingRequests <= 0 {
      ArrayClear(this.m_spawnTokens);
      this.UpadateChoiceData();
    };
  }

  private final func UpadateChoiceData() -> Void {
    let curLogicControler: ref<interactionItemLogicController>;
    let skillCheck: UIInteractionSkillCheck;
    let count: Int32 = ArraySize(this.m_currentOptions);
    let i: Int32 = 0;
    while i < count {
      curLogicControler = this.m_widgetsPool[i].GetController() as interactionItemLogicController;
      if this.GetSkillcheck(this.m_currentOptions[i], skillCheck) {
        curLogicControler.SetData(this.m_currentOptions[i], skillCheck);
      } else {
        curLogicControler.SetData(this.m_currentOptions[i]);
      };
      curLogicControler.SetButtonVisibility(this.m_isActive && !this.m_areContactsOpen);
      i += 1;
    };
  }

  private final func GetSkillchecks(choiceHubData: InteractionChoiceHubData) -> array<UIInteractionSkillCheck> {
    let action: ref<DeviceAction>;
    let k: Int32;
    let skillCheckAction: ref<ActionSkillCheck>;
    let skillChecks: array<UIInteractionSkillCheck>;
    let i: Int32 = 0;
    while i < ArraySize(choiceHubData.choices) {
      k = 0;
      while k < ArraySize(choiceHubData.choices[i].data) {
        action = FromVariant(choiceHubData.choices[i].data[k]);
        skillCheckAction = action as ActionSkillCheck;
        if skillCheckAction != null {
          ArrayPush(skillChecks, skillCheckAction.GetSkillcheckInfo());
        };
        k += 1;
      };
      i += 1;
    };
    return skillChecks;
  }

  private final func GetSkillcheck(choice: InteractionChoiceData, out skillcheck: UIInteractionSkillCheck) -> Bool {
    let action: ref<DeviceAction>;
    let skillCheckAction: ref<ActionSkillCheck>;
    let i: Int32 = 0;
    while i < ArraySize(choice.data) {
      action = FromVariant(choice.data[i]);
      skillCheckAction = action as ActionSkillCheck;
      if skillCheckAction != null {
        skillcheck = skillCheckAction.GetSkillcheckInfo();
        return true;
      };
      i += 1;
    };
    return false;
  }

  protected cb func OnZoneChange(value: Int32) -> Bool {
    let currLogic: ref<interactionItemLogicController>;
    let widgetCount: Int32 = ArraySize(this.m_widgetsPool);
    let i: Int32 = 0;
    while i < widgetCount {
      currLogic = this.m_widgetsPool[i].GetController() as interactionItemLogicController;
      currLogic.SetZoneChange(value);
      i += 1;
    };
  }

  protected cb func OnChangeActiveVisualizer(value: Variant) -> Bool {
    let info: VisualizersInfo = FromVariant(value);
    this.m_isActive = this.m_isActive && info.activeVisId == -1 || info.activeVisId == this.m_id;
    this.UpdateVisibility();
  }

  private final func UpdateVisibility() -> Void {
    let currLogic: ref<interactionItemLogicController>;
    let widgetCount: Int32 = ArraySize(this.m_widgetsPool);
    let i: Int32 = 0;
    while i < widgetCount {
      currLogic = this.m_widgetsPool[i].GetController() as interactionItemLogicController;
      currLogic.SetButtonVisibility(this.m_isActive && !this.m_areContactsOpen);
      i += 1;
    };
  }
}
