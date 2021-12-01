
public abstract class ObjectScanningDescription extends IScriptable {

  public const func GetGameplayDesription() -> TweakDBID {
    let id: TweakDBID;
    return id;
  }

  public const func GetCustomDesriptions() -> array<TweakDBID> {
    let ids: array<TweakDBID>;
    return ids;
  }

  public final const func IsValid() -> Bool {
    let customDescArr: array<TweakDBID> = this.GetCustomDesriptions();
    let gmplDesc: TweakDBID = this.GetGameplayDesription();
    return TDBID.IsValid(gmplDesc) || ArraySize(customDescArr) > 0;
  }
}

public class DeviceScanningDescription extends ObjectScanningDescription {

  @attrib(customEditor, "TweakDBGroupInheritance;device_scanning_data")
  protected persistent let DeviceGameplayDescription: TweakDBID;

  @attrib(customInnerTypeEditor, "TweakDBGroupInheritance;device_scanning_data")
  protected persistent const let DeviceCustomDescriptions: array<TweakDBID>;

  @attrib(customEditor, "TweakDBGroupInheritance;device_gameplay_role")
  public let DeviceGameplayRole: TweakDBID;

  @attrib(customInnerTypeEditor, "TweakDBGroupInheritance;device_role_action_desctiption")
  public let DeviceRoleActionsDescriptions: array<TweakDBID>;

  public const func GetGameplayDesription() -> TweakDBID {
    return this.DeviceGameplayDescription;
  }

  public const func GetCustomDesriptions() -> array<TweakDBID> {
    return this.DeviceCustomDescriptions;
  }

  public final const func GetDeviceRoleActionsDescriptions() -> array<TweakDBID> {
    return this.DeviceRoleActionsDescriptions;
  }
}

public class NPCScanningDescription extends ObjectScanningDescription {

  @attrib(customEditor, "TweakDBGroupInheritance;npc_scanning_data")
  protected edit persistent let NPCGameplayDescription: TweakDBID;

  @attrib(customInnerTypeEditor, "TweakDBGroupInheritance;npc_scanning_data")
  protected persistent const let NPCCustomDescriptions: array<TweakDBID>;

  public const func GetGameplayDesription() -> TweakDBID {
    return this.NPCGameplayDescription;
  }

  public const func GetCustomDesriptions() -> array<TweakDBID> {
    return this.NPCCustomDescriptions;
  }
}

public class ToggleClueConclusionEvent extends Event {

  @default(ToggleClueConclusionEvent, false)
  public let toggleConclusion: Bool;

  public let clueID: Int32;

  @default(ToggleClueConclusionEvent, true)
  public let updatePS: Bool;

  public final func GetFriendlyDescription() -> String {
    return "Toggle Conclusion";
  }
}

public class DisableScannerEvent extends Event {

  @default(DisableScannerEvent, true)
  public let isDisabled: Bool;

  public final func GetFriendlyDescription() -> String {
    return "Disable Scanner";
  }
}

public class DisableObjectDescriptionEvent extends Event {

  @default(DisableObjectDescriptionEvent, true)
  public let isDisabled: Bool;

  public final func GetFriendlyDescription() -> String {
    return "Disable Object Description";
  }
}

public class SetCustomObjectDescriptionEvent extends Event {

  private inline let m_objectDescription: ref<ObjectScanningDescription>;

  public final func GetFriendlyDescription() -> String {
    return "Set Custom Object Description";
  }

  public final func GetObjectDescription() -> ref<ObjectScanningDescription> {
    return this.m_objectDescription;
  }
}

public class ClearCustomObjectDescriptionEvent extends Event {

  public final func GetFriendlyDescription() -> String {
    return "Clear Custom Object Description";
  }
}

public class ToggleFocusClueEvent extends Event {

  public let clueIndex: Int32;

  public let isEnabled: Bool;

  @default(ToggleFocusClueEvent, EFocusClueInvestigationState.NONE)
  public let investigationState: EFocusClueInvestigationState;

  @default(ToggleFocusClueEvent, true)
  public let updatePS: Bool;

  public final func GetFriendlyDescription() -> String {
    return "Toggle Focus Clue";
  }
}

public class CluePSData extends IScriptable {

  private persistent let m_id: Int32;

  private persistent let m_isEnabled: Bool;

  private persistent let m_wasInspected: Bool;

  private persistent let m_isScanned: Bool;

  private persistent let m_conclusionQuestState: EConclusionQuestState;

  public final func SetupData(id: Int32, isEnabled: Bool, wasInspected: Bool, isScanned: Bool, conclusionQuestState: EConclusionQuestState) -> Void {
    this.m_id = id;
    this.m_isEnabled = isEnabled;
    this.m_wasInspected = wasInspected;
    if NotEquals(conclusionQuestState, EConclusionQuestState.Undefined) {
      this.m_conclusionQuestState = conclusionQuestState;
    };
  }

  public final const func GetID() -> Int32 {
    return this.m_id;
  }

  public final const func IsEnabled() -> Bool {
    return this.m_isEnabled;
  }

  public final const func IsScanned() -> Bool {
    return this.m_isEnabled;
  }

  public final const func WasInspected() -> Bool {
    return this.m_wasInspected;
  }

  public final const func GetConclusionState() -> EConclusionQuestState {
    return this.m_conclusionQuestState;
  }

  public final func SetConclusionState(state: EConclusionQuestState) -> Void {
    this.m_conclusionQuestState = state;
  }
}

