
public native class HoldIndicatorGameController extends inkGameController {

  protected cb func OnInitialize() -> Bool {
    this.RegisterToCallback(n"OnHoldProgress", this, n"OnHoldProgress");
    this.RegisterToCallback(n"OnHoldStart", this, n"OnHoldStart");
    this.RegisterToCallback(n"OnHoldFinish", this, n"OnHoldFinish");
    this.RegisterToCallback(n"OnHoldStop", this, n"OnHoldStop");
    if IsNoInputIconsModeEnabled() {
      this.GetRootWidget().SetVisible(false);
    };
  }

  protected cb func OnHoldProgress(value: Float) -> Bool {
    this.HoldProgress(value);
  }

  protected cb func OnHoldStart() -> Bool {
    this.HoldStart();
  }

  protected cb func OnHoldFinish() -> Bool {
    this.HoldFinish();
  }

  protected cb func OnHoldStop() -> Bool {
    this.HoldStop();
  }

  protected func HoldProgress(value: Float) -> Void;

  protected func HoldStart() -> Void;

  protected func HoldFinish() -> Void;

  protected func HoldStop() -> Void;
}

public class GamepadHoldIndicatorGameController extends HoldIndicatorGameController {

  private edit let m_image: inkImageRef;

  @default(GamepadHoldIndicatorGameController, icon_circle_anim_)
  private edit let m_partName: String;

  private let m_progress: Int32;

  private let m_animProxy: ref<inkAnimProxy>;

  protected cb func OnInitialize() -> Bool {
    super.OnInitialize();
    inkWidgetRef.SetVisible(this.m_image, false);
    this.SetProgress(0);
  }

  protected func HoldProgress(value: Float) -> Void {
    this.HoldProgress(value);
    this.SetProgress(Cast(value * 100.00));
  }

  protected func HoldStart() -> Void {
    this.HoldStart();
    if Equals(IsNoInputIconsModeEnabled(), false) {
      inkWidgetRef.SetVisible(this.m_image, true);
      if IsDefined(this.m_animProxy) {
        this.m_animProxy.Stop();
      };
      this.m_animProxy = this.PlayLibraryAnimation(n"hold");
    };
  }

  protected func HoldFinish() -> Void {
    this.HoldFinish();
    if IsDefined(this.m_animProxy) {
      this.m_animProxy.Stop();
      this.m_animProxy = null;
    };
    inkWidgetRef.SetVisible(this.m_image, false);
  }

  protected func HoldStop() -> Void {
    this.HoldStop();
    if IsDefined(this.m_animProxy) {
      this.m_animProxy.Stop();
      this.m_animProxy = null;
    };
    inkWidgetRef.SetVisible(this.m_image, false);
  }

  private final func SetProgress(value: Int32) -> Void {
    let partName: CName;
    value = Clamp(value, 0, 99);
    if this.m_progress != value {
      this.m_progress = value;
      partName = StringToName(this.m_partName + IntToString(this.m_progress));
      inkImageRef.SetTexturePart(this.m_image, partName);
    };
  }
}

public class KeyboardHoldIndicatorGameController extends HoldIndicatorGameController {

  private edit let m_progress: inkImageRef;

  protected func HoldProgress(value: Float) -> Void {
    inkWidgetRef.SetScale(this.m_progress, new Vector2(1.00, value));
  }

  protected func HoldStart() -> Void {
    inkWidgetRef.SetVisible(this.m_progress, true);
  }

  protected func HoldFinish() -> Void {
    inkWidgetRef.SetVisible(this.m_progress, false);
  }

  protected func HoldStop() -> Void {
    inkWidgetRef.SetVisible(this.m_progress, false);
  }
}
