
public class VehicleSummonWidgetGameController extends inkHUDGameController {

  private edit let m_vehicleNameLabel: inkTextRef;

  private edit let m_vehicleTypeIcon: inkImageRef;

  private edit let m_vehicleManufactorIcon: inkImageRef;

  private edit let m_distanceLabel: inkTextRef;

  private edit let m_isWaiting: inkTextRef;

  private edit let m_unit: EMeasurementUnit;

  private edit let m_unitText: inkTextRef;

  private let m_animationProxy: ref<inkAnimProxy>;

  private let m_animationCounterProxy: ref<inkAnimProxy>;

  private let optionIntro: inkAnimOptions;

  private let optionCounter: inkAnimOptions;

  private let m_vehicleSummonDataDef: ref<VehicleSummonDataDef>;

  private let m_vehicleSummonDataBB: wref<IBlackboard>;

  private let m_vehicleSummonStateCallback: ref<CallbackHandle>;

  private let m_vehicleSummonState: Uint32;

  private let m_vehiclePos: Vector4;

  private let m_playerPos: Vector4;

  private let m_distanceVector: Vector4;

  private let m_gameInstance: GameInstance;

  private let distance: Int32;

  private let vehicleID: EntityID;

  private let vehicleEntity: wref<Entity>;

  private let vehicle: wref<VehicleObject>;

  private let vehicleRecord: ref<Vehicle_Record>;

  private let textParams: ref<inkTextParams>;

  private let iconRecord: ref<UIIcon_Record>;

  protected cb func OnInitialize() -> Bool {
    this.GetRootWidget().SetVisible(false);
    this.m_vehicleSummonDataDef = GetAllBlackboardDefs().VehicleSummonData;
    this.m_vehicleSummonDataBB = this.GetBlackboardSystem().Get(this.m_vehicleSummonDataDef);
    this.m_vehicleSummonStateCallback = this.m_vehicleSummonDataBB.RegisterListenerUint(this.m_vehicleSummonDataDef.SummonState, this, n"OnVehicleSummonStateChanged");
  }

  protected cb func OnUninitialize() -> Bool {
    this.GetRootWidget().SetVisible(false);
    this.m_vehicleSummonDataBB.UnregisterListenerUint(this.m_vehicleSummonDataDef.SummonState, this.m_vehicleSummonStateCallback);
  }

  protected cb func OnPlayerAttach(playerPuppet: ref<GameObject>) -> Bool {
    this.m_playerPos = this.GetPlayerControlledObject().GetWorldPosition();
    this.m_gameInstance = playerPuppet.GetGame();
  }

  protected cb func OnVehicleSummonStateChanged(value: Uint32) -> Bool {
    this.m_vehicleSummonState = value;
    if this.m_vehicleSummonState == EnumInt(vehicleSummonState.EnRoute) {
      this.GetRootWidget().SetVisible(true);
      this.ShowNotification();
    } else {
      if this.m_vehicleSummonState == EnumInt(vehicleSummonState.Arrived) {
        this.HideNotification();
      } else {
        if this.m_vehicleSummonState == EnumInt(vehicleSummonState.AlreadySummoned) {
          this.PlayLibraryAnimation(n"waiting");
        } else {
          this.GetRootWidget().SetVisible(false);
        };
      };
    };
  }

