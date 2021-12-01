
public native class Muppet extends gamePuppetBase {

  private let m_hitRepresantation: ref<SlotComponent>;

  private let m_slotComponent: ref<SlotComponent>;

  public let m_highDamageThreshold: Float;

  public let m_medDamageThreshold: Float;

  public let m_lowDamageThreshold: Float;

  public let m_effectTimeStamp: Float;

  public final native const func GetAttitude() -> ref<AttitudeAgent>;

  public final native const func IsMuppetIncapacitated() -> Bool;

  public final native const func GetItemQuantity(itemId: ItemID) -> Int32;

  public const func GetAttitudeAgent() -> ref<AttitudeAgent> {
    return this.GetAttitude();
  }

  public final const func GetHitRepresantationSlotComponent() -> ref<SlotComponent> {
    return this.m_hitRepresantation;
  }

  public final const func GetSlotComponent() -> ref<SlotComponent> {
    return this.m_slotComponent;
  }

  public const func IsPlayer() -> Bool {
    return true;
  }

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    EntityRequestComponentsInterface.RequestComponent(ri, n"HitRepresentation", n"SlotComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"Item_Attachment_Slot", n"SlotComponent", false);
    super.OnRequestComponents(ri);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    this.m_hitRepresantation = EntityResolveComponentsInterface.GetComponent(ri, n"HitRepresentation") as SlotComponent;
    this.m_slotComponent = EntityResolveComponentsInterface.GetComponent(ri, n"Item_Attachment_Slot") as SlotComponent;
    super.OnTakeControl(ri);
  }

  public const func IsIncapacitated() -> Bool {
    return this.IsMuppetIncapacitated();
  }

  private final func GetDamageThresholdParams() -> Void {
    this.m_highDamageThreshold = TweakDBInterface.GetFloat(t"player.damageThresholds.highDamageThreshold", 40.00);
    this.m_medDamageThreshold = TweakDBInterface.GetFloat(t"player.damageThresholds.medDamageThreshold", 20.00);
    this.m_lowDamageThreshold = TweakDBInterface.GetFloat(t"player.damageThresholds.lowDamageThreshold", 1.00);
  }

  private func OnHitVFX(hitEvent: ref<gameHitEvent>) -> Void {
    let currentHitStamp: Float;
    let damageDealt: Float;
    let effectDelay: Float;
    if IsClient() && this.IsControlledByLocalPeer() || !IsMultiplayer() {
      damageDealt = hitEvent.attackComputed.GetTotalAttackValue(gamedataStatPoolType.Health);
      this.GetDamageThresholdParams();
      effectDelay = TweakDBInterface.GetFloat(t"player.hitVFX.delay", 0.40);
      currentHitStamp = EngineTime.ToFloat(GameInstance.GetSimTime(this.GetGame()));
      if currentHitStamp - effectDelay >= this.m_effectTimeStamp {
        if damageDealt <= 0.00 {
          return;
        };
        if damageDealt >= this.m_highDamageThreshold {
          GameObjectEffectHelper.StartEffectEvent(this, n"fx_damage_high");
        } else {
          if damageDealt >= this.m_medDamageThreshold {
            GameObjectEffectHelper.StartEffectEvent(this, n"fx_damage_medium");
          } else {
            if damageDealt >= this.m_lowDamageThreshold {
              GameObjectEffectHelper.StartEffectEvent(this, n"fx_damage_low");
            };
          };
        };
        this.m_effectTimeStamp = EngineTime.ToFloat(GameInstance.GetSimTime(this.GetGame()));
      };
    };
  }

  private final func OnHitSounds(hitEvent: ref<gameHitEvent>) -> Void {
    let damageSwitch: ref<SoundSwitchEvent>;
    let damageValue: Float;
    let forwardLocalToWorldAngle: Float;
    let hitDirection: Vector4;
    let playerOutOfOxygen: Bool;
    let soundEvent: ref<SoundPlayEvent>;
    let soundParamAxisX: ref<SoundParameterEvent>;
    let soundParamAxisY: ref<SoundParameterEvent>;
    let target: ref<GameObject>;
    this.OnHitSounds(hitEvent);
    if IsServer() {
      if GameInstance.GetStatPoolsSystem(this.GetGame()).GetStatPoolValue(Cast(this.GetEntityID()), gamedataStatPoolType.Health) < 30.00 {
        ChatterHelper.PlayCpoServerSyncVoiceOver(this, n"cpo_nearly_dead");
      };
      if GameInstance.GetStatPoolsSystem(this.GetGame()).GetStatPoolValue(Cast(this.GetEntityID()), gamedataStatPoolType.CPO_Armor) == 0.00 {
        ChatterHelper.PlayCpoServerSyncVoiceOver(this, n"cpo_armor_broken");
      };
      return;
    };
    playerOutOfOxygen = hitEvent.attackData.GetAttackDefinition().GetRecord().GetID() == t"Attacks.OutOfOxygenDamageOverTime";
    if playerOutOfOxygen {
      return;
    };
    soundEvent = new SoundPlayEvent();
    damageSwitch = new SoundSwitchEvent();
    soundParamAxisX = new SoundParameterEvent();
    soundParamAxisY = new SoundParameterEvent();
    target = hitEvent.target;
    forwardLocalToWorldAngle = Vector4.Heading(target.GetWorldForward());
    hitDirection = Vector4.RotByAngleXY(hitEvent.hitDirection, forwardLocalToWorldAngle);
    soundParamAxisX.parameterName = n"RTPC_Positioning_2D_LR_axis";
    soundParamAxisX.parameterValue = hitDirection.X * 100.00;
    soundParamAxisY.parameterName = n"RTPC_Positioning_2D_FB_axis";
    soundParamAxisY.parameterValue = hitDirection.Y * 100.00;
    target.QueueEvent(soundParamAxisX);
    target.QueueEvent(soundParamAxisY);
    damageSwitch.switchName = n"SW_Impact_Velocity";
    damageValue = hitEvent.attackComputed.GetTotalAttackValue(gamedataStatPoolType.Health);
    if damageValue >= this.m_highDamageThreshold {
      damageSwitch.switchValue = n"SW_Impact_Velocity_Hi";
    } else {
      if damageValue >= this.m_medDamageThreshold {
        damageSwitch.switchValue = n"SW_Impact_Velocity_Med";
      } else {
        if damageValue >= this.m_lowDamageThreshold {
          damageSwitch.switchValue = n"SW_Impact_Velocity_Low";
        };
      };
    };
    target.QueueEvent(damageSwitch);
    GameObject.PlayVoiceOver(this, n"onPlayerHit", n"Scripts:OnHitSounds");
    if !hitEvent.attackData.GetWeapon().GetItemData().HasTag(WeaponObject.GetMeleeWeaponTag()) {
      soundEvent.soundName = n"w_feedback_player_damage";
      target.QueueEvent(soundEvent);
    };
    if IsClient() && this.IsControlledByLocalPeer() && GameInstance.GetStatPoolsSystem(this.GetGame()).GetStatPoolValue(Cast(this.GetEntityID()), gamedataStatPoolType.CPO_Armor) == 0.00 {
      soundEvent.soundName = n"test_ad_emitter_2_1";
      target.QueueEvent(soundEvent);
    };
  }
}
