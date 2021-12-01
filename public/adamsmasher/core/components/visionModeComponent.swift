
public class RevealQuestTargetEvent extends Event {

  public edit let sourceName: CName;

  @default(RevealQuestTargetEvent, ERevealDurationType.TEMPORARY)
  public edit let durationType: ERevealDurationType;

  @default(RevealQuestTargetEvent, true)
  public edit let reveal: Bool;

  @default(RevealQuestTargetEvent, 4.0f)
  public let timeout: Float;

  public final func GetFriendlyDescription() -> String {
    return "Reveal Quest Target";
  }
}

public class ToggleForcedHighlightEvent extends Event {

  public edit let sourceName: CName;

  public inline edit let highlightData: ref<HighlightEditableData>;

  public edit let operation: EToggleOperationType;

  public final func GetFriendlyDescription() -> String {
    return "Toggle Forced Highlight";
  }
}

public class SetPersistentForcedHighlightEvent extends Event {

  public edit let sourceName: CName;

  public inline edit let highlightData: ref<HighlightEditableData>;

  public edit let operation: EToggleOperationType;

  public final func GetFriendlyDescription() -> String {
    return "Set Persitent Forced Highlight";
  }
}

public class SetDefaultHighlightEvent extends Event {

  public inline edit let highlightData: ref<HighlightEditableData>;

  public final func GetFriendlyDescription() -> String {
    return "Set Default Highlight";
  }
}

public class FocusForcedHighlightPersistentData extends IScriptable {

  private persistent let sourceID: EntityID;

  private persistent let sourceName: CName;

  private persistent let highlightType: EFocusForcedHighlightType;

  private persistent let outlineType: EFocusOutlineType;

  private persistent let priority: EPriority;

  private persistent let inTransitionTime: Float;

  private persistent let outTransitionTime: Float;

  private persistent let isRevealed: Bool;

  private persistent let patternType: VisionModePatternType;

  public final func Initialize(data: ref<FocusForcedHighlightData>) -> Void {
    if data == null {
      return;
    };
    this.sourceID = data.sourceID;
    this.sourceName = data.sourceName;
    this.highlightType = data.highlightType;
    this.outlineType = data.outlineType;
    this.priority = data.priority;
    this.inTransitionTime = data.inTransitionTime;
    this.outTransitionTime = data.outTransitionTime;
    this.isRevealed = data.isRevealed;
    this.patternType = data.patternType;
  }

  public final const func GetData() -> ref<FocusForcedHighlightData> {
    let data: ref<FocusForcedHighlightData> = new FocusForcedHighlightData();
    data.sourceID = this.sourceID;
    data.sourceName = this.sourceName;
    data.highlightType = this.highlightType;
    data.outlineType = this.outlineType;
    data.priority = this.priority;
    data.inTransitionTime = this.inTransitionTime;
    data.outTransitionTime = this.outTransitionTime;
    data.isRevealed = this.isRevealed;
    data.patternType = this.patternType;
    data.isSavable = true;
    return data;
  }
}

public class FocusForcedHighlightData extends IScriptable {

  public let sourceID: EntityID;

  public let sourceName: CName;

  public let highlightType: EFocusForcedHighlightType;

  @default(FocusForcedHighlightData, EFocusOutlineType.INVALID)
  public let outlineType: EFocusOutlineType;

  public let priority: EPriority;

  @default(FocusForcedHighlightData, 0.5f)
  public let inTransitionTime: Float;

  @default(FocusForcedHighlightData, 2f)
  public let outTransitionTime: Float;

  public let hudData: ref<HighlightInstance>;

  public let isRevealed: Bool;

  public let isSavable: Bool;

  public let patternType: VisionModePatternType;

  public final func IsValid() -> Bool {
    return (IsNameValid(this.sourceName) || EntityID.IsDefined(this.sourceID)) && (NotEquals(this.highlightType, EFocusForcedHighlightType.INVALID) || NotEquals(this.outlineType, EFocusOutlineType.INVALID));
  }

  public final func InitializeWithHudInstruction(data: ref<HighlightInstance>) -> Void {
    this.hudData = data;
    this.isRevealed = data.isRevealed;
    if data.instant {
      this.inTransitionTime = 0.00;
      this.outTransitionTime = 0.00;
    };
  }

