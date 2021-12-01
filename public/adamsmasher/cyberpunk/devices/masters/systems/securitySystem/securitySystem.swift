
public class SecuritySystem extends DeviceSystemBase {

  private let m_savedOutputCache: array<OutputValidationDataStruct>;

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    super.OnTakeControl(ri);
    this.m_controller = EntityResolveComponentsInterface.GetComponent(ri, n"controller") as SecuritySystemController;
  }

  public const func GetDefaultHighlight() -> ref<FocusForcedHighlightData> {
    return null;
  }

  public const func GetDevicePS() -> ref<ScriptableDeviceComponentPS> {
    return this.GetControllerPersistentState() as ScriptableDeviceComponentPS;
  }

  private const func GetController() -> ref<ScriptableDC> {
    return this.m_controller;
  }

  protected cb func OnSlaveStateChanged(evt: ref<PSDeviceChangedEvent>) -> Bool {
    return false;
  }

  protected cb func OnQuestIllegalActionNotification(evt: ref<QuestIllegalActionNotification>) -> Bool {
    (this.GetDevicePS() as SecuritySystemControllerPS).QuestIllegalActionNotification(evt);
  }

  protected cb func OnQuestCombatActionNotification(evt: ref<QuestCombatActionNotification>) -> Bool {
    (this.GetDevicePS() as SecuritySystemControllerPS).QuestCombatActionNotification(evt);
  }

  protected cb func OnSetSecuritySystemState(evt: ref<SetSecuritySystemState>) -> Bool {
    (this.GetDevicePS() as SecuritySystemControllerPS).QuestChangeSecuritySystemState(evt);
  }

  protected cb func OnQuestAuthorizePlayer(evt: ref<AuthorizePlayerInSecuritySystem>) -> Bool {
    (this.GetDevicePS() as SecuritySystemControllerPS).QuestAuthorizePlayer(evt);
  }

  protected cb func OnQuestBlackListPlayer(evt: ref<BlacklistPlayer>) -> Bool {
    (this.GetDevicePS() as SecuritySystemControllerPS).QuestBlacklistPlayer(evt);
  }

  protected cb func OnQuestExclusiveQuestControl(evt: ref<SuppressSecuritySystemStateChange>) -> Bool {
    (this.GetDevicePS() as SecuritySystemControllerPS).QuestSuppressSecuritySystem(evt);
  }

  protected cb func OnQuestChangeSecuritySystemAttitudeGroup(evt: ref<QuestChangeSecuritySystemAttitudeGroup>) -> Bool {
    (this.GetDevicePS() as SecuritySystemControllerPS).QuestChangeSecuritySystemAttitudeGroup(evt);
  }

  public func OnMaraudersMapDeviceDebug(sink: ref<MaraudersMapDevicesSink>) -> Void;
}
