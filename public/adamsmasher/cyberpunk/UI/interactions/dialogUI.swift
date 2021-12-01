
public class dialogWidgetGameController extends InteractionUIBase {

  private let m_root: wref<inkCanvas>;

  private edit let m_hubsContainer: inkBasePanelRef;

  private let m_hubControllers: array<wref<DialogHubLogicController>>;

  private let m_activeHubController: wref<DialogHubLogicController>;

  private let m_data: DialogChoiceHubs;

  @default(dialogWidgetGameController, -1)
  private let m_activeHubID: Int32;

  private let m_prevActiveHubID: Int32;

  @default(dialogWidgetGameController, 0)
  private let m_selectedIndex: Int32;

  @default(dialogWidgetGameController, 0.5)
  private let m_fadeAnimTime: Float;

  @default(dialogWidgetGameController, 1.0)
  private let m_fadeDelay: Float;

  private let m_dialogFocusInputHintShown: Bool;

  private let m_hubAvailable: Bool;

  private let m_animCloseHudProxy: ref<inkAnimProxy>;

  public let currentFadeItem: wref<DialogHubLogicController>;

  private let blackboard: wref<IBlackboard>;

  private let uiSystemBB: ref<UI_SystemDef>;

  private let uiSystemId: ref<CallbackHandle>;

  protected cb func OnInitialize() -> Bool {
    super.OnInitialize();
    this.m_root = this.GetRootWidget() as inkCanvas;
    this.blackboard = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UI_System);
    this.uiSystemBB = GetAllBlackboardDefs().UI_System;
    this.uiSystemId = this.blackboard.RegisterListenerBool(this.uiSystemBB.IsInMenu, this, n"OnMenuVisibilityChange");
  }

  protected cb func OnUninitialize() -> Bool {
    if IsDefined(this.uiSystemId) {
      this.blackboard.UnregisterListenerBool(this.uiSystemBB.IsInMenu, this.uiSystemId);
    };
    super.OnUninitialize();
  }

  protected func UpdateDialogsData(data: DialogChoiceHubs) -> Void {
    this.m_data = data;
  }

  protected cb func OnDialogsActivateHub(activeHubId: Int32) -> Bool {
    if this.m_activeHubID != activeHubId {
      this.m_prevActiveHubID = this.m_activeHubID;
      this.m_activeHubID = activeHubId;
    };
    super.OnDialogsActivateHub(activeHubId);
  }

  protected cb func OnDialogsSelectIndex(index: Int32) -> Bool {
    this.m_selectedIndex = index;
    super.OnDialogsSelectIndex(index);
  }

  protected func OnInteractionsChanged() -> Void {
    let currentInd: Int32;
    let currentItem: wref<DialogHubLogicController>;
    let hasAboveElements: Bool;
    let hasBelowElements: Bool;
    let hubData: ListChoiceHubData;
    let i: Int32;
    let totalCountAcrossHubs: Int32;
    let hubsListData: array<ListChoiceHubData> = this.m_data.choiceHubs;
    let count: Int32 = ArraySize(hubsListData);
    this.AdjustHubsCount(count);
    totalCountAcrossHubs = 0;
    i = 0;
    while i < count {
      totalCountAcrossHubs += ArraySize(hubsListData[i].choices);
      i += 1;
    };
    this.m_hubAvailable = false;
    currentInd = 0;
    i = 0;
    while i < count {
      currentItem = this.m_hubControllers[i];
      hubData = hubsListData[i];
      hasAboveElements = i != 0 || this.m_AreInteractionsOpen || this.m_IsLootingOpen;
      hasBelowElements = i != count - 1 || this.m_AreContactsOpen;
      currentItem.SetData(hubData, hubData.id == this.m_activeHubID, this.m_selectedIndex, hasAboveElements, hasBelowElements, currentInd, totalCountAcrossHubs);
      currentInd += ArraySize(hubData.choices);
      if !this.m_hubAvailable {
        this.m_hubAvailable = true;
      };
      i += 1;
    };
    if count > 0 {
      this.m_hubControllers[0].OverrideInputButton(this.m_activeHubID == -1);
    };
    if IsDefined(this.m_root) {
      this.m_root.SetVisible(this.m_AreDialogsOpen);
    };
  }

  private final func AdjustHubsCount(count: Int32) -> Void {
    let currentItem: wref<DialogHubLogicController>;
    while ArraySize(this.m_hubControllers) > count {
      currentItem = ArrayPop(this.m_hubControllers);
      inkCompoundRef.RemoveChild(this.m_hubsContainer, currentItem.GetRootWidget());
    };
    while ArraySize(this.m_hubControllers) < count {
      currentItem = this.SpawnFromLocal(inkWidgetRef.Get(this.m_hubsContainer), n"hub").GetController() as DialogHubLogicController;
      ArrayPush(this.m_hubControllers, currentItem);
    };
  }

  private final func CloseDelayed(hudController: wref<DialogHubLogicController>) -> Void {
    let animDef: ref<inkAnimDef>;
    let opacityInterp: ref<inkAnimTransparency>;
    this.currentFadeItem = hudController;
    if this.m_animCloseHudProxy.IsPlaying() {
      return;
    };
    if this.m_animCloseHudProxy.IsPlaying() {
      this.m_animCloseHudProxy.Stop();
    };
    animDef = new inkAnimDef();
    opacityInterp = new inkAnimTransparency();
    opacityInterp.SetStartDelay(this.m_fadeDelay);
    opacityInterp.SetStartTransparency(1.00);
    opacityInterp.SetEndTransparency(0.00);
    opacityInterp.SetDuration(this.m_fadeAnimTime);
    animDef.AddInterpolator(opacityInterp);
    this.m_animCloseHudProxy = hudController.GetRootWidget().PlayAnimation(animDef);
    this.m_animCloseHudProxy.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnFinish");
    hudController.FadeOutItems(this.m_fadeAnimTime);
  }

  protected cb func OnFinish(proxy: ref<inkAnimProxy>) -> Bool {
    this.m_animCloseHudProxy.UnregisterFromCallback(inkanimEventType.OnFinish, this, n"OnFinish");
    inkCompoundRef.RemoveChild(this.m_hubsContainer, this.currentFadeItem.GetRootWidget());
    this.m_animCloseHudProxy.Stop();
  }

  protected cb func OnMenuVisibilityChange(isMenuVisible: Bool) -> Bool {
    let controller: ref<DialogHubLogicController>;
    let hubsListData: array<ListChoiceHubData> = this.m_data.choiceHubs;
    let count: Int32 = ArraySize(hubsListData);
    let i: Int32 = 0;
    while i < count {
      controller = this.m_hubControllers[i];
      if IsDefined(controller) {
        controller.OnMenuVisibilityChange(isMenuVisible);
      };
      i += 1;
    };
  }
}

