
public class stealthAlertGameController extends inkHUDGameController {

  private edit let m_label: inkTextRef;

  private edit let m_icon: inkImageRef;

  private edit let m_indicator_01: inkImageRef;

  private edit let m_indicator_02: inkImageRef;

  private edit let m_indicator_03: inkImageRef;

  private edit let m_fluff_01: inkWidgetRef;

  private edit let m_fluff_02: inkWidgetRef;

  private edit let m_fluff_03: inkWidgetRef;

  private edit let m_fluff_04: inkWidgetRef;

  private let m_root: wref<inkWidget>;

  private let m_securityBlackBoardID: ref<CallbackHandle>;

  private let m_playerBlackboardID: Uint32;

  private let m_blackboard: wref<IBlackboard>;

  private let m_playerPuppet: wref<GameObject>;

  private let m_animationProxy: ref<inkAnimProxy>;

  protected cb func OnPlayerAttach(playerPuppet: ref<GameObject>) -> Bool {
    this.m_playerPuppet = playerPuppet;
    this.m_blackboard = this.GetPSMBlackboard(this.m_playerPuppet);
    this.m_securityBlackBoardID = this.m_blackboard.RegisterListenerVariant(GetAllBlackboardDefs().PlayerStateMachine.SecurityZoneData, this, n"OnSecurityDataChange");
    this.m_root = this.GetRootWidget();
    inkWidgetRef.SetVisible(this.m_fluff_01, false);
    inkWidgetRef.SetVisible(this.m_fluff_02, false);
    inkWidgetRef.SetVisible(this.m_fluff_03, false);
    inkWidgetRef.SetVisible(this.m_fluff_04, false);
    this.m_root.SetState(n"Public");
    this.m_root.SetVisible(false);
  }

  protected cb func OnPlayerDetach(playerPuppet: ref<GameObject>) -> Bool {
    this.m_blackboard.UnregisterListenerVariant(GetAllBlackboardDefs().PlayerStateMachine.SecurityZoneData, this.m_securityBlackBoardID);
  }

  protected cb func OnSecurityDataChange(arg: Variant) -> Bool {
    let securityZoneData: SecurityAreaData = FromVariant(arg);
    inkWidgetRef.SetVisible(this.m_fluff_01, false);
    inkWidgetRef.SetVisible(this.m_fluff_02, false);
    inkWidgetRef.SetVisible(this.m_fluff_03, false);
    inkWidgetRef.SetVisible(this.m_fluff_04, false);
    switch securityZoneData.securityAreaType {
      case ESecurityAreaType.DANGEROUS:
        if Equals(this.m_root.GetState(), n"Dangerous") {
        } else {
          inkTextRef.SetText(this.m_label, "UI-Cyberpunk-Widgets-DANGER_ZONE");
          this.m_root.SetState(n"Dangerous");
          inkWidgetRef.SetVisible(this.m_fluff_01, true);
          inkImageRef.SetTexturePart(this.m_icon, n"danger_icon_zone");
          inkImageRef.SetTexturePart(this.m_indicator_01, n"indicator_on");
          inkImageRef.SetTexturePart(this.m_indicator_02, n"indicator_on");
          inkImageRef.SetTexturePart(this.m_indicator_03, n"indicator_on");
          this.PlayAnimation(n"outro_danger");
          this.PlaySound(n"StealthTrespassingPopup", n"OnOpen");
          goto 1247;
        };
      case ESecurityAreaType.RESTRICTED:
        if Equals(this.m_root.GetState(), n"Restricted") {
        } else {
          inkTextRef.SetText(this.m_label, "UI-Cyberpunk-Widgets-RESTRICTED_ZONE");
          this.m_root.SetState(n"Restricted");
          inkWidgetRef.SetVisible(this.m_fluff_02, true);
          inkImageRef.SetTexturePart(this.m_icon, n"estricted_icon_zone");
          inkImageRef.SetTexturePart(this.m_indicator_01, n"indicator_on");
          inkImageRef.SetTexturePart(this.m_indicator_02, n"indicator_on");
          inkImageRef.SetTexturePart(this.m_indicator_03, n"indicator_off");
          this.PlayAnimation(n"outro_restricted");
          this.PlaySound(n"StealthTrespassingPopup", n"OnOpen");
          goto 1247;
        };
      default:
        if Equals(this.m_root.GetState(), n"Public") {
        } else {
          inkTextRef.SetText(this.m_label, "UI-Cyberpunk-Widgets-PUBLIC_ZONE");
          this.m_root.SetState(n"Public");
          inkWidgetRef.SetVisible(this.m_fluff_03, true);
          inkImageRef.SetTexturePart(this.m_icon, n"public_icon_zone");
          inkImageRef.SetTexturePart(this.m_indicator_01, n"indicator_on");
          inkImageRef.SetTexturePart(this.m_indicator_02, n"indicator_off");
          inkImageRef.SetTexturePart(this.m_indicator_03, n"indicator_off");
          this.PlayAnimation(n"outro_public");
          this.PlaySound(n"StealthTrespassingPopup", n"OnOpen");
        };
    };
  }

