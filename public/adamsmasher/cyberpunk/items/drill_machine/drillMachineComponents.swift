
public class DrillMachineScanManager extends ScriptableComponent {

  private let m_ppStarting: Bool;

  private let m_ppEnding: Bool;

  private let m_ppCurrentStartTime: Float;

  private let m_ppCurrentEndFrame: Int32;

  @default(DrillMachineScanManager, 1.7)
  private let m_idleToScanTime: Float;

  @default(DrillMachineScanManager, 2)
  private let m_ppOffFrameDelay: Int32;

  protected cb func OnDrillerScanEvent(evt: ref<DrillerScanEvent>) -> Bool {
    this.m_ppStarting = evt.newIsScanning;
    if !evt.newIsScanning {
      this.m_ppEnding = true;
    };
  }

  private final func OnUpdate(dt: Float) -> Void {
    if this.m_ppStarting {
      this.m_ppCurrentStartTime += dt;
      if this.m_ppCurrentStartTime > this.m_idleToScanTime {
        this.m_ppStarting = false;
        this.m_ppCurrentStartTime = 0.00;
        this.QueuePostProcessEvent(true);
      };
    };
    if this.m_ppEnding {
      this.m_ppCurrentEndFrame += 1;
      if this.m_ppCurrentEndFrame > this.m_ppOffFrameDelay {
        this.m_ppEnding = false;
        this.m_ppCurrentEndFrame = 0;
        this.QueuePostProcessEvent(false);
      };
    };
  }

  private final func QueuePostProcessEvent(isEnabled: Bool) -> Void {
    let evt: ref<DrillScanPostProcessEvent> = new DrillScanPostProcessEvent();
    evt.IsEnabled = isEnabled;
    this.GetOwner().QueueEvent(evt);
  }
}

public class RewireComponent extends ScriptableComponent {

  @default(RewireComponent, base\movies\loading_screen_temp.bk2)
  public let miniGameVideoPath: ResRef;

  public let miniGameAudioEvent: CName;

  @default(RewireComponent, 5.f)
  public let miniGameVideoLenght: Float;

  private let m_rewireEvent: ref<RewireEvent>;

  private let m_rewireCurrentLenght: Float;

  @default(RewireComponent, false)
  private let m_isActive: Bool;

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool;

  protected cb func OnRewireStart(rewireEvent: ref<RewireEvent>) -> Bool {
    this.m_rewireCurrentLenght = 0.00;
    this.m_rewireEvent = rewireEvent;
    this.m_isActive = true;
    this.RewireFinished();
    this.ToggleMovie(true);
  }

  private final func OnUpdate(dt: Float) -> Void {
    if this.m_isActive {
      this.m_rewireCurrentLenght += dt;
      if this.m_rewireCurrentLenght > this.miniGameVideoLenght {
        this.RewireFinished();
      };
    };
  }

  private final func RewireFinished() -> Void {
    this.m_isActive = false;
    this.m_rewireEvent.sucess = true;
    this.m_rewireEvent.state = EDrillMachineRewireState.RewireFinished;
    this.ToggleMovie(false);
    this.GetOwner().QueueEventForEntityID(this.m_rewireEvent.ownerID, this.m_rewireEvent);
    this.GetOwner().QueueEventForEntityID(this.m_rewireEvent.activatorID, this.m_rewireEvent);
  }

  private final func ToggleMovie(play: Bool) -> Void;
}
