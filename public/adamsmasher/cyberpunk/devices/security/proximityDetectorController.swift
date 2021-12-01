
public class ProximityDetectorController extends ScriptableDC {

  protected const func GetPS() -> ref<GameComponentPS> {
    return this.GetBasePS();
  }
}

public class ProximityDetectorControllerPS extends ScriptableDeviceComponentPS {

  protected func PerformRestart() -> Void;

  protected func OnTargetAssessmentRequest(evt: ref<TargetAssessmentRequest>) -> EntityNotificationType {
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected func GetDeviceIconTweakDBID() -> TweakDBID {
    return t"DeviceIcons.SecuritySystemDeviceIcon";
  }

  protected func GetBackgroundTextureTweakDBID() -> TweakDBID {
    return t"DeviceIcons.SecuritySystemDeviceBackground";
  }
}
