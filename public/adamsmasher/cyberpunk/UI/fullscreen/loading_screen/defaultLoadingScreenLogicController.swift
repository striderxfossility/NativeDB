
public native class DefaultLoadingScreenLogicController extends ILoadingLogicController {

  private edit let progressBarRoot: inkWidgetRef;

  private edit let progressBarController: wref<LoadingScreenProgressBarController>;

  protected cb func OnInitialize() -> Bool {
    this.progressBarController = inkWidgetRef.GetController(this.progressBarRoot) as LoadingScreenProgressBarController;
  }

  protected final func SetProgressIndicatorVisibility(visible: Bool) -> Void {
    this.progressBarController.SetSpinnerVisibility(visible);
  }

  protected final func SetSpinnerVisiblility(visible: Bool) -> Void {
    this.progressBarController.SetProgressBarVisiblity(visible);
  }

  protected final func SetLoadProgress(progress: Float) -> Void {
    this.progressBarController.SetProgress(progress);
  }
}
