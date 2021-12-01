
public class RevealEnemies extends ActionBool {

  public final func SetProperties(reveal: Bool) -> Void {
    this.actionName = n"RevealEnemies";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"RevealEnemies", reveal, n"LocKey#17840", n"LocKey#17850");
  }
}

public class SurveillanceSystemController extends DeviceSystemBaseController {

  protected const func GetPS() -> ref<GameComponentPS> {
    return this.GetBasePS();
  }
}

public class SurveillanceSystemControllerPS extends DeviceSystemBaseControllerPS {

  private let m_isRevealingEnemies: Bool;

  protected cb func OnInstantiated() -> Bool {
    super.OnInstantiated();
    if !IsStringValid(this.m_deviceName) {
      this.m_deviceName = "LocKey#50770";
    };
  }

  protected func Initialize() -> Void {
    this.Initialize();
  }

  private func ActionRevealEnemies() -> ref<RevealEnemies> {
    let action: ref<RevealEnemies> = new RevealEnemies();
    action.SetUp(this);
    action.SetProperties(this.m_isRevealingEnemies);
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  public func GetActions(out outActions: array<ref<DeviceAction>>, context: GetActionsContext) -> Bool {
    this.GetActions(outActions, context);
    if ScriptableDeviceAction.IsDefaultConditionMet(this, context) {
      ArrayPush(outActions, this.ActionRevealEnemies());
    };
    this.SetActionIllegality(outActions, this.m_illegalActions.regularActions);
    return true;
  }

  public final func OnRevealEnemies(evt: ref<RevealEnemies>) -> EntityNotificationType {
    let mySlaves: array<ref<DeviceComponentPS>> = this.GetImmediateSlaves();
    this.m_isRevealingEnemies = !this.m_isRevealingEnemies;
    let i: Int32 = 0;
    while i < ArraySize(mySlaves) {
      (mySlaves[i] as SurveillanceCameraControllerPS).ForceRevealEnemies(this.m_isRevealingEnemies);
      i += 1;
    };
    this.UseNotifier(evt);
    return EntityNotificationType.DoNotNotifyEntity;
  }
}