  private final func GetFillColorIndex() -> Int32 {
    switch this.highlightType {
      case EFocusForcedHighlightType.INTERACTION:
        return 2;
      case EFocusForcedHighlightType.IMPORTANT_INTERACTION:
        return 5;
      case EFocusForcedHighlightType.WEAKSPOT:
        return 6;
      case EFocusForcedHighlightType.QUEST:
        return 1;
      case EFocusForcedHighlightType.DISTRACTION:
        return 3;
      case EFocusForcedHighlightType.CLUE:
        return 4;
      case EFocusForcedHighlightType.NPC:
        return 0;
      case EFocusForcedHighlightType.AOE:
        return 7;
      case EFocusForcedHighlightType.ITEM:
        return 5;
      case EFocusForcedHighlightType.HOSTILE:
        return 7;
      case EFocusForcedHighlightType.FRIENDLY:
        return 4;
      case EFocusForcedHighlightType.NEUTRAL:
        return 2;
      case EFocusForcedHighlightType.HACKABLE:
        return 4;
      case EFocusForcedHighlightType.ENEMY_NETRUNNER:
        return 6;
      case EFocusForcedHighlightType.BACKDOOR:
        return 5;
      default:
        return 0;
    };
  }

  private final func GetOutlineColorIndex() -> Int32 {
    switch this.outlineType {
      case EFocusOutlineType.HOSTILE:
        return 2;
      case EFocusOutlineType.FRIENDLY:
        return 1;
      case EFocusOutlineType.NEUTRAL:
        return 3;
      case EFocusOutlineType.ITEM:
        return 6;
      case EFocusOutlineType.INTERACTION:
        return 3;
      case EFocusOutlineType.IMPORTANT_INTERACTION:
        return 6;
      case EFocusOutlineType.QUEST:
        return 5;
      case EFocusOutlineType.CLUE:
        return 1;
      case EFocusOutlineType.DISTRACTION:
        return 7;
      case EFocusOutlineType.AOE:
        return 2;
      case EFocusOutlineType.HACKABLE:
        return 1;
      case EFocusOutlineType.WEAKSPOT:
        return 4;
      case EFocusOutlineType.ENEMY_NETRUNNER:
        return 4;
      case EFocusOutlineType.BACKDOOR:
        return 6;
      default:
        return 0;
    };
  }

  public final func GetVisionApperance() -> VisionAppearance {
    let apperance: VisionAppearance;
    apperance.patternType = this.patternType;
    if this.hudData == null {
      apperance.fill = this.GetFillColorIndex();
      apperance.outline = this.GetOutlineColorIndex();
    } else {
      if Equals(this.hudData.context, HighlightContext.FILL) {
        apperance.fill = this.GetFillColorIndex();
      } else {
        if Equals(this.hudData.context, HighlightContext.OUTLINE) {
          apperance.outline = this.GetOutlineColorIndex();
        } else {
          if Equals(this.hudData.context, HighlightContext.FULL) {
            apperance.fill = this.GetFillColorIndex();
            apperance.outline = this.GetOutlineColorIndex();
          };
        };
      };
      apperance.showThroughWalls = this.hudData.isRevealed;
    };
    switch this.highlightType {
      case EFocusForcedHighlightType.QUEST:
        apperance.showThroughWalls = false;
        break;
      case EFocusForcedHighlightType.INTERACTION:
        apperance.showThroughWalls = false;
        break;
      case EFocusForcedHighlightType.IMPORTANT_INTERACTION:
        apperance.showThroughWalls = false;
        break;
      case EFocusForcedHighlightType.WEAKSPOT:
        apperance.showThroughWalls = false;
        break;
      case EFocusForcedHighlightType.DISTRACTION:
        apperance.showThroughWalls = false;
        break;
      case EFocusForcedHighlightType.CLUE:
        apperance.showThroughWalls = false;
        break;
      case EFocusForcedHighlightType.NPC:
        apperance.showThroughWalls = false;
        break;
      case EFocusForcedHighlightType.AOE:
        apperance.showThroughWalls = false;
        break;
      case EFocusForcedHighlightType.ITEM:
        apperance.showThroughWalls = false;
        break;
      default:
    };
    return apperance;
  }
}

