
public class inkMotorcycleHUDGameController extends BaseVehicleHUDGameController {

  private let m_vehicleBlackboard: wref<IBlackboard>;

  private let m_activeVehicleUIBlackboard: wref<IBlackboard>;

  private let m_vehicleBBStateConectionId: ref<CallbackHandle>;

  private let m_speedBBConnectionId: ref<CallbackHandle>;

  private let m_gearBBConnectionId: ref<CallbackHandle>;

  private let m_tppBBConnectionId: ref<CallbackHandle>;

  private let m_rpmValueBBConnectionId: ref<CallbackHandle>;

  private let m_leanAngleBBConnectionId: ref<CallbackHandle>;

  private let m_playerStateBBConnectionId: ref<CallbackHandle>;

  private let playOptionReverse: inkAnimOptions;

  private let m_rootWidget: wref<inkCanvas>;

  private let m_mainCanvas: wref<inkCanvas>;

  private let m_activeChunks: Int32;

  private edit let m_chunksNumber: Int32;

  private edit let m_dynamicRpmPath: CName;

  private edit let m_rpmPerChunk: Int32;

  private edit let m_hasRevMax: Bool;

  private edit let m_HiResMode: Bool;

  private edit let m_revMaxPath: CName;

  private edit let m_revMaxChunk: Int32;

  private edit let m_revMax: Int32;

  private edit let m_revRedLine: Int32;

  private edit let m_maxSpeed: Int32;

  private edit let m_speedTextWidget: inkTextRef;

  private edit let m_gearTextWidget: inkTextRef;

  private edit let m_RPMTextWidget: inkTextRef;

  private let m_lower: wref<inkCanvas>;

  private let m_lowerSpeedBigR: wref<inkCanvas>;

  private let m_lowerSpeedBigL: wref<inkCanvas>;

  private let m_lowerSpeedSmallR: wref<inkCanvas>;

  private let m_lowerSpeedSmallL: wref<inkCanvas>;

  private let m_lowerSpeedFluffR: wref<inkImage>;

  private let m_lowerSpeedFluffL: wref<inkImage>;

  private let m_hudLowerPart: wref<inkCanvas>;

  private let m_lowerfluff_R: wref<inkCanvas>;

  private let m_lowerfluff_L: wref<inkCanvas>;

  private let m_HudHideAnimation: ref<inkAnimProxy>;

  private let m_HudShowAnimation: ref<inkAnimProxy>;

  private let m_HudRedLineAnimation: ref<inkAnimProxy>;

  private let m_fluffBlinking: ref<inkAnimController>;

  protected cb func OnInitialize() -> Bool {
    this.m_rootWidget = this.GetRootWidget() as inkCanvas;
    this.playOptionReverse.playReversed = true;
    if !this.m_HiResMode {
      this.m_rootWidget.SetScale(new Vector2(0.50, 0.50));
    };
    this.m_rootWidget.SetVisible(false);
    this.m_lower = this.GetWidget(n"HudMain/Lower") as inkCanvas;
    this.m_lowerSpeedBigR = this.GetWidget(n"HudMain/Lower/bigR") as inkCanvas;
    this.m_lowerSpeedBigL = this.GetWidget(n"HudMain/Lower/bigL") as inkCanvas;
    this.m_lowerSpeedSmallR = this.GetWidget(n"HudMain/Lower/bigR/smallWingR") as inkCanvas;
    this.m_lowerSpeedSmallL = this.GetWidget(n"HudMain/Lower/bigL/smallWingL") as inkCanvas;
    this.m_lowerSpeedFluffR = this.GetWidget(n"HudMain/Lower/bigR/R_lowerFluff") as inkImage;
    this.m_lowerSpeedFluffL = this.GetWidget(n"HudMain/Lower/bigL/L_lowerFluff") as inkImage;
    this.m_lowerfluff_L = this.GetWidget(n"HudMain/Lower/bigL/smallWingL/fluffIcons") as inkCanvas;
    this.m_lowerfluff_R = this.GetWidget(n"HudMain/Lower/bigR/smallWingR/R_fluffIcons") as inkCanvas;
    this.m_hudLowerPart = this.GetWidget(n"HudMain/Lower") as inkCanvas;
  }

