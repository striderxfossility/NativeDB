
public class hudCameraController extends inkHUDGameController {

  @default(hudCameraController, -360)
  private let pitch_min: Float;

  @default(hudCameraController, 360)
  private let pitch_max: Float;

  @default(hudCameraController, -640)
  private let yaw_min: Float;

  @default(hudCameraController, 640)
  private let yaw_max: Float;

  @default(hudCameraController, -360)
  private let tele_min: Float;

  @default(hudCameraController, 360)
  private let tele_max: Float;

  @default(hudCameraController, .75)
  private let tele_scale: Float;

  @default(hudCameraController, 4)
  private let max_zoom_level: Float;

  private edit let m_Date: inkTextRef;

  private edit let m_Timer: inkTextRef;

  private edit let m_CameraID: inkTextRef;

  private edit let m_timerHrs: inkTextRef;

  private edit let m_timerMin: inkTextRef;

  private edit let m_timerSec: inkTextRef;

  private edit let m_watermark: inkWidgetRef;

  private edit let m_yawCounter: inkTextRef;

  private edit let m_pitchCounter: inkTextRef;

  private edit let m_pitch: inkCanvasRef;

  private edit let m_yaw: inkCanvasRef;

  private edit let m_tele: inkCanvasRef;

  private edit let m_teleScale: inkCanvasRef;

  private let m_psmBlackboard: wref<IBlackboard>;

  private let m_tcsBlackboard: wref<IBlackboard>;

  private let m_PSM_BBID: ref<CallbackHandle>;

  private let m_tcs_BBID: ref<CallbackHandle>;

  private let m_deviceChain_BBID: ref<CallbackHandle>;

  private let m_root: wref<inkCompoundWidget>;

  private let m_currentZoom: Float;

  private let m_controlledObjectRef: wref<GameObject>;

  private let m_alpha_fadein: ref<inkAnimDef>;

  private let m_AnimProxy: ref<inkAnimProxy>;

  private let m_AnimOptions: inkAnimOptions;

  private let m_ownerObject: wref<GameObject>;

  private let m_maxZoomLevel: Int32;