public class DialogHubLogicController extends inkLogicController {

  public edit let m_progressBarHolder: inkWidgetRef;

  public edit let m_selectionSizeProviderRef: inkWidgetRef;

  public edit let m_selectionRoot: inkWidgetRef;

  @default(DialogHubLogicController, 0.09f)
  public edit let m_moveAnimTime: Float;

  private let m_rootWidget: wref<inkWidget>;

  private let m_possessedDialogFluff: wref<inkWidget>;

  private let m_titleWidget: wref<inkText>;

  private let m_titleBorder: wref<inkWidget>;

  private let m_titleContainer: wref<inkCompoundWidget>;

  private let m_mainVert: wref<inkCompoundWidget>;

  private let m_id: Int32;

  @default(DialogHubLogicController, false)
  private let m_isSelected: Bool;

  private let m_data: ListChoiceHubData;

  private let m_itemControllers: array<wref<DialogChoiceLogicController>>;

  private let m_progressBar: wref<DialogChoiceTimerController>;

  @default(DialogHubLogicController, false)
  private let m_hasProgressBar: Bool;

  @default(DialogHubLogicController, false)
  private let m_wasTimmed: Bool;

  private let m_isClosingDelayed: Bool;

  private let m_lastSelectedIdx: Int32;

  @default(DialogHubLogicController, 0.1)
  private let m_inActiveTransparency: Float;

  private let m_animSelectMarginProxy: ref<inkAnimProxy>;

  private let m_animSelectSizeProxy: ref<inkAnimProxy>;

  private let m_animSelectMargin: ref<inkAnimDef>;

  private let m_animSelectSize: ref<inkAnimDef>;

  private let m_animfFadingOutProxy: ref<inkAnimProxy>;

  public let selectBgSizeInterp: ref<inkAnimSize>;

  public let selectBgMarginInterp: ref<inkAnimMargin>;

  private let m_dialogHubData: DialogHubData;

  private let m_pendingRequests: Int32;

  private let m_spawnTokens: array<wref<inkAsyncSpawnRequest>>;

  protected cb func OnInitialize() -> Bool {
    this.m_rootWidget = this.GetRootWidget();
    this.m_titleWidget = this.GetWidget(n"dpadFlex\\titleFlex\\mainTitle") as inkText;
    this.m_possessedDialogFluff = this.GetWidget(n"dpadFlex\\titleFlex\\possessedDialogBorder");
    this.m_titleBorder = this.GetWidget(n"dpadFlex\\titleFlex\\mainTitleBorder");
    this.m_mainVert = this.GetWidget(n"mainVerticalContainer") as inkCompoundWidget;
    this.m_titleContainer = this.GetWidget(n"dpadFlex\\titleFlex") as inkCompoundWidget;
    this.m_rootWidget.SetOpacity(1.00);
  }

  public final func OnMenuVisibilityChange(isMenuVisible: Bool) -> Void {
    if IsDefined(this.m_progressBar) {
      this.m_progressBar.OnMenuVisibilityChange(isMenuVisible);
    };
  }

  public final func SetData(value: ListChoiceHubData, isSelected: Bool, selectedInd: Int32, hasAboveElements: Bool, hasBelowElements: Bool, currentNum: Int32, argTotalCountAcrossHubs: Int32) -> Void {
    let curSpawnRequest: wref<inkAsyncSpawnRequest>;
    let currentItem: wref<DialogChoiceLogicController>;
    this.m_data = value;
    this.m_id = this.m_data.id;
    let count: Int32 = ArraySize(this.m_data.choices);
    this.m_dialogHubData.m_isSelected = isSelected;
    this.m_dialogHubData.m_selectedInd = selectedInd;
    this.m_dialogHubData.m_hasAboveElements = hasAboveElements;
    this.m_dialogHubData.m_hasBelowElements = hasBelowElements;
    this.m_dialogHubData.m_currentNum = currentNum;
    this.m_dialogHubData.m_argTotalCountAcrossHubs = argTotalCountAcrossHubs;
    if this.m_isClosingDelayed {
      return;
    };
    while this.m_pendingRequests > 0 && ArraySize(this.m_itemControllers) + this.m_pendingRequests > count {
      curSpawnRequest = ArrayPop(this.m_spawnTokens);
      if IsDefined(curSpawnRequest) {
        curSpawnRequest.Cancel();
        this.m_pendingRequests -= 1;
      };
    };
    while ArraySize(this.m_itemControllers) > count {
      currentItem = ArrayPop(this.m_itemControllers);
      this.m_mainVert.RemoveChild(currentItem.GetRootWidget());
    };
    while ArraySize(this.m_itemControllers) + this.m_pendingRequests < count {
      curSpawnRequest = this.AsyncSpawnFromLocal(this.m_mainVert, n"item", this, n"OnItemSpawned");
      ArrayPush(this.m_spawnTokens, curSpawnRequest);
      this.m_pendingRequests += 1;
    };
    if this.m_pendingRequests <= 0 {
      this.UpdateDialogHubData();
    };
  }

  protected cb func OnItemSpawned(newItem: ref<inkWidget>, userData: ref<IScriptable>) -> Bool {
    let currentItem: wref<DialogChoiceLogicController> = newItem.GetController() as DialogChoiceLogicController;
    ArrayPush(this.m_itemControllers, currentItem);
    this.m_pendingRequests -= 1;
    if this.m_pendingRequests <= 0 {
      this.UpdateDialogHubData();
      ArrayClear(this.m_spawnTokens);
    };
  }

