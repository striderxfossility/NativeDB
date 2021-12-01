
public class TutorialPopupDisplayController extends inkLogicController {

  protected edit let m_title: inkTextRef;

  protected edit let m_message: inkTextRef;

  protected edit let m_image: inkImageRef;

  protected edit let m_video_1360x768: inkVideoRef;

  protected edit let m_video_1024x576: inkVideoRef;

  protected edit let m_video_1280x720: inkVideoRef;

  protected edit let m_video_720x405: inkVideoRef;

  protected edit let m_inputHint: inkWidgetRef;

  public final func SetData(data: ref<TutorialPopupData>) -> Void {
    inkTextRef.SetText(this.m_title, data.title);
    inkTextRef.SetText(this.m_message, data.message);
    this.SetVideoData(data.videoType, data.video);
    if TDBID.IsValid(data.imageId) {
      inkWidgetRef.SetVisible(this.m_image, true);
      InkImageUtils.RequestSetImage(this, this.m_image, data.imageId);
    } else {
      inkWidgetRef.SetVisible(this.m_image, false);
    };
    inkWidgetRef.SetVisible(this.m_inputHint, data.closeAtInput);
  }

  private final func SetVideoData(videoType: VideoType, video: ResRef) -> Void {
    inkWidgetRef.SetVisible(this.m_video_1360x768, false);
    inkWidgetRef.SetVisible(this.m_video_1024x576, false);
    inkWidgetRef.SetVisible(this.m_video_1280x720, false);
    inkWidgetRef.SetVisible(this.m_video_720x405, false);
    switch videoType {
      case VideoType.Tutorial_720x405:
        this.PlayVideo(this.m_video_720x405, video);
        break;
      case VideoType.Tutorial_1024x576:
        this.PlayVideo(this.m_video_1024x576, video);
        break;
      case VideoType.Tutorial_1280x720:
        this.PlayVideo(this.m_video_1280x720, video);
        break;
      case VideoType.Tutorial_1360x768:
        this.PlayVideo(this.m_video_1360x768, video);
        break;
      default:
    };
  }

  private final func PlayVideo(videoWidget: inkVideoRef, video: ResRef) -> Void {
    inkVideoRef.Stop(videoWidget);
    inkVideoRef.SetVideoPath(videoWidget, video);
    inkVideoRef.SetLoop(videoWidget, true);
    inkVideoRef.Play(videoWidget);
    inkWidgetRef.SetVisible(videoWidget, true);
  }
}
