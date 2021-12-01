
public class ModifyStatPoolModifierEffector extends Effector {

  public let m_owner: wref<GameObject>;

  public let m_ownerEntityID: EntityID;

  public let m_poolModifier: StatPoolModifier;

  public let m_poolType: gamedataStatPoolType;

  public let m_modType: gameStatPoolModificationTypes;

  public let m_previousMod: StatPoolModifier;

  protected func Initialize(record: TweakDBID, game: GameInstance, parentRecord: TweakDBID) -> Void {
    let poolModRecord: ref<PoolValueModifier_Record> = TweakDBInterface.GetPoolValueModifierRecord(TweakDBInterface.GetModifyStatPoolModifierEffectorRecord(record).PoolModifier().GetID());
    this.m_poolModifier.enabled = poolModRecord.Enabled();
    this.m_poolModifier.rangeBegin = poolModRecord.RangeBegin();
    this.m_poolModifier.rangeEnd = poolModRecord.RangeEnd();
    this.m_poolModifier.startDelay = poolModRecord.StartDelay();
    this.m_poolModifier.valuePerSec = poolModRecord.ValuePerSec();
    this.m_poolModifier.delayOnChange = poolModRecord.DelayOnChange();
    this.m_poolType = IntEnum(Cast(EnumValueFromString("gamedataStatPoolType", TweakDBInterface.GetString(record + t".statPoolType", ""))));
    this.m_modType = IntEnum(Cast(EnumValueFromString("gameStatPoolModificationTypes", TweakDBInterface.GetString(record + t".modificationType", ""))));
  }

  protected func Uninitialize(game: GameInstance) -> Void {
    this.RevertPoolModifier(game);
  }

  protected func ActionOn(owner: ref<GameObject>) -> Void {
    this.m_owner = owner;
    this.m_ownerEntityID = owner.GetEntityID();
    let poolSys: ref<StatPoolsSystem> = GameInstance.GetStatPoolsSystem(owner.GetGame());
    poolSys.GetModifier(Cast(this.m_ownerEntityID), this.m_poolType, this.m_modType, this.m_previousMod);
    poolSys.RequestSettingModifier(Cast(this.m_ownerEntityID), this.m_poolType, this.m_modType, this.m_poolModifier);
  }

  protected func ActionOff(owner: ref<GameObject>) -> Void {
    this.RevertPoolModifier(owner.GetGame());
  }

  private final func RevertPoolModifier(gameInstance: GameInstance) -> Void {
    let emptyModifier: StatPoolModifier;
    let statPoolsSystem: ref<StatPoolsSystem> = GameInstance.GetStatPoolsSystem(gameInstance);
    if IsDefined(this.m_owner) && this.m_owner.IsAttached() {
      if this.m_owner.IsPlayer() && Equals(this.m_poolType, gamedataStatPoolType.Health) {
        if (this.m_owner as PlayerPuppet).IsInCombat() {
          statPoolsSystem.RequestSettingModifierWithRecord(Cast(this.m_ownerEntityID), gamedataStatPoolType.Health, gameStatPoolModificationTypes.Regeneration, t"BaseStatPools.PlayerBaseInCombatHealthRegen");
        } else {
          statPoolsSystem.RequestSettingModifierWithRecord(Cast(this.m_ownerEntityID), gamedataStatPoolType.Health, gameStatPoolModificationTypes.Regeneration, t"BaseStatPools.PlayerBaseOutOfCombatHealthRegen");
        };
      } else {
        if this.m_owner.IsPlayer() && (this.m_owner as PlayerPuppet).IsInCombat() {
          statPoolsSystem.RequestSettingModifier(Cast(this.m_ownerEntityID), this.m_poolType, this.m_modType, emptyModifier);
        } else {
          statPoolsSystem.RequestResetingModifier(Cast(this.m_ownerEntityID), this.m_poolType, this.m_modType);
        };
      };
    } else {
      statPoolsSystem.RequestResetingModifier(Cast(this.m_ownerEntityID), this.m_poolType, this.m_modType);
    };
  }
}
