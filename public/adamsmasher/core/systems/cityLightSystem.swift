
public class TimetableCallbackData extends IScriptable {

  private persistent let m_time: SSimpleGameTime;

  private persistent let m_recipients: array<RecipientData>;

  private persistent let m_callbackID: Uint32;

  public final func Initialize(timetableEntry: SSimpleGameTime, recipient: RecipientData) -> Void {
    this.m_time = timetableEntry;
    this.AddRecipient(recipient);
  }

  public final const func GetTime() -> SSimpleGameTime {
    return this.m_time;
  }

  public final const func GetGameTime() -> GameTime {
    return GameTime.MakeGameTime(0, this.m_time.hours, this.m_time.minutes, this.m_time.seconds);
  }

  public final const func GetRecipients() -> array<RecipientData> {
    return this.m_recipients;
  }

  public final const func GetCallbackID() -> Uint32 {
    return this.m_callbackID;
  }

  public final func AddRecipient(recipient: RecipientData) -> Void {
    if !this.HasReciepient(recipient) {
      ArrayPush(this.m_recipients, recipient);
    };
  }

  public final func SetCallbackID(id: Uint32) -> Void {
    this.m_callbackID = id;
  }

  private final func HasReciepient(recipient: RecipientData) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(this.m_recipients) {
      if recipient.fuseID == this.m_recipients[i].fuseID {
        return true;
      };
      i += 1;
    };
    return false;
  }
}

public class ForceCLSStateRequest extends ScriptableSystemRequest {

  public edit let state: ECLSForcedState;

  public edit let sourceName: CName;

  @default(ForceCLSStateRequest, EPriority.Medium)
  public edit let priority: EPriority;

  @default(ForceCLSStateRequest, true)
  public edit let removePreviousRequests: Bool;

  @default(ForceCLSStateRequest, true)
  public let savable: Bool;

  public final func GetFriendlyDescription() -> String {
    return "Force CLS State";
  }
}

public class CLSWeatherListener extends WeatherScriptListener {

  private let m_owner: wref<CityLightSystem>;

  public final func Initialize(owner: ref<CityLightSystem>) -> Void {
    this.m_owner = owner;
  }

  public func OnRainIntensityChanged(rainIntensity: Float) -> Void;

  public func OnRainIntensityTypeChanged(rainIntensityType: worldRainIntensity) -> Void {
    if Equals(rainIntensityType, worldRainIntensity.HeavyRain) {
      this.TurnOnLights(n"RAIN");
    } else {
      if Equals(rainIntensityType, worldRainIntensity.NoRain) {
        this.TurnOffLights(n"RAIN");
      };
    };
  }

  private final func TurnOnLights(reason: CName) -> Void {
    let request: ref<ForceCLSStateRequest>;
    if IsDefined(this.m_owner) {
      request = new ForceCLSStateRequest();
      request.state = ECLSForcedState.ForcedON;
      request.sourceName = reason;
      request.priority = EPriority.VeryLow;
      request.removePreviousRequests = true;
      request.savable = false;
      this.m_owner.QueueRequest(request);
    };
  }

  private final func TurnOffLights(reason: CName) -> Void {
    let request: ref<ForceCLSStateRequest>;
    if IsDefined(this.m_owner) {
      request = new ForceCLSStateRequest();
      request.state = ECLSForcedState.DEFAULT;
      request.sourceName = reason;
      request.priority = EPriority.VeryLow;
      request.removePreviousRequests = true;
      request.savable = false;
      this.m_owner.QueueRequest(request);
    };
  }
}

public class CityLightSystem extends ScriptableSystem {

  private persistent let m_timeSystemCallbacks: array<ref<TimetableCallbackData>>;

  private persistent let m_fuses: array<FuseData>;

  @default(CityLightSystem, ECLSForcedState.DEFAULT)
  private persistent let m_state: ECLSForcedState;

  private persistent let m_forcedStateSource: CName;

  private persistent let m_forcedStatesStack: array<ForcedStateData>;

  private let m_weatherListener: ref<CLSWeatherListener>;

  private let m_turnOffLisenerID: CName;

  private let m_turnOnLisenerID: CName;

  private let m_resetLisenerID: CName;

