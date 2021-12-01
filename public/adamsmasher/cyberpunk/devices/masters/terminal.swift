
public class Terminal extends InteractiveMasterDevice {

  protected let m_cameraFeed: ref<ScriptableVirtualCameraViewComponent>;

  private let m_isShortGlitchActive: Bool;

  private let m_shortGlitchDelayID: DelayID;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    EntityRequestComponentsInterface.RequestComponent(ri, n"terminalui", n"worlduiWidgetComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"disassemblableComponent", n"DisassemblableComponent", true);
    super.OnRequestComponents(ri);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    this.m_uiComponent = EntityResolveComponentsInterface.GetComponent(ri, n"terminalui") as worlduiWidgetComponent;
    this.m_disassemblableComponent = EntityResolveComponentsInterface.GetComponent(ri, n"disassemblableComponent") as DisassemblableComponent;
    super.OnTakeControl(ri);
    this.m_controller = EntityResolveComponentsInterface.GetComponent(ri, n"controller") as TerminalController;
  }

  protected func ResolveGameplayState() -> Void {
    this.ResolveGameplayState();
    this.ResetScreenToDefault();
  }

  protected cb func OnLogicReady(evt: ref<SetLogicReadyEvent>) -> Bool {
    super.OnLogicReady(evt);
    if this.IsUIdirty() && this.m_isInsideLogicArea {
      this.RefreshUI();
    };
  }

  protected cb func OnDetach() -> Bool {
    super.OnDetach();
    GameInstance.GetGlobalTVSystem(this.GetGame()).UnregisterTVChannelFromEntity(this);
  }

  protected cb func OnPersitentStateInitialized(evt: ref<GameAttachedEvent>) -> Bool {
    super.OnPersitentStateInitialized(evt);
  }

  protected func UpdateDeviceState(opt isDelayed: Bool) -> Bool {
    if this.UpdateDeviceState(isDelayed) {
      if this.GetDevicePS().HasActiveContext(gamedeviceRequestType.Direct) || this.GetDevicePS().IsAdvancedInteractionModeOn() || this.ShouldAlwasyRefreshUIInLogicAra() && this.m_isInsideLogicArea {
        this.RefreshUI(isDelayed);
      };
      return true;
    };
    return false;
  }

  protected func ShouldAlwasyRefreshUIInLogicAra() -> Bool {
    return true;
  }

  private const func GetController() -> ref<ScriptableDC> {
    return this.m_controller;
  }

  public const func GetDevicePS() -> ref<ScriptableDeviceComponentPS> {
    return this.GetControllerPersistentState() as ScriptableDeviceComponentPS;
  }

  protected func CreateBlackboard() -> Void {
    this.m_blackboard = IBlackboard.Create(GetAllBlackboardDefs().MasterDeviceBaseBlackboard);
  }

  public const func GetBlackboardDef() -> ref<DeviceBaseBlackboardDef> {
    return this.GetDevicePS().GetBlackboardDef();
  }

  protected func RestoreDeviceState() -> Void {
    this.RestoreDeviceState();
  }

  protected func CutPower() -> Void {
    this.TurnOffScreen();
    this.m_cameraFeed.Toggle(false);
  }

  protected func TurnOffDevice() -> Void {
    this.TurnOffScreen();
    this.m_cameraFeed.Toggle(false);
  }

  protected func TurnOnDevice() -> Void {
    this.TurnOnScreen();
  }

  protected cb func OnActionEngineering(evt: ref<ActionEngineering>) -> Bool {
    let playerStateMachineBlackboard: ref<IBlackboard>;
    this.EnterWorkspot(GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerControlledGameObject(), true, n"playerEngineeringWorkspot");
    playerStateMachineBlackboard = GameInstance.GetBlackboardSystem(this.GetGame()).Get(GetAllBlackboardDefs().PlayerStateMachine);
    playerStateMachineBlackboard.SetBool(GetAllBlackboardDefs().PlayerStateMachine.IsInteractingWithDevice, true);
  }

  protected cb func OnDisassembleDevice(evt: ref<DisassembleDevice>) -> Bool {
    this.m_disassemblableComponent.ObtainParts();
    this.UpdateDeviceState();
  }

  protected cb func OnWorkspotFinished(componentName: CName) -> Bool {
    super.OnWorkspotFinished(componentName);
    if Equals(componentName, n"disassembleWorkspot") {
      this.m_disassemblableComponent.ObtainParts();
    };
  }

  protected cb func OnAuthorizeUser(evt: ref<AuthorizeUser>) -> Bool {
    let action: ref<DeviceAction>;
    if this.ShouldExitZoomOnAuthorization() && this.GetDevicePS().IsAdvancedInteractionModeOn() {
      action = this.GetDevicePS().ActionToggleZoomInteraction();
      this.ExecuteAction(action, GetPlayer(this.GetGame()));
    };
    super.OnAuthorizeUser(evt);
  }

