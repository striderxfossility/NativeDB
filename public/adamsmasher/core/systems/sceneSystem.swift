
public class BraindanceSystem extends ScriptableSystem {

  private persistent let inputMask: SBraindanceInputMask;

  private persistent let requestCameraToggle: Bool;

  private persistent let requestEditorState: Bool;

  private persistent let pauseBraindanceRequest: Bool;

  private persistent let isInBraindance: Bool;

  private let debugFFSceneThrehsold: Int32;

  private func IsSavingLocked() -> Bool {
    return this.isInBraindance;
  }

  private final func OnPlayerAttach(request: ref<PlayerAttachRequest>) -> Void {
    if !this.isInBraindance {
      this.inputMask.pauseAction = true;
      this.inputMask.playForwardAction = true;
      this.inputMask.playBackwardAction = true;
      this.inputMask.restartAction = true;
      this.inputMask.switchLayerAction = true;
      this.inputMask.cameraToggleAction = true;
      this.requestCameraToggle = false;
      this.requestEditorState = false;
      this.pauseBraindanceRequest = false;
      this.debugFFSceneThrehsold = 3;
    };
  }

  private func OnRestored(saveVersion: Int32, gameVersion: Int32) -> Void {
    this.inputMask.pauseAction = true;
    this.inputMask.playForwardAction = true;
    this.inputMask.playBackwardAction = true;
    this.inputMask.restartAction = true;
    this.inputMask.switchLayerAction = true;
    this.inputMask.cameraToggleAction = true;
    this.requestCameraToggle = false;
    this.requestEditorState = false;
    this.pauseBraindanceRequest = false;
    this.debugFFSceneThrehsold = 3;
  }

  public final const func GetInputMask() -> SBraindanceInputMask {
    return this.inputMask;
  }

  public final const func GetRequstCameraToggle() -> Bool {
    return this.requestCameraToggle;
  }

  public final const func GetRequestEditorState() -> Bool {
    return this.requestEditorState;
  }

  public final const func GetDebugFFSceneThreshold() -> Int32 {
    return this.debugFFSceneThrehsold;
  }

  public final const func GetIsInBraindance() -> Bool {
    return this.isInBraindance;
  }

  public final const func GetPauseBraindanceRequest() -> Bool {
    return this.pauseBraindanceRequest;
  }

  private final func SetInputMask(newMask: SBraindanceInputMask) -> Void {
    this.inputMask = newMask;
  }

  private final func SetDebugFFSceneThreshold(newThreshold: Int32) -> Void {
    this.debugFFSceneThrehsold = newThreshold;
  }

  private final func SetIsInBraindance(newState: Bool) -> Void {
    this.isInBraindance = newState;
  }

  private final func ApplyORMask(mask: SBraindanceInputMask) -> Void {
    let retMask: SBraindanceInputMask;
    let globalMask: SBraindanceInputMask = this.GetInputMask();
    retMask.pauseAction = mask.pauseAction || globalMask.pauseAction;
    retMask.playForwardAction = mask.playForwardAction || globalMask.playForwardAction;
    retMask.playBackwardAction = mask.playBackwardAction || globalMask.playBackwardAction;
    retMask.restartAction = mask.restartAction || globalMask.restartAction;
    retMask.switchLayerAction = mask.switchLayerAction || globalMask.switchLayerAction;
    retMask.cameraToggleAction = mask.cameraToggleAction || globalMask.cameraToggleAction;
    this.SetInputMask(retMask);
  }

  private final func ApplyInvertedANDMask(mask: SBraindanceInputMask) -> Void {
    let retMask: SBraindanceInputMask;
    let globalMask: SBraindanceInputMask = this.GetInputMask();
    retMask.pauseAction = !mask.pauseAction && globalMask.pauseAction;
    retMask.playForwardAction = !mask.playForwardAction && globalMask.playForwardAction;
    retMask.playBackwardAction = !mask.playBackwardAction && globalMask.playBackwardAction;
    retMask.restartAction = !mask.restartAction && globalMask.restartAction;
    retMask.switchLayerAction = !mask.switchLayerAction && globalMask.switchLayerAction;
    retMask.cameraToggleAction = !mask.cameraToggleAction && globalMask.cameraToggleAction;
    this.SetInputMask(retMask);
  }

  private final func SetEditorStateRequest(newState: Bool) -> Void {
    this.requestCameraToggle = true;
    this.requestEditorState = newState;
  }

  private final func ClearEditorStateRequest() -> Void {
    this.requestCameraToggle = false;
    this.requestEditorState = false;
  }

  private final func SetPauseRequest() -> Void {
    this.pauseBraindanceRequest = true;
  }

  private final func ClearPauseRequest() -> Void {
    this.pauseBraindanceRequest = false;
  }

  private final func OnEnableFields(request: ref<EnableFields>) -> Void {
    this.ApplyORMask(request.actionMask);
  }

