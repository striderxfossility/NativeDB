
public abstract class AITimeoutCondition extends AITimeCondition {

  protected let m_timestamp: Float;

  protected func Check(context: ScriptExecutionContext) -> AIbehaviorConditionOutcomes {
    if this.m_timestamp < 0.00 {
      return Cast(true);
    };
    return Cast(AIBehaviorScriptBase.GetAITime(context) < this.m_timestamp);
  }

  protected func Activate(context: ScriptExecutionContext) -> Void {
    this.UpdateTimeStamp(context);
  }

  protected final func UpdateTimeStamp(context: ScriptExecutionContext) -> Void {
    let timeoutValue: Float = this.GetTimeoutValue(context);
    if timeoutValue >= 0.00 {
      this.m_timestamp = AIBehaviorScriptBase.GetAITime(context) + timeoutValue;
    } else {
      this.m_timestamp = -1.00;
    };
  }

  protected func GetTimeoutValue(context: ScriptExecutionContext) -> Float {
    return 0.00;
  }
}

public class SelectorTimeout extends AITimeoutCondition {

  protected func GetTimeoutValue(context: ScriptExecutionContext) -> Float {
    return 0.10;
  }
}

public class MappingTimeout extends AITimeoutCondition {

  public inline edit let m_timeoutMapping: ref<AIArgumentMapping>;

  protected let m_timeoutValue: Float;

  protected func GetTimeoutValue(context: ScriptExecutionContext) -> Float {
    if IsDefined(this.m_timeoutMapping) {
      this.m_timeoutValue = FromVariant(ScriptExecutionContext.GetMappingValue(context, this.m_timeoutMapping));
    };
    return this.m_timeoutValue;
  }
}

public class CustomValueTimeout extends AITimeoutCondition {

  public edit let m_timeoutValue: Float;

  protected func GetTimeoutValue(context: ScriptExecutionContext) -> Float {
    return this.m_timeoutValue;
  }
}

public class CustomValueFromMappingTimeout extends AITimeoutCondition {

  public inline edit let m_actionTweakIDMapping: ref<AIArgumentMapping>;

  protected func GetTimeoutValue(context: ScriptExecutionContext) -> Float {
    return FromVariant(ScriptExecutionContext.GetMappingValue(context, this.m_actionTweakIDMapping));
  }
}

public class CharParamTimeout extends AITimeoutCondition {

  public edit let m_timeoutParamName: String;

  protected func GetTimeoutValue(context: ScriptExecutionContext) -> Float {
    return AIBehaviorScriptBase.GetPuppet(context).GetFloatFromCharacterTweak(this.m_timeoutParamName);
  }
}

public abstract class AICooldown extends AITimeCondition {

  public edit let m_cooldown: Float;

  protected let m_timestamp: Float;

  protected func Check(context: ScriptExecutionContext) -> AIbehaviorConditionOutcomes {
    return Cast(AIBehaviorScriptBase.GetAITime(context) > this.m_timestamp);
  }

  protected final func UpdateTimeStamp(context: ScriptExecutionContext) -> Void {
    if this.m_cooldown > 0.00 {
      this.m_timestamp = AIBehaviorScriptBase.GetAITime(context) + this.m_cooldown;
    };
  }
}

public class CooldownOnActivation extends AICooldown {

  protected func Activate(context: ScriptExecutionContext) -> Void {
    this.UpdateTimeStamp(context);
  }
}

public class CooldownOnDeactivation extends AICooldown {

  protected func Deactivate(context: ScriptExecutionContext) -> Void {
    if AIBehaviorScriptBase.GetAITime(context) > this.m_timestamp {
      this.UpdateTimeStamp(context);
    };
  }
}