  protected cb func OnUninitialize() -> Bool;

  protected cb func OnVehicleMounted() -> Bool {
    let bbSys: ref<BlackboardSystem>;
    let playerPuppet: wref<GameObject>;
    let shouldConnect: Bool;
    let vehicle: wref<VehicleObject>;
    this.m_fluffBlinking = new inkAnimController();
    this.m_fluffBlinking.Select(this.m_lowerfluff_L).Select(this.m_lowerfluff_R).Interpolate(n"transparency", ToVariant(0.25), ToVariant(1.00)).Duration(0.50).Interpolate(n"transparency", ToVariant(1.00), ToVariant(0.25)).Delay(0.55).Duration(0.50).Type(inkanimInterpolationType.Linear).Mode(inkanimInterpolationMode.EasyIn);
    playerPuppet = this.GetOwnerEntity() as PlayerPuppet;
    vehicle = GetMountedVehicle(playerPuppet);
    bbSys = GameInstance.GetBlackboardSystem(playerPuppet.GetGame());
    if shouldConnect {
      this.m_vehicleBlackboard = vehicle.GetBlackboard();
      this.m_activeVehicleUIBlackboard = bbSys.Get(GetAllBlackboardDefs().UI_ActiveVehicleData);
    };
    if IsDefined(this.m_vehicleBlackboard) {
      this.m_vehicleBBStateConectionId = this.m_vehicleBlackboard.RegisterListenerInt(GetAllBlackboardDefs().Vehicle.VehicleState, this, n"OnVehicleStateChanged");
      this.m_speedBBConnectionId = this.m_vehicleBlackboard.RegisterListenerFloat(GetAllBlackboardDefs().Vehicle.SpeedValue, this, n"OnSpeedValueChanged");
      this.m_gearBBConnectionId = this.m_vehicleBlackboard.RegisterListenerInt(GetAllBlackboardDefs().Vehicle.GearValue, this, n"OnGearValueChanged");
      this.m_rpmValueBBConnectionId = this.m_vehicleBlackboard.RegisterListenerFloat(GetAllBlackboardDefs().Vehicle.RPMValue, this, n"OnRpmValueChanged");
      this.m_leanAngleBBConnectionId = this.m_vehicleBlackboard.RegisterListenerFloat(GetAllBlackboardDefs().Vehicle.BikeTilt, this, n"OnLeanAngleChanged");
      this.m_tppBBConnectionId = this.m_activeVehicleUIBlackboard.RegisterListenerBool(GetAllBlackboardDefs().UI_ActiveVehicleData.IsTPPCameraOn, this, n"OnCameraModeChanged");
      this.m_playerStateBBConnectionId = this.m_activeVehicleUIBlackboard.RegisterListenerVariant(GetAllBlackboardDefs().UI_ActiveVehicleData.VehPlayerStateData, this, n"OnPlayerStateChanged");
    };
  }

  protected cb func OnVehicleUnmounted() -> Bool {
    if IsDefined(this.m_vehicleBlackboard) {
      this.m_vehicleBlackboard.UnregisterListenerInt(GetAllBlackboardDefs().Vehicle.VehicleState, this.m_vehicleBBStateConectionId);
      this.m_vehicleBlackboard.UnregisterListenerFloat(GetAllBlackboardDefs().Vehicle.SpeedValue, this.m_speedBBConnectionId);
      this.m_vehicleBlackboard.UnregisterListenerInt(GetAllBlackboardDefs().Vehicle.GearValue, this.m_gearBBConnectionId);
      this.m_vehicleBlackboard.UnregisterListenerFloat(GetAllBlackboardDefs().Vehicle.RPMValue, this.m_rpmValueBBConnectionId);
      this.m_vehicleBlackboard.UnregisterListenerFloat(GetAllBlackboardDefs().Vehicle.BikeTilt, this.m_leanAngleBBConnectionId);
      this.m_activeVehicleUIBlackboard.UnregisterListenerBool(GetAllBlackboardDefs().UI_ActiveVehicleData.IsTPPCameraOn, this.m_tppBBConnectionId);
      this.m_activeVehicleUIBlackboard.UnregisterListenerVariant(GetAllBlackboardDefs().UI_ActiveVehicleData.VehPlayerStateData, this.m_playerStateBBConnectionId);
    };
  }

