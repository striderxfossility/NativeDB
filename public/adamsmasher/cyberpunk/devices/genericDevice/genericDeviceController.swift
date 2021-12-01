
public class QuestCustomAction extends ActionName {

  public final func SetProperties(actionID: CName) -> Void {
    this.actionName = n"QuestCustomAction";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Name(n"actionID", actionID);
  }
}

public class QuestToggleCustomAction extends ActionName {

  public final func SetProperties(actionID: CName, enable: Bool) -> Void {
    if enable {
      this.actionName = n"EnableCustomAction";
    } else {
      this.actionName = n"DisableCustomAction";
    };
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Name(n"actionID", actionID);
  }
}

public class CustomDeviceAction extends ActionBool {

  public final func SetProperties(customActionName: CName, displayName: CName) -> Void {
    if !IsNameValid(customActionName) {
      this.actionName = n"wrong_name";
    };
    this.actionName = customActionName;
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(customActionName, true, displayName, displayName);
  }

  public func SetObjectActionID(id: TweakDBID) -> Void {
    this.m_objectActionID = id;
    this.ProduceInteractionPart();
  }

  public final static func IsDefaultConditionMet(device: ref<ScriptableDeviceComponentPS>, context: GetActionsContext, actionData: SDeviceActionCustomData) -> Bool {
    if CustomDeviceAction.IsAvailable(device, actionData) && CustomDeviceAction.IsClearanceValid(context.clearance) {
      return true;
    };
    return false;
  }

  public final static func IsAvailable(device: ref<ScriptableDeviceComponentPS>, actionData: SDeviceActionCustomData) -> Bool {
    if device.IsDisabled() {
      return false;
    };
    if device.IsON() && actionData.On {
      return true;
    };
    if device.IsOFF() && actionData.Off {
      return true;
    };
    if device.IsUnpowered() && actionData.Unpowered {
      return true;
    };
    return false;
  }

  public final static func IsClearanceValid(clearance: ref<Clearance>) -> Bool {
    if Clearance.IsInRange(clearance, DefaultActionsParametersHolder.GetQuestClearance()) {
      return true;
    };
    return false;
  }

  public final func IsCustomClearanceValid(clearance: ref<Clearance>) -> Bool {
    if Clearance.IsInRange(clearance, this.clearanceLevel) {
      return true;
    };
    return false;
  }

  public func GetActivationTime() -> Float {
    if this.IsQuickHack() {
      return this.GetActivationTime();
    };
    return 0.00;
  }
}

public class GenericDeviceController extends ScriptableDC {

  protected const func GetPS() -> ref<GameComponentPS> {
    return this.GetBasePS();
  }
}

public class GenericDeviceControllerPS extends ScriptableDeviceComponentPS {

  @attrib(category, "Senses")
  private persistent let m_isRecognizableBySenses: Bool;

  @attrib(category, "Device Operations")
  protected persistent let m_genericDeviceActionsSetup: GenericDeviceActionsData;

  protected inline let m_genericDeviceSkillChecks: ref<GenericContainer>;

  @attrib(category, "UI")
  @attrib(customEditor, "TweakDBGroupInheritance;DeviceWidgetDefinition")
  public edit let m_deviceWidgetRecord: TweakDBID;

  @attrib(category, "UI")
  @attrib(customEditor, "TweakDBGroupInheritance;ThumbnailWidgetDefinition")
  public edit let m_thumbnailWidgetRecord: TweakDBID;

  private persistent let m_performedCustomActionsIDs: array<CName>;

  protected cb func OnInstantiated() -> Bool {
    super.OnInstantiated();
    if !IsStringValid(this.m_deviceName) {
      this.m_deviceName = "LocKey#42164";
    };
  }

  protected func GameAttached() -> Void;

  protected func LogicReady() -> Void {
    this.LogicReady();
    this.InitializeSkillChecks(this.m_genericDeviceSkillChecks);
  }

  protected final func ActionQuestCustomAction() -> ref<QuestCustomAction> {
    let action: ref<QuestCustomAction> = new QuestCustomAction();
    action.SetUp(this);
    action.SetProperties(n"InvalidID");
    action.AddDeviceName(this.m_deviceName);
    action.clearanceLevel = DefaultActionsParametersHolder.GetQuestClearance();
    return action;
  }

  protected final func ActionQuestToggleCustomAction(enable: Bool) -> ref<QuestToggleCustomAction> {
    let action: ref<QuestToggleCustomAction> = new QuestToggleCustomAction();
    action.SetUp(this);
    action.SetProperties(n"InvalidID", enable);
    action.AddDeviceName(this.m_deviceName);
    action.clearanceLevel = DefaultActionsParametersHolder.GetQuestClearance();
    return action;
  }

