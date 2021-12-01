
public class CreditsGameController extends gameuiCreditsController {

  private edit let m_videoContainer: inkCompoundRef;

  private edit let m_sceneTexture: inkImageRef;

  private edit let m_backgroundVideo: inkVideoRef;

  private edit let m_binkVideo: inkVideoRef;

  private edit const let m_binkVideos: array<BinkResource>;

  private let m_currentBinkVideo: Int32;

  private let m_videoSummary: VideoWidgetSummary;

  private let m_isDataSet: Bool;

  protected cb func OnInitialize() -> Bool {
    this.InitializeCredits();
  }

  protected cb func OnUpdate(timeDelta: Float) -> Bool;

  protected cb func OnUninitialize() -> Bool {
    inkVideoRef.Stop(this.m_backgroundVideo);
    inkVideoRef.Stop(this.m_binkVideo);
  }

  protected cb func OnSetUserData(data: ref<IScriptable>) -> Bool {
    if data as CreditsData.isFinalBoards {
      inkWidgetRef.SetVisible(this.m_sceneTexture, true);
      inkWidgetRef.SetVisible(this.m_binkVideo, false);
    } else {
      inkWidgetRef.SetVisible(this.m_sceneTexture, false);
      inkWidgetRef.SetVisible(this.m_binkVideo, true);
    };
    this.shouldShowRewardPrompt = data as CreditsData.showRewardPrompt;
    this.isInFinalBoardsMode = data as CreditsData.isFinalBoards;
    this.m_isDataSet = true;
  }

  private final func InitializeCredits() -> Void {
    if Equals(this.m_isDataSet, false) {
      inkWidgetRef.SetVisible(this.m_sceneTexture, false);
      inkWidgetRef.SetVisible(this.m_binkVideo, true);
    };
    inkVideoRef.Play(this.m_backgroundVideo);
    inkWidgetRef.SetTranslation(this.m_binkVideo, -400.00, 0.00);
  }

  private final func PlayNextVideo() -> Void {
    let ratio: Float;
    let videoContainerSize: Vector2;
    if this.m_currentBinkVideo >= ArraySize(this.m_binkVideos) {
      return;
    };
    videoContainerSize = inkWidgetRef.GetSize(this.m_videoContainer);
    inkVideoRef.SetVideoPath(this.m_binkVideo, BinkResource.GetPath(this.m_binkVideos[this.m_currentBinkVideo]));
    if !inkVideoRef.IsPlayingVideo(this.m_binkVideo) {
      inkVideoRef.Play(this.m_binkVideo);
      this.m_videoSummary = inkVideoRef.GetVideoWidgetSummary(this.m_binkVideo);
      ratio = Cast(this.m_videoSummary.width) / Cast(this.m_videoSummary.height);
      inkWidgetRef.SetSize(this.m_binkVideo, videoContainerSize.X, videoContainerSize.X / ratio);
    };
    this.m_currentBinkVideo += 1;
  }
}
