
public static func Cast(flag: EAIGateSignalFlags) -> AISignalFlags {
  switch flag {
    case EAIGateSignalFlags.AIGSF_Undefined:
      return AISignalFlags.Undefined;
    case EAIGateSignalFlags.AIGSF_OverridesSelf:
      return AISignalFlags.OverridesSelf;
    case EAIGateSignalFlags.AIGSF_InterruptsSamePriorityTask:
      return AISignalFlags.InterruptsSamePriorityTask;
    case EAIGateSignalFlags.AIGSF_InterruptsForcedBehavior:
      return AISignalFlags.InterruptsForcedBehavior;
    case EAIGateSignalFlags.AIGSF_AcceptsAdditives:
      return AISignalFlags.AcceptsAdditives;
    default:
      return AISignalFlags.Undefined;
  };
}