  private let m_weatherCallbackId: Uint32;

  private func OnAttach() -> Void {
    if !IsFinal() {
      this.InitializeDebugButtons();
      this.ShowDebug_state();
    };
    this.m_weatherListener = new CLSWeatherListener();
    this.m_weatherListener.Initialize(this);
    this.m_weatherCallbackId = GameInstance.GetWeatherSystem(this.GetGameInstance()).RegisterWeatherListener(this.m_weatherListener);
  }

  private func OnDetach() -> Void {
    GameInstance.GetWeatherSystem(this.GetGameInstance()).UnregisterWeatherListener(this.m_weatherCallbackId);
    this.m_weatherListener = null;
    if !IsFinal() {
      this.UninitializeDebugButtons();
    };
  }

  private func OnRestored(saveVersion: Int32, gameVersion: Int32) -> Void {
    let i: Int32;
    this.ResolveForcedStatesStackOnLoad();
    i = 0;
    while i < ArraySize(this.m_timeSystemCallbacks) {
      this.RegisterTimetableCallback(this.m_timeSystemCallbacks[i]);
      i += 1;
    };
    if !IsFinal() {
      this.ShowDebug_fuses(this.m_fuses);
    };
  }

  private final func OnTimeTableCallbackRequest(request: ref<TimeTableCallbackRequest>) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_timeSystemCallbacks) {
      if request.m_callBackID == this.m_timeSystemCallbacks[i].GetCallbackID() {
        this.NotifyRecipients(this.m_timeSystemCallbacks[i]);
        if !IsFinal() {
          this.ShowDebug_fuses(this.m_fuses);
        };
      };
      i += 1;
    };
  }

  private final func OnRegisterTimetableRequest(request: ref<RegisterTimetableRequest>) -> Void {
    this.AddTimeTableCallbacks(request.requesterData, request.timeTable, request.lights);
  }

  private final func OnForceCLSStateRequest(request: ref<ForceCLSStateRequest>) -> Void {
    let shoulEvaluate: Bool;
    if Equals(request.state, ECLSForcedState.DEFAULT) {
      shoulEvaluate = this.RemoveForcedStateRequestForSource(request.sourceName);
    } else {
      if request.removePreviousRequests {
        this.RemoveForcedStateRequestForSource(request.sourceName);
      };
      shoulEvaluate = this.AddForcedStateRequest(request.state, request.sourceName, request.priority, request.savable);
    };
    if shoulEvaluate {
      this.EvaluateForcedStatesStack();
    };
  }

  private final func UpdateCLSForcedState() -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_fuses) {
      this.SendForceStateDeviceTimetableEvent(this.m_fuses[i], this.m_state);
      i += 1;
    };
  }

  private final func AddForcedStateRequest(state: ECLSForcedState, sourceName: CName, priority: EPriority, savable: Bool) -> Bool {
    let data: ForcedStateData;
    let i: Int32;
    if Equals(state, ECLSForcedState.DEFAULT) || !IsNameValid(sourceName) {
      return false;
    };
    i = 0;
    while i < ArraySize(this.m_forcedStatesStack) {
      if Equals(this.m_forcedStatesStack[i].state, state) && Equals(this.m_forcedStatesStack[i].sourceName, sourceName) && Equals(this.m_forcedStatesStack[i].priority, priority) {
        return false;
      };
      i += 1;
    };
    data.state = state;
    data.sourceName = sourceName;
    data.priority = priority;
    data.savable = savable;
    ArrayPush(this.m_forcedStatesStack, data);
    return true;
  }

  private final func RemoveForcedStateRequestForSource(sourceName: CName) -> Bool {
    let i: Int32;
    let wasRemoved: Bool;
    if !IsNameValid(sourceName) {
      return false;
    };
    i = ArraySize(this.m_forcedStatesStack) - 1;
    while i >= 0 {
      if Equals(this.m_forcedStatesStack[i].sourceName, sourceName) {
        ArrayErase(this.m_forcedStatesStack, i);
        wasRemoved = true;
      };
      i -= 1;
    };
    return wasRemoved;
  }

  private final func ResolveForcedStatesStackOnLoad() -> Void {
    let wasRemoved: Bool;
    let i: Int32 = ArraySize(this.m_forcedStatesStack) - 1;
    while i >= 0 {
      if !IsNameValid(this.m_forcedStatesStack[i].sourceName) || !this.IsForcedRequestSavable(this.m_forcedStatesStack[i]) {
        ArrayErase(this.m_forcedStatesStack, i);
        wasRemoved = true;
      };
      i -= 1;
    };
    if wasRemoved {
      this.EvaluateForcedStatesStack();
    };
  }

  private final func EvaluateForcedStatesStack() -> Void {
    let newSource: CName;
    let shouldUpdate: Bool = false;
    let newPriority: EPriority = EPriority.VeryLow;
    let newState: ECLSForcedState = ECLSForcedState.DEFAULT;
    let i: Int32 = 0;
    while i < ArraySize(this.m_forcedStatesStack) {
      if !IsNameValid(this.m_forcedStatesStack[i].sourceName) {
      } else {
        if EnumInt(this.m_forcedStatesStack[i].priority) >= EnumInt(newPriority) {
          newPriority = this.m_forcedStatesStack[i].priority;
          newState = this.m_forcedStatesStack[i].state;
          newSource = this.m_forcedStatesStack[i].sourceName;
        };
      };
      i += 1;
    };
    if NotEquals(this.m_state, newState) {
      shouldUpdate = true;
    };
    this.m_state = newState;
    this.m_forcedStateSource = newSource;
    if shouldUpdate {
      this.UpdateCLSForcedState();
      if !IsFinal() {
        this.ShowDebug_state();
      };
    };
  }

  private final func IsForcedRequestSavable(data: ForcedStateData) -> Bool {
    if Equals(data.sourceName, n"RAIN") {
      return false;
    };
    return data.savable;
  }

  private final func RegisterTimetableCallback(callbackData: ref<TimetableCallbackData>) -> Void {
    let timeSystem: ref<TimeSystem> = GameInstance.GetTimeSystem(this.GetGameInstance());
    let timeout: GameTime = GameTime.MakeGameTime(0, 24, 0, 0);
    let request: ref<TimeTableCallbackRequest> = new TimeTableCallbackRequest();
    let entryTime: GameTime = callbackData.GetGameTime();
    timeout += entryTime;
    request.m_callBackID = timeSystem.RegisterScriptableSystemIntervalListener(n"CityLightSystem", request, entryTime, timeout, -1);
    callbackData.SetCallbackID(request.m_callBackID);
    this.NotifyRecipientsOnRegistration(callbackData);
  }

  private final func NotifyRecipientsOnRegistration(callbackData: ref<TimetableCallbackData>) -> Void {
    let recipients: array<RecipientData> = callbackData.GetRecipients();
    let i: Int32 = 0;
    while i < ArraySize(recipients) {
      if this.ShouldNotifyRecipient(recipients[i], callbackData.GetGameTime()) {
        this.SendDeviceTimetableEvent(recipients[i]);
      };
      i += 1;
    };
  }

  private final func NotifyRecipients(callbackData: ref<TimetableCallbackData>) -> Void {
    let recipients: array<RecipientData> = callbackData.GetRecipients();
    this.SendNotificationToRecipients(recipients, callbackData.GetGameTime());
  }

  private final func SendNotificationToRecipients(recipients: array<RecipientData>, time: GameTime) -> Void {
    let excessRecipients: array<RecipientData>;
    let totalNotifications: Int32;
    let i: Int32 = 0;
    while i < ArraySize(recipients) {
      if totalNotifications >= this.GetMaxNotificationsPerFrame() {
        ArrayPush(excessRecipients, recipients[i]);
      } else {
        if this.ShouldNotifyRecipient(recipients[i], time) {
          this.SendDeviceTimetableEvent(recipients[i]);
          totalNotifications += 1;
        };
      };
      i += 1;
    };
    if ArraySize(excessRecipients) > 0 {
      this.SendNotificationByRequest(excessRecipients, time);
    };
  }

  private final func SendNotificationByRequest(recipients: array<RecipientData>, time: GameTime) -> Void {
    let request: ref<NotifyRecipientsRequest> = new NotifyRecipientsRequest();
    request.recipients = recipients;
    request.time = time;
    GameInstance.GetDelaySystem(this.GetGameInstance()).DelayScriptableSystemRequest(this.GetClassName(), request, 0.00, false);
  }

  private final func OnNotifyRecipientsrequest(request: ref<NotifyRecipientsRequest>) -> Void {
    this.SendNotificationToRecipients(request.recipients, request.time);
  }

  private final const func GetMaxNotificationsPerFrame() -> Int32 {
    return 50;
  }

  private final func SendDeviceTimetableEvent(data: RecipientData) -> Void {
    let fuse: FuseData;
    let evt: ref<DeviceTimetableEvent> = new DeviceTimetableEvent();
    if this.GetFuse(data.fuseID, fuse) {
      if Equals(this.m_state, ECLSForcedState.DEFAULT) {
        evt.state = fuse.timeTable[data.entryID].state;
      } else {
        if Equals(this.m_state, ECLSForcedState.ForcedON) {
          evt.state = EDeviceStatus.ON;
        } else {
          if Equals(this.m_state, ECLSForcedState.ForcedOFF) {
            evt.state = EDeviceStatus.OFF;
          };
        };
      };
      evt.requesterID = PersistentID.ExtractEntityID(fuse.psOwnerData.id);
      if EntityID.IsDefined(evt.requesterID) {
        GameInstance.GetPersistencySystem(this.GetGameInstance()).QueuePSEvent(fuse.psOwnerData.id, fuse.psOwnerData.className, evt);
      };
    };
  }

  private final func SendForceStateDeviceTimetableEvent(fuse: FuseData, state: ECLSForcedState) -> Void {
    let entry: SDeviceTimetableEntry;
    let evt: ref<DeviceTimetableEvent> = new DeviceTimetableEvent();
    if Equals(this.m_state, ECLSForcedState.DEFAULT) {
      this.GetActiveTimeTableEntry(fuse, entry);
      evt.state = entry.state;
    } else {
      if Equals(this.m_state, ECLSForcedState.ForcedON) {
        evt.state = EDeviceStatus.ON;
      } else {
        if Equals(this.m_state, ECLSForcedState.ForcedOFF) {
          evt.state = EDeviceStatus.OFF;
        };
      };
    };
    evt.requesterID = PersistentID.ExtractEntityID(fuse.psOwnerData.id);
    if EntityID.IsDefined(evt.requesterID) {
      GameInstance.GetPersistencySystem(this.GetGameInstance()).QueuePSEvent(fuse.psOwnerData.id, fuse.psOwnerData.className, evt);
    };
  }

  private final func AddTimeTableCallbacks(requesterData: PSOwnerData, timeTable: array<SDeviceTimetableEntry>, opt lights: Int32) -> Void {
    let callbackData: ref<TimetableCallbackData>;
    let recipientData: RecipientData;
    let fuseID: Int32 = this.AddFuse(requesterData, timeTable, lights);
    let i: Int32 = 0;
    while i < ArraySize(timeTable) {
      callbackData = this.GetTimeTableCallback(timeTable[i].time);
      recipientData.fuseID = fuseID;
      recipientData.entryID = i;
      if callbackData == null {
        callbackData = new TimetableCallbackData();
        callbackData.Initialize(timeTable[i].time, recipientData);
        ArrayPush(this.m_timeSystemCallbacks, callbackData);
        this.RegisterTimetableCallback(callbackData);
      } else {
        callbackData.AddRecipient(recipientData);
      };
      i += 1;
    };
  }

  private final func GetTimeTableCallback(time: SSimpleGameTime) -> ref<TimetableCallbackData> {
    let i: Int32 = 0;
    while i < ArraySize(this.m_timeSystemCallbacks) {
      if this.IsTimeTheSame(this.m_timeSystemCallbacks[i].GetTime(), time) {
        return this.m_timeSystemCallbacks[i];
      };
      i += 1;
    };
    return null;
  }

  private final func AddFuse(requesterData: PSOwnerData, timeTable: array<SDeviceTimetableEntry>, opt lights: Int32) -> Int32 {
    let fuse: FuseData;
    let id: Int32;
    if !this.HasFuse(requesterData, id) {
      fuse.psOwnerData = requesterData;
      fuse.timeTable = timeTable;
      fuse.lights = lights;
      ArrayPush(this.m_fuses, fuse);
      if !IsFinal() {
        this.ShowDebug_fuses(this.m_fuses);
      };
      id = ArraySize(this.m_fuses) - 1;
      return id;
    };
    return id;
  }

  private final const func HasFuse(requesterData: PSOwnerData, out id: Int32) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(this.m_fuses) {
      if Equals(this.m_fuses[i].psOwnerData.id, requesterData.id) {
        id = i;
        return true;
      };
      i += 1;
    };
    id = -1;
    return false;
  }

  private final const func GetFuseID(requesterData: PSOwnerData) -> Int32 {
    let i: Int32 = 0;
    while i < ArraySize(this.m_fuses) {
      if Equals(this.m_fuses[i].psOwnerData.id, requesterData.id) {
        return i;
      };
      i += 1;
    };
    return -1;
  }

  private final const func GetFuseID(id: PersistentID) -> Int32 {
    let i: Int32 = 0;
    while i < ArraySize(this.m_fuses) {
      if Equals(this.m_fuses[i].psOwnerData.id, id) {
        return i;
      };
      i += 1;
    };
    return -1;
  }

  private final const func GetFuse(fuseID: Int32, out fuseData: FuseData) -> Bool {
    if fuseID >= 0 && fuseID < ArraySize(this.m_fuses) {
      fuseData = this.m_fuses[fuseID];
      return true;
    };
    return false;
  }

  private final func IsTimeTheSame(time1: SSimpleGameTime, time2: SSimpleGameTime) -> Bool {
    return time1.hours == time2.hours && time1.minutes == time2.minutes && time1.seconds == time2.seconds;
  }

  private final const func GetCurrentTime() -> GameTime {
    let currentTime: GameTime = GameInstance.GetTimeSystem(this.GetGameInstance()).GetGameTime();
    let time: GameTime = GameTime.MakeGameTime(0, GameTime.Hours(currentTime), GameTime.Minutes(currentTime), GameTime.Seconds(currentTime));
    return time;
  }

  private final const func ShouldNotifyRecipient(recipient: RecipientData, callbackTime: GameTime) -> Bool {
    let entry: SDeviceTimetableEntry;
    let entryTime: GameTime;
    let fuse: FuseData;
    if !this.GetFuse(recipient.fuseID, fuse) {
      return false;
    };
    if this.GetActiveTimeTableEntry(fuse, entry) {
      entryTime = GameTime.MakeGameTime(0, entry.time.hours, entry.time.minutes, entry.time.seconds);
      return entryTime == callbackTime;
    };
    return false;
  }

  private final const func GetActiveTimeTableEntry(fuse: FuseData, out entry: SDeviceTimetableEntry) -> Bool {
    let entryTime: GameTime;
    let storedtime: GameTime;
    let time: GameTime;
    let wasTimeStored: Bool;
    let currentTime: GameTime = this.GetCurrentTime();
    let id: Int32 = -1;
    let i: Int32 = 0;
    while i < ArraySize(fuse.timeTable) {
      entryTime = GameTime.MakeGameTime(0, fuse.timeTable[i].time.hours, fuse.timeTable[i].time.minutes, fuse.timeTable[i].time.seconds);
      if currentTime < entryTime {
        time = GameTime.MakeGameTime(0, 24, 0, 0) - entryTime + currentTime;
      } else {
        time = currentTime - entryTime;
      };
      if time < storedtime || !wasTimeStored {
        wasTimeStored = true;
        storedtime = time;
        id = i;
        entry = fuse.timeTable[i];
      };
      i += 1;
    };
    return id >= 0;
  }

  private final const func GetActiveTimeTableEntryID(fuse: FuseData) -> Int32 {
    let entryTime: GameTime;
    let storedtime: GameTime;
    let time: GameTime;
    let wasTimeStored: Bool;
    let currentTime: GameTime = this.GetCurrentTime();
    let id: Int32 = -1;
    let i: Int32 = 0;
    while i < ArraySize(fuse.timeTable) {
      entryTime = GameTime.MakeGameTime(0, fuse.timeTable[i].time.hours, fuse.timeTable[i].time.minutes, fuse.timeTable[i].time.seconds);
      if currentTime < entryTime {
        time = GameTime.MakeGameTime(0, 24, 0, 0) - entryTime + currentTime;
      } else {
        time = currentTime - entryTime;
      };
      if time < storedtime || !wasTimeStored {
        wasTimeStored = true;
        storedtime = time;
        id = i;
      };
      i += 1;
    };
    return id;
  }

  public final const func GetFuseStateByID(id: PersistentID) -> EDeviceStatus {
    let entry: SDeviceTimetableEntry;
    let fuse: FuseData;
    let returnValue: EDeviceStatus = EDeviceStatus.DISABLED;
    if Equals(this.m_state, ECLSForcedState.DEFAULT) {
      if this.GetFuse(this.GetFuseID(id), fuse) {
        if this.GetActiveTimeTableEntry(fuse, entry) {
          returnValue = entry.state;
        };
      };
    } else {
      if Equals(this.m_state, ECLSForcedState.ForcedON) {
        returnValue = EDeviceStatus.ON;
      } else {
        if Equals(this.m_state, ECLSForcedState.ForcedOFF) {
          returnValue = EDeviceStatus.OFF;
        };
      };
    };
    return returnValue;
  }

  public final const func GetState() -> ECLSForcedState {
    return this.m_state;
  }

  public final const func GetFusesCount() -> Int32 {
    return ArraySize(this.m_fuses);
  }

  public final const func GetLightsCount() -> Int32 {
    let counter: Int32;
    let i: Int32 = 0;
    while i < ArraySize(this.m_fuses) {
      counter += this.m_fuses[i].lights;
      i += 1;
    };
    return counter;
  }

  public final const func GetCallbacks() -> array<ref<TimetableCallbackData>> {
    return this.m_timeSystemCallbacks;
  }

  private final func OnDebugButtonClicked(request: ref<SDOClickedRequest>) -> Void {
    let stateRequest: ref<ForceCLSStateRequest> = new ForceCLSStateRequest();
    if Equals(request.key, n"Turn On") {
      stateRequest.state = ECLSForcedState.ForcedON;
      stateRequest.sourceName = n"DEBUG";
      stateRequest.priority = EPriority.Absolute;
      stateRequest.removePreviousRequests = true;
      this.QueueRequest(stateRequest);
    } else {
      if Equals(request.key, n"Turn Off") {
        stateRequest.state = ECLSForcedState.ForcedOFF;
        stateRequest.sourceName = n"DEBUG";
        stateRequest.priority = EPriority.Absolute;
        stateRequest.removePreviousRequests = true;
        this.QueueRequest(stateRequest);
      } else {
        if Equals(request.key, n"Reset") {
          stateRequest.state = ECLSForcedState.DEFAULT;
          stateRequest.sourceName = n"DEBUG";
          stateRequest.priority = EPriority.Absolute;
          stateRequest.removePreviousRequests = true;
          this.QueueRequest(stateRequest);
        };
      };
    };
  }

  private final func UninitializeDebugButtons() -> Void {
    let sink: SDOSink = GameInstance.GetScriptsDebugOverlaySystem(this.GetGameInstance()).CreateSink();
    SDOSink.SetRoot(sink, "CLS");
    SDOSink.UnregisterListener_OnClicked(sink, this, this.m_turnOffLisenerID);
    SDOSink.UnregisterListener_OnClicked(sink, this, this.m_turnOnLisenerID);
    SDOSink.UnregisterListener_OnClicked(sink, this, this.m_resetLisenerID);
  }

  private final func InitializeDebugButtons() -> Void {
    let sink: SDOSink = GameInstance.GetScriptsDebugOverlaySystem(this.GetGameInstance()).CreateSink();
    SDOSink.SetRoot(sink, "CLS");
    SDOSink.PushString(sink, "Turn On", "EXECUTE");
    SDOSink.PushString(sink, "Turn Off", "EXECUTE");
    SDOSink.PushString(sink, "Reset", "EXECUTE");
    this.m_turnOnLisenerID = SDOSink.RegisterListener_OnClicked(sink, this, "Turn On");
    this.m_turnOffLisenerID = SDOSink.RegisterListener_OnClicked(sink, this, "Turn Off");
    this.m_resetLisenerID = SDOSink.RegisterListener_OnClicked(sink, this, "Reset");
  }

  private final func ShowDebug_state() -> Void {
    let sink: SDOSink = GameInstance.GetScriptsDebugOverlaySystem(this.GetGameInstance()).CreateSink();
    SDOSink.SetRoot(sink, "CLS");
    SDOSink.PushString(sink, "STATE", ToString(this.GetState()));
    SDOSink.SetRoot(sink, "CLS/STATE");
    SDOSink.PushName(sink, "SOURCE", this.m_forcedStateSource);
  }

  private final func ShowDebug_fuses(fuses: array<FuseData>) -> Void {
    let activeEntry: SDeviceTimetableEntry;
    let entryString: String;
    let globalIDString: String;
    let i: Int32;
    let k: Int32;
    let stateString: String;
    let sink: SDOSink = GameInstance.GetScriptsDebugOverlaySystem(this.GetGameInstance()).CreateSink();
    SDOSink.SetRoot(sink, "CLS");
    SDOSink.PushString(sink, "FUSES", ToString(this.GetFusesCount()));
    SDOSink.PushString(sink, "LIGHTS", ToString(this.GetLightsCount()));
    i = 0;
    while i < ArraySize(fuses) {
      globalIDString = PersistentID.ToDebugString(fuses[i].psOwnerData.id);
      if !PersistentID.IsDefined(fuses[i].psOwnerData.id) {
        globalIDString += " [WARNING: INVALID GLOBAL ID!]";
      };
      SDOSink.SetRoot(sink, "CLS/FUSES/fuse" + ToString(i));
      SDOSink.PushString(sink, "", globalIDString);
      SDOSink.PushString(sink, "globalID", globalIDString);
      SDOSink.PushString(sink, "connectedLights", ToString(fuses[i].lights));
      k = 0;
      while k < ArraySize(fuses[i].timeTable) {
        activeEntry = fuses[i].timeTable[k];
        entryString = ToString(activeEntry.time.hours) + " : " + ToString(activeEntry.time.minutes) + " : " + ToString(activeEntry.time.seconds);
        stateString = " [" + ToString(activeEntry.state) + "]";
        entryString += stateString;
        if this.GetActiveTimeTableEntryID(fuses[i]) == k {
          entryString += " [ACTIVE]";
        };
        SDOSink.PushString(sink, "entry" + ToString(k), entryString);
        k += 1;
      };
      i += 1;
    };
  }
}