  protected cb func OnInitialize() -> Bool {
    let alphaInterpolator: ref<inkAnimTransparency>;
    let delayInitialize: ref<DelayedHUDInitializeEvent>;
    this.m_root = this.GetRootWidget() as inkCompoundWidget;
    this.m_ownerObject = this.GetOwnerEntity() as GameObject;
    this.m_tcsBlackboard = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().DeviceTakeControl);
    if IsDefined(this.m_tcsBlackboard) {
      this.m_tcs_BBID = this.m_tcsBlackboard.RegisterDelayedListenerEntityID(GetAllBlackboardDefs().DeviceTakeControl.ActiveDevice, this, n"OnChangeControlledDevice");
      this.m_deviceChain_BBID = this.m_tcsBlackboard.RegisterListenerVariant(GetAllBlackboardDefs().DeviceTakeControl.DevicesChain, this, n"OnTakeControllOverDevice");
      this.OnChangeControlledDevice(this.m_tcsBlackboard.GetEntityID(GetAllBlackboardDefs().DeviceTakeControl.ActiveDevice));
      this.OnTakeControllOverDevice(this.m_tcsBlackboard.GetVariant(GetAllBlackboardDefs().DeviceTakeControl.DevicesChain));
    };
    this.UpdateTime();
    this.UpdateRulers();
    this.m_alpha_fadein = new inkAnimDef();
    alphaInterpolator = new inkAnimTransparency();
    alphaInterpolator.SetDuration(1.00);
    alphaInterpolator.SetStartTransparency(1.00);
    alphaInterpolator.SetEndTransparency(1.00);
    alphaInterpolator.SetType(inkanimInterpolationType.Linear);
    alphaInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
    this.m_alpha_fadein.AddInterpolator(alphaInterpolator);
    this.m_AnimOptions.playReversed = false;
    this.m_AnimOptions.executionDelay = 0.00;
    this.m_AnimOptions.loopType = inkanimLoopType.Cycle;
    this.m_AnimOptions.loopInfinite = true;
    this.m_AnimProxy = this.m_root.PlayAnimationWithOptions(this.m_alpha_fadein, this.m_AnimOptions);
    this.m_AnimProxy.RegisterToCallback(inkanimEventType.OnEndLoop, this, n"OnEndLoop");
    this.GetPlayerControlledObject().RegisterInputListener(this);
    this.OnZoomChange(1.00);
    delayInitialize = new DelayedHUDInitializeEvent();
    GameInstance.GetDelaySystem(this.GetPlayerControlledObject().GetGame()).DelayEvent(this.GetPlayerControlledObject(), delayInitialize, 0.10);
    GameInstance.GetAudioSystem(this.GetPlayerControlledObject().GetGame()).Play(n"global_menu_hacking_close");
    GameInstance.GetAudioSystem(this.GetPlayerControlledObject().GetGame()).Play(n"ui_hacking_close");
  }

  protected cb func OnUninitialize() -> Bool {
    this.m_tcsBlackboard.UnregisterListenerEntityID(GetAllBlackboardDefs().DeviceTakeControl.ActiveDevice, this.m_tcs_BBID);
    this.m_tcsBlackboard.UnregisterListenerVariant(GetAllBlackboardDefs().DeviceTakeControl.DevicesChain, this.m_deviceChain_BBID);
    this.m_AnimProxy.UnregisterFromCallback(inkanimEventType.OnEndLoop, this, n"OnEndLoop");
    this.m_AnimProxy.Stop();
    TakeOverControlSystem.CreateInputHint(this.GetPlayerControlledObject().GetGame(), false);
  }

  protected cb func OnAction(action: ListenerAction, consumer: ListenerActionConsumer) -> Bool {
    this.UpdateTime();
    this.UpdateRulers();
  }

  protected cb func OnEndLoop(proxy: ref<inkAnimProxy>) -> Bool {
    this.UpdateTime();
    this.UpdateRulers();
  }

  protected cb func OnTakeControllOverDevice(value: Variant) -> Bool {
    let widgets: array<SWidgetPackage> = FromVariant(value);
    if ArraySize(widgets) <= 1 {
      inkWidgetRef.SetVisible(this.m_watermark, true);
    } else {
      inkWidgetRef.SetVisible(this.m_watermark, false);
    };
  }

  private final func UpdateRulers() -> Void {
    let m_pitchMargin: Float;
    let m_yawMargin: Float;
    let pitchPt: Float;
    let yawPt: Float;
    let data: CameraRotationData = (this.m_controlledObjectRef as SensorDevice).GetRotationData();
    let euAngles: EulerAngles = (this.m_controlledObjectRef as SensorDevice).GetRotationFromSlotRotation();
    if data.m_maxPitch == 0.00 {
      data.m_maxPitch = 360.00;
    };
    pitchPt = euAngles.Pitch / AbsF(data.m_maxPitch - data.m_minPitch);
    m_pitchMargin = AbsF(this.pitch_max - this.pitch_min) * pitchPt;
    inkWidgetRef.SetMargin(this.m_pitch, 0.00, m_pitchMargin, 0.00, 0.00);
    if data.m_maxYaw == 0.00 {
      data.m_maxYaw = 360.00;
    };
    yawPt = -euAngles.Yaw / AbsF(data.m_maxYaw - data.m_minYaw);
    m_yawMargin = AbsF(this.yaw_max - this.yaw_min) * yawPt;
    inkWidgetRef.SetMargin(this.m_yaw, m_yawMargin, 0.00, 0.00, 0.00);
    inkTextRef.SetText(this.m_yawCounter, ToString(RoundF(-euAngles.Yaw)));
    inkTextRef.SetText(this.m_pitchCounter, ToString(RoundF(-euAngles.Pitch)));
  }

  private final func UpdateTime() -> Void {
    let currentTime: GameTime;
    let hours: Int32;
    let hoursStr: String;
    let minutes: Int32;
    let minutesStr: String;
    let seconds: Int32;
    let secondsStr: String;
    if !IsDefined(this.m_ownerObject) {
      this.m_ownerObject = this.GetOwnerEntity() as GameObject;
    };
    currentTime = GameInstance.GetTimeSystem(this.m_ownerObject.GetGame()).GetGameTime();
    hours = GameTime.Hours(currentTime);
    minutes = GameTime.Minutes(currentTime);
    seconds = GameTime.Seconds(currentTime);
    hoursStr = hours >= 10 ? ToString(hours) : "0" + ToString(hours);
    minutesStr = minutes >= 10 ? ToString(minutes) : "0" + ToString(minutes);
    secondsStr = seconds >= 10 ? ToString(seconds) : "0" + ToString(seconds);
    inkTextRef.SetText(this.m_timerHrs, hoursStr + ":");
    inkTextRef.SetText(this.m_timerMin, minutesStr + ":");
    inkTextRef.SetText(this.m_timerSec, secondsStr);
  }

  protected cb func OnPlayerAttach(playerPuppet: ref<GameObject>) -> Bool {
    this.m_psmBlackboard = this.GetPSMBlackboard(playerPuppet);
    if IsDefined(this.m_psmBlackboard) {
      this.m_PSM_BBID = this.m_psmBlackboard.RegisterDelayedListenerFloat(GetAllBlackboardDefs().PlayerStateMachine.ZoomLevel, this, n"OnZoomChange");
      this.m_maxZoomLevel = this.m_psmBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.MaxZoomLevel);
    };
  }

  protected cb func OnPlayerDetach(playerPuppet: ref<GameObject>) -> Bool {
    this.m_psmBlackboard.UnregisterDelayedListener(GetAllBlackboardDefs().PlayerStateMachine.ZoomLevel, this.m_PSM_BBID);
  }

  protected cb func OnZoomChange(curZoom: Float) -> Bool {
    this.m_currentZoom = curZoom;
    let maxZoomLevel: Float = this.m_maxZoomLevel == 0 ? this.max_zoom_level : Cast(this.m_maxZoomLevel);
    let zoomFactor: Float = this.m_currentZoom / maxZoomLevel;
    let zoomRange: Float = AbsF(this.tele_max - this.tele_min);
    let zoomPointPosition: Float = this.tele_max - zoomRange * zoomFactor;
    inkWidgetRef.SetMargin(this.m_tele, 0.00, zoomPointPosition, 0.00, 0.00);
    inkWidgetRef.SetScale(this.m_teleScale, new Vector2(this.tele_scale + zoomFactor, this.tele_scale + zoomFactor));
  }

  protected cb func OnChangeControlledDevice(value: EntityID) -> Bool {
    if IsDefined(this.m_ownerObject) {
      this.m_controlledObjectRef = this.m_ownerObject.GetTakeOverControlSystem().GetControlledObject();
    };
    this.ChangeCameraName();
    this.ResolveState();
  }

  protected final func ChangeCameraName() -> Void {
    inkTextRef.SetText(this.m_CameraID, this.GetEntityNameFromEntityID(this.m_controlledObjectRef));
  }

  protected final func GetEntityNameFromEntityID(obj: ref<GameObject>) -> String {
    let device: ref<Device>;
    if IsDefined(obj) {
      device = obj as Device;
      if IsDefined(device) {
        return device.GetDeviceName();
      };
    };
    return "CAM:#####";
  }

  protected cb func OnDelayedHUDInitializeEvent(evt: ref<DelayedHUDInitializeEvent>) -> Bool {
    TakeOverControlSystem.CreateInputHint(this.GetPlayerControlledObject().GetGame(), true);
  }

  private final func ResolveState() -> Void {
    let ownerObject: ref<GameObject>;
    let stateName: CName;
    if IsDefined(this.m_controlledObjectRef) {
      ownerObject = this.m_controlledObjectRef.GetOwner();
      if IsDefined(ownerObject) && (ownerObject.IsDrone() || ownerObject.IsVehicle()) {
        stateName = n"Drone";
      } else {
        if EntityID.IsDynamic(this.m_controlledObjectRef.GetEntityID()) {
          stateName = n"Drone";
        } else {
          stateName = n"Default";
        };
      };
    } else {
      stateName = n"Default";
    };
    if IsDefined(this.m_root) {
      this.m_root.SetState(stateName);
    };
  }
}