public native class gameScanningComponentPS extends GameComponentPS {

  private persistent let m_storedClues: array<ref<CluePSData>>;

  private persistent let m_isScanningDisabled: Bool;

  @default(gameScanningComponentPS, true)
  private persistent let m_isDecriptionEnabled: Bool;

  private persistent let m_objectDescriptionOverride: ref<ObjectScanningDescription>;

  private final const func GetOwnerEntityWeak() -> wref<Entity> {
    return GameInstance.FindEntityByID(this.GetGameInstance(), this.GetMyEntityID());
  }

  private final const func GetMyEntityID() -> EntityID {
    return PersistentID.ExtractEntityID(this.GetID());
  }

  public final const func IsScanningDisabled() -> Bool {
    return this.m_isScanningDisabled;
  }

  public final const func IsDescriptionEnabled() -> Bool {
    return this.m_isDecriptionEnabled;
  }

  public final const func HasAnyStoredClues() -> Bool {
    return ArraySize(this.m_storedClues) > 0;
  }

  public final const func GetObjectDecriptionOverride() -> ref<ObjectScanningDescription> {
    return this.m_objectDescriptionOverride;
  }

  public final const func HasStoredClue(id: Int32) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(this.m_storedClues) {
      if id == this.m_storedClues[i].GetID() {
        return true;
      };
      i += 1;
    };
    return false;
  }

  public final const func GetStoredClueData(id: Int32, out data: ref<CluePSData>) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(this.m_storedClues) {
      if id == this.m_storedClues[i].GetID() {
        data = this.m_storedClues[i];
        return true;
      };
      i += 1;
    };
    return false;
  }

  public final const func UpdateFocusClueData(id: Int32, out clueData: FocusClueDefinition) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(this.m_storedClues) {
      if id == this.m_storedClues[i].GetID() {
        clueData.isEnabled = this.m_storedClues[i].IsEnabled();
        clueData.wasInspected = this.m_storedClues[i].WasInspected();
        clueData.conclusionQuestState = this.m_storedClues[i].GetConclusionState();
        return true;
      };
      i += 1;
    };
    return false;
  }

  public final func StoreClueData(id: Int32, clueData: FocusClueDefinition, isScanned: Bool) -> Void {
    let data: ref<CluePSData>;
    if !this.GetStoredClueData(id, data) {
      data = new CluePSData();
      ArrayPush(this.m_storedClues, data);
    };
    data.SetupData(id, clueData.isEnabled, clueData.wasInspected, isScanned, clueData.conclusionQuestState);
  }

  private final func OnLinkedClueUpdateEvent(evt: ref<linkedClueUpdateEvent>) -> EntityNotificationType {
    let data: ref<CluePSData>;
    evt.updatePS = false;
    if !this.GetStoredClueData(evt.linkedCluekData.clueIndex, data) {
      data = new CluePSData();
      ArrayPush(this.m_storedClues, data);
    };
    data.SetupData(evt.linkedCluekData.clueIndex, evt.linkedCluekData.isEnabled, evt.linkedCluekData.wasInspected, evt.linkedCluekData.isScanned, EConclusionQuestState.Undefined);
    return EntityNotificationType.SendThisEventToEntity;
  }

  private final func OnToggleFocusClue(evt: ref<ToggleFocusClueEvent>) -> EntityNotificationType {
    let data: ref<CluePSData>;
    let isInspected: Bool;
    evt.updatePS = false;
    if Equals(evt.investigationState, EFocusClueInvestigationState.INSPECTED) {
      isInspected = true;
    } else {
      isInspected = false;
    };
    if !this.GetStoredClueData(evt.clueIndex, data) {
      data = new CluePSData();
      ArrayPush(this.m_storedClues, data);
    };
    data.SetupData(evt.clueIndex, evt.isEnabled, isInspected, data.IsScanned(), EConclusionQuestState.Undefined);
    this.RequestFocusClueSystemUpdate(data);
    return EntityNotificationType.SendThisEventToEntity;
  }

  private final func OnClueStateChanged(evt: ref<FocusClueStateChangeEvent>) -> EntityNotificationType {
    let data: ref<CluePSData>;
    if !this.GetStoredClueData(evt.clueIndex, data) {
      data = new CluePSData();
      ArrayPush(this.m_storedClues, data);
    };
    data.SetupData(evt.clueIndex, evt.isEnabled, data.WasInspected(), data.IsScanned(), EConclusionQuestState.Undefined);
    this.RequestFocusClueSystemUpdate(data);
    return EntityNotificationType.SendThisEventToEntity;
  }

  private final func OnQuestToggleClueConclusion(evt: ref<ToggleClueConclusionEvent>) -> EntityNotificationType {
    let data: ref<CluePSData>;
    evt.updatePS = false;
    if this.GetStoredClueData(evt.clueID, data) {
      if evt.toggleConclusion {
        data.SetConclusionState(EConclusionQuestState.Active);
      } else {
        data.SetConclusionState(EConclusionQuestState.Inactive);
      };
    };
    return EntityNotificationType.SendThisEventToEntity;
  }

  private final func OnDisableScanner(evt: ref<DisableScannerEvent>) -> EntityNotificationType {
    this.m_isScanningDisabled = evt.isDisabled;
    return EntityNotificationType.SendThisEventToEntity;
  }

  private final func OnDisableObjectDescription(evt: ref<DisableObjectDescriptionEvent>) -> EntityNotificationType {
    this.m_isDecriptionEnabled = !evt.isDisabled;
    return EntityNotificationType.SendThisEventToEntity;
  }

  private final func OnClearCustomObjectDescription(evt: ref<ClearCustomObjectDescriptionEvent>) -> EntityNotificationType {
    this.m_objectDescriptionOverride = null;
    return EntityNotificationType.SendThisEventToEntity;
  }

  private final func OnSetCustomObjectDescription(evt: ref<SetCustomObjectDescriptionEvent>) -> EntityNotificationType {
    this.m_objectDescriptionOverride = evt.GetObjectDescription();
    return EntityNotificationType.SendThisEventToEntity;
  }

  public final const func GetFocusClueSystem() -> ref<FocusCluesSystem> {
    return GameInstance.GetScriptableSystemsContainer(this.GetGameInstance()).Get(n"FocusCluesSystem") as FocusCluesSystem;
  }

  private final func RequestFocusClueSystemUpdate(clueData: ref<CluePSData>) -> Void {
    let clueRequest: ref<UpdateLinkedClueskRequest>;
    let groupID: CName;
    let linkedClueData: LinkedFocusClueData;
    if this.GetOwnerEntityWeak() != null {
      return;
    };
    if this.GetFocusClueSystem().IsGroupped(this.GetMyEntityID(), groupID) {
      clueRequest = new UpdateLinkedClueskRequest();
      linkedClueData.ownerID = this.GetMyEntityID();
      linkedClueData.clueGroupID = groupID;
      linkedClueData.clueIndex = clueData.GetID();
      linkedClueData.isScanned = clueData.IsScanned();
      linkedClueData.wasInspected = clueData.WasInspected();
      linkedClueData.isEnabled = clueData.IsEnabled();
      clueRequest.linkedCluekData = linkedClueData;
      this.GetFocusClueSystem().QueueRequest(clueRequest);
    };
  }
}

