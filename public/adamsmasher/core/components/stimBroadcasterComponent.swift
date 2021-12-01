
public static exec func CreateDebugStimuli(gameInstance: GameInstance, stimType: String, activeStim: String) -> Void {
  let broadcaster: ref<StimBroadcasterComponent>;
  let debugStim: gamedataStimType;
  let player: ref<PlayerPuppet>;
  StimBroadcasterComponent.nameToStimEnum(StringToName(stimType), debugStim);
  player = GameInstance.GetPlayerSystem(gameInstance).GetLocalPlayerMainGameObject() as PlayerPuppet;
  broadcaster = player.GetStimBroadcasterComponent();
  if IsDefined(broadcaster) {
    if Equals(activeStim, "true") {
      broadcaster.AddActiveStimuli(player, debugStim, 15.00);
    } else {
      broadcaster.TriggerSingleBroadcast(player, debugStim);
    };
  };
}

public struct StimRequestID {

  public let ID: Uint32;

  public let isValid: Bool;

  public final static func IsValid(self: StimRequestID) -> Bool {
    return self.isValid;
  }

  public final static func GetID(self: StimRequestID) -> Uint32 {
    return self.ID;
  }
}

public struct StimTargetData {

  public edit let spawnerRef: NodeRef;

  public edit let entryID: CName;

  public final static func IsValid(self: StimTargetData) -> Bool {
    return GlobalNodeRef.IsDefined(ResolveNodeRef(self.spawnerRef, Cast(GlobalNodeID.GetRoot()))) && IsNameValid(self.entryID);
  }
}

public class StimTargetsEvent extends Event {

  public edit let targets: array<StimTargetData>;

  public edit let restore: Bool;

  public final func GetFriendlyDescription() -> String {
    return "Stim Targets";
  }
}

public class StimBroadcasterComponent extends ScriptableComponent {

  public let m_activeRequests: array<ref<StimRequest>>;

  @default(StimBroadcasterComponent, 0)
  public let m_currentID: Uint32;

  public let m_shouldBroadcast: Bool;

  public let m_targets: array<NPCstubData>;

  @default(StimBroadcasterComponent, 1.0f)
  public let m_fallbackInterval: Float;

  public final static func BroadcastStim(sender: wref<GameObject>, gdStimType: gamedataStimType, opt radius: Float, opt investigateData: stimInvestigateData, opt propagationChange: Bool) -> Void {
    let broadcaster: ref<StimBroadcasterComponent>;
    if !IsDefined(sender) {
      return;
    };
    broadcaster = sender.GetStimBroadcasterComponent();
    if IsDefined(broadcaster) {
      broadcaster.TriggerSingleBroadcast(sender, gdStimType, radius, investigateData, propagationChange);
    };
  }

  public final static func BroadcastActiveStim(sender: wref<GameObject>, gdStimType: gamedataStimType, opt lifetime: Float, opt radius: Float, opt investigateData: stimInvestigateData, opt propagationChange: Bool) -> Void {
    let broadcaster: ref<StimBroadcasterComponent>;
    if !IsDefined(sender) {
      return;
    };
    broadcaster = sender.GetStimBroadcasterComponent();
    if IsDefined(broadcaster) {
      broadcaster.SetSingleActiveStimuli(sender, gdStimType, lifetime, radius, investigateData, propagationChange);
    };
  }

  public final static func SendStimDirectly(sender: wref<GameObject>, gdStimType: gamedataStimType, target: ref<GameObject>, opt investigateData: stimInvestigateData, opt delay: Float) -> Void {
    let broadcaster: ref<StimBroadcasterComponent>;
    if !IsDefined(sender) {
      return;
    };
    broadcaster = sender.GetStimBroadcasterComponent();
    if IsDefined(broadcaster) {
      broadcaster.SendDrirectStimuliToTarget(sender, gdStimType, target, investigateData, delay);
    };
  }

