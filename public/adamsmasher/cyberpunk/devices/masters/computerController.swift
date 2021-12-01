
public class ToggleOpenComputer extends ActionBool {

  public final func SetProperties(isOpen: Bool) -> Void {
    this.actionName = n"ToggleOpen";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"Open", isOpen, n"LocKey#273", n"LocKey#274");
  }

  public final static func IsDefaultConditionMet(device: ref<ComputerControllerPS>, context: GetActionsContext) -> Bool {
    if ToggleOpenComputer.IsAvailable(device) && ToggleOpenComputer.IsClearanceValid(context.clearance) {
      return true;
    };
    return false;
  }

  public final static func IsAvailable(device: ref<ComputerControllerPS>) -> Bool {
    if device.IsDisabled() || Equals(device.GetAnimationState(), IntEnum(0l)) || device.IsPersonalLinkConnected() || device.IsPersonalLinkConnecting() {
      return false;
    };
    return true;
  }

  public final static func IsClearanceValid(clearance: ref<Clearance>) -> Bool {
    if Clearance.IsInRange(clearance, DefaultActionsParametersHolder.GetToggleOpenClearance()) {
      return true;
    };
    return false;
  }

  public func GetTweakDBChoiceRecord() -> String {
    if !FromVariant(this.prop.first) {
      return "Open";
    };
    return "Close";
  }

  public func GetInkWidgetTweakDBID() -> TweakDBID {
    return t"DevicesUIDefinitions.GenericActionWidget";
  }
}

public class ComputerController extends TerminalController {

  protected const func GetPS() -> ref<GameComponentPS> {
    return this.GetBasePS();
  }
}

public class ComputerControllerPS extends TerminalControllerPS {

  protected persistent let m_computerSetup: ComputerSetup;

  protected let m_quickHackSetup: ComputerQuickHackData;

  protected let m_activatorActionSetup: EToggleActivationTypeComputer;

  protected inline let m_computerSkillChecks: ref<HackEngContainer>;

  protected persistent let m_openedMailAdress: SDocumentAdress;

  protected persistent let m_openedFileAdress: SDocumentAdress;

  protected persistent let m_quickhackPerformed: Bool;

  @default(ComputerControllerPS, true)
  private let m_isInSleepMode: Bool;

  public final const func GetInitialMenuType() -> EComputerMenuType {
    return this.m_computerSetup.m_startingMenu;
  }

  public final const func GetActivatorType() -> EToggleActivationTypeComputer {
    return this.m_activatorActionSetup;
  }

  public final const func IsInSleepMode() -> Bool {
    if !this.HasUICameraZoom() {
      return false;
    };
    return this.m_isInSleepMode;
  }

  public final func SetIsInSleepMode(value: Bool) -> Void {
    this.m_isInSleepMode = value;
  }

  public final const func GetAnimationState() -> EComputerAnimationState {
    return this.m_computerSetup.m_animationState;
  }

  public final func SetAnimationState(state: EComputerAnimationState) -> Void {
    this.m_computerSetup.m_animationState = state;
  }

  public const func ShouldShowExamineIntaraction() -> Bool {
    if Equals(this.GetAnimationState(), EComputerAnimationState.Closed) {
      return false;
    };
    return this.ShouldShowExamineIntaraction();
  }

  public final const func DataInitialized() -> Bool {
    if ArraySize(this.m_computerSetup.m_mailsStructure) > 0 || ArraySize(this.m_computerSetup.m_filesStructure) > 0 || ArraySize(this.m_computerSetup.m_newsFeed) > 0 {
      return true;
    };
    return false;
  }

  protected cb func OnInstantiated() -> Bool {
    super.OnInstantiated();
    if !IsStringValid(this.m_deviceName) {
      this.m_deviceName = "LocKey#48";
    };
  }

  protected func GameAttached() -> Void;

  protected func LogicReady() -> Void {
    this.LogicReady();
    this.InitializeSkillChecks(this.m_computerSkillChecks);
  }

  public final func PushResaveData(data: ComputerPersistentData) -> Void;

  protected const func GenerateContext(requestType: gamedeviceRequestType, providedClearance: ref<Clearance>, opt providedProcessInitiator: ref<GameObject>, opt providedRequestor: EntityID) -> GetActionsContext {
    let generatedContext: GetActionsContext = this.GenerateContext(requestType, providedClearance, providedProcessInitiator, providedRequestor);
    generatedContext.ignoresAuthorization = this.m_computerSetup.m_ignoreSlaveAuthorizationModule;
    return generatedContext;
  }

  protected const func CanCreateAnyQuickHackActions() -> Bool {
    return true;
  }

  protected func GetQuickHackActions(out outActions: array<ref<DeviceAction>>, context: GetActionsContext) -> Void {
    let currentAction: ref<ScriptableDeviceAction>;
    this.GetQuickHacksFromSlave(outActions, context);
    if !this.m_quickhackPerformed && IsNameValid(this.m_quickHackSetup.factName) {
      currentAction = this.ActionCreateFactQuickHack();
      currentAction.SetObjectActionID(t"DeviceAction.DataExtractionClassHack");
      ArrayPush(outActions, currentAction);
    };
    if this.CanPlayerTakeOverControl() {
      currentAction = this.ActionToggleTakeOverControl();
      currentAction.SetObjectActionID(t"DeviceAction.TakeControlClassHack");
      ArrayPush(outActions, currentAction);
    };
    currentAction = this.ActionGlitchScreen(t"DeviceAction.GlitchScreenSuicide", t"QuickHack.DeviceSuicideHack");
    currentAction.SetDurationValue(this.GetDistractionDuration(currentAction));
    currentAction.SetInactiveWithReason(GlitchScreen.IsDefaultConditionMet(this, context), "LocKey#7003");
    ArrayPush(outActions, currentAction);
    currentAction = this.ActionGlitchScreen(t"DeviceAction.GlitchScreenBlind", t"QuickHack.BlindHack");
    currentAction.SetDurationValue(this.GetDistractionDuration(currentAction));
    currentAction.SetInactiveWithReason(GlitchScreen.IsDefaultConditionMet(this, context), "LocKey#7003");
    ArrayPush(outActions, currentAction);
    currentAction = this.ActionGlitchScreen(t"DeviceAction.GlitchScreenHeartAttack", t"QuickHack.HeartAttackHack");
    currentAction.SetDurationValue(this.GetDistractionDuration(currentAction));
    currentAction.SetInactiveWithReason(GlitchScreen.IsDefaultConditionMet(this, context), "LocKey#7003");
    ArrayPush(outActions, currentAction);
    currentAction = this.ActionGlitchScreen(t"DeviceAction.GlitchScreenGrenade", t"QuickHack.GrenadeHack");
    currentAction.SetDurationValue(this.GetDistractionDuration(currentAction));
    currentAction.SetInactiveWithReason(GlitchScreen.IsDefaultConditionMet(this, context), "LocKey#7003");
    ArrayPush(outActions, currentAction);
    currentAction = this.ActionQuickHackDistraction();
    currentAction.SetObjectActionID(t"DeviceAction.MalfunctionClassHack");
    currentAction.SetDurationValue(this.GetDistractionDuration(currentAction));
    currentAction.SetInactiveWithReason(ScriptableDeviceAction.IsDefaultConditionMet(this, context), "LocKey#7003");
    ArrayPush(outActions, currentAction);
    if this.IsGlitching() || this.IsDistracting() {
      ScriptableDeviceComponentPS.SetActionsInactiveAll(outActions, "LocKey#7004");
    };
    this.FinalizeGetQuickHackActions(outActions, context);
  }

