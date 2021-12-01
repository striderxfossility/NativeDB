
public class PopupStateUtils extends IScriptable {

  public final static func SetBackgroundBlurBlendTime(gameCtrl: ref<inkGameController>, blendTime: Float) -> Void {
    let uiSystemBB: ref<UI_SystemDef> = GetAllBlackboardDefs().UI_System;
    let blackboard: ref<IBlackboard> = gameCtrl.GetBlackboardSystem().Get(uiSystemBB);
    blackboard.SetFloat(uiSystemBB.CircularBlurBlendTime, blendTime);
  }

  public final static func SetBackgroundBlur(gameCtrl: ref<inkGameController>, enable: Bool) -> Void {
    let uiSystemBB: ref<UI_SystemDef> = GetAllBlackboardDefs().UI_System;
    let blackboard: ref<IBlackboard> = gameCtrl.GetBlackboardSystem().Get(uiSystemBB);
    blackboard.SetBool(uiSystemBB.CircularBlurEnabled, enable);
  }
}
