
public class DamageManager extends IScriptable {

  public final static func ModifyHitData(hitEvent: ref<gameHitEvent>) -> Void {
    let attackType: gamedataAttackType;
    let chargeVal: Float;
    let attackData: ref<AttackData> = hitEvent.attackData;
    let statusEffectsSystem: ref<StatusEffectSystem> = GameInstance.GetStatusEffectSystem(hitEvent.target.GetGame());
    let statPoolSystem: ref<StatPoolsSystem> = GameInstance.GetStatPoolsSystem(hitEvent.target.GetGame());
    if !IsDefined(DamageManager.GetScriptedPuppetTarget(hitEvent)) {
      LogAI("No scripted puppet has been found /!\\");
      return;
    };
    if ArraySize(hitEvent.hitRepresentationResult.hitShapes) > 0 && DamageSystemHelper.IsProtectionLayer(DamageSystemHelper.GetHitShape(hitEvent)) {
      attackData.AddFlag(hitFlag.DamageNullified, n"ProtectionLayer");
    };
    if IsDefined(attackData.GetWeapon()) && GameInstance.GetStatsSystem(hitEvent.target.GetGame()).GetStatValue(Cast(attackData.GetWeapon().GetEntityID()), gamedataStatType.CanSilentKill) > 0.00 {
      attackData.AddFlag(hitFlag.SilentKillModifier, n"CanSilentKill");
    };
    if attackData.GetInstigator().IsPlayer() {
      if !AttackData.IsPlayerInCombat(attackData) {
        attackData.AddFlag(hitFlag.StealthHit, n"Player attacked from out of combat");
      };
    };
    if statusEffectsSystem.HasStatusEffect(hitEvent.target.GetEntityID(), t"BaseStatusEffect.Defeated") {
      attackData.AddFlag(hitFlag.Defeated, n"Defeated");
    };
    if statPoolSystem.HasActiveStatPool(Cast(attackData.GetWeapon().GetEntityID()), gamedataStatPoolType.WeaponCharge) {
      chargeVal = statPoolSystem.GetStatPoolValue(Cast(attackData.GetWeapon().GetEntityID()), gamedataStatPoolType.WeaponCharge, false);
      if chargeVal >= 100.00 {
        attackData.AddFlag(hitFlag.WeaponFullyCharged, n"Charge Weapon");
      };
    };
    if AttackData.IsMelee(attackType) && chargeVal > 0.00 {
      if !AttackData.IsStrongMelee(attackType) {
        chargeVal = MinF(chargeVal, 20.00);
      };
      hitEvent.attackComputed.MultAttackValue(LerpF(chargeVal / 100.00, 1.00, 2.00));
      attackData.AddFlag(hitFlag.DoNotTriggerFinisher, n"Charge Weapon");
    };
    if !AttackData.IsBullet(attackType) && !AttackData.IsExplosion(attackType) {
      DamageManager.ProcessDefensiveState(hitEvent);
    };
    return;
  }

  public final static func IsValidDirectionToDefendMeleeAttack(attackerForward: Vector4, defenderForward: Vector4) -> Bool {
    let finalHitDirection: Float = Vector4.GetAngleBetween(attackerForward, defenderForward);
    return finalHitDirection < 180.00;
  }

  private final static func ProcessDefensiveState(hitEvent: ref<gameHitEvent>) -> Void {
    let attackType: gamedataAttackType;
    let attackData: ref<AttackData> = hitEvent.attackData;
    let targetID: StatsObjectID = Cast(hitEvent.target.GetEntityID());
    let attackSource: wref<GameObject> = attackData.GetSource();
    let hitAIEvent: ref<AIEvent> = new AIEvent();
    let statSystem: ref<StatsSystem> = GameInstance.GetStatsSystem(hitEvent.target.GetGame());
    if AttackData.IsMelee(hitEvent.attackData.GetAttackType()) && (statSystem.GetStatValue(targetID, gamedataStatType.IsBlocking) == 1.00 || statSystem.GetStatValue(targetID, gamedataStatType.IsDeflecting) == 1.00) {
      if DamageManager.IsValidDirectionToDefendMeleeAttack(attackSource.GetWorldForward(), hitEvent.target.GetWorldForward()) {
        attackType = attackData.GetAttackType();
        if statSystem.GetStatValue(targetID, gamedataStatType.IsDeflecting) == 1.00 && NotEquals(attackType, gamedataAttackType.QuickMelee) {
          attackData.AddFlag(hitFlag.WasDeflected, n"Parry");
          AnimationControllerComponent.PushEvent(attackSource, n"myAttackParried");
          hitAIEvent.name = n"MyAttackParried";
          attackSource.QueueEvent(hitAIEvent);
          if hitEvent.target.IsPlayer() {
            DamageManager.SendNameEventToPSM(n"successfulDeflect", hitEvent);
          };
        } else {
          if statSystem.GetStatValue(targetID, gamedataStatType.IsBlocking) == 1.00 || statSystem.GetStatValue(targetID, gamedataStatType.IsDeflecting) == 1.00 && Equals(attackType, gamedataAttackType.QuickMelee) {
            attackData.AddFlag(hitFlag.WasBlocked, n"Block");
            AnimationControllerComponent.PushEvent(attackSource, n"myAttackBlocked");
            ScriptedPuppet.SendActionSignal(attackSource as NPCPuppet, n"BlockSignal", 0.30);
            hitAIEvent.name = n"MyAttackBlocked";
            attackSource.QueueEvent(hitAIEvent);
            DamageManager.DealStaminaDamage(hitEvent, targetID, statSystem);
          };
        };
      };
    } else {
      ScriptedPuppet.SendActionSignal(attackSource as NPCPuppet, n"HitSignal", 0.30);
      hitAIEvent.name = n"MyAttackHit";
      attackSource.QueueEvent(hitAIEvent);
    };
  }

