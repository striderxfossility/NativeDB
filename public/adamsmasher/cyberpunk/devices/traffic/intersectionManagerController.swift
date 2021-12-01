
public class InitiateTrafficLightChange extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"InitiateTrafficLightChange";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(this.actionName, true, this.actionName, this.actionName);
  }
}

public class TrafficIntersectionManagerController extends MasterController {

  protected const func GetPS() -> ref<GameComponentPS> {
    return this.GetBasePS();
  }
}

public class TrafficIntersectionManagerControllerPS extends MasterControllerPS {

  private persistent let m_trafficLightStatus: worldTrafficLightColor;

  private final func ActionInitiateTrafficLightChange() -> ref<InitiateTrafficLightChange> {
    let action: ref<InitiateTrafficLightChange> = new InitiateTrafficLightChange();
    action.clearanceLevel = DefaultActionsParametersHolder.GetToggleOnClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    action.CreateActionWidgetPackage();
    return action;
  }

  public func GetQuestActions(out outActions: array<ref<DeviceAction>>, context: GetActionsContext) -> Void {
    this.GetQuestActions(outActions, context);
    ArrayPush(outActions, this.ActionInitiateTrafficLightChange());
  }

  public final func OnInitiateTrafficLightChange(evt: ref<InitiateTrafficLightChange>) -> EntityNotificationType {
    this.HandleLightChangeRequest();
    return EntityNotificationType.SendPSChangedEventToEntity;
  }

  public final func HandleLightChangeRequest() -> Void {
    this.InitiateChangeLightsSequenceForEntireIntersection();
  }

  public final func SetLightChangeRequest(newColor: worldTrafficLightColor) -> Void {
    this.SetLightsSequenceForEntireIntersection(newColor);
  }

  private final func InitiateChangeLightsSequenceForEntireIntersection() -> Void {
    let devices: array<ref<DeviceComponentPS>>;
    let i: Int32;
    let toggleLightAction: ref<ToggleLight>;
    if !this.IsON() {
      return;
    };
    this.ToggleLights();
    GameInstance.GetDeviceSystem(this.GetGameInstance()).GetChildren(PersistentID.ExtractEntityID(this.GetID()), devices);
    i = 0;
    while i < ArraySize(devices) {
      toggleLightAction = (devices[i] as ScriptableDeviceComponentPS).GetActionByName(n"ToggleLight") as ToggleLight;
      if IsDefined(toggleLightAction) {
        this.GetPersistencySystem().QueuePSDeviceEvent(toggleLightAction);
      };
      i += 1;
    };
  }

  private final func SetLightsSequenceForEntireIntersection(newColor: worldTrafficLightColor) -> Void {
    let action: ref<DeviceAction>;
    let devices: array<ref<DeviceComponentPS>>;
    let i: Int32;
    if !this.IsON() {
      return;
    };
    this.m_trafficLightStatus = newColor;
    GameInstance.GetDeviceSystem(this.GetGameInstance()).GetChildren(PersistentID.ExtractEntityID(this.GetID()), devices);
    i = 0;
    while i < ArraySize(devices) {
      if Equals(newColor, worldTrafficLightColor.RED) {
        action = (devices[i] as ScriptableDeviceComponentPS).GetActionByName(n"TrafficLightRed");
      } else {
        action = (devices[i] as ScriptableDeviceComponentPS).GetActionByName(n"TrafficLightGreen");
      };
      if IsDefined(action) {
        this.GetPersistencySystem().QueuePSDeviceEvent(action);
      };
      i += 1;
    };
  }

  public final const func GetDesiredTrafficLightState() -> worldTrafficLightColor {
    return this.m_trafficLightStatus;
  }

  private final func ToggleLights() -> Void {
    this.m_trafficLightStatus = Equals(this.m_trafficLightStatus, worldTrafficLightColor.RED) ? worldTrafficLightColor.GREEN : worldTrafficLightColor.RED;
  }
}
