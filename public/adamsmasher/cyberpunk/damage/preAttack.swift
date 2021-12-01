
public class EffectPreAction_PreAttack extends EffectPreAction_Scripted {

  @default(EffectPreAction_PreAttack, false)
  @default(EffectPreAction_PreAttack_WithFriendlyFire, true)
  protected edit let m_withFriendlyFire: Bool;

  @default(EffectPreAction_PreAttack, false)
  @default(EffectPreAction_PreAttack_WithFriendlyFire, true)
  protected edit let m_withSelfDamage: Bool;

  public final const func Process(ctx: EffectScriptContext) -> Void {
    let TEMP_recordFlags: array<String>;
    let attackPosition: Vector4;
    let attackSource: ref<IAttack>;
    let effects: array<SHitStatusEffect>;
    let i: Int32;
    let newFlags: array<SHitFlag>;
    let tempFlag: hitFlag;
    let tempVariant: Variant;
    let weaponCharge: Float;
    let weaponObject: ref<WeaponObject>;
    let data: ref<AttackData> = new AttackData();
    data.SetInstigator(EffectScriptContext.GetInstigator(ctx) as GameObject);
    data.SetSource(EffectScriptContext.GetSource(ctx) as GameObject);
    if EffectData.GetVector(EffectScriptContext.GetSharedData(ctx), GetAllBlackboardDefs().EffectSharedData.position, attackPosition) {
      data.SetAttackPosition(attackPosition);
    };
    if EffectData.GetVariant(EffectScriptContext.GetSharedData(ctx), GetAllBlackboardDefs().EffectSharedData.attack, tempVariant) {
      attackSource = FromVariant(tempVariant);
    };
    if EffectData.GetFloat(EffectScriptContext.GetSharedData(ctx), GetAllBlackboardDefs().EffectSharedData.charge, weaponCharge) {
      data.SetWeaponCharge(weaponCharge);
    };
    weaponObject = EffectScriptContext.GetWeapon(ctx) as WeaponObject;
    if IsDefined(weaponObject) {
      data.SetWeapon(weaponObject);
    };
    if IsDefined(attackSource) {
      data.SetAttackDefinition(attackSource);
    } else {
      if IsDefined(weaponObject) {
        data.SetAttackDefinition(weaponObject.GetCurrentAttack());
      };
    };
    TEMP_recordFlags = data.GetAttackDefinition().GetRecord().HitFlags();
    i = 0;
    while i < ArraySize(TEMP_recordFlags) {
      tempFlag = IntEnum(Cast(EnumValueFromString("hitFlag", TEMP_recordFlags[i])));
      if EnumInt(tempFlag) > -1 {
        data.AddFlag(tempFlag, n"PreAttack");
      };
      i += 1;
    };
    EffectData.GetVariant(EffectScriptContext.GetSharedData(ctx), GetAllBlackboardDefs().EffectSharedData.flags, tempVariant);
    if VariantIsValid(tempVariant) {
      newFlags = FromVariant(tempVariant);
    };
    i = 0;
    while i < ArraySize(newFlags) {
      data.AddFlag(newFlags[i].flag, n"PreAttack");
      i += 1;
    };
    if this.m_withFriendlyFire {
      data.AddFlag(hitFlag.FriendlyFire, n"PreAttack");
    };
    if this.m_withSelfDamage {
      data.AddFlag(hitFlag.CanDamageSelf, n"PreAttack");
    };
    if EffectData.GetVariant(EffectScriptContext.GetSharedData(ctx), GetAllBlackboardDefs().EffectSharedData.statusEffect, tempVariant) {
      effects = FromVariant(tempVariant);
    };
    i = 0;
    while i < ArraySize(effects) {
      data.AddStatusEffect(effects[i].id, effects[i].stacks);
      i += 1;
    };
    data.PreAttack();
    EffectData.SetVariant(EffectScriptContext.GetSharedData(ctx), GetAllBlackboardDefs().EffectSharedData.attackData, ToVariant(data));
  }
}