public static exec func CLS_on(gameInstance: GameInstance) -> Void {
  let request: ref<ForceCLSStateRequest>;
  let system: ref<CityLightSystem> = GameInstance.GetScriptableSystemsContainer(gameInstance).Get(n"CityLightSystem") as CityLightSystem;
  if IsDefined(system) {
    request = new ForceCLSStateRequest();
    request.state = ECLSForcedState.ForcedON;
    request.sourceName = n"DEBUG";
    request.priority = EPriority.Absolute;
    request.removePreviousRequests = true;
    system.QueueRequest(request);
  };
}

public static exec func CLS_off(gameInstance: GameInstance) -> Void {
  let request: ref<ForceCLSStateRequest>;
  let system: ref<CityLightSystem> = GameInstance.GetScriptableSystemsContainer(gameInstance).Get(n"CityLightSystem") as CityLightSystem;
  if IsDefined(system) {
    request = new ForceCLSStateRequest();
    request.state = ECLSForcedState.ForcedOFF;
    request.sourceName = n"DEBUG";
    request.priority = EPriority.Absolute;
    request.removePreviousRequests = true;
    system.QueueRequest(request);
  };
}

public static exec func CLS_reset(gameInstance: GameInstance) -> Void {
  let request: ref<ForceCLSStateRequest>;
  let system: ref<CityLightSystem> = GameInstance.GetScriptableSystemsContainer(gameInstance).Get(n"CityLightSystem") as CityLightSystem;
  if IsDefined(system) {
    request = new ForceCLSStateRequest();
    request.state = ECLSForcedState.DEFAULT;
    request.sourceName = n"DEBUG";
    request.priority = EPriority.Absolute;
    request.removePreviousRequests = true;
    system.QueueRequest(request);
  };
}