  public final func TriggerSingleBroadcast(contextOwner: wref<GameObject>, gdStimType: gamedataStimType, opt radius: Float, opt investigateData: stimInvestigateData, opt propagationChange: Bool) -> Void {
    let broadcastEvent: ref<BroadcastEvent>;
    let stimuliEvent: ref<StimuliEvent>;
    let owner: ref<GameObject> = this.GetOwner();
    if contextOwner == owner {
      stimuliEvent = StimBroadcasterComponentHelper.CreateStimEvent(owner, gdStimType, radius, investigateData, propagationChange);
      StimBroadcasterComponentHelper.ProcessSingleStimuliBroadcast(owner, stimuliEvent, (owner as ScriptedPuppet).IsCrowd(), IsDefined(owner as SurveillanceCamera), Equals(stimuliEvent.GetStimType(), gamedataStimType.Distract) && !(IsDefined(stimuliEvent.sourceObject) && stimuliEvent.sourceObject.CanBeInvestigated()), this.m_targets);
    } else {
      broadcastEvent = new BroadcastEvent();
      broadcastEvent.broadcastType = EBroadcasteingType.Single;
      broadcastEvent.stimType = gdStimType;
      broadcastEvent.radius = radius;
      broadcastEvent.stimData = investigateData;
      broadcastEvent.propagationChange = propagationChange;
      this.GetOwner().QueueEvent(broadcastEvent);
    };
  }

  public final func AddActiveStimuli(contextOwner: wref<GameObject>, gdStimType: gamedataStimType, opt lifetime: Float, opt radius: Float, opt investigateData: stimInvestigateData, opt propagationChange: Bool, opt shouldOverride: Bool) -> Void {
    let broadcastEvent: ref<BroadcastEvent>;
    if contextOwner == this.GetOwner() {
      this.AddActiveStimulus(gdStimType, lifetime, shouldOverride, radius, investigateData, propagationChange);
    } else {
      broadcastEvent = new BroadcastEvent();
      broadcastEvent.broadcastType = EBroadcasteingType.Active;
      broadcastEvent.stimType = gdStimType;
      broadcastEvent.lifetime = lifetime;
      broadcastEvent.radius = radius;
      broadcastEvent.stimData = investigateData;
      broadcastEvent.propagationChange = propagationChange;
      broadcastEvent.shouldOverride = shouldOverride;
      this.GetOwner().QueueEvent(broadcastEvent);
    };
  }

  public final func SetSingleActiveStimuli(contextOwner: wref<GameObject>, gdStimType: gamedataStimType, opt lifetime: Float, opt radius: Float, opt investigateData: stimInvestigateData, opt propagationChange: Bool) -> Void {
    let broadcastEvent: ref<BroadcastEvent>;
    if contextOwner == this.GetOwner() {
      this.ClearRequests();
      this.AddActiveStimulus(gdStimType, lifetime, false, radius, investigateData, propagationChange);
    } else {
      broadcastEvent = new BroadcastEvent();
      broadcastEvent.broadcastType = EBroadcasteingType.SingleActive;
      broadcastEvent.stimType = gdStimType;
      broadcastEvent.lifetime = lifetime;
      broadcastEvent.radius = radius;
      broadcastEvent.stimData = investigateData;
      broadcastEvent.propagationChange = propagationChange;
      this.GetOwner().QueueEvent(broadcastEvent);
    };
  }

  public final func RemoveActiveStimuliByName(contextOwner: wref<GameObject>, gdStimType: gamedataStimType) -> Void {
    let broadcastEvent: ref<BroadcastEvent>;
    if contextOwner == this.GetOwner() {
      this.ProcessStopRequest(gdStimType);
    } else {
      broadcastEvent = new BroadcastEvent();
      broadcastEvent.broadcastType = EBroadcasteingType.Remove;
      broadcastEvent.stimType = gdStimType;
      this.GetOwner().QueueEvent(broadcastEvent);
    };
  }

  public final func SendDrirectStimuliToTarget(contextOwner: wref<GameObject>, gdStimType: gamedataStimType, target: ref<GameObject>, opt investigateData: stimInvestigateData, opt delay: Float) -> Void {
    let broadcastEvent: ref<BroadcastEvent>;
    let newStim: ref<StimuliEvent>;
    if contextOwner == this.GetOwner() {
      newStim = StimBroadcasterComponentHelper.CreateStimEvent(this.GetOwner(), gdStimType, investigateData);
      if delay > 0.00 {
        GameInstance.GetDelaySystem(target.GetGame()).DelayEvent(target, newStim, delay);
      } else {
        target.QueueEvent(newStim);
      };
    } else {
      broadcastEvent = new BroadcastEvent();
      broadcastEvent.broadcastType = EBroadcasteingType.Direct;
      broadcastEvent.stimType = gdStimType;
      broadcastEvent.directTarget = target;
      broadcastEvent.delay = delay;
      broadcastEvent.stimData = investigateData;
      this.GetOwner().QueueEvent(broadcastEvent);
    };
  }

