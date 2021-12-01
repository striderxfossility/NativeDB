
public class ArcadeMachine extends InteractiveDevice {

  private let m_isShortGlitchActive: Bool;

  private let m_shortGlitchDelayID: DelayID;

  private let m_currentGame: ResRef;

  protected let m_currentGameAudio: CName;

  protected let m_currentGameAudioStop: CName;

  private let m_meshAppearanceOn: CName;

  private let m_meshAppearanceOff: CName;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    EntityRequestComponentsInterface.RequestComponent(ri, n"ui", n"worlduiWidgetComponent", false);
    super.OnRequestComponents(ri);
  }

  public func ResavePersistentData(ps: ref<PersistentState>) -> Bool {
    return false;
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    this.m_uiComponent = EntityResolveComponentsInterface.GetComponent(ri, n"ui") as worlduiWidgetComponent;
    super.OnTakeControl(ri);
    this.m_controller = EntityResolveComponentsInterface.GetComponent(ri, n"controller") as ArcadeMachineController;
  }

  protected func ResolveGameplayState() -> Void {
    this.InitializeGame();
    this.ResolveGameplayState();
    if this.IsUIdirty() && this.m_isInsideLogicArea {
      this.RefreshUI();
    };
  }

  protected func CreateBlackboard() -> Void {
    this.m_blackboard = IBlackboard.Create(GetAllBlackboardDefs().ArcadeMachineBlackBoard);
  }

  public const func GetBlackboardDef() -> ref<DeviceBaseBlackboardDef> {
    return this.GetDevicePS().GetBlackboardDef();
  }

  protected const func GetController() -> ref<ScriptableDC> {
    return this.m_controller;
  }

  public const func GetDevicePS() -> ref<ScriptableDeviceComponentPS> {
    return this.GetControllerPersistentState() as ScriptableDeviceComponentPS;
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
    GameObjectEffectHelper.ActivateEffectAction(this, gamedataFxActionType.Start, n"hack_fx");
  }

  protected func StopGlitching() -> Void {
    let glitchData: GlitchData;
    let evt: ref<AdvertGlitchEvent> = new AdvertGlitchEvent();
    evt.SetShouldGlitch(0.00);
    this.QueueEvent(evt);
    glitchData.state = EGlitchState.NONE;
    this.GetBlackboard().SetVariant(this.GetBlackboardDef().GlitchData, ToVariant(glitchData));
    this.GetBlackboard().FireCallbacks();
    GameObjectEffectHelper.ActivateEffectAction(this, gamedataFxActionType.BreakLoop, n"hack_fx");
  }

  protected cb func OnHitEvent(hit: ref<gameHitEvent>) -> Bool {
    super.OnHitEvent(hit);
    this.StartShortGlitch();
  }

  private final func StartShortGlitch() -> Void {
    let evt: ref<StopShortGlitchEvent>;
    if this.GetDevicePS().IsGlitching() || this.GetDevicePS().IsDistracting() {
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
    if !this.GetDevicePS().IsGlitching() && !this.GetDevicePS().IsDistracting() {
      this.StopGlitching();
    };
  }

  protected func TurnOnDevice() -> Void {
    this.TurnOnDevice();
    this.TurnOnScreen();
  }

  protected func TurnOffDevice() -> Void {
    this.TurnOffDevice();
    this.TurnOffScreen();
  }

  protected func CutPower() -> Void {
    this.CutPower();
    this.TurnOffScreen();
  }

  protected func TurnOffScreen() -> Void {
    this.m_uiComponent.Toggle(false);
    GameObject.PlaySound(this, this.m_currentGameAudioStop);
    this.SetMeshAppearance(this.m_meshAppearanceOff);
  }

  protected func TurnOnScreen() -> Void {
    this.m_uiComponent.Toggle(true);
    GameObject.PlaySound(this, this.m_currentGameAudio);
    this.SetMeshAppearance(this.m_meshAppearanceOn);
  }

  public const func DeterminGameplayRole() -> EGameplayRole {
    return EGameplayRole.Distract;
  }

  protected func ApplyActiveStatusEffect(target: EntityID, statusEffect: TweakDBID) -> Void {
    if this.IsActiveStatusEffectValid() && this.GetDevicePS().IsGlitching() {
      GameInstance.GetStatusEffectSystem(this.GetGame()).ApplyStatusEffect(target, statusEffect);
    };
  }

  protected func UploadActiveProgramOnNPC(targetID: EntityID) -> Void {
    let evt: ref<ExecutePuppetActionEvent>;
    if this.IsActiveProgramToUploadOnNPCValid() && this.GetDevicePS().IsGlitching() {
      evt = new ExecutePuppetActionEvent();
      evt.actionID = this.GetActiveProgramToUploadOnNPC();
      this.QueueEventForEntityID(targetID, evt);
    };
  }

  private final func InitializeGame() -> Void {
    let randValue: Int32;
    let path: ResRef = (this.GetDevicePS() as ArcadeMachineControllerPS).GetGameVideoPath();
    if ResRef.IsValid(path) {
      this.m_currentGame = path;
    } else {
      randValue = RandRange(0, 5);
      if randValue == 0 {
        this.m_currentGame = r"base\\movies\\misc\\arcade\\hishousai_panzer.bk2";
      } else {
        if randValue == 1 {
          this.m_currentGame = r"base\\movies\\misc\\arcade\\quadracer.bk2";
        } else {
          if randValue == 2 {
            this.m_currentGame = r"base\\movies\\misc\\arcade\\retros.bk2";
          } else {
            if randValue == 3 {
              this.m_currentGame = r"base\\movies\\misc\\arcade\\roach_race.bk2";
            } else {
              if randValue == 4 {
                this.m_currentGame = r"base\\movies\\misc\\arcade\\roachrace.bk2";
              };
            };
          };
        };
      };
    };
    this.InitializeGameAudioVisuals(this.m_currentGame);
  }

  private final func InitializeGameAudioVisuals(path: ResRef) -> Void {
    if !ResRef.IsValid(path) {
      return;
    };
    if path == r"base\\movies\\misc\\arcade\\hishousai_panzer.bk2" {
      this.m_currentGameAudio = n"mus_cp_arcade_panzer_START_menu";
      this.m_currentGameAudioStop = n"mus_cp_arcade_panzer_STOP";
      this.m_meshAppearanceOn = n"ap4";
      this.m_meshAppearanceOff = n"ap4_off";
    } else {
      if path == r"base\\movies\\misc\\arcade\\quadracer.bk2" {
        this.m_currentGameAudio = n"mus_cp_arcade_quadra_START_menu";
        this.m_currentGameAudioStop = n"mus_cp_arcade_quadra_STOP";
        this.m_meshAppearanceOn = n"ap1";
        this.m_meshAppearanceOff = n"ap1_off";
      } else {
        if path == r"base\\movies\\misc\\arcade\\retros.bk2" {
          this.m_currentGameAudio = n"mus_cp_arcade_shooter_START_menu";
          this.m_currentGameAudioStop = n"mus_cp_arcade_shooter_STOP";
          this.m_meshAppearanceOn = n"ap3";
          this.m_meshAppearanceOff = n"ap3_off";
        } else {
          if path == r"base\\movies\\misc\\arcade\\roach_race.bk2" {
            this.m_currentGameAudio = n"mus_cp_arcade_roach_START_menu";
            this.m_currentGameAudioStop = n"mus_cp_arcade_roach_STOP";
            this.m_meshAppearanceOn = n"ap2";
            this.m_meshAppearanceOff = n"ap2_off";
          } else {
            if path == r"base\\movies\\misc\\arcade\\roachrace.bk2" {
              this.m_currentGameAudio = n"mus_cp_arcade_roach_START_menu";
              this.m_currentGameAudioStop = n"mus_cp_arcade_roach_STOP";
              this.m_meshAppearanceOn = n"ap2";
              this.m_meshAppearanceOff = n"ap2_off";
            } else {
              this.m_meshAppearanceOn = n"default";
              this.m_meshAppearanceOff = n"default";
            };
          };
        };
      };
    };
  }

  public final const func GetArcadeGame() -> ResRef {
    return this.m_currentGame;
  }

  public final const func GetArcadeGameAudio() -> CName {
    return this.m_currentGameAudio;
  }

  public final const func GetArcadeGameAudioStop() -> CName {
    return this.m_currentGameAudioStop;
  }
}