  public final const func IsAuthorizationModuleOn() -> Bool {
    return this.GetDevicePS().IsAuthorizationModuleOn();
  }

  private final func UnsecureTerminal() -> Void {
    this.ExecuteAction(this.GetDevicePS().GetActionByName(n"ToggleSecure"));
  }

  protected func ShouldExitZoomOnAuthorization() -> Bool {
    return true;
  }

  protected final func StartHacking(executor: ref<GameObject>) -> Void {
    if executor != null {
    };
  }

  protected final func ResetScreenToDefault() -> Void {
    if this.GetDevicePS().IsON() {
      return;
    };
    this.TurnOffScreen();
  }

  protected final func ShowScreenSaver() -> Void;

  protected final func TurnOffScreen() -> Void {
    this.m_uiComponent.Toggle(false);
    GameInstance.GetGlobalTVSystem(this.GetGame()).UnregisterTVChannelFromEntity(this);
  }

  protected final func TurnOnScreen() -> Void {
    this.m_uiComponent.Toggle(true);
  }

  protected final func SetState(state: gameinteractionsReactionState) -> Void {
    let evt: ref<TerminalSetState> = new TerminalSetState();
    evt.state = state;
    GameInstance.GetPersistencySystem(this.GetGame()).QueuePSEvent(this.GetController().GetPersistentID(), this.GetController().GetPSName(), evt);
  }

  private func InitializeScreenDefinition() -> Void {
    if !TDBID.IsValid(this.m_screenDefinition.screenDefinition) {
      this.m_screenDefinition.screenDefinition = t"DevicesUIDefinitions.Terminal_9x16";
    };
    if !TDBID.IsValid(this.m_screenDefinition.style) {
      this.m_screenDefinition.style = t"DevicesUIStyles.None";
    };
  }

  public const func ShouldShowTerminalTitle() -> Bool {
    return (this.GetDevicePS() as TerminalControllerPS).ShouldShowTerminalTitle();
  }

  protected func BreakDevice() -> Void {
    this.TurnOffScreen();
  }

  public const func DeterminGameplayRole() -> EGameplayRole {
    return EGameplayRole.ControlOtherDevice;
  }

  public const func GetDefaultGlitchVideoPath() -> ResRef {
    return (this.GetDevicePS() as TerminalControllerPS).GetDefaultGlitchVideoPath();
  }

  public const func GetBroadcastGlitchVideoPath() -> ResRef {
    return (this.GetDevicePS() as TerminalControllerPS).GetBroadcastGlitchVideoPath();
  }

  protected func StartGlitching(glitchState: EGlitchState, opt intensity: Float) -> Void {
    let evt: ref<AdvertGlitchEvent>;
    let glitchData: GlitchData;
    glitchData.state = glitchState;
    glitchData.intensity = intensity;
    if intensity == 0.00 {
      intensity = 1.00;
    };
    evt = new AdvertGlitchEvent();
    evt.SetShouldGlitch(intensity);
    this.QueueEvent(evt);
    this.GetBlackboard().SetVariant(this.GetBlackboardDef().GlitchData, ToVariant(glitchData), true);
    this.GetBlackboard().FireCallbacks();
  }

  protected func StopGlitching() -> Void {
    let glitchData: GlitchData;
    let evt: ref<AdvertGlitchEvent> = new AdvertGlitchEvent();
    evt.SetShouldGlitch(0.00);
    this.QueueEvent(evt);
    glitchData.state = EGlitchState.NONE;
    this.GetBlackboard().SetVariant(this.GetDevicePS().GetBlackboardDef().GlitchData, ToVariant(glitchData));
    this.GetBlackboard().FireCallbacks();
  }

  protected cb func OnHitEvent(hit: ref<gameHitEvent>) -> Bool {
    super.OnHitEvent(hit);
    this.StartShortGlitch();
  }

  private final func StartShortGlitch() -> Void {
    let evt: ref<StopShortGlitchEvent>;
    if this.GetDevicePS().IsGlitching() {
      return;
    };
    if !this.m_isShortGlitchActive {
      evt = new StopShortGlitchEvent();
      this.StartGlitching(EGlitchState.DEFAULT, 1.00);
      this.m_shortGlitchDelayID = GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, evt, 0.25);
      this.m_isShortGlitchActive = true;
    };
  }

  protected cb func OnStopShortGlitch(evt: ref<StopShortGlitchEvent>) -> Bool {
    this.m_isShortGlitchActive = false;
    if !this.GetDevicePS().IsGlitching() {
      this.StopGlitching();
    };
  }
}