  protected cb func OnBroadcastEvent(evt: ref<BroadcastEvent>) -> Bool {
    let stimuliEvent: ref<StimuliEvent>;
    let owner: ref<GameObject> = this.GetOwner();
    switch evt.broadcastType {
      case EBroadcasteingType.Single:
        stimuliEvent = StimBroadcasterComponentHelper.CreateStimEvent(owner, evt.stimType, evt.radius, evt.stimData, evt.propagationChange);
        StimBroadcasterComponentHelper.ProcessSingleStimuliBroadcast(owner, stimuliEvent, (owner as ScriptedPuppet).IsCrowd(), IsDefined(owner as SurveillanceCamera), Equals(stimuliEvent.GetStimType(), gamedataStimType.Distract) && !(IsDefined(stimuliEvent.sourceObject) && stimuliEvent.sourceObject.CanBeInvestigated()), this.m_targets);
        break;
      case EBroadcasteingType.Direct:
        stimuliEvent = StimBroadcasterComponentHelper.CreateStimEvent(owner, evt.stimType, evt.stimData);
        if evt.delay > 0.00 {
          GameInstance.GetDelaySystem(owner.GetGame()).DelayEvent(evt.directTarget, stimuliEvent, evt.delay);
        } else {
          evt.directTarget.QueueEvent(stimuliEvent);
        };
        break;
      case EBroadcasteingType.Active:
        this.AddActiveStimulus(evt.stimType, evt.lifetime, evt.shouldOverride, evt.radius, evt.stimData, evt.propagationChange);
        break;
      case EBroadcasteingType.SingleActive:
        this.ClearRequests();
        this.AddActiveStimulus(evt.stimType, evt.lifetime, evt.shouldOverride, evt.radius, evt.stimData, evt.propagationChange);
        break;
      case EBroadcasteingType.Remove:
        this.ProcessStopRequest(evt.stimType);
    };
  }

  protected final func OnGameDetach() -> Void {
    this.ClearRequests();
  }

  protected cb func OnStimTargetsUpdate(evt: ref<StimTargetsEvent>) -> Bool {
    let i: Int32;
    if evt.restore {
      this.ClearStimTargets();
      return false;
    };
    i = 0;
    while i < ArraySize(evt.targets) {
      if !StimTargetData.IsValid(evt.targets[i]) {
      } else {
        if !this.HasStimTarget(evt.targets[i]) {
          this.AddStimmTarget(evt.targets[i]);
        };
      };
      i += 1;
    };
  }

  private final func ClearStimTargets() -> Void {
    ArrayClear(this.m_targets);
  }

  private final func HasStimTarget(data: StimTargetData) -> Bool {
    let spawnerID: EntityID = Cast(ResolveNodeRef(data.spawnerRef, Cast(GlobalNodeID.GetRoot())));
    let i: Int32 = 0;
    while i < ArraySize(this.m_targets) {
      if this.m_targets[i].spawnerID == spawnerID && Equals(this.m_targets[i].entryID, data.entryID) {
        return true;
      };
      i += 1;
    };
    return false;
  }

  private final func AddStimmTarget(data: StimTargetData) -> Void {
    let stubData: NPCstubData;
    stubData.spawnerID = Cast(ResolveNodeRef(data.spawnerRef, Cast(GlobalNodeID.GetRoot())));
    stubData.entryID = data.entryID;
    ArrayPush(this.m_targets, stubData);
  }

  public final const func HasStimTargets() -> Bool {
    return ArraySize(this.m_targets) > 0;
  }

  private final func AddActiveStimulus(gdStimType: gamedataStimType, lifetime: Float, opt shouldOverride: Bool, opt radius: Float, opt investigateData: stimInvestigateData, opt propagationChange: Bool) -> Void {
    let index: Int32;
    let owner: ref<GameObject> = this.GetOwner();
    let lootContainer: ref<gameLootContainerBase> = owner as gameLootContainerBase;
    let deviceBase: ref<DeviceBase> = owner as DeviceBase;
    if IsDefined(deviceBase) && !deviceBase.IsLogicReady() || IsDefined(lootContainer) && !lootContainer.IsLogicReady() {
      return;
    };
    if lifetime == 0.00 {
      return;
    };
    if shouldOverride {
      index = this.FindRequestIndexByName(gdStimType);
      this.RemoveRequest(index);
    };
    this.ProcessStartRequest(gdStimType, lifetime, radius, investigateData, propagationChange);
  }