public final native class gameVisionModeComponentPS extends GameComponentPS {

  private persistent let m_storedHighlightData: ref<FocusForcedHighlightPersistentData>;

  public final func StoreHighlightData(data: ref<FocusForcedHighlightData>) -> Void {
    if IsDefined(data) {
      this.m_storedHighlightData = new FocusForcedHighlightPersistentData();
      this.m_storedHighlightData.Initialize(data);
    } else {
      this.m_storedHighlightData = null;
    };
  }

  public final const func GetStoredHighlightData() -> ref<FocusForcedHighlightData> {
    if this.m_storedHighlightData != null {
      return this.m_storedHighlightData.GetData();
    };
    return null;
  }

  private final func OnSetPersistentForcedHighlightEvent(evt: ref<SetPersistentForcedHighlightEvent>) -> EntityNotificationType {
    let highlight: ref<FocusForcedHighlightData>;
    if Equals(evt.operation, EToggleOperationType.REMOVE) {
      this.StoreHighlightData(null);
    } else {
      highlight = new FocusForcedHighlightData();
      highlight.sourceID = PersistentID.ExtractEntityID(this.GetID());
      highlight.sourceName = evt.sourceName;
      highlight.highlightType = evt.highlightData.highlightType;
      highlight.outlineType = evt.highlightData.outlineType;
      highlight.inTransitionTime = evt.highlightData.inTransitionTime;
      highlight.outTransitionTime = evt.highlightData.outTransitionTime;
      highlight.priority = evt.highlightData.priority;
      highlight.isRevealed = evt.highlightData.isRevealed;
      highlight.isSavable = true;
      this.StoreHighlightData(highlight);
    };
    return EntityNotificationType.SendThisEventToEntity;
  }
}

