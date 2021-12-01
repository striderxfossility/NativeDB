
public class ScannerControlComponent extends ScriptableComponent {

  private let m_currentScanType: MechanicalScanType;

  private let m_currentScanEffect: ref<EffectInstance>;

  private let m_currentScanAnimation: CName;

  private edit let m_scannerTriggerComponentName: CName;

  private let m_scannerTriggerComponent: ref<IComponent>;

  private let m_a: ref<TriggerComponent>;

  private let m_isScanningPlayer: Bool;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    EntityRequestComponentsInterface.RequestComponent(ri, this.m_scannerTriggerComponentName, n"entTriggerComponent", false);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    this.m_scannerTriggerComponent = EntityResolveComponentsInterface.GetComponent(ri, this.m_scannerTriggerComponentName);
    this.m_a = EntityResolveComponentsInterface.GetComponent(ri, this.m_scannerTriggerComponentName) as TriggerComponent;
  }

  protected final func OnGameAttach() -> Void {
    this.m_currentScanType = IntEnum(0l);
    if IsDefined(this.m_scannerTriggerComponent) {
      this.m_scannerTriggerComponent.Toggle(false);
    };
  }

  protected cb func OnAIEvent(aiEvent: ref<AIEvent>) -> Bool {
    switch aiEvent.name {
      case n"ScanShort":
        this.StartScanning(MechanicalScanType.Short);
        break;
      case n"ScanLong":
        this.StartScanning(MechanicalScanType.Long);
        break;
      case n"ScanDanger":
        this.StartScanning(MechanicalScanType.Danger);
        break;
      case n"StopScanning":
        this.StopScanning();
        break;
      default:
    };
  }

  protected cb func OnDeath(evt: ref<gameDeathEvent>) -> Bool {
    this.StopScanning();
  }

  protected cb func OnAreaEnter(trigger: ref<AreaEnteredEvent>) -> Bool {
    let player: ref<ScriptedPuppet> = GameInstance.GetPlayerSystem(this.GetOwner().GetGame()).GetLocalPlayerControlledGameObject() as ScriptedPuppet;
    if !this.m_isScanningPlayer && EntityGameInterface.GetEntity(trigger.activator).GetEntityID() == player.GetEntityID() {
      this.StartFullscreenPlayerVFX();
    };
  }

  protected cb func OnAreaExit(trigger: ref<AreaExitedEvent>) -> Bool {
    let player: ref<ScriptedPuppet> = GameInstance.GetPlayerSystem(this.GetOwner().GetGame()).GetLocalPlayerControlledGameObject() as ScriptedPuppet;
    if this.m_isScanningPlayer && EntityGameInterface.GetEntity(trigger.activator).GetEntityID() == player.GetEntityID() {
      this.StopFullscreenPlayerVFX();
    };
  }

  protected final func StartFullscreenPlayerVFX() -> Void {
    let player: ref<GameObject>;
    if Equals(this.m_currentScanType, IntEnum(0l)) || Equals(this.m_currentScanType, MechanicalScanType.Short) {
      return;
    };
    player = GameInstance.GetPlayerSystem(this.GetOwner().GetGame()).GetLocalPlayerControlledGameObject();
    if Equals(this.m_currentScanType, MechanicalScanType.Long) {
      GameObjectEffectHelper.StartEffectEvent(player, n"screen_scanning_loop", true);
    } else {
      if Equals(this.m_currentScanType, MechanicalScanType.Danger) {
        GameObjectEffectHelper.StartEffectEvent(player, n"screen_scanning_red_loop", true);
      };
    };
    this.m_isScanningPlayer = true;
  }

  protected final func StopFullscreenPlayerVFX() -> Void {
    let player: ref<GameObject>;
    if !this.m_isScanningPlayer {
      return;
    };
    player = GameInstance.GetPlayerSystem(this.GetOwner().GetGame()).GetLocalPlayerControlledGameObject();
    GameObjectEffectHelper.BreakEffectLoopEvent(player, n"screen_scanning_loop");
    GameObjectEffectHelper.BreakEffectLoopEvent(player, n"screen_scanning_red_loop");
    this.m_isScanningPlayer = false;
  }

  private final func StartScanning(scanType: MechanicalScanType) -> Void {
    if Equals(this.m_currentScanType, IntEnum(0l)) {
      this.PlayScannerSlotAnimation(n"scan_default");
    };
    this.StopCurrentScanningEffect();
    switch scanType {
      case MechanicalScanType.Short:
        GameObject.StartReplicatedEffectEvent(this.GetOwner(), n"scan_short");
        break;
      case MechanicalScanType.Long:
        GameObject.StartReplicatedEffectEvent(this.GetOwner(), n"scan");
        break;
      case MechanicalScanType.Danger:
        GameObject.StartReplicatedEffectEvent(this.GetOwner(), n"scan_red");
        break;
      default:
    };
    this.m_currentScanType = scanType;
    if IsDefined(this.m_scannerTriggerComponent) && (Equals(this.m_currentScanType, MechanicalScanType.Long) || Equals(this.m_currentScanType, MechanicalScanType.Danger)) {
      if this.m_isScanningPlayer {
        this.StopFullscreenPlayerVFX();
        this.StartFullscreenPlayerVFX();
      };
      this.m_scannerTriggerComponent.Toggle(true);
    };
  }

  private final func StopCurrentScanningEffect() -> Void {
    switch this.m_currentScanType {
      case MechanicalScanType.Short:
        GameObject.BreakReplicatedEffectLoopEvent(this.GetOwner(), n"scan_short");
        break;
      case MechanicalScanType.Long:
        GameObject.BreakReplicatedEffectLoopEvent(this.GetOwner(), n"scan");
        break;
      case MechanicalScanType.Danger:
        GameObject.BreakReplicatedEffectLoopEvent(this.GetOwner(), n"scan_red");
        break;
      default:
    };
  }

  private final func StopScanning() -> Void {
    this.StopCurrentScanningEffect();
    this.StopScannerSlotAnimation();
    if IsDefined(this.m_scannerTriggerComponent) {
      this.m_scannerTriggerComponent.Toggle(false);
      this.StopFullscreenPlayerVFX();
    };
    this.m_currentScanType = IntEnum(0l);
  }

  protected final func PlayScannerSlotAnimation(animationName: CName) -> Void {
    let transformAnimationPlayEvent: ref<gameTransformAnimationPlayEvent> = new gameTransformAnimationPlayEvent();
    transformAnimationPlayEvent.animationName = animationName;
    transformAnimationPlayEvent.looping = true;
    transformAnimationPlayEvent.timeScale = 1.00;
    this.GetOwner().QueueEvent(transformAnimationPlayEvent);
  }

  protected final func StopScannerSlotAnimation() -> Void {
    let transformAnimationResetEvent: ref<gameTransformAnimationResetEvent> = new gameTransformAnimationResetEvent();
    transformAnimationResetEvent.animationName = this.m_currentScanAnimation;
    this.GetOwner().QueueEvent(transformAnimationResetEvent);
  }
}