  private final func RemoveActiveStimByID(id: StimRequestID) -> Void {
    let index: Int32 = this.FindRequestIndexByID(id);
    this.RemoveRequest(index);
  }

  private final func ProcessStartRequest(gdStimType: gamedataStimType, lifetime: Float, opt radius: Float, opt investigateData: stimInvestigateData, opt propagationChange: Bool) -> StimRequestID {
    let newStimRequest: ref<StimRequest>;
    let owner: ref<GameObject> = this.GetOwner();
    if this.IsRequestDuplicated(gdStimType) {
      LogAI("Stim already registered");
      return this.GenerateRequestID(0u, false);
    };
    newStimRequest = this.CreateStimRequest(gdStimType, lifetime, radius, investigateData, propagationChange);
    ArrayPush(this.m_activeRequests, newStimRequest);
    this.m_shouldBroadcast = true;
    this.AddNewDelayEvent();
    StimBroadcasterComponentHelper.ProcessSingleStimuliBroadcast(owner, newStimRequest.stimuli, (owner as ScriptedPuppet).IsCrowd(), IsDefined(owner as SurveillanceCamera), Equals(newStimRequest.stimuli.GetStimType(), gamedataStimType.Distract) && !(IsDefined(newStimRequest.stimuli.sourceObject) && newStimRequest.stimuli.sourceObject.CanBeInvestigated()), this.m_targets);
    return newStimRequest.requestID;
  }

  private final func ProcessStopRequest(gdStimType: gamedataStimType) -> Void {
    let indexRequest: Int32 = this.FindRequestIndexByName(gdStimType);
    this.RemoveRequest(indexRequest);
  }

  private final func RemoveRequest(index: Int32) -> Void {
    if index >= 0 {
      ArrayErase(this.m_activeRequests, index);
    } else {
      LogAI("Invalid index. Index to be >= 0");
    };
    if ArraySize(this.m_activeRequests) == 0 {
      this.StopTriggeringStims();
    };
  }

  private final func RemoveRequest(request: ref<StimRequest>) -> Void {
    this.RemoveRequest(this.FindRequestIndex(request));
  }

  private final func ClearRequests() -> Void {
    ArrayClear(this.m_activeRequests);
    this.m_currentID = 0u;
    this.m_shouldBroadcast = false;
  }

  private final func AddNewDelayEvent() -> Void {
    let evt: ref<RecurrentStimuliEvent> = new RecurrentStimuliEvent();
    let index: Int32 = ArraySize(this.m_activeRequests) - 1;
    let interval: Float = this.m_activeRequests[index].stimuli.GetStimInterval();
    evt.requestID = this.m_activeRequests[index].requestID;
    GameInstance.GetDelaySystem(this.GetOwner().GetGame()).DelayEvent(this.GetOwner(), evt, interval);
  }

  protected cb func OnRecurrentStimuliEvent(evt: ref<RecurrentStimuliEvent>) -> Bool {
    let owner: ref<GameObject> = this.GetOwner();
    let lootContainer: ref<gameLootContainerBase> = owner as gameLootContainerBase;
    let deviceBase: ref<DeviceBase> = owner as DeviceBase;
    if !this.m_shouldBroadcast || IsDefined(deviceBase) && !deviceBase.IsLogicReady() || IsDefined(lootContainer) && !lootContainer.IsLogicReady() {
      return false;
    };
    this.RebroadcastStimuli(evt);
  }