  public func GetActions(out actions: array<ref<DeviceAction>>, context: GetActionsContext) -> Bool {
    this.GetActions(actions, context);
    if ToggleOpenComputer.IsDefaultConditionMet(this, context) {
      ArrayPush(actions, this.ActionToggleOpen());
    };
    this.SetActionIllegality(actions, this.m_illegalActions.regularActions);
    return true;
  }

  public func GetQuestActionByName(actionName: CName) -> ref<DeviceAction> {
    let action: ref<DeviceAction> = this.GetQuestActionByName(actionName);
    if action == null {
      switch actionName {
        case n"ToggleOpen":
          action = this.ActionToggleOpen();
      };
    };
    return action;
  }

  public func GetQuestActions(out actions: array<ref<DeviceAction>>, context: GetActionsContext) -> Void {
    this.GetQuestActions(actions, context);
    ArrayPush(actions, this.ActionToggleOpen());
  }

  public func ActionToggleOpen() -> ref<ToggleOpenComputer> {
    let action: ref<ToggleOpenComputer> = new ToggleOpenComputer();
    action.clearanceLevel = DefaultActionsParametersHolder.GetToggleOpenClearance();
    action.SetUp(this);
    action.SetProperties(Equals(this.GetAnimationState(), EComputerAnimationState.Opened));
    action.AddDeviceName(this.GetDeviceName());
    action.OverrideInteractionRecord(t"Interactions.CloseLaptop", t"Interactions.OpenLaptop");
    action.CreateActionWidgetPackage();
    return action;
  }

