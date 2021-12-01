
public class FanController extends BasicDistractionDeviceController {

  protected const func GetPS() -> ref<GameComponentPS> {
    return this.GetBasePS();
  }
}

public class FanControllerPS extends BasicDistractionDeviceControllerPS {

  private persistent let m_fanSetup: FanSetup;

  protected cb func OnInstantiated() -> Bool {
    super.OnInstantiated();
    if !IsStringValid(this.m_deviceName) {
      this.m_deviceName = "LocKey#94";
    };
  }

  protected func Initialize() -> Void {
    this.Initialize();
  }

  public final const func IsRotatingClockwise() -> Bool {
    return this.m_fanSetup.m_rotateClockwise;
  }

  public final const func IsBladesSpeedRandomized() -> Bool {
    return this.m_fanSetup.m_randomizeBladesSpeed;
  }

  public final const func GetMaxRotationSpeed() -> Float {
    return this.m_fanSetup.m_maxRotationSpeed;
  }

  public final const func GetTimeToMaxRotation() -> Float {
    return this.m_fanSetup.m_timeToMaxRotation;
  }

  public final func PushResaveData(data: FanResaveData) -> Void;

  public func GetActions(out actions: array<ref<DeviceAction>>, context: GetActionsContext) -> Bool {
    this.GetActions(actions, context);
    if ToggleON.IsDefaultConditionMet(this, context) {
      ArrayPush(actions, this.ActionToggleON());
    };
    this.SetActionIllegality(actions, this.m_illegalActions.regularActions);
    return true;
  }

  protected func GetDeviceIconTweakDBID() -> TweakDBID {
    return t"DeviceIcons.VentilationDeviceIcon";
  }

  protected func GetBackgroundTextureTweakDBID() -> TweakDBID {
    return t"DeviceIcons.VentilationDeviceBackground";
  }
}