  private final func OnDisableFields(request: ref<DisableFields>) -> Void {
    this.ApplyInvertedANDMask(request.actionMask);
  }

  private final func OnSetBraindanceState(request: ref<SetBraindanceState>) -> Void {
    this.SetEditorStateRequest(request.newState);
  }

  private final func OnClearBraindanceStateRequest(request: ref<ClearBraindanceStateRequest>) -> Void {
    this.ClearEditorStateRequest();
  }

  private final func OnSendPauseBraindanceRequest(request: ref<SendPauseBraindanceRequest>) -> Void {
    this.SetPauseRequest();
  }

  private final func OnClearBraindancePauseRequest(request: ref<ClearBraindancePauseRequest>) -> Void {
    this.ClearPauseRequest();
  }

  private final func OnSetDebugSceneThrehsold(request: ref<SetDebugSceneThrehsold>) -> Void {
    this.SetDebugFFSceneThreshold(request.newThreshold);
  }

  private final func OnSetIsInBraindance(request: ref<SetIsInBraindance>) -> Void {
    this.SetIsInBraindance(request.newState);
  }
}

public static exec func DbgBraindanceIsActive(gameInstance: GameInstance) -> Void {
  let value: Bool = GameInstance.GetSceneSystem(gameInstance).GetScriptInterface().IsRewindableSectionActive();
  Log("Braindance active: " + BoolToString(value));
}

public static exec func DbgBraindanceProgress(gameInstance: GameInstance) -> Void {
  let value: Float = GameInstance.GetSceneSystem(gameInstance).GetScriptInterface().GetRewindableSectionProgress();
  Log("Braindance progress: " + FloatToString(value * 100.00) + "%");
}

public static exec func DbgBraindanceTimeInSec(gameInstance: GameInstance) -> Void {
  let value: Float = GameInstance.GetSceneSystem(gameInstance).GetScriptInterface().GetRewindableSectionTimeInSec();
  Log("Braindance time: " + FloatToString(value) + "s");
}

public static exec func DbgBraindancePlayDirection(gameInstance: GameInstance) -> Void {
  let value: scnPlayDirection = GameInstance.GetSceneSystem(gameInstance).GetScriptInterface().GetRewindableSectionPlayDirection();
  Log("Braindance play direction: " + EnumValueToString("scnPlayDirection", Cast(EnumInt(value))));
}

public static exec func DbgBraindanceSetPlayDirection(gameInstance: GameInstance, direction: String) -> Void {
  let directionInt: Int32 = Cast(EnumValueFromString("scnPlayDirection", direction));
  if directionInt != -1 {
    GameInstance.GetSceneSystem(gameInstance).GetScriptInterface().SetRewindableSectionPlayDirection(IntEnum(directionInt));
  };
}

public static exec func DbgBraindancePlaySpeed(gameInstance: GameInstance) -> Void {
  let value: scnPlaySpeed = GameInstance.GetSceneSystem(gameInstance).GetScriptInterface().GetRewindableSectionPlaySpeed();
  Log("Braindance play speed: " + EnumValueToString("scnPlaySpeed", Cast(EnumInt(value))));
}

public static exec func DbgBraindanceSetPlaySpeed(gameInstance: GameInstance, speed: String) -> Void {
  let speedInt: Int32 = Cast(EnumValueFromString("scnPlaySpeed", speed));
  if speedInt != -1 {
    GameInstance.GetSceneSystem(gameInstance).GetScriptInterface().SetRewindableSectionPlaySpeed(IntEnum(speedInt));
  };
}

public static exec func DbgBraindanceIsPaused(gameInstance: GameInstance) -> Void {
  let value: Bool = GameInstance.GetSceneSystem(gameInstance).GetScriptInterface().IsRewindableSectionPaused();
  Log("Braindance paused: " + BoolToString(value));
}

public static exec func EnterBD(gameInstance: GameInstance) -> Void {
  let psmAdd: ref<PSMAddOnDemandStateMachine> = new PSMAddOnDemandStateMachine();
  psmAdd.stateMachineName = n"BraindanceControls";
  GetPlayer(gameInstance).QueueEvent(psmAdd);
  AnimationControllerComponent.SetInputBool(GetPlayer(gameInstance), n"disable_camera_bobbing", true);
}

public static exec func LeaveBD(gameInstance: GameInstance) -> Void {
  let stateMachineIdentifier: StateMachineIdentifier;
  let psmRem: ref<PSMRemoveOnDemandStateMachine> = new PSMRemoveOnDemandStateMachine();
  stateMachineIdentifier.definitionName = n"BraindanceControls";
  psmRem.stateMachineIdentifier = stateMachineIdentifier;
  GetPlayer(gameInstance).QueueEvent(psmRem);
  AnimationControllerComponent.SetInputBool(GetPlayer(gameInstance), n"disable_camera_bobbing", false);
}