  private final func UpdateDialogHubData() -> Void {
    let currListChoiceData: ListChoiceData;
    let currentItem: wref<DialogChoiceLogicController>;
    let localizedText: String;
    let tags: String;
    let timedDuration: Float;
    let timedProgress: Float;
    let isPossessed: Bool = false;
    let isTimed: Bool = false;
    let count: Int32 = ArraySize(this.m_data.choices);
    let i: Int32 = 0;
    while i < count {
      currentItem = this.m_itemControllers[i];
      currListChoiceData = this.m_data.choices[i];
      tags = GetCaptionTagsFromArray(currListChoiceData.captionParts.parts);
      localizedText = currListChoiceData.localizedName;
      if Equals(tags, "") {
        currentItem.SetText(localizedText, ChoiceTypeWrapper.IsType(currListChoiceData.type, gameinteractionsChoiceType.Inactive));
      } else {
        currentItem.SetText("[" + tags + "] " + localizedText, ChoiceTypeWrapper.IsType(currListChoiceData.type, gameinteractionsChoiceType.Inactive));
      };
      currentItem.SetType(currListChoiceData.type);
      currentItem.SetDedicatedInput(currListChoiceData.inputActionName);
      currentItem.SetIsPhoneLockActive(this.m_data.isPhoneLockActive);
      currentItem.SetDimmed(ChoiceTypeWrapper.IsType(currListChoiceData.type, gameinteractionsChoiceType.Inactive) || ChoiceTypeWrapper.IsType(currListChoiceData.type, gameinteractionsChoiceType.CheckFailed) || !ChoiceTypeWrapper.IsType(currListChoiceData.type, gameinteractionsChoiceType.QuestImportant) && ChoiceTypeWrapper.IsType(currListChoiceData.type, gameinteractionsChoiceType.AlreadyRead));
      currentItem.SetSelected(this.m_dialogHubData.m_isSelected && this.m_dialogHubData.m_selectedInd == i);
      currentItem.SetData(this.m_dialogHubData.m_currentNum + i, this.m_dialogHubData.m_argTotalCountAcrossHubs, this.m_dialogHubData.m_hasAboveElements, this.m_dialogHubData.m_hasBelowElements);
      if ChoiceTypeWrapper.IsType(currListChoiceData.type, gameinteractionsChoiceType.PossessedDialog) {
        isPossessed = true;
      };
      if IsDefined(currListChoiceData.timeProvider) {
        isTimed = !this.m_dialogHubData.m_hasAboveElements;
        timedProgress = currListChoiceData.timeProvider.GetCurrentProgress();
        timedDuration = currListChoiceData.timeProvider.GetDuration();
      };
      if IsDefined(this.m_data.timeProvider) {
        isTimed = !this.m_dialogHubData.m_hasAboveElements;
        timedProgress = this.m_data.timeProvider.GetCurrentProgress();
        timedDuration = this.m_data.timeProvider.GetDuration();
      };
      currentItem.SetCaptionParts(currListChoiceData.captionParts.parts);
      currentItem.UpdateView();
      currentItem.AnimateSelection();
      if !this.m_dialogHubData.m_isSelected {
        currentItem.SetSelected(false);
      };
      i += 1;
    };
    this.SetupTimeBar(isTimed, timedDuration, timedProgress);
    this.m_rootWidget.SetOpacity(1.00);
    this.SetupTitle(this.m_data.title, this.m_dialogHubData.m_isSelected, isPossessed);
    this.m_isSelected = this.m_dialogHubData.m_isSelected;
    this.m_lastSelectedIdx = this.m_dialogHubData.m_selectedInd;
  }

  public final func FadeOutItems(fadeOutTime: Float) -> Void {
    let count: Int32;
    let i: Int32;
    if this.m_isClosingDelayed {
      return;
    };
    this.m_isClosingDelayed = true;
    count = ArraySize(this.m_itemControllers);
    if count == 1 {
      this.m_itemControllers[i].SetSelected(true);
    };
    i = 0;
    while i < count {
      if this.m_lastSelectedIdx == i {
        this.m_itemControllers[i].SetSelected(true);
      };
      this.m_itemControllers[i].FadeOut(fadeOutTime);
      i += 1;
    };
  }

  public final func GetId() -> Int32 {
    return this.m_id;
  }

  public final func OverrideInputButton(overrideButton: Bool) -> Void {
    if ArraySize(this.m_itemControllers) > 0 {
      this.m_itemControllers[0].OverrideInputButton(overrideButton);
    };
  }

  public final func WasTimed() -> Bool {
    return this.m_wasTimmed;
  }

  private final func SetupTimeBar(isActive: Bool, timedDuration: Float, timedProgress: Float) -> Void {
    let timerParent: ref<inkCompoundWidget>;
    if isActive {
      if !this.m_hasProgressBar {
        this.m_hasProgressBar = true;
        this.m_wasTimmed = true;
        this.m_progressBar = this.SpawnFromLocal(inkWidgetRef.Get(this.m_progressBarHolder), n"progress_bar").GetController() as DialogChoiceTimerController;
        this.m_progressBar.StartProgressBarAnim(timedDuration, timedProgress);
      };
    } else {
      if this.m_hasProgressBar {
        timerParent = inkWidgetRef.Get(this.m_progressBarHolder) as inkCompoundWidget;
        this.m_hasProgressBar = false;
        timerParent.RemoveChild(this.m_progressBar.GetRootWidget());
      };
    };
  }

  private final func SetupTitle(title: String, isActive: Bool, isPossessed: Bool) -> Void {
    this.m_titleContainer.SetVisible(true);
    this.m_titleWidget.SetLetterCase(textLetterCase.UpperCase);
    this.m_titleWidget.SetText(title);
    this.m_titleContainer.SetState(isActive && isPossessed ? n"PossessedDialog" : n"Default");
    this.m_titleBorder.SetVisible(isActive && !isPossessed && StrLen(title) > 0 && NotEquals(title, " "));
    this.m_possessedDialogFluff.SetVisible(isPossessed);
  }
}

public class DialogChoiceLogicController extends inkLogicController {