  protected final func ActionCustom(actionData: SDeviceActionCustomData) -> ref<CustomDeviceAction> {
    let action: ref<CustomDeviceAction>;
    let displayName: String;
    let tweakDBName: String;
    if TDBID.IsValid(actionData.displayNameRecord) {
      displayName = LocKeyToString(TweakDBInterface.GetInteractionBaseRecord(actionData.displayNameRecord).Caption());
    } else {
      tweakDBName = actionData.displayName;
    };
    action = new CustomDeviceAction();
    action.clearanceLevel = actionData.customClearance;
    action.SetUp(this);
    action.SetProperties(actionData.actionID, StringToName(displayName));
    action.AddDeviceName(this.m_deviceName);
    if TDBID.IsValid(actionData.objectActionRecord) {
      action.SetObjectActionID(actionData.objectActionRecord);
    } else {
      if actionData.isQuickHack {
        action.SetObjectActionID(t"DeviceAction.MalfunctionClassHack");
      };
    };
    if actionData.hasInteraction || actionData.isQuickHack || actionData.isSpiderbotAction {
      action.CreateCustomInteraction(tweakDBName, tweakDBName, actionData.displayNameRecord, actionData.displayNameRecord);
    };
    if actionData.hasUI {
      if TDBID.IsValid(actionData.widgetRecord) {
        action.CreateActionWidgetPackage(actionData.widgetRecord);
      } else {
        action.CreateActionWidgetPackage();
      };
    };
    return action;
  }

  protected final func ActionTogglePower(actionData: SDeviceActionBoolData) -> ref<TogglePower> {
    let actionNameOnFalse: TweakDBID;
    let actionNameOnTrue: TweakDBID;
    let tweakDBNameOnFalse: String;
    let tweakDBNameOnTrue: String;
    let action: ref<TogglePower> = new TogglePower();
    if TDBID.IsValid(actionData.nameOnTrueRecord) {
      actionNameOnTrue = actionData.nameOnTrueRecord;
    } else {
      tweakDBNameOnTrue = actionData.nameOnTrue;
      actionNameOnTrue = TDBID.Create("Interactions." + tweakDBNameOnTrue);
    };
    if TDBID.IsValid(actionData.nameOnFalseRecord) {
      actionNameOnFalse = actionData.nameOnFalseRecord;
    } else {
      tweakDBNameOnFalse = actionData.nameOnFalse;
      actionNameOnTrue = TDBID.Create("Interactions." + tweakDBNameOnFalse);
    };
    action.clearanceLevel = DefaultActionsParametersHolder.GetTogglePowerClearance();
    action.SetUp(this);
    action.SetProperties(this.m_deviceState, actionNameOnTrue, actionNameOnFalse);
    action.AddDeviceName(this.m_deviceName);
    if TDBID.IsValid(actionData.objectActionRecord) {
      action.SetObjectActionID(actionData.objectActionRecord);
    } else {
      if actionData.isQuickHack {
        action.SetObjectActionID(t"DeviceAction.ToggleStateClassHack");
      };
    };
    if actionData.hasInteraction || actionData.isQuickHack {
      action.CreateCustomInteraction(tweakDBNameOnTrue, tweakDBNameOnFalse, actionData.nameOnTrueRecord, actionData.nameOnFalseRecord);
    };
    if actionData.hasUI {
      if TDBID.IsValid(actionData.widgetRecord) {
        action.CreateActionWidgetPackage(actionData.widgetRecord);
      } else {
        action.CreateActionWidgetPackage();
      };
    };
    return action;
  }

  public final func ActionToggleON(actionData: SDeviceActionBoolData) -> ref<ToggleON> {
    let actionNameOnFalse: TweakDBID;
    let actionNameOnTrue: TweakDBID;
    let tweakDBNameOnFalse: String;
    let tweakDBNameOnTrue: String;
    let action: ref<ToggleON> = new ToggleON();
    if TDBID.IsValid(actionData.nameOnTrueRecord) {
      actionNameOnTrue = actionData.nameOnTrueRecord;
    } else {
      tweakDBNameOnTrue = actionData.nameOnTrue;
      actionNameOnTrue = TDBID.Create("Interactions." + tweakDBNameOnTrue);
    };
    if TDBID.IsValid(actionData.nameOnFalseRecord) {
      actionNameOnFalse = actionData.nameOnFalseRecord;
    } else {
      tweakDBNameOnFalse = actionData.nameOnFalse;
      actionNameOnTrue = TDBID.Create("Interactions." + tweakDBNameOnFalse);
    };
    action.clearanceLevel = DefaultActionsParametersHolder.GetTogglePowerClearance();
    action.SetUp(this);
    action.SetProperties(this.m_deviceState, actionNameOnTrue, actionNameOnFalse);
    action.AddDeviceName(this.m_deviceName);
    if TDBID.IsValid(actionData.objectActionRecord) {
      action.SetObjectActionID(actionData.objectActionRecord);
    } else {
      if actionData.isQuickHack {
        action.SetObjectActionID(t"DeviceAction.ToggleStateClassHack");
      };
    };
    if actionData.hasInteraction || actionData.isQuickHack {
      action.CreateCustomInteraction(tweakDBNameOnTrue, tweakDBNameOnFalse, actionData.nameOnTrueRecord, actionData.nameOnFalseRecord);
    };
    if actionData.hasUI {
      if TDBID.IsValid(actionData.widgetRecord) {
        action.CreateActionWidgetPackage(actionData.widgetRecord);
      } else {
        action.CreateActionWidgetPackage();
      };
    };
    return action;
  }