public final native class VisionModeComponent extends GameComponent {

  private inline let m_defaultHighlightData: ref<HighlightEditableData>;

  private let m_forcedHighlights: array<ref<FocusForcedHighlightData>>;

  private let m_activeForcedHighlight: ref<FocusForcedHighlightData>;

  private let m_currentDefaultHighlight: ref<FocusForcedHighlightData>;

  private let m_activeRevealRequests: array<gameVisionModeSystemRevealIdentifier>;

  private let m_isFocusModeActive: Bool;

  private let m_wasCleanedUp: Bool;

  public final native func SetHiddenInVisionMode(hidden: Bool, type: gameVisionModeType) -> Void;

  protected final func OnGameAttach() -> Void {
    this.GetVisionModeSystem().GetDelayedRevealEntries(this.GetOwner().GetEntityID(), this.m_activeRevealRequests);
    this.AddForcedHighlight(this.GetMyPS().GetStoredHighlightData());
  }

  protected final func OnGameDetach() -> Void {
    if IsDefined(this.m_activeForcedHighlight) && this.m_activeForcedHighlight.isSavable {
      this.GetMyPS().StoreHighlightData(this.m_activeForcedHighlight);
    };
  }

  protected final cb func OnRestoreRevealEvent(evt: ref<RestoreRevealStateEvent>) -> Bool {
    this.RestoreReveal();
  }

  private final func RestoreReveal() -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_activeRevealRequests) {
      if i == 0 {
        this.SendRevealStateChangedEvent(ERevealState.STARTED, this.m_activeRevealRequests[i]);
      } else {
        this.SendRevealStateChangedEvent(ERevealState.CONTINUE, this.m_activeRevealRequests[i]);
      };
      i += 1;
    };
  }

  private final const func GetMyPS() -> ref<gameVisionModeComponentPS> {
    return this.GetPS() as gameVisionModeComponentPS;
  }

  private final const func GetOwner() -> ref<GameObject> {
    return this.GetEntity() as GameObject;
  }

  private final func AddForcedHighlight(data: ref<FocusForcedHighlightData>) -> Void {
    if data == null || !data.IsValid() {
      return;
    };
    if !this.HasForcedHighlightOnStack(data) {
      ArrayPush(this.m_forcedHighlights, data);
    };
    if ArraySize(this.m_forcedHighlights) > 0 {
      this.EvaluateForcedHighLightsStack();
    };
  }

  private final func RemoveForcedHighlight(data: ref<FocusForcedHighlightData>, opt ignoreStackEvaluation: Bool) -> Void {
    let evaluate: Bool;
    let i: Int32 = 0;
    while i < ArraySize(this.m_forcedHighlights) {
      if this.m_forcedHighlights[i].sourceID == data.sourceID {
        if Equals(this.m_forcedHighlights[i].sourceName, data.sourceName) {
          if Equals(this.m_forcedHighlights[i].highlightType, data.highlightType) && Equals(this.m_forcedHighlights[i].outlineType, data.outlineType) {
            this.m_forcedHighlights[i] = null;
            ArrayErase(this.m_forcedHighlights, i);
            evaluate = true;
          } else {
            i += 1;
          };
        } else {
        };
      };
      i += 1;
    };
    if evaluate && !ignoreStackEvaluation {
      this.EvaluateForcedHighLightsStack();
    };
  }

  private final func EvaluateForcedHighLightsStack() -> Void {
    let currentForcedHighlight: ref<FocusForcedHighlightData>;
    let i: Int32 = 0;
    while i < ArraySize(this.m_forcedHighlights) {
      if currentForcedHighlight == null || currentForcedHighlight != null && EnumInt(this.m_forcedHighlights[i].priority) >= EnumInt(currentForcedHighlight.priority) {
        currentForcedHighlight = this.m_forcedHighlights[i];
      };
      i += 1;
    };
    this.UpdateActiveForceHighlight(currentForcedHighlight);
  }

  protected final cb func OnAIAction(evt: ref<AIEvent>) -> Bool {
    if Equals(evt.name, n"NewWeaponEquipped") {
      this.ForwardHighlightToSlaveEntity(this.m_activeForcedHighlight, true);
    };
  }

  private final func UpdateActiveForceHighlight(data: ref<FocusForcedHighlightData>) -> Void {
    if data != this.m_activeForcedHighlight {
      if data != null {
        this.ForceVisionAppearance(data);
        this.m_activeForcedHighlight = data;
      } else {
        if this.m_activeForcedHighlight != null {
          this.CancelForcedVisionAppearance(this.m_activeForcedHighlight.outTransitionTime);
          this.m_activeForcedHighlight = null;
        };
      };
    };
  }

  private final func ReactivateForceHighlight() -> Void {
    if this.m_activeForcedHighlight != null {
      this.ForceVisionAppearance(this.m_activeForcedHighlight);
    };
  }

  private final func HasForcedHighlightOnStack(data: ref<FocusForcedHighlightData>) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(this.m_forcedHighlights) {
      if this.m_forcedHighlights[i].sourceID == data.sourceID {
        if Equals(this.m_forcedHighlights[i].sourceName, data.sourceName) {
          if Equals(this.m_forcedHighlights[i].highlightType, data.highlightType) && Equals(this.m_forcedHighlights[i].outlineType, data.outlineType) {
            return true;
          };
        };
      };
      i += 1;
    };
    return false;
  }

  private final func ForceVisionAppearance(data: ref<FocusForcedHighlightData>) -> Void {
    let appearance: VisionAppearance = data.GetVisionApperance();
    if this.IsRevealed() || data.isRevealed {
      data.isRevealed = true;
      appearance.showThroughWalls = true;
    } else {
      data.isRevealed = false;
      appearance.showThroughWalls = false;
    };
    GameInstance.GetVisionModeSystem(this.GetOwner().GetGame()).ForceVisionAppearance(this.GetOwner(), appearance, data.inTransitionTime);
    this.ForwardHighlightToSlaveEntity(data, true);
  }

  private final func CancelForcedVisionAppearance(transitionTime: Float) -> Void {
    GameInstance.GetVisionModeSystem(this.GetOwner().GetGame()).CancelForceVisionAppearance(this.GetOwner(), transitionTime);
    this.ForwardHighlightToSlaveEntity(this.m_activeForcedHighlight, false);
  }

  private final func PulseObject() -> Void {
    let data: ref<HighlightInstance>;
    let emptyAppearance: VisionAppearance;
    let targetHighlight: ref<FocusForcedHighlightData>;
    if this.m_activeForcedHighlight == null {
      data = new HighlightInstance();
      data.SetContext(HighlightContext.FULL, false, false);
      targetHighlight = this.GetDefaultHighlight();
      if targetHighlight != null {
        GameInstance.GetVisionModeSystem(this.GetOwner().GetGame()).RequestPulse(this.GetOwner(), emptyAppearance, targetHighlight.GetVisionApperance(), 0.40, 1.00);
      };
    };
  }

  private final const func GetDefaultHighlight(opt data: ref<HighlightInstance>) -> ref<FocusForcedHighlightData> {
    let highlight: ref<FocusForcedHighlightData>;
    if this.GetOwner().IsBraindanceBlocked() || this.GetOwner().IsPhotoModeBlocked() {
      return null;
    };
    if this.m_defaultHighlightData != null {
      highlight = new FocusForcedHighlightData();
      highlight.sourceID = this.GetOwner().GetEntityID();
      highlight.sourceName = this.GetOwner().GetClassName();
      highlight.outlineType = this.m_defaultHighlightData.outlineType;
      highlight.highlightType = this.m_defaultHighlightData.highlightType;
      highlight.priority = this.m_defaultHighlightData.priority;
      highlight.inTransitionTime = this.m_defaultHighlightData.inTransitionTime;
      highlight.outTransitionTime = this.m_defaultHighlightData.outTransitionTime;
    } else {
      highlight = this.GetOwner().GetDefaultHighlight();
      if data != null {
        highlight.InitializeWithHudInstruction(data);
      };
    };
    return highlight;
  }

  public final func ToggleRevealObject(reveal: Bool, opt forced: Bool) -> Void {
    if reveal {
      if this.m_activeForcedHighlight != null && !this.m_activeForcedHighlight.isRevealed {
        if forced {
          this.m_activeForcedHighlight.isRevealed = reveal;
        };
        this.CancelForcedVisionAppearance(0.30);
        this.ReactivateForceHighlight();
      };
    } else {
      if this.m_activeForcedHighlight != null && this.m_activeForcedHighlight.isRevealed {
        if forced {
          this.m_activeForcedHighlight.isRevealed = reveal;
        };
        this.CancelForcedVisionAppearance(0.30);
        this.ReactivateForceHighlight();
      };
    };
  }

  private final func IsTagged() -> Bool {
    return this.GetOwner().IsTaggedinFocusMode();
  }

  private final func AddRevealRequest(data: gameVisionModeSystemRevealIdentifier) -> Int32 {
    if !this.HasRevealRequest(data) {
      ArrayPush(this.m_activeRevealRequests, data);
      return ArraySize(this.m_activeRevealRequests) - 1;
    };
    return -1;
  }

  private final func RemoveRevealRequest(data: gameVisionModeSystemRevealIdentifier) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_activeRevealRequests) {
      if Equals(this.m_activeRevealRequests[i].reason, data.reason) && this.m_activeRevealRequests[i].sourceEntityId == data.sourceEntityId {
        ArrayErase(this.m_activeRevealRequests, i);
      } else {
        i += 1;
      };
    };
  }

  public final func HasRevealRequest(data: gameVisionModeSystemRevealIdentifier) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(this.m_activeRevealRequests) {
      if Equals(this.m_activeRevealRequests[i].reason, data.reason) && this.m_activeRevealRequests[i].sourceEntityId == data.sourceEntityId {
        return true;
      };
      i += 1;
    };
    return false;
  }

  private final const func GetRevealRequestIndex(data: gameVisionModeSystemRevealIdentifier) -> Int32 {
    let i: Int32 = 0;
    while i < ArraySize(this.m_activeRevealRequests) {
      if this.IsRequestTheSame(this.m_activeRevealRequests[i], data) {
        return i;
      };
      i += 1;
    };
    return -1;
  }

  private final const func IsRequestTheSame(request1: gameVisionModeSystemRevealIdentifier, request2: gameVisionModeSystemRevealIdentifier) -> Bool {
    if Equals(request1.reason, request2.reason) && request1.sourceEntityId == request2.sourceEntityId {
      return true;
    };
    return false;
  }

  public final const func IsRevealed() -> Bool {
    return ArraySize(this.m_activeRevealRequests) > 0;
  }

  private final func IsRevealRequestIndexValid(index: Int32) -> Bool {
    if index >= 0 && index < ArraySize(this.m_activeRevealRequests) {
      return true;
    };
    return false;
  }

  private final func UpdateDefaultHighlight(data: ref<FocusForcedHighlightData>) -> Void {
    if data == null {
      if this.m_currentDefaultHighlight != null {
        this.RemoveForcedHighlight(this.m_currentDefaultHighlight);
        this.m_currentDefaultHighlight = null;
      };
    } else {
      if this.m_currentDefaultHighlight == null {
        this.AddForcedHighlight(data);
        this.m_currentDefaultHighlight = data;
      } else {
        if this.m_currentDefaultHighlight != null && !this.CompareHighlightData(this.m_currentDefaultHighlight, data) {
          this.RemoveForcedHighlight(this.m_currentDefaultHighlight, true);
          this.AddForcedHighlight(data);
          this.m_currentDefaultHighlight = data;
        };
      };
    };
  }

  private final func RequestHUDRefresh() -> Void {
    let request: ref<RefreshActorRequest> = new RefreshActorRequest();
    request.ownerID = this.GetOwner().GetEntityID();
    this.GetOwner().GetHudManager().QueueRequest(request);
  }

  private final func GetVisionModeSystem() -> ref<VisionModeSystem> {
    return GameInstance.GetVisionModeSystem(this.GetOwner().GetGame());
  }

  private final func SendRevealStateChangedEvent(state: ERevealState, reason: gameVisionModeSystemRevealIdentifier) -> Void {
    let evt: ref<RevealStateChangedEvent>;
    let hudManager: ref<HUDManager>;
    let request: ref<RevealStatusNotification>;
    if NotEquals(state, ERevealState.CONTINUE) {
      hudManager = this.GetOwner().GetHudManager();
      if IsDefined(hudManager) {
        request = new RevealStatusNotification();
        request.ownerID = this.GetOwner().GetEntityID();
        if Equals(state, ERevealState.STARTED) {
          request.isRevealed = true;
        } else {
          if Equals(state, ERevealState.STOPPED) {
            request.isRevealed = false;
          };
        };
        hudManager.QueueRequest(request);
      };
    };
    evt = new RevealStateChangedEvent();
    evt.state = state;
    evt.reason = reason;
    if IsDefined(this.m_activeForcedHighlight) {
      evt.transitionTime = this.m_activeForcedHighlight.outTransitionTime;
    };
    this.GetOwner().QueueEvent(evt);
  }

  private final func ClearAllReavealRequests() -> Bool {
    let evaluate: Bool;
    let lastRequest: gameVisionModeSystemRevealIdentifier;
    let i: Int32 = ArraySize(this.m_activeRevealRequests) - 1;
    while i >= 0 {
      if NotEquals(this.m_activeRevealRequests[i].reason, n"tag") {
        evaluate = true;
        if i == 0 {
          lastRequest = this.m_activeRevealRequests[i];
        } else {
          ArrayErase(this.m_activeRevealRequests, i);
          i -= 1;
        };
      } else {
      };
      i -= 1;
    };
    if evaluate {
      this.RevealObject(false, lastRequest, 0.00);
    };
    return evaluate;
  }

  private final func ClearForcedHighlights() -> Bool {
    let evaluate: Bool;
    let i: Int32 = ArraySize(this.m_forcedHighlights) - 1;
    while i >= 0 {
      if this.m_forcedHighlights[i] != this.m_currentDefaultHighlight {
        ArrayErase(this.m_forcedHighlights, i);
        evaluate = true;
      };
      i -= 1;
    };
    if evaluate {
      this.EvaluateForcedHighLightsStack();
    };
    return evaluate;
  }

  private final func CompareHighlightData(data1: ref<FocusForcedHighlightData>, data2: ref<FocusForcedHighlightData>) -> Bool {
    if NotEquals(data1.patternType, data2.patternType) {
      return false;
    };
    if data1.sourceID != data2.sourceID || NotEquals(data1.sourceName, data2.sourceName) {
      return false;
    };
    if NotEquals(data1.highlightType, data2.highlightType) || NotEquals(data1.outlineType, data2.outlineType) {
      return false;
    };
    if IsDefined(data1.hudData) && !IsDefined(data2.hudData) || IsDefined(data2.hudData) && !IsDefined(data1.hudData) {
      return false;
    };
    if IsDefined(data1.hudData) && IsDefined(data2.hudData) {
      if NotEquals(data1.hudData.context, data2.hudData.context) {
        return false;
      };
      if NotEquals(data1.hudData.isRevealed, data2.hudData.isRevealed) {
        return false;
      };
    };
    return true;
  }

  protected final func ForwardHighlightToSlaveEntity(data: ref<FocusForcedHighlightData>, apply: Bool) -> Void {
    let evt: ref<ForceVisionApperanceEvent>;
    let i: Int32;
    let objectsToHighlight: array<wref<GameObject>> = this.GetOwner().GetObjectToForwardHighlight();
    if ArraySize(objectsToHighlight) <= 0 {
      return;
    };
    evt = new ForceVisionApperanceEvent();
    evt.forcedHighlight = data;
    evt.apply = apply;
    evt.forceCancel = true;
    evt.ignoreStackEvaluation = apply;
    i = 0;
    while i < ArraySize(objectsToHighlight) {
      this.GetOwner().QueueEventForEntityID(objectsToHighlight[i].GetEntityID(), evt);
      i += 1;
    };
  }

  protected final cb func OnForceVisionApperance(evt: ref<ForceVisionApperanceEvent>) -> Bool {
    let reason: gameVisionModeSystemRevealIdentifier;
    let responseEvt: ref<ResponseEvent>;
    if evt.forceCancel {
      if this.m_activeForcedHighlight != null {
        this.RemoveForcedHighlight(this.m_activeForcedHighlight, evt.ignoreStackEvaluation);
      } else {
        this.CancelForcedVisionAppearance(0.00);
      };
    };
    if evt.forcedHighlight != null {
      if evt.apply {
        if evt.forcedHighlight.isRevealed {
          reason.reason = evt.forcedHighlight.sourceName;
          reason.sourceEntityId = evt.forcedHighlight.sourceID;
          this.RevealObject(true, reason, 0.00);
        };
        this.AddForcedHighlight(evt.forcedHighlight);
      } else {
        if evt.forcedHighlight.isRevealed {
          reason.reason = evt.forcedHighlight.sourceName;
          reason.sourceEntityId = evt.forcedHighlight.sourceID;
          this.RevealObject(false, reason, 0.00);
        };
        this.RemoveForcedHighlight(evt.forcedHighlight, evt.ignoreStackEvaluation);
      };
      if IsDefined(evt.responseData) {
        responseEvt = new ResponseEvent();
        responseEvt.responseData = evt.responseData;
        this.GetOwner().QueueEventForEntityID(evt.forcedHighlight.sourceID, responseEvt);
      };
    };
  }

  protected final cb func OnRevealObject(evt: ref<RevealObjectEvent>) -> Bool {
    this.RevealObject(evt.reveal, evt.reason, evt.lifetime);
  }

  protected final cb func OnVisionRevealExpiredEvent(evt: ref<gameVisionRevealExpiredEvent>) -> Bool {
    this.RevealObject(false, evt.revealId, 0.00);
  }

  private final func RevealObject(reveal: Bool, reason: gameVisionModeSystemRevealIdentifier, lifetime: Float) -> Void {
    let index: Int32;
    let visonModeSystem: ref<VisionModeSystem>;
    if reveal {
      visonModeSystem = this.GetVisionModeSystem();
      index = this.GetRevealRequestIndex(reason);
      if this.IsRevealRequestIndexValid(index) && visonModeSystem.IsDelayedRevealInProgress(this.GetOwner().GetEntityID(), reason) {
        visonModeSystem.UnregisterDelayedReveal(this.GetOwner().GetEntityID(), reason);
        this.RemoveRevealRequest(reason);
      };
      if !this.IsRevealed() {
        this.SendRevealStateChangedEvent(ERevealState.STARTED, reason);
      } else {
        this.SendRevealStateChangedEvent(ERevealState.CONTINUE, reason);
      };
      index = this.AddRevealRequest(reason);
      if lifetime > 0.00 {
        if !this.IsRevealRequestIndexValid(index) {
          return;
        };
        this.RemoveRevealWithDelay(reason, lifetime);
        return;
      };
    } else {
      index = this.GetRevealRequestIndex(reason);
      if !this.IsRevealRequestIndexValid(index) {
        return;
      };
      if lifetime > 0.00 {
        this.RemoveRevealWithDelay(reason, lifetime);
        return;
      };
      this.RemoveRevealRequest(reason);
      if !this.IsRevealed() {
        this.SendRevealStateChangedEvent(ERevealState.STOPPED, reason);
      } else {
        this.SendRevealStateChangedEvent(ERevealState.CONTINUE, reason);
      };
    };
  }

  private final func RemoveRevealWithDelay(reason: gameVisionModeSystemRevealIdentifier, lifetime: Float) -> Void {
    this.GetVisionModeSystem().RegisterDelayedReveal(this.GetOwner().GetEntityID(), reason, lifetime);
  }

  protected final cb func OnForceReactivateHighlights(evt: ref<ForceReactivateHighlightsEvent>) -> Bool {
    this.ReactivateForceHighlight();
  }

  protected final cb func OnHUDInstruction(evt: ref<HUDInstruction>) -> Bool {
    let highlight: ref<FocusForcedHighlightData>;
    if Equals(evt.braindanceInstructions.GetState(), InstanceState.ON) {
      if this.GetOwner().IsBraindanceBlocked() || this.GetOwner().IsPhotoModeBlocked() {
        this.UpdateDefaultHighlight(null);
        this.ToggleRevealObject(false);
        return false;
      };
    };
    if Equals(evt.highlightInstructions.GetState(), InstanceState.ON) {
      highlight = this.GetDefaultHighlight(evt.highlightInstructions);
      this.UpdateDefaultHighlight(highlight);
      this.ToggleRevealObject(evt.highlightInstructions.isRevealed);
    } else {
      if evt.highlightInstructions.WasProcessed() {
        this.UpdateDefaultHighlight(null);
        this.ToggleRevealObject(false);
      };
    };
  }

  protected final cb func OnPulseEvent(evt: ref<gameVisionModeUpdateVisuals>) -> Bool {
    if evt.pulse {
      this.PulseObject();
    };
  }

  protected final cb func OnDeath(evt: ref<gameDeathEvent>) -> Bool {
    if !this.m_wasCleanedUp {
      this.CleanUp();
    };
  }

  protected final cb func OnDefeated(evt: ref<DefeatedEvent>) -> Bool {
    if !this.m_wasCleanedUp {
      this.CleanUp();
    };
  }

  private final func CleanUp() -> Void {
    this.ClearAllReavealRequests();
    this.ClearForcedHighlights();
  }

  protected final cb func OnForceUpdateDefultHighlight(evt: ref<ForceUpdateDefaultHighlightEvent>) -> Bool {
    this.RequestHUDRefresh();
  }

  protected final cb func OnSetForcedDefaultHighlight(evt: ref<SetDefaultHighlightEvent>) -> Bool {
    this.m_defaultHighlightData = evt.highlightData;
    this.RequestHUDRefresh();
  }

  protected final cb func OnRevealQuestTargetEvent(evt: ref<RevealQuestTargetEvent>) -> Bool {
    let duration: Float;
    let revealData: gameVisionModeSystemRevealIdentifier;
    revealData.reason = evt.sourceName;
    if Equals(evt.durationType, ERevealDurationType.TEMPORARY) && Equals(evt.reveal, true) {
      duration = evt.timeout;
    } else {
      duration = 0.00;
    };
    this.RevealObject(evt.reveal, revealData, duration);
  }

  protected final cb func OnSetPersistentForcedHighlightEvent(evt: ref<SetPersistentForcedHighlightEvent>) -> Bool {
    this.ToggleForcedHighlight(evt.sourceName, evt.highlightData, evt.operation);
  }

  protected final cb func OnToggleForcedHighlightEvent(evt: ref<ToggleForcedHighlightEvent>) -> Bool {
    this.ToggleForcedHighlight(evt.sourceName, evt.highlightData, evt.operation);
  }

  private final func ToggleForcedHighlight(sourceName: CName, highlightData: ref<HighlightEditableData>, operation: EToggleOperationType) -> Void {
    let reason: gameVisionModeSystemRevealIdentifier;
    let highlight: ref<FocusForcedHighlightData> = new FocusForcedHighlightData();
    highlight.sourceID = this.GetOwner().GetEntityID();
    highlight.sourceName = sourceName;
    highlight.highlightType = highlightData.highlightType;
    highlight.outlineType = highlightData.outlineType;
    highlight.inTransitionTime = highlightData.inTransitionTime;
    highlight.outTransitionTime = highlightData.outTransitionTime;
    highlight.priority = highlightData.priority;
    highlight.isSavable = true;
    if Equals(operation, EToggleOperationType.ADD) {
      this.AddForcedHighlight(highlight);
      if highlightData.isRevealed {
        reason.reason = sourceName;
        reason.sourceEntityId = this.GetOwner().GetEntityID();
        this.RevealObject(true, reason, 0.00);
      };
    } else {
      this.RemoveForcedHighlight(highlight);
      if highlightData.isRevealed {
        reason.reason = sourceName;
        reason.sourceEntityId = this.GetOwner().GetEntityID();
        this.RevealObject(false, reason, 0.00);
      };
    };
  }

  public final const func HasStaticDefaultHighlight() -> Bool {
    return this.m_defaultHighlightData != null;
  }

  public final const func HasDefaultHighlight() -> Bool {
    if this.GetOwner().IsBraindanceBlocked() || this.GetOwner().IsPhotoModeBlocked() {
      return false;
    };
    if IsDefined(this.m_defaultHighlightData) {
      return true;
    };
    return this.GetOwner().GetDefaultHighlight() != null;
  }

  public final const func HasOutlineOrFill(highlightType: EFocusForcedHighlightType, outlineType: EFocusOutlineType) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(this.m_forcedHighlights) {
      if Equals(this.m_forcedHighlights[i].highlightType, highlightType) || Equals(this.m_forcedHighlights[i].outlineType, outlineType) {
        return true;
      };
      i += 1;
    };
    return false;
  }

  public final const func HasHighlight(highlightType: EFocusForcedHighlightType, outlineType: EFocusOutlineType) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(this.m_forcedHighlights) {
      if Equals(this.m_forcedHighlights[i].highlightType, highlightType) && Equals(this.m_forcedHighlights[i].outlineType, outlineType) {
        return true;
      };
      i += 1;
    };
    return false;
  }

  public final const func HasHighlight(highlightType: EFocusForcedHighlightType, outlineType: EFocusOutlineType, sourceID: EntityID) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(this.m_forcedHighlights) {
      if Equals(this.m_forcedHighlights[i].highlightType, highlightType) && Equals(this.m_forcedHighlights[i].outlineType, outlineType) && this.m_forcedHighlights[i].sourceID == sourceID {
        return true;
      };
      i += 1;
    };
    return false;
  }

  public final const func HasHighlight(highlightType: EFocusForcedHighlightType, outlineType: EFocusOutlineType, sourceID: EntityID, sourceName: CName) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(this.m_forcedHighlights) {
      if Equals(this.m_forcedHighlights[i].highlightType, highlightType) && Equals(this.m_forcedHighlights[i].outlineType, outlineType) && this.m_forcedHighlights[i].sourceID == sourceID && Equals(this.m_forcedHighlights[i].sourceName, sourceName) {
        return true;
      };
      i += 1;
    };
    return false;
  }
}