  private edit let m_InputViewRef: inkWidgetRef;

  private edit let m_VerticalLineWidget: inkWidgetRef;

  private edit let m_ActiveTextRef: inkTextRef;

  private edit let m_InActiveTextRef: inkTextRef;

  private edit let m_InActiveTextRootRef: inkWidgetRef;

  private edit let m_TextFlexRef: inkWidgetRef;

  private edit let m_SelectedBgRef: inkWidgetRef;

  private edit let m_SelectedBgRefJohnny: inkWidgetRef;

  private edit let m_CaptionHolder: inkCompoundRef;

  private edit let m_SecondaryCaptionHolder: inkCompoundRef;

  private edit let m_RootWidget: wref<inkCompoundWidget>;

  @default(DialogChoiceLogicController, 0.15)
  private edit let m_AnimationTime: Float;

  @default(DialogChoiceLogicController, 500.0f)
  private edit let m_AnimationSpeed: Float;

  @default(DialogChoiceLogicController, false)
  private edit let m_UseConstantSpeed: Bool;

  private edit let m_phoneIcon: inkWidgetRef;

  private let m_TextFlex: wref<inkWidget>;

  private let m_InActiveTextRoot: wref<inkWidget>;

  private let m_SelectedBg: wref<inkWidget>;

  private let m_SelectedBgJohnny: wref<inkWidget>;

  private let m_InputView: wref<InteractionsInputView>;

  private let m_CaptionControllers: array<wref<CaptionImageIconsLogicController>>;

  private let m_SecondaryCaptionControllers: array<wref<CaptionImageIconsLogicController>>;

  private let m_type: ChoiceTypeWrapper;

  @default(DialogChoiceLogicController, false)
  private let m_isSelected: Bool;

  private let m_prevIsSelected: Bool;

  private let m_hasDedicatedInput: Bool;

  private let m_overriddenInput: Bool;

  @default(DialogChoiceLogicController, false)
  private let m_isPreserveSelectionFadeOut: Bool;

  private let m_isPhoneLockActive: Bool;

  private let m_dedicatedInputName: CName;

  private let m_Active: CName;

  private let m_Inactive: CName;

  private let m_Black: CName;

  private let m_questColor: CName;

  private let m_possessedDialog: CName;

  @default(DialogChoiceLogicController, 3)
  private const let m_ControllerPromptLimit: Int32;

  @default(DialogChoiceLogicController, 0.1)
  private let m_fadingOptionEndTransparency: Float;

  private let m_animSelectedBgProxy: ref<inkAnimProxy>;

  private let m_animSelectedJohnnyBgProxy: ref<inkAnimProxy>;

  private let m_animActiveTextProxy: ref<inkAnimProxy>;

  private let m_animfFadingOutProxy: ref<inkAnimProxy>;

  private let m_animIntroProxy: ref<inkAnimProxy>;

  protected cb func OnInitialize() -> Bool {
    this.m_RootWidget = this.GetRootCompoundWidget();
    this.m_InputView = inkWidgetRef.GetController(this.m_InputViewRef) as InteractionsInputView;
    this.m_InActiveTextRoot = inkWidgetRef.Get(this.m_InActiveTextRootRef);
    this.m_TextFlex = inkWidgetRef.Get(this.m_TextFlexRef);
    this.m_SelectedBg = inkWidgetRef.Get(this.m_SelectedBgRef);
    this.m_SelectedBgJohnny = inkWidgetRef.Get(this.m_SelectedBgRefJohnny);
    this.m_Active = n"Active";
    this.m_Black = n"Black";
    this.m_questColor = n"Quest";
    this.m_possessedDialog = n"PossessedDialog";
    this.m_Inactive = n"Inactive";
    this.m_animIntroProxy = this.PlayLibraryAnimation(n"line_intro");
  }

  public final func SetText(value: String, isFailed: Bool) -> Void {
    inkTextRef.SetText(this.m_ActiveTextRef, value);
    inkWidgetRef.SetOpacity(this.m_ActiveTextRef, isFailed ? 1.00 : 1.00);
  }

  public final func SetDedicatedInput(value: CName) -> Void {
    this.m_hasDedicatedInput = NotEquals(value, n"") && NotEquals(value, n"");
    this.m_dedicatedInputName = value;
  }

  public final func SetIsPhoneLockActive(value: Bool) -> Void {
    this.m_isPhoneLockActive = value;
  }

  public final func SetType(value: ChoiceTypeWrapper) -> Void {
    this.m_type = value;
  }

  public final func SetSelected(isSelected: Bool) -> Void {
    this.m_prevIsSelected = this.m_isSelected;
    this.m_isSelected = isSelected;
  }

  public final func SetData(currentNum: Int32, allItemsNum: Int32, hasAbove: Bool, hasBelow: Bool) -> Void {
    this.m_InputView.Setup(currentNum, allItemsNum, hasAbove, hasBelow);
    this.UpdateView();
  }

  public final func OverrideInputButton(overrideButton: Bool) -> Void {
    this.m_overriddenInput = overrideButton;
    this.UpdateView();
  }

  public final func FadeOut(fadeOutTime: Float) -> Void {
    this.m_isPreserveSelectionFadeOut = true;
    if this.m_prevIsSelected || this.m_isSelected {
      if this.m_animActiveTextProxy.IsPlaying() {
        this.m_animActiveTextProxy.Stop();
      };
      if this.m_animSelectedBgProxy.IsPlaying() {
        this.m_animSelectedBgProxy.Stop();
      };
      if IsDefined(this.m_animSelectedJohnnyBgProxy) && this.m_animSelectedJohnnyBgProxy.IsPlaying() {
        this.m_animSelectedJohnnyBgProxy.Stop();
      };
      this.Fade(this.m_RootWidget.GetOpacity(), 1.00, 0.22);
      return;
    };
    this.Fade(this.m_RootWidget.GetOpacity(), 0.01, fadeOutTime);
  }

  public final func SetFadingState(isFading: Bool, timedDuration: Float, timedProgress: Float, progressBar: wref<inkWidget>) -> Void {
    if isFading {
      this.Fade(1.00 - timedProgress, 0.00, timedDuration * (1.00 - timedProgress));
      progressBar.SetVisible(false);
    };
  }

