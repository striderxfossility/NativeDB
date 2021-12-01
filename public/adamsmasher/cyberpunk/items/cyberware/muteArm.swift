
public class MuteArm extends WeaponObject {

  private edit let m_gameEffectRef: EffectRef;

  private let gameEffectInstance: ref<EffectInstance>;

  protected cb func OnChargeStartedEvent(evt: ref<ChargeStartedEvent>) -> Bool {
    let player: ref<PlayerPuppet>;
    this.SetUpMuteArmBlackboard(true);
    player = GetPlayer(this.GetGame());
    this.gameEffectInstance = GameInstance.GetGameEffectSystem(this.GetGame()).CreateEffect(this.m_gameEffectRef, player, this);
    EffectData.SetFloat(this.gameEffectInstance.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.radius, 4.00);
    this.gameEffectInstance.AttachToEntity(player, GetAllBlackboardDefs().EffectSharedData.position);
    this.gameEffectInstance.Run();
    this.ChangeAppearance(n"green");
  }

  protected cb func OnChargeEndedEvent(evt: ref<ChargeEndedEvent>) -> Bool {
    if IsDefined(this.gameEffectInstance) {
      this.gameEffectInstance.Terminate();
      this.ChangeAppearance(n"default");
    };
  }

  protected final func ChangeAppearance(newAppearance: CName) -> Void {
    let evt: ref<entAppearanceEvent> = new entAppearanceEvent();
    evt.appearanceName = newAppearance;
    this.QueueEvent(evt);
  }

  protected final func SetUpMuteArmBlackboard(enabled: Bool) -> Void {
    let blackboardSystem: ref<BlackboardSystem> = GameInstance.GetBlackboardSystem(this.GetGame());
    let blackboard: ref<IBlackboard> = blackboardSystem.Get(GetAllBlackboardDefs().CW_MuteArm);
    if enabled {
      blackboard.SetBool(GetAllBlackboardDefs().CW_MuteArm.MuteArmActive, true, true);
      blackboard.SetFloat(GetAllBlackboardDefs().CW_MuteArm.MuteArmRadius, 4.00, true);
    } else {
      blackboard.SetBool(GetAllBlackboardDefs().CW_MuteArm.MuteArmActive, false, true);
      blackboard.SetFloat(GetAllBlackboardDefs().CW_MuteArm.MuteArmRadius, 0.00, true);
    };
  }
}
