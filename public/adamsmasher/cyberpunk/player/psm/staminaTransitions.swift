
public abstract class PlayerStaminaHelpers extends IScriptable {

  public final static func GetSprintStaminaCost() -> Float {
    return TweakDBInterface.GetFloat(t"player.staminaCosts.sprint", 0.00);
  }

  public final static func GetSlideStaminaCost() -> Float {
    return TweakDBInterface.GetFloat(t"player.staminaCosts.slide", 0.00);
  }

  public final static func GetJumpStaminaCost() -> Float {
    return TweakDBInterface.GetFloat(t"player.staminaCosts.jump", 0.00);
  }

  public final static func GetDodgeStaminaCost() -> Float {
    return TweakDBInterface.GetFloat(t"player.staminaCosts.dodge", 0.00);
  }

  public final static func GetAirDodgeStaminaCost() -> Float {
    return TweakDBInterface.GetFloat(t"player.staminaCosts.airDodge", 0.00);
  }

  public final static func GetExhaustedStatusEffectID() -> TweakDBID {
    return t"BaseStatusEffect.PlayerExhausted";
  }

  public final static func GetBlockStaminaDelay() -> Float {
    return TweakDBInterface.GetFloat(t"player.staminaCosts.blockStaminaDelay", 0.00);
  }

  public final static func OnPlayerBlock(player: ref<PlayerPuppet>) -> Void {
    GameObject.StartCooldown(player, n"OnBlockStaminaCooldown", PlayerStaminaHelpers.GetBlockStaminaDelay());
  }

  public final static func ModifyStamina(player: ref<PlayerPuppet>, delta: Float, opt perc: Bool) -> Void {
    let canIgnoreStamina: Bool;
    let isExhausted: Bool;
    if IsDefined(player) {
      isExhausted = StatusEffectSystem.ObjectHasStatusEffect(player, PlayerStaminaHelpers.GetExhaustedStatusEffectID());
      canIgnoreStamina = RPGManager.HasStatFlag(player, gamedataStatType.CanIgnoreStamina);
      if delta > 0.00 || delta < 0.00 && !isExhausted && !canIgnoreStamina {
        GameInstance.GetStatPoolsSystem(player.GetGame()).RequestChangingStatPoolValue(Cast(player.GetEntityID()), gamedataStatPoolType.Stamina, delta, null, false, perc);
      };
    };
  }
}

public abstract class StaminaTransition extends DefaultTransition {

  public let staminaChangeToggle: Bool;

  protected final const func ShouldRegenStamina(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let meleeState: Int32 = scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Melee);
    let meleeWeaponState: Int32 = scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.MeleeWeapon);
    let locomotionState: Int32 = scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.LocomotionDetailed);
    let staminaState: Int32 = scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Stamina);
    if staminaState == EnumInt(gamePSMStamina.Exhausted) {
      return true;
    };
    if scriptInterface.HasStatFlag(gamedataStatType.CanIgnoreStamina) {
      return true;
    };
    if meleeState == EnumInt(gamePSMMelee.Attack) {
      return false;
    };
    if meleeWeaponState == EnumInt(gamePSMMeleeWeapon.ChargedHold) {
      return false;
    };
    if locomotionState == EnumInt(gamePSMDetailedLocomotionStates.Dodge) || locomotionState == EnumInt(gamePSMDetailedLocomotionStates.Slide) || locomotionState == EnumInt(gamePSMDetailedLocomotionStates.DodgeAir) || locomotionState == EnumInt(gamePSMDetailedLocomotionStates.VeryHardLand) {
      return false;
    };
    if GameObject.IsCooldownActive(scriptInterface.owner, n"OnBlockStaminaCooldown") {
      return false;
    };
    return true;
  }

  protected final func EnableStaminaPoolRegen(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>, enable: Bool) -> Void {
    let staminaCost: Float = 0.10;
    if !enable {
      if this.staminaChangeToggle {
        staminaCost = staminaCost * -1.00;
      };
      this.staminaChangeToggle = !this.staminaChangeToggle;
      PlayerStaminaHelpers.ModifyStamina(scriptInterface.executionOwner as PlayerPuppet, staminaCost, true);
    };
  }

  protected final func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let shouldRegenStamina: Bool = true;
    shouldRegenStamina = this.ShouldRegenStamina(stateContext, scriptInterface);
    this.EnableStaminaPoolRegen(stateContext, scriptInterface, shouldRegenStamina);
  }
}

public class RestedEvents extends StaminaEventsTransition {

  protected final func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Stamina, EnumInt(gamePSMStamina.Rested));
    StatusEffectHelper.RemoveStatusEffect(scriptInterface.executionOwner, PlayerStaminaHelpers.GetExhaustedStatusEffectID());
  }
}

public class ExhaustedDecisions extends StaminaTransition {

  protected final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let player: ref<PlayerPuppet> = scriptInterface.executionOwner as PlayerPuppet;
    let currentStamina: Float = player.GetStaminaValueUnsafe();
    if currentStamina <= 1.00 {
      return true;
    };
    return false;
  }

  protected final const func ExitCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let player: ref<PlayerPuppet> = scriptInterface.executionOwner as PlayerPuppet;
    let currentStaminaPerc: Float = player.GetStaminaPercUnsafe();
    if currentStaminaPerc >= 100.00 || scriptInterface.GetStatusEffectSystem().HasStatusEffectOfType(scriptInterface.executionOwnerEntityID, gamedataStatusEffectType.Berserk) {
      return true;
    };
    return false;
  }
}

public class ExhaustedEvents extends StaminaEventsTransition {

  public let m_staminaVfxBlackboard: ref<worldEffectBlackboard>;

  protected final func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let animFeature: ref<AnimFeature_Stamina>;
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Stamina, EnumInt(gamePSMStamina.Exhausted));
    StatusEffectHelper.ApplyStatusEffect(scriptInterface.executionOwner, PlayerStaminaHelpers.GetExhaustedStatusEffectID());
    this.m_staminaVfxBlackboard = new worldEffectBlackboard();
    if IsDefined(this.m_staminaVfxBlackboard) {
      this.m_staminaVfxBlackboard.SetValue(n"alpha", 1.00);
      GameObjectEffectHelper.StartEffectEvent(scriptInterface.executionOwner, n"status_tired", false, this.m_staminaVfxBlackboard);
    };
    animFeature = new AnimFeature_Stamina();
    animFeature.staminaValue = 0.00;
    animFeature.tiredness = 1.00;
    AnimationControllerComponent.ApplyFeature(scriptInterface.executionOwner, n"StaminaData", animFeature);
  }

  protected final func HandleExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    GameObjectEffectHelper.StopEffectEvent(scriptInterface.executionOwner, n"status_tired");
    this.m_staminaVfxBlackboard = null;
    AnimationControllerComponent.ApplyFeature(scriptInterface.executionOwner, n"StaminaData", new AnimFeature_Stamina());
    StatusEffectHelper.RemoveStatusEffect(scriptInterface.executionOwner, PlayerStaminaHelpers.GetExhaustedStatusEffectID());
  }

  protected final func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.HandleExit(stateContext, scriptInterface);
  }

  protected final func OnForcedExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.HandleExit(stateContext, scriptInterface);
  }
}