  private final func RebroadcastStimuli(evt: ref<RecurrentStimuliEvent>) -> Bool {
    let owner: ref<GameObject> = this.GetOwner();
    let requestID: StimRequestID = evt.requestID;
    let requestIndex: Int32 = this.FindRequestIndexByID(requestID);
    let request: ref<StimRequest> = this.GetRequestByID(requestID);
    if !IsDefined(request) {
      LogAI("Request with ID: " + IntToString(Cast(StimRequestID.GetID(requestID))) + " does not exist anymore");
      return false;
    };
    if !request.hasExpirationDate {
      GameInstance.GetDelaySystem(owner.GetGame()).DelayEvent(owner, evt, request.stimuli.GetStimInterval());
      return StimBroadcasterComponentHelper.ProcessSingleStimuliBroadcast(owner, request.stimuli, (owner as ScriptedPuppet).IsCrowd(), IsDefined(owner as SurveillanceCamera), Equals(request.stimuli.GetStimType(), gamedataStimType.Distract) && !(IsDefined(request.stimuli.sourceObject) && request.stimuli.sourceObject.CanBeInvestigated()), this.m_targets);
    };
    request.duration -= request.stimuli.GetStimInterval();
    if request.duration < 0.00 {
      this.RemoveRequest(requestIndex);
      return false;
    };
    GameInstance.GetDelaySystem(owner.GetGame()).DelayEvent(owner, evt, request.stimuli.GetStimInterval());
    return StimBroadcasterComponentHelper.ProcessSingleStimuliBroadcast(owner, request.stimuli, (owner as ScriptedPuppet).IsCrowd(), IsDefined(owner as SurveillanceCamera), Equals(request.stimuli.GetStimType(), gamedataStimType.Distract) && !(IsDefined(request.stimuli.sourceObject) && request.stimuli.sourceObject.CanBeInvestigated()), this.m_targets);
  }

  private final func StopTriggeringStims() -> Void {
    this.m_shouldBroadcast = false;
  }

  private final func CreateStimRequest(gdStimType: gamedataStimType, opt duration: Float, opt radius: Float, opt investigateData: stimInvestigateData, opt propagationChange: Bool) -> ref<StimRequest> {
    let newStimRequest: ref<StimRequest> = new StimRequest();
    newStimRequest.stimuli = StimBroadcasterComponentHelper.CreateStimEvent(this.GetOwner(), gdStimType, radius, investigateData, propagationChange);
    if duration > 0.00 {
      newStimRequest.hasExpirationDate = true;
    };
    newStimRequest.duration = duration;
    newStimRequest.requestID = this.AssignNextValidUniqueID();
    return newStimRequest;
  }

  private final func IsEqual(stim: ref<StimuliEvent>, gdStimType: gamedataStimType) -> Bool {
    if Equals(stim.name, EnumValueToName(n"gamedataStimType", Cast(EnumInt(gdStimType)))) {
      return true;
    };
    return false;
  }

