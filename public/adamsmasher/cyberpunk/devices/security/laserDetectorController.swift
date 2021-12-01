
public class LaserDetectorController extends ScriptableDC {

  protected const func GetPS() -> ref<GameComponentPS> {
    return this.GetBasePS();
  }
}

public class LaserDetectorControllerPS extends ScriptableDeviceComponentPS {

  protected func GetDeviceIconTweakDBID() -> TweakDBID {
    return t"DeviceIcons.SecuritySystemDeviceIcon";
  }

  protected func GetBackgroundTextureTweakDBID() -> TweakDBID {
    return t"DeviceIcons.SecuritySystemDeviceBackground";
  }
}