  public func GetActions(out actions: array<ref<DeviceAction>>, context: GetActionsContext) -> Bool {
    let action: ref<DeviceAction>;
    let customAction: ref<CustomDeviceAction>;
    let i: Int32;
    if !this.GetActions(actions, context) {
      return false;
    };
    if IsDefined(context.processInitiatorObject) && !this.IsUserAuthorized(context.processInitiatorObject.GetEntityID()) {
      return false;
    };
    if ToggleON.IsDefaultConditionMet(this, context) {
      if Equals(context.requestType, gamedeviceRequestType.Direct) && this.m_genericDeviceActionsSetup.m_stateActionsOverrides.toggleON.hasInteraction {
        action = this.ActionToggleON(this.m_genericDeviceActionsSetup.m_stateActionsOverrides.toggleON);
        this.m_genericDeviceActionsSetup.m_stateActionsOverrides.toggleON.currentDisplayName = StringToName(action.GetCurrentDisplayString());
        this.m_genericDeviceActionsSetup.m_stateActionsOverrides.toggleON.interactionRecord = this.GetRecordName(action);
      } else {
        if NotEquals(context.requestType, gamedeviceRequestType.Direct) && NotEquals(context.requestType, gamedeviceRequestType.Remote) {
          action = this.ActionToggleON(this.m_genericDeviceActionsSetup.m_stateActionsOverrides.toggleON);
          this.m_genericDeviceActionsSetup.m_stateActionsOverrides.toggleON.currentDisplayName = StringToName(action.GetCurrentDisplayString());
          this.m_genericDeviceActionsSetup.m_stateActionsOverrides.toggleON.interactionRecord = this.GetRecordName(action);
        };
      };
      if action != null {
        ArrayPush(actions, action);
      };
    };
    if TogglePower.IsDefaultConditionMet(this, context) {
      action = null;
      if Equals(context.requestType, gamedeviceRequestType.Direct) && this.m_genericDeviceActionsSetup.m_stateActionsOverrides.togglePower.hasInteraction {
        action = this.ActionTogglePower(this.m_genericDeviceActionsSetup.m_stateActionsOverrides.togglePower);
        this.m_genericDeviceActionsSetup.m_stateActionsOverrides.togglePower.currentDisplayName = StringToName(action.GetCurrentDisplayString());
        this.m_genericDeviceActionsSetup.m_stateActionsOverrides.togglePower.interactionRecord = this.GetRecordName(action);
      } else {
        if NotEquals(context.requestType, gamedeviceRequestType.Direct) && NotEquals(context.requestType, gamedeviceRequestType.Remote) {
          action = this.ActionTogglePower(this.m_genericDeviceActionsSetup.m_stateActionsOverrides.togglePower);
          this.m_genericDeviceActionsSetup.m_stateActionsOverrides.togglePower.currentDisplayName = StringToName(action.GetCurrentDisplayString());
          this.m_genericDeviceActionsSetup.m_stateActionsOverrides.togglePower.interactionRecord = this.GetRecordName(action);
        };
      };
      if action != null {
        ArrayPush(actions, action);
      };
    };
    i = 0;
    while i < ArraySize(this.m_genericDeviceActionsSetup.m_customActions.actions) {
      if this.m_genericDeviceActionsSetup.m_customActions.actions[i].isEnabled && NotEquals(context.requestType, gamedeviceRequestType.Remote) {
        if Equals(context.requestType, gamedeviceRequestType.Direct) && !this.m_genericDeviceActionsSetup.m_customActions.actions[i].hasInteraction {
        } else {
          if Equals(context.requestType, gamedeviceRequestType.External) && !this.m_genericDeviceActionsSetup.m_customActions.actions[i].hasUI {
          } else {
            customAction = this.ActionCustom(this.m_genericDeviceActionsSetup.m_customActions.actions[i]);
            if CustomDeviceAction.IsAvailable(this, this.m_genericDeviceActionsSetup.m_customActions.actions[i]) {
              this.m_genericDeviceActionsSetup.m_customActions.actions[i].currentDisplayName = StringToName(customAction.GetCurrentDisplayString());
              this.m_genericDeviceActionsSetup.m_customActions.actions[i].interactionRecord = this.GetRecordName(customAction);
              ArrayPush(actions, customAction);
            };
          };
        };
      };
      i += 1;
    };
    this.SetActionIllegality(actions, this.m_illegalActions.regularActions);
    return true;
  }