  private final func IsRequestDuplicated(gdStimType: gamedataStimType) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(this.m_activeRequests) {
      if this.IsEqual(this.m_activeRequests[i].stimuli, gdStimType) {
        return true;
      };
      i += 1;
    };
    return false;
  }

  private final func GetRequestByID(id: StimRequestID) -> ref<StimRequest> {
    let index: Int32 = this.FindRequestIndexByID(id);
    return this.GetRequestByArrayIndex(index);
  }

  private final func GetRequestByName(gdStimType: gamedataStimType) -> ref<StimRequest> {
    let index: Int32 = this.FindRequestIndexByName(gdStimType);
    return this.GetRequestByArrayIndex(index);
  }

  private final func GetRequestByArrayIndex(index: Int32) -> ref<StimRequest> {
    if index >= 0 {
      return this.m_activeRequests[index];
    };
    LogAI("StimBroadcaster / Invalid Index. Request not found. Returning NULL");
    return null;
  }

  private final func FindRequestIndexByName(gdStimType: gamedataStimType) -> Int32 {
    let i: Int32 = 0;
    while i < ArraySize(this.m_activeRequests) {
      if this.IsEqual(this.m_activeRequests[i].stimuli, gdStimType) {
        return i;
      };
      i += 1;
    };
    return -1;
  }

  private final func FindRequestIndexByID(id: StimRequestID) -> Int32 {
    let i: Int32 = 0;
    while i < ArraySize(this.m_activeRequests) {
      if Equals(this.m_activeRequests[i].requestID, id) {
        return i;
      };
      i += 1;
    };
    return -1;
  }

  private final func FindRequestIndex(request: ref<StimRequest>) -> Int32 {
    let i: Int32 = 0;
    while i < ArraySize(this.m_activeRequests) {
      if this.m_activeRequests[i] == request {
        return i;
      };
      i += 1;
    };
    return -1;
  }

  private final func AssignNextValidUniqueID() -> StimRequestID {
    let requestID: StimRequestID;
    this.m_currentID += 1u;
    if this.m_currentID == 0u {
      this.m_currentID += 1u;
    };
    requestID = this.GenerateRequestID(this.m_currentID, true);
    return requestID;
  }

  private final func GenerateRequestID(id: Uint32, valid: Bool) -> StimRequestID {
    let newID: StimRequestID;
    newID.ID = id;
    newID.isValid = valid;
    return newID;
  }

  private final func DetermineHowManyRepeats(request: ref<StimRequest>) -> Int32 {
    let duration: Float = request.duration;
    let interval: Float = request.stimuli.GetStimInterval();
    let repeats: Int32 = Cast(duration / interval);
    return repeats;
  }

  protected cb func OnStatusEffectApplied(evt: ref<ApplyStatusEffectEvent>) -> Bool {
    let stimData: stimInvestigateData;
    if StatusEffectSystem.ObjectHasStatusEffectWithTag(this.GetOwner(), n"SpreadFear") {
      stimData.fearPhase = 3;
      this.TriggerSingleBroadcast(this.GetOwner(), gamedataStimType.SpreadFear, TweakDBInterface.GetFloat(t"AIGeneralSettings.spreadFearEffectStimuliRange", 5.00), stimData);
    };
    if StatusEffectSystem.ObjectHasStatusEffectWithTag(this.GetOwner(), n"GreaterSpreadFear") {
      stimData.fearPhase = 3;
      this.TriggerSingleBroadcast(this.GetOwner(), gamedataStimType.SpreadFear, TweakDBInterface.GetFloat(t"AIGeneralSettings.greaterSpreadFearEffectStimuliRange", 15.00), stimData);
    };
  }

  private final func LogStimuliBroadcast(stim: ref<StimuliEvent>, opt request: ref<StimRequest>, opt context: String) -> Void {
    let hasExpirationDate: Bool;
    let isNextDepartureScheduled: Bool;
    let requestPresent: Bool;
    let requestType: String;
    if IsDefined(request) {
      requestPresent = true;
      requestType = "Active Request";
      hasExpirationDate = request.hasExpirationDate;
      if !hasExpirationDate || request.duration >= stim.GetStimInterval() {
        isNextDepartureScheduled = true;
      };
    } else {
      requestPresent = false;
      requestType = "Single Event";
    };
    LogAI("//////////////////////////////////////////////////////////////////////////////////");
    LogAI("STIM BROADCAST LOG");
    LogAI("OPERATION TYPE:\t\t\t\t\t\t" + "SENDING");
    LogAI("Stim name:\t\t\t\t\t\t\t" + NameToString(stim.name));
    LogAI("Request Type:\t\t\t\t\t\t" + requestType);
    LogAI("DATA - Radius:\t\t\t\t\t\t" + FloatToString(stim.radius));
    LogAI("DATA - Time of departure:\t\t\t\t\t" + FloatToString(this.GetTimeSystem().GetGameTimeStamp()));
    if isNextDepartureScheduled {
      LogAI("DATA - Next departure estimated at:\t\t\t\t" + FloatToString(this.GetTimeSystem().GetGameTimeStamp() + stim.GetStimInterval()));
    } else {
      LogAI("DATA - Next departure estimated at:\t\t\t" + "Not planned. Last Reoccurence");
    };
    if requestPresent {
      LogAI("DATA - Has expiration date\t\t\t\t\t" + BoolToString(request.hasExpirationDate));
      if hasExpirationDate {
        LogAI("DATA - Duration remaining:\t\t\t\t\t" + FloatToString(request.duration));
      } else {
        LogAI("DATA - Duration remaining:\t\t\t" + "Undefined");
      };
      LogAI("DATA - RequestID\t\t\t\t\t\t" + IntToString(Cast(request.requestID.ID)));
    };
    LogAI("DATA - Stim sender:\t\t\t\t\t\t" + stim.sourceObject.GetDisplayName());
    LogAI("//////////////////////////////////////////////////////////////////////////////////");
  }

  private final func LogStimuliRemoval(stim: ref<StimuliEvent>, opt request: ref<StimRequest>) -> Void {
    LogAI("//////////////////////////////////////////////////////////////////////////////////");
    LogAI("STIM BROADCAST LOG");
    LogAI("OPERATION TYPE:\t\t\t\t\t\t" + "REMOVING");
    LogAI("Stim name:\t\t\t\t\t\t\t" + NameToString(stim.name));
    LogAI("DATA - RequestID\t\t\t\t\t\t" + IntToString(Cast(request.requestID.ID)));
    LogAI("DATA - Stim sender:\t\t\t\t\t\t" + stim.sourceObject.GetDisplayName());
    LogAI("DATA - Active Stims left:\t\t\t\t" + IntToString(ArraySize(this.m_activeRequests) - 1));
  }

  public final static func nameToStimEnum(stimName: CName, out stimType: gamedataStimType) -> Void {
    switch stimName {
      case n"DeadBody":
        stimType = gamedataStimType.DeadBody;
        break;
      case n"FootStepRegular":
        stimType = gamedataStimType.FootStepRegular;
        break;
      case n"Distract":
        stimType = gamedataStimType.Distract;
        break;
      case n"VisualDistract":
        stimType = gamedataStimType.VisualDistract;
        break;
      case n"Gunshot":
        stimType = gamedataStimType.Gunshot;
        break;
      case n"Reprimand":
        stimType = gamedataStimType.Reprimand;
        break;
      case n"Alarm":
        stimType = gamedataStimType.Alarm;
        break;
      case n"GrenadeLanded":
        stimType = gamedataStimType.GrenadeLanded;
        break;
      case n"IllegalAction":
        stimType = gamedataStimType.IllegalAction;
        break;
      case n"CarAlarm":
        stimType = gamedataStimType.CarAlarm;
        break;
      case n"ProjectileDistraction":
        stimType = gamedataStimType.ProjectileDistraction;
        break;
      case n"SoundDistraction":
        stimType = gamedataStimType.SoundDistraction;
        break;
      case n"OpeningDoor":
        stimType = gamedataStimType.OpeningDoor;
        break;
      case n"AreaEffec":
        stimType = gamedataStimType.AreaEffect;
        break;
      case n"Scream":
        stimType = gamedataStimType.Scream;
        break;
      case n"Attention":
        stimType = gamedataStimType.Attention;
        break;
      case n"Explosion":
        stimType = gamedataStimType.Explosion;
        break;
      case n"IllegalInteraction":
        stimType = gamedataStimType.IllegalInteraction;
        break;
      case n"Combat":
        stimType = gamedataStimType.Combat;
        break;
      case n"Bullet":
        stimType = gamedataStimType.Bullet;
        break;
      case n"CarryBody":
        stimType = gamedataStimType.CarryBody;
        break;
      case n"MeleeHit":
        stimType = gamedataStimType.MeleeHit;
        break;
      case n"VehicleHit":
        stimType = gamedataStimType.VehicleHit;
        break;
      case n"LandingVeryHard":
        stimType = gamedataStimType.LandingVeryHard;
        break;
      case n"Bump":
        stimType = gamedataStimType.Bump;
        break;
      case n"Police":
        stimType = gamedataStimType.CrimeWitness;
        break;
      case n"EnvironmentalHazard":
        stimType = gamedataStimType.EnvironmentalHazard;
        break;
      case n"VehicleHorn":
        stimType = gamedataStimType.VehicleHorn;
        break;
      default:
        stimType = gamedataStimType.Invalid;
    };
  }

  public final func TriggerNoiseStim(owner: wref<GameObject>, takedownActionType: ETakedownActionType) -> Void {
    if IsDefined(owner) {
      if Equals(takedownActionType, ETakedownActionType.Takedown) || Equals(takedownActionType, ETakedownActionType.AerialTakedown) || Equals(takedownActionType, ETakedownActionType.DisposalTakedown) {
        this.TriggerSingleBroadcast(owner, gamedataStimType.SoundDistraction, TweakDBInterface.GetFloat(t"AIGeneralSettings.takedownNoiseRange", 3.00));
      } else {
        if Equals(takedownActionType, ETakedownActionType.TakedownNonLethal) || Equals(takedownActionType, ETakedownActionType.DisposalTakedownNonLethal) {
          this.TriggerSingleBroadcast(owner, gamedataStimType.SoundDistraction, TweakDBInterface.GetFloat(t"AIGeneralSettings.takedownLessNoiseRange", 3.00));
        } else {
          if Equals(takedownActionType, ETakedownActionType.Grapple) || Equals(takedownActionType, ETakedownActionType.GrappleFailed) {
            this.TriggerSingleBroadcast(owner, gamedataStimType.SoundDistraction, TweakDBInterface.GetFloat(t"AIGeneralSettings.grappleNoiseRange", 3.00));
          };
        };
      };
    };
  }
}
