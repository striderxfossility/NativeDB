
public class SmartHouseController extends MasterController {

  protected const func GetPS() -> ref<GameComponentPS> {
    return this.GetBasePS();
  }
}

public class SmartHouseControllerPS extends MasterControllerPS {

  protected let m_timetable: array<SPresetTimetableEntry>;

  protected inline let m_activePreset: ref<SmartHousePreset>;

  protected inline const let m_availablePresets: array<ref<SmartHousePreset>>;

  protected let m_smartHouseCustomization: SmartHouseConfiguration;

  protected let m_callbackID: Uint32;

  protected cb func OnInstantiated() -> Bool {
    super.OnInstantiated();
  }

  protected func Initialize() -> Void {
    this.Initialize();
  }

  protected func GameAttached() -> Void {
    this.InitializePreset();
  }

  public final func GetCustomizationFact() -> CName {
    return this.m_smartHouseCustomization.factName;
  }

  public final func RegisterFactCallback() -> Void {
    if this.m_smartHouseCustomization.enableInteraction && IsNameValid(this.m_smartHouseCustomization.factName) {
      this.m_callbackID = GameInstance.GetQuestsSystem(this.GetGameInstance()).RegisterEntity(this.m_smartHouseCustomization.factName, PersistentID.ExtractEntityID(this.GetID()));
    };
  }

  public final func UnregisterFactCallback() -> Void {
    if this.m_smartHouseCustomization.enableInteraction && IsNameValid(this.m_smartHouseCustomization.factName) {
      GameInstance.GetQuestsSystem(this.GetGameInstance()).UnregisterEntity(this.m_smartHouseCustomization.factName, this.m_callbackID);
    };
  }

  public func GetActions(out outActions: array<ref<DeviceAction>>, context: GetActionsContext) -> Bool {
    let fact: Int32;
    let i: Int32;
    this.GetActions(outActions, context);
    i = 0;
    while i < ArraySize(this.m_availablePresets) {
      if this.m_activePreset != this.m_availablePresets[i] && PresetAction.IsAvailable(this) {
        ArrayPush(outActions, this.ActionPreset(this.m_availablePresets[i]));
      };
      i += 1;
    };
    fact = GameInstance.GetQuestsSystem(this.GetGameInstance()).GetFact(this.m_smartHouseCustomization.factName);
    if this.m_smartHouseCustomization.enableInteraction && fact == 0 {
      ArrayPush(outActions, this.ActionOpenInteriorManager());
    };
    this.SetActionIllegality(outActions, this.m_illegalActions.regularActions);
    return true;
  }

  protected final func ActionOpenInteriorManager() -> ref<OpenInteriorManager> {
    let action: ref<OpenInteriorManager> = new OpenInteriorManager();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    action.CreateActionWidgetPackage();
    return action;
  }