  private final func GetRecordName(inputAction: ref<DeviceAction>) -> String {
    let action: ref<ScriptableDeviceAction> = inputAction as ScriptableDeviceAction;
    let interaction: InteractionChoice = action.GetInteractionChoice();
    let record: String = interaction.choiceMetaData.tweakDBName;
    return record;
  }

  public func GetQuestActionByName(actionName: CName) -> ref<DeviceAction> {
    let action: ref<DeviceAction> = this.GetQuestActionByName(actionName);
    if action == null {
      switch actionName {
        case n"QuestCustomAction":
          action = this.ActionQuestCustomAction();
          break;
        case n"EnableCustomAction":
          action = this.ActionQuestToggleCustomAction(true);
          break;
        case n"DisableCustomAction":
          action = this.ActionQuestToggleCustomAction(false);
      };
    };
    return action;
  }

  public func GetQuestActions(out actions: array<ref<DeviceAction>>, context: GetActionsContext) -> Void {
    this.GetQuestActions(actions, context);
    ArrayPush(actions, this.ActionQuestCustomAction());
    ArrayPush(actions, this.ActionQuestToggleCustomAction(true));
    ArrayPush(actions, this.ActionQuestToggleCustomAction(false));
  }

  protected const func CanCreateAnyQuickHackActions() -> Bool {
    let i: Int32;
    if this.m_genericDeviceActionsSetup.m_stateActionsOverrides.toggleON.isQuickHack || this.m_genericDeviceActionsSetup.m_stateActionsOverrides.togglePower.isQuickHack {
      return true;
    };
    i = 0;
    while i < ArraySize(this.m_genericDeviceActionsSetup.m_customActions.actions) {
      if this.m_genericDeviceActionsSetup.m_customActions.actions[i].isEnabled && this.m_genericDeviceActionsSetup.m_customActions.actions[i].isQuickHack {
        return true;
      };
      i += 1;
    };
    return false;
  }

  protected func GetQuickHackActions(out actions: array<ref<DeviceAction>>, context: GetActionsContext) -> Void {
    let actionON: ref<ScriptableDeviceAction>;
    let actionPower: ref<ScriptableDeviceAction>;
    let customAction: ref<CustomDeviceAction>;
    let i: Int32;
    if this.m_genericDeviceActionsSetup.m_stateActionsOverrides.toggleON.isQuickHack && ToggleON.IsDefaultConditionMet(this, context) {
      actionON = this.ActionToggleON(this.m_genericDeviceActionsSetup.m_stateActionsOverrides.toggleON);
    };
    if this.m_genericDeviceActionsSetup.m_stateActionsOverrides.togglePower.isQuickHack && TogglePower.IsAvailable(this) {
      actionPower = this.ActionTogglePower(this.m_genericDeviceActionsSetup.m_stateActionsOverrides.togglePower);
    };
    if actionON != null {
      ArrayPush(actions, actionON);
    };
    if actionPower != null {
      ArrayPush(actions, actionPower);
    };
    i = 0;
    while i < ArraySize(this.m_genericDeviceActionsSetup.m_customActions.actions) {
      if this.m_genericDeviceActionsSetup.m_customActions.actions[i].isEnabled && this.m_genericDeviceActionsSetup.m_customActions.actions[i].isQuickHack {
        customAction = this.ActionCustom(this.m_genericDeviceActionsSetup.m_customActions.actions[i]);
        if CustomDeviceAction.IsAvailable(this, this.m_genericDeviceActionsSetup.m_customActions.actions[i]) {
          ArrayPush(actions, customAction);
        };
      };
      i += 1;
    };
    this.FinalizeGetQuickHackActions(actions, context);
  }

  protected func CanCreateAnySpiderbotActions() -> Bool {
    let i: Int32;
    if this.m_genericDeviceActionsSetup.m_stateActionsOverrides.toggleON.isSpiderbotAction || this.m_genericDeviceActionsSetup.m_stateActionsOverrides.togglePower.isSpiderbotAction {
      return true;
    };
    i = 0;
    while i < ArraySize(this.m_genericDeviceActionsSetup.m_customActions.actions) {
      if this.m_genericDeviceActionsSetup.m_customActions.actions[i].isEnabled && this.m_genericDeviceActionsSetup.m_customActions.actions[i].isSpiderbotAction {
        return true;
      };
      i += 1;
    };
    return false;
  }

