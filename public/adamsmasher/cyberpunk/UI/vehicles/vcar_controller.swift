
public class vehicleVcarRootLogicController extends inkLogicController {

  protected cb func OnInitialize() -> Bool;

  protected cb func OnMounted() -> Bool;
}

public class vehicleVcarGameController extends inkGameController {

  private let activeVehicleBlackboard: wref<IBlackboard>;

  private let m_vehicleBlackboard: wref<IBlackboard>;

  private let m_mountBBConnectionId: ref<CallbackHandle>;

  private let m_speedBBConnectionId: ref<CallbackHandle>;

  private let m_rpmValueBBConnectionId: ref<CallbackHandle>;

  private let m_rpmMaxBBConnectionId: ref<CallbackHandle>;

  private let m_autopilotOnId: ref<CallbackHandle>;

  private let m_playerVehStateId: ref<CallbackHandle>;

  private let m_isInAutoPilot: Bool;

  private let m_isInCombat: Bool;

  private let m_wasCombat: Bool;

  private let m_rootWidget: wref<inkCanvas>;

  private let m_windowWidget: wref<inkCanvas>;

  private let m_speedTextWidget: wref<inkText>;

  private let m_rpmGaugeFullWidget: wref<inkImage>;

  private let m_rpmGaugeMaxSize: Vector2;

  private let m_interiorRootWidget: wref<inkCanvas>;

  private let m_interiorRPMWidget: wref<inkCanvas>;

  private let m_interiorFluff1Widget: wref<inkCanvas>;

  private let m_interiorFluff2Widget: wref<inkCanvas>;

  private let m_interiorFluff3Widget: wref<inkCanvas>;

  private let m_interiorFluff4Widget: wref<inkCanvas>;

  private let m_interiorFluff5Widget: wref<inkCanvas>;

  private let m_interiorFluff1Anim1Widget: wref<inkCanvas>;

  private let m_interiorFluff1Anim2Widget: wref<inkCanvas>;

  private let m_interiorFluff2Anim1Widget: wref<inkCanvas>;

  private let m_interiorFluff2Anim2Widget: wref<inkCanvas>;

  private let m_activeChunks: Int32;

  private let m_animFadeOutProxy: ref<inkAnimProxy>;

  private let m_anim_exterior_fadein: ref<inkAnimDef>;

  private let m_anim_exterior_fadeout: ref<inkAnimDef>;

  private let m_anim_interior_fadeout: ref<inkAnimDef>;

  private let m_anim_interior_rpm_fadein: ref<inkAnimDef>;

  private let m_anim_interior_fluff1_fadein: ref<inkAnimDef>;

  private let m_anim_interior_fluff2_fadein: ref<inkAnimDef>;

  private let m_anim_interior_fluff3_fadein: ref<inkAnimDef>;

  private let m_anim_interior_fluff4_fadein: ref<inkAnimDef>;

  private let m_anim_interior_fluff5_fadein: ref<inkAnimDef>;

  private let m_animFluffFadeInProxy: ref<inkAnimProxy>;

  private let m_anim_interior_fluff1_anim1: ref<inkAnimDef>;

  private let m_anim_interior_fluff1_anim2: ref<inkAnimDef>;

  private let m_anim_interior_fluff2_anim1: ref<inkAnimDef>;

  private let m_anim_interior_fluff2_anim2: ref<inkAnimDef>;

  private let m_fluff1animOptions1: inkAnimOptions;

  private let m_fluff1animOptions2: inkAnimOptions;

  private let m_fluff2animOptions1: inkAnimOptions;

  private let m_fluff2animOptions2: inkAnimOptions;

  private edit let m_isWindow: Bool;

  private edit let m_isInterior: Bool;

  private edit let m_hasSpeed: Bool;

  private edit let m_hasRPM: Bool;

  private edit let m_chunksNumber: Int32;

  private edit let m_dynamicRpmPath: CName;

  private edit let m_rpmPerChunk: Int32;

  private edit let m_hasRevMax: Bool;

  private edit let m_revMaxPath: CName;

  private edit let m_revMaxChunk: Int32;

  private edit let m_windowWidgetPath: CName;

  private edit let m_interiorWidgetPath: CName;

  private edit let m_interiorRPMWidgetPath: CName;