  private final func Fade(startValue: Float, endValue: Float, fadeOutTime: Float) -> Void {
    let animFadeOut: ref<inkAnimDef>;
    let animTransparencyInterp: ref<inkAnimTransparency>;
    if this.m_animfFadingOutProxy.IsPlaying() {
      this.m_animfFadingOutProxy.Stop();
    };
    animFadeOut = new inkAnimDef();
    animTransparencyInterp = new inkAnimTransparency();
    animTransparencyInterp.SetStartDelay(0.00);
    animTransparencyInterp.SetStartTransparency(startValue);
    animTransparencyInterp.SetEndTransparency(endValue);
    animTransparencyInterp.SetDuration(fadeOutTime);
    animFadeOut.AddInterpolator(animTransparencyInterp);
    this.m_animfFadingOutProxy = this.m_RootWidget.PlayAnimation(animFadeOut);
  }

  private final func ResizeCaptionParts(newSize: Int32) -> Void {
    let controller: wref<CaptionImageIconsLogicController>;
    let currentSize: Int32 = ArraySize(this.m_CaptionControllers);
    if currentSize < newSize {
      while ArraySize(this.m_CaptionControllers) < newSize {
        controller = this.SpawnFromLocal(inkWidgetRef.Get(this.m_CaptionHolder), n"CaptionImageItems").GetController() as CaptionImageIconsLogicController;
        ArrayPush(this.m_CaptionControllers, controller);
      };
      while ArraySize(this.m_SecondaryCaptionControllers) < newSize {
        controller = this.SpawnFromLocal(inkWidgetRef.Get(this.m_SecondaryCaptionHolder), n"CaptionImageItems").GetController() as CaptionImageIconsLogicController;
        ArrayPush(this.m_SecondaryCaptionControllers, controller);
      };
    };
    if currentSize > newSize {
      if newSize == 0 {
        ArrayClear(this.m_CaptionControllers);
        inkCompoundRef.RemoveAllChildren(this.m_CaptionHolder);
        ArrayClear(this.m_SecondaryCaptionControllers);
        inkCompoundRef.RemoveAllChildren(this.m_SecondaryCaptionHolder);
      } else {
        while ArraySize(this.m_CaptionControllers) > newSize {
          ArrayPop(this.m_CaptionControllers);
          inkCompoundRef.RemoveChildByIndex(this.m_CaptionHolder, ArraySize(this.m_CaptionControllers));
        };
        while ArraySize(this.m_SecondaryCaptionControllers) > newSize {
          ArrayPop(this.m_SecondaryCaptionControllers);
          inkCompoundRef.RemoveChildByIndex(this.m_SecondaryCaptionHolder, ArraySize(this.m_SecondaryCaptionControllers));
        };
      };
    };
  }

  public final func SetCaptionParts(argList: array<ref<InteractionChoiceCaptionPart>>) -> Void {
    let currBluelineHolder: wref<InteractionChoiceCaptionBluelinePart>;
    let currController: wref<CaptionImageIconsLogicController>;
    let currType: gamedataChoiceCaptionPartType;
    let currentSecondaryController: wref<CaptionImageIconsLogicController>;
    let i: Int32;
    this.ResizeCaptionParts(ArraySize(argList));
    i = 0;
    while i < ArraySize(argList) {
      currController = this.m_CaptionControllers[i];
      currentSecondaryController = this.m_SecondaryCaptionControllers[i];
      currType = argList[i].GetType();
      if Equals(currType, gamedataChoiceCaptionPartType.Icon) {
        currController.SetGenericIcon(argList[i] as InteractionChoiceCaptionIconPart.iconRecord);
        currentSecondaryController.HideAllHolders();
      } else {
        if Equals(currType, gamedataChoiceCaptionPartType.Blueline) {
          currBluelineHolder = argList[i] as InteractionChoiceCaptionBluelinePart;
          if IsDefined(currBluelineHolder.blueline.parts[0] as LifePathBluelinePart) {
            currController.SetLifePath(currBluelineHolder.blueline.parts[0] as LifePathBluelinePart);
          } else {
            if IsDefined(currBluelineHolder.blueline.parts[0] as BuildBluelinePart) {
              currentSecondaryController.SetSkillCheck(currBluelineHolder.blueline.parts[0] as BuildBluelinePart);
            } else {
              if IsDefined(currBluelineHolder.blueline.parts[0] as PaymentBluelinePart) {
                currController.SetPaymentCheck(currBluelineHolder.blueline.parts[0] as PaymentBluelinePart);
              };
            };
          };
        };
      };
      i = i + 1;
    };
  }

  public final func UpdateView() -> Void {
    if this.m_overriddenInput {
      this.m_InputView.SetInputButton(n"dpad_up_down");
    } else {
      if this.m_hasDedicatedInput {
        this.m_InputView.SetInputButton(n"y_wide");
      } else {
        if IsNameValid(this.m_dedicatedInputName) {
          this.m_InputView.SetInputButton(this.m_dedicatedInputName);
        } else {
          this.m_InputView.ResetInputButton();
        };
      };
    };
    this.m_InputView.ShowArrows(!this.m_overriddenInput);
    this.m_InputView.SetVisible(this.m_isSelected || this.m_hasDedicatedInput || this.m_overriddenInput);
    inkWidgetRef.SetVisible(this.m_VerticalLineWidget, !this.m_isSelected);
    this.UpdateColors();
  }

