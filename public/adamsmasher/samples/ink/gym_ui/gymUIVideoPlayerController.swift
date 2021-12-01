
public class sampleUIVideoPlayer extends inkLogicController {

  public edit let videoWidgetPath: CName;

  public edit let counterWidgetPath: CName;

  public edit let lastFramePath: CName;

  public edit let currentFramePath: CName;

  private let videoWidget: wref<inkVideo>;

  private let framesToSkipCounterWidget: wref<inkText>;

  private let lastFrameWidget: wref<inkText>;

  private let currentFrameWidget: wref<inkText>;

  private let m_numberOfFrames: Uint32;

  protected cb func OnInitialize() -> Bool {
    this.videoWidget = this.GetWidget(this.videoWidgetPath) as inkVideo;
    this.framesToSkipCounterWidget = this.GetWidget(this.counterWidgetPath) as inkText;
    this.lastFrameWidget = this.GetWidget(this.lastFramePath) as inkText;
    this.currentFrameWidget = this.GetWidget(this.currentFramePath) as inkText;
    this.UpdateCounter();
    this.UpdateTextWidgets();
  }

  public final func PlayPauseVideo(e: ref<inkPointerEvent>) -> Void {
    if this.videoWidget.IsPlayingVideo() {
      if this.videoWidget.IsPaused() {
        this.videoWidget.Resume();
      } else {
        this.videoWidget.Pause();
      };
    } else {
      this.videoWidget.Play();
    };
    this.UpdateTextWidgets();
  }

  public final func StopVideo(e: ref<inkPointerEvent>) -> Void {
    this.videoWidget.Stop();
  }

  public final func PauseVideo(e: ref<inkPointerEvent>) -> Void {
    this.videoWidget.Pause();
    this.UpdateTextWidgets();
  }

  public final func ResumeVideo(e: ref<inkPointerEvent>) -> Void {
    this.videoWidget.Resume();
    this.UpdateTextWidgets();
  }

  public final func Rewind(e: ref<inkPointerEvent>) -> Void {
    this.videoWidget.RewindTo(this.m_numberOfFrames);
    this.UpdateTextWidgets();
  }

  public final func FastForward(e: ref<inkPointerEvent>) -> Void {
    this.videoWidget.FastForwardTo(this.m_numberOfFrames);
    this.UpdateTextWidgets();
  }

  public final func JumpToFrame(e: ref<inkPointerEvent>) -> Void {
    this.videoWidget.JumpToFrame(this.m_numberOfFrames);
    this.UpdateTextWidgets();
  }

  public final func JumpToTime(e: ref<inkPointerEvent>) -> Void {
    this.videoWidget.JumpToTime(Cast(this.m_numberOfFrames));
    this.UpdateTextWidgets();
  }

  public final func RiseFramesCounter(e: ref<inkPointerEvent>) -> Void {
    this.m_numberOfFrames += 1u;
    this.UpdateCounter();
  }

  public final func LowerFramesCounter(e: ref<inkPointerEvent>) -> Void {
    this.m_numberOfFrames -= 1u;
    this.UpdateCounter();
  }

  private final func UpdateTextWidgets() -> Void {
    let videoSummary: VideoWidgetSummary = this.videoWidget.GetVideoWidgetSummary();
    this.currentFrameWidget.SetText(ToString(videoSummary.currentFrame));
    this.lastFrameWidget.SetText(ToString(videoSummary.totalFrames));
  }

  private final func UpdateCounter() -> Void {
    this.framesToSkipCounterWidget.SetText(ToString(this.m_numberOfFrames));
  }
}
