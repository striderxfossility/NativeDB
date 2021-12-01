
public class AlarmLightController extends ScriptableDC {

  protected const func GetPS() -> ref<GameComponentPS> {
    return this.GetBasePS();
  }
}

public class AlarmLightControllerPS extends BasicDistractionDeviceControllerPS {

  @default(AlarmLightControllerPS, ESecuritySystemState.SAFE)
  protected let m_securityAlarmState: ESecuritySystemState;

  public final const func GetAlarmState() -> ESecuritySystemState {
    return this.m_securityAlarmState;
  }

  public func OnQuestForceSecuritySystemSafe(evt: ref<QuestForceSecuritySystemSafe>) -> EntityNotificationType {
    this.m_securityAlarmState = ESecuritySystemState.SAFE;
    return EntityNotificationType.SendThisEventToEntity;
  }

  public func OnQuestForceSecuritySystemArmed(evt: ref<QuestForceSecuritySystemArmed>) -> EntityNotificationType {
    this.m_securityAlarmState = ESecuritySystemState.COMBAT;
    this.WakeUpDevice();
    return EntityNotificationType.SendThisEventToEntity;
  }

  public func OnSecurityAlarmBreachResponse(evt: ref<SecurityAlarmBreachResponse>) -> EntityNotificationType {
    this.m_securityAlarmState = evt.GetSecurityState();
    if Equals(this.m_securityAlarmState, ESecuritySystemState.COMBAT) {
      this.WakeUpDevice();
    };
    return EntityNotificationType.SendThisEventToEntity;
  }

  public func OnSecuritySystemOutput(evt: ref<SecuritySystemOutput>) -> EntityNotificationType {
    this.OnSecuritySystemOutput(evt);
    this.m_securityAlarmState = evt.GetCachedSecurityState();
    if Equals(this.m_securityAlarmState, ESecuritySystemState.COMBAT) {
      this.WakeUpDevice();
    };
    return EntityNotificationType.SendThisEventToEntity;
  }
}
