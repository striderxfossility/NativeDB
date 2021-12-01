
public class drillMachine extends WeaponObject {

  private let m_rewireComponent: ref<RewireComponent>;

  private let m_player: wref<GameObject>;

  private let m_scanManager: ref<DrillMachineScanManager>;

  private let m_screen_postprocess: ref<IVisualComponent>;

  private let m_screen_backside: ref<IVisualComponent>;

  private let m_isScanning: Bool;

  private let m_isActive: Bool;

  private let m_targetDevice: wref<GameObject>;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    EntityRequestComponentsInterface.RequestComponent(ri, n"ui", n"worlduiWidgetComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"rewire", n"RewireComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"screen_postprocess", n"entMeshComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"screen_backside", n"entSkinnedMeshComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"scan_manager", n"DrillMachineScanManager", false);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    this.m_rewireComponent = EntityResolveComponentsInterface.GetComponent(ri, n"rewire") as RewireComponent;
    this.m_screen_postprocess = EntityResolveComponentsInterface.GetComponent(ri, n"screen_postprocess") as IVisualComponent;
    this.m_screen_backside = EntityResolveComponentsInterface.GetComponent(ri, n"screen_backside") as IVisualComponent;
    this.m_scanManager = EntityResolveComponentsInterface.GetComponent(ri, n"scan_manager") as DrillMachineScanManager;
  }

  protected cb func OnGameAttached() -> Bool {
    this.m_player = GetPlayer(this.GetGame());
    this.TogglePostprocess(false);
  }

  protected cb func OnRewireEvent(evt: ref<RewireEvent>) -> Bool {
    switch evt.state {
      case EDrillMachineRewireState.InsideInteractionRange:
        this.m_isActive = true;
        break;
      case EDrillMachineRewireState.OutsideInteractionRange:
        this.m_isActive = false;
    };
  }

  protected cb func OnScanEvent(evt: ref<DrillScanEvent>) -> Bool {
    let drillerScanEvent: ref<DrillerScanEvent> = new DrillerScanEvent();
    drillerScanEvent.newIsScanning = evt.IsScanning;
    this.QueueEvent(drillerScanEvent);
  }

  protected cb func OnPostProcessEvent(evt: ref<DrillScanPostProcessEvent>) -> Bool {
    this.TogglePostprocess(evt.IsEnabled);
    this.ToggleScreenBack(!evt.IsEnabled);
  }

  private final func ToggleScreenBack(isEnable: Bool) -> Void {
    this.m_screen_backside.Toggle(isEnable);
  }

  private final func TogglePostprocess(isEnable: Bool) -> Void {
    this.m_screen_postprocess.Toggle(isEnable);
  }

  private final func ToggleMinigameAnimation(isEnable: Bool) -> Void {
    let animEvt: ref<AnimInputSetterFloat> = new AnimInputSetterFloat();
    animEvt.key = n"rewiring_state";
    animEvt.value = 0.00;
    if isEnable {
      animEvt.value = 1.00;
    };
    this.QueueEvent(animEvt);
  }

  private final func ToggleFingerAnimation(isEnable: Bool) -> Void {
    let animEvt: ref<AnimInputSetterInt> = new AnimInputSetterInt();
    animEvt.key = n"driller_stick_pressed";
    animEvt.value = 0;
    if isEnable {
      animEvt.value = 1;
    };
    GetPlayer(this.GetGame()).QueueEvent(animEvt);
    this.QueueEvent(animEvt);
  }

  protected cb func OnDrillerInputAction(actionChosen: InteractionChoice) -> Bool;

  protected cb func OnDrillMachineEvent(evt: ref<drillMachineEvent>) -> Bool {
    if evt.newTargetDevice != null {
      this.m_targetDevice = evt.newTargetDevice;
    };
    if NotEquals(evt.newIsActive, this.m_isActive) {
      this.m_isActive = evt.newIsActive;
    };
  }

  public const func IsActive() -> Bool {
    return this.m_isActive;
  }
}
