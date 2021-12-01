
public class LookAtTargetExecutor extends EffectExecutor_Scripted {

  public final func Process(ctx: EffectScriptContext, applierCtx: EffectExecutionScriptContext) -> Bool {
    let aimRequestData: AimRequest;
    aimRequestData.duration = 0.25;
    aimRequestData.easeIn = true;
    aimRequestData.easeOut = true;
    aimRequestData.adjustPitch = true;
    aimRequestData.adjustYaw = true;
    aimRequestData.checkRange = true;
    aimRequestData.endOnCameraInputApplied = false;
    aimRequestData.cameraInputMagToBreak = 0.20;
    aimRequestData.endOnTargetReached = false;
    aimRequestData.endOnTimeExceeded = true;
    aimRequestData.processAsInput = true;
    let target: ref<Entity> = EffectExecutionScriptContext.GetTarget(applierCtx);
    if IsDefined(target as ScriptedPuppet) {
      GameInstance.GetTargetingSystem(EffectScriptContext.GetGameInstance(ctx)).LookAt(EffectScriptContext.GetInstigator(ctx) as GameObject, aimRequestData);
    };
    return true;
  }
}
