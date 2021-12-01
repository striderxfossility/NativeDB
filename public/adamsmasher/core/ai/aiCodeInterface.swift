
public abstract class AICodeInterface extends IScriptable {

  public final static func CheckSlotsForEquipment(context: script_ref<ScriptExecutionContext>, puppet: ref<gamePuppet>, equipmentGroup: CName) -> AIbehaviorConditionOutcomes {
    let scriptedPuppet: ref<ScriptedPuppet> = puppet as ScriptedPuppet;
    if AIActionTransactionSystem.ShouldPerformEquipmentCheck(scriptedPuppet, equipmentGroup) {
      if !AIActionTransactionSystem.CheckSlotsForEquipment(Deref(context), equipmentGroup) {
        return AIbehaviorConditionOutcomes.False;
      };
      return AIbehaviorConditionOutcomes.True;
    };
    return AIbehaviorConditionOutcomes.Failure;
  }

  public final static func GetLastRequestedTriggerMode(weapon: ref<WeaponObject>) -> gamedataTriggerMode {
    return AIActionHelper.GetLastRequestedTriggerMode(weapon);
  }
}
