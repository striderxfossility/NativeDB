
public class ActionOverride extends ActionBool {

  public final func SetProperties() -> Void;

  public func GetTweakDBChoiceRecord() -> String {
    if TDBID.IsValid(this.m_objectActionID) {
      return this.GetTweakDBChoiceRecord();
    };
    return "Override";
  }
}

public class ElectricBoxController extends MasterController {

  protected const func GetPS() -> ref<GameComponentPS> {
    return this.GetBasePS();
  }
}

public class ElectricBoxControllerPS extends MasterControllerPS {

  private inline let m_techieSkillChecks: ref<EngineeringContainer>;

  private let m_questFactSetup: ComputerQuickHackData;

  private persistent let m_isOverriden: Bool;

  protected func GameAttached() -> Void;

  protected func LogicReady() -> Void {
    this.LogicReady();
    this.InitializeSkillChecks(this.m_techieSkillChecks);
  }

  public final const quest func IsOverriden() -> Bool {
    return this.m_isOverriden;
  }

  public func GetActions(out actions: array<ref<DeviceAction>>, context: GetActionsContext) -> Bool {
    if !this.GetActions(actions, context) {
      return false;
    };
    if !this.IsON() {
      return false;
    };
    if !this.m_isOverriden {
      ArrayPush(actions, this.ActionOverride());
    };
    this.SetActionIllegality(actions, this.m_illegalActions.regularActions);
    return true;
  }

  private final func ActionOverride() -> ref<ActionOverride> {
    let action: ref<ActionOverride> = new ActionOverride();
    action.SetUp(this);
    action.AddDeviceName(this.m_deviceName);
    if TDBID.IsValid(this.m_questFactSetup.alternativeName) {
      action.CreateInteraction(this.m_questFactSetup.alternativeName);
    } else {
      action.CreateInteraction();
    };
    action.SetIllegal(this.m_illegalActions.skillChecks || this.m_illegalActions.regularActions);
    return action;
  }

  protected func OnActionEngineering(evt: ref<ActionEngineering>) -> EntityNotificationType {
    this.OnActionEngineering(evt);
    this.m_isOverriden = true;
    this.ExecutePSAction(this.ActionOverride(), n"direct");
    return EntityNotificationType.DoNotNotifyEntity;
  }

  protected func OnActionOverride(evt: ref<ActionOverride>) -> EntityNotificationType {
    this.m_isOverriden = true;
    if this.IsConnectedToSecuritySystem() {
      this.TriggerSecuritySystemNotification(evt.GetExecutor(), this.GetOwnerEntityWeak().GetWorldPosition(), ESecurityNotificationType.ILLEGAL_ACTION);
    };
    this.UseNotifier(evt);
    return EntityNotificationType.SendThisEventToEntity;
  }

  public final func GetQuestSetup() -> ComputerQuickHackData {
    return this.m_questFactSetup;
  }

  public final func WorkspotFinished() -> Void {
    this.m_isOverriden = true;
    this.RefreshSlaves();
  }

  private final const func RefreshSlaves() -> Void {
    this.SendActionToAllSlaves(new ActionOverride());
  }

  protected func GetDeviceIconTweakDBID() -> TweakDBID {
    return t"DeviceIcons.GeneratorDeviceIcon";
  }

  protected func GetBackgroundTextureTweakDBID() -> TweakDBID {
    return t"DeviceIcons.GeneratorDeviceBackground";
  }
}