  protected func GetSpiderbotActions(out actions: array<ref<DeviceAction>>, context: GetActionsContext) -> Void {
    let actionON: ref<DeviceAction>;
    let actionPower: ref<DeviceAction>;
    let customAction: ref<CustomDeviceAction>;
    let globalNodeRef: GlobalNodeRef;
    let i: Int32;
    if this.m_genericDeviceActionsSetup.m_stateActionsOverrides.toggleON.isSpiderbotAction && ToggleON.IsDefaultConditionMet(this, context) {
      actionON = this.ActionToggleON(this.m_genericDeviceActionsSetup.m_stateActionsOverrides.toggleON);
    };
    if this.m_genericDeviceActionsSetup.m_stateActionsOverrides.togglePower.isSpiderbotAction && TogglePower.IsAvailable(this) {
      actionPower = this.ActionTogglePower(this.m_genericDeviceActionsSetup.m_stateActionsOverrides.togglePower);
    };
    if actionON != null {
      ArrayPush(actions, actionON);
    };
    if actionPower != null {
      ArrayPush(actions, actionPower);
    };
    i = 0;
    while i < ArraySize(this.m_genericDeviceActionsSetup.m_customActions.actions) {
      if this.m_genericDeviceActionsSetup.m_customActions.actions[i].isEnabled && this.m_genericDeviceActionsSetup.m_customActions.actions[i].isSpiderbotAction {
        customAction = this.ActionCustom(this.m_genericDeviceActionsSetup.m_customActions.actions[i]);
        if CustomDeviceAction.IsAvailable(this, this.m_genericDeviceActionsSetup.m_customActions.actions[i]) {
          globalNodeRef = ResolveNodeRefWithEntityID(this.m_genericDeviceActionsSetup.m_customActions.actions[i].spiderbotLocationOverrideReference, PersistentID.ExtractEntityID(this.GetID()));
          if GlobalNodeRef.IsDefined(globalNodeRef) {
            customAction.SetSpiderbotLocationOverrideReference(this.m_genericDeviceActionsSetup.m_customActions.actions[i].spiderbotLocationOverrideReference);
          };
          ArrayPush(actions, customAction);
        };
      };
      i += 1;
    };
    this.MarkActionsAsSpiderbotActions(actions);
  }

  public final func StorePerformedCustomActionID(ID: CName) -> Void {
    if ArrayContains(this.m_performedCustomActionsIDs, ID) {
      ArrayRemove(this.m_performedCustomActionsIDs, ID);
    };
    ArrayPush(this.m_performedCustomActionsIDs, ID);
  }

  public final func ResetPerformedCustomActionsStorage() -> Void {
    ArrayClear(this.m_performedCustomActionsIDs);
  }

  private final const func HasCustomActionStored(ID: CName) -> Bool {
    return ArrayContains(this.m_performedCustomActionsIDs, ID);
  }