public native class ScanningComponent extends GameComponent {

  private let m_isBraindanceClue: Bool;

  private let m_BraindanceLayer: braindanceVisionMode;

  private let m_isBraindanceBlocked: Bool;

  private let m_isBraindanceLayerUnlocked: Bool;

  private let m_isBraindanceTimelineUnlocked: Bool;

  private let m_isBraindanceActive: Bool;

  private let m_currentBraindanceLayer: Int32;

  private const let m_clues: array<FocusClueDefinition>;

  private inline let m_objectDescription: ref<ObjectScanningDescription>;

  @attrib(customEditor, "TweakDBGroupInheritance;device_descriptions.ScanningBarText")
  private let scanningBarText: TweakDBID;

  private let m_isFocusModeActive: Bool;

  private let m_currentHighlight: ref<FocusForcedHighlightData>;

  private let m_isHudManagerInitialized: Bool;

  private let m_isBeingScanned: Bool;

  private let m_isScanningCluesBlocked: Bool;

  @default(ScanningComponent, true)
  private let m_isEntityVisible: Bool;

  private let m_OnBraindanceVisionModeChangeCallback: ref<CallbackHandle>;

  private let m_OnBraindanceFppChangeCallback: ref<CallbackHandle>;

  public final native func GetScanningProgress() -> Float;

  public final native func GetTimeNeeded() -> Float;

  public final native func GetBoundingSphere() -> Sphere;

  public final native const func IsScanned() -> Bool;

  public final native const func IsScanning() -> Bool;

  public final native func SetIsScanned_Event(val: Bool) -> Void;

  public final native func UpdateTooltipData() -> Void;

  public final native const func IsBlocked() -> Bool;

  public final native func SetBlocked(isBlocked: Bool) -> Void;

  public final native const func GetScanningState() -> gameScanningState;

  public final native func SetScannableThroughWalls(isScannableThroughWalls: Bool) -> Void;

  private final func ToggleScanningBlocked(isBlocked: Bool) -> Void {
    if NotEquals(this.IsBlocked(), isBlocked) {
      this.SetBlocked(isBlocked);
    };
  }

  protected final func OnGameAttach() -> Void {
    let BraindanceBB: ref<IBlackboard>;
    this.InitializeQuestDBCallbacks();
    if this.m_isBraindanceClue {
      BraindanceBB = GameInstance.GetBlackboardSystem(this.GetOwner().GetGame()).Get(GetAllBlackboardDefs().Braindance);
      this.m_OnBraindanceVisionModeChangeCallback = BraindanceBB.RegisterListenerInt(GetAllBlackboardDefs().Braindance.activeBraindanceVisionMode, this, n"OnBraindanceVisionModeChange");
      this.m_OnBraindanceFppChangeCallback = BraindanceBB.RegisterListenerBool(GetAllBlackboardDefs().Braindance.IsFPP, this, n"OnBraindanceFppChange");
      this.EvaluateBraindanceClueState();
    };
    this.RestoreClueState();
  }

  protected final func OnGameDetach() -> Void {
    this.UnInitializeQuestDBCallbacks();
  }

  private final const func GetOwner() -> ref<GameObject> {
    return this.GetEntity() as GameObject;
  }

  private final const func GetMyPS() -> ref<gameScanningComponentPS> {
    return this.GetPS() as gameScanningComponentPS;
  }

  private final func RestoreClueState() -> Void {
    let hasPSData: Bool;
    let hasSystemData: Bool;
    let isGroupDisabled: Bool;
    let psData: FocusClueDefinition;
    let systemData: FocusClueDefinition;
    let i: Int32 = 0;
    while i < ArraySize(this.m_clues) {
      psData = this.m_clues[i];
      systemData = this.m_clues[i];
      hasPSData = this.GetMyPS().UpdateFocusClueData(i, psData);
      if this.IsClueLinked(i) {
        hasSystemData = this.GetFocusClueSystem().GetClueGroupData(systemData.clueGroupID, systemData);
        isGroupDisabled = this.GetFocusClueSystem().IsGroupDisabled(psData.clueGroupID);
        if hasPSData && hasSystemData && !this.GetFocusClueSystem().IsRegistered(this.GetOwner().GetEntityID(), psData.clueGroupID) {
          this.m_clues[i] = psData;
          this.RequestFocusClueSystemUpdate(i);
        } else {
          if hasPSData && isGroupDisabled {
            this.m_clues[i] = psData;
          } else {
            if hasSystemData {
              this.m_clues[i] = systemData;
            } else {
              if isGroupDisabled {
                this.m_clues[i].wasInspected = true;
                this.m_clues[i].isEnabled = false;
              } else {
                if hasPSData {
                  this.RegisterGrouppedClue(i);
                  if NotEquals(this.m_clues[i].isEnabled, psData.isEnabled) || NotEquals(this.m_clues[i].wasInspected, psData.wasInspected) {
                    this.m_clues[i] = psData;
                    this.RequestFocusClueSystemUpdate(i);
                  } else {
                    this.m_clues[i] = psData;
                  };
                };
              };
            };
          };
        };
        this.RegisterGrouppedClue(i);
      } else {
        if this.GetMyPS().UpdateFocusClueData(i, psData) {
          this.m_clues[i] = psData;
        };
      };
      i += 1;
    };
  }

  private final func ReEvaluateGrouppedCluesState() -> Bool {
    let systemData: FocusClueDefinition;
    let i: Int32 = 0;
    while i < ArraySize(this.m_clues) {
      systemData = this.m_clues[i];
      if this.IsClueLinked(i) {
        if this.GetFocusClueSystem().GetClueGroupData(systemData.clueGroupID, systemData) {
          if NotEquals(systemData.isEnabled, this.m_clues[i].isEnabled) || NotEquals(systemData.wasInspected, this.m_clues[i].wasInspected) {
            this.SetClueState(i, systemData.isEnabled, systemData.wasInspected, false, false);
            return true;
          };
        };
      };
      i += 1;
    };
    return false;
  }

  private final func RegisterGrouppedClue(clueIndex: Int32) -> Bool {
    let clueRequest: ref<RegisterLinkedCluekRequest>;
    let linkedClueData: LinkedFocusClueData;
    if !this.m_clues[clueIndex].isEnabled && this.m_clues[clueIndex].wasInspected {
      return false;
    };
    if !this.GetLinkedClueData(clueIndex, linkedClueData) {
      return false;
    };
    if IsNameValid(linkedClueData.clueGroupID) {
      if this.GetFocusClueSystem().IsRegistered(this.GetOwner().GetEntityID(), linkedClueData.clueGroupID) {
        return false;
      };
      clueRequest = new RegisterLinkedCluekRequest();
      clueRequest.linkedCluekData = linkedClueData;
      this.GetFocusClueSystem().QueueRequest(clueRequest);
    };
    return true;
  }

  public final const func GetLinkedClueData(clueIndex: Int32, out linkedClueData: LinkedFocusClueData) -> Bool {
    let clue: FocusClueDefinition;
    if !this.HasClueWithID(clueIndex) {
      return false;
    };
    clue = this.m_clues[clueIndex];
    if IsNameValid(clue.clueGroupID) {
      linkedClueData.clueGroupID = clue.clueGroupID;
      linkedClueData.ownerID = this.GetOwner().GetEntityID();
      linkedClueData.clueIndex = clueIndex;
      linkedClueData.isEnabled = clue.isEnabled;
      linkedClueData.wasInspected = clue.wasInspected;
      linkedClueData.isScanned = this.IsScanned();
      linkedClueData.psData.id = this.GetPersistentID();
      linkedClueData.psData.className = n"gameScanningComponentPS";
      return true;
    };
    return false;
  }

  public final const func IsBraindanceClue() -> Bool {
    return this.m_isBraindanceClue;
  }

  public final const func GetBraindanceLayer() -> braindanceVisionMode {
    return this.m_BraindanceLayer;
  }

  public final const func GetObjectDescription() -> ref<ObjectScanningDescription> {
    let objectDescriptionOverride: ref<ObjectScanningDescription> = this.GetMyPS().GetObjectDecriptionOverride();
    if objectDescriptionOverride != null {
      return objectDescriptionOverride;
    };
    return this.m_objectDescription;
  }

  public final const func IsObjectDescriptionEnabled() -> Bool {
    return this.GetMyPS().IsDescriptionEnabled();
  }

  public final const func HasValidObjectDescription() -> Bool {
    let data: ref<ObjectScanningDescription> = this.GetObjectDescription();
    return data != null && data.IsValid();
  }

  public final const func GetAllClues() -> array<FocusClueDefinition> {
    return this.m_clues;
  }

  public final const func GetScanningBarTextTweak() -> TweakDBID {
    return this.scanningBarText;
  }

  public final const func GetAvailableClueIndex() -> Int32 {
    let i: Int32 = 0;
    while i < ArraySize(this.m_clues) {
      if this.m_clues[i].isEnabled {
        return i;
      };
      i += 1;
    };
    return -1;
  }

  public final func GetScannableObjects(out arr: array<ScanningTooltipElementDef>) -> Void {
    let i: Int32;
    let k: Int32;
    let objectData: ScanningTooltipElementDef;
    if this.IsScanningCluesBlocked() {
      return;
    };
    i = 0;
    while i < ArraySize(this.m_clues) {
      if this.m_clues[i].isEnabled {
        k = 0;
        while i < ArraySize(this.m_clues[i].extendedClueRecords) {
          objectData.recordID = this.m_clues[i].extendedClueRecords[k].clueRecord;
          objectData.timePct = this.m_clues[i].extendedClueRecords[k].percentage;
          if TDBID.IsValid(objectData.recordID) {
            ArrayPush(arr, objectData);
          };
          k += 1;
        };
        if this.IsConclusionActive(i) {
          if ArraySize(this.m_clues[i].extendedClueRecords) > 0 {
            objectData.timePct = 1.00;
          } else {
            objectData.timePct = 0.00;
          };
          objectData.recordID = this.m_clues[i].clueRecord;
          if TDBID.IsValid(objectData.recordID) {
            ArrayPush(arr, objectData);
          };
        };
        return;
      };
      i += 1;
    };
  }

  public final func GetScannableDataForSingleClueByIndex(index: Int32, out conclusionData: ScanningTooltipElementDef) -> array<ScanningTooltipElementDef> {
    let arr: array<ScanningTooltipElementDef>;
    let i: Int32;
    let objectData: ScanningTooltipElementDef;
    if this.IsScanningCluesBlocked() {
      return arr;
    };
    i = 0;
    while i < ArraySize(this.m_clues[index].extendedClueRecords) {
      objectData.recordID = this.m_clues[index].extendedClueRecords[i].clueRecord;
      objectData.timePct = this.m_clues[index].extendedClueRecords[i].percentage;
      if TDBID.IsValid(objectData.recordID) {
        ArrayPush(arr, objectData);
      };
      i += 1;
    };
    if this.IsConclusionActive(index) {
      if ArraySize(this.m_clues[index].extendedClueRecords) > 0 {
        objectData.timePct = 1.00;
      } else {
        objectData.timePct = 0.00;
      };
      objectData.recordID = this.m_clues[index].clueRecord;
      if TDBID.IsValid(objectData.recordID) {
        ArrayPush(arr, objectData);
        conclusionData = objectData;
      };
    };
    return arr;
  }

  private final func IsConclusionActive(clueIndex: Int32) -> Bool {
    let isActive: Bool;
    let owner: ref<GameObject>;
    if NotEquals(this.m_clues[clueIndex].conclusionQuestState, EConclusionQuestState.Undefined) {
      if Equals(this.m_clues[clueIndex].conclusionQuestState, EConclusionQuestState.Active) || Equals(this.m_clues[clueIndex].conclusionQuestState, EConclusionQuestState.Shown) {
        isActive = true;
      } else {
        isActive = false;
      };
    } else {
      if !IsNameValid(this.m_clues[clueIndex].factToActivate) {
        isActive = true;
      } else {
        owner = this.GetOwner();
        if IsDefined(owner) {
          isActive = GameInstance.GetQuestsSystem(this.GetOwner().GetGame()).GetFact(this.m_clues[clueIndex].factToActivate) > 0;
        };
      };
    };
    return isActive;
  }

  public final const func IsBraindanceBlocked() -> Bool {
    if this.GetOwner().GetHudManager().IsBraindanceActive() {
      return !this.m_isBraindanceClue || this.m_isBraindanceBlocked;
    };
    return false;
  }

  public final const func IsPhotoModeBlocked() -> Bool {
    return GameInstance.GetPhotoModeSystem(this.GetOwner().GetGame()).IsPhotoModeActive();
  }

  public final const func IsClueLinked(index: Int32) -> Bool {
    return IsNameValid(this.m_clues[index].clueGroupID);
  }

  public final const func IsActiveClueUsingAutoInspect() -> Bool {
    let id: Int32 = this.GetAvailableClueIndex();
    if id >= 0 {
      return this.IsClueUsingAutoInspect(id);
    };
    return false;
  }

  public final const func IsClueUsingAutoInspect(index: Int32) -> Bool {
    return this.m_clues[index].useAutoInspect;
  }

  public final const func IsActiveClueLinked() -> Bool {
    let id: Int32 = this.GetAvailableClueIndex();
    if id >= 0 {
      return this.IsClueLinked(id);
    };
    return false;
  }

  public final const func GetClueGroupID(index: Int32) -> CName {
    if !this.HasClueWithID(index) {
      return n"";
    };
    return this.m_clues[index].clueGroupID;
  }

  public final const func GetClueByIndex(index: Int32) -> FocusClueDefinition {
    let clue: FocusClueDefinition;
    if !this.HasClueWithID(index) {
      return clue;
    };
    clue = this.m_clues[index];
    return clue;
  }

  public final func GetExtendedClueRecords(clueIndex: Int32) -> array<ClueRecordData> {
    let records: array<ClueRecordData>;
    if clueIndex < ArraySize(this.m_clues) {
      records = this.m_clues[clueIndex].extendedClueRecords;
    };
    return records;
  }

  public final func SetClueExtendedDescriptionAsInspected(clueIndex: Int32, descriptionIndex: Int32) -> Void {
    if clueIndex < ArraySize(this.m_clues) {
      if descriptionIndex < ArraySize(this.m_clues[clueIndex].extendedClueRecords) {
        this.m_clues[clueIndex].extendedClueRecords[descriptionIndex].wasInspected = true;
      };
    };
  }

  public final func SetClueState(clueIndex: Int32, isEnabled: Bool, isInspected: Bool, updateFocusClueSystem: Bool, ignorePS: Bool) -> Void {
    let i: Int32;
    let shouldNotifyChange: Bool;
    if !this.HasClueWithID(clueIndex) {
      return;
    };
    shouldNotifyChange = NotEquals(this.m_clues[clueIndex].wasInspected, isInspected) || NotEquals(this.m_clues[clueIndex].isEnabled, isEnabled);
    this.m_clues[clueIndex].wasInspected = isInspected;
    if NotEquals(this.m_clues[clueIndex].isEnabled, isEnabled) {
      if !isEnabled {
        this.m_clues[clueIndex].isEnabled = false;
        if isInspected {
          this.SetIsScanned_Event(true);
        };
      } else {
        this.SetIsScanned_Event(false);
        i = 0;
        while i < ArraySize(this.m_clues) {
          if i == clueIndex || IsNameValid(this.m_clues[clueIndex].clueGroupID) && Equals(this.m_clues[i].clueGroupID, this.m_clues[clueIndex].clueGroupID) {
            this.m_clues[i].isEnabled = true;
            this.RegisterGrouppedClue(i);
          } else {
            this.m_clues[i].isEnabled = false;
            this.GetMyPS().StoreClueData(i, this.m_clues[i], this.IsScanned());
          };
          i += 1;
        };
      };
    };
    if shouldNotifyChange {
      this.NotifyClueStateChanged(clueIndex, ignorePS, updateFocusClueSystem);
    };
  }

  public final func SetClueState(clueIndex: Int32, isEnabled: Bool, updateFocusClueSystem: Bool, ignorePS: Bool) -> Void {
    let i: Int32;
    let shouldNotifyChange: Bool;
    if !this.HasClueWithID(clueIndex) {
      return;
    };
    shouldNotifyChange = NotEquals(isEnabled, this.m_clues[clueIndex].isEnabled);
    if NotEquals(isEnabled, this.m_clues[clueIndex].isEnabled) {
      if !isEnabled {
        this.m_clues[clueIndex].isEnabled = false;
      } else {
        this.SetIsScanned_Event(false);
        i = 0;
        while i < ArraySize(this.m_clues) {
          if i == clueIndex || IsNameValid(this.m_clues[clueIndex].clueGroupID) && Equals(this.m_clues[i].clueGroupID, this.m_clues[clueIndex].clueGroupID) {
            this.m_clues[i].isEnabled = true;
            this.RegisterGrouppedClue(i);
          } else {
            this.m_clues[i].isEnabled = false;
            this.GetMyPS().StoreClueData(i, this.m_clues[i], this.IsScanned());
          };
          i += 1;
        };
      };
    };
    if shouldNotifyChange {
      this.NotifyClueStateChanged(clueIndex, ignorePS, updateFocusClueSystem);
    };
  }

  private final func NotifyClueStateChanged(clueIndex: Int32, ignorePS: Bool, updateFocusClueSystem: Bool) -> Void {
    this.NotifyHudManager(this.IsAnyClueEnabled());
    this.ForceReEvaluateGameplayRole();
    if !ignorePS {
      this.GetMyPS().StoreClueData(clueIndex, this.m_clues[clueIndex], this.IsScanned());
    };
    if updateFocusClueSystem {
      this.RequestFocusClueSystemUpdate(clueIndex);
    };
    if this.m_isBeingScanned {
      this.ResolveScannerAvailability();
    };
  }

  public final const func IsScanningCluesBlocked() -> Bool {
    let id: EntityID = this.GetOwner().GetHudManager().GetLockedClueID();
    if EntityID.IsDefined(id) && id != this.GetOwner().GetEntityID() {
      return true;
    };
    return false;
  }

  public final const func IsAnyClueEnabled() -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(this.m_clues) {
      if this.m_clues[i].isEnabled {
        return true;
      };
      i += 1;
    };
    return false;
  }

  private final const func IsAnyClueValid() -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(this.m_clues) {
      if this.m_clues[i].isProgressing {
        return true;
      };
      i += 1;
    };
    return false;
  }

  public final const func IsClueInspected() -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(this.m_clues) {
      if this.m_clues[i].isEnabled && this.m_clues[i].wasInspected {
        return true;
      };
      i += 1;
    };
    return false;
  }

  public final const func IsClueProgressing() -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(this.m_clues) {
      if this.m_clues[i].isEnabled && this.m_clues[i].isProgressing {
        return true;
      };
      i += 1;
    };
    return false;
  }

  public final const func HasAnyClue() -> Bool {
    return ArraySize(this.m_clues) > 0;
  }

  public final const func GetClueCount() -> Int32 {
    return ArraySize(this.m_clues);
  }

  public final const func HasClueWithID(clueID: Int32) -> Bool {
    return clueID >= 0 && clueID < ArraySize(this.m_clues);
  }

  private final func InitializeQuestDBCallbacks() -> Void {
    let owner: ref<GameObject>;
    let i: Int32 = 0;
    while i < ArraySize(this.m_clues) {
      if this.m_clues[i].isEnabled {
        if IsNameValid(this.m_clues[i].factToActivate) {
          owner = this.GetOwner();
          if IsDefined(owner) {
            this.m_clues[i].qDbCallbackID = GameInstance.GetQuestsSystem(owner.GetGame()).RegisterEntity(this.m_clues[i].factToActivate, owner.GetEntityID());
          };
        };
      };
      i += 1;
    };
  }

  private final func UnInitializeQuestDBCallbacks() -> Void {
    let owner: ref<GameObject>;
    let i: Int32 = 0;
    while i < ArraySize(this.m_clues) {
      if this.m_clues[i].isEnabled {
        if IsNameValid(this.m_clues[i].factToActivate) {
          owner = this.GetOwner();
          if IsDefined(owner) {
            GameInstance.GetQuestsSystem(owner.GetGame()).UnregisterEntity(this.m_clues[i].factToActivate, this.m_clues[i].qDbCallbackID);
          };
        };
      };
      i += 1;
    };
  }

  private final func CancelForcedVisionAppearance(data: ref<FocusForcedHighlightData>, opt fast: Bool, opt ignoreStackEvaluation: Bool) -> Void {
    let evt: ref<ForceVisionApperanceEvent> = new ForceVisionApperanceEvent();
    if fast {
      data.outTransitionTime = 0.20;
    };
    evt.forcedHighlight = data;
    evt.apply = false;
    evt.ignoreStackEvaluation = ignoreStackEvaluation;
    this.GetOwner().QueueEvent(evt);
  }

  private final func ForceVisionAppearance(data: ref<FocusForcedHighlightData>) -> Void {
    let evt: ref<ForceVisionApperanceEvent> = new ForceVisionApperanceEvent();
    evt.forcedHighlight = data;
    evt.apply = true;
    this.GetOwner().QueueEvent(evt);
  }

  private final const func GetQuestHighlight(highlightInstructions: ref<HighlightInstance>) -> ref<FocusForcedHighlightData> {
    let data: ref<FocusForcedHighlightData> = new FocusForcedHighlightData();
    data.sourceID = this.GetOwner().GetEntityID();
    data.sourceName = this.GetClassName();
    data.highlightType = EFocusForcedHighlightType.QUEST;
    data.priority = EPriority.Medium;
    if Equals(highlightInstructions.context, HighlightContext.FILL) {
      data.highlightType = EFocusForcedHighlightType.QUEST;
      data.outlineType = EFocusOutlineType.INVALID;
    } else {
      if Equals(highlightInstructions.context, HighlightContext.OUTLINE) {
        data.outlineType = EFocusOutlineType.QUEST;
        data.highlightType = EFocusForcedHighlightType.INVALID;
      } else {
        if Equals(highlightInstructions.context, HighlightContext.FULL) {
          data.highlightType = EFocusForcedHighlightType.QUEST;
          data.outlineType = EFocusOutlineType.QUEST;
        };
      };
    };
    return data;
  }

  private final const func GetDefaultHighlight(highlightInstructions: ref<HighlightInstance>) -> ref<FocusForcedHighlightData> {
    let data: ref<FocusForcedHighlightData> = new FocusForcedHighlightData();
    data.sourceID = this.GetOwner().GetEntityID();
    data.sourceName = this.GetClassName();
    data.highlightType = EFocusForcedHighlightType.INTERACTION;
    data.priority = EPriority.Medium;
    if Equals(highlightInstructions.context, HighlightContext.FILL) {
      data.highlightType = EFocusForcedHighlightType.INTERACTION;
      data.outlineType = EFocusOutlineType.INVALID;
    } else {
      if Equals(highlightInstructions.context, HighlightContext.OUTLINE) {
        data.outlineType = EFocusOutlineType.INTERACTION;
        data.highlightType = EFocusForcedHighlightType.INVALID;
      } else {
        if Equals(highlightInstructions.context, HighlightContext.FULL) {
          data.highlightType = EFocusForcedHighlightType.INTERACTION;
          data.outlineType = EFocusOutlineType.INTERACTION;
        };
      };
    };
    return data;
  }

  private final const func GetClueHighlight(highlightInstructions: ref<HighlightInstance>) -> ref<FocusForcedHighlightData> {
    let data: ref<FocusForcedHighlightData> = new FocusForcedHighlightData();
    data.sourceID = this.GetOwner().GetEntityID();
    data.sourceName = this.GetClassName();
    data.highlightType = EFocusForcedHighlightType.CLUE;
    data.priority = EPriority.Medium;
    data.outTransitionTime = 8.00;
    if Equals(highlightInstructions.context, HighlightContext.FILL) {
      data.highlightType = EFocusForcedHighlightType.CLUE;
      data.outlineType = EFocusOutlineType.INVALID;
    } else {
      if Equals(highlightInstructions.context, HighlightContext.OUTLINE) {
        data.outlineType = EFocusOutlineType.CLUE;
        data.highlightType = EFocusForcedHighlightType.INVALID;
      } else {
        if Equals(highlightInstructions.context, HighlightContext.FULL) {
          data.highlightType = EFocusForcedHighlightType.CLUE;
          data.outlineType = EFocusOutlineType.CLUE;
        };
      };
    };
    return data;
  }

  private final func ToggleHighlight(toggle: Bool, highlightInstructions: ref<HighlightInstance>) -> Void {
    let newHighlight: ref<FocusForcedHighlightData> = this.GetClueHighlightData(highlightInstructions);
    if toggle {
      if this.m_currentHighlight != null && (NotEquals(this.m_currentHighlight.highlightType, newHighlight.highlightType) || NotEquals(this.m_currentHighlight.outlineType, newHighlight.outlineType)) {
        this.CancelForcedVisionAppearance(this.m_currentHighlight, true, newHighlight != null);
      };
      if newHighlight != null {
        this.ForceVisionAppearance(newHighlight);
      };
    } else {
      if this.m_currentHighlight != null {
        this.CancelForcedVisionAppearance(this.m_currentHighlight, false);
      };
    };
    this.m_currentHighlight = newHighlight;
  }

  public final const func GetClueHighlightData(highlightInstructions: ref<HighlightInstance>) -> ref<FocusForcedHighlightData> {
    if this.IsAnyClueEnabled() {
      if GameInstance.GetPhotoModeSystem(this.GetOwner().GetGame()).IsPhotoModeActive() {
        return null;
      };
      if this.IsBraindanceBlocked() || this.IsPhotoModeBlocked() {
        return null;
      };
      if this.IsClueInspected() || !this.IsClueProgressing() {
        return this.GetDefaultHighlight(highlightInstructions);
      };
      return this.GetQuestHighlight(highlightInstructions);
    };
    return null;
  }

  private final func UpdateDefaultHighlight() -> Void {
    let updateHighlightEvt: ref<ForceUpdateDefaultHighlightEvent> = new ForceUpdateDefaultHighlightEvent();
    this.GetOwner().QueueEvent(updateHighlightEvt);
  }

  private final func ResolveFocusClueOnScannCompleted() -> Void {
    let clueIndex: Int32 = this.GetAvailableClueIndex();
    if clueIndex < 0 {
      return;
    };
    if this.m_clues[clueIndex].useAutoInspect {
      this.m_clues[clueIndex].wasInspected = true;
      this.GetMyPS().StoreClueData(clueIndex, this.m_clues[clueIndex], true);
    };
    if this.m_isBeingScanned {
      this.RequestFocusClueSystemUpdate(clueIndex);
    };
    this.StopBraindanceClueEffect();
    this.RequestHUDRefresh();
  }

  private final const func Script_IsScanningStateTransitionAllowed(currentState: gameScanningState, newState: gameScanningState) -> Bool {
    if Equals(currentState, gameScanningState.ShallowComplete) && Equals(newState, gameScanningState.Started) {
      return !this.HasAnyClue() || this.IsAnyClueEnabled();
    };
    return true;
  }

  private final func HighLightWeakspots() -> Void {
    let i: Int32;
    let weakspots: array<wref<WeakspotObject>>;
    let Puppet: ref<NPCPuppet> = this.GetOwner() as NPCPuppet;
    Puppet.GetWeakspotComponent().GetWeakspots(weakspots);
    if ArraySize(weakspots) > 0 {
      i = 0;
      while i < ArraySize(weakspots) {
        this.SendHighlightEventToWeakspot(weakspots[i]);
        i += 1;
      };
    };
  }

  private final func SendHighlightEventToWeakspot(object: ref<GameObject>) -> Void {
    let evt: ref<ScanningLookAtEvent> = new ScanningLookAtEvent();
    object.QueueEvent(evt);
  }

  protected cb func OnScanningLookedAt(evt: ref<ScanningLookAtEvent>) -> Bool {
    this.m_isBeingScanned = evt.state;
    if evt.state {
      this.ResolveScannerAvailability();
    };
    this.HighLightWeakspots();
  }

  private final func ResolveScannerAvailability() -> Void {
    if !this.m_isEntityVisible || this.IsBraindanceBlocked() || this.GetMyPS().IsScanningDisabled() || !this.GetOwner().ShouldShowScanner() || this.IsPhotoModeBlocked() {
      this.ToggleScanningBlocked(true);
    } else {
      this.ToggleScanningBlocked(false);
    };
  }

  protected cb func OnEnteventsSetVisibility(evt: ref<enteventsSetVisibility>) -> Bool {
    if NotEquals(evt.visible, this.m_isEntityVisible) {
      this.m_isEntityVisible = evt.visible;
      this.ResolveScannerAvailability();
    };
  }

  protected cb func OnScanningEvent(evt: ref<ScanningEvent>) -> Bool {
    if Equals(evt.state, gameScanningState.Complete) {
      this.ResolveFocusClueOnScannCompleted();
    };
  }

  protected cb func OnClueLockedByScene(evt: ref<SetExclusiveFocusClueEntityEvent>) -> Bool {
    let request: ref<ClueLockNotification> = new ClueLockNotification();
    request.isLocked = evt.isSetExclusive;
    request.ownerID = this.GetOwner().GetEntityID();
    this.GetOwner().GetHudManager().QueueRequest(request);
  }

  protected cb func OnActivateConclusionFactChanged(evt: ref<FactChangedEvent>) -> Bool {
    let factName: CName = evt.GetFactName();
    let i: Int32 = 0;
    while i < ArraySize(this.m_clues) {
      if !this.m_clues[i].isEnabled {
      } else {
        if Equals(factName, this.m_clues[i].factToActivate) {
          this.SetConclusionState(i, EConclusionQuestState.Active);
          this.UpdateTooltipData();
        };
      };
      i += 1;
    };
  }

  protected cb func OnHUDInstruction(evt: ref<HUDInstruction>) -> Bool {
    if !this.m_isHudManagerInitialized {
      this.NotifyHudManager(this.IsAnyClueEnabled());
      this.m_isHudManagerInitialized = true;
      return false;
    };
    if this.ReEvaluateGrouppedCluesState() {
      return false;
    };
    if evt.scannerInstructions.WasProcessed() {
      this.ProcessScannerHudInstruction(evt.scannerInstructions);
    };
    if evt.highlightInstructions.WasProcessed() {
      this.ProcessHighlightHudInstruction(evt.highlightInstructions);
    };
    if evt.braindanceInstructions.WasProcessed() {
      this.ProcessBraindanceHudInstruction(evt.braindanceInstructions);
    };
  }

  protected final func ProcessHighlightHudInstruction(instruction: ref<HighlightInstance>) -> Void {
    if Equals(instruction.GetState(), InstanceState.ON) {
      this.m_isFocusModeActive = true;
      this.ToggleHighlight(true, instruction);
    } else {
      this.m_isFocusModeActive = false;
      this.ToggleHighlight(false, instruction);
    };
  }

  protected final func ProcessScannerHudInstruction(instruction: ref<ScanInstance>) -> Void {
    let evaluate: Bool;
    if Equals(instruction.GetState(), InstanceState.ON) {
      evaluate = NotEquals(instruction.isScanningCluesBlocked, this.m_isScanningCluesBlocked);
      this.m_isScanningCluesBlocked = instruction.isScanningCluesBlocked;
    };
    if evaluate {
      if instruction.isLookedAt {
        this.SetIsScanned_Event(false);
      };
      this.ResolveScannerAvailability();
    };
  }

  protected final func ProcessBraindanceHudInstruction(instruction: ref<BraindanceInstance>) -> Void {
    let braindanceToggle: Bool;
    if !this.m_isBraindanceClue {
      return;
    };
    braindanceToggle = Equals(instruction.GetState(), InstanceState.ON);
    if NotEquals(this.m_isBraindanceActive, braindanceToggle) {
      this.m_isBraindanceActive = braindanceToggle;
      this.ToggleBraindance(this.m_isBraindanceActive);
    };
  }

  protected cb func OnDisableScanner(evt: ref<DisableScannerEvent>) -> Bool {
    if this.m_isBeingScanned {
      this.ResolveScannerAvailability();
      this.UpdateTooltipData();
    };
  }

  protected cb func OnSetGameplayRole(evt: ref<SetGameplayRoleEvent>) -> Bool {
    if this.m_isFocusModeActive {
      this.UpdateTooltipData();
    };
  }

  protected cb func OnDisableObjectDescription(evt: ref<DisableObjectDescriptionEvent>) -> Bool {
    if this.m_isFocusModeActive {
      this.UpdateTooltipData();
    };
  }

  protected cb func OnSetCustomObjectDescription(evt: ref<SetCustomObjectDescriptionEvent>) -> Bool {
    if this.m_isFocusModeActive {
      this.UpdateTooltipData();
    };
  }

  protected cb func OnClearCustomObjectDescription(evt: ref<ClearCustomObjectDescriptionEvent>) -> Bool {
    if this.m_isFocusModeActive {
      this.UpdateTooltipData();
    };
  }

  protected cb func OnSetCurrentGameplayRole(evt: ref<SetCurrentGameplayRoleEvent>) -> Bool {
    if this.m_isFocusModeActive {
      this.UpdateTooltipData();
    };
  }

  protected cb func OnQuestToggleClueConclusion(evt: ref<ToggleClueConclusionEvent>) -> Bool {
    if this.HasClueWithID(evt.clueID) {
      if evt.toggleConclusion {
        this.m_clues[evt.clueID].conclusionQuestState = EConclusionQuestState.Active;
      } else {
        this.m_clues[evt.clueID].conclusionQuestState = EConclusionQuestState.Inactive;
      };
      if this.m_clues[evt.clueID].isEnabled {
        this.UpdateTooltipData();
      };
      if evt.updatePS {
        this.GetMyPS().StoreClueData(evt.clueID, this.m_clues[evt.clueID], this.IsScanned());
      };
    };
  }

  public final func SetConclusionAsShown(clueID: Int32) -> Void {
    if !this.HasClueWithID(clueID) {
      return;
    };
    this.SetConclusionState(clueID, EConclusionQuestState.Shown);
  }

  private final func SetConclusionState(clueID: Int32, state: EConclusionQuestState) -> Void {
    if !this.HasClueWithID(clueID) {
      return;
    };
    this.m_clues[clueID].conclusionQuestState = state;
    this.GetMyPS().StoreClueData(clueID, this.m_clues[clueID], this.IsScanned());
  }

  public final const func WasConclusionShown(clueID: Int32) -> Bool {
    if !this.HasClueWithID(clueID) {
      return false;
    };
    return Equals(this.m_clues[clueID].conclusionQuestState, EConclusionQuestState.Shown);
  }

  protected cb func OnToggleFocusClue(evt: ref<ToggleFocusClueEvent>) -> Bool {
    let isInspected: Bool;
    if Equals(evt.investigationState, EFocusClueInvestigationState.NONE) {
      this.SetClueState(evt.clueIndex, evt.isEnabled, true, !evt.updatePS);
    } else {
      if Equals(evt.investigationState, EFocusClueInvestigationState.INSPECTED) {
        isInspected = true;
      } else {
        isInspected = false;
      };
      this.SetClueState(evt.clueIndex, evt.isEnabled, isInspected, true, !evt.updatePS);
    };
    if this.m_isFocusModeActive && this.IsScanning() && evt.isEnabled {
      this.SetIsScanned_Event(true);
    };
  }

  protected cb func OnClueStateChanged(evt: ref<FocusClueStateChangeEvent>) -> Bool {
    this.SetClueState(evt.clueIndex, evt.isEnabled, true, true);
    if this.m_isFocusModeActive && this.IsScanning() && evt.isEnabled {
      this.SetIsScanned_Event(true);
    };
  }

  protected cb func OnLinkedClueUpdateEvent(evt: ref<linkedClueUpdateEvent>) -> Bool {
    this.UpdateLinkedClues(evt.linkedCluekData, evt.updatePS);
  }

  private final func UpdateLinkedClues(linkedCluekData: LinkedFocusClueData, updatePS: Bool) -> Void {
    let setAsScanned: Bool;
    let i: Int32 = 0;
    while i < ArraySize(this.m_clues) {
      if !IsNameValid(this.m_clues[i].clueGroupID) {
      } else {
        if Equals(this.m_clues[i].clueGroupID, linkedCluekData.clueGroupID) {
          this.SetClueState(i, linkedCluekData.isEnabled, linkedCluekData.wasInspected, false, !updatePS);
          if linkedCluekData.isEnabled && !this.IsScanned() && linkedCluekData.isScanned {
            setAsScanned = true;
          };
        };
      };
      i += 1;
    };
    if setAsScanned {
      this.SetIsScanned_Event(true);
    };
  }

  protected cb func OnRevealStateChanged(evt: ref<RevealStateChangedEvent>) -> Bool {
    if Equals(evt.state, ERevealState.STARTED) {
      if this.GetOwner().CanScanThroughWalls() {
        if this.GetOwner().IsDevice() {
          this.SetScannableThroughWalls(true);
        } else {
          this.SetScannableThroughWalls(false);
        };
      };
    } else {
      if Equals(evt.state, ERevealState.STOPPED) {
        this.SetScannableThroughWalls(false);
      };
    };
  }

  protected cb func OnScannableBraindanceClueEnabledEvent(evt: ref<OnScannableBraindanceClueEnabledEvent>) -> Bool {
    if this.m_isBraindanceClue {
      this.m_isBraindanceTimelineUnlocked = true;
      this.EvaluateBraindanceClueState();
    };
  }

  protected cb func OnScannableBraindanceClueDisabledEvent(evt: ref<OnScannableBraindanceClueDisabledEvent>) -> Bool {
    if this.m_isBraindanceClue {
      this.m_isBraindanceTimelineUnlocked = false;
      this.EvaluateBraindanceClueState();
    };
  }

  protected cb func OnBraindanceVisionModeChange(value: Int32) -> Bool {
    this.m_currentBraindanceLayer = value;
    if this.m_currentBraindanceLayer == EnumInt(this.m_BraindanceLayer) {
      this.m_isBraindanceLayerUnlocked = true;
    } else {
      this.m_isBraindanceLayerUnlocked = false;
    };
    this.EvaluateBraindanceClueState();
  }

  protected cb func OnBraindanceFppChange(fppToggle: Bool) -> Bool {
    if fppToggle {
      this.m_isBraindanceLayerUnlocked = false;
    } else {
      if this.m_currentBraindanceLayer == EnumInt(this.m_BraindanceLayer) {
        this.m_isBraindanceLayerUnlocked = true;
      } else {
        this.m_isBraindanceLayerUnlocked = false;
      };
    };
    this.EvaluateBraindanceClueState();
  }

  private final func ToggleBraindanceScanning(value: Bool) -> Void {
    this.m_isBraindanceBlocked = !value;
    if !this.IsScanned() {
      this.SetIsScanned_Event(false);
    };
    this.ResolveScannerAvailability();
  }

  private final func SignalScannablesBlackboard() -> Void {
    let Blackboard: ref<IBlackboard> = GameInstance.GetBlackboardSystem(this.GetOwner().GetGame()).Get(GetAllBlackboardDefs().UI_Scanner);
    if IsDefined(Blackboard) {
      Blackboard.SignalVariant(GetAllBlackboardDefs().UI_Scanner.Scannables);
      Blackboard.SignalEntityID(GetAllBlackboardDefs().UI_Scanner.ScannedObject);
    };
  }

  protected final func ToggleBraindance(value: Bool) -> Void {
    if value {
      this.NotifyHudManager(false);
      if 0 == EnumInt(this.m_BraindanceLayer) {
        this.m_isBraindanceLayerUnlocked = true;
      } else {
        this.m_isBraindanceLayerUnlocked = false;
      };
    } else {
      this.m_isBraindanceLayerUnlocked = false;
    };
    this.EvaluateBraindanceClueState();
  }

  private final func StartBraindanceClueEffect() -> Void {
    let spawnEffectEvent: ref<entSpawnEffectEvent> = new entSpawnEffectEvent();
    spawnEffectEvent.effectName = n"braindanceClueEffect";
    this.GetOwner().QueueEvent(spawnEffectEvent);
  }

  private final func StopBraindanceClueEffect() -> Void {
    let evt: ref<entKillEffectEvent> = new entKillEffectEvent();
    evt.effectName = n"braindanceClueEffect";
    this.GetOwner().QueueEvent(evt);
  }

  private final func EvaluateBraindanceClueState() -> Void {
    if this.m_isBraindanceLayerUnlocked && this.m_isBraindanceTimelineUnlocked {
      this.ToggleBraindanceScanning(true);
      if !this.IsScanned() {
        this.StartBraindanceClueEffect();
      };
      this.SignalScannablesBlackboard();
      this.HideMappins(false);
    } else {
      if this.IsEnabled() {
        this.ToggleBraindanceScanning(false);
        this.StopBraindanceClueEffect();
        this.HideMappins(true);
      };
    };
    this.UpdateTooltipData();
    this.UpdateDefaultHighlight();
  }

  private final func HideMappins(value: Bool) -> Void {
    let evt: ref<ToggleGameplayMappinVisibilityEvent> = new ToggleGameplayMappinVisibilityEvent();
    evt.isHidden = value;
    this.GetOwner().QueueEvent(evt);
  }

  private final func NotifyHudManager(isClue: Bool) -> Void {
    let request: ref<ClueStatusNotification> = new ClueStatusNotification();
    request.isClue = isClue;
    request.clueGroupID = this.GetClueGroupID(this.GetAvailableClueIndex());
    request.ownerID = this.GetOwner().GetEntityID();
    this.GetOwner().GetHudManager().QueueRequest(request);
  }

  private final func RequestHUDRefresh() -> Void {
    let request: ref<RefreshActorRequest> = new RefreshActorRequest();
    request.ownerID = this.GetOwner().GetEntityID();
    this.GetOwner().GetHudManager().QueueRequest(request);
  }

  public final const func GetFocusClueSystem() -> ref<FocusCluesSystem> {
    return GameInstance.GetScriptableSystemsContainer(this.GetOwner().GetGame()).Get(n"FocusCluesSystem") as FocusCluesSystem;
  }

  private final func RequestFocusClueSystemUpdate(clueIndex: Int32) -> Void {
    let clue: FocusClueDefinition;
    let clueRequest: ref<UpdateLinkedClueskRequest>;
    let linkedClueData: LinkedFocusClueData;
    if !this.HasClueWithID(clueIndex) {
      return;
    };
    clue = this.m_clues[clueIndex];
    if IsNameValid(clue.clueGroupID) {
      clueRequest = new UpdateLinkedClueskRequest();
      linkedClueData.clueGroupID = clue.clueGroupID;
      linkedClueData.ownerID = this.GetOwner().GetEntityID();
      linkedClueData.clueIndex = clueIndex;
      linkedClueData.clueRecord = clue.clueRecord;
      linkedClueData.extendedClueRecords = clue.extendedClueRecords;
      linkedClueData.isScanned = this.IsScanned();
      linkedClueData.wasInspected = clue.wasInspected;
      linkedClueData.isEnabled = clue.isEnabled;
      clueRequest.linkedCluekData = linkedClueData;
      this.GetFocusClueSystem().QueueRequest(clueRequest);
    };
  }

  protected final func ForceReEvaluateGameplayRole() -> Void {
    let evt: ref<EvaluateGameplayRoleEvent> = new EvaluateGameplayRoleEvent();
    evt.force = true;
    this.GetOwner().QueueEvent(evt);
  }
}
