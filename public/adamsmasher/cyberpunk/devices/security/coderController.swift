
public class CoderController extends ScriptableDC {

  protected const func GetPS() -> ref<GameComponentPS> {
    return this.GetBasePS();
  }
}

public class CoderControllerPS extends BasicDistractionDeviceControllerPS {

  @attrib(tooltip, "Whoever uses this device is granted provided security access level")
  @default(CoderControllerPS, ESecurityAccessLevel.ESL_4)
  private let m_providedAuthorizationLevel: ESecurityAccessLevel;

  protected func ActionAuthorizeUser() -> ref<AuthorizeUser> {
    let action: ref<AuthorizeUser> = this.ActionAuthorizeUser();
    action.CreateInteraction();
    return action;
  }

  public func OnAuthorizeUser(evt: ref<AuthorizeUser>) -> EntityNotificationType {
    let secSys: ref<SecuritySystemControllerPS> = this.GetSecuritySystem();
    if IsDefined(secSys) {
      secSys.AuthorizeUser(evt.GetExecutor().GetEntityID(), this.m_providedAuthorizationLevel);
      return EntityNotificationType.SendThisEventToEntity;
    };
    return EntityNotificationType.DoNotNotifyEntity;
  }

  public func GetActions(out outActions: array<ref<DeviceAction>>, context: GetActionsContext) -> Bool {
    let secSys: ref<SecuritySystemControllerPS> = this.GetSecuritySystem();
    if !IsDefined(secSys) {
      return false;
    };
    if !secSys.IsUserAuthorized(context.processInitiatorObject.GetEntityID(), this.m_providedAuthorizationLevel) {
      if !secSys.IsEntityBlacklistedForAtLeast(context.processInitiatorObject.GetEntityID(), BlacklistReason.COMBAT) {
        ArrayPush(outActions, this.ActionAuthorizeUser());
      };
    };
    return true;
  }

  protected func GetDeviceIconTweakDBID() -> TweakDBID {
    return t"DeviceIcons.SecuritySystemDeviceIcon";
  }

  protected func GetBackgroundTextureTweakDBID() -> TweakDBID {
    return t"DeviceIcons.SecuritySystemDeviceBackground";
  }
}
