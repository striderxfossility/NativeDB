
public class ScriptableVirtualCameraViewComponent extends VirtualCameraViewComponent {

  protected cb func OnFeedChange(evt: ref<FeedEvent>) -> Bool {
    this.Toggle(evt.On);
  }
}
