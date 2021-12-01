
public class ScannerHintInkGameController extends inkGameController {

  private let m_messegeWidget: wref<inkText>;

  private let m_root: wref<inkWidget>;

  private edit let m_iconWidget: inkImageRef;

  private let m_OnShowMessegeCallback: ref<CallbackHandle>;

  private let m_OnMessegeUpdateCallback: ref<CallbackHandle>;

  private let m_OnVisionModeChangedCallback: ref<CallbackHandle>;

  protected cb func OnInitialize() -> Bool {
    this.m_messegeWidget = this.GetWidget(n"mainPanel/messege") as inkText;
    this.m_root = this.GetRootWidget();
    this.m_root.SetVisible(false);
    this.RegisterBlackboardCallbacks();
  }

  private final func GetOwner() -> ref<GameObject> {
    return this.GetOwnerEntity() as GameObject;
  }

  private final func RegisterBlackboardCallbacks() -> Void {
    let blackboard: ref<IBlackboard> = GameInstance.GetBlackboardSystem(this.GetOwner().GetGame()).Get(GetAllBlackboardDefs().HUD_Manager);
    if IsDefined(blackboard) {
      this.m_OnShowMessegeCallback = blackboard.RegisterListenerBool(GetAllBlackboardDefs().HUD_Manager.ShowHudHintMessege, this, n"OnShowMessege");
      this.m_OnMessegeUpdateCallback = blackboard.RegisterListenerString(GetAllBlackboardDefs().HUD_Manager.HudHintMessegeContent, this, n"OnMessegeUpdate");
    };
    blackboard = GameInstance.GetBlackboardSystem(this.GetOwner().GetGame()).GetLocalInstanced(this.GetPlayerControlledObject().GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
    if IsDefined(blackboard) {
      this.m_OnVisionModeChangedCallback = blackboard.RegisterListenerInt(GetAllBlackboardDefs().PlayerStateMachine.Vision, this, n"OnVisionModeChanged");
    };
  }

  protected cb func OnShowMessege(value: Bool) -> Bool {
    this.m_root.SetVisible(value);
  }

  protected cb func OnMessegeUpdate(value: String) -> Bool {
    if IsDefined(this.m_messegeWidget) {
      this.m_messegeWidget.SetLocalizedTextScript(value);
    };
  }

  protected cb func OnVisionModeChanged(value: Int32) -> Bool {
    let visionType: gameVisionModeType = IntEnum(value);
    if Equals(visionType, gameVisionModeType.Default) {
      inkImageRef.SetTexturePart(this.m_iconWidget, n"left_shoulder");
    } else {
      if Equals(visionType, gameVisionModeType.Focus) {
        inkImageRef.SetTexturePart(this.m_iconWidget, n"right_shoulder");
      };
    };
  }
}
