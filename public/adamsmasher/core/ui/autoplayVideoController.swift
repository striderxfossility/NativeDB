
public class AutoplayVideoController extends inkLogicController {

  protected cb func OnInitialize() -> Bool {
    let video: ref<inkVideo> = this.GetRootWidget() as inkVideo;
    if !video.IsPlayingVideo() {
      video.Play();
    };
  }
}