  protected cb func OnHudHideAnimFinished(proxy: ref<inkAnimProxy>) -> Bool {
    this.m_rootWidget.SetVisible(false);
    this.m_HudHideAnimation.UnregisterFromCallback(inkanimEventType.OnFinish, this, n"OnHudHideAnimFinished");
  }

  protected cb func OnHudShowAnimFinished(proxy: ref<inkAnimProxy>) -> Bool {
    let LoopOptions: inkAnimOptions;
    LoopOptions.loopType = inkanimLoopType.Cycle;
    LoopOptions.loopInfinite = true;
    this.m_fluffBlinking.PlayWithOptions(LoopOptions);
    this.m_HudShowAnimation.UnregisterFromCallback(inkanimEventType.OnFinish, this, n"OnHudShowAnimFinished");
  }

  protected cb func OnVehicleStateChanged(state: Int32) -> Bool {
    if state == EnumInt(vehicleEState.On) {
    };
    if state != EnumInt(vehicleEState.On) {
    };
  }

  protected cb func OnPlayerStateChanged(data: Variant) -> Bool {
    let newData: VehEntityPlayerStateData = FromVariant(data);
    let playerState: Int32 = newData.state;
    if playerState == 4 {
      this.m_fluffBlinking.Stop();
      this.m_HudHideAnimation = this.PlayLibraryAnimation(n"show", this.playOptionReverse);
      this.m_HudHideAnimation.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnHudHideAnimFinished");
    };
  }

  protected cb func OnRpmMaxChanged(rpmMax: Float) -> Bool {
    let rpm: Int32 = Cast(rpmMax);
    let level: Float = Cast(rpm / this.m_rpmPerChunk);
    let levelInt: Int32 = Cast(level);
    this.EvaluateRPMMeterWidget(levelInt);
  }

  protected cb func OnSpeedValueChanged(speedValue: Float) -> Bool {
    let animRatio: Float = 0.70;
    let calcSpeedFloat: Float = speedValue * 2.24;
    let calcSpeed: Int32 = RoundMath(calcSpeedFloat);
    if speedValue < 0.00 {
      inkTextRef.SetText(this.m_speedTextWidget, "Common-Digits-Zero");
    } else {
      inkTextRef.SetText(this.m_speedTextWidget, IntToString(calcSpeed));
    };
    this.m_lowerSpeedBigL.SetTranslation(new Vector2(calcSpeedFloat * animRatio * -1.00, 0.00));
    this.m_lowerSpeedBigR.SetTranslation(new Vector2(calcSpeedFloat * animRatio, 0.00));
    this.m_lowerSpeedSmallL.SetTranslation(new Vector2(calcSpeedFloat * animRatio * -1.00, 0.00));
    this.m_lowerSpeedSmallR.SetTranslation(new Vector2(calcSpeedFloat * animRatio, 0.00));
    this.m_lowerSpeedFluffL.SetTranslation(new Vector2(calcSpeedFloat * animRatio * -1.20, 0.00));
    this.m_lowerSpeedFluffR.SetTranslation(new Vector2(calcSpeedFloat * animRatio * 1.20, 0.00));
    this.m_hudLowerPart.SetTranslation(new Vector2(0.00, calcSpeedFloat * animRatio * -1.00));
  }

  protected cb func OnGearValueChanged(gearValue: Int32) -> Bool {
    if gearValue == 0 {
      inkTextRef.SetText(this.m_gearTextWidget, "UI-Cyberpunk-Vehicles-Gears-Neutral");
    } else {
      inkTextRef.SetText(this.m_gearTextWidget, IntToString(gearValue));
    };
  }

  protected cb func OnRpmValueChanged(rpmValue: Float) -> Bool {
    inkTextRef.SetText(this.m_RPMTextWidget, IntToString(RoundMath(rpmValue)));
    if rpmValue > 7800.00 {
      this.m_HudRedLineAnimation = this.PlayLibraryAnimation(n"redLine");
    };
    this.drawRPMGaugeFull(rpmValue);
  }