  private final func UpdateColors() -> Void {
    let backgroundColor: CName;
    let i: Int32;
    let iconColor: CName;
    if ChoiceTypeWrapper.IsType(this.m_type, gameinteractionsChoiceType.QuestImportant) {
      iconColor = this.m_questColor;
      backgroundColor = this.m_isSelected ? this.m_questColor : this.m_Black;
    } else {
      if ChoiceTypeWrapper.IsType(this.m_type, gameinteractionsChoiceType.PossessedDialog) {
        iconColor = this.m_possessedDialog;
        backgroundColor = this.m_isSelected ? this.m_possessedDialog : this.m_Black;
      } else {
        iconColor = this.m_Active;
        backgroundColor = this.m_isSelected ? this.m_Active : this.m_Black;
      };
    };
    inkWidgetRef.SetVisible(this.m_InActiveTextRef, true);
    i = 0;
    while i < inkCompoundRef.GetNumChildren(this.m_CaptionHolder) {
      if !(inkCompoundRef.GetWidgetByIndex(this.m_CaptionHolder, i).GetController() as CaptionImageIconsLogicController).ShouldShowFluffIcon() {
        inkWidgetRef.SetVisible(this.m_InActiveTextRef, false);
      };
      if this.m_isSelected {
        (inkCompoundRef.GetWidgetByIndex(this.m_CaptionHolder, i).GetController() as CaptionImageIconsLogicController).SetSelectedColor(backgroundColor, this.m_Black);
      } else {
        (inkCompoundRef.GetWidgetByIndex(this.m_CaptionHolder, i).GetController() as CaptionImageIconsLogicController).SetSelectedColor(backgroundColor, iconColor);
      };
      i = i + 1;
    };
    inkWidgetRef.SetVisible(this.m_VerticalLineWidget, !this.m_isSelected);
    inkWidgetRef.SetState(this.m_VerticalLineWidget, iconColor);
    inkWidgetRef.SetState(this.m_SelectedBgRef, iconColor);
    inkWidgetRef.SetState(this.m_SelectedBgRefJohnny, iconColor);
    inkWidgetRef.SetVisible(this.m_phoneIcon, this.m_isPhoneLockActive);
    if this.m_isPhoneLockActive {
      inkWidgetRef.SetState(this.m_ActiveTextRef, this.m_Inactive);
      inkWidgetRef.SetState(this.m_InActiveTextRef, this.m_Inactive);
    } else {
      if this.m_isSelected {
        inkWidgetRef.SetState(this.m_ActiveTextRef, this.m_Black);
        inkWidgetRef.SetState(this.m_InActiveTextRef, this.m_Black);
      } else {
        inkWidgetRef.SetState(this.m_ActiveTextRef, iconColor);
        inkWidgetRef.SetState(this.m_InActiveTextRef, iconColor);
      };
    };
  }

  public final func SetDimmed(value: Bool) -> Void {
    let opacity: Float = value ? 0.40 : 1.00;
    inkWidgetRef.SetOpacity(this.m_ActiveTextRef, opacity);
    inkWidgetRef.SetOpacity(this.m_InActiveTextRef, opacity);
    this.m_SelectedBg.SetOpacity(opacity);
  }

  public final func SetButtonPromptTextureFromHub(value: CName) -> Void {
    if !this.m_hasDedicatedInput {
      this.m_dedicatedInputName = value;
    };
  }

  public final func AnimateSelection() -> Void {
    let adjustedTime: Float;
    let animBgEffectInterp: ref<inkAnimEffect>;
    let animEffectInterp: ref<inkAnimEffect>;
    let animSelect: ref<inkAnimDef>;
    let animSelectBg: ref<inkAnimDef>;
    let containerSize: Vector2;
    let endValue: Float;
    let startValue: Float;
    let timeConstantSpeed: Float;
    if Equals(this.m_prevIsSelected, this.m_isSelected) || this.m_isPreserveSelectionFadeOut {
      return;
    };
    containerSize = this.m_InActiveTextRoot.GetDesiredSize();
    startValue = this.m_InActiveTextRoot.GetEffectParamValue(inkEffectType.LinearWipe, n"LinearWipe_0", n"transition");
    endValue = this.m_isSelected ? 1.00 : 0.00;
    adjustedTime = AbsF(endValue - startValue) * this.m_AnimationTime;
    timeConstantSpeed = AbsF(endValue - startValue) * containerSize.X / this.m_AnimationSpeed * this.m_AnimationTime;
    if this.m_UseConstantSpeed {
      adjustedTime = timeConstantSpeed;
    };
    if IsDefined(this.m_animActiveTextProxy) && this.m_animActiveTextProxy.IsPlaying() {
      this.m_animActiveTextProxy.Stop();
    };
    if startValue != endValue {
      animSelect = new inkAnimDef();
      animEffectInterp = new inkAnimEffect();
      animEffectInterp.SetStartDelay(0.00);
      animEffectInterp.SetEffectType(inkEffectType.LinearWipe);
      animEffectInterp.SetEffectName(n"LinearWipe_0");
      animEffectInterp.SetParamName(n"transition");
      animEffectInterp.SetStartValue(startValue);
      animEffectInterp.SetEndValue(endValue);
      animEffectInterp.SetDuration(adjustedTime);
      animSelect.AddInterpolator(animEffectInterp);
    };
    this.m_InActiveTextRoot.SetEffectEnabled(inkEffectType.LinearWipe, n"LinearWipe_0", true);
    this.m_animActiveTextProxy = this.m_InActiveTextRoot.PlayAnimation(animSelect);
    if IsDefined(this.m_animSelectedBgProxy) && this.m_animSelectedBgProxy.IsPlaying() {
      this.m_animSelectedBgProxy.Stop();
    };
    if IsDefined(this.m_animSelectedJohnnyBgProxy) && this.m_animSelectedJohnnyBgProxy.IsPlaying() {
      this.m_animSelectedJohnnyBgProxy.Stop();
    };
    if startValue != endValue {
      animSelectBg = new inkAnimDef();
      animBgEffectInterp = new inkAnimEffect();
      animBgEffectInterp.SetStartDelay(0.00);
      animBgEffectInterp.SetEffectType(inkEffectType.LinearWipe);
      animBgEffectInterp.SetEffectName(n"LinearWipe_0");
      animBgEffectInterp.SetParamName(n"transition");
      animBgEffectInterp.SetStartValue(startValue);
      animBgEffectInterp.SetEndValue(endValue);
      animBgEffectInterp.SetDuration(adjustedTime);
      animSelectBg.AddInterpolator(animBgEffectInterp);
    };
    this.m_SelectedBg.SetEffectEnabled(inkEffectType.LinearWipe, n"LinearWipe_0", true);
    this.m_SelectedBgJohnny.SetEffectEnabled(inkEffectType.LinearWipe, n"LinearWipe_0", true);
    this.m_animSelectedBgProxy = this.m_SelectedBg.PlayAnimation(animSelectBg);
    this.m_animSelectedJohnnyBgProxy = this.m_SelectedBgJohnny.PlayAnimation(animSelectBg);
  }
}

