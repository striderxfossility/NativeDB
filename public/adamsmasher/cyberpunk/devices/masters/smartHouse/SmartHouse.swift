
public class ChangePresetEvent extends Event {

  public edit let presetID: ESmartHousePreset;

  public final func GetFriendlyDescription() -> String {
    return "Change Preset";
  }
}

public class EnableTimeCallbacks extends Event {

  public final func GetFriendlyDescription() -> String {
    return "Enable Time Callbacks";
  }
}

public class DisableTimeCallbacks extends Event {

  public final func GetFriendlyDescription() -> String {
    return "Disable Time Callbacks";
  }
}

public class SmartHouse extends InteractiveMasterDevice {

  @default(SmartHouse, true)
  protected let m_timetableActive: Bool;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    super.OnRequestComponents(ri);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    super.OnTakeControl(ri);
    this.m_controller = EntityResolveComponentsInterface.GetComponent(ri, n"controller") as SmartHouseController;
  }

  protected cb func OnGameAttached() -> Bool {
    super.OnGameAttached();
    (this.GetDevicePS() as SmartHouseControllerPS).RegisterFactCallback();
  }

  protected cb func OnDetach() -> Bool {
    super.OnDetach();
    (this.GetDevicePS() as SmartHouseControllerPS).UninitializeTimetable();
    (this.GetDevicePS() as SmartHouseControllerPS).UnregisterFactCallback();
  }

  protected cb func OnTimeTableCallback(evt: ref<PresetTimetableEvent>) -> Bool {
    if this.m_timetableActive {
      (this.GetDevicePS() as SmartHouseControllerPS).ActivatePreset(evt.arrayPosition);
    };
  }

  protected cb func OnFactChanged(evt: ref<FactChangedEvent>) -> Bool {
    super.OnFactChanged(evt);
    if Equals((this.GetDevicePS() as SmartHouseControllerPS).GetCustomizationFact(), evt.GetFactName()) {
      this.NotifyParents();
    };
  }

  protected cb func OnQuestChangePreset(evt: ref<ChangePresetEvent>) -> Bool {
    (this.GetDevicePS() as SmartHouseControllerPS).QuestForcePreset(StringToName(ToString(evt.presetID)));
  }

  protected cb func OnEnableTimeCallbacks(evt: ref<EnableTimeCallbacks>) -> Bool {
    this.m_timetableActive = true;
  }

  protected cb func OnDisableTimeCallbacks(evt: ref<DisableTimeCallbacks>) -> Bool {
    this.m_timetableActive = false;
  }

  protected const func GetController() -> ref<ScriptableDC> {
    return this.m_controller;
  }

  public const func GetDevicePS() -> ref<ScriptableDeviceComponentPS> {
    return this.GetControllerPersistentState() as ScriptableDeviceComponentPS;
  }
}
