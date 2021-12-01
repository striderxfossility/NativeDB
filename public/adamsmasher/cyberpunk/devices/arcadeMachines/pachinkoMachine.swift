
public class PachinkoMachine extends ArcadeMachine {

  @default(PachinkoMachine, effect_distraction)
  protected let m_distractionFXName: CName;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    super.OnRequestComponents(ri);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    super.OnTakeControl(ri);
    this.m_controller = EntityResolveComponentsInterface.GetComponent(ri, n"controller") as PachinkoMachineController;
  }

  protected cb func OnGameAttached() -> Bool {
    super.OnGameAttached();
    GameObject.PlayMetadataEvent(this, n"dev_pachinko_music_loop");
  }

  protected const func GetController() -> ref<ScriptableDC> {
    return this.m_controller;
  }

  public const func GetDevicePS() -> ref<ScriptableDeviceComponentPS> {
    return this.GetControllerPersistentState() as ScriptableDeviceComponentPS;
  }

  protected func TurnOffScreen() -> Void {
    this.m_uiComponent.Toggle(false);
    GameObject.PlaySound(this, this.m_currentGameAudioStop);
  }

  protected func TurnOnScreen() -> Void {
    this.m_uiComponent.Toggle(true);
    GameObject.PlaySound(this, this.m_currentGameAudio);
  }

  protected final func RefreshDeviceInteractions() -> Void {
    let playerPuppet: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerMainGameObject() as PlayerPuppet;
    this.RefreshInteraction(gamedeviceRequestType.Direct, playerPuppet);
  }

  protected cb func OnQuickHackDistraction(evt: ref<QuickHackDistraction>) -> Bool {
    super.OnQuickHackDistraction(evt);
    if evt.IsCompleted() {
      GameObjectEffectHelper.BreakEffectLoopEvent(this, this.m_distractionFXName);
      this.RefreshDeviceInteractions();
    } else {
      GameObjectEffectHelper.StartEffectEvent(this, this.m_distractionFXName);
    };
  }

  public const func DeterminGameplayRole() -> EGameplayRole {
    return EGameplayRole.Distract;
  }
}