  public func OnOpenInteriorManager(evt: ref<OpenInteriorManager>) -> EntityNotificationType {
    this.UseNotifier(evt);
    SetFactValue(this.GetGameInstance(), this.m_smartHouseCustomization.factName, 1);
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected final func ActionPreset(preset: ref<SmartHousePreset>) -> ref<PresetAction> {
    let action: ref<PresetAction> = new PresetAction();
    action.clearanceLevel = DefaultActionsParametersHolder.GetToggleOnClearance();
    action.SetUp(this);
    action.SetProperties(preset);
    action.AddDeviceName(this.m_deviceName);
    action.CreateActionWidgetPackage();
    return action;
  }

  public func OnPresetAction(evt: ref<PresetAction>) -> EntityNotificationType {
    this.UseNotifier(evt);
    this.m_activePreset = evt.GetPreset();
    this.m_activePreset.ExecutePresetActions(this.GetImmediateSlaves());
    return EntityNotificationType.SendThisEventToEntity;
  }

  public final func ActivatePreset(i: Int32) -> Void {
    this.m_activePreset = this.m_availablePresets[i];
    if this.GetActiveTimeTableEntry() == i {
      this.m_activePreset.ExecutePresetActions(this.GetImmediateSlaves());
    };
  }

  public final func QuestForcePreset(preset: CName) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_availablePresets) {
      if Equals(this.m_availablePresets[i].GetClassName(), preset) {
        this.m_activePreset = this.m_availablePresets[i];
        this.m_activePreset.ExecutePresetActions(this.GetImmediateSlaves());
        this.NotifyParents();
      } else {
        i += 1;
      };
    };
  }

  protected final func InitializePreset() -> Void {
    let currentTimetable: SPresetTimetableEntry;
    let i: Int32 = 0;
    while i < ArraySize(this.m_availablePresets) {
      currentTimetable = this.m_availablePresets[i].GetTimeTable();
      if ArraySize(this.m_timetable) == 0 {
        if currentTimetable.useTime {
          currentTimetable.arrayPosition = i;
          ArrayPush(this.m_timetable, currentTimetable);
        };
      } else {
        this.CheckTimetable(currentTimetable, i);
      };
      i += 1;
    };
    this.InitializeTimetable();
  }

  protected final func InitializeTimetable() -> Void {
    let entryTime: GameTime;
    let evt: ref<PresetTimetableEvent>;
    let timeout: GameTime;
    let timeSystem: ref<TimeSystem> = GameInstance.GetTimeSystem(this.GetGameInstance());
    let activeEntry: Int32 = this.GetActiveTimeTableEntry();
    let i: Int32 = 0;
    while i < ArraySize(this.m_timetable) {
      evt = new PresetTimetableEvent();
      evt.arrayPosition = this.m_timetable[i].arrayPosition;
      entryTime = this.MakeTime(this.m_timetable[i].time);
      timeout = GameTime.MakeGameTime(0, 24, 0, 0);
      this.m_timetable[i].entryID = timeSystem.RegisterIntervalListener(this.GetOwnerEntityWeak(), evt, entryTime, timeout, -1);
      if i == activeEntry {
        this.GetOwnerEntityWeak().QueueEvent(evt);
      };
      i += 1;
    };
  }

  public final func UninitializeTimetable() -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_timetable) {
      GameInstance.GetTimeSystem(this.GetGameInstance()).UnregisterListener(this.m_timetable[i].entryID);
      i += 1;
    };
  }

  protected final const func GetActiveTimeTableEntry() -> Int32 {
    let entryTime: GameTime;
    let id: Int32;
    let storedtime: GameTime;
    let time: GameTime;
    let wasTimeStored: Bool;
    let currentTime: GameTime = this.GetCurrentTime();
    let i: Int32 = 0;
    while i < ArraySize(this.m_timetable) {
      entryTime = this.MakeTime(this.m_timetable[i].time);
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

  protected final func CheckTimetable(newTable: SPresetTimetableEntry, arrayPos: Int32) -> Void {
    let sameHour: Bool;
    let i: Int32 = 0;
    while i < ArraySize(this.m_timetable) {
      if newTable.useTime {
        if this.m_timetable[i].time.hours == newTable.time.hours {
          sameHour = true;
        };
      };
      i += 1;
    };
    if !sameHour {
      newTable.arrayPosition = arrayPos;
      ArrayPush(this.m_timetable, newTable);
    };
  }

  protected final const func GetCurrentTime() -> GameTime {
    let currentTime: GameTime = GameInstance.GetTimeSystem(this.GetGameInstance()).GetGameTime();
    return GameTime.MakeGameTime(0, GameTime.Hours(currentTime), GameTime.Minutes(currentTime), GameTime.Seconds(currentTime));
  }

  protected final const func MakeTime(time: SSimpleGameTime) -> GameTime {
    return GameTime.MakeGameTime(0, time.hours, time.minutes, time.seconds);
  }

  public func GetDeviceWidget(context: GetActionsContext) -> SDeviceWidgetPackage {
    let widgetData: SDeviceWidgetPackage = this.GetDeviceWidget(context);
    return widgetData;
  }

  protected func GetInkWidgetTweakDBID(context: GetActionsContext) -> TweakDBID {
    if !this.IsUserAuthorized(context.processInitiatorObject.GetEntityID()) && !context.ignoresAuthorization {
      return this.GetInkWidgetTweakDBID(context);
    };
    return t"DevicesUIDefinitions.SmartHouseDeviceWidget";
  }
}
