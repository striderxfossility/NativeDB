
public class SceneScreenGameController extends inkGameController {

  private let m_onQuestAnimChangeListener: ref<CallbackHandle>;

  protected cb func OnInitialize() -> Bool {
    this.RegisterBlackboardCallbacks(this.GetBlackboard());
  }

  protected final func RegisterBlackboardCallbacks(blackboard: ref<IBlackboard>) -> Void {
    if IsDefined(blackboard) {
      this.m_onQuestAnimChangeListener = blackboard.RegisterListenerName(GetAllBlackboardDefs().UI_SceneScreen.AnimName, this, n"OnQuestAnimChange");
    };
  }

  private final func UnRegisterBlackboardCallbacks(blackboard: ref<IBlackboard>) -> Void {
    if IsDefined(blackboard) {
      blackboard.UnregisterListenerName(GetAllBlackboardDefs().UI_SceneScreen.AnimName, this.m_onQuestAnimChangeListener);
    };
  }

  protected cb func OnQuestAnimChange(value: CName) -> Bool {
    this.PlayLibraryAnimation(value);
  }

  protected final func GetOwner() -> ref<SceneScreen> {
    return this.GetOwnerEntity() as SceneScreen;
  }

  protected final func GetBlackboard() -> ref<IBlackboard> {
    let device: ref<SceneScreen> = this.GetOwner();
    if IsDefined(device) {
      return device.GetBlackboard();
    };
    return null;
  }
}
