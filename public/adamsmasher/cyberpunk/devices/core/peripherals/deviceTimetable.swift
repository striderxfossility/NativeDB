
public class DeviceTimeTableManager extends IScriptable {

  protected persistent const let m_timeTable: array<SDeviceTimetableEntry>;

  public final func InitializeTimetable(owner: ref<GameObject>) -> Void {
    let entryTime: GameTime;
    let evt: ref<DeviceTimetableEvent>;
    let timeout: GameTime;
    let timeSystem: ref<TimeSystem> = GameInstance.GetTimeSystem(owner.GetGame());
    let currentTime: GameTime = this.GetCurrentTime(owner.GetGame());
    let i: Int32 = 0;
    while i < ArraySize(this.m_timeTable) {
      timeout = GameTime.MakeGameTime(0, 0, 0, 30);
      evt = new DeviceTimetableEvent();
      evt.state = this.m_timeTable[i].state;
      evt.requesterID = owner.GetEntityID();
      entryTime = GameTime.MakeGameTime(0, this.m_timeTable[i].time.hours, this.m_timeTable[i].time.minutes, this.m_timeTable[i].time.seconds);
      timeout += entryTime;
      this.m_timeTable[i].entryID = timeSystem.RegisterIntervalListener(owner, evt, entryTime, timeout, -1);
      if entryTime != currentTime && this.IsEntryActive(owner.GetGame(), i) {
        owner.QueueEvent(evt);
      };
      i += 1;
    };
  }

  public final func IsValid() -> Bool {
    return ArraySize(this.m_timeTable) > 0;
  }

  public final func UninitializeTimetable(game: GameInstance) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_timeTable) {
      GameInstance.GetTimeSystem(game).UnregisterListener(this.m_timeTable[i].entryID);
      i += 1;
    };
  }

  public final const func GetTimeTable() -> array<SDeviceTimetableEntry> {
    return this.m_timeTable;
  }

  public final const func GetDeviceStateForActiveEntry(game: GameInstance) -> EDeviceStatus {
    let state: EDeviceStatus;
    let id: Int32 = this.GetACtiveEntryID(game);
    if id >= 0 {
      state = this.m_timeTable[id].state;
    };
    return state;
  }

  public final const func GetACtiveEntryID(game: GameInstance) -> Int32 {
    let entryTime: GameTime;
    let storedtime: GameTime;
    let time: GameTime;
    let wasTimeStored: Bool;
    let currentTime: GameTime = this.GetCurrentTime(game);
    let id: Int32 = -1;
    let i: Int32 = 0;
    while i < ArraySize(this.m_timeTable) {
      entryTime = GameTime.MakeGameTime(0, this.m_timeTable[i].time.hours, this.m_timeTable[i].time.minutes, this.m_timeTable[i].time.seconds);
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

  private final const func IsEntryActive(game: GameInstance, entryID: Int32) -> Bool {
    return this.GetACtiveEntryID(game) == entryID;
  }

  private final const func GetCurrentTime(game: GameInstance) -> GameTime {
    let currentTime: GameTime = GameInstance.GetTimeSystem(game).GetGameTime();
    let time: GameTime = GameTime.MakeGameTime(0, GameTime.Hours(currentTime), GameTime.Minutes(currentTime), GameTime.Seconds(currentTime));
    return time;
  }
}

public class DeviceTimetable extends ScriptableComponent {

  public inline let m_timeTableSetup: ref<DeviceTimeTableManager>;

  private final func OnGameAttach() -> Void {
    this.InitializeTimetable();
  }

  private final func OnGameDetach() -> Void {
    this.UninitializeTimetable();
  }

  public final func SetTimetable(timetable: ref<DeviceTimeTableManager>) -> Void {
    this.m_timeTableSetup = timetable;
    this.InitializeTimetable();
  }

  private final func InitializeTimetable() -> Void {
    if this.m_timeTableSetup != null {
      this.m_timeTableSetup.InitializeTimetable(this.GetOwner());
    };
  }

  private final func UninitializeTimetable() -> Void {
    if this.m_timeTableSetup != null {
      this.m_timeTableSetup.UninitializeTimetable(this.GetOwner().GetGame());
    };
  }
}
