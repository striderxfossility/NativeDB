
public class RemoveStatusEffectsEffector extends Effector {

  private let m_effectTypes: array<String>;

  private let m_effectString: array<String>;

  private let m_effectTags: array<CName>;

  protected func Initialize(record: TweakDBID, game: GameInstance, parentRecord: TweakDBID) -> Void {
    this.m_effectString = TDB.GetStringArray(record + t".statusEffects");
    this.m_effectTypes = TDB.GetStringArray(record + t".effectTypes");
    this.m_effectTags = TDB.GetCNameArray(record + t".effectTypes");
  }

  protected func ActionOn(owner: ref<GameObject>) -> Void {
    let type: gamedataStatusEffectType;
    let i: Int32 = 0;
    while i < ArraySize(this.m_effectString) {
      StatusEffectHelper.RemoveStatusEffect(owner, TDBID.Create(this.m_effectString[i]));
      i += 1;
    };
    i = 0;
    while i < ArraySize(this.m_effectTypes) {
      type = IntEnum(Cast(EnumValueFromString("gamedataStatusEffectType", this.m_effectTypes[i])));
      if NotEquals(type, gamedataStatusEffectType.Invalid) {
        StatusEffectHelper.RemoveAllStatusEffectsByType(owner, type);
      };
      i += 1;
    };
    i = 0;
    while i < ArraySize(this.m_effectTags) {
      StatusEffectHelper.RemoveStatusEffectsWithTag(owner, this.m_effectTags[i]);
      i += 1;
    };
  }
}

public class RemoveDOTStatusEffectsEffector extends Effector {

  protected let m_ownerEntityID: EntityID;

  protected let m_delay: Float;

  protected func Initialize(record: TweakDBID, game: GameInstance, parentRecord: TweakDBID) -> Void {
    this.m_delay = TDB.GetFloat(record + t".delay");
  }

  protected func ActionOn(owner: ref<GameObject>) -> Void {
    this.m_ownerEntityID = owner.GetEntityID();
    if IsDefined(owner) && this.m_delay >= 0.00 {
      StatusEffectHelper.RemoveStatusEffectsWithTag(owner, n"DoT", this.m_delay);
    };
  }

  protected func Uninitialize(game: GameInstance) -> Void {
    if EntityID.IsDefined(this.m_ownerEntityID) && this.m_delay < 0.00 {
      StatusEffectHelper.RemoveStatusEffectsWithTag(game, this.m_ownerEntityID, n"DoT");
    };
  }
}
