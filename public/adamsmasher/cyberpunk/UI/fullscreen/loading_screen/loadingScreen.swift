
public class LoadingScreenProgressBarController extends inkLogicController {

  private edit let progressBarRoot: inkWidgetRef;

  private edit let progressBarFill: inkWidgetRef;

  private edit let progressSpinerRoot: inkWidgetRef;

  private let rotationAnimationProxy: ref<inkAnimProxy>;

  private let rotationAnimation: ref<inkAnimDef>;

  private let rotationInterpolator: ref<inkAnimRotation>;

  protected cb func OnInitialize() -> Bool {
    let animOptions: inkAnimOptions;
    animOptions.loopType = inkanimLoopType.Cycle;
    animOptions.loopInfinite = true;
    this.rotationAnimation = new inkAnimDef();
    this.rotationInterpolator = new inkAnimRotation();
    this.rotationInterpolator.SetDuration(1.00);
    this.rotationInterpolator.SetDirection(inkanimInterpolationDirection.To);
    this.rotationInterpolator.SetType(inkanimInterpolationType.Linear);
    this.rotationInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
    this.rotationInterpolator.SetEndRotation(180.00);
    this.rotationAnimation.AddInterpolator(this.rotationInterpolator);
    this.rotationAnimationProxy = inkWidgetRef.PlayAnimationWithOptions(this.progressSpinerRoot, this.rotationAnimation, animOptions);
  }

  public final func SetSpinnerVisibility(visible: Bool) -> Void {
    inkWidgetRef.SetVisible(this.progressSpinerRoot, visible);
  }

  public final func SetProgressBarVisiblity(visible: Bool) -> Void {
    inkWidgetRef.SetVisible(this.progressBarRoot, visible);
  }

  public final func SetProgress(progress: Float) -> Void {
    let scale: Vector2 = inkWidgetRef.GetScale(this.progressBarFill);
    scale.X = progress;
    inkWidgetRef.SetScale(this.progressBarFill, scale);
  }
}

public native class LoadingScreenLogicController extends ILoadingLogicController {

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
