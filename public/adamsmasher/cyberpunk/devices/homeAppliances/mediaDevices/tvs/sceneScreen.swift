
public class SceneScreen extends GameObject {

  @attrib(category, "Animations")
  public inline let m_uiAnimationsData: ref<SceneScreenUIAnimationsData>;

  protected let m_blackboard: ref<IBlackboard>;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    super.OnRequestComponents(ri);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    this.CreateBlackboard();
    super.OnTakeControl(ri);
  }

  protected cb func OnChangeUIAnimEvent(evt: ref<ChangeUIAnimEvent>) -> Bool {
    this.SendDataToUIBlackboard(evt.animName);
  }

  protected final func SendDataToUIBlackboard(animName: CName) -> Void {
    this.GetBlackboard().SetName(GetAllBlackboardDefs().UI_SceneScreen.AnimName, animName);
    this.GetBlackboard().FireCallbacks();
  }

  public const func GetBlackboard() -> ref<IBlackboard> {
    return this.m_blackboard;
  }

  protected func CreateBlackboard() -> Void {
    this.m_blackboard = IBlackboard.Create(GetAllBlackboardDefs().UI_SceneScreen);
  }

  public final const func GetUIAnimationData() -> ref<SceneScreenUIAnimationsData> {
    return this.m_uiAnimationsData;
  }
}

public class ChangeUIAnimEvent extends Event {

  public edit let animName: CName;

  public final func GetFriendlyDescription() -> String {
    return "Change Anim On UI";
  }
}