public class CaptionImageIconsLogicController extends inkLogicController {

  private edit let m_LifeIcon: inkImageRef;

  private edit let m_CheckIcon: inkImageRef;

  private edit let m_GenericIcon: inkImageRef;

  private edit let m_PayIcon: inkImageRef;

  private edit let m_LifeHolder: inkCompoundRef;

  private edit let m_CheckHolder: inkCompoundRef;

  private edit let m_GenericHolder: inkCompoundRef;

  private edit let m_PayHolder: inkCompoundRef;

  private edit let m_LifeDescriptionText: inkTextRef;

  private edit let m_CheckText: inkTextRef;

  private edit let m_PayText: inkTextRef;

  private edit let m_LifeBackground: inkWidgetRef;

  private edit let m_LifeBackgroundFail: inkWidgetRef;

  private edit let m_CheckBackground: inkWidgetRef;

  private edit let m_CheckBackgroundFail: inkWidgetRef;

  private edit let m_PayBackground: inkWidgetRef;

  private edit let m_PayBackgroundFail: inkWidgetRef;

  protected cb func OnInitialize() -> Bool {
    inkWidgetRef.SetVisible(this.m_LifeHolder, false);
    inkWidgetRef.SetVisible(this.m_CheckHolder, false);
    inkWidgetRef.SetVisible(this.m_PayHolder, false);
    inkWidgetRef.SetVisible(this.m_GenericHolder, false);
  }

  public final func ShouldShowFluffIcon() -> Bool {
    return !(inkWidgetRef.IsVisible(this.m_LifeHolder) || inkWidgetRef.IsVisible(this.m_CheckHolder) || inkWidgetRef.IsVisible(this.m_PayHolder) || inkWidgetRef.IsVisible(this.m_GenericHolder));
  }

  public final func SetSelectedColor(backgroundColor: CName, iconColor: CName) -> Void {
    this.GetRootWidget().SetState(backgroundColor);
    inkWidgetRef.SetState(this.m_GenericIcon, iconColor);
    inkWidgetRef.SetState(this.m_CheckIcon, iconColor);
    inkWidgetRef.SetState(this.m_LifeIcon, iconColor);
    inkWidgetRef.SetState(this.m_PayIcon, iconColor);
    inkWidgetRef.SetState(this.m_CheckText, iconColor);
    inkWidgetRef.SetState(this.m_LifeDescriptionText, iconColor);
    inkWidgetRef.SetState(this.m_PayText, iconColor);
  }

  public final func SetGenericIcon(iconRecord: wref<ChoiceCaptionIconPart_Record>) -> Void {
    let iconID: TweakDBID;
    let iconTexturePart: CName;
    let invalidIconID: TweakDBID;
    inkWidgetRef.SetVisible(this.m_LifeHolder, false);
    inkWidgetRef.SetVisible(this.m_CheckHolder, false);
    inkWidgetRef.SetVisible(this.m_PayHolder, false);
    invalidIconID = t"ChoiceCaptionParts.None";
    iconID = iconRecord.TexturePartID().GetID();
    if iconID != invalidIconID && TDBID.IsValid(iconID) {
      this.SetTexture(this.m_GenericIcon, iconID);
      inkWidgetRef.SetVisible(this.m_GenericHolder, true);
    } else {
      iconTexturePart = MappinUIUtils.MappinToTexturePart(iconRecord.MappinVariant().Type());
      if NotEquals(iconTexturePart, n"invalid") {
        inkImageRef.SetTexturePart(this.m_GenericIcon, iconTexturePart);
        inkWidgetRef.SetVisible(this.m_GenericHolder, true);
      };
    };
  }

  public final func SetLifePath(argData: ref<LifePathBluelinePart>) -> Void {
    let lifePathIconID: TweakDBID;
    inkWidgetRef.SetVisible(this.m_LifeHolder, true);
    inkWidgetRef.SetVisible(this.m_CheckHolder, false);
    inkWidgetRef.SetVisible(this.m_PayHolder, false);
    inkWidgetRef.SetVisible(this.m_GenericHolder, false);
    lifePathIconID = argData.m_record.CaptionIcon().TexturePartID().GetID();
    if TDBID.IsValid(lifePathIconID) {
      this.SetTexture(this.m_LifeIcon, lifePathIconID);
      inkWidgetRef.SetVisible(this.m_LifeHolder, true);
    };
    inkTextRef.SetLocalizedTextScript(this.m_LifeDescriptionText, argData.m_record.DisplayName());
    inkWidgetRef.SetOpacity(this.m_LifeBackground, 0.50);
    inkWidgetRef.SetOpacity(this.m_LifeBackgroundFail, 0.50);
    inkWidgetRef.SetVisible(this.m_LifeBackground, argData.passed);
    inkWidgetRef.SetVisible(this.m_LifeBackgroundFail, !argData.passed);
    if !argData.passed {
      this.GetRootWidget().SetVisible(false);
    };
  }

  public final func SetSkillCheck(argData: ref<BuildBluelinePart>) -> Void {
    let skillIconID: TweakDBID;
    inkWidgetRef.SetVisible(this.m_LifeHolder, false);
    inkWidgetRef.SetVisible(this.m_CheckHolder, false);
    inkWidgetRef.SetVisible(this.m_PayHolder, false);
    inkWidgetRef.SetVisible(this.m_GenericHolder, false);
    if argData.passed {
      inkTextRef.SetText(this.m_CheckText, IntToString(argData.m_lhsValue));
    } else {
      inkTextRef.SetText(this.m_CheckText, argData.m_lhsValue + " / " + argData.m_rhsValue);
    };
    inkWidgetRef.SetOpacity(this.m_CheckBackground, 0.50);
    inkWidgetRef.SetOpacity(this.m_CheckBackgroundFail, 0.50);
    inkWidgetRef.SetVisible(this.m_CheckBackground, argData.passed);
    inkWidgetRef.SetVisible(this.m_CheckBackgroundFail, !argData.passed);
    skillIconID = argData.m_record.CaptionIcon().TexturePartID().GetID();
    if TDBID.IsValid(skillIconID) {
      this.SetTexture(this.m_CheckIcon, skillIconID);
      inkWidgetRef.SetVisible(this.m_CheckHolder, true);
    };
  }

