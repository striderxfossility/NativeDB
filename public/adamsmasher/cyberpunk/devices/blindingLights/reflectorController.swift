
public class ReflectorController extends BlindingLightController {

  protected const func GetPS() -> ref<GameComponentPS> {
    return this.GetBasePS();
  }
}

public class ReflectorControllerPS extends BlindingLightControllerPS {

  public func GetActions(out outActions: array<ref<DeviceAction>>, context: GetActionsContext) -> Bool {
    this.GetActions(outActions, context);
    if this.IsPowered() {
      if NotEquals(context.requestType, gamedeviceRequestType.Remote) && !this.m_distractExecuted {
        ArrayPush(outActions, this.ActionToggleON());
      };
      if Equals(context.requestType, gamedeviceRequestType.Direct) && !this.m_distractExecuted {
        ArrayPush(outActions, this.ActionDistraction());
      };
    };
    this.SetActionIllegality(outActions, this.m_illegalActions.regularActions);
    return true;
  }

  public func ActionToggleON() -> ref<ToggleON> {
    let action: ref<ToggleON> = this.ActionToggleON();
    action.SetDurationValue(9.40);
    return action;
  }

  protected final func ActionDistraction() -> ref<Distraction> {
    let action: ref<Distraction> = new Distraction();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    action.SetDurationValue(this.GetDistractionDuration(action));
    action.CreateInteraction();
    return action;
  }

  public final func OnDistraction(evt: ref<Distraction>) -> EntityNotificationType {
    let cachedStatus: ref<BaseDeviceStatus> = this.GetDeviceStatusAction();
    if evt.IsStarted() {
      this.m_distractExecuted = true;
      evt.SetCanTriggerStim(true);
      this.ExecutePSActionWithDelay(evt, this, evt.GetDurationValue());
    } else {
      this.m_distractExecuted = false;
      evt.SetCanTriggerStim(false);
    };
    this.UseNotifier(evt);
    if !IsFinal() {
      this.LogActionDetails(evt, cachedStatus);
    };
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected func OnActivateDevice(evt: ref<ActivateDevice>) -> EntityNotificationType {
    if NotEquals(this.m_activationState, EActivationState.ACTIVATED) && this.IsOFF() {
      this.OnActivateDevice(evt);
      this.ExecutePSAction(this.ActionToggleON());
    };
    return EntityNotificationType.DoNotNotifyEntity;
  }

  protected func OnDeactivateDevice(evt: ref<DeactivateDevice>) -> EntityNotificationType {
    if NotEquals(this.m_activationState, EActivationState.DEACTIVATED) && this.IsON() {
      this.OnDeactivateDevice(evt);
      this.ExecutePSAction(this.ActionToggleON());
    };
    return EntityNotificationType.DoNotNotifyEntity;
  }

  protected func GetBackgroundTextureTweakDBID() -> TweakDBID {
    return t"DeviceIcons.LightDeviceBackground";
  }

  protected func GetDeviceIconTweakDBID() -> TweakDBID {
    return t"DeviceIcons.LightDeviceIcon";
  }
}