  public final func drawRPMGaugeFull(rpmValue: Float) -> Void {
    let rpm: Int32 = Cast(rpmValue);
    let level: Float = Cast(rpm / this.m_rpmPerChunk);
    let levelInt: Int32 = Cast(level);
    this.EvaluateRPMMeterWidget(levelInt);
  }

  private final func EvaluateRPMMeterWidget(currentAmountOfChunks: Int32) -> Void {
    if currentAmountOfChunks == this.m_activeChunks {
      return;
    };
    this.RedrawRPM(currentAmountOfChunks);
  }

  private final func RedrawRPM(currentAmountOfChunks: Int32) -> Void {
    let chunkToModify: String;
    let i: Int32;
    let widgetToModify: wref<inkRectangle>;
    let difference: Int32 = Abs(currentAmountOfChunks - this.m_activeChunks);
    let increasing: Bool = currentAmountOfChunks > this.m_activeChunks;
    if increasing {
      i = this.m_activeChunks;
      while i <= this.m_activeChunks + difference {
        chunkToModify = NameToString(this.m_dynamicRpmPath) + IntToString(i);
        widgetToModify = this.GetWidget(StringToName(chunkToModify)) as inkRectangle;
        widgetToModify.SetVisible(true);
        widgetToModify.SetOpacity(1.00);
        i += 1;
      };
    } else {
      i = this.m_activeChunks;
      while i >= this.m_activeChunks - difference {
        chunkToModify = NameToString(this.m_dynamicRpmPath) + IntToString(i);
        widgetToModify = this.GetWidget(StringToName(chunkToModify)) as inkRectangle;
        widgetToModify.SetVisible(false);
        i -= 1;
      };
    };
    this.m_activeChunks = currentAmountOfChunks;
  }

  private final func AddChunk() -> Void {
    let chunkToActivate: String;
    let i: Int32;
    let widgetToShow: wref<inkRectangle>;
    if IsNameValid(this.m_dynamicRpmPath) {
      i = 1;
      while i <= this.m_activeChunks {
        chunkToActivate = NameToString(this.m_dynamicRpmPath) + IntToString(i);
        widgetToShow = this.GetWidget(StringToName(chunkToActivate)) as inkRectangle;
        widgetToShow.SetVisible(true);
        widgetToShow.SetOpacity(1.00);
        i += 1;
      };
    };
  }

  private final func RemoveChunk() -> Void {
    let chunkToRemove: String;
    let i: Int32;
    let widgetToHide: wref<inkRectangle>;
    if IsNameValid(this.m_dynamicRpmPath) {
      i = this.m_chunksNumber;
      while i > this.m_activeChunks {
        chunkToRemove = NameToString(this.m_dynamicRpmPath) + IntToString(i);
        widgetToHide = this.GetWidget(StringToName(chunkToRemove)) as inkRectangle;
        widgetToHide.SetVisible(false);
        i -= 1;
      };
    };
  }

  protected cb func OnLeanAngleChanged(leanAngle: Float) -> Bool;

  protected cb func OnCameraModeChanged(mode: Bool) -> Bool {
    if Equals(mode, true) {
      this.m_rootWidget.SetVisible(true);
      this.m_HudShowAnimation = this.PlayLibraryAnimation(n"show");
      this.m_HudShowAnimation.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnHudShowAnimFinished");
    } else {
      if Equals(mode, false) {
        this.m_fluffBlinking.Stop();
        this.m_HudHideAnimation = this.PlayLibraryAnimation(n"show", this.playOptionReverse);
        this.m_HudHideAnimation.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnHudHideAnimFinished");
      };
    };
  }

  protected final func CheckVehicleType(desiredType: String) -> Bool {
    let playerPuppet: wref<GameObject> = this.GetOwnerEntity() as PlayerPuppet;
    let vehicle: wref<VehicleObject> = GetMountedVehicle(playerPuppet);
    let record: wref<Vehicle_Record> = vehicle.GetRecord();
    let typeRecord: wref<VehicleType_Record> = record.Type();
    let type: String = typeRecord.EnumName();
    if Equals(type, desiredType) {
      return true;
    };
    return false;
  }
}