  public final func SetPaymentCheck(argData: ref<PaymentBluelinePart>) -> Void {
    inkWidgetRef.SetVisible(this.m_LifeHolder, false);
    inkWidgetRef.SetVisible(this.m_CheckHolder, false);
    inkWidgetRef.SetVisible(this.m_PayHolder, true);
    inkWidgetRef.SetVisible(this.m_GenericHolder, false);
    inkTextRef.SetText(this.m_PayText, IntToString(argData.m_paymentMoney));
    inkWidgetRef.SetOpacity(this.m_PayBackground, 0.50);
    inkWidgetRef.SetOpacity(this.m_PayBackgroundFail, 0.50);
    inkWidgetRef.SetVisible(this.m_PayBackground, argData.passed);
    inkWidgetRef.SetVisible(this.m_PayBackgroundFail, !argData.passed);
  }

  public final func HideAllHolders() -> Void {
    inkWidgetRef.SetVisible(this.m_LifeHolder, false);
    inkWidgetRef.SetVisible(this.m_CheckHolder, false);
    inkWidgetRef.SetVisible(this.m_PayHolder, false);
    inkWidgetRef.SetVisible(this.m_GenericHolder, false);
  }
}

public class DialogChoiceTimerController extends inkLogicController {

  public edit let m_bar: inkWidgetRef;

  public edit let m_timerValue: inkTextRef;

  private let m_progressAnimDef: ref<inkAnimDef>;

  private let m_timerAnimDef: ref<inkAnimDef>;

  private let m_ProgressAnimInterpolator: ref<inkAnimScale>;

  private let m_timerAnimInterpolator: ref<inkAnimTransparency>;

  private let m_timerAnimProxy: ref<inkAnimProxy>;

  private let m_timerBarAnimProxy: ref<inkAnimProxy>;

  private let m_AnimOptions: inkAnimOptions;

  private let time: Float;

  protected cb func OnInitialize() -> Bool {
    inkWidgetRef.SetScale(this.m_bar, new Vector2(1.00, 1.00));
    this.SetupAnimation();
    this.PlayLibraryAnimation(n"bar_intro");
  }

  protected cb func OnUninitialize() -> Bool {
    this.m_timerAnimProxy.Stop();
    this.m_timerBarAnimProxy.Stop();
    this.m_timerAnimProxy.UnregisterFromCallback(inkanimEventType.OnEndLoop, this, n"OnTimerEndLoop");
  }

  public final func StartProgressBarAnim(timeDuration: Float, timedProgress: Float) -> Void {
    this.m_ProgressAnimInterpolator.SetDuration((1.00 - timedProgress) * timeDuration);
    this.m_ProgressAnimInterpolator.SetStartScale(new Vector2(1.00 - timedProgress, 1.00));
    this.time = this.m_ProgressAnimInterpolator.GetDuration() - 1.00;
    this.m_timerBarAnimProxy = inkWidgetRef.PlayAnimation(this.m_bar, this.m_progressAnimDef);
  }

  private final func SetTime() -> Void {
    let timeS: String;
    if this.time < 10.00 {
      timeS = "00:0" + ToString(RoundF(this.time));
    } else {
      timeS = "00:" + ToString(RoundF(this.time));
    };
    inkTextRef.SetText(this.m_timerValue, timeS);
  }

  protected cb func OnTimerEndLoop(proxy: ref<inkAnimProxy>) -> Bool {
    this.SetTime();
    if this.time < 1.00 {
      this.m_timerAnimProxy.Stop();
    };
    this.time = this.time - 1.00;
  }

  public final func OnMenuVisibilityChange(isMenuVisible: Bool) -> Void {
    if isMenuVisible {
      this.m_timerAnimProxy.Pause();
      this.m_timerBarAnimProxy.Pause();
    } else {
      this.m_timerAnimProxy.Resume();
      this.m_timerBarAnimProxy.Resume();
    };
  }

  private final func SetupAnimation() -> Void {
    this.SetTime();
    this.m_progressAnimDef = new inkAnimDef();
    this.m_ProgressAnimInterpolator = new inkAnimScale();
    this.m_ProgressAnimInterpolator.SetStartScale(new Vector2(1.00, 1.00));
    this.m_ProgressAnimInterpolator.SetEndScale(new Vector2(0.00, 1.00));
    this.m_progressAnimDef.AddInterpolator(this.m_ProgressAnimInterpolator);
    this.m_timerAnimDef = new inkAnimDef();
    this.m_timerAnimInterpolator = new inkAnimTransparency();
    this.m_timerAnimInterpolator.SetDuration(1.00);
    this.m_timerAnimInterpolator.SetStartTransparency(1.00);
    this.m_timerAnimInterpolator.SetEndTransparency(1.00);
    this.m_timerAnimInterpolator.SetType(inkanimInterpolationType.Linear);
    this.m_timerAnimInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
    this.m_timerAnimDef.AddInterpolator(this.m_timerAnimInterpolator);
    this.m_AnimOptions.playReversed = false;
    this.m_AnimOptions.executionDelay = 0.00;
    this.m_AnimOptions.loopType = inkanimLoopType.Cycle;
    this.m_AnimOptions.loopInfinite = true;
    this.m_AnimOptions.dependsOnTimeDilation = true;
    this.m_timerAnimProxy = this.GetRootWidget().PlayAnimationWithOptions(this.m_timerAnimDef, this.m_AnimOptions);
    this.m_timerAnimProxy.RegisterToCallback(inkanimEventType.OnEndLoop, this, n"OnTimerEndLoop");
    this.m_timerAnimProxy.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnTimerEndLoop");
  }
}