  private final func PlayAnimation(animName: CName) -> Void {
    this.m_root.SetVisible(true);
    this.m_animationProxy = this.PlayLibraryAnimation(animName);
    this.m_animationProxy.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnOutroAnimFinished");
  }

  protected cb func OnOutroAnimFinished(anim: ref<inkAnimProxy>) -> Bool {
    this.m_root.SetVisible(false);
  }
}

public static exec func ChangeZoneIndicatorDanger(gameInstance: GameInstance) -> Void {
  let SecurityData: SecurityAreaData;
  SecurityData.securityAreaType = ESecurityAreaType.DANGEROUS;
  let player: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(gameInstance).GetLocalPlayerControlledGameObject() as PlayerPuppet;
  let Blackboard: ref<IBlackboard> = GameInstance.GetBlackboardSystem(player.GetGame()).GetLocalInstanced(player.GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
  if IsDefined(Blackboard) {
    Blackboard.SetVariant(GetAllBlackboardDefs().PlayerStateMachine.SecurityZoneData, ToVariant(SecurityData));
    Blackboard.SignalVariant(GetAllBlackboardDefs().PlayerStateMachine.SecurityZoneData);
  };
}

public static exec func ChangeZoneIndicatorSafe(gameInstance: GameInstance) -> Void {
  let SecurityData: SecurityAreaData;
  SecurityData.securityAreaType = ESecurityAreaType.SAFE;
  let player: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(gameInstance).GetLocalPlayerControlledGameObject() as PlayerPuppet;
  let Blackboard: ref<IBlackboard> = GameInstance.GetBlackboardSystem(player.GetGame()).GetLocalInstanced(player.GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
  if IsDefined(Blackboard) {
    Blackboard.SetVariant(GetAllBlackboardDefs().PlayerStateMachine.SecurityZoneData, ToVariant(SecurityData));
    Blackboard.SignalVariant(GetAllBlackboardDefs().PlayerStateMachine.SecurityZoneData);
  };
}

public static exec func ChangeZoneIndicatorRestricted(gameInstance: GameInstance) -> Void {
  let SecurityData: SecurityAreaData;
  SecurityData.securityAreaType = ESecurityAreaType.RESTRICTED;
  let player: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(gameInstance).GetLocalPlayerControlledGameObject() as PlayerPuppet;
  let Blackboard: ref<IBlackboard> = GameInstance.GetBlackboardSystem(player.GetGame()).GetLocalInstanced(player.GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
  if IsDefined(Blackboard) {
    Blackboard.SetVariant(GetAllBlackboardDefs().PlayerStateMachine.SecurityZoneData, ToVariant(SecurityData));
    Blackboard.SignalVariant(GetAllBlackboardDefs().PlayerStateMachine.SecurityZoneData);
  };
}

public static exec func ChangeZoneIndicatorPublic(gameInstance: GameInstance) -> Void {
  let SecurityData: SecurityAreaData;
  SecurityData.securityAreaType = ESecurityAreaType.DISABLED;
  let player: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(gameInstance).GetLocalPlayerControlledGameObject() as PlayerPuppet;
  let Blackboard: ref<IBlackboard> = GameInstance.GetBlackboardSystem(player.GetGame()).GetLocalInstanced(player.GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
  if IsDefined(Blackboard) {
    Blackboard.SetVariant(GetAllBlackboardDefs().PlayerStateMachine.SecurityZoneData, ToVariant(SecurityData));
    Blackboard.SignalVariant(GetAllBlackboardDefs().PlayerStateMachine.SecurityZoneData);
  };
}