  public final func ResolveCustomAction(actionID: CName) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_genericDeviceActionsSetup.m_customActions.actions) {
      if Equals(this.m_genericDeviceActionsSetup.m_customActions.actions[i].actionID, actionID) {
        if this.m_genericDeviceActionsSetup.m_customActions.actions[i].disableOnUse {
          this.m_genericDeviceActionsSetup.m_customActions.actions[i].isEnabled = false;
        };
      };
      i += 1;
    };
  }

  public final func ResolveFactOnCustomAction(factName: CName) -> Bool {
    let isEnabled: Bool;
    let wasChanged: Bool;
    let i: Int32 = 0;
    while i < ArraySize(this.m_genericDeviceActionsSetup.m_customActions.actions) {
      if Equals(factName, this.m_genericDeviceActionsSetup.m_customActions.actions[i].factToEnableName) {
        isEnabled = GameInstance.GetQuestsSystem(this.GetGameInstance()).GetFact(this.m_genericDeviceActionsSetup.m_customActions.actions[i].factToEnableName) > 0;
        if NotEquals(this.m_genericDeviceActionsSetup.m_customActions.actions[i].isEnabled, isEnabled) {
          wasChanged = true;
        };
        this.m_genericDeviceActionsSetup.m_customActions.actions[i].isEnabled = isEnabled;
      };
      i += 1;
    };
    if wasChanged {
      this.DetermineInitialPlaystyle();
      this.NotifyParents_Event();
    };
    return wasChanged;
  }

  private final func ResolveFactOnCustomActionByIndex(index: Int32) -> Bool {
    let isEnabled: Bool;
    if index >= 0 && index < ArraySize(this.m_genericDeviceActionsSetup.m_customActions.actions) {
      isEnabled = GameInstance.GetQuestsSystem(this.GetGameInstance()).GetFact(this.m_genericDeviceActionsSetup.m_customActions.actions[index].factToEnableName) > 0;
      if NotEquals(this.m_genericDeviceActionsSetup.m_customActions.actions[index].isEnabled, isEnabled) {
        this.m_genericDeviceActionsSetup.m_customActions.actions[index].isEnabled = isEnabled;
        this.DetermineInitialPlaystyle();
        this.NotifyParents_Event();
        return true;
      };
    };
    return false;
  }

  public final func InitializeQuestDBCallbacksForCustomActions() -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_genericDeviceActionsSetup.m_customActions.actions) {
      if IsNameValid(this.m_genericDeviceActionsSetup.m_customActions.actions[i].factToEnableName) {
        this.m_genericDeviceActionsSetup.m_customActions.actions[i].callbackID = GameInstance.GetQuestsSystem(this.GetGameInstance()).RegisterEntity(this.m_genericDeviceActionsSetup.m_customActions.actions[i].factToEnableName, PersistentID.ExtractEntityID(this.GetID()));
        this.ResolveFactOnCustomActionByIndex(i);
      };
      i += 1;
    };
  }

  public final func UnInitializeQuestDBCallbacksForCustomActions() -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_genericDeviceActionsSetup.m_customActions.actions) {
      if IsNameValid(this.m_genericDeviceActionsSetup.m_customActions.actions[i].factToEnableName) {
        GameInstance.GetQuestsSystem(this.GetGameInstance()).UnregisterEntity(this.m_genericDeviceActionsSetup.m_customActions.actions[i].factToEnableName, this.m_genericDeviceActionsSetup.m_customActions.actions[i].callbackID);
      };
      i += 1;
    };
  }

  public final const func GetPerformedCustomActionsStorage() -> array<CName> {
    return this.m_performedCustomActionsIDs;
  }

  protected func ResolveBaseActionOperation(action: ref<ScriptableDeviceAction>) -> Void {
    let customAction: ref<CustomDeviceAction> = action as CustomDeviceAction;
    if customAction == null {
      this.ResolveBaseActionOperation(action);
    } else {
      this.ResolveCustomActionOperation(customAction);
    };
  }

  private final func ResolveCustomActionOperation(action: ref<CustomDeviceAction>) -> Void {
    let evt: ref<PerformedAction> = new PerformedAction();
    evt.m_action = action;
    this.StorePerformedCustomActionID(action.GetActionName());
    this.GetPersistencySystem().QueueEntityEvent(PersistentID.ExtractEntityID(this.GetID()), evt);
  }

  public func OnCustomAction(evt: ref<CustomDeviceAction>) -> EntityNotificationType {
    let cachedStatus: ref<BaseDeviceStatus>;
    let notifier: ref<ActionNotifier> = new ActionNotifier();
    notifier.SetNone();
    cachedStatus = this.GetDeviceStatusAction();
    if this.IsUnpowered() || this.IsDisabled() {
      return this.SendActionFailedEvent(evt, evt.GetRequesterID(), "Unpowered or Disabled");
    };
    if !IsFinal() {
      this.LogActionDetails(evt, cachedStatus);
    };
    this.Notify(notifier, evt);
    this.ResolveCustomAction(evt.GetActionName());
    return EntityNotificationType.SendThisEventToEntity;
  }

  public final func OnQuestCustomAction(evt: ref<QuestCustomAction>) -> EntityNotificationType {
    if this.IsDisabled() {
      return this.SendActionFailedEvent(evt, evt.GetRequesterID(), "Disabled");
    };
    this.UseNotifier(evt);
    return EntityNotificationType.SendThisEventToEntity;
  }

  public final func OnQuestToggleCustomAction(evt: ref<QuestToggleCustomAction>) -> EntityNotificationType {
    let enabled: Bool;
    let actionID: CName = FromVariant(evt.prop.first);
    if !IsNameValid(actionID) {
      return EntityNotificationType.DoNotNotifyEntity;
    };
    enabled = Equals(evt.GetActionName(), n"EnableCustomAction");
    if this.ToggleCustomAction(actionID, enabled) {
      return EntityNotificationType.SendThisEventToEntity;
    };
    return EntityNotificationType.DoNotNotifyEntity;
  }

  public final func OnToggleCustomActionEvent(evt: ref<ToggleCustomActionEvent>) -> EntityNotificationType {
    if this.ToggleCustomAction(evt.actionID, evt.enabled) {
      return EntityNotificationType.SendThisEventToEntity;
    };
    return EntityNotificationType.DoNotNotifyEntity;
  }

  private final func ToggleCustomAction(actionID: CName, enable: Bool) -> Bool {
    let wasChanged: Bool;
    let i: Int32 = 0;
    while i < ArraySize(this.m_genericDeviceActionsSetup.m_customActions.actions) {
      if Equals(this.m_genericDeviceActionsSetup.m_customActions.actions[i].actionID, actionID) {
        wasChanged = NotEquals(this.m_genericDeviceActionsSetup.m_customActions.actions[i].isEnabled, enable);
        this.m_genericDeviceActionsSetup.m_customActions.actions[i].isEnabled = enable;
        if wasChanged {
          this.DetermineInitialPlaystyle();
          wasChanged = false;
          this.NotifyParents_Event();
          return true;
        };
      };
      i += 1;
    };
    return false;
  }

  protected func ActionHacking(context: GetActionsContext) -> ref<ActionHacking> {
    let action: ref<ActionHacking> = this.ActionHacking(context);
    let displayName: String = this.GetSkillCheckActionDisplayName(action);
    if IsStringValid(displayName) {
      action.ResetCaption();
      action.CreateInteraction(context.processInitiatorObject, displayName);
    } else {
      action.CreateInteraction(context.processInitiatorObject);
    };
    return action;
  }

  protected func ResolveActionHackingCompleted(evt: ref<ActionHacking>) -> Void {
    this.ResolveActionHackingCompleted(evt);
    if NotEquals(evt.GetAttributeCheckType(), EDeviceChallengeSkill.Invalid) {
      this.ResolveSkillCheckAction(evt);
    };
  }

  protected func ActionEngineering(context: GetActionsContext) -> ref<ActionEngineering> {
    let action: ref<ActionEngineering> = this.ActionEngineering(context);
    let displayName: String = this.GetSkillCheckActionDisplayName(action);
    if IsStringValid(displayName) {
      action.ResetCaption();
      action.CreateInteraction(context.processInitiatorObject, displayName);
    } else {
      action.CreateInteraction(context.processInitiatorObject);
    };
    return action;
  }

  public func OnActionEngineering(evt: ref<ActionEngineering>) -> EntityNotificationType {
    if !evt.WasPassed() {
      return EntityNotificationType.DoNotNotifyEntity;
    };
    this.OnActionEngineering(evt);
    if evt.IsCompleted() {
      this.ResolveSkillCheckAction(evt);
      return EntityNotificationType.SendPSChangedEventToEntity;
    };
    return EntityNotificationType.DoNotNotifyEntity;
  }

  protected func ActionDemolition(context: GetActionsContext) -> ref<ActionDemolition> {
    let action: ref<ActionDemolition> = this.ActionDemolition(context);
    let displayName: String = this.GetSkillCheckActionDisplayName(action);
    if IsStringValid(displayName) {
      action.ResetCaption();
      action.CreateInteraction(context.processInitiatorObject, displayName);
    } else {
      action.CreateInteraction(context.processInitiatorObject);
    };
    return action;
  }

  public func OnActionDemolition(evt: ref<ActionDemolition>) -> EntityNotificationType {
    if !evt.WasPassed() {
      return EntityNotificationType.DoNotNotifyEntity;
    };
    this.OnActionDemolition(evt);
    if evt.IsCompleted() {
      this.ResolveSkillCheckAction(evt);
      return EntityNotificationType.SendPSChangedEventToEntity;
    };
    return EntityNotificationType.DoNotNotifyEntity;
  }

  protected func OnActivateDevice(evt: ref<ActivateDevice>) -> EntityNotificationType {
    this.OnActivateDevice(evt);
    return EntityNotificationType.SendThisEventToEntity;
  }

  private final func GetSkillCheckActionDisplayName(skillAction: ref<ActionSkillCheck>) -> String {
    let displayName: String;
    let i: Int32;
    let id: TweakDBID;
    let record: wref<InteractionBase_Record>;
    switch skillAction.GetAttributeCheckType() {
      case EDeviceChallengeSkill.Hacking:
        id = this.m_genericDeviceSkillChecks.m_hackingCheck.GetAlternativeName();
        break;
      case EDeviceChallengeSkill.Engineering:
        id = this.m_genericDeviceSkillChecks.m_engineeringCheck.GetAlternativeName();
        break;
      case EDeviceChallengeSkill.Athletics:
        id = this.m_genericDeviceSkillChecks.m_demolitionCheck.GetAlternativeName();
        break;
      default:
    };
    if TDBID.IsValid(id) {
      record = TweakDBInterface.GetInteractionBaseRecord(id);
      if IsDefined(record) {
        displayName = record.Name();
        if IsStringValid(displayName) {
          return displayName;
        };
      };
    };
    if NotEquals(this.m_genericDeviceActionsSetup.m_stateActionsOverrides.toggleON.attachedToSkillCheck, EDeviceChallengeSkill.Invalid) && Equals(this.m_genericDeviceActionsSetup.m_stateActionsOverrides.toggleON.attachedToSkillCheck, skillAction.GetAttributeCheckType()) {
      displayName = this.m_genericDeviceActionsSetup.m_stateActionsOverrides.toggleON.interactionRecord;
      return displayName;
    };
    if NotEquals(this.m_genericDeviceActionsSetup.m_stateActionsOverrides.togglePower.attachedToSkillCheck, EDeviceChallengeSkill.Invalid) && Equals(this.m_genericDeviceActionsSetup.m_stateActionsOverrides.togglePower.attachedToSkillCheck, skillAction.GetAttributeCheckType()) {
      displayName = this.m_genericDeviceActionsSetup.m_stateActionsOverrides.togglePower.interactionRecord;
      return displayName;
    };
    i = 0;
    while i < ArraySize(this.m_genericDeviceActionsSetup.m_customActions.actions) {
      if NotEquals(this.m_genericDeviceActionsSetup.m_customActions.actions[i].attachedToSkillCheck, EDeviceChallengeSkill.Invalid) && Equals(this.m_genericDeviceActionsSetup.m_customActions.actions[i].attachedToSkillCheck, skillAction.GetAttributeCheckType()) {
        displayName = this.m_genericDeviceActionsSetup.m_customActions.actions[i].interactionRecord;
        return displayName;
      };
      i += 1;
    };
    return displayName;
  }

  private final func ResolveSkillCheckAction(skillAction: ref<ActionSkillCheck>) -> Void {
    let action: ref<ScriptableDeviceAction>;
    let i: Int32;
    if NotEquals(this.m_genericDeviceActionsSetup.m_stateActionsOverrides.toggleON.attachedToSkillCheck, EDeviceChallengeSkill.Invalid) && Equals(this.m_genericDeviceActionsSetup.m_stateActionsOverrides.toggleON.attachedToSkillCheck, skillAction.GetAttributeCheckType()) {
      action = this.ActionToggleON(this.m_genericDeviceActionsSetup.m_stateActionsOverrides.toggleON);
      if IsDefined(action) {
        this.m_genericDeviceActionsSetup.m_stateActionsOverrides.toggleON.currentDisplayName = StringToName(action.GetCurrentDisplayString());
        action.RegisterAsRequester(PersistentID.ExtractEntityID(this.GetID()));
        action.SetExecutor(skillAction.GetExecutor());
        this.GetPersistencySystem().QueuePSDeviceEvent(action);
      };
    };
    if NotEquals(this.m_genericDeviceActionsSetup.m_stateActionsOverrides.togglePower.attachedToSkillCheck, EDeviceChallengeSkill.Invalid) && Equals(this.m_genericDeviceActionsSetup.m_stateActionsOverrides.togglePower.attachedToSkillCheck, skillAction.GetAttributeCheckType()) {
      action = this.ActionTogglePower(this.m_genericDeviceActionsSetup.m_stateActionsOverrides.togglePower);
      if IsDefined(action) {
        this.m_genericDeviceActionsSetup.m_stateActionsOverrides.togglePower.currentDisplayName = StringToName(action.GetCurrentDisplayString());
        action.RegisterAsRequester(PersistentID.ExtractEntityID(this.GetID()));
        action.SetExecutor(skillAction.GetExecutor());
        this.GetPersistencySystem().QueuePSDeviceEvent(action);
      };
    };
    i = 0;
    while i < ArraySize(this.m_genericDeviceActionsSetup.m_customActions.actions) {
      if NotEquals(this.m_genericDeviceActionsSetup.m_customActions.actions[i].attachedToSkillCheck, EDeviceChallengeSkill.Invalid) && Equals(this.m_genericDeviceActionsSetup.m_customActions.actions[i].attachedToSkillCheck, skillAction.GetAttributeCheckType()) {
        action = this.ActionCustom(this.m_genericDeviceActionsSetup.m_customActions.actions[i]);
        if IsDefined(action) {
          this.m_genericDeviceActionsSetup.m_customActions.actions[i].currentDisplayName = StringToName(action.GetCurrentDisplayString());
          action.RegisterAsRequester(PersistentID.ExtractEntityID(this.GetID()));
          action.SetExecutor(skillAction.GetExecutor());
          this.GetPersistencySystem().QueuePSDeviceEvent(action);
        };
      };
      i += 1;
    };
  }

  protected func GetInkWidgetTweakDBID(context: GetActionsContext) -> TweakDBID {
    if !this.IsUserAuthorized(context.processInitiatorObject.GetEntityID()) && !context.ignoresAuthorization {
      return this.GetInkWidgetTweakDBID(context);
    };
    if TDBID.IsValid(this.m_deviceWidgetRecord) {
      return this.m_deviceWidgetRecord;
    };
    return this.GetInkWidgetTweakDBID(context);
  }

  public func GetThumbnailWidget() -> SThumbnailWidgetPackage {
    let widgetData: SThumbnailWidgetPackage = this.GetThumbnailWidget();
    if TDBID.IsValid(this.m_thumbnailWidgetRecord) {
      widgetData.widgetTweakDBID = this.m_thumbnailWidgetRecord;
    };
    return widgetData;
  }

  public final const quest func WasCustomActionPerformed(actionID: CName) -> Bool {
    return this.HasCustomActionStored(actionID);
  }
}
