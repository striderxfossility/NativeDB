
public class BreachViewTimeListener extends TimeDilationListener {

  public let myOwner: wref<GameObject>;

  protected cb func OnFinished(reason: CName) -> Bool {
    if IsDefined(this.myOwner as ScriptedPuppet) {
      (this.myOwner as ScriptedPuppet).OnDiveFinished(reason);
    } else {
      if IsDefined(this.myOwner as AccessPoint) {
        (this.myOwner as AccessPoint).OnDiveFinished(reason);
      };
    };
  }

  public final func SetOwner(owner: ref<GameObject>) -> Void {
    this.myOwner = owner;
  }
}

public class AccessPoint extends InteractiveMasterDevice {

  @attrib(category, "Network Visualisation")
  @default(AccessPoint, Local Network 1)
  private let m_networkName: String;

  private let m_isPlayerInBreachView: Bool;

  private let m_isRevealed: Bool;

  private let m_breachViewTimeListener: ref<BreachViewTimeListener>;

  private let upload_program_listener_id: Uint32;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    super.OnRequestComponents(ri);
    EntityRequestComponentsInterface.RequestComponent(ri, n"routerUI", n"worlduiWidgetComponent", false);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    this.m_uiComponent = EntityResolveComponentsInterface.GetComponent(ri, n"routerUI") as worlduiWidgetComponent;
    super.OnTakeControl(ri);
    this.m_controller = EntityResolveComponentsInterface.GetComponent(ri, n"controller") as AccessPointController;
  }

  protected const func ShouldRegisterToHUD() -> Bool {
    if (this.GetDevicePS() as AccessPointControllerPS).IsVirtual() {
      return false;
    };
    return this.ShouldRegisterToHUD();
  }

  protected func ResolveGameplayState() -> Void {
    this.ResolveGameplayState();
    this.ToggleLights(!this.GetDevicePS().IsBreached());
    this.upload_program_listener_id = GameInstance.GetQuestsSystem(this.GetGame()).RegisterEntity(n"upload_program", this.GetEntityID());
  }

  protected final func ToggleLights(on: Bool) -> Void {
    let evt: ref<ToggleLightEvent> = new ToggleLightEvent();
    evt.toggle = on;
    this.QueueEvent(evt);
  }

  protected cb func OnGameDetached() -> Bool {
    GameInstance.GetQuestsSystem(this.GetGame()).UnregisterEntity(n"upload_program", this.upload_program_listener_id);
  }

  protected const func GetController() -> ref<ScriptableDC> {
    return this.m_controller;
  }

  public const func GetDevicePS() -> ref<ScriptableDeviceComponentPS> {
    return this.GetControllerPersistentState() as ScriptableDeviceComponentPS;
  }

  protected func InitiatePersonalLinkWorkspot(puppet: ref<GameObject>) -> Void {
    this.InitiatePersonalLinkWorkspot(puppet);
  }

  protected func PerformDive(attempt: Int32, isRemote: Bool) -> Void {
    this.PerformDive(attempt, isRemote);
  }

  protected cb func OnAccessPointMiniGameStatus(evt: ref<AccessPointMiniGameStatus>) -> Bool {
    super.OnAccessPointMiniGameStatus(evt);
    if Equals(evt.minigameState, HackingMinigameState.Succeeded) {
      this.ToggleLights(false);
    };
  }

  protected func TerminateConnection() -> Void {
    this.TerminateConnection();
  }

  protected cb func OnValidate(evt: ref<Validate>) -> Bool {
    if this.GetDevicePS().IsBreached() {
      this.ToggleLights(false);
    };
  }

  public const func CanRevealRemoteActionsWheel() -> Bool {
    return false;
  }

  public const func DeterminGameplayRole() -> EGameplayRole {
    return EGameplayRole.ControlNetwork;
  }

  public const func GetBlackboardDef() -> ref<DeviceBaseBlackboardDef> {
    return this.GetDevicePS().GetBlackboardDef();
  }

  protected final func BootModule(module: Int32) -> Void {
    this.GetBlackboard().SetInt(GetAllBlackboardDefs().BackdoorBlackboard.bootModule, module);
    this.GetBlackboard().FireCallbacks();
  }

  public const func IsAccessPoint() -> Bool {
    return true;
  }

  public final func IsRevealed() -> Bool {
    return this.m_isRevealed;
  }

  protected cb func OnDebugRemoteConnectionEvent(evt: ref<DebugRemoteConnectionEvent>) -> Bool {
    (this.GetDevicePS() as AccessPointControllerPS).DebugBreachConnectedDevices();
  }

  protected cb func OnFactChangedEvent(evt: ref<FactChangedEvent>) -> Bool {
    if Equals(evt.GetFactName(), n"upload_program") {
      this.UploadProgram();
    };
  }

  private final func UploadProgram() -> Void {
    let programID: Int32 = GameInstance.GetQuestsSystem(this.GetGame()).GetFact(n"upload_program");
    (this.GetDevicePS() as AccessPointControllerPS).UploadProgram(programID);
  }

  protected func TogglePersonalLink(toggle: Bool, puppet: ref<GameObject>) -> Void {
    this.TogglePersonalLink(toggle, puppet);
  }

  public final func OnDiveFinished(reason: CName) -> Void {
    let action: ref<DeviceAction>;
    let player: ref<GameObject>;
    if this.GetDevicePS().IsPersonalLinkConnected() && this.GetDevicePS().HasPersonalLinkSlot() {
      player = GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerMainGameObject();
      action = this.GetDevicePS().GetActionByName(n"TogglePersonalLink", this.GetDevicePS().GenerateContext(gamedeviceRequestType.Direct, Device.GetInteractionClearance(), player, this.GetEntityID()));
      this.ExecuteAction(action, player);
      (this.GetDevicePS() as AccessPointControllerPS).RefreshSlaves_Event();
    };
  }

  public const func IsControllingDevices() -> Bool {
    return false;
  }
}