  protected final static func SendNameEventToPSM(eventName: CName, hitEvent: ref<gameHitEvent>) -> Void {
    let player: ref<PlayerPuppet> = hitEvent.target as PlayerPuppet;
    let es: ref<EquipmentSystem> = GameInstance.GetScriptableSystemsContainer(player.GetGame()).Get(n"EquipmentSystem") as EquipmentSystem;
    let playerWeapon: ref<ItemObject> = es.GetActiveWeaponObject(player, gamedataEquipmentArea.Weapon);
    let psmEvent: ref<PSMPostponedParameterBool> = new PSMPostponedParameterBool();
    psmEvent.id = eventName;
    psmEvent.value = true;
    player.QueueEvent(psmEvent);
    player.QueueEventForEntityID(playerWeapon.GetEntityID(), psmEvent);
  }

  public final static func PostProcess(hitEvent: ref<gameHitEvent>) -> Void;

  public final static func CalculateSourceModifiers(hitEvent: ref<gameHitEvent>) -> Void {
    let tempStat: Float;
    if (hitEvent.target as ScriptedPuppet).IsMechanical() || hitEvent.target.IsTurret() {
      tempStat = GameInstance.GetStatsSystem(hitEvent.target.GetGame()).GetStatValue(Cast(hitEvent.attackData.GetInstigator().GetEntityID()), gamedataStatType.BonusDamageAgainstMechanicals);
      if !FloatIsEqual(tempStat, 0.00) {
        hitEvent.attackComputed.MultAttackValue(1.00 + tempStat);
      };
    };
    if hitEvent.attackData.GetInstigator().IsPlayer() {
      if Equals((hitEvent.target as ScriptedPuppet).GetNPCRarity(), gamedataNPCRarity.Elite) {
        tempStat = GameInstance.GetStatsSystem(hitEvent.target.GetGame()).GetStatValue(Cast(hitEvent.attackData.GetInstigator().GetEntityID()), gamedataStatType.BonusDamageAgainstElites);
        if !FloatIsEqual(tempStat, 0.00) {
          hitEvent.attackComputed.MultAttackValue(1.00 + tempStat);
        };
      };
      if AttackData.IsMelee(hitEvent.attackData.GetAttackType()) && StatusEffectSystem.ObjectHasStatusEffect(hitEvent.attackData.GetInstigator(), t"BaseStatusEffect.BerserkPlayerBuff") {
        tempStat = GameInstance.GetStatsSystem(hitEvent.target.GetGame()).GetStatValue(Cast(hitEvent.attackData.GetInstigator().GetEntityID()), gamedataStatType.BerserkMeleeDamageBonus);
        if !FloatIsEqual(tempStat, 0.00) {
          hitEvent.attackComputed.MultAttackValue(1.00 + tempStat * 0.01);
        };
      };
    };
  }

  public final static func CalculateTargetModifiers(hitEvent: ref<gameHitEvent>) -> Void {
    let tempStat: Float;
    if AttackData.IsExplosion(hitEvent.attackData.GetAttackType()) {
      tempStat = tempStat = GameInstance.GetStatsSystem(hitEvent.target.GetGame()).GetStatValue(Cast(hitEvent.target.GetEntityID()), gamedataStatType.DamageReductionExplosion);
      if !FloatIsEqual(tempStat, 0.00) {
        hitEvent.attackComputed.MultAttackValue(1.00 - tempStat);
      };
    };
    if AttackData.IsDoT(hitEvent.attackData.GetAttackType()) {
      tempStat = tempStat = GameInstance.GetStatsSystem(hitEvent.target.GetGame()).GetStatValue(Cast(hitEvent.target.GetEntityID()), gamedataStatType.DamageReductionDamageOverTime);
      if !FloatIsEqual(tempStat, 0.00) {
        hitEvent.attackComputed.MultAttackValue(1.00 - tempStat);
      };
    };
  }

  public final static func CalculateGlobalModifiers(hitEvent: ref<gameHitEvent>) -> Void;

  private final static func GetScriptedPuppetTarget(hitEvent: ref<gameHitEvent>) -> ref<ScriptedPuppet> {
    return hitEvent.target as ScriptedPuppet;
  }

  protected final static func DealStaminaDamage(hitEvent: ref<gameHitEvent>, targetID: StatsObjectID, statSystem: ref<StatsSystem>) -> Void {
    let weapon: ref<WeaponObject> = hitEvent.attackData.GetWeapon();
    let staminaDamageValue: Float = statSystem.GetStatValue(Cast(weapon.GetEntityID()), gamedataStatType.StaminaDamage);
    GameInstance.GetStatPoolsSystem(hitEvent.target.GetGame()).RequestChangingStatPoolValue(targetID, gamedataStatPoolType.Stamina, -staminaDamageValue, hitEvent.attackData.GetInstigator(), false, false);
  }
}