  public final func OnToggleOpen(evt: ref<ToggleOpenComputer>) -> EntityNotificationType {
    let notifier: ref<ActionNotifier> = new ActionNotifier();
    notifier.SetNone();
    if this.IsDisabled() || Equals(this.GetAnimationState(), IntEnum(0l)) {
      return this.SendActionFailedEvent(evt, evt.GetRequesterID(), "Unpowered or Disabled");
    };
    if Equals(this.GetAnimationState(), EComputerAnimationState.Opened) {
      this.SetAnimationState(EComputerAnimationState.Closed);
    } else {
      if Equals(this.GetAnimationState(), EComputerAnimationState.Closed) {
        this.SetAnimationState(EComputerAnimationState.Opened);
      };
    };
    this.Notify(notifier, evt);
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected final func ActionCreateFactQuickHack() -> ref<FactQuickHack> {
    let action: ref<FactQuickHack> = new FactQuickHack();
    action.SetUp(this);
    action.AddDeviceName(this.m_deviceName);
    action.SetProperties(this.m_quickHackSetup);
    if TDBID.IsValid(this.m_quickHackSetup.alternativeName) {
      action.CreateInteraction(this.m_quickHackSetup.alternativeName);
    } else {
      action.CreateInteraction();
    };
    return action;
  }

  public final func OnCreateFactQuickHack(evt: ref<FactQuickHack>) -> EntityNotificationType {
    this.m_quickhackPerformed = true;
    return EntityNotificationType.SendThisEventToEntity;
  }

  public const func GetBlackboardDef() -> ref<DeviceBaseBlackboardDef> {
    return GetAllBlackboardDefs().ComputerDeviceBlackboard;
  }

  private final func DisableMenu(menuType: EComputerMenuType) -> Void {
    if Equals(menuType, EComputerMenuType.MAILS) {
      this.m_computerSetup.m_mailsMenu = false;
    } else {
      if Equals(menuType, EComputerMenuType.FILES) {
        this.m_computerSetup.m_filesMenu = false;
      } else {
        if Equals(menuType, EComputerMenuType.SYSTEM) {
          this.m_computerSetup.m_systemMenu = false;
        } else {
          if Equals(menuType, EComputerMenuType.INTERNET) {
            this.m_computerSetup.m_internetMenu = false;
          } else {
            if Equals(menuType, EComputerMenuType.NEWSFEED) {
              this.m_computerSetup.m_newsFeedMenu = false;
            };
          };
        };
      };
    };
  }

  private final func EnableMenu(menuType: EComputerMenuType) -> Void {
    if Equals(menuType, EComputerMenuType.MAILS) {
      this.m_computerSetup.m_mailsMenu = true;
    } else {
      if Equals(menuType, EComputerMenuType.FILES) {
        this.m_computerSetup.m_filesMenu = true;
      } else {
        if Equals(menuType, EComputerMenuType.SYSTEM) {
          this.m_computerSetup.m_systemMenu = true;
        } else {
          if Equals(menuType, EComputerMenuType.INTERNET) {
            this.m_computerSetup.m_internetMenu = true;
          } else {
            if Equals(menuType, EComputerMenuType.NEWSFEED) {
              this.m_computerSetup.m_newsFeedMenu = true;
            };
          };
        };
      };
    };
  }

  private final func IsMenuEnabled(menuType: EComputerMenuType) -> Bool {
    let returnValue: Bool;
    if Equals(menuType, EComputerMenuType.MAILS) {
      returnValue = this.m_computerSetup.m_mailsMenu;
    } else {
      if Equals(menuType, EComputerMenuType.FILES) {
        returnValue = this.m_computerSetup.m_filesMenu;
      } else {
        if Equals(menuType, EComputerMenuType.SYSTEM) {
          returnValue = this.m_computerSetup.m_systemMenu;
        } else {
          if Equals(menuType, EComputerMenuType.INTERNET) {
            returnValue = this.m_computerSetup.m_internetMenu;
          } else {
            if Equals(menuType, EComputerMenuType.NEWSFEED) {
              returnValue = this.m_computerSetup.m_newsFeedMenu;
            };
          };
        };
      };
    };
    return returnValue;
  }

  public final const func GetNewsfeedInterval() -> Float {
    return this.m_computerSetup.m_newsFeedInterval;
  }

  public final const func HasNewsfeed() -> Bool {
    return ArraySize(this.m_computerSetup.m_newsFeed) > 0;
  }

  public final func UpdateBanners() -> Void {
    let bannerID: Int32;
    let i: Int32 = 0;
    while i < ArraySize(this.m_computerSetup.m_newsFeed) {
      bannerID = this.m_computerSetup.m_newsFeed[i].currentBanner;
      if bannerID < ArraySize(this.m_computerSetup.m_newsFeed[i].banners) - 1 {
        bannerID += 1;
      } else {
        if bannerID == ArraySize(this.m_computerSetup.m_newsFeed[i].banners) - 1 {
          bannerID = 0;
        };
      };
      this.m_computerSetup.m_newsFeed[i].currentBanner = bannerID;
      i += 1;
    };
  }

  public func OnRequestDocumentWidgetUpdate(evt: ref<RequestDocumentWidgetUpdateEvent>) -> Void {
    if Equals(evt.documentType, EDocumentType.FILE) {
      this.RequestFileWidgetUpdate(this.GetBlackboard(), evt.documentAdress);
    } else {
      if Equals(evt.documentType, EDocumentType.MAIL) {
        this.RequestMailWidgetUpdate(this.GetBlackboard(), evt.documentAdress);
      };
    };
  }

  public func OnRequestDocumentThumbnailWidgetsUpdate(evt: ref<RequestDocumentThumbnailWidgetsUpdateEvent>) -> Void {
    if Equals(evt.documentType, EDocumentType.FILE) {
      this.RequestFileThumbnailWidgetsUpdate(this.GetBlackboard());
    } else {
      if Equals(evt.documentType, EDocumentType.MAIL) {
        this.RequestMailThumbnailWidgetsUpdate(this.GetBlackboard());
      };
    };
  }

  public func OnRequestMenuWidgetsUpdate(evt: ref<RequestComputerMenuWidgetsUpdateEvent>) -> Void {
    this.RequestMenuButtonWidgetsUpdate(this.GetBlackboard());
  }

  public final func RequestBannerWidgetsUpdate(blackboard: ref<IBlackboard>) -> Void {
    let widgetsData: array<SBannerWidgetPackage> = this.GetBannerWidgets();
    if IsDefined(blackboard) {
      blackboard.SetVariant(this.GetBlackboardDef() as ComputerDeviceBlackboardDef.BannerWidgetsData, ToVariant(widgetsData));
      blackboard.SignalVariant(this.GetBlackboardDef() as ComputerDeviceBlackboardDef.BannerWidgetsData);
      blackboard.FireCallbacks();
    };
  }

  public func RequestFileWidgetUpdate(blackboard: ref<IBlackboard>, documentAdress: SDocumentAdress) -> Void {
    let widgetsData: array<SDocumentWidgetPackage>;
    let documentData: SDocumentWidgetPackage = this.GetFileWidget(documentAdress);
    if IsStringValid(documentData.title) {
      ArrayPush(widgetsData, documentData);
      if IsDefined(blackboard) {
        blackboard.SetVariant(this.GetBlackboardDef() as ComputerDeviceBlackboardDef.FileWidgetsData, ToVariant(widgetsData));
        blackboard.SignalVariant(this.GetBlackboardDef() as ComputerDeviceBlackboardDef.FileWidgetsData);
        blackboard.FireCallbacks();
      };
    };
  }

  public func RequestMailWidgetUpdate(blackboard: ref<IBlackboard>, documentAdress: SDocumentAdress) -> Void {
    let widgetsData: array<SDocumentWidgetPackage>;
    let documentData: SDocumentWidgetPackage = this.GetMailWidget(documentAdress);
    if IsStringValid(documentData.title) {
      ArrayPush(widgetsData, documentData);
      if IsDefined(blackboard) {
        blackboard.SetVariant(this.GetBlackboardDef() as ComputerDeviceBlackboardDef.MailWidgetsData, ToVariant(widgetsData));
        blackboard.SignalVariant(this.GetBlackboardDef() as ComputerDeviceBlackboardDef.MailWidgetsData);
        blackboard.FireCallbacks();
      };
    };
  }

  public func RequestMailThumbnailWidgetsUpdate(blackboard: ref<IBlackboard>) -> Void {
    let widgetsData: array<SDocumentThumbnailWidgetPackage> = this.GetMailThumbnailWidgets();
    if IsDefined(blackboard) {
      blackboard.SetVariant(this.GetBlackboardDef() as ComputerDeviceBlackboardDef.MailThumbnailWidgetsData, ToVariant(widgetsData));
      blackboard.SignalVariant(this.GetBlackboardDef() as ComputerDeviceBlackboardDef.MailThumbnailWidgetsData);
      blackboard.FireCallbacks();
    };
  }

  public func RequestFileThumbnailWidgetsUpdate(blackboard: ref<IBlackboard>) -> Void {
    let widgetsData: array<SDocumentThumbnailWidgetPackage> = this.GetFileThumbnailWidgets();
    if IsDefined(blackboard) {
      blackboard.SetVariant(this.GetBlackboardDef() as ComputerDeviceBlackboardDef.FileThumbnailWidgetsData, ToVariant(widgetsData));
      blackboard.SignalVariant(this.GetBlackboardDef() as ComputerDeviceBlackboardDef.FileThumbnailWidgetsData);
      blackboard.FireCallbacks();
    };
  }

  public func RequestMenuButtonWidgetsUpdate(blackboard: ref<IBlackboard>) -> Void {
    let widgetsData: array<SComputerMenuButtonWidgetPackage> = this.GetMenuButtonWidgets();
    if IsDefined(blackboard) {
      blackboard.SetVariant(this.GetBlackboardDef() as ComputerDeviceBlackboardDef.MenuButtonWidgetsData, ToVariant(widgetsData));
      blackboard.SignalVariant(this.GetBlackboardDef() as ComputerDeviceBlackboardDef.MenuButtonWidgetsData);
      blackboard.FireCallbacks();
    };
  }

  public func RequestMainMenuButtonWidgetsUpdate(blackboard: ref<IBlackboard>) -> Void {
    let widgetsData: array<SComputerMenuButtonWidgetPackage> = this.GetMainMenuButtonWidgets();
    if IsDefined(blackboard) {
      blackboard.SetVariant(this.GetBlackboardDef() as ComputerDeviceBlackboardDef.MainMenuButtonWidgetsData, ToVariant(widgetsData));
      blackboard.SignalVariant(this.GetBlackboardDef() as ComputerDeviceBlackboardDef.MainMenuButtonWidgetsData);
      blackboard.FireCallbacks();
    };
  }

  protected func GetBannerWidgetTweakDBID() -> TweakDBID {
    return t"DevicesUIDefinitions.BannerWidget";
  }

  private final func GetBannerWidgets() -> array<SBannerWidgetPackage> {
    let currentBanner: Int32;
    let i: Int32;
    let widgetPackage: SBannerWidgetPackage;
    let widgetsData: array<SBannerWidgetPackage>;
    let tweakID: TweakDBID = this.GetBannerWidgetTweakDBID();
    widgetPackage.widgetTweakDBID = tweakID;
    SWidgetPackageBase.ResolveWidgetTweakDBData(tweakID, widgetPackage.libraryID, widgetPackage.libraryPath);
    widgetPackage.isValid = ResRef.IsValid(widgetPackage.libraryPath) || IsNameValid(widgetPackage.libraryID);
    if !widgetPackage.isValid {
      return widgetsData;
    };
    i = 0;
    while i < ArraySize(this.m_computerSetup.m_newsFeed) {
      currentBanner = this.m_computerSetup.m_newsFeed[i].currentBanner;
      widgetPackage.title = this.m_computerSetup.m_newsFeed[i].banners[currentBanner].title;
      widgetPackage.content = this.m_computerSetup.m_newsFeed[i].banners[currentBanner].content;
      widgetPackage.widgetName = "banner" + "_" + ToString(currentBanner) + "_" + ToString(i);
      widgetPackage.ownerID = this.GetID();
      widgetPackage.description = this.m_computerSetup.m_newsFeed[i].banners[currentBanner].description;
      ArrayPush(widgetsData, widgetPackage);
      i += 1;
    };
    return widgetsData;
  }

  protected func GetFileWidgetTweakDBID() -> TweakDBID {
    return t"DevicesUIDefinitions.FileWidget";
  }

  public final func GetFileWidget(documentAdress: SDocumentAdress) -> SDocumentWidgetPackage {
    let journalFile: wref<JournalFile>;
    let tweakID: TweakDBID;
    let widgetPackage: SDocumentWidgetPackage;
    let dataElement: DataElement = this.m_computerSetup.m_filesStructure[documentAdress.folderID].content[documentAdress.documentID];
    if this.IsDataElementValid(dataElement) {
      tweakID = this.GetFileWidgetTweakDBID();
      widgetPackage.widgetTweakDBID = tweakID;
      SWidgetPackageBase.ResolveWidgetTweakDBData(tweakID, widgetPackage.libraryID, widgetPackage.libraryPath);
      widgetPackage.isValid = ResRef.IsValid(widgetPackage.libraryPath) || IsNameValid(widgetPackage.libraryID);
      if !widgetPackage.isValid {
        return widgetPackage;
      };
      journalFile = this.GetJournalFileEntry(dataElement);
      if journalFile != null {
        widgetPackage.title = journalFile.GetTitle();
        widgetPackage.content = journalFile.GetContent();
        widgetPackage.videoPath = journalFile.GetVideoResourcePath();
        widgetPackage.image = journalFile.GetImageTweak();
      } else {
        widgetPackage.title = dataElement.title;
        widgetPackage.content = dataElement.content;
      };
      widgetPackage.owner = dataElement.owner;
      widgetPackage.widgetName = "file" + "_" + ToString(documentAdress.folderID) + "_" + ToString(documentAdress.documentID);
      widgetPackage.date = dataElement.date;
      widgetPackage.isEncrypted = dataElement.isEncrypted;
      widgetPackage.questInfo = dataElement.questInfo;
      widgetPackage.ownerID = this.GetID();
      widgetPackage.wasRead = dataElement.wasRead;
      widgetPackage.documentType = EDocumentType.FILE;
    };
    return widgetPackage;
  }

  protected func GetMailWidgetTweakDBID() -> TweakDBID {
    return t"DevicesUIDefinitions.MailWidget";
  }

  public final func GetMailWidget(documentAdress: SDocumentAdress) -> SDocumentWidgetPackage {
    let journalEmail: wref<JournalEmail>;
    let tweakID: TweakDBID;
    let widgetPackage: SDocumentWidgetPackage;
    let dataElement: DataElement = this.m_computerSetup.m_mailsStructure[documentAdress.folderID].content[documentAdress.documentID];
    if this.IsDataElementValid(dataElement) {
      tweakID = this.GetMailWidgetTweakDBID();
      SWidgetPackageBase.ResolveWidgetTweakDBData(tweakID, widgetPackage.libraryID, widgetPackage.libraryPath);
      widgetPackage.isValid = ResRef.IsValid(widgetPackage.libraryPath) || IsNameValid(widgetPackage.libraryID);
      if !widgetPackage.isValid {
        return widgetPackage;
      };
      widgetPackage.widgetTweakDBID = tweakID;
      journalEmail = this.GetJournalMailEntry(dataElement);
      if journalEmail != null {
        widgetPackage.owner = journalEmail.GetSender();
        widgetPackage.date = journalEmail.GetAddressee();
        widgetPackage.title = journalEmail.GetTitle();
        widgetPackage.content = journalEmail.GetContent();
        widgetPackage.image = journalEmail.GetImageTweak();
        widgetPackage.videoPath = journalEmail.GetVideoResourcePath();
      } else {
        widgetPackage.owner = dataElement.owner;
        widgetPackage.date = dataElement.date;
        widgetPackage.title = dataElement.title;
        widgetPackage.content = dataElement.content;
      };
      widgetPackage.widgetName = "mail" + "_" + ToString(documentAdress.folderID) + "_" + ToString(documentAdress.documentID);
      widgetPackage.isEncrypted = dataElement.isEncrypted;
      widgetPackage.questInfo = dataElement.questInfo;
      widgetPackage.ownerID = this.GetID();
      widgetPackage.wasRead = dataElement.wasRead;
      widgetPackage.documentType = EDocumentType.MAIL;
    };
    return widgetPackage;
  }

  protected func GetMailThumbnailWidgetTweakDBID() -> TweakDBID {
    return t"DevicesUIDefinitions.MailThumbnailWidget";
  }

  public final func GetMailThumbnailWidgets() -> array<SDocumentThumbnailWidgetPackage> {
    let dataElement: DataElement;
    let documentAdress: SDocumentAdress;
    let i: Int32;
    let journalEmail: wref<JournalEmail>;
    let k: Int32;
    let widgetPackage: SDocumentThumbnailWidgetPackage;
    let widgetPackages: array<SDocumentThumbnailWidgetPackage>;
    let tweakID: TweakDBID = this.GetMailThumbnailWidgetTweakDBID();
    widgetPackage.widgetTweakDBID = tweakID;
    SWidgetPackageBase.ResolveWidgetTweakDBData(tweakID, widgetPackage.libraryID, widgetPackage.libraryPath);
    widgetPackage.isValid = ResRef.IsValid(widgetPackage.libraryPath) || IsNameValid(widgetPackage.libraryID);
    if !widgetPackage.isValid {
      return widgetPackages;
    };
    i = 0;
    while i < ArraySize(this.m_computerSetup.m_mailsStructure) {
      k = 0;
      while k < ArraySize(this.m_computerSetup.m_mailsStructure[i].content) {
        dataElement = this.m_computerSetup.m_mailsStructure[i].content[k];
        if !this.IsDataElementValid(dataElement) {
        } else {
          journalEmail = this.GetJournalMailEntry(dataElement);
          if journalEmail != null {
            widgetPackage.displayName = journalEmail.GetTitle();
          } else {
            widgetPackage.displayName = dataElement.title;
          };
          documentAdress.folderID = i;
          documentAdress.documentID = k;
          widgetPackage.widgetName = "mailThumbnail" + "_" + ToString(i) + "_" + ToString(k);
          widgetPackage.folderName = this.m_computerSetup.m_mailsStructure[i].name;
          widgetPackage.documentAdress = documentAdress;
          widgetPackage.isOpened = documentAdress.folderID == this.m_openedMailAdress.folderID && documentAdress.documentID == this.m_openedMailAdress.documentID;
          widgetPackage.documentType = EDocumentType.MAIL;
          widgetPackage.ownerID = this.GetID();
          widgetPackage.questInfo = dataElement.questInfo;
          widgetPackage.wasRead = dataElement.wasRead;
          ArrayPush(widgetPackages, widgetPackage);
        };
        k += 1;
      };
      i += 1;
    };
    return widgetPackages;
  }

  protected func GetFileThumbnailWidgetTweakDBID() -> TweakDBID {
    return t"DevicesUIDefinitions.FileThumbnailWidget";
  }

  public final func GetFileThumbnailWidgets() -> array<SDocumentThumbnailWidgetPackage> {
    let dataElement: DataElement;
    let documentAdress: SDocumentAdress;
    let i: Int32;
    let journalFile: wref<JournalFile>;
    let k: Int32;
    let widgetPackage: SDocumentThumbnailWidgetPackage;
    let widgetPackages: array<SDocumentThumbnailWidgetPackage>;
    let tweakID: TweakDBID = this.GetFileThumbnailWidgetTweakDBID();
    widgetPackage.widgetTweakDBID = tweakID;
    SWidgetPackageBase.ResolveWidgetTweakDBData(tweakID, widgetPackage.libraryID, widgetPackage.libraryPath);
    widgetPackage.isValid = ResRef.IsValid(widgetPackage.libraryPath) || IsNameValid(widgetPackage.libraryID);
    if !widgetPackage.isValid {
      return widgetPackages;
    };
    i = 0;
    while i < ArraySize(this.m_computerSetup.m_filesStructure) {
      k = 0;
      while k < ArraySize(this.m_computerSetup.m_filesStructure[i].content) {
        dataElement = this.m_computerSetup.m_filesStructure[i].content[k];
        if !this.IsDataElementValid(dataElement) {
        } else {
          journalFile = this.GetJournalFileEntry(dataElement);
          if journalFile != null {
            widgetPackage.displayName = journalFile.GetTitle();
          } else {
            widgetPackage.displayName = dataElement.title;
          };
          documentAdress.folderID = i;
          documentAdress.documentID = k;
          widgetPackage.widgetName = "mailThumbnail" + "_" + ToString(i) + "_" + ToString(k);
          widgetPackage.folderName = this.m_computerSetup.m_filesStructure[i].name;
          widgetPackage.documentAdress = documentAdress;
          widgetPackage.isOpened = documentAdress.folderID == this.m_openedFileAdress.folderID && documentAdress.documentID == this.m_openedFileAdress.documentID;
          widgetPackage.documentType = EDocumentType.FILE;
          widgetPackage.ownerID = this.GetID();
          widgetPackage.questInfo = dataElement.questInfo;
          widgetPackage.wasRead = dataElement.wasRead;
          ArrayPush(widgetPackages, widgetPackage);
        };
        k += 1;
      };
      i += 1;
    };
    return widgetPackages;
  }

  protected func GetMenuButtonWidgetTweakDBID() -> TweakDBID {
    return t"DevicesUIDefinitions.MenuButtonWidget";
  }

  public final func GetMenuButtonWidgets() -> array<SComputerMenuButtonWidgetPackage> {
    let devices: array<ref<DeviceComponentPS>>;
    let i: Int32;
    let widgetPackage: SComputerMenuButtonWidgetPackage;
    let widgetPackages: array<SComputerMenuButtonWidgetPackage>;
    let tweakID: TweakDBID = this.GetMenuButtonWidgetTweakDBID();
    widgetPackage.widgetTweakDBID = tweakID;
    SWidgetPackageBase.ResolveWidgetTweakDBData(tweakID, widgetPackage.libraryID, widgetPackage.libraryPath);
    widgetPackage.isValid = ResRef.IsValid(widgetPackage.libraryPath) || IsNameValid(widgetPackage.libraryID);
    if !widgetPackage.isValid {
      return widgetPackages;
    };
    if this.IsMenuEnabled(EComputerMenuType.MAILS) {
      i = 0;
      while i < ArraySize(this.m_computerSetup.m_mailsStructure) {
        widgetPackage.counter += this.GetEnabledDocumentsCount(this.m_computerSetup.m_mailsStructure[i].content, true);
        i += 1;
      };
      if ArraySize(this.m_computerSetup.m_mailsStructure) > 0 {
        widgetPackage.widgetName = "mails";
        widgetPackage.displayName = "Gameplay-Devices-Computers-Common-Inbox";
        widgetPackage.ownerID = this.GetID();
        widgetPackage.iconID = n"iconMail";
        ArrayPush(widgetPackages, widgetPackage);
      };
      widgetPackage.counter = 0;
    };
    if this.IsMenuEnabled(EComputerMenuType.FILES) {
      i = 0;
      while i < ArraySize(this.m_computerSetup.m_filesStructure) {
        widgetPackage.counter += this.GetEnabledDocumentsCount(this.m_computerSetup.m_filesStructure[i].content, true);
        i += 1;
      };
      if ArraySize(this.m_computerSetup.m_filesStructure) > 0 {
        widgetPackage.widgetName = "files";
        widgetPackage.displayName = "Gameplay-Devices-Computers-Common-Files";
        widgetPackage.ownerID = this.GetID();
        widgetPackage.iconID = n"iconFiles";
        ArrayPush(widgetPackages, widgetPackage);
      };
      widgetPackage.counter = 0;
    };
    if this.IsMenuEnabled(EComputerMenuType.NEWSFEED) {
    };
    if this.IsMenuEnabled(EComputerMenuType.SYSTEM) {
      devices = this.GetImmediateSlaves();
      if ArraySize(devices) > 0 {
        widgetPackage.counter = this.GetEnabledDevicesCount(devices);
        widgetPackage.widgetName = "devices";
        widgetPackage.displayName = "Gameplay-Devices-Computers-Common-System";
        widgetPackage.ownerID = this.GetID();
        widgetPackage.iconID = n"iconNetwork";
        ArrayPush(widgetPackages, widgetPackage);
      };
      widgetPackage.counter = 0;
    };
    if this.IsMenuEnabled(EComputerMenuType.INTERNET) {
      widgetPackage.widgetName = "internet";
      widgetPackage.displayName = "Gameplay-Devices-Computers-Common-Internet";
      widgetPackage.ownerID = this.GetID();
      widgetPackage.iconID = n"iconInternet";
      ArrayPush(widgetPackages, widgetPackage);
    };
    return widgetPackages;
  }

  protected func GetMainMenuButtonWidgetTweakDBID() -> TweakDBID {
    return t"DevicesUIDefinitions.MainMenuButtonWidget";
  }

  public final func GetMainMenuButtonWidgets() -> array<SComputerMenuButtonWidgetPackage> {
    let devices: array<ref<DeviceComponentPS>>;
    let i: Int32;
    let widgetPackage: SComputerMenuButtonWidgetPackage;
    let widgetPackages: array<SComputerMenuButtonWidgetPackage>;
    let tweakID: TweakDBID = this.GetMainMenuButtonWidgetTweakDBID();
    widgetPackage.widgetTweakDBID = tweakID;
    SWidgetPackageBase.ResolveWidgetTweakDBData(tweakID, widgetPackage.libraryID, widgetPackage.libraryPath);
    widgetPackage.isValid = ResRef.IsValid(widgetPackage.libraryPath) || IsNameValid(widgetPackage.libraryID);
    if !widgetPackage.isValid {
      return widgetPackages;
    };
    if this.IsMenuEnabled(EComputerMenuType.MAILS) {
      i = 0;
      while i < ArraySize(this.m_computerSetup.m_mailsStructure) {
        widgetPackage.counter += this.GetEnabledDocumentsCount(this.m_computerSetup.m_mailsStructure[i].content, true);
        i += 1;
      };
      if ArraySize(this.m_computerSetup.m_mailsStructure) > 0 {
        widgetPackage.widgetName = "mails";
        widgetPackage.displayName = "Gameplay-Devices-Computers-Common-Inbox";
        widgetPackage.ownerID = this.GetID();
        widgetPackage.iconID = n"iconMail";
        ArrayPush(widgetPackages, widgetPackage);
      };
      widgetPackage.counter = 0;
    };
    if this.IsMenuEnabled(EComputerMenuType.FILES) {
      i = 0;
      while i < ArraySize(this.m_computerSetup.m_filesStructure) {
        widgetPackage.counter += this.GetEnabledDocumentsCount(this.m_computerSetup.m_filesStructure[i].content, true);
        i += 1;
      };
      if ArraySize(this.m_computerSetup.m_filesStructure) > 0 {
        widgetPackage.widgetName = "files";
        widgetPackage.displayName = "Gameplay-Devices-Computers-Common-Files";
        widgetPackage.ownerID = this.GetID();
        widgetPackage.iconID = n"iconFiles";
        ArrayPush(widgetPackages, widgetPackage);
      };
      widgetPackage.counter = 0;
    };
    if this.IsMenuEnabled(EComputerMenuType.NEWSFEED) {
      if ArraySize(this.m_computerSetup.m_newsFeed) > 0 {
        widgetPackage.counter = ArraySize(this.m_computerSetup.m_newsFeed);
        widgetPackage.widgetName = "newsFeed";
        widgetPackage.displayName = "Gameplay-Devices-Computers-Common-NewsFeed";
        widgetPackage.ownerID = this.GetID();
        widgetPackage.iconID = n"systemLogo";
        ArrayPush(widgetPackages, widgetPackage);
        widgetPackage.counter = 0;
      };
    };
    if this.IsMenuEnabled(EComputerMenuType.MAILS) {
      devices = this.GetImmediateSlaves();
      if ArraySize(devices) > 0 {
        widgetPackage.counter = this.GetEnabledDevicesCount(devices);
        widgetPackage.widgetName = "devices";
        widgetPackage.displayName = "Gameplay-Devices-Computers-Common-System";
        widgetPackage.ownerID = this.GetID();
        widgetPackage.iconID = n"iconNetwork";
        ArrayPush(widgetPackages, widgetPackage);
      };
      widgetPackage.counter = 0;
    };
    if this.IsMenuEnabled(EComputerMenuType.INTERNET) {
      widgetPackage.widgetName = "internet";
      widgetPackage.displayName = "Gameplay-Devices-Computers-Common-Internet";
      widgetPackage.ownerID = this.GetID();
      widgetPackage.iconID = n"iconInternet";
      ArrayPush(widgetPackages, widgetPackage);
    };
    return widgetPackages;
  }

  private final func IsDataElementValid(data: DataElement) -> Bool {
    return data.isEnabled && (data.journalPath.IsValid() || IsStringValid(data.title));
  }

  private final func GetEnabledDocumentsCount(documents: array<DataElement>, opt unredOnly: Bool) -> Int32 {
    let counter: Int32;
    let i: Int32 = 0;
    while i < ArraySize(documents) {
      if this.IsDataElementValid(documents[i]) {
        if unredOnly && documents[i].wasRead {
        } else {
          counter += 1;
        };
      };
      i += 1;
    };
    return counter;
  }

  private final func GetEnabledDevicesCount(devices: array<ref<DeviceComponentPS>>) -> Int32 {
    let counter: Int32;
    let currentDevice: ref<ScriptableDeviceComponentPS>;
    let i: Int32 = 0;
    while i < ArraySize(devices) {
      if IsDefined(devices[i] as ScriptableDeviceComponentPS) {
        currentDevice = devices[i] as ScriptableDeviceComponentPS;
        if currentDevice.IsDisabled() || this.IsPartOfAnyVirtualSystem(currentDevice) {
        } else {
          counter += 1;
        };
      };
      i += 1;
    };
    return counter + this.GetVirtualSystemsCount();
  }

  public final const func GetFileStructure(out data: ComputerUIData) -> Void {
    data.mails = this.m_computerSetup.m_mailsStructure;
    data.files = this.m_computerSetup.m_filesStructure;
  }

  public final const func GetOpenedMailAdress() -> SDocumentAdress {
    return this.m_openedMailAdress;
  }

  public final const func GetOpenedFileAdress() -> SDocumentAdress {
    return this.m_openedFileAdress;
  }

  public final const func GetInternetData() -> SInternetData {
    return this.m_computerSetup.m_internetSubnet;
  }

  public final func SetOpenedMailAdress(documentAdress: SDocumentAdress) -> Void {
    let wasAlreadyRed: Bool;
    if documentAdress.folderID >= 0 && documentAdress.documentID >= 0 {
      this.m_openedMailAdress = documentAdress;
      wasAlreadyRed = this.m_computerSetup.m_mailsStructure[documentAdress.folderID].content[documentAdress.documentID].wasRead;
      this.m_computerSetup.m_mailsStructure[documentAdress.folderID].content[documentAdress.documentID].wasRead = true;
      if !wasAlreadyRed {
        this.RequestMenuButtonWidgetsUpdate(this.GetBlackboard());
      };
    };
  }

  public final func SetOpenedFileAdress(documentAdress: SDocumentAdress) -> Void {
    let wasAlreadyRed: Bool;
    if documentAdress.folderID >= 0 && documentAdress.documentID >= 0 {
      this.m_openedFileAdress = documentAdress;
      wasAlreadyRed = this.m_computerSetup.m_mailsStructure[documentAdress.folderID].content[documentAdress.documentID].wasRead;
      this.m_computerSetup.m_filesStructure[documentAdress.folderID].content[documentAdress.documentID].wasRead = true;
      if !wasAlreadyRed {
        this.RequestMenuButtonWidgetsUpdate(this.GetBlackboard());
      };
    };
  }

  public final func ClearOpenedMailAdress() -> Void {
    let invalidAdres: SDocumentAdress;
    this.m_openedMailAdress = invalidAdres;
  }

  public final func ClearOpenedFileAdress() -> Void {
    let invalidAdres: SDocumentAdress;
    this.m_openedFileAdress = invalidAdres;
  }

  public final func EnableDocument(documentType: EDocumentType, documentAdress: SDocumentAdress, isEnabled: Bool) -> Void {
    let shouldRefresh: Bool;
    if Equals(documentType, EDocumentType.MAIL) {
      shouldRefresh = NotEquals(this.m_computerSetup.m_mailsStructure[documentAdress.folderID].content[documentAdress.documentID].isEnabled, isEnabled);
      this.m_computerSetup.m_mailsStructure[documentAdress.folderID].content[documentAdress.documentID].isEnabled = isEnabled;
    } else {
      shouldRefresh = NotEquals(this.m_computerSetup.m_filesStructure[documentAdress.folderID].content[documentAdress.documentID].isEnabled, isEnabled);
      this.m_computerSetup.m_filesStructure[documentAdress.folderID].content[documentAdress.documentID].isEnabled = isEnabled;
    };
    if shouldRefresh {
      this.RequestMenuButtonWidgetsUpdate(this.GetBlackboard());
      this.RefreshUI(this.GetBlackboard());
    };
  }

  public final func EnableDocumentsInFolder(documentType: EDocumentType, folderID: Int32, isEnabled: Bool) -> Void {
    let i: Int32;
    let shouldRefresh: Bool;
    if Equals(documentType, EDocumentType.MAIL) {
      i = 0;
      while i < ArraySize(this.m_computerSetup.m_mailsStructure[folderID].content) {
        shouldRefresh = NotEquals(this.m_computerSetup.m_mailsStructure[folderID].content[i].isEnabled, isEnabled);
        this.m_computerSetup.m_mailsStructure[folderID].content[i].isEnabled = isEnabled;
        i += 1;
      };
    } else {
      i = 0;
      while i < ArraySize(this.m_computerSetup.m_filesStructure[folderID].content) {
        shouldRefresh = NotEquals(this.m_computerSetup.m_filesStructure[folderID].content[i].isEnabled, isEnabled);
        this.m_computerSetup.m_filesStructure[folderID].content[i].isEnabled = isEnabled;
        i += 1;
      };
    };
    if shouldRefresh {
      this.RequestMenuButtonWidgetsUpdate(this.GetBlackboard());
      this.RefreshUI(this.GetBlackboard());
    };
  }

  public final const func GetDocumentAdressByName(documentType: EDocumentType, documentName: CName) -> SDocumentAdress {
    let adress: SDocumentAdress;
    let i: Int32;
    let k: Int32;
    if Equals(documentType, EDocumentType.MAIL) {
      i = 0;
      while i < ArraySize(this.m_computerSetup.m_mailsStructure) {
        k = 0;
        while k < ArraySize(this.m_computerSetup.m_mailsStructure[i].content) {
          if Equals(this.m_computerSetup.m_mailsStructure[i].content[k].documentName, documentName) {
            adress.folderID = i;
            adress.documentID = k;
          } else {
            k += 1;
          };
        };
        i += 1;
      };
    } else {
      i = 0;
      while i < ArraySize(this.m_computerSetup.m_filesStructure) {
        k = 0;
        while k < ArraySize(this.m_computerSetup.m_filesStructure[i].content) {
          if Equals(this.m_computerSetup.m_filesStructure[i].content[k].documentName, documentName) {
            adress.folderID = i;
            adress.documentID = k;
          } else {
            k += 1;
          };
        };
        i += 1;
      };
    };
    return adress;
  }

  public final func EnableDocumentsByName(documentType: EDocumentType, documentName: CName, isEnabled: Bool) -> Void {
    let i: Int32;
    let k: Int32;
    let shouldRefresh: Bool;
    if Equals(documentType, EDocumentType.MAIL) {
      i = 0;
      while i < ArraySize(this.m_computerSetup.m_mailsStructure) {
        k = 0;
        while k < ArraySize(this.m_computerSetup.m_mailsStructure[i].content) {
          if NotEquals(this.m_computerSetup.m_mailsStructure[i].content[k].documentName, documentName) {
          } else {
            if !shouldRefresh {
              shouldRefresh = NotEquals(this.m_computerSetup.m_mailsStructure[i].content[k].isEnabled, isEnabled);
            };
            this.m_computerSetup.m_mailsStructure[i].content[k].isEnabled = isEnabled;
          };
          k += 1;
        };
        i += 1;
      };
    } else {
      i = 0;
      while i < ArraySize(this.m_computerSetup.m_filesStructure) {
        k = 0;
        while k < ArraySize(this.m_computerSetup.m_filesStructure[i].content) {
          if NotEquals(this.m_computerSetup.m_filesStructure[i].content[k].documentName, documentName) {
          } else {
            if !shouldRefresh {
              shouldRefresh = NotEquals(this.m_computerSetup.m_filesStructure[i].content[k].isEnabled, isEnabled);
            };
            this.m_computerSetup.m_filesStructure[i].content[k].isEnabled = isEnabled;
          };
          k += 1;
        };
        i += 1;
      };
    };
    if shouldRefresh {
      this.RequestMenuButtonWidgetsUpdate(this.GetBlackboard());
      this.RefreshUI(this.GetBlackboard());
    };
  }

  public final func EncryptFile(documentAdress: SDocumentAdress) -> Void {
    this.m_computerSetup.m_filesStructure[documentAdress.folderID].content[documentAdress.documentID].isEncrypted = true;
  }

  public final func DecryptFile(documentAdress: SDocumentAdress) -> Void {
    this.m_computerSetup.m_filesStructure[documentAdress.folderID].content[documentAdress.documentID].isEncrypted = false;
  }

  public final func EncryptMail(documentAdress: SDocumentAdress) -> Void {
    this.m_computerSetup.m_mailsStructure[documentAdress.folderID].content[documentAdress.documentID].isEncrypted = true;
  }

  public final func DecryptMail(documentAdress: SDocumentAdress) -> Void {
    this.m_computerSetup.m_mailsStructure[documentAdress.folderID].content[documentAdress.documentID].isEncrypted = false;
  }

  public final func PushData(data: ComputerPersistentData) -> Void;

  public func OnAuthorizeUser(evt: ref<AuthorizeUser>) -> EntityNotificationType {
    let notifier: ref<ActionNotifier> = new ActionNotifier();
    notifier.SetAll();
    if this.UserAuthorizationAttempt(evt.GetExecutor().GetEntityID(), evt.GetEnteredPassword()) {
      this.ResolveOtherSkillchecks();
    };
    this.Notify(notifier, evt);
    return EntityNotificationType.DoNotNotifyEntity;
  }

  protected func OnFillTakeOverChainBBoardEvent(evt: ref<FillTakeOverChainBBoardEvent>) -> EntityNotificationType {
    this.FillTakeOverChainBB();
    return EntityNotificationType.DoNotNotifyEntity;
  }

  public func TurnAuthorizationModuleOFF() -> Void {
    this.m_authorizationProperties.m_isAuthorizationModuleOn = false;
    this.m_computerSetup.m_ignoreSlaveAuthorizationModule = true;
  }

  protected final func GetJournalMailEntry(dataElement: DataElement) -> wref<JournalEmail> {
    let journalEmail: wref<JournalEmail>;
    let journalHash: Uint32;
    let journalManager: ref<JournalManager>;
    if dataElement.journalPath == null {
      return journalEmail;
    };
    journalHash = dataElement.journalPath.GetHash();
    journalManager = GameInstance.GetJournalManager(this.GetGameInstance());
    return journalManager.GetEntry(journalHash) as JournalEmail;
  }

  protected final func GetJournalFileEntry(dataElement: DataElement) -> wref<JournalFile> {
    let journalFile: wref<JournalFile>;
    let journalHash: Uint32;
    let journalManager: ref<JournalManager>;
    if dataElement.journalPath == null {
      return journalFile;
    };
    journalHash = dataElement.journalPath.GetHash();
    journalManager = GameInstance.GetJournalManager(this.GetGameInstance());
    return journalManager.GetEntry(journalHash) as JournalFile;
  }

  public func OnToggleZoomInteraction(evt: ref<ToggleZoomInteraction>) -> EntityNotificationType {
    this.SetIsInSleepMode(false);
    return this.OnToggleZoomInteraction(evt);
  }

  public func OnQuestForceCameraZoom(evt: ref<QuestForceCameraZoom>) -> EntityNotificationType {
    if FromVariant(evt.prop.first) {
      this.SetIsInSleepMode(false);
    };
    return this.OnQuestForceCameraZoom(evt);
  }
}