  public final func ShowNotification() -> Void {
    this.vehicleID = this.m_vehicleSummonDataBB.GetEntityID(this.m_vehicleSummonDataDef.SummonedVehicleEntityID);
    if EntityID.IsDefined(this.vehicleID) {
      this.vehicleEntity = GameInstance.FindEntityByID(this.m_gameInstance, this.vehicleID);
      this.vehicle = this.vehicleEntity as VehicleObject;
      this.vehicleRecord = TweakDBInterface.GetVehicleRecord(this.vehicle.GetRecordID());
      this.distance = RoundF(Vector4.Distance(this.vehicleEntity.GetWorldPosition(), this.GetPlayerControlledObject().GetWorldPosition()));
      this.textParams = new inkTextParams();
      this.textParams.AddMeasurement("distance", Cast(this.distance), EMeasurementUnit.Meter);
      this.textParams.AddString("unit", GetLocalizedText(NameToString(MeasurementUtils.GetUnitLocalizationKey(UILocalizationHelper.GetSystemBaseUnit()))));
      this.iconRecord = TweakDBInterface.GetUIIconRecord(TDBID.Create("UIIcon." + this.vehicleRecord.Manufacturer().EnumName()));
      inkImageRef.SetTexturePart(this.m_vehicleManufactorIcon, this.iconRecord.AtlasPartName());
      inkTextRef.SetText(this.m_distanceLabel, "{distance}{unit}", this.textParams);
      this.PlayAnim(n"intro", n"OnIntroFinished");
      this.optionCounter.loopType = inkanimLoopType.Cycle;
      this.optionCounter.loopCounter = 35u;
      this.m_animationCounterProxy = this.PlayLibraryAnimation(n"counter", this.optionCounter);
      this.m_animationCounterProxy.RegisterToCallback(inkanimEventType.OnEndLoop, this, n"OnEndLoop");
      GameInstance.GetAudioSystem(this.m_gameInstance).Play(n"ui_jingle_car_call");
      inkTextRef.SetLocalizedTextScript(this.m_vehicleNameLabel, this.vehicleRecord.DisplayName());
      if Equals(this.vehicleRecord.Type().Type(), gamedataVehicleType.Bike) {
        inkImageRef.SetTexturePart(this.m_vehicleTypeIcon, n"motorcycle");
      } else {
        inkImageRef.SetTexturePart(this.m_vehicleTypeIcon, n"car");
      };
    };
  }

  public final func HideNotification() -> Void {
    if IsDefined(this.m_animationProxy) && this.m_animationProxy.IsPlaying() {
      this.m_animationProxy.Stop();
    };
    if IsDefined(this.m_animationCounterProxy) && this.m_animationCounterProxy.IsPlaying() {
      this.m_animationCounterProxy.Stop();
    };
    this.optionIntro.loopCounter = 0u;
    this.optionIntro.loopType = IntEnum(0l);
    this.optionIntro.loopInfinite = false;
    this.m_animationProxy = this.PlayLibraryAnimation(n"arrived", this.optionIntro);
  }

  protected cb func OnIntroFinished(anim: ref<inkAnimProxy>) -> Bool {
    if IsDefined(this.m_animationProxy) && this.m_animationProxy.IsPlaying() {
      this.m_animationProxy.Stop();
    };
    this.optionIntro.loopType = inkanimLoopType.PingPong;
    this.optionIntro.loopCounter = 35u;
    this.m_animationProxy = this.PlayLibraryAnimation(n"loop", this.optionIntro);
    this.m_animationProxy.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnTimeOut");
  }

  protected cb func OnEndLoop(anim: ref<inkAnimProxy>) -> Bool {
    this.vehicleID = this.m_vehicleSummonDataBB.GetEntityID(this.m_vehicleSummonDataDef.SummonedVehicleEntityID);
    if EntityID.IsDefined(this.vehicleID) {
      this.vehicleEntity = GameInstance.FindEntityByID(this.m_gameInstance, this.vehicleID);
      this.vehicle = this.vehicleEntity as VehicleObject;
      this.distance = RoundF(Vector4.Distance(this.vehicleEntity.GetWorldPosition(), this.GetPlayerControlledObject().GetWorldPosition()));
      this.textParams = new inkTextParams();
      this.textParams.AddMeasurement("distance", Cast(this.distance), EMeasurementUnit.Meter);
      this.textParams.AddString("unit", GetLocalizedText(NameToString(MeasurementUtils.GetUnitLocalizationKey(UILocalizationHelper.GetSystemBaseUnit()))));
      inkTextRef.SetText(this.m_distanceLabel, "{distance}{unit}", this.textParams);
    };
  }

  protected cb func OnTimeOut(anim: ref<inkAnimProxy>) -> Bool {
    this.HideNotification();
  }

  public final func PlayAnim(animName: CName, opt callBack: CName) -> Void {
    if IsDefined(this.m_animationProxy) && this.m_animationProxy.IsPlaying() {
      this.m_animationProxy.Stop();
    };
    this.m_animationProxy = this.PlayLibraryAnimation(animName);
    if NotEquals(callBack, n"") {
      this.m_animationProxy.RegisterToCallback(inkanimEventType.OnFinish, this, callBack);
    };
  }
}