  private edit let m_interiorFluff1WidgetPath: CName;

  private edit let m_interiorFluff2WidgetPath: CName;

  private edit let m_interiorFluff3WidgetPath: CName;

  private edit let m_interiorFluff4WidgetPath: CName;

  private edit let m_interiorFluff5WidgetPath: CName;

  private edit let m_interiorFluff1Anim1WidgetPath: CName;

  private edit let m_interiorFluff1Anim2WidgetPath: CName;

  private edit let m_interiorFluff2Anim1WidgetPath: CName;

  private edit let m_interiorFluff2Anim2WidgetPath: CName;

  protected cb func OnInitialize() -> Bool {
    let ownerObject: ref<GameObject> = this.GetOwnerEntity() as GameObject;
    let vehicle: ref<VehicleObject> = GetMountedVehicle(ownerObject);
    this.m_vehicleBlackboard = vehicle.GetBlackboard();
    this.m_rootWidget = this.GetRootWidget() as inkCanvas;
    if IsNameValid(this.m_interiorWidgetPath) {
      this.m_interiorRootWidget = this.GetWidget(this.m_interiorWidgetPath) as inkCanvas;
    };
    if this.m_isWindow && IsNameValid(this.m_windowWidgetPath) {
      this.m_windowWidget = this.GetWidget(this.m_windowWidgetPath) as inkCanvas;
    };
    if this.m_hasSpeed {
      this.m_speedTextWidget = this.GetWidget(n"maindashcontainer/dynamic/speed_text") as inkText;
    };
    if this.m_isInterior {
      if this.m_hasRPM && IsNameValid(this.m_interiorRPMWidgetPath) {
        this.m_interiorRPMWidget = this.GetWidget(this.m_interiorRPMWidgetPath) as inkCanvas;
      };
      if IsNameValid(this.m_interiorFluff1WidgetPath) {
        this.m_interiorFluff1Widget = this.GetWidget(this.m_interiorFluff1WidgetPath) as inkCanvas;
      };
      if IsNameValid(this.m_interiorFluff2WidgetPath) {
        this.m_interiorFluff2Widget = this.GetWidget(this.m_interiorFluff2WidgetPath) as inkCanvas;
      };
      if IsNameValid(this.m_interiorFluff3WidgetPath) {
        this.m_interiorFluff3Widget = this.GetWidget(this.m_interiorFluff3WidgetPath) as inkCanvas;
      };
      if IsNameValid(this.m_interiorFluff4WidgetPath) {
        this.m_interiorFluff4Widget = this.GetWidget(this.m_interiorFluff4WidgetPath) as inkCanvas;
      };
      if IsNameValid(this.m_interiorFluff5WidgetPath) {
        this.m_interiorFluff5Widget = this.GetWidget(this.m_interiorFluff5WidgetPath) as inkCanvas;
      };
      if IsNameValid(this.m_interiorFluff1Anim1WidgetPath) {
        this.m_interiorFluff1Anim1Widget = this.GetWidget(this.m_interiorFluff1Anim1WidgetPath) as inkCanvas;
      };
      if IsNameValid(this.m_interiorFluff1Anim2WidgetPath) {
        this.m_interiorFluff1Anim2Widget = this.GetWidget(this.m_interiorFluff1Anim2WidgetPath) as inkCanvas;
      };
      if IsNameValid(this.m_interiorFluff2Anim1WidgetPath) {
        this.m_interiorFluff2Anim1Widget = this.GetWidget(this.m_interiorFluff2Anim1WidgetPath) as inkCanvas;
      };
      if IsNameValid(this.m_interiorFluff2Anim2WidgetPath) {
        this.m_interiorFluff2Anim2Widget = this.GetWidget(this.m_interiorFluff2Anim2WidgetPath) as inkCanvas;
      };
    };
    this.activeVehicleBlackboard = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UI_ActiveVehicleData);
    if IsDefined(this.activeVehicleBlackboard) {
      this.m_playerVehStateId = this.activeVehicleBlackboard.RegisterListenerVariant(GetAllBlackboardDefs().UI_ActiveVehicleData.VehPlayerStateData, this, n"OnPlayerStateChanged");
      this.m_mountBBConnectionId = this.activeVehicleBlackboard.RegisterListenerBool(GetAllBlackboardDefs().UI_ActiveVehicleData.IsPlayerMounted, this, n"OnActiveVehicleChanged");
      if IsDefined(this.m_vehicleBlackboard) {
        if this.m_hasSpeed {
          this.m_speedBBConnectionId = this.m_vehicleBlackboard.RegisterListenerFloat(GetAllBlackboardDefs().Vehicle.SpeedValue, this, n"OnSpeedValueChanegd");
        };
        if this.m_hasRPM {
          this.m_rpmValueBBConnectionId = this.m_vehicleBlackboard.RegisterListenerFloat(GetAllBlackboardDefs().Vehicle.RPMValue, this, n"OnRpmValueChanged");
          this.m_rpmMaxBBConnectionId = this.m_vehicleBlackboard.RegisterListenerFloat(GetAllBlackboardDefs().Vehicle.RPMMax, this, n"OnRpmMaxChanged");
        };
        this.m_autopilotOnId = this.m_vehicleBlackboard.RegisterListenerBool(GetAllBlackboardDefs().Vehicle.IsAutopilotOn, this, n"OnAutopilotChanged");
      };
    };
    this.PrepAnim();
    this.m_windowWidget.SetOpacity(0.00);
    this.m_windowWidget.SetVisible(false);
    this.m_interiorRPMWidget.SetOpacity(0.00);
    this.m_interiorRPMWidget.SetVisible(false);
    this.m_interiorFluff1Widget.SetOpacity(0.00);
    this.m_interiorFluff1Widget.SetVisible(false);
    this.m_interiorFluff2Widget.SetOpacity(0.00);
    this.m_interiorFluff2Widget.SetVisible(false);
    this.m_interiorFluff3Widget.SetOpacity(0.00);
    this.m_interiorFluff3Widget.SetVisible(false);
    this.m_interiorFluff4Widget.SetOpacity(0.00);
    this.m_interiorFluff4Widget.SetVisible(false);
    this.m_interiorFluff5Widget.SetOpacity(0.00);
    this.m_interiorFluff5Widget.SetVisible(false);
    this.m_interiorFluff1Anim1Widget.SetOpacity(0.00);
    this.m_interiorFluff1Anim1Widget.SetVisible(false);
    this.m_interiorFluff1Anim2Widget.SetOpacity(0.00);
    this.m_interiorFluff1Anim2Widget.SetVisible(false);
    this.m_interiorFluff2Anim1Widget.SetOpacity(0.00);
    this.m_interiorFluff2Anim1Widget.SetVisible(false);
    this.m_interiorFluff2Anim2Widget.SetOpacity(0.00);
    this.m_interiorFluff2Anim2Widget.SetVisible(false);
    this.RegisterDebugCommand(n"OnActivateTest");
  }

  protected cb func OnActivateTest(value: Bool) -> Bool {
    if IsDefined(this.activeVehicleBlackboard) {
      this.activeVehicleBlackboard.SetBool(GetAllBlackboardDefs().UI_ActiveVehicleData.IsPlayerMounted, value);
    };
  }

  protected cb func OnUninitialize() -> Bool {
    if IsDefined(this.activeVehicleBlackboard) {
      this.activeVehicleBlackboard.UnregisterListenerVariant(GetAllBlackboardDefs().UI_ActiveVehicleData.VehPlayerStateData, this.m_playerVehStateId);
      this.activeVehicleBlackboard.UnregisterListenerBool(GetAllBlackboardDefs().UI_ActiveVehicleData.IsPlayerMounted, this.m_mountBBConnectionId);
      if IsDefined(this.m_vehicleBlackboard) {
        this.m_vehicleBlackboard.UnregisterListenerFloat(GetAllBlackboardDefs().Vehicle.SpeedValue, this.m_speedBBConnectionId);
        this.m_vehicleBlackboard.UnregisterListenerFloat(GetAllBlackboardDefs().Vehicle.RPMValue, this.m_rpmValueBBConnectionId);
        this.m_vehicleBlackboard.UnregisterListenerFloat(GetAllBlackboardDefs().Vehicle.RPMMax, this.m_rpmMaxBBConnectionId);
        this.m_vehicleBlackboard.UnregisterListenerBool(GetAllBlackboardDefs().Vehicle.IsAutopilotOn, this.m_autopilotOnId);
      };
    };
  }

  protected cb func OnActiveVehicleChanged(isPlayerMounted: Bool) -> Bool;

  protected cb func OnSpeedValueChanegd(speedValue: Float) -> Bool {
    if this.m_hasSpeed {
      if speedValue < 0.00 {
        this.m_speedTextWidget.SetText(IntToString(RoundMath((speedValue * 3.60) / 1.61) * -1));
      } else {
        this.m_speedTextWidget.SetText(IntToString(RoundMath((speedValue * 3.60) / 1.41)));
      };
    };
  }

  protected cb func OnRpmValueChanged(rpmValue: Float) -> Bool {
    this.drawRPMGaugeFull(rpmValue);
  }

  public final func drawRPMGaugeFull(rpmValue: Float) -> Void {
    let level: Float;
    let levelInt: Int32;
    let rpm: Int32;
    if this.m_hasRPM {
      if this.m_rpmPerChunk == 0 {
        this.m_rpmPerChunk = 1;
      };
      rpm = Cast(rpmValue);
      levelInt = rpm / this.m_rpmPerChunk;
      level = Cast(rpm / this.m_rpmPerChunk);
      levelInt = Cast(level);
      this.EvaluateRPMMeterWidget(levelInt);
    };
  }

  protected cb func OnRpmMaxChanged(rpmMax: Float) -> Bool {
    let level: Float;
    let levelInt: Int32;
    let rpm: Int32;
    if this.m_hasRPM {
      rpm = Cast(rpmMax);
      levelInt = rpm / this.m_rpmPerChunk;
      level = Cast(rpm / this.m_rpmPerChunk);
      levelInt = Cast(level);
      this.EvaluateRPMMeterWidget(levelInt);
    };
  }

  private final func EvaluateRPMMeterWidget(currentAmountOfChunks: Int32) -> Void {
    if currentAmountOfChunks == this.m_activeChunks {
      return;
    };
    if currentAmountOfChunks > this.m_activeChunks {
      this.AddChunk();
    } else {
      if currentAmountOfChunks < this.m_activeChunks {
        this.RemoveChunk();
      };
    };
    this.m_activeChunks = currentAmountOfChunks;
  }

  private final func AddChunk() -> Void {
    let chunkToActivate: String;
    let i: Int32;
    let widgetToShow: wref<inkImage>;
    if IsNameValid(this.m_dynamicRpmPath) {
      i = 1;
      while i <= this.m_activeChunks {
        chunkToActivate = NameToString(this.m_dynamicRpmPath) + IntToString(i);
        widgetToShow = this.GetWidget(StringToName(chunkToActivate)) as inkImage;
        widgetToShow.SetVisible(true);
        if this.m_hasRevMax && i >= this.m_revMaxChunk {
          widgetToShow = this.GetWidget(this.m_revMaxPath) as inkImage;
          widgetToShow.SetOpacity(1.00);
        } else {
          widgetToShow = this.GetWidget(this.m_revMaxPath) as inkImage;
          widgetToShow.SetOpacity(0.00);
        };
        i += 1;
      };
    };
  }

  private final func RemoveChunk() -> Void {
    let chunkToRemove: String;
    let i: Int32;
    let widgetToHide: wref<inkImage>;
    if IsNameValid(this.m_dynamicRpmPath) {
      i = this.m_chunksNumber;
      while i > this.m_activeChunks {
        chunkToRemove = NameToString(this.m_dynamicRpmPath) + IntToString(i);
        widgetToHide = this.GetWidget(StringToName(chunkToRemove)) as inkImage;
        widgetToHide.SetVisible(false);
        i -= 1;
      };
    };
  }

  private final func PrepAnim() -> Void {
    this.m_anim_exterior_fadein = new inkAnimDef();
    let fadeInterp: ref<inkAnimTransparency> = new inkAnimTransparency();
    fadeInterp.SetStartTransparency(0.00);
    fadeInterp.SetEndTransparency(0.70);
    fadeInterp.SetDuration(1.00);
    this.m_anim_exterior_fadein.AddInterpolator(fadeInterp);
    this.m_anim_exterior_fadeout = new inkAnimDef();
    fadeInterp = new inkAnimTransparency();
    fadeInterp.SetStartTransparency(0.70);
    fadeInterp.SetEndTransparency(0.00);
    fadeInterp.SetDuration(0.50);
    this.m_anim_exterior_fadeout.AddInterpolator(fadeInterp);
    this.m_anim_interior_fadeout = new inkAnimDef();
    fadeInterp = new inkAnimTransparency();
    fadeInterp.SetStartTransparency(1.00);
    fadeInterp.SetEndTransparency(0.00);
    fadeInterp.SetDuration(0.50);
    this.m_anim_interior_fadeout.AddInterpolator(fadeInterp);
    this.m_anim_interior_rpm_fadein = new inkAnimDef();
    fadeInterp = new inkAnimTransparency();
    fadeInterp.SetStartDelay(0.80);
    fadeInterp.SetStartTransparency(0.00);
    fadeInterp.SetEndTransparency(1.00);
    fadeInterp.SetDuration(0.10);
    this.m_anim_interior_rpm_fadein.AddInterpolator(fadeInterp);
    this.m_anim_interior_fluff1_fadein = new inkAnimDef();
    fadeInterp = new inkAnimTransparency();
    fadeInterp.SetStartDelay(1.00);
    fadeInterp.SetStartTransparency(0.00);
    fadeInterp.SetEndTransparency(1.00);
    fadeInterp.SetDuration(0.10);
    this.m_anim_interior_fluff1_fadein.AddInterpolator(fadeInterp);
    this.m_anim_interior_fluff2_fadein = new inkAnimDef();
    fadeInterp = new inkAnimTransparency();
    fadeInterp.SetStartDelay(1.10);
    fadeInterp.SetStartTransparency(0.00);
    fadeInterp.SetEndTransparency(1.00);
    fadeInterp.SetDuration(0.10);
    this.m_anim_interior_fluff2_fadein.AddInterpolator(fadeInterp);
    this.m_anim_interior_fluff3_fadein = new inkAnimDef();
    fadeInterp = new inkAnimTransparency();
    fadeInterp.SetStartDelay(1.50);
    fadeInterp.SetStartTransparency(0.00);
    fadeInterp.SetEndTransparency(1.00);
    fadeInterp.SetDuration(0.10);
    this.m_anim_interior_fluff3_fadein.AddInterpolator(fadeInterp);
    this.m_anim_interior_fluff4_fadein = new inkAnimDef();
    fadeInterp = new inkAnimTransparency();
    fadeInterp.SetStartDelay(1.30);
    fadeInterp.SetStartTransparency(0.00);
    fadeInterp.SetEndTransparency(1.00);
    fadeInterp.SetDuration(0.10);
    this.m_anim_interior_fluff4_fadein.AddInterpolator(fadeInterp);
    this.m_anim_interior_fluff5_fadein = new inkAnimDef();
    fadeInterp = new inkAnimTransparency();
    fadeInterp.SetStartDelay(1.80);
    fadeInterp.SetStartTransparency(0.00);
    fadeInterp.SetEndTransparency(1.00);
    fadeInterp.SetDuration(0.10);
    this.m_anim_interior_fluff5_fadein.AddInterpolator(fadeInterp);
  }

  private final func PrepFluffLoopAnim() -> Void {
    this.m_anim_interior_fluff1_anim1 = new inkAnimDef();
    let fadeInterp: ref<inkAnimTransparency> = new inkAnimTransparency();
    fadeInterp.SetStartTransparency(0.00);
    fadeInterp.SetEndTransparency(1.00);
    fadeInterp.SetDuration(3.00);
    this.m_anim_interior_fluff1_anim1.AddInterpolator(fadeInterp);
    fadeInterp.SetStartDelay(5.50);
    fadeInterp.SetStartTransparency(1.00);
    fadeInterp.SetEndTransparency(0.00);
    fadeInterp.SetDuration(2.00);
    this.m_anim_interior_fluff1_anim1.AddInterpolator(fadeInterp);
    this.m_anim_interior_fluff1_anim2 = new inkAnimDef();
    fadeInterp = new inkAnimTransparency();
    fadeInterp.SetStartTransparency(0.00);
    fadeInterp.SetEndTransparency(1.00);
    fadeInterp.SetDuration(2.50);
    this.m_anim_interior_fluff1_anim2.AddInterpolator(fadeInterp);
    fadeInterp.SetStartDelay(3.50);
    fadeInterp.SetStartTransparency(1.00);
    fadeInterp.SetEndTransparency(0.00);
    fadeInterp.SetDuration(3.00);
    this.m_anim_interior_fluff1_anim2.AddInterpolator(fadeInterp);
    this.m_anim_interior_fluff2_anim1 = new inkAnimDef();
    fadeInterp = new inkAnimTransparency();
    fadeInterp.SetStartTransparency(0.00);
    fadeInterp.SetEndTransparency(1.00);
    fadeInterp.SetDuration(4.00);
    this.m_anim_interior_fluff2_anim1.AddInterpolator(fadeInterp);
    fadeInterp.SetStartDelay(7.50);
    fadeInterp.SetStartTransparency(1.00);
    fadeInterp.SetEndTransparency(0.00);
    fadeInterp.SetDuration(3.00);
    this.m_anim_interior_fluff2_anim1.AddInterpolator(fadeInterp);
    this.m_anim_interior_fluff2_anim2 = new inkAnimDef();
    fadeInterp = new inkAnimTransparency();
    fadeInterp.SetStartTransparency(0.00);
    fadeInterp.SetEndTransparency(1.00);
    fadeInterp.SetDuration(2.00);
    this.m_anim_interior_fluff2_anim2.AddInterpolator(fadeInterp);
    fadeInterp.SetStartDelay(6.50);
    fadeInterp.SetStartTransparency(1.00);
    fadeInterp.SetEndTransparency(0.00);
    fadeInterp.SetDuration(3.00);
    this.m_anim_interior_fluff2_anim2.AddInterpolator(fadeInterp);
    this.m_fluff1animOptions1.loopType = inkanimLoopType.Cycle;
    this.m_fluff1animOptions1.loopCounter = 10000u;
    this.m_fluff1animOptions2.loopType = inkanimLoopType.Cycle;
    this.m_fluff1animOptions2.loopCounter = 10000u;
    this.m_fluff2animOptions1.loopType = inkanimLoopType.Cycle;
    this.m_fluff2animOptions1.loopCounter = 10000u;
    this.m_fluff2animOptions2.loopType = inkanimLoopType.Cycle;
    this.m_fluff2animOptions2.loopCounter = 10000u;
  }

  protected cb func OnAutopilotChanged(autopilotOn: Bool) -> Bool {
    this.m_isInAutoPilot = autopilotOn;
  }

  protected cb func OnPlayerStateChanged(data: Variant) -> Bool {
    let newData: VehEntityPlayerStateData = FromVariant(data);
    let vehEntityID: EntityID = newData.entID;
    let entID: EntityID = this.GetOwnerEntity().GetEntityID();
    let playerState: Int32 = newData.state;
    if entID == vehEntityID {
      if playerState == EnumInt(gamePSMVehicle.Driving) || playerState == EnumInt(gamePSMVehicle.Passenger) {
        this.m_windowWidget.PlayAnimation(this.m_anim_exterior_fadein);
        this.m_windowWidget.SetVisible(true);
        if !this.m_wasCombat {
          this.m_interiorRPMWidget.PlayAnimation(this.m_anim_interior_rpm_fadein);
          this.m_interiorRPMWidget.SetVisible(true);
          this.m_interiorFluff1Widget.PlayAnimation(this.m_anim_interior_fluff1_fadein);
          this.m_interiorFluff1Widget.SetVisible(true);
          this.m_interiorFluff1Anim1Widget.SetVisible(true);
          this.m_interiorFluff1Anim2Widget.SetVisible(true);
          this.m_animFluffFadeInProxy = this.m_interiorFluff2Widget.PlayAnimation(this.m_anim_interior_fluff2_fadein);
          this.m_interiorFluff2Widget.SetVisible(true);
          this.m_interiorFluff2Anim1Widget.SetVisible(true);
          this.m_interiorFluff2Anim2Widget.SetVisible(true);
          this.m_interiorFluff3Widget.PlayAnimation(this.m_anim_interior_fluff3_fadein);
          this.m_interiorFluff3Widget.SetVisible(true);
          this.m_interiorFluff4Widget.PlayAnimation(this.m_anim_interior_fluff4_fadein);
          this.m_interiorFluff4Widget.SetVisible(true);
          this.m_interiorFluff5Widget.PlayAnimation(this.m_anim_interior_fluff5_fadein);
          this.m_interiorFluff5Widget.SetVisible(true);
          this.m_animFluffFadeInProxy.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnAnimFluffFadeInFinshed");
        };
      };
      if playerState == EnumInt(gamePSMVehicle.Combat) {
        this.m_windowWidget.PlayAnimation(this.m_anim_exterior_fadeout);
        this.m_wasCombat = true;
      } else {
        if playerState == EnumInt(gamePSMVehicle.Transition) {
          this.m_animFadeOutProxy = this.m_windowWidget.PlayAnimation(this.m_anim_exterior_fadeout);
          this.m_interiorRPMWidget.PlayAnimation(this.m_anim_interior_fadeout);
          this.m_interiorFluff1Widget.PlayAnimation(this.m_anim_interior_fadeout);
          this.m_interiorFluff2Widget.PlayAnimation(this.m_anim_interior_fadeout);
          this.m_interiorFluff3Widget.PlayAnimation(this.m_anim_interior_fadeout);
          this.m_interiorFluff4Widget.PlayAnimation(this.m_anim_interior_fadeout);
          this.m_interiorFluff5Widget.PlayAnimation(this.m_anim_interior_fadeout);
          this.m_interiorFluff1Anim1Widget.PlayAnimation(this.m_anim_interior_fadeout);
          this.m_interiorFluff1Anim2Widget.PlayAnimation(this.m_anim_interior_fadeout);
          this.m_interiorFluff2Anim1Widget.PlayAnimation(this.m_anim_interior_fadeout);
          this.m_interiorFluff2Anim2Widget.PlayAnimation(this.m_anim_interior_fadeout);
          this.m_interiorFluff1Anim1Widget.StopAllAnimations();
          this.m_interiorFluff1Anim1Widget.PlayAnimation(this.m_anim_interior_fadeout);
          this.m_interiorFluff1Anim2Widget.StopAllAnimations();
          this.m_interiorFluff1Anim2Widget.PlayAnimation(this.m_anim_interior_fadeout);
          this.m_interiorFluff2Anim1Widget.StopAllAnimations();
          this.m_interiorFluff2Anim1Widget.PlayAnimation(this.m_anim_interior_fadeout);
          this.m_interiorFluff2Anim2Widget.StopAllAnimations();
          this.m_interiorFluff2Anim2Widget.PlayAnimation(this.m_anim_interior_fadeout);
          this.m_animFadeOutProxy.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnAnimFadeOutFinshed");
          this.m_wasCombat = false;
        };
      };
    };
  }

  protected cb func OnAnimFadeOutFinshed(anim: ref<inkAnimProxy>) -> Bool {
    this.m_windowWidget.SetVisible(false);
    this.m_interiorRPMWidget.SetVisible(false);
    this.m_interiorFluff1Widget.SetVisible(false);
    this.m_interiorFluff2Widget.SetVisible(false);
    this.m_interiorFluff3Widget.SetVisible(false);
    this.m_interiorFluff4Widget.SetVisible(false);
    this.m_interiorFluff5Widget.SetVisible(false);
    this.m_interiorFluff1Anim1Widget.SetVisible(false);
    this.m_interiorFluff1Anim2Widget.SetVisible(false);
    this.m_interiorFluff2Anim1Widget.SetVisible(false);
    this.m_interiorFluff2Anim2Widget.SetVisible(false);
  }

  protected cb func OnAnimFluffFadeInFinshed(anim: ref<inkAnimProxy>) -> Bool {
    this.PrepFluffLoopAnim();
    this.m_interiorFluff1Anim1Widget.PlayAnimationWithOptions(this.m_anim_interior_fluff1_anim1, this.m_fluff1animOptions1);
    this.m_interiorFluff1Anim2Widget.PlayAnimationWithOptions(this.m_anim_interior_fluff1_anim2, this.m_fluff1animOptions2);
    this.m_interiorFluff2Anim1Widget.PlayAnimationWithOptions(this.m_anim_interior_fluff2_anim1, this.m_fluff2animOptions1);
    this.m_interiorFluff2Anim2Widget.PlayAnimationWithOptions(this.m_anim_interior_fluff2_anim2, this.m_fluff2animOptions2);
  }
}
